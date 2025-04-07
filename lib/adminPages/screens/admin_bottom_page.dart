import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero/adminPages/screens/_admin_dashboard.dart';
import 'package:zero/adminPages/screens/admin_dashboard.dart';
import 'package:zero/adminPages/screens/drivers_page.dart';
import 'package:zero/adminPages/screens/managing_page.dart';
import 'package:zero/adminPages/screens/organisation_page.dart';
import 'package:zero/adminPages/screens/vehicles_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/driverPages/driver_bottom_page.dart';

final ScrollController scrollController = ScrollController();

class AdminBottomBar extends StatefulWidget {
  const AdminBottomBar({super.key});

  @override
  State<AdminBottomBar> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AdminBottomBar> {
  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      const AdminDashboard(),
      const VehiclesPage(),
      const DriversPage(),
      // const ManagingPage(),
      // const OrganisationPage()
      DriverBottomBar()
    ];
    return Scaffold(
      body: bottomBarPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // enableFeedback: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorConst.boxColor,
        selectedItemColor: ColorConst.textColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car_detailed), label: 'Vehicles'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined), label: 'Drivers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assured_workload_outlined),
              label: 'Organisation'),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
