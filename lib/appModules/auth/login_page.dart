import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/customWidgets/page_view.dart';
import 'package:pinput/pinput.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    print(controller.authStatus.value);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: [_buildBackground(h, w)]),
          ),
          _buildSignIn(
            h: h,
            w: w,
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(double h, double w) {
    return Container(
      height: h,
      width: w,
      color: Get.theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            SizedBox(height: h * 0.2),
            SizedBox(height: h * 0.3, child: _pageview()),
          ],
        ),
      ),
    );
  }

  Widget _pageview() {
    List items = [
      {
        'title': 'Easily log and monitor all your trips in real-time.',
        'gif': 'assets/1.gif',
      },
      {
        'title':
            'Track daily, weekly, and monthly income without spreadsheets.',
        'gif': 'assets/2.gif',
      },
      {
        'title':
            'Fleet owners can manage drivers, vehicles, and expenses in one place.',
        'gif': 'assets/3.gif',
      },
      {
        'title':
            'Drivers can record working hours and duties for better accountability.',
        'gif': 'assets/4.gif',
      },
      {
        'title':
            'Get smart analytics of trips, fuel usage, and earnings to optimize performance.',
        'gif': 'assets/5.gif'
      },
    ];
    return AutoPageView(
      transitionDuration: const Duration(seconds: 1),
      interval: const Duration(seconds: 5),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                items[index]['title'],
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyLarge!,
              ),
              const SizedBox(height: 20),
              //Image.asset(items[index]['gif'], height: 150),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignIn({
    required double h,
    required double w,
  }) {
    return Form(
      key: controller.loginFormkey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            width: w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Get.theme.cardColor,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                        child:
                            Image.asset('assets/icons/logo.png', width: 200)),
                    _phoneNumberField(),
                    const SizedBox(height: 20),
                    controller.authStatus.value == AuthStatus.otpSent ||
                            controller.authStatus.value ==
                                AuthStatus.verifyingOTP
                        ? otpField()
                        : const SizedBox.shrink(),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: ColorConst.primaryColor,
                            foregroundColor: Colors.black,
                            fixedSize: Size(w, 40)),
                        onPressed: controller.authStatus.value ==
                                    AuthStatus.sendingOTP ||
                                controller.authStatus.value ==
                                    AuthStatus.verifyingOTP
                            ? null
                            : () {
                                if (controller.loginFormkey.currentState!
                                    .validate()) {
                                  if (controller.authStatus.value ==
                                      AuthStatus.initial) {
                                    controller.verifyPhoneNumber();
                                  } else if (controller.authStatus.value ==
                                      AuthStatus.otpSent) {
                                    controller.verifyOtp();
                                  }
                                }
                              },
                        child: controller.authStatus.value ==
                                    AuthStatus.sendingOTP ||
                                controller.authStatus.value ==
                                    AuthStatus.verifyingOTP
                            ? const Center(child: CupertinoActivityIndicator())
                            : Text(controller.authStatus.value ==
                                    AuthStatus.initial
                                ? 'Send OTP'
                                : 'Verify OTP')),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          controller.authError.value,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.bodySmall!
                              .copyWith(color: Colors.red),
                        ),
                      ),
                    ),
                    _buildFooterSection()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneNumberField() {
    return TextFormField(
      controller: controller.phonenumberController,
      autofocus: true,
      readOnly: controller.authStatus.value != AuthStatus.initial,
      style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
      cursorColor: Colors.white,
      maxLength: 10,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onFieldSubmitted: (value) => controller.verifyPhoneNumber(),
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) async {
        if (value.length == 10) {
          FocusManager.instance.primaryFocus!.unfocus();
          await controller.verifyPhoneNumber();
        } else {
          null;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Mobile number';
        }
        if (value.length != 10) {
          return 'Enter a valid Mobile number';
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: '',
        fillColor: Colors.white12,
        suffixIcon: controller.authStatus.value == AuthStatus.otpSent
            ? TextButton(
                onPressed: () {
                  controller.authStatus.value = AuthStatus.initial;
                },
                child: const Text('Edit'))
            : null,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            '+91',
            style: Get.textTheme.bodyMedium!,
          ),
        ),
        hintText: 'Enter your phone number*',
      ),
    );
  }

  Widget otpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter OTP'),
        const SizedBox(
          height: 10,
        ),
        FractionallySizedBox(
            child: Pinput(
          autofocus: true,
          controller: controller.otpController,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          errorTextStyle: Get.textTheme.bodySmall!.copyWith(color: Colors.red),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'OTP must be 6 digits';
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'OTP must contain only digits';
            }
            return null;
          },
          defaultPinTheme: PinTheme(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withValues(alpha: 0.25),
                        blurRadius: 4,
                        spreadRadius: 2),
                  ])),
          length: 6,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          onCompleted: (otp) {
            controller.verifyOtp();
          },
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        const Text(
          ' • ',
          style: TextStyle(color: Colors.white54),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
