import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero/adminPages/screens/managing_page.dart';
import 'package:zero/adminPages/screens/admin_home.dart';
import 'package:zero/adminPages/screens/reports_page.dart';
import 'package:zero/adminPages/screens/settings_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/dashboard_page.dart';
import 'package:zero/driverPages/driver_dash_board.dart';
import 'package:zero/driverPages/driver_home.dart';

final ScrollController scrollController = ScrollController();

class DriverBottomBar extends StatefulWidget {
  const DriverBottomBar({super.key});

  @override
  State<DriverBottomBar> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DriverBottomBar> {
  // final _pageController = PageController(initialPage: 1);
  // final NotchBottomBarController _controller =
  //     NotchBottomBarController(index: 0);

  // int maxCount = 2;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      const DriverHomePage(),
      // const DriverDashboard()
      DashboardPage()
    ];
    void _onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    return Scaffold(
      body: bottomBarPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: false,
        backgroundColor: ColorConst.boxColor,
        selectedItemColor: ColorConst.primaryColor,
        unselectedItemColor: ColorConst.textColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
    // Scaffold(
    //     body: bottomBarPages[selectedIndex!],
    //     //  PageView(
    //     //   controller: _pageController,
    //     //   physics: const NeverScrollableScrollPhysics(),
    //     //   children: List.generate(
    //     //       bottomBarPages.length, (index) => bottomBarPages[index]),
    //     // ),
    //     extendBody: true,
    //     bottomNavigationBar: BottomNavigationBar(
    //         onTap: (value) {
    //           setState(() {
    //             selectedIndex = value;
    //           });
    //         },
    //         backgroundColor: ColorConst.boxColor,
    //         selectedItemColor: ColorConst.primaryColor,
    //         unselectedItemColor: ColorConst.textColor,
    //         items: const [
    //           BottomNavigationBarItem(
    //               icon: Icon(CupertinoIcons.home), label: 'Home'),
    //           BottomNavigationBarItem(
    //               icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
    //         ])
    //     // (bottomBarPages.length <= maxCount)
    //     //     ?
    //     //     AnimatedNotchBottomBar(
    //     //         notchBottomBarController: _controller,
    //     //         color: ColorConst.primaryColor.withOpacity(0.5),
    //     //         showLabel: true,
    //     //         textOverflow: TextOverflow.visible,
    //     //         maxLine: 1,
    //     //         shadowElevation: 5,
    //     //         kBottomRadius: 28.0,
    //     //         notchColor: ColorConst.primaryColor.withOpacity(0.5),
    //     //         removeMargins: false,
    //     //         bottomBarWidth: w * 0.5,
    //     //         showShadow: true,
    //     //         durationInMilliSeconds: 300,
    //     //         itemLabelStyle: TextStyle(color: ColorConst.textColor),
    //     //         elevation: 1,
    //     //         bottomBarItems: const [
    //     //           BottomBarItem(
    //     //             inActiveItem:
    //     //                 Icon(CupertinoIcons.home, color: ColorConst.textColor),
    //     //             activeItem:
    //     //                 Icon(CupertinoIcons.home, color: ColorConst.textColor),
    //     //             itemLabel: 'Home',
    //     //           ),
    //     //           BottomBarItem(
    //     //             inActiveItem: Icon(Icons.dashboard_outlined,
    //     //                 color: ColorConst.textColor),
    //     //             activeItem: Icon(Icons.dashboard_outlined,
    //     //                 color: ColorConst.textColor),
    //     //             itemLabel: 'Dashboard',
    //     //           ),
    //     //         ],
    //     //         onTap: (index) {
    //     //           _pageController.jumpToPage(index);
    //     //         },
    //     //         kIconSize: 24.0,
    //     //       )
    //     //     : null,
    //     );
  }
}
