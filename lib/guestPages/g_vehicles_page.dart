import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:zero/adminPages/screens/admin_notifications.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class GVehiclesPage extends StatefulWidget {
  const GVehiclesPage({super.key});

  @override
  State<GVehiclesPage> createState() => _GVehiclesPageState();
}

class _GVehiclesPageState extends State<GVehiclesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  [appbar(), vehicleStats()],
              body: SingleChildScrollView(
                child: Column(
                  children: [_buildVehiclesTab()],
                ),
              ))),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      toolbarHeight: h * 0.1,
      title: const Text('Vehicle details',
          style: TextStyle(
              color: ColorConst.textColor, fontWeight: FontWeight.bold)),
      backgroundColor: ColorConst.boxColor,
      elevation: 2,
      actions: [
        IconButton(
            onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AdminNotifications(),
                )),
            icon: const Icon(Icons.notifications, color: ColorConst.textColor))
      ],
    );
  }

  Widget vehicleStats() {
    int inUseVehicles = 1;
    int availableVehicles = 1 - inUseVehicles;
    return SliverAppBar(
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      toolbarHeight: h * 0.1,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Card(
          color: ColorConst.boxColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    1.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor),
                  ),
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
                  Text(
                    inUseVehicles.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor),
                  ),
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
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor),
                  ),
                  SizedBox(height: w * 0.03),
                  const Text(
                    'Idle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () => {
                        Fluttertoast.showToast(
                            msg: 'Not available in trial mode')
                      },
                  icon: const Icon(
                    Icons.add,
                    color: ColorConst.textColor,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehiclesTab() {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 1,
        itemBuilder: (context, index) {
          int targetTrips = 140;
          final tripCompletion = 125 / (targetTrips > 0 ? targetTrips : 1);
          return Card(
              color: ColorConst.boxColor,
              margin: EdgeInsets.symmetric(
                  horizontal: w * 0.03, vertical: w * 0.03),
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                    hasIcon: false, useInkWell: false),
                collapsed: const SizedBox(),
                expanded: Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Column(
                    children: [
                      _textRow(
                          label: 'Rent per shift',
                          value: 500.toStringAsFixed(0)),
                      _textRow(label: 'Rental plan', value: 'plan_rent'),
                      _textRow(
                          label: 'Added on',
                          value:
                              DateFormat('dd-MM-yyyy').format(DateTime.now())),
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
                          Icon(Icons.circle,
                              size: w * 0.04, color: ColorConst.successColor),
                          SizedBox(
                            height: h * 0.01,
                          ),
                          Text(
                            'On duty',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorConst.textColor,
                                fontSize: w * 0.04),
                          ),
                        ],
                      ),
                    ),
                    title: const Text(
                      'AB12CD3456',
                      style: TextStyle(
                          color: ColorConst.textColor,
                          fontWeight: FontWeight.bold),
                    ),
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
                                tripCompletion >= 1
                                    ? ColorConst.successColor
                                    : ColorConst.errorColor,
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.01),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${125.toString()} / ${targetTrips.toString()} trips',
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
                      color: ColorConst.boxColor,
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: ColorConst.textColor,
                      ),
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                              child: Text(
                            'Edit',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ColorConst.textColor),
                          )),
                          const PopupMenuItem(
                              child: Text('Delete',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: ColorConst.textColor))),
                        ];
                      },
                    )),
              ));
        });
  }

  _textRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: w * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
                color: ColorConst.textColor, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
