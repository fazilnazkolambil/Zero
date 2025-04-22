import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/adminPages/screens/admin_bottom_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/driver_bottom_page.dart';

class SwitchModePage extends StatefulWidget {
  final bool isDriving;
  const SwitchModePage({super.key, required this.isDriving});

  @override
  State<SwitchModePage> createState() => _SwitchModePageState();
}

class _SwitchModePageState extends State<SwitchModePage> {
  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDriving', widget.isDriving);
    setState(() {});
  }

  @override
  void initState() {
    getData();
    Future.delayed(const Duration(seconds: 3)).then((value) =>
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => widget.isDriving
                    ? const DriverBottomBar()
                    : const AdminBottomBar())));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(),
            Image.asset(
              ImageConst.logo,
              width: w * 0.5,
              height: w * 0.5,
            ),
            Text(
                widget.isDriving
                    ? 'Switching to Driving...'
                    : 'Switching to Admin...',
                style: TextStyle(
                    color: ColorConst.textColor,
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.w600)),
            const CupertinoActivityIndicator(
              color: ColorConst.primaryColor,
            )
          ],
        ),
      ),
    );
  }
}
