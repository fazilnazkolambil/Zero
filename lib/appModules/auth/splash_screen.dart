import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class SplashScreen extends GetView<AuthController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    Future.delayed(const Duration(milliseconds: 2000), () async {
      controller.checkAuth();
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          ImageConst.logo,
          width: w * 0.5,
          height: w * 0.5,
        ),
      ),
    );
  }
}
