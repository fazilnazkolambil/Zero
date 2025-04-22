import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/guestPages/g_admin_dashboard.dart';
import 'package:zero/guestPages/g_drivers_page.dart';
import 'package:zero/guestPages/g_organisation_page.dart';
import 'package:zero/guestPages/g_vehicles_page.dart';

final ScrollController scrollController = ScrollController();

class GuestAdminBottomBar extends StatefulWidget {
  const GuestAdminBottomBar({super.key});

  @override
  State<GuestAdminBottomBar> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<GuestAdminBottomBar> {
  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      const GAdminDashboard(),
      const GVehiclesPage(),
      const GDriversPage(),
      const GOrganisationPage()
    ];
    return Scaffold(
      body: bottomBarPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
