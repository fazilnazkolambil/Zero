import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/transactions/transaction_controller.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/duty_model.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void onInit() {
    fetchWeeklyDuties();
    super.onInit();
  }

  var weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).obs;
  DateTime? weekEnd;

  void previousWeek() {
    weekStart.value = weekStart.value.subtract(const Duration(days: 7));
    Get.put(TransactionController()).fetchTransactions();
    fetchWeeklyDuties();
  }

  void nextWeek() {
    if (DateTime.now().difference(weekStart.value).inDays < 7) {
      null;
    } else {
      weekStart.value = weekStart.value.add(const Duration(days: 7));
      fetchWeeklyDuties();
      Get.put(TransactionController()).fetchTransactions();
    }
  }

  String getWeekRange() {
    final DateFormat formatter = DateFormat('MMM d');
    final DateTime weekEnd = weekStart.value.add(const Duration(days: 6));
    return '${formatter.format(weekStart.value)} - ${formatter.format(weekEnd)}';
  }

  RxBool isDutyLoading = false.obs;
  RxList<DutyModel> duties = <DutyModel>[].obs;
  Future<void> fetchWeeklyDuties() async {
    final start = DateTime(
        weekStart.value.year, weekStart.value.month, weekStart.value.day);
    final end = start.add(const Duration(days: 7));
    try {
      isDutyLoading.value = true;
      final snapshot = await _firestore
          .collection('duties')
          .where('fleet_id', isEqualTo: currentUser!.fleetId)
          .where('duty_status', isEqualTo: 'COMPLETED')
          .where('start_time',
              isGreaterThanOrEqualTo: start.millisecondsSinceEpoch)
          .where('start_time', isLessThan: end.millisecondsSinceEpoch)
          .get();
      duties.value = snapshot.docs
          .map((e) => DutyModel.fromMap(e.data()))
          .toList()
        ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
    } catch (e) {
      log('Error fetching duties: $e');
      Fluttertoast.showToast(
          msg: 'Error loading dashboard duties', backgroundColor: Colors.red);
    } finally {
      isDutyLoading.value = false;
    }
  }
}
