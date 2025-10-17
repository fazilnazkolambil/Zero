import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
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
          appBar: AppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: driverStats(),
            ),
          ),
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
                currentFleet!.targets['driver']! * driver.weeklyShift!;
            final tripCompletion =
                driver.weeklyTrip! / (targetTrips > 0 ? targetTrips : 1);
            return Card(
                child: ExpandablePanel(
                    theme: const ExpandableThemeData(
                        useInkWell: false, hasIcon: false),
                    header: ListTile(
                      contentPadding: EdgeInsets.all(w * 0.03),
                      minLeadingWidth: w * 0.15,
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
                                          ? Colors.red
                                          : Colors.green),
                                  SizedBox(
                                    height: h * 0.01,
                                  ),
                                  Text(
                                      driver.onDuty != null ? 'Online' : 'Rest')
                                ],
                              ),
                            )
                          : const Icon(
                              Icons.block,
                            ),
                      title: Text(driver.fullName),
                      subtitle: driver.blocked == null
                          ? Padding(
                              padding: EdgeInsets.only(top: h * 0.01),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: tripCompletion > 1
                                          ? 1
                                          : tripCompletion,
                                      minHeight: 5,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        tripCompletion >= 1
                                            ? Colors.green
                                            : Colors.green,
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
                            )
                          : const Text('Driver have been blocked'),
                      // trailing:
                      //  PopupMenuButton(
                      //   color: ColorConst.boxColor,
                      //   child: const Icon(
                      //     Icons.more_vert_rounded,
                      //     color: ColorConst.textColor,
                      //   ),
                      //   itemBuilder: (context) {
                      //     return [
                      //       if (drivers[index].isBlocked.isEmpty)
                      //         PopupMenuItem(
                      //             onTap: () =>
                      //                 _showDriverForm(driver: drivers[index]),
                      //             child: const Text(
                      //               'Edit',
                      //               style: TextStyle(
                      //                   fontWeight: FontWeight.w600,
                      //                   color: ColorConst.textColor),
                      //             )),
                      //       PopupMenuItem(
                      //           onTap: () async {
                      //             TextEditingController reasonController =
                      //                 TextEditingController(
                      //                     text: drivers[index].isBlocked);
                      //             showDialog(
                      //                 context: context,
                      //                 builder: (context) => AlertDialog(
                      //                       backgroundColor:
                      //                           ColorConst.boxColor,
                      //                       title: Text(
                      //                           drivers[index].isBlocked.isEmpty
                      //                               ? 'Block driver?'
                      //                               : 'Ublock driver?',
                      //                           style: const TextStyle(
                      //                               color:
                      //                                   ColorConst.textColor)),
                      //                       content: drivers[index]
                      //                               .isBlocked
                      //                               .isEmpty
                      //                           ? TextField(
                      //                               controller:
                      //                                   reasonController,
                      //                               style: const TextStyle(
                      //                                   color: ColorConst
                      //                                       .textColor),
                      //                               decoration:
                      //                                   const InputDecoration(
                      //                                       border:
                      //                                           OutlineInputBorder(),
                      //                                       focusedBorder:
                      //                                           OutlineInputBorder(
                      //                                         borderSide: BorderSide(
                      //                                             color: ColorConst
                      //                                                 .primaryColor),
                      //                                       ),
                      //                                       filled: true,
                      //                                       fillColor:
                      //                                           ColorConst
                      //                                               .boxColor,
                      //                                       labelStyle: TextStyle(
                      //                                           color: ColorConst
                      //                                               .textColor),
                      //                                       labelText:
                      //                                           'Reason'),
                      //                             )
                      //                           : Text(
                      //                               'Reason : ${drivers[index].isBlocked}',
                      //                               style: const TextStyle(
                      //                                   color: ColorConst
                      //                                       .textColor,
                      //                                   fontWeight:
                      //                                       FontWeight.bold),
                      //                             ),
                      //                       actions: [
                      //                         TextButton(
                      //                             style: const ButtonStyle(
                      //                               side: WidgetStatePropertyAll(
                      //                                   BorderSide(
                      //                                       color: ColorConst
                      //                                           .primaryColor)),
                      //                               foregroundColor:
                      //                                   WidgetStatePropertyAll(
                      //                                       ColorConst
                      //                                           .primaryColor),
                      //                             ),
                      //                             onPressed: () =>
                      //                                 Navigator.pop(context),
                      //                             child: const Text('No')),
                      //                         TextButton(
                      //                             style: const ButtonStyle(
                      //                               foregroundColor:
                      //                                   WidgetStatePropertyAll(
                      //                                       ColorConst
                      //                                           .backgroundColor),
                      //                               backgroundColor:
                      //                                   WidgetStatePropertyAll(
                      //                                       ColorConst
                      //                                           .primaryColor),
                      //                             ),
                      //                             onPressed: () async {
                      //                               if (reasonController
                      //                                   .text.isNotEmpty) {
                      //                                 await FirebaseFirestore
                      //                                     .instance
                      //                                     .collection('users')
                      //                                     .doc(drivers[index]
                      //                                         .driverId)
                      //                                     .update({
                      //                                   'organisation_id': '',
                      //                                   'organisation_name': '',
                      //                                   'status': drivers[index]
                      //                                           .isBlocked
                      //                                           .isEmpty
                      //                                       ? 'BLOCKED'
                      //                                       : 'ACTIVE',
                      //                                   'is_blocked': drivers[
                      //                                               index]
                      //                                           .isBlocked
                      //                                           .isEmpty
                      //                                       ? reasonController
                      //                                           .text
                      //                                       : ''
                      //                                 });
                      //                                 await FirebaseFirestore
                      //                                     .instance
                      //                                     .collection(
                      //                                         'organisations')
                      //                                     .doc(currentUser!
                      //                                         .organisationId)
                      //                                     .collection('drivers')
                      //                                     .doc(drivers[index]
                      //                                         .driverId)
                      //                                     .update({
                      //                                   'is_blocked': drivers[
                      //                                               index]
                      //                                           .isBlocked
                      //                                           .isEmpty
                      //                                       ? reasonController
                      //                                           .text
                      //                                       : ''
                      //                                 });
                      //                                 Fluttertoast.showToast(
                      //                                     msg: drivers[index]
                      //                                             .isBlocked
                      //                                             .isEmpty
                      //                                         ? 'Driver blocked!'
                      //                                         : 'Driver unblocked');
                      //                                 Navigator.pop(context);
                      //                                 getDrivers();
                      //                               } else {
                      //                                 Fluttertoast.showToast(
                      //                                     msg:
                      //                                         'Enter the reason!',
                      //                                     toastLength: Toast
                      //                                         .LENGTH_SHORT);
                      //                               }
                      //                             },
                      //                             child: const Text('Yes')),
                      //                       ],
                      //                     ));
                      //           },
                      //           child: Text(
                      //               drivers[index].isBlocked.isEmpty
                      //                   ? 'Block'
                      //                   : 'Unblock',
                      //               style: TextStyle(
                      //                   fontWeight: FontWeight.w600,
                      //                   color: drivers[index].isBlocked.isEmpty
                      //                       ? ColorConst.textColor
                      //                       : ColorConst.errorColor))),
                      //       if (drivers[index].isBlocked.isEmpty)
                      //         PopupMenuItem(
                      //             onTap: () async {
                      //               showDialog(
                      //                   context: context,
                      //                   builder: (context) => AlertDialog(
                      //                         backgroundColor:
                      //                             ColorConst.boxColor,
                      //                         title: const Text(
                      //                             'Remove driver?',
                      //                             style: TextStyle(
                      //                                 color: ColorConst
                      //                                     .textColor)),
                      //                         content: const Text(
                      //                           'Are you sure you want to remove this driver?',
                      //                           style: TextStyle(
                      //                               color:
                      //                                   ColorConst.textColor),
                      //                         ),
                      //                         actions: [
                      //                           TextButton(
                      //                               style: const ButtonStyle(
                      //                                 foregroundColor:
                      //                                     WidgetStatePropertyAll(
                      //                                         ColorConst
                      //                                             .primaryColor),
                      //                               ),
                      //                               onPressed: () =>
                      //                                   Navigator.pop(context),
                      //                               child: const Text('No')),
                      //                           TextButton(
                      //                               style: const ButtonStyle(
                      //                                 foregroundColor:
                      //                                     WidgetStatePropertyAll(
                      //                                         ColorConst
                      //                                             .backgroundColor),
                      //                                 backgroundColor:
                      //                                     WidgetStatePropertyAll(
                      //                                         ColorConst
                      //                                             .primaryColor),
                      //                               ),
                      //                               onPressed: () async {
                      //                                 await FirebaseFirestore
                      //                                     .instance
                      //                                     .collection('users')
                      //                                     .doc(drivers[index]
                      //                                         .driverId)
                      //                                     .update({
                      //                                   'organisation_id': '',
                      //                                   'organisation_name': '',
                      //                                   'status': 'LEFT_COMPANY'
                      //                                 });
                      //                                 await FirebaseFirestore
                      //                                     .instance
                      //                                     .collection(
                      //                                         'organisations')
                      //                                     .doc(currentUser!
                      //                                         .organisationId)
                      //                                     .collection('drivers')
                      //                                     .doc(drivers[index]
                      //                                         .driverId)
                      //                                     .update({
                      //                                   'is_deleted': true
                      //                                 });
                      //                                 Fluttertoast.showToast(
                      //                                     msg:
                      //                                         'Driver have been removed!',
                      //                                     toastLength: Toast
                      //                                         .LENGTH_SHORT,
                      //                                     gravity: ToastGravity
                      //                                         .TOP_LEFT);
                      //                                 Navigator.pop(context);
                      //                                 getDrivers();
                      //                               },
                      //                               child: const Text('Yes')),
                      //                         ],
                      //                       ));
                      //             },
                      //             child: const Text('Remove',
                      //                 style: TextStyle(
                      //                     fontWeight: FontWeight.w600,
                      //                     color: ColorConst.textColor))
                      //                     ),
                      //     ];
                      //   },
                      // )
                    ),
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
