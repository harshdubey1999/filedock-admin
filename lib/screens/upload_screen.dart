import 'package:file_dock/controllers/nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/colors.dart';
import '../controllers/file_manager_controller.dart';
import '../controllers/uploadcontroller.dart';
import '../widget/custom_app_bar.dart';

class UploadScreen extends StatelessWidget {
  UploadScreen({super.key});

  final UploadController uploadController = Get.put(UploadController());
  final NavController navController = Get.put(NavController());
  final FileManagerController fileManagerController =
      Get.put(FileManagerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbg1black500,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          /// 🌄 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/home_BG.jpg"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
          ),

          /// 📦 Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _title(),
                const SizedBox(height: 25),
                _cloudText(),
                const SizedBox(height: 10),
                _uploadBox(),
                const SizedBox(height: 20),
                _uploadButton(),
                const SizedBox(height: 14),
                _infoNote(),
                const SizedBox(height: 30),
                _uploadedFilesHeader(),
                const SizedBox(height: 15),
                _uploadedFilesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI PARTS ----------------

  Widget _title() => Text(
        "Upload Videos",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: kwhite,
        ),
      );

  Widget _cloudText() => Text(
        "FileDock Cloud",
        style: TextStyle(
          fontSize: 16,
          color: ktext2white200,
        ),
      );

  Widget _uploadBox() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kbg2lightblack300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Upload your files",
              style: TextStyle(
                color: kblueaccent,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Icon(Icons.cloud_upload, color: kwhite, size: 46),
            const SizedBox(height: 18),
            Text(
              "Only Local Video Files",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ktext2white200,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );

  Widget _uploadButton() => Obx(() {
        if (uploadController.isUploading.value) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
                color: kbg2lightblack300,
                borderRadius: BorderRadius.circular(30)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      value: uploadController.uploadProgress.value,
                      color: kblueaccent,
                      strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                    "${(uploadController.uploadProgress.value * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                        color: kwhite, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        return SizedBox(
          height: 50,
          width: 180,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kblueaccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: uploadController.pickAndUploadVideo,
            icon: const Icon(Icons.file_upload_outlined, color: Colors.black),
            label: const Text(
              "Upload",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      });

  Widget _infoNote() => Text(
        "If you face issues with Jio Internet, please try using a VPN or set DNS to Cloudflare DNS.",
        textAlign: TextAlign.center,
        style: TextStyle(color: kwhite, fontSize: 14),
      );

  Widget _uploadedFilesHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionTitle("Uploaded Files"),
          InkWell(
            onTap: () => navController.changeIndex(2),
            child: Row(
              children: [
                Text(
                  "View All",
                  style: TextStyle(color: ktext1white100, fontSize: 14),
                ),
                const SizedBox(width: 5),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: ktext1white100),
              ],
            ),
          ),
        ],
      );

  Widget _uploadedFilesList() {
    return Obx(() {
      if (fileManagerController.files.isEmpty) {
        return _emptyBox();
      }

      return Column(
        children: fileManagerController.files.map((video) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _videoIcon(),
                const SizedBox(width: 12),

                /// 📄 File Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shortUrl(video.id, video.shortUrl),
                      const SizedBox(height: 6),

                      /// Size + Date
                      Row(
                        children: [
                          Text(
                            "${(video.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                            style: TextStyle(
                              color: ktext3white300,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat("dd/MM/yyyy • hh:mm a")
                                .format(video.createdAt),
                            style: TextStyle(
                              color: ktext3white300,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// 📋 Copy Button
                InkWell(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: video.shortUrl));
                    Get.snackbar(
                      "Copied",
                      "URL copied to clipboard",
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svg icons/file manager svg/copy.svg',
                    height: 24,
                    width: 24,
                    color: kblueaccent,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  // ---------------- SMALL WIDGETS ----------------

  Widget _videoIcon() => Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          color: ktext2white200.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.videocam, color: kblueaccent, size: 28),
      );

  Widget _shortUrl(String videoId, String shortUrl) => GestureDetector(
        onTap: () async {
          final uri = Uri.parse(
              "https://filedock.in/details?videoId=$videoId");
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri,
                mode: LaunchMode.externalApplication);
          }
        },
        child: Text(
          shortUrl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: kblueaccent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      );

  Widget _emptyBox() => Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kbg2lightblack300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_copy,
                color: ktext2white200, size: 30),
            const SizedBox(height: 6),
            Text(
              "No Uploaded Files",
              style:
                  TextStyle(color: ktext2white200, fontSize: 13),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String text) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: ktext1white100,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: kblueaccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      );
}
