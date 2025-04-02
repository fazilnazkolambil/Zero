import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zero/adminPages/controller/admin_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero/models/vehicle_model.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Stream<List<VehicleModel>> getVehicles() {
    return FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('vehicles')
        .snapshots()
        .map((event) =>
            event.docs.map((e) => VehicleModel.fromJson(e.data())).toList());
  }

  @override
  void initState() {
    getVehicles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.primaryColor,
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: getVehicles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Expanded(
                    child: Center(
                      child: CupertinoActivityIndicator(
                          color: ColorConst.primaryColor),
                    ),
                  );
                }
                return snapshot.data!.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text('No vehicles added!',
                              style: TextStyle(color: ColorConst.primaryColor)),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            VehicleModel vehicle = snapshot.data![index];
                            return Container(
                                width: w,
                                height: h * 0.2,
                                margin: EdgeInsets.all(w * 0.05),
                                padding: EdgeInsets.all(w * 0.05),
                                decoration: BoxDecoration(
                                    color: ColorConst.backgroundColor,
                                    borderRadius:
                                        BorderRadius.circular(w * 0.03),
                                    boxShadow: [
                                      BoxShadow(
                                          color: ColorConst.primaryColor
                                              .withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 5)
                                    ]),
                                child: vehicle.onDuty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(vehicle.vehicleNumber,
                                              style: TextStyle(
                                                  fontSize: w * 0.06,
                                                  color:
                                                      ColorConst.primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                          Text('Driver : ${vehicle.driver}',
                                              style: TextStyle(
                                                  fontSize: w * 0.05,
                                                  color:
                                                      ColorConst.primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              'Start time : ${DateFormat.jm().format(vehicle.startTime.toDate())}',
                                              style: TextStyle(
                                                  fontSize: w * 0.05,
                                                  color:
                                                      ColorConst.primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(vehicle.vehicleNumber,
                                              style: TextStyle(
                                                  fontSize: w * 0.06,
                                                  color:
                                                      ColorConst.primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              'Last trip : ${DateFormat.jm().format(vehicle.lastDriven.toDate())}',
                                              style: TextStyle(
                                                  fontSize: w * 0.05,
                                                  color:
                                                      ColorConst.primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ));
                          },
                        ),
                      );
              }),
        ],
      ),
    );
  }
}
