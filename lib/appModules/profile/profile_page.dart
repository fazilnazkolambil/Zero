import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () => Get.put(AuthController().logoutUser()),
              child: const Text('Logout'))),
    );
  }
}
