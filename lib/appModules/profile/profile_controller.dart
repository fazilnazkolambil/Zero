import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/user_model.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  var profilePicUrl = ''.obs;
  var licenseUrl = ''.obs;
  var aadhaarUrl = ''.obs;

  void loadUserData(Map<String, dynamic> user) {
    nameController.text = user['full_name'] ?? '';
    phoneController.text = user['phone_number'] ?? '';
    emailController.text = user['email'] ?? '';
    profilePicUrl.value = user['profile_pic_url'] ?? '';
    licenseUrl.value = user['license_url'] ?? '';
    aadhaarUrl.value = user['aadhaar_url'] ?? '';
  }

  RxBool isEditing = false.obs;
  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  RxBool isEditLoading = false.obs;
  editUserInfo() async {
    try {
      isEditLoading.value = true;
      _firestore.collection('users').doc(currentUser!.uid).update({
        'full_name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'profile_pic_url': profilePicUrl.value,
        'updated_at': DateTime.now().millisecondsSinceEpoch
      });
      Get.back();
      Fluttertoast.showToast(msg: 'Profile updated successfully!');
    } catch (e) {
      log('Error editing user info : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      isEditLoading.value = false;
    }
  }

  deleteUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await user.delete();
      Get.put(AuthController()).logoutUser();
    } catch (e) {
      if (e.toString().contains('Log in again before retrying this request')) {
        Get.dialog(AlertDialog(
          content: const Text(
            'Please login again to delete the account',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
            TextButton(
                onPressed: () => Get.put(AuthController()).logoutUser(),
                child: const Text('Log out')),
          ],
        ));
      } else {
        log('Error deleting user : $e');
        Fluttertoast.showToast(msg: 'Something went wrong. Please try again!');
      }
    }
  }

  RxBool isLoading = false.obs;
  Future<void> leaveFleet() async {
    String fleetId = currentFleet!.fleetId;
    final userRef = _firestore.collection('users').doc(currentUser!.uid);
    final fleetRef = _firestore.collection('fleets').doc(fleetId);

    _firestore.runTransaction(
      (transaction) async {
        var userSnap = await transaction.get(userRef);
        var fleetSnap = await transaction.get(fleetRef);
        if (!userSnap.exists || !fleetSnap.exists) {
          throw Exception('Documents not found!');
        }
        transaction.update(userRef, {'fleet_id': null, 'user_role': 'USER'});
        transaction.update(fleetRef, {
          'drivers': FieldValue.arrayRemove([currentUser!.uid])
        });
      },
    );
    Get.offAllNamed('/splash');
  }

  Future<void> deleteFleet() async {
    String fleetId = currentFleet!.fleetId;
    final userRef = _firestore.collection('users').doc(currentUser!.uid);
    final fleetRef = _firestore.collection('fleets').doc(fleetId);

    _firestore.runTransaction(
      (transaction) async {
        var userSnap = await transaction.get(userRef);
        var fleetSnap = await transaction.get(fleetRef);
        if (!userSnap.exists || !fleetSnap.exists) {
          Fluttertoast.showToast(
              msg: 'Document does not exist!', backgroundColor: Colors.red);
          return;
        }
        transaction.update(userRef, {'fleet_id': null, 'user_role': 'USER'});
        transaction.delete(fleetRef);
      },
    );
    Get.offAllNamed('/splash');
  }
}
