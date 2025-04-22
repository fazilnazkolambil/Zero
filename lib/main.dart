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
import 'package:zero/models/driver_model.dart';
import 'package:zero/models/user_model.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Zer0',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: ColorConst.backgroundColor,
          textTheme: GoogleFonts.manropeTextTheme(),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLogged') ?? false;
      bool isDriving = prefs.getBool('isDriving') ?? false;
      if (isLoggedIn) {
        String? userJson = prefs.getString('currentUser');
        if (userJson != null && userJson.isNotEmpty) {
          try {
            Map<String, dynamic> userData = json.decode(userJson);
            currentUser = UserModel.fromJson(userData);
            if (currentUser!.userRole.toUpperCase() == 'ADMIN') {
              _navigateTo(
                  isDriving ? const DriverBottomBar() : const AdminBottomBar());
            } else {
              String? driverJson = prefs.getString('driverModel');
              Map<String, dynamic> driverData = json.decode(driverJson!);
              currentDriver = DriverModel.fromJson(driverData);
              _navigateTo(const DriverBottomBar());
            }
          } catch (e) {
            await prefs.clear();
            _navigateTo(const AuthPage());
          }
        } else {
          _navigateTo(const AuthPage());
        }
      } else {
        _navigateTo(const AuthPage());
      }
    } catch (e) {
      _navigateTo(const AuthPage());
    }
  }

  void _navigateTo(Widget screen) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
