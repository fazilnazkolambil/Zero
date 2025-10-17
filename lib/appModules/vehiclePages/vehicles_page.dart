import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/vehiclePages/add_vehicle.dart';
import 'package:zero/appModules/vehiclePages/vehicle_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:timeago/timeago.dart' as timeago;

class VehiclesPage extends StatelessWidget {
  final VehicleController controller = Get.isRegistered()
      ? Get.find<VehicleController>()
      : Get.put(VehicleController());
  VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              controller.clearAll();
              Get.to(() => const AddVehiclePage());
            },
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: vehicleStats(),
            ),
          ),
          body: Obx(
            () => RefreshIndicator(
              color: ColorConst.primaryColor,
              onRefresh: () => controller.listVehicles(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [_buildVehiclesTab()],
                ),
              ),
            ),
          )),
    );
  }

  Widget vehicleStats() {
    return Obx(() {
      int inUseVehicles =
          controller.vehicles.where((element) => element.onDuty != null).length;
      int availableVehicles = controller.vehicles.length - inUseVehicles;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.vehicles.length.toString()),
              SizedBox(height: w * 0.03),
              const Text(
                'Vehicles',
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
              Text(inUseVehicles.toString()),
              SizedBox(height: w * 0.03),
              const Text(
                'In use',
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
                availableVehicles.toString(),
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
          // ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          //     ),
          //     onPressed: () {},
          //     child: const Text('Add new'))
        ],
      );
    });
  }

  Widget _buildVehiclesTab() {
    if (controller.vehicles.isEmpty) {
      return SizedBox(
        height: 500,
        width: w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No vehicles added yet',
              style:
                  Get.textTheme.titleLarge!.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap the + button to add new',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
        padding: const EdgeInsets.all(5),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = controller.vehicles[index];
          final tripCompletion = vehicle.weeklyTrips! /
              (vehicle.targetTrips > 0 ? vehicle.targetTrips : 1);
          return Card(
              child: ExpandablePanel(
            theme: const ExpandableThemeData(hasIcon: false, useInkWell: false),
            collapsed: const SizedBox(),
            expanded: Padding(
              padding: EdgeInsets.all(w * 0.03),
              child: Column(
                children: [
                  CustomWidgets().textRow(
                      label: 'Last driver', value: vehicle.lastDriver!),
                  if (vehicle.onDuty == null)
                    CustomWidgets().textRow(
                        label: 'Last online',
                        value: timeago.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                vehicle.lastOnline!))),
                  // CustomWidgets().textRow(
                  //     label: 'Rent per shift', value: 500.toStringAsFixed(0)),
                  CustomWidgets().textRow(
                      label: 'Added on',
                      value: DateFormat('dd-MM-yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(vehicle.addedOn)))
                ],
              ),
            ),
            header: ListTile(
                contentPadding: EdgeInsets.all(w * 0.03),
                minLeadingWidth: w * 0.15,
                leading: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: w * 0.04,
                      ),
                      SizedBox(
                        height: h * 0.01,
                      ),
                      Text(
                        vehicle.onDuty != null ? 'Online' : 'Idle',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                title: Text(vehicle.numberPlate),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: h * 0.01),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: tripCompletion > 1 ? 1 : tripCompletion,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            tripCompletion >= 1 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${vehicle.weeklyTrips.toString()} / ${vehicle.targetTrips.toString()} trips',
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
                          onTap: () {
                            controller.clearAll();
                            Get.to(() => AddVehiclePage(
                                  vehicle: vehicle,
                                ));
                          },
                          child: const Text('Edit')),
                      PopupMenuItem(
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Remove vehicle?'),
                                      content: const Text(
                                        'Are you sure you want to remove this vehicle?',
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('No')),
                                        TextButton(
                                            onPressed: () async {
                                              await controller.removeVehicle(
                                                  vehicleId: vehicle.vehicleId);
                                              Get.back();
                                            },
                                            child: Obx(() => controller
                                                    .isLoading.value
                                                ? const CupertinoActivityIndicator()
                                                : const Text('Yes'))),
                                      ],
                                    ));
                          },
                          child: const Text('Delete')),
                    ];
                  },
                )),
          ));
        });
  }
}
