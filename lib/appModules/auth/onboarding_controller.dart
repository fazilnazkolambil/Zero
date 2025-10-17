import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/vehicle_model.dart';
import 'package:geolocator/geolocator.dart';

class OnboardingController extends GetxController {
  PageController pageController = PageController();
  RxString selectedMainFlow = ''.obs;
  final box = Hive.box('zeroCache');

  RxBool isLoading = false.obs;
  TextEditingController numberPlateController = TextEditingController();
  TextEditingController vehicleModelController = TextEditingController();
  TextEditingController fleetNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController officeAddressController = TextEditingController();
  TextEditingController latLongController = TextEditingController();
  RxBool isFleetHiring = false.obs;

  final formkey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // createVehicle({required String vehicleImage}) async {
  //   try {
  //     isLoading.value = true;
  //     String vehicleId = numberPlateController.text.trim();
  //     var vehicles =
  //         await _firestore.collection('vehicles').doc(vehicleId).get();
  //     if (vehicles.data() != null) {
  //       Fluttertoast.showToast(
  //           msg: 'Vehicle already exist. Please check the Number plate',
  //           backgroundColor: Colors.red);
  //       isLoading.value = false;
  //     } else {
  //       // await _firestore
  //       //     .collection('users')
  //       //     .doc(currentUser!.uid)
  //       //     .update({'user_role': 'VEHICLE_OWNER'});
  //       // currentUser = currentUser!.copyWith(userRole: 'VEHICLE_OWNER');
  //       VehicleModel vehicleModel = VehicleModel(
  //           vehicleId: vehicleId,
  //           vehicleModel: vehicleModelController.text.trim(),
  //           ownerId: currentUser!.uid,
  //           status: 'ACTIVE',
  //           addedOn: DateTime.now().millisecondsSinceEpoch,
  //           updatedOn: DateTime.now().millisecondsSinceEpoch,
  //           vehicleImage: vehicleImage);
  //       vehicles.reference.set(vehicleModel.toMap());
  //       Fluttertoast.showToast(msg: 'Vehicle added successfully!');
  //       updateUserRole(userRole: 'VEHICLE_OWNER');
  //       // Get.offAllNamed('/home');
  //       // isLoading.value = false;
  //     }
  //   } catch (e) {
  //     log('Error while creating vehicle : $e');
  //     Fluttertoast.showToast(
  //         msg: 'Something went wrong. Please try again!',
  //         backgroundColor: Colors.red);
  //     isLoading.value = false;
  //   }
  // }

  Future<void> getLocation() async {
    try {
      isLoading.value = true;
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: 'Location permission denied!', backgroundColor: Colors.red);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      latLongController.text = "${position.latitude}, ${position.longitude}";
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Error fetching location', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  createfleet() async {
    try {
      isLoading.value = true;
      String fleetId = '';
      currentFleet = FleetModel(
          fleetId: '',
          ownerId: currentUser!.uid,
          fleetName: fleetNameController.text.trim(),
          isHiring: isFleetHiring.value,
          contactNumber: '+91${contactNumberController.text.trim()}',
          officeAddress: officeAddressController.text.trim(),
          parkingLocation: latLongController.text.trim(),
          addedOn: DateTime.now().millisecondsSinceEpoch,
          updatedOn: DateTime.now().millisecondsSinceEpoch,
          targets: {'driver': 0, 'vehicle': 0}); //TODO:
      await _firestore.collection('fleets').add(currentFleet!.toMap()).then(
        (value) {
          value.update({'fleet_id': value.id});
          fleetId = value.id;
        },
      );
      box.put('currentFleet', jsonEncode(currentFleet!.toMap()));
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({'user_role': 'FLEET_OWNER', 'fleet_id': fleetId});
      currentUser =
          currentUser!.copyWith(userRole: 'FLEET_OWNER', fleetId: fleetId);
      Get.offAllNamed('/home');
      isLoading.value = false;
    } catch (e) {
      log('Error creating fleet : $e');
      isLoading.value = false;
    }
  }
}
