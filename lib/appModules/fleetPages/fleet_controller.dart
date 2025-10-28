import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/notification_model.dart';

class FleetController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void onInit() {
    listFleets();
    super.onInit();
  }

  RxBool isLoading = false.obs;
  RxList<FleetModel> fleetList = <FleetModel>[].obs;
  Future<void> listFleets() async {
    try {
      isLoading.value = true;
      var data = await _firestore
          .collection('fleets')
          .where('is_hiring', isEqualTo: true)
          .get();
      List fleets = data.docs.map((e) => e.data()).toList();
      fleetList.value = fleets.map((e) => FleetModel.fromMap(e)).toList();
      isLoading.value = false;
    } catch (e) {
      log('Error listing fleets : $e');
      isLoading.value = false;
    }
  }

  RxBool isSendingRequest = false.obs;
  Future<void> joinRequest(String ownerId) async {
    try {
      isSendingRequest.value = true;
      NotificationModel notification = NotificationModel(
        id: '',
        notificationType: NotificationTypes.joinRequest,
        senderId: currentUser!.uid,
        receiverId: ownerId,
        status: 'PENDING',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        user: currentUser,
      );
      await _firestore
          .collection('inbox')
          .add(notification.toMap())
          .then((value) {
        value.update({'id': value.id});
      });
      fleetList.removeWhere((element) => element.ownerId == ownerId);
      // await _firestore.collection('users').doc(currentUser!.uid).update({
      //   'fleet_requests': FieldValue.arrayUnion([fleetId])
      // });

      Fluttertoast.showToast(msg: 'Request sent successfully');
    } catch (e) {
      log('Error sending joinRequest: $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      isSendingRequest.value = false;
    }
  }
}
