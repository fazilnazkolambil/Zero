import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/vehicle_model.dart';

class VehicleController extends GetxController {
  @override
  void onInit() {
    loadVehicles();
    super.onInit();
  }

  final formkey = GlobalKey<FormState>();
  final numberPlateController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final targetTrips = TextEditingController();
  final rentType = 'fixed'.obs;
  final fixedRentController = TextEditingController();
  final rentRules = <RuleModel>[].obs;

  final box = Hive.box('zeroCache');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isVehiclesLoading = false.obs;
  RxList<VehicleModel> vehicles = <VehicleModel>[].obs;

  loadVehicles() async {
    vehicles.clear();
    final cachedData = box.get('vehicles');
    if (cachedData != null) {
      vehicles.value = (jsonDecode(cachedData) as List)
          .map((v) => VehicleModel.fromMap(v))
          .toList();
    }
    listVehicles();
  }

  listVehicles() async {
    try {
      isVehiclesLoading.value = true;
      var data = await _firestore
          .collection('vehicles')
          .where('owner_id', isEqualTo: currentUser!.uid)
          .get();
      vehicles.clear();
      List<Map<String, dynamic>> vehicleData = [];
      for (var vehicle in data.docs) {
        vehicleData.add(vehicle.data());
        VehicleModel vehicleModel = VehicleModel.fromMap(vehicle.data());
        vehicles.add(vehicleModel);
      }
      box.put('vehicles', jsonEncode(vehicleData));
    } catch (e) {
      log('Error getting vehicles : $e');
    } finally {
      isVehiclesLoading.value = false;
    }
  }

  RxBool isLoading = false.obs;
  createVehicle() async {
    try {
      isLoading.value = true;
      var vehicles = await _firestore
          .collection('vehicles')
          .where('number_plate', isEqualTo: numberPlateController.text.trim())
          .get();
      if (vehicles.docs.isNotEmpty &&
          vehicles.docs.first.data()['owner_id'].isNotEmpty) {
        Fluttertoast.showToast(
            msg: 'Vehicle has another owner. Please check the Number plate',
            backgroundColor: Colors.red);
        isLoading.value = false;
      } else {
        String vehicleId = '';
        VehicleModel vehicleModel = VehicleModel(
          vehicleId: '',
          numberPlate: numberPlateController.text.trim(),
          vehicleModel: vehicleModelController.text.trim(),
          ownerId: currentUser!.uid,
          status: 'ACTIVE',
          addedOn: DateTime.now().millisecondsSinceEpoch,
          updatedOn: DateTime.now().millisecondsSinceEpoch,
          targetTrips: int.parse(targetTrips.text),
          fleetId: currentUser!.fleetId,
          vehicleRent: rentType.value == 'fixed'
              ? double.parse(fixedRentController.text)
              : rentRules.map((r) => RentRule(
                      minTrips: int.tryParse(r.minController.text) ?? 0,
                      rent: double.tryParse(r.rentController.text) ?? 0)
                  .toMap()),
        );
        await _firestore
            .collection('vehicles')
            .add(vehicleModel.toMap())
            .then((value) {
          vehicleId = value.id;
          value.update({'vehicle_id': value.id});
        });
        await _firestore
            .collection('fleets')
            .doc(currentFleet!.fleetId)
            .update({
          'vehicles': FieldValue.arrayUnion([vehicleId])
        });
        Fluttertoast.showToast(msg: 'Vehicle added successfully!');
        await listVehicles();
        Get.back();
        clearAll();
        isLoading.value = false;
      }
    } catch (e) {
      log('Error while creating vehicle : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
      isLoading.value = false;
    }
  }

  editVehicle({required String vehicleId}) async {
    try {
      isLoading.value = true;
      dynamic vehicleRent = rentType.value == 'fixed'
          ? double.parse(fixedRentController.text)
          : rentRules
              .map((r) => RentRule(
                      minTrips: int.tryParse(r.minController.text) ?? 0,
                      rent: double.tryParse(r.rentController.text) ?? 0)
                  .toMap())
              .toList();
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'number_plate': numberPlateController.text.trim(),
        'vehicle_model': vehicleModelController.text.trim(),
        'updated_on': DateTime.now().millisecondsSinceEpoch,
        'target_trips': int.parse(targetTrips.text),
        'vehicle_rent': vehicleRent,
      });
      Fluttertoast.showToast(msg: 'Vehicle updated successfully!');
      await listVehicles();
      Get.back();
      clearAll();
      isLoading.value = false;
    } catch (e) {
      log('Error while editing vehicle : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
      isLoading.value = false;
    }
  }

  removeVehicle({required String vehicleId}) async {
    try {
      isLoading.value = true;
      await _firestore.collection('vehicles').doc(vehicleId).delete();
      // .update({'owner_id': '', 'status': 'REMOVED'});
      await _firestore.collection('fleets').doc(currentFleet!.fleetId).update({
        'vehicles': FieldValue.arrayRemove([vehicleId])
      });
      Fluttertoast.showToast(msg: 'Vehicle deleted!');
      await listVehicles();
      isLoading.value = false;
    } catch (e) {
      log('Error while removing vehicle : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
      isLoading.value = false;
    }
  }

  clearAll() {
    numberPlateController.clear();
    vehicleModelController.clear();
    targetTrips.clear();
    fixedRentController.clear();
    rentRules.clear();
  }
}

class RuleModel {
  final minController = TextEditingController();
  final rentController = TextEditingController();
}
