import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/auth/onboarding_controller.dart';
import 'package:zero/appModules/home/home_navigation.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/appModules/auth/image_upload.dart';

class OnboardingPage extends GetView<AuthController> {
  final OnboardingController onboardingController = Get.isRegistered()
      ? Get.find<OnboardingController>()
      : Get.put(OnboardingController());
  OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => PageView(
            controller: onboardingController.pageController,
            // physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLandingPage(),
              if (onboardingController.selectedMainFlow.value == "driver")
                ..._buildDriverPages(),
              if (onboardingController.selectedMainFlow.value == "fleet")
                ..._buildFleetPages(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandingPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "What brings you here?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Are you here to start your own fleet and run a business, or to find a fleet and start driving?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              onboardingController.selectedMainFlow.value = "driver";
              onboardingController.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromWidth(w),
              padding: const EdgeInsets.all(14),
            ),
            child: const Text("I'm a Driver"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              onboardingController.selectedMainFlow.value = "fleet";
              onboardingController.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromWidth(w),
              padding: const EdgeInsets.all(14),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text("I'm a fleet owner"),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDriverPages() {
    return [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "How do you want to start driving?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Choose whether you'll drive using your own vehicle, or join a fleet where cars are provided by the owner",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                onboardingController.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(w),
                padding: const EdgeInsets.all(14),
              ),
              child: const Text("I have my own Vehicle"),
            ),
            const SizedBox(height: 12),
            Obx(
              () => ElevatedButton(
                onPressed: onboardingController.isLoading.value
                    ? null
                    : () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser!.uid)
                            .update({'user_role': 'USER'});
                        currentUser = currentUser!.copyWith(userRole: 'USER');
                        Get.offAllNamed('/home');
                      },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size.fromWidth(w),
                  padding: const EdgeInsets.all(14),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: onboardingController.isLoading.value
                    ? const CupertinoActivityIndicator(
                        color: Colors.black,
                      )
                    : const Text("Join a Fleet"),
              ),
            ),
          ],
        ),
      ),
      _vehicleDetails()
    ];
  }

  List<Widget> _buildFleetPages() {
    return [_fleetDetails()];
  }

  Widget _vehicleDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: onboardingController.formkey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "Add Your Vehicle Details",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Add your car details to begin driving and tracking your earnings.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            CustomWidgets().textField(
                textInputType: TextInputType.text,
                hintText: 'AA00BB1111',
                maxLength: 10,
                label: 'Number plate',
                textController: onboardingController.numberPlateController,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle number';
                  }

                  final input = value.toUpperCase().replaceAll(' ', '');
                  final RegExp pattern =
                      RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{1,4}$');

                  if (!pattern.hasMatch(input)) {
                    return 'Enter a valid vehicle number';
                  }

                  return null;
                }),
            CustomWidgets().textField(
              textInputType: TextInputType.text,
              hintText: 'Maruti Suzuki WagonR',
              label: 'Vehicle model',
              textController: onboardingController.vehicleModelController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your vehicle\'s model';
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 10),
            ImageUpload(
              label: 'Vehicle Image',
              uploadLabel: 'vehicle_image',
              controller: controller,
              folderName: 'Vehicle images',
            ),
            const SizedBox(height: 30),
            Obx(
              () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size.fromWidth(w),
                      backgroundColor: ColorConst.primaryColor,
                      foregroundColor: Colors.black),
                  onPressed: onboardingController.isLoading.value
                      ? null
                      : () {
                          if (onboardingController.formkey.currentState!
                              .validate()) {
                            //TODO: DO THIS AFTER SETTING UP FLEET AND DRIVER

                            // onboardingController.createVehicle(
                            //     vehicleImage: controller
                            //         .uploads['vehicle_image']['image_url']);
                          }
                        },
                  child: onboardingController.isLoading.value
                      ? const CupertinoActivityIndicator(
                          color: Colors.black,
                        )
                      : const Text('Confirm')),
            )
          ],
        ),
      ),
    );
  }

  Widget _fleetDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: onboardingController.formkey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "Set up your Fleet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Add your fleet details to manage cars, drivers, and daily operations all in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            CustomWidgets().textField(
              textInputType: TextInputType.text,
              hintText: 'Your Fleet name',
              label: 'Fleet name',
              textController: onboardingController.fleetNameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your Fleet name';
                } else {
                  return null;
                }
              },
            ),
            CustomWidgets().textField(
              textInputType: TextInputType.number,
              hintText: 'Contact number',
              label: 'Contact number',
              textController: onboardingController.contactNumberController,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(15),
                child: Text('+91'),
              ),
              maxLength: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Mobile number';
                }
                if (value.length != 10) {
                  return 'Enter a valid Mobile number';
                }
                return null;
              },
            ),
            CustomWidgets().textField(
              textInputType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              hintText:
                  'Apartment, street name, Town, District, State, Zipcode.',
              label: 'Office address',
              maxLines: 3,
              textController: onboardingController.officeAddressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Office address';
                }
                return null;
              },
            ),
            Row(
              children: [
                Obx(
                  () => Checkbox(
                    activeColor: ColorConst.primaryColor,
                    checkColor: Colors.black,
                    value: onboardingController.isFleetHiring.value,
                    onChanged: (value) {
                      onboardingController.isFleetHiring.toggle();
                    },
                  ),
                ),
                const Text("I'm looking for drivers")
              ],
            ),
            const Divider(
              color: Colors.white10,
            ),
            Row(
              children: [
                const Text('Parking location'),
                const SizedBox(width: 5),
                Tooltip(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: Get.textTheme.bodySmall,
                  waitDuration: Duration.zero,
                  preferBelow: false,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  message:
                      "Make sure you're standing at the exact spot where drivers should end their duty. This location will be saved as your fleet's endpoint.\n"
                      "This helps prevent fake duty start/end locations.",
                  child: const Icon(Icons.help_outline,
                      color: Colors.grey, size: 20),
                ),
              ],
            ),
            CustomWidgets().textField(
              readOnly: true,
              textInputType: TextInputType.number,
              hintText: 'Latitude, Longitude',
              label: '',
              textController: onboardingController.latLongController,
              suffixIcon: Obx(() => TextButton(
                  onPressed: () => onboardingController.getLocation(),
                  child: onboardingController.isLoading.value
                      ? const CupertinoActivityIndicator()
                      : const Text('Fetch'))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tap on the fetch location button';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            Obx(
              () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size.fromWidth(w),
                      backgroundColor: ColorConst.primaryColor,
                      foregroundColor: Colors.black),
                  onPressed: onboardingController.isLoading.value
                      ? null
                      : () {
                          if (onboardingController.formkey.currentState!
                              .validate()) {
                            onboardingController.createfleet();
                          }
                        },
                  child: onboardingController.isLoading.value
                      ? const CupertinoActivityIndicator(
                          color: Colors.black,
                        )
                      : const Text('Confirm')),
            )
          ],
        ),
      ),
    );
  }
}
