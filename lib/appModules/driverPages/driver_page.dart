import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/driverPages/add_driver.dart';
import 'package:zero/appModules/driverPages/driver_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/user_model.dart';

class DriversPage extends StatelessWidget {
  final DriverController controller = Get.isRegistered()
      ? Get.find<DriverController>()
      : Get.put(DriverController());
  DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              controller.foundUser.value = null;
              controller.phoneController.clear();
              Get.to(() => const AddDriverPage());
            },
            child: const Icon(Icons.person_add_alt_1),
          ),
          // appBar: AppBar(
          //   flexibleSpace: FlexibleSpaceBar(
          //     background: driverStats(),
          //   ),
          // ),
          body: RefreshIndicator(
            color: ColorConst.primaryColor,
            onRefresh: () => controller.listDrivers(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [_buildDriverTab()],
              ),
            ),
          )),
    );
  }

  Widget driverStats() {
    return Obx(() {
      List<UserModel> drivers = controller.driverList;
      int onDutyDrivers = drivers.where((e) => e.onDuty != null).length;
      int availableDrivers = drivers.length - onDutyDrivers;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                drivers.length.toString(),
              ),
              SizedBox(height: w * 0.03),
              const Text(
                'Drivers',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                onDutyDrivers.toString(),
              ),
              SizedBox(height: w * 0.03),
              const Text(
                'On duty',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                availableDrivers.toString(),
              ),
              SizedBox(height: w * 0.03),
              const Text(
                'On rest',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildDriverTab() {
    return Obx(() {
      if (controller.driverList.isEmpty) {
        return SizedBox(
          height: 500,
          width: w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_2, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No drivers added yet',
                style:
                    Get.textTheme.titleLarge!.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Text(
                'Tap the + button to add new driver',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.driverList.length,
          itemBuilder: (context, index) {
            final driver = controller.driverList[index];
            int targetTrips =
                currentUser!.fleet!.targets['driver']! * driver.weeklyShift!;
            final tripCompletion =
                driver.weeklyTrip! / (targetTrips > 0 ? targetTrips : 1);
            return Card(
                child: ExpandablePanel(
                    theme: const ExpandableThemeData(
                        useInkWell: false, hasIcon: false),
                    header: ListTile(
                        // minLeadingWidth: w * 0.15,
                        leading: driver.blocked == null
                            ? Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: w * 0.03),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.circle,
                                        size: w * 0.04,
                                        color: driver.onDuty == null
                                            ? Colors.green
                                            : Colors.red),
                                    SizedBox(
                                      height: h * 0.01,
                                    ),
                                    Text(driver.onDuty != null
                                        ? 'On duty'
                                        : 'On rest')
                                  ],
                                ),
                              )
                            : const Icon(
                                Icons.block,
                              ),
                        title: Text(driver.fullName),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: h * 0.01),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value:
                                      tripCompletion > 1 ? 1 : tripCompletion,
                                  minHeight: 5,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    tripCompletion >= 1
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              SizedBox(height: h * 0.01),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${driver.weeklyTrip.toString()} / ${targetTrips.toString()} trips',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton(
                          child: const Icon(
                            Icons.more_vert_rounded,
                          ),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                  onTap: () async {
                                    if (driver.onDuty != null) {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Driver is on duty. Please try again after the driver finishing duty',
                                          backgroundColor: Colors.red);
                                    } else {
                                      Get.dialog(
                                          barrierDismissible: false,
                                          AlertDialog(
                                            title: const Text('Remove driver?'),
                                            content: const Text(
                                                'Are you sure you want to remove this driver from your fleet?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => Get.back(),
                                                  child:
                                                      const Text('No, cancel')),
                                              TextButton(
                                                  onPressed: () {
                                                    controller.removeDriver(
                                                        userId: driver.uid);
                                                    Get.back();
                                                  },
                                                  child: const Text(
                                                      'Yes, confirm')),
                                            ],
                                          ));
                                    }
                                  },
                                  child: const Text('Remove')),
                            ];
                          },
                        )),
                    collapsed: const SizedBox(),
                    expanded: Padding(
                      padding: EdgeInsets.all(w * 0.03),
                      child: Column(
                        children: [
                          CustomWidgets().textRow(
                              label: driver.onDuty == null
                                  ? 'Last vehicle'
                                  : 'Current vehicle',
                              value: driver.onDuty == null
                                  ? driver.lastVehicle
                                  : driver.onDuty!.vehicleNumber),
                          CustomWidgets().textRow(
                              label: 'Wallet',
                              value: driver.wallet.toStringAsFixed(2)),
                          ElevatedButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('View activities',
                                      style: Get.textTheme.bodySmall),
                                  const SizedBox(width: 5),
                                  Icon(
                                    Icons.play_arrow,
                                    size: Get.textTheme.bodySmall!.fontSize,
                                    color: Get.textTheme.bodySmall!.color,
                                  )
                                ],
                              ))
                        ],
                      ),
                    )));
          });
    });
  }
}
