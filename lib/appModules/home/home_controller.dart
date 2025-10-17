import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero/appModules/dashboard/dashboard_page.dart';
import 'package:zero/appModules/driverPages/driver_page.dart';
import 'package:zero/appModules/home/home_page.dart';
import 'package:zero/appModules/earningPages/earning_page.dart';
import 'package:zero/appModules/checkPages/page3.dart';
import 'package:zero/appModules/inbox/inbox_page.dart';
import 'package:zero/appModules/profile/profile_page.dart';
import 'package:zero/appModules/vehiclePages/vehicles_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/duty_model.dart';
import 'package:zero/models/vehicle_model.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    listVehicles();
    super.onInit();
  }

  RxInt currentIndex = 0.obs;
  String userRole = currentUser!.userRole ?? 'USER';
  final box = Hive.box('zeroCache');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> get homePages {
    switch (userRole) {
      case ('USER'):
        return [
          {
            'label': 'Fleets',
            'icon': Icons.email,
            'page': Page3(),
          },
          {
            'label': 'Inbox',
            'icon': Icons.email,
            'page': InboxPage(),
          },
          {
            'label': 'Profile',
            'icon': Icons.email,
            'page': ProfilePage(),
          },
        ].obs;
      case ('FLEET_OWNER'):
        return [
          {
            'label': 'Dashboard',
            'icon': Icons.dashboard,
            'page': DashboardPage(),
          },
          {
            'label': 'Vehicles',
            'icon': Icons.directions_car,
            'page': VehiclesPage(),
          },
          {
            'label': 'Drivers',
            'icon': Icons.group,
            'page': DriversPage(),
          },
          {
            'label': 'Home',
            'icon': Icons.home_filled,
            'page': HomePage(),
          },
          {
            'label': 'Earnings',
            'icon': Icons.money,
            'page': EarningPage(),
          },
          {
            'label': 'Inbox',
            'icon': Icons.email,
            'page': InboxPage(),
          },
          {
            'label': 'Profile',
            'icon': Icons.person,
            'page': ProfilePage(),
          },
        ].obs;
      default:
        return [
          {
            'label': 'Home',
            'icon': Icons.home_filled,
            'page': HomePage(),
          },
          {
            'label': 'Earnings',
            'icon': Icons.money,
            'page': EarningPage(),
          },
          {
            'label': 'Inbox',
            'icon': Icons.email,
            'page': InboxPage(),
          },
          {
            'label': 'Profile',
            'icon': Icons.person,
            'page': ProfilePage(),
          },
        ].obs;
    }
  }

  RxBool isVehiclesLoading = false.obs;
  RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  // loadVehicles() async {
  //   vehicles.clear();
  //   final cachedData = box.get('vehicles');
  //   if (cachedData != null) {
  //     vehicles.value = (jsonDecode(cachedData) as List)
  //         .map((v) => VehicleModel.fromMap(v))
  //         .toList();
  //   }
  //   listVehicles();
  // }

  listVehicles() async {
    try {
      isVehiclesLoading.value = true;

      vehicles.clear();
      var data = await _firestore
          .collection('vehicles')
          .where('fleet_id', isEqualTo: currentUser!.fleetId)
          .where('on_duty', isNull: true)
          .get();
      vehicles.value =
          data.docs.map((e) => VehicleModel.fromMap(e.data())).toList();

      // box.put('vehicles', jsonEncode(vehicles.toJson()));
    } catch (e) {
      log('Error getting vehicles : $e');
    } finally {
      isVehiclesLoading.value = false;
    }
  }

  void changeIndex(int index) {
    if (homePages.length > 4 && currentIndex.value != index) {
      Get.back();
    }
    currentIndex.value = index;
  }
}
