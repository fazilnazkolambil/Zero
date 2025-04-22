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
      const DriverProfilePage()
    ];
    void onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    return Scaffold(
      body: bottomBarPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        enableFeedback: false,
        backgroundColor: ColorConst.boxColor,
        selectedItemColor: ColorConst.textColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.account_balance_wallet_outlined),
          //     label: 'Transactions'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
