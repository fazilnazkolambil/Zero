import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/adminPages/screens/admin_bottom_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/driver_bottom_page.dart';
import 'package:zero/driverPages/driver_home.dart';
import 'package:zero/models/user_model.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final mobileNumberController = TextEditingController();
  final otpController = TextEditingController();

  bool isLoading = false;
  bool otpField = false;
  String _verificationId = "";

  void verifyPhoneNumber(String mobileNumber) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          checkUserInFirestore();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? "Verification failed")));
          setState(() {
            isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            otpField = true;
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("OTP sent successfully!")));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('CATCH ERROR: $e');
    }
  }

  void verifyOTP(String otp) async {
    try {
      setState(() {
        isLoading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await checkUserInFirestore();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid OTP. Please try again.")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkUserInFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('mobile_number', isEqualTo: user.phoneNumber)
            .get();

        if (userDoc.docs.isNotEmpty) {
          currentUser = UserModel.fromJson(userDoc.docs.first.data());
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLogged', true);
          prefs.setString(
              'currentUser', json.encode(userDoc.docs.first.data()));
          if (currentUser!.userRole.toUpperCase() == 'ADMIN') {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => AdminBottomBar(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => DriverBottomBar(),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "You haven't registered yet. Please contact your Admin!")));
          setState(() {
            otpField = false;
          });
        }
      }
    } catch (e) {
      print("Error checking Firestore: $e");
      setState(() {
        otpField = false;
      });
    }
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(w * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: h * 0.1,
                ),
                Image.asset(
                  ImageConst.logo,
                  width: w * 0.5,
                  height: w * 0.5,
                ),
                SizedBox(height: h * 0.05),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    otpField ? 'Enter the OTP' : 'Enter your Mobile number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: w * 0.04,
                    ),
                  ),
                ),
                SizedBox(height: h * 0.02),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Mobile number Field
                      TextFormField(
                        controller: mobileNumberController,
                        readOnly: otpField,
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Mobile number',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(w * 0.05),
                            child: const Text('+91',
                                style:
                                    TextStyle(color: ColorConst.primaryColor)),
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorConst.primaryColor),
                          ),
                          filled: true,
                          fillColor: ColorConst.boxColor,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: ColorConst.textColor),
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 10) {
                            return 'Please enter your Mobile number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: h * 0.02),
                      if (otpField) ...[
                        FractionallySizedBox(
                            child: Pinput(
                          defaultPinTheme: PinTheme(
                              textStyle:
                                  const TextStyle(color: ColorConst.textColor),
                              height: h * 0.07,
                              margin:
                                  EdgeInsets.symmetric(horizontal: w * 0.01),
                              decoration: BoxDecoration(
                                  color: ColorConst.boxColor,
                                  borderRadius: BorderRadius.circular(w * 0.02),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.white.withOpacity(0.25),
                                        blurRadius: 4,
                                        spreadRadius: 2),
                                  ])),
                          controller: otpController,
                          length: 6,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        )),
                        SizedBox(height: h * 0.05),
                      ],
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (otpField) {
                                verifyOTP(otpController.text.trim());
                              } else {
                                verifyPhoneNumber(
                                    '+91${mobileNumberController.text.trim()}');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConst.primaryColor,
                            foregroundColor: ColorConst.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const CupertinoActivityIndicator()
                              : Text(
                                  otpField ? 'VERIFY' : 'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
