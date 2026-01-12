import 'package:file_dock/controllers/file_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoScreen extends StatefulWidget {
  final String id;
  const VideoScreen({super.key, required this.id});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool isLoading = true;
  bool _countedView = false;
  String? storagePath;

  final FileManagerController fileManagerController =
    Get.find<FileManagerController>();


  String generateStorageUrl(String path) {
    final encoded = Uri.encodeComponent(path);
    return "https://firebasestorage.googleapis.com/v0/b/filedoc-64d48.appspot.com/o/$encoded?alt=media";
  }

  @override
  void initState() {
    super.initState();
    fetchVideo();
  }

  Future<void> fetchVideo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("videos")
          .doc(widget.id)
          .get();

      if (!doc.exists) {
        setState(() => isLoading = false);
        return;
      }

      storagePath = doc.data()?["storagePath"];
      if (storagePath == null) {
        setState(() => isLoading = false);
        return;
      }

      final url = generateStorageUrl(storagePath!);
      debugPrint("🎬 VIDEO URL: $url");

      // Important: network buffering problem fix
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoController!.initialize();
      await _videoController!.play(); // autoplay

      _videoController!.addListener(() {
  if (_videoController!.value.isInitialized &&
      _videoController!.value.position.inSeconds >= 1 &&
      !_countedView) {
    _countedView = true;

    fileManagerController.countViewOnce(
      videoId: widget.id,
    );
  }
});


      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControlsOnInitialize: true,
        allowFullScreen: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              "⚠ Video cannot be played.\n$errorMessage",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        },
      );

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Watch Video")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chewieController == null
              ? const Center(
                  child: Text(
                    "⚠ Video not found!",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Chewie(controller: _chewieController!),
    );
  }
}
