import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/invitation_model.dart';

class InboxController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchInbox();
    super.onInit();
  }

  RxList<InvitationModel> inboxList = <InvitationModel>[].obs;
  Future<void> fetchInbox() async {
    try {
      isLoading.value = true;
      // final currentUserId = currentUser!.uid;
      // final currentFleetId = currentFleet?.fleetId;
      // final currentRole = currentUser!.userRole;

      // QuerySnapshot snapshot;

      // if (currentRole == "driver") {
      //   // Driver sees invitations from fleets
      //   snapshot = await _firestore
      //       .collection('invitations')
      //       .where('receiver_id', isEqualTo: currentUserId)
      //       .where('fleet_id', isNotEqualTo: null)
      //       .get();
      // } else {
      //   // Fleet sees join requests from drivers
      //   snapshot = await _firestore
      //       .collection('invitations')
      //       .where('fleet_id', isEqualTo: currentFleetId)
      //       .where('fleet_id', isEqualTo: null)
      //       .get();
      // }

      // invitations.value = snapshot.docs
      //     .map((doc) =>
      //         InvitationModel.fromJson(doc.data() as Map<String, dynamic>))
      //     .toList();

      var data = await _firestore
          .collection('inbox')
          .where('receiver_id', isEqualTo: currentUser!.uid)
          .get();
      inboxList.value = data.docs
          .map((e) => InvitationModel.fromJson(e.data()))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } finally {
      isLoading.value = false;
    }
  }

  RxBool isDeclining = false.obs;
  Future<void> declineRequest({required String invitationId}) async {
    try {
      isDeclining.value = true;
      await _firestore.collection('inbox').doc(invitationId).update({
        'status': 'DECLINED',
      });
      fetchInbox();
    } catch (e) {
      log('Error declining request : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      isDeclining.value = false;
    }
  }

  RxBool isAccepting = false.obs;
  Future<void> acceptRequest(
      {required String invitationId, required String fleetId}) async {
    try {
      isAccepting.value = true;
      await _firestore.collection('inbox').doc(invitationId).update({
        'status': 'ACCEPTED',
      });
      fetchInbox();
      _firestore.collection('users').doc(currentUser!.uid).update({
        'fleet_id': fleetId,
        'user_role': 'DRIVER',
      });
      currentUser = currentUser!.copyWith(fleetId: fleetId, userRole: 'DRIVER');
      await _firestore.collection('fleets').doc(fleetId).update({
        'drivers': FieldValue.arrayUnion([currentUser!.uid])
      });
      Fluttertoast.showToast(msg: 'Successfully joined fleet!');
      Get.offAllNamed('/home');
    } catch (e) {
      log('Error accepting request : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      isAccepting.value = false;
    }
  }
}
