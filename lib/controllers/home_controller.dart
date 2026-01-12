import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/controllers/billing_controller.dart';
import 'package:file_dock/controllers/withdrawal_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreenController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // ================= REVENUE =================
  final RxDouble total = 0.0.obs;
  final RxDouble paid = 0.0.obs;
  final RxDouble pending = 0.0.obs;

  // ================= DAILY =================
  final RxString todayDate = "".obs;
  final RxInt dailyFilesUploaded = 0.obs;
  final RxInt dailyClicks = 0.obs;
  final RxDouble dailyEarned = 0.0.obs;

  // ================= MONTHLY =================
  final RxString currentMonth = "".obs;
  final RxInt monthlyFilesUploaded = 0.obs;
  final RxInt monthlyClicks = 0.obs;
  final RxDouble monthlyEarned = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      fetchRevenue();
      fetchDailyAnalytics();
      fetchMonthlyAnalytics();
    }
  }

  // ================= REFRESH =================
  Future<void> refreshData() async {
    await fetchRevenue();
    await fetchDailyAnalytics();
    await fetchMonthlyAnalytics();
  }

  // ================= REVENUE =================
  Future<void> fetchRevenue() async {
    if (userId == null) return;

    final withdrawal = Get.find<WithdrawalProvider>();
    final billing = Get.find<BillingController>();

    withdrawal.fetchApprovedAmount();
    billing.bindUserEarnings(userId!);

    total.value = withdrawal.approvedAmount.value;
    paid.value = billing.paid.value;
    pending.value = billing.pending.value;
  }

  // ================= DAILY (TODAY) =================
  Future<void> fetchDailyAnalytics() async {
    if (userId == null) return;

    final now = DateTime.now();
    todayDate.value = DateFormat("d MMM yyyy").format(now);

    await _fetchByRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day + 1),
      isDaily: true,
    );
  }

  // ================= DAILY (PICKED DATE) =================
  Future<void> fetchAnalyticsForPickedDate(DateTime pickedDate) async {
    if (userId == null) return;

    todayDate.value = DateFormat("d MMM yyyy").format(pickedDate);

    await _fetchByRange(
      start: DateTime(pickedDate.year, pickedDate.month, pickedDate.day),
      end: DateTime(pickedDate.year, pickedDate.month, pickedDate.day + 1),
      isDaily: true,
    );
  }

  // ================= MONTHLY (CURRENT) =================
  Future<void> fetchMonthlyAnalytics() async {
    if (userId == null) return;

    final now = DateTime.now();
    currentMonth.value = DateFormat("MMMM yyyy").format(now);

    await _fetchByRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 1),
      isDaily: false,
    );
  }

  // ================= MONTHLY (PICKED) =================
  Future<void> fetchAnalyticsForPickedMonth(DateTime pickedMonth) async {
    if (userId == null) return;

    currentMonth.value = DateFormat("MMMM yyyy").format(pickedMonth);

    await _fetchByRange(
      start: DateTime(pickedMonth.year, pickedMonth.month, 1),
      end: DateTime(pickedMonth.year, pickedMonth.month + 1, 1),
      isDaily: false,
    );
  }

  // ================= CORE QUERY =================
  Future<void> _fetchByRange({
    required DateTime start,
    required DateTime end,
    required bool isDaily,
  }) async {
    final snapshot = await _db
        .collection("videos")
        .where("userId", isEqualTo: userId)
        .where("createdAt", isGreaterThanOrEqualTo: start)
        .where("createdAt", isLessThan: end)
        .get();

    int views = 0;
    for (final doc in snapshot.docs) {
      views += (doc.data()["uniqueViews"] ?? 0) as int;
    }

    final usd = (views / 1000) * 0.5;
    
    // final inr = await convertDollarToInr(usd); // Removed conversion

    if (isDaily) {
      dailyFilesUploaded.value = snapshot.docs.length;
      dailyClicks.value = views;
      dailyEarned.value = usd;
    } else {
      monthlyFilesUploaded.value = snapshot.docs.length;
      monthlyClicks.value = views;
      monthlyEarned.value = usd;
    }
  }


}
