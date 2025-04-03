import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/driverPages/dashboard_page.dart';
import 'package:zero/driverPages/driver_home.dart';
import 'package:zero/driverPages/driver_profile.dart';

final ScrollController scrollController = ScrollController();

class DriverBottomBar extends StatefulWidget {
  const DriverBottomBar({super.key});

  @override
  State<DriverBottomBar> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DriverBottomBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      const DriverHomePage(),
      const DashboardPage(),
      DriverProfilePage(
        cashCollected: 1000.00,
        driverId: 'driver_id',
        driverName: 'Fazil naz kolambil',
        isBlocked: 'Not blocked',
        isDeleted: false,
        mobileNumber: '+919487022519',
        onRent: 'rentId1',
        organisationId: 'organisation_id',
        organisationName: 'Zero uber',
        refund: 500.50,
        status: 'active',
        targetTrips: 70,
        totalEarnings: 3500.50,
        totalShifts: 7,
        totalTrips: 35,
        vehicleRent: 500,
        wallet: -1500.50,
        createdOn: Timestamp.now(),
      )
    ];
    void onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    return Scaffold(
      body: bottomBarPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: false,
        backgroundColor: ColorConst.boxColor,
        selectedItemColor: ColorConst.textColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
