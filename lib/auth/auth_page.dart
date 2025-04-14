import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/adminPages/screens/admin_bottom_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/driver_bottom_page.dart';
import 'package:zero/models/user_model.dart';

enum AuthState {
  initial,
  sendingOTP,
  otpSent,
  verifyingOTP,
  authenticated,
  error
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final mobileNumberController = TextEditingController();
  final otpController = TextEditingController();

  AuthState _authState = AuthState.initial;
  String _verificationId = "";
  String _errorMessage = "";
  int? _resendToken;
  bool _canResendOTP = false;
  int _resendCountdown = 0;

  void verifyPhoneNumber(String mobileNumber) async {
    try {
      setState(() {
        _authState = AuthState.sendingOTP;
        _errorMessage = "";
      });

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _authState = AuthState.error;
            _errorMessage = e.message ?? "Verification failed";
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _authState = AuthState.otpSent;
            _canResendOTP = false;
            _resendCountdown = 30;
          });

          _startResendTimer();
          Fluttertoast.showToast(
            msg: "OTP sent successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
          if (_authState == AuthState.sendingOTP) {
            setState(() {
              _authState = AuthState.otpSent;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _authState = AuthState.error;
        _errorMessage = "Failed to send OTP: $e";
      });
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResendOTP = true;
        });
      }
    });
  }

  void verifyOTP(String otp) async {
    if (otp.length != 6) {
      Fluttertoast.showToast(
        msg: "Please enter a valid 6-digit OTP",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    try {
      setState(() {
        _authState = AuthState.verifyingOTP;
        _errorMessage = "";
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _authState = AuthState.error;
        _errorMessage = "Invalid OTP. Please try again.";
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await checkUserInFirestore(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _authState = AuthState.error;
        _errorMessage = e.message ?? "Authentication failed";
      });
    }
  }

  Future<void> checkUserInFirestore(User firebaseUser) async {
    try {
      setState(() {
        _authState = AuthState.authenticated;
      });

      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('mobile_number', isEqualTo: firebaseUser.phoneNumber)
          .get();

      if (userDoc.docs.isNotEmpty) {
        // User exists in Firestore
        Map<String, dynamic> userData = userDoc.docs.first.data();

        // Check if user is blocked
        if (userData['is_blocked'].isNotEmpty) {
          setState(() {
            _authState = AuthState.error;
            _errorMessage =
                "Your account has been blocked due to ${userData['is_blocked']}. Please contact admin.";
          });
          await FirebaseAuth.instance.signOut();
          return;
        }

        // Check if user is deleted
        if (userData['is_deleted'] == true) {
          setState(() {
            _authState = AuthState.error;
            _errorMessage =
                "Your account has been deleted. Please contact admin.";
          });
          await FirebaseAuth.instance.signOut();
          return;
        }
        currentUser = UserModel.fromJson(userData);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLogged', true);
        prefs.setString('currentUser', json.encode(userData));
        if (currentUser!.userRole.toUpperCase() == 'ADMIN') {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => const AdminBottomBar()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => const DriverBottomBar()),
          );
        }
      } else {
        setState(() {
          _authState = AuthState.error;
          _errorMessage =
              "You haven't registered yet. Please contact your Admin!";
        });
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print("Error checking Firestore: $e");
      setState(() {
        _authState = AuthState.error;
        _errorMessage = "Error loading user data: $e";
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
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(w * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: h * 0.1),
                Image.asset(
                  ImageConst.logo,
                  width: w * 0.5,
                  height: w * 0.5,
                ),
                SizedBox(height: h * 0.05),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _authState == AuthState.otpSent ||
                            _authState == AuthState.verifyingOTP
                        ? 'Enter the OTP'
                        : 'Enter your Mobile number',
                    textAlign: TextAlign.left,
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
                      TextFormField(
                        controller: mobileNumberController,
                        readOnly: _authState == AuthState.otpSent ||
                            _authState == AuthState.verifyingOTP ||
                            _authState == AuthState.authenticated,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Mobile number';
                          }
                          if (value.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: h * 0.02),

                      // OTP Field (visible only when OTP is sent)
                      if (_authState == AuthState.otpSent ||
                          _authState == AuthState.verifyingOTP ||
                          _authState == AuthState.error &&
                              _verificationId.isNotEmpty) ...[
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
                          onCompleted: (otp) {
                            // Auto-verify when OTP is completely entered
                            verifyOTP(otp);
                          },
                        )),

                        // Resend OTP button
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: h * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive OTP? ",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7)),
                              ),
                              _canResendOTP
                                  ? TextButton(
                                      onPressed: () {
                                        verifyPhoneNumber(
                                            '+91${mobileNumberController.text.trim()}');
                                      },
                                      child: const Text(
                                        "Resend",
                                        style: TextStyle(
                                          color: ColorConst.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Resend in $_resendCountdown sec",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],

                      // Error message
                      if (_errorMessage.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: h * 0.02),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: w * 0.035,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _authState == AuthState.sendingOTP ||
                                  _authState == AuthState.verifyingOTP ||
                                  _authState == AuthState.authenticated
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_authState == AuthState.otpSent) {
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
                            disabledForegroundColor:
                                Colors.white.withOpacity(0.5),
                            disabledBackgroundColor:
                                ColorConst.primaryColor.withOpacity(0.5),
                          ),
                          child: _getButtonChild(),
                        ),
                      ),
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

  Widget _getButtonChild() {
    switch (_authState) {
      case AuthState.sendingOTP:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 10),
            Text("Sending OTP..."),
          ],
        );
      case AuthState.verifyingOTP:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 10),
            Text("Verifying..."),
          ],
        );
      case AuthState.authenticated:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 10),
            Text("Signing in..."),
          ],
        );
      case AuthState.otpSent:
        return const Text(
          'VERIFY',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return const Text(
          'SEND OTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }
}
