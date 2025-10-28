import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/notification_model.dart';
import 'package:zero/models/transaction_model.dart';

class WalletController extends GetxController {
  @override
  void onInit() {
    fetchTransactions();
    super.onInit();
  }

  final _firestore = FirebaseFirestore.instance;

  final TextEditingController payingAmount = TextEditingController();

  RxDouble pendingAmount = 0.0.obs;
  RxDouble totalPaid = 0.0.obs;
  RxDouble onlinePaid = 0.0.obs;
  RxDouble offlinePaid = 0.0.obs;
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  RxBool isLoading = false.obs;

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('fleet_id', isEqualTo: currentFleet!.fleetId)
          .get();

      transactions.value = snapshot.docs
          .map((e) => TransactionModel.fromMap(e.data()))
          .toList()
        ..sort((a, b) => b.paymentTime.compareTo(a.paymentTime));

      pendingAmount.value = _sumBy(transactions, 'PENDING');
      totalPaid.value = _sumBy(transactions, 'APPROVED');
      onlinePaid.value = _sumBy(transactions, 'APPROVED', filter: 'ONLINE');
      offlinePaid.value = _sumBy(transactions, 'APPROVED', filter: 'OFFINE');
    } catch (e) {
      log("Error fetching transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  double _sumBy(List<TransactionModel> txs, String status, {String? filter}) {
    return txs
        .where((t) =>
            (t.status == status) &&
            (filter == null || t.paymentMethod == filter))
        .fold(0.0, (add, t) => add + (t.amount));
  }

  Future<bool> upiPayment() async {
    String url = Uri.encodeFull(
        'upi://pay?pa=${currentFleet!.upiId}&pn=${currentFleet!.bankingName}&am=${payingAmount.text}&tn=RentPayment&cu=INR');
    bool result =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    return result;
  }

  RxBool isPaymentLoading = false.obs;
  Future<void> makePayment(String type) async {
    isPaymentLoading.value = true;

    try {
      await _firestore.runTransaction((transaction) async {
        final transactionsRef = _firestore.collection('transactions').doc();
        final inboxRef = _firestore.collection('inbox').doc();

        TransactionModel transactionModel = TransactionModel(
          transactionId: transactionsRef.id,
          userId: currentUser!.uid,
          paymentTime: DateTime.now().millisecondsSinceEpoch,
          amount: double.parse(payingAmount.text),
          status: "PENDING",
          senderName: currentUser!.fullName,
          paymentMethod: type,
          fleetId: currentFleet!.fleetId,
        );

        NotificationModel notificationModel = NotificationModel(
          id: inboxRef.id,
          notificationType: 'PAYMENT',
          transaction: transactionModel,
          senderId: currentUser!.uid,
          receiverId: currentFleet!.ownerId,
          status: 'PENDING',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );

        transaction.set(transactionsRef, transactionModel.toJson());
        transaction.set(inboxRef, notificationModel.toMap());
      });
    } catch (e) {
      log("Error making payment: $e");
      Fluttertoast.showToast(
          msg: "Something went wrong. Please try again!",
          backgroundColor: Colors.red);
      rethrow;
    } finally {
      isPaymentLoading.value = false;
      Get.offAllNamed('/splash');
    }
  }
}
