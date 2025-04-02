import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/adminPages/screens/admin_bottom_page.dart';
import 'package:zero/driverPages/driver_home.dart';
import 'package:zero/models/user_model.dart';

final authProvider =
    ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());

class AuthProvider with ChangeNotifier {
  String? _verificationId;
  bool isLoading = false;
  bool otpField = false;
  UserModel? currentUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BuildContext? _context; // Context reference for snackbars

  void setContext(BuildContext context) {
    _context = context;
  }

  void _showSnackbar(String message) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// **Phone Authentication - Send OTP**
  Future<void> verifyPhoneNumber({required String mobileNumber}) async {
    try {
      isLoading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            await checkUserInFirestore();
          } catch (e) {
            _showSnackbar("Auto-verification failed: $e");
          } finally {
            isLoading = false;
            notifyListeners();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackbar(e.message ?? "Verification failed. Try again.");
          isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          otpField = true;
          isLoading = false;
          notifyListeners();
          _showSnackbar(
              "OTP sent to +91${mobileNumber.replaceRange(0, mobileNumber.length - 3, '*' * 5)} successfully!");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _showSnackbar("Error: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  /// **Verify OTP and Authenticate User**
  Future<void> verifyOTP({required String otp}) async {
    if (_verificationId == null) {
      _showSnackbar("Something went wrong. Please try again.");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await checkUserInFirestore();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar("Invalid OTP. Please try again.");
    } catch (e) {
      _showSnackbar("Something went wrong. Please try again.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// **Check if User Exists in Firestore**
  Future<void> checkUserInFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _showSnackbar("User not authenticated.");
        return;
      }

      var userDoc = await _firestore
          .collection('users')
          .where('mobile_number', isEqualTo: user.phoneNumber)
          .limit(1) // Optimized query with limit
          .get();

      if (userDoc.docs.isNotEmpty) {
        currentUser = UserModel.fromJson(userDoc.docs.first.data());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLogged', true);
        prefs.setString('currentUser', json.encode(userDoc.docs.first.data()));

        if (_context != null) {
          if (currentUser!.userRole.toUpperCase() == 'ADMIN') {
            Navigator.pushReplacement(_context!,
                CupertinoPageRoute(builder: (context) => AdminBottomBar()));
          } else {
            Navigator.pushReplacement(_context!,
                CupertinoPageRoute(builder: (context) => DriverHomePage()));
          }
        }
      } else {
        _showSnackbar(
            "You haven't registered to Zero yet. Please contact your Admin!");
        otpField = false;
        notifyListeners();
      }
    } catch (e) {
      _showSnackbar("Error: $e");
      otpField = false;
      notifyListeners();
    }
  }
}
