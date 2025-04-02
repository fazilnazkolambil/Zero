import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero/adminPages/screens/managing_page.dart';
import 'package:zero/adminPages/screens/admin_home.dart';
import 'package:zero/adminPages/screens/reports_page.dart';
import 'package:zero/adminPages/screens/settings_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

final ScrollController scrollController = ScrollController();

class AdminBottomBar extends StatefulWidget {
  const AdminBottomBar({super.key});

  @override
  State<AdminBottomBar> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AdminBottomBar> {
  final _pageController = PageController(initialPage: 1);
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 1);

  int maxCount = 3;

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      ReportsPage(),
      AdminHomePage(),
      ManagingPage()
    ];
    return Scaffold(
      // drawer:
      //     Drawer(
      //   backgroundColor: ColorConst.backgroundColor,
      //   width: w * 0.7,
      //   child: Padding(
      //     padding:
      //         EdgeInsets.symmetric(vertical: h * 0.03, horizontal: w * 0.03),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         ListTile(
      //           leading: CircleAvatar(
      //             backgroundColor: ColorConst.backgroundColor,
      //             backgroundImage: const AssetImage(ImageConst.logo),
      //             radius: w * 0.07,
      //           ),
      //           title: Text(, style: textStyle(true)),
      //           subtitle: Text(
      //             currentGamer!.gamerRole,
      //             style: textStyle(false),
      //           ),
      //         ),
      //         TextButton(
      //             onPressed: () => Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => PendingBills())),
      //             child: Text('Pending bills', style: textStyle(true))),
      //         TextButton(
      //             onPressed: () => Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => IncomePage())),
      //             child: Text('Income', style: textStyle(true))),
      //         TextButton(
      //             onPressed: () => Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => gamersPage())),
      //             child: Text('gamers', style: textStyle(true))),
      //         TextButton(
      //             onPressed: () => Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => DevicePage())),
      //             child: Text('Devices', style: textStyle(true))),
      //         TextButton(
      //             onPressed: () => Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => BevaragesPage())),
      //             child: Text('Beverages', style: textStyle(true))),
      //         const SizedBox(),
      //         GestureDetector(
      //             onTap: () {
      //               showDialog(
      //                 context: context,
      //                 barrierDismissible: false,
      //                 builder: (context) {
      //                   return AlertDialog(
      //                     backgroundColor: ColorConst.backgroundColor,
      //                     title: Text(
      //                       'Logout',
      //                       style: textStyle(true),
      //                     ),
      //                     content: Text(
      //                       'Are you sure you want to logout?',
      //                       style: textStyle(false),
      //                     ),
      //                     actions: [
      //                       TextButton(
      //                           onPressed: () => Navigator.pop(context),
      //                           child: const Text('No')),
      //                       TextButton(
      //                           onPressed: () async {
      //                             Amplify.Auth.signOut();
      //                             SharedPreferences prefs =
      //                                 await SharedPreferences.getInstance();
      //                             prefs.setBool('isLoggedIn', false);
      //                             prefs.remove('selectedCafe');
      //                             prefs.remove('cafe');
      //                             Navigator.pushAndRemoveUntil(
      //                                 context,
      //                                 MaterialPageRoute(
      //                                     builder: (context) =>
      //                                         const LoginPage()),
      //                                 (route) => false);
      //                           },
      //                           child: const Text('Yes'))
      //                     ],
      //                   );
      //                 },
      //               );
      //             },
      //             child: Row(
      //               children: [
      //                 const Icon(Icons.logout_outlined,
      //                     color: ColorConst.textColor),
      //                 const SizedBox(
      //                   width: 10,
      //                 ),
      //                 Text('Sign out', style: textStyle(false)),
      //               ],
      //             )),
      //         Center(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             children: [
      //               Text('M80 Esports', style: textStyle(true)),
      //               Text('App version : $version', style: textStyle(false))
      //             ],
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              notchBottomBarController: _controller,
              color: ColorConst.primaryColor.withOpacity(0.5),
              showLabel: true,
              textOverflow: TextOverflow.visible,
              maxLine: 1,
              shadowElevation: 5,
              kBottomRadius: 28.0,
              notchColor: ColorConst.primaryColor.withOpacity(0.5),
              removeMargins: false,
              bottomBarWidth: w * 0.5,
              showShadow: true,
              durationInMilliSeconds: 300,
              itemLabelStyle: TextStyle(color: ColorConst.textColor),
              elevation: 1,
              bottomBarItems: const [
                BottomBarItem(
                  inActiveItem: Icon(CupertinoIcons.list_bullet_below_rectangle,
                      color: ColorConst.textColor),
                  activeItem: Icon(CupertinoIcons.list_bullet_below_rectangle,
                      color: ColorConst.textColor),
                  itemLabel: 'Reports',
                ),
                BottomBarItem(
                  inActiveItem: Icon(CupertinoIcons.car_detailed,
                      color: ColorConst.textColor),
                  activeItem: Icon(CupertinoIcons.car_detailed,
                      color: ColorConst.textColor),
                  itemLabel: 'Vehicles',
                ),
                BottomBarItem(
                  inActiveItem: Icon(CupertinoIcons.settings,
                      color: ColorConst.textColor),
                  activeItem: Icon(CupertinoIcons.settings,
                      color: ColorConst.textColor),
                  itemLabel: 'Manage',
                ),
              ],
              onTap: (index) {
                _pageController.jumpToPage(index);
              },
              kIconSize: 24.0,
            )
          : null,
    );
  }
}
