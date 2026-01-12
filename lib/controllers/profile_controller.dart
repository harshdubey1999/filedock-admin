// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_dock/model/userModel.dart';
// import 'package:file_dock/screens/login_screen.dart';
// import 'package:file_dock/screens/signInScreen.dart';
// import 'package:file_dock/screens/splashscreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class ProfileController extends GetxController {
//   final _auth = FirebaseAuth.instance;
//   final _db = FirebaseFirestore.instance;

//   final Rx<UserModel?> user = Rx<UserModel?>(null);
//   final isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserData();
//   }

//   // Future<void> fetchUserData() async {
//   //   try {
//   //     isLoading.value = true;
//   //     final firebaseUser = _auth.currentUser;

//   //     if (firebaseUser != null) {
//   //       final docSnapshot = await _db
//   //           .collection("users")
//   //           .doc(firebaseUser.uid)
//   //           .get();

//   //       if (docSnapshot.exists) {
//   //         user.value = UserModel.fromSnapshot(docSnapshot);
//   //       } else {
//   //         Get.snackbar("Error", "User profile data not found.");
//   //       }
//   //     }
//   //   } catch (e) {
//   //     Get.snackbar("Error", "Failed to fetch user data: ${e.toString()}");
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }

//   void fetchUserData() {
//     final firebaseUser = _auth.currentUser;

//     if (firebaseUser != null) {
//       _db
//           .collection("users")
//           .doc(firebaseUser.uid)
//           .snapshots() // ✅ realtime stream
//           .listen((docSnapshot) {
//             if (docSnapshot.exists) {
//               user.value = UserModel.fromSnapshot(docSnapshot);
//             } else {
//               Get.snackbar("Error", "User profile data not found.");
//             }
//           });
//     }
//   }

//   Future<void> refreshData() async {
//     try {
//       fetchUserData();
//       Get.snackbar("Data Refreshed", "Your Profile details Refreshed");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to refresh: $e");
//     }
//   }

//   Future<void> logout() async {
//     try {
//       await _auth.signOut();
//       Get.offAll(LoginWithGoogle());
//       Get.snackbar("Logged Out", "You have been logged out successfully.");
//     } catch (e) {
//       Get.snackbar("Logout Error", "Failed to log out: ${e.toString()}");
//     }
//   }

//   String get photoUrl {
//     // Prefer Firestore photoUrl, else Firebase Auth ka
//     return user.value?.photoUrl ?? _auth.currentUser?.photoURL ?? "";
//   }

//   /// --- Clean Getters for UI ---
//   String get userName => user.value?.userName ?? "";
//   String get email => user.value?.email ?? "";
//   int get videoCount => user.value?.videoCount ?? 0;
//   int get clicks => user.value?.clicks ?? 0;
//   double get earnings => user.value?.earnings ?? 0.0;
// }
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/model/userModel.dart';
import 'package:file_dock/screens/signInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxDouble paid = 0.0.obs;
  final RxDouble pending = 0.0.obs;

  StreamSubscription? _withdrawalSub;

  @override
  void onInit() {
    super.onInit();
    _listenUser();
    _listenWithdrawals();
  }

  void _listenUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _db.collection("users").doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        user.value = UserModel.fromSnapshot(doc);
      }
    });
  }

  void _listenWithdrawals() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _withdrawalSub?.cancel();
    _withdrawalSub = _db
        .collection('withdrawals')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      double totalPaid = 0.0;
      double totalPending = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final status = (data['status'] as String?)?.toLowerCase();
        if (status == 'approved') {
          totalPaid += amount;
        } else if (status == 'pending') {
          totalPending += amount;
        }
      }
      paid.value = totalPaid;
      pending.value = totalPending;
    });
  }

    Future<void> refreshData() async {
    Get.snackbar(
      "Updated",
      "Profile data refreshed",
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    _withdrawalSub?.cancel();
    super.onClose();
  }

  // 🔹 UI Getters
  String get userName => user.value?.userName ?? "";
  String get email => user.value?.email ?? "";
  String get photoUrl =>
      user.value?.photoUrl ?? _auth.currentUser?.photoURL ?? "";

  int get videoCount => user.value?.videoCount ?? 0;
  int get clicks => user.value?.clicks ?? 0;

  /// USD stored in Firestore
  double get earnings => user.value?.earnings ?? 0.0;
}

