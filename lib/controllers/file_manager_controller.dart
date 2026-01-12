 // import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_dock/model/videoModel.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// class FileManagerController extends GetxController {
//   var files = <VideoModel>[].obs;

//   Future<void> fetchVideos() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection("videos")
//         .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//         .get();

//     files.value = snapshot.docs
//         .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
//         .toList();
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchVideos();
//   }

//   Future<void> onRefresh() async {
//     try {
//       await fetchVideos();
//       Get.snackbar("Refreshed", "Video list updated", colorText: Colors.black);
//     } catch (e) {
//       Get.snackbar("Error", "Failed to refresh: $e");
//     }
//   }

//   Future<void> deleteFile(int index) async {
//     try {
//       final video = files[index];

//       // 1. Delete Firestore document
//       await FirebaseFirestore.instance
//           .collection("videos")
//           .doc(video.id)
//           .delete();

//       // 2. Delete file from Firebase Storage (if stored there)
//       if (video.storageUrl != null && video.storageUrl!.isNotEmpty) {
//         final ref = FirebaseStorage.instance.refFromURL(video.storageUrl!);
//         await ref.delete();
//       }

//       // 3. Remove from local list
//       files.removeAt(index);

//       Get.snackbar("Deleted", "${video.title} removed successfully");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to delete: $e");
//     }
//   }

//   void copyFileLink(VideoModel video) {
//     Clipboard.setData(ClipboardData(text: "https://filedock/${video.id}"));
//     Get.snackbar("Copied", "https://filedock/${video.id}  link copied!");
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_dock/model/videoModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FileManagerController extends GetxController {
var files = <VideoModel>[].obs;
StreamSubscription? _subscription;



@override
void onInit() {
super.onInit();
_listenVideos();
}

  /// 🔥 UNIQUE VIEW COUNT (Shorts / Scoop-of-Work style)
Future<void> countViewOnce({
  required String videoId,
}) async {
  String userId;

  // 🔐 Logged-in or guest
  if (FirebaseAuth.instance.currentUser != null) {
    userId = FirebaseAuth.instance.currentUser!.uid;
  } else {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    userId = androidInfo.id;
  }

  final videoRef =
      FirebaseFirestore.instance.collection('videos').doc(videoId);

  final viewerRef =
      videoRef.collection('viewedBy').doc(userId);

  final viewerSnap = await viewerRef.get();
  if (viewerSnap.exists) return; // ❌ already counted

  await FirebaseFirestore.instance.runTransaction((tx) async {
    tx.set(viewerRef, {
      'viewedAt': FieldValue.serverTimestamp(),
    });

    /// 👁️ UNIQUE VIEW + 💰 EARNING
    tx.update(videoRef, {
      'uniqueViews': FieldValue.increment(1),
      'earnings': FieldValue.increment(0.01), // ₹0.01 per view
    });
  });

  /// 📊 DAILY ANALYTICS
  await FirebaseFirestore.instance
      .collection('analytics')
      .doc(userId)
      .collection('days')
      .doc(DateTime.now().toString().substring(0, 10))
      .set({
    'views': FieldValue.increment(1),
    'earnings': FieldValue.increment(0.01),
  }, SetOptions(merge: true));
}


Future<void> incrementClick(String videoId) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final videoRef =
      FirebaseFirestore.instance.collection("videos").doc(videoId);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    tx.update(videoRef, {
      'clickCount': FieldValue.increment(1),
      'earnings': FieldValue.increment(0.05), // ₹0.05 per click
    });
  });

  /// 📊 DAILY ANALYTICS
  await FirebaseFirestore.instance
      .collection('analytics')
      .doc(uid)
      .collection('days')
      .doc(DateTime.now().toString().substring(0, 10))
      .set({
    'clicks': FieldValue.increment(1),
    'earnings': FieldValue.increment(0.05),
  }, SetOptions(merge: true));
}




void _listenVideos() {
final uid = FirebaseAuth.instance.currentUser!.uid;

_subscription = FirebaseFirestore.instance
    .collection("videos")
    .where("userId", isEqualTo: uid)
.orderBy("createdAt", descending: true)
    .snapshots()
    .listen((snapshot) {
files.value = snapshot.docs
    .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
    .toList();
});
}

Future<void> refreshFiles() async {
_subscription?.cancel();
_listenVideos();
}

Future<void> deleteFile(int index) async {
try {
final video = files[index];

// Delete from Firestore
await FirebaseFirestore.instance
    .collection("videos")
    .doc(video.id)
    .delete();

// Decrease videoCount in user document
await FirebaseFirestore.instance
    .collection("users")
    .doc(video.userId)
    .update({"videoCount": FieldValue.increment(-1)});

// Delete from Firebase Storage
if (video.storageUrl.isNotEmpty) {
final ref = FirebaseStorage.instance.refFromURL(video.storageUrl);
await ref.delete();
}

// ❌ Don't do files.removeAt(index) because listener will handle it
// files.removeAt(index);

Get.snackbar(
"Deleted",
"${video.title} removed successfully",
colorText: Colors.white,
);
} catch (e) {
print("ERROR : ${e.toString()}");
Get.snackbar("Error", "Failed to delete: $e", colorText: Colors.white);
}
}

void copyFileLink(VideoModel video) {
Clipboard.setData(ClipboardData(text: video.shortUrl));
Get.snackbar(
"Copied",
colorText: Colors.white,
"URL copied to clipboard",
snackPosition: SnackPosition.BOTTOM,
);
}

@override
void onClose() {
_subscription?.cancel();
super.onClose();
}
}
