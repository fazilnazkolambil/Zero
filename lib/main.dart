import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/adminPages/screens/admin_bottom_page.dart';
import 'package:zero/auth/auth_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zero/driverPages/driver_bottom_page.dart';
import 'package:zero/driverPages/driver_home.dart';
import 'package:zero/models/user_model.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;
  Future getStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('currentUser') ?? '';
    if (jsonData.isNotEmpty) {
      Map<String, dynamic> currentUserData = json.decode(jsonData);
      currentUser = UserModel.fromJson(currentUserData);
    }
    setState(() {
      loggedIn = prefs.getBool('isLogged') ?? false;
    });
  }

  @override
  void initState() {
    getStorageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: MaterialApp(
          title: 'Zer0',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: ColorConst.backgroundColor,
            textTheme: GoogleFonts.manropeTextTheme(),
            useMaterial3: true,
          ),
          home: AnimatedSplashScreen(
            duration: 1000,
            backgroundColor: ColorConst.backgroundColor,
            splash: const Center(
              child: CupertinoActivityIndicator(
                color: ColorConst.primaryColor,
              ),
            ),
            nextScreen: !loggedIn
                ? const AuthPage()
                : currentUser!.userRole.toUpperCase() == 'ADMIN'
                    ? const AdminBottomBar()
                    : const DriverBottomBar(),
          )),
    );
  }
}
