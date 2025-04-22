import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/wallet_page.dart';

class DriverNotifications extends StatefulWidget {
  const DriverNotifications({super.key});

  @override
  State<DriverNotifications> createState() => _DriverNotificationsState();
}

class _DriverNotificationsState extends State<DriverNotifications> {
  List notifications = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [appbar()],
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'No new notifications',
                    style: TextStyle(
                        color: ColorConst.textColor,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      foregroundColor: ColorConst.textColor,
      toolbarHeight: h * 0.1,
      title: const Text('Notifications',
          style: TextStyle(
              color: ColorConst.textColor, fontWeight: FontWeight.bold)),
      backgroundColor: ColorConst.boxColor,
      elevation: 2,
      actions: [
        const IconButton(
          icon: Icon(Icons.notifications, color: ColorConst.textColor),
          onPressed: null,
        ),
        IconButton(
          icon: Icon(Icons.wallet,
              color: currentDriver!.wallet < 0
                  ? ColorConst.errorColor
                  : ColorConst.successColor),
          onPressed: () => Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (context) => const WalletPage())),
        ),
      ],
    );
  }
}
