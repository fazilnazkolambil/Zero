import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/auth/auth_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/driver_model.dart';
import 'package:zero/models/rent_model.dart';
import 'package:zero/models/vehicle_model.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool isLoading = true;
  DriverModel? currentDriver;
  RentModel? rentModel;
  TextEditingController searchController = TextEditingController();
  String searchkey = '';

  Future getDriverDetails() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('drivers')
        .doc(currentUser!.userId)
        .get()
        .then((value) {
      currentDriver =
          DriverModel.fromJson(value.data() as Map<String, dynamic>);
    });
    log(currentDriver!.toJson().toString());
    if (currentDriver!.onRent.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('organisations')
          .doc(currentUser!.organisationId)
          .collection('rents')
          .doc(currentDriver!.onRent)
          .get()
          .then(
        (value) {
          rentModel = RentModel.fromMap(value.data() as Map<String, dynamic>);
        },
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getDriverDetails();
    super.initState();
  }

  Stream<List<VehicleModel>> getVehicles() {
    return FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('vehicles')
        .where('on_duty', isEqualTo: false)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((event) =>
            event.docs.map((e) => VehicleModel.fromJson(e.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.backgroundColor,
      appBar: AppBar(
        toolbarHeight: h * 0.1,
        title: const Text('Home',
            style: TextStyle(
                color: ColorConst.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: ColorConst.boxColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: ColorConst.primaryColor),
            onPressed: () => _logOutDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
                color: ColorConst.primaryColor,
              ),
            )
          : currentDriver!.onRent.isNotEmpty
              ? driverOnDuty()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(w * 0.03),
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchkey = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          suffixIcon: Padding(
                              padding: EdgeInsets.all(w * 0.03),
                              child: Icon(
                                Icons.search,
                                color: ColorConst.primaryColor.withOpacity(0.5),
                              )),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(w * 0.05)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.05),
                            borderSide: BorderSide(
                                color:
                                    ColorConst.primaryColor.withOpacity(0.3)),
                          ),
                          filled: true,
                          fillColor: ColorConst.boxColor,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: ColorConst.textColor),
                      ),
                    ),
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
                                        style: TextStyle(
                                            color: ColorConst.primaryColor)),
                                  ),
                                )
                              : Expanded(
                                  child: ListView.builder(
                                    // shrinkWrap: true,
                                    // physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      VehicleModel vehicle =
                                          snapshot.data![index];
                                      return vehicle.vehicleNumber
                                              .toLowerCase()
                                              .contains(searchkey.toLowerCase())
                                          ? Container(
                                              width: w,
                                              height: h * 0.2,
                                              margin: EdgeInsets.all(w * 0.05),
                                              padding: EdgeInsets.all(w * 0.05),
                                              decoration: BoxDecoration(
                                                  color: ColorConst
                                                      .backgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          w * 0.03),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: ColorConst
                                                            .primaryColor
                                                            .withOpacity(0.5),
                                                        blurRadius: 10,
                                                        spreadRadius: 5)
                                                  ]),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(vehicle.vehicleNumber,
                                                      style: TextStyle(
                                                          fontSize: w * 0.06,
                                                          color: ColorConst
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  PopupMenuButton(
                                                    color: ColorConst.boxColor,
                                                    onSelected:
                                                        (shiftValue) async {
                                                      var getRents =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'organisations')
                                                              .doc(currentUser!
                                                                  .organisationId)
                                                              .collection(
                                                                  'rents')
                                                              .get();
                                                      String rentId =
                                                          'rentid${getRents.size}';
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'organisations')
                                                          .doc(currentUser!
                                                              .organisationId)
                                                          .collection('rents')
                                                          .doc(rentId)
                                                          .set(RentModel(
                                                                  rentId:
                                                                      rentId,
                                                                  driverId:
                                                                      currentDriver!
                                                                          .driverId,
                                                                  vehicleId: vehicle
                                                                      .vehicleId,
                                                                  vehicleNumber:
                                                                      vehicle
                                                                          .vehicleNumber,
                                                                  startTime:
                                                                      Timestamp
                                                                          .now(),
                                                                  rent: vehicle
                                                                      .rent,
                                                                  shift: int.parse(
                                                                      shiftValue),
                                                                  totalTrips: 0,
                                                                  totalEarnings:
                                                                      0,
                                                                  cashCollected:
                                                                      0,
                                                                  totaltoPay: 0,
                                                                  refund: 0,
                                                                  rentStatus:
                                                                      'ongoing')
                                                              .toJson());
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'organisations')
                                                          .doc(currentUser!
                                                              .organisationId)
                                                          .collection(
                                                              'vehicles')
                                                          .doc(
                                                              vehicle.vehicleId)
                                                          .update({
                                                        'driver': currentDriver!
                                                            .driverId,
                                                        'on_duty': true,
                                                        'start_time':
                                                            DateTime.now(),
                                                        'selected_shift':
                                                            int.parse(
                                                                shiftValue)
                                                      });
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'organisations')
                                                          .doc(currentUser!
                                                              .organisationId)
                                                          .collection('drivers')
                                                          .doc(currentUser!
                                                              .userId)
                                                          .update({
                                                        'on_rent': rentId
                                                      });
                                                      await getDriverDetails();
                                                    },
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                          value: "1",
                                                          child: Text(
                                                            "12 hrs",
                                                            style: TextStyle(
                                                                color: ColorConst
                                                                    .primaryColor),
                                                          )),
                                                      const PopupMenuItem(
                                                          value: "2",
                                                          child: Text(
                                                            "24 hrs",
                                                            style: TextStyle(
                                                                color: ColorConst
                                                                    .primaryColor),
                                                          )),
                                                    ],
                                                    child: const ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                WidgetStatePropertyAll(
                                                                    ColorConst
                                                                        .boxColor)),
                                                        onPressed: null,
                                                        child: Text(
                                                          'Start duty',
                                                          style: TextStyle(
                                                              color: ColorConst
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                  )
                                                ],
                                              ))
                                          : const SizedBox();
                                    },
                                  ),
                                );
                        }),
                  ],
                ),
    );
  }

  Widget _buildDriverStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: ColorConst.boxColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Today\'s Trips', '0'),
              _buildStatItem('Today\'s Earnings', '\$0'),
              _buildStatItem('Week Total', '\$0'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: ColorConst.textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: ColorConst.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget titleText() {
    return Padding(
      padding: EdgeInsets.all(w * 0.03),
      child: SizedBox(
        width: w * 0.8,
        // height: h * 0.2,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back',
                style: TextStyle(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.primaryColor)),
            Text('${currentDriver!.driverName}!',
                style: TextStyle(
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.primaryColor)),
            SizedBox(
              height: h * 0.02,
            ),
            Text(
              DateFormat.MMMMEEEEd().format(DateTime.now()),
              style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.bold,
                  color: ColorConst.primaryColor.withOpacity(0.8)),
            ),
            SizedBox(width: w * 0.04),
            Text(
              DateFormat.Hm().format(DateTime.now()),
              style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.bold,
                  color: ColorConst.primaryColor.withOpacity(0.8)),
            )
          ],
        ),
      ),
    );
  }

  Widget driverOnDuty() {
    TextEditingController totalTripsController = TextEditingController();
    TextEditingController totalEarningscontroller = TextEditingController();
    TextEditingController refundController = TextEditingController();
    TextEditingController cashCollectedcontroller = TextEditingController();
    final formkey = GlobalKey<FormState>();
    return isLoading
        ? const Center(
            child: CupertinoActivityIndicator(color: ColorConst.primaryColor),
          )
        : SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  Center(
                      child: Container(
                    width: w,
                    // height: h * 0.2,
                    margin: EdgeInsets.all(w * 0.05),
                    padding: EdgeInsets.all(w * 0.05),
                    decoration: BoxDecoration(
                        color: ColorConst.backgroundColor,
                        borderRadius: BorderRadius.circular(w * 0.03),
                        boxShadow: [
                          BoxShadow(
                              color: ColorConst.primaryColor.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 5)
                        ]),
                    child: Column(
                      children: [
                        Text(rentModel!.vehicleNumber,
                            style: TextStyle(
                                fontSize: w * 0.06,
                                color: ColorConst.primaryColor,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: h * 0.02),
                        Text(
                            'Started time : ${DateFormat.jm().format(rentModel!.startTime.toDate())}',
                            style: TextStyle(
                                fontSize: w * 0.04,
                                color: ColorConst.primaryColor,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: h * 0.02),
                        TextFormField(
                          controller: totalTripsController,
                          maxLength: 2,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Total trips',
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                                padding: EdgeInsets.all(w * 0.03),
                                child: const Icon(Icons.car_rental_outlined,
                                    color: ColorConst.primaryColor)),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter the Total trips";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: h * 0.02),
                        TextFormField(
                          controller: totalEarningscontroller,
                          decoration: InputDecoration(
                            labelText: 'Total Earnings',
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                                padding: EdgeInsets.all(w * 0.05),
                                child: Text(
                                  '₹',
                                  style: TextStyle(
                                      color: ColorConst.primaryColor,
                                      fontSize: w * 0.05),
                                )),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter the Total earnings";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: h * 0.02),
                        TextFormField(
                          controller: refundController,
                          decoration: InputDecoration(
                            labelText: 'Refund',
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                                padding: EdgeInsets.all(w * 0.05),
                                child: Text(
                                  '₹',
                                  style: TextStyle(
                                      color: ColorConst.primaryColor,
                                      fontSize: w * 0.05),
                                )),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter the refund amount";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: h * 0.02),
                        TextFormField(
                          controller: cashCollectedcontroller,
                          decoration: InputDecoration(
                            labelText: 'Cash Collected',
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                                padding: EdgeInsets.all(w * 0.05),
                                child: Text(
                                  '₹',
                                  style: TextStyle(
                                      color: ColorConst.primaryColor,
                                      fontSize: w * 0.05),
                                )),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter the Cash collected amount";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: h * 0.03),
                        ElevatedButton(
                            style: ButtonStyle(
                              side: const WidgetStatePropertyAll(
                                  BorderSide(color: ColorConst.primaryColor)),
                              backgroundColor: const WidgetStatePropertyAll(
                                  ColorConst.boxColor),
                              fixedSize:
                                  WidgetStatePropertyAll(Size(w, h * 0.07)),
                              foregroundColor: const WidgetStatePropertyAll(
                                  ColorConst.primaryColor),
                            ),
                            onPressed: () async {
                              if (Timestamp.now()
                                      .toDate()
                                      .difference(rentModel!.startTime.toDate())
                                      .inHours <
                                  2) {
                                if (formkey.currentState!.validate()) {
                                  TextEditingController reasonController =
                                      TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: ColorConst.boxColor,
                                      title: const Text('Cancel shift?',
                                          style: TextStyle(
                                              color: ColorConst.primaryColor)),
                                      content: TextField(
                                        controller: reasonController,
                                        style: const TextStyle(
                                            color: ColorConst.textColor),
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      ColorConst.primaryColor),
                                            ),
                                            filled: true,
                                            fillColor: ColorConst.boxColor,
                                            labelStyle: TextStyle(
                                                color: ColorConst.textColor),
                                            labelText: 'Reason'),
                                      ),
                                      actions: [
                                        TextButton(
                                            style: const ButtonStyle(
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      ColorConst.primaryColor),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('No')),
                                        TextButton(
                                            style: const ButtonStyle(
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      ColorConst
                                                          .backgroundColor),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      ColorConst.primaryColor),
                                            ),
                                            onPressed: () async {
                                              if (reasonController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Enter the reason')));
                                              } else {
                                                await FirebaseFirestore.instance
                                                    .collection('organisations')
                                                    .doc(currentUser!
                                                        .organisationId)
                                                    .collection('rents')
                                                    .doc(rentModel!.rentId)
                                                    .update({
                                                  'end_time': Timestamp.now(),
                                                  'total_trips': FieldValue
                                                      .increment(int.parse(
                                                          totalTripsController
                                                              .text)),
                                                  'total_earnings': FieldValue
                                                      .increment(double.parse(
                                                          totalEarningscontroller
                                                              .text)),
                                                  'cash_collected': FieldValue
                                                      .increment(double.parse(
                                                          cashCollectedcontroller
                                                              .text)),
                                                  'refund':
                                                      FieldValue.increment(
                                                          double.parse(
                                                              refundController
                                                                  .text)),
                                                  'total_to_pay': 0,
                                                  'rent_status':
                                                      'canceled:${reasonController.text}',
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('organisations')
                                                    .doc(currentUser!
                                                        .organisationId)
                                                    .collection('vehicles')
                                                    .doc(rentModel!.vehicleId)
                                                    .update({
                                                  'driver': '',
                                                  'on_duty': false,
                                                  'start_time': Timestamp.now(),
                                                  'last_driven':
                                                      Timestamp.now(),
                                                  'selected_shift': 0,
                                                  'total_trips': FieldValue
                                                      .increment(int.parse(
                                                          totalTripsController
                                                              .text)),
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('organisations')
                                                    .doc(currentUser!
                                                        .organisationId)
                                                    .collection('drivers')
                                                    .doc(currentUser!.userId)
                                                    .update({
                                                  'on_rent': '',
                                                  'cash_collected': FieldValue
                                                      .increment(double.parse(
                                                          cashCollectedcontroller
                                                              .text)),
                                                  'total_earnings': FieldValue
                                                      .increment(double.parse(
                                                          totalEarningscontroller
                                                              .text)),
                                                  'refund':
                                                      FieldValue.increment(
                                                          double.parse(
                                                              refundController
                                                                  .text)),
                                                  'total_trips': FieldValue
                                                      .increment(int.parse(
                                                          totalTripsController
                                                              .text))
                                                });
                                                await getDriverDetails();
                                              }
                                            },
                                            child: const Text('Yes')),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Fill the required fields!')));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Cannot cancel the shift anymore. Please end the shift!')));
                              }
                            },
                            child: const Text("Cancel shift")),
                        SizedBox(height: h * 0.02),
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                  ColorConst.primaryColor),
                              fixedSize:
                                  WidgetStatePropertyAll(Size(w, h * 0.07)),
                              foregroundColor: const WidgetStatePropertyAll(
                                  ColorConst.backgroundColor),
                            ),
                            onPressed: () {
                              if (formkey.currentState!.validate()) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: ColorConst.boxColor,
                                    title: const Text('End shift?',
                                        style: TextStyle(
                                            color: ColorConst.primaryColor)),
                                    content: const Text(
                                      'Are you sure you want to end this shift now?',
                                      style: TextStyle(
                                          color: ColorConst.primaryColor),
                                    ),
                                    actions: [
                                      TextButton(
                                          style: const ButtonStyle(
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    ColorConst.primaryColor),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('No')),
                                      TextButton(
                                          style: const ButtonStyle(
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    ColorConst.backgroundColor),
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    ColorConst.primaryColor),
                                          ),
                                          onPressed: () async {
                                            if (!formkey.currentState!
                                                .validate()) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Fill up the required fields')));
                                            } else {
                                              double totaltoPay = (double.parse(
                                                          totalEarningscontroller
                                                              .text) +
                                                      double.parse(
                                                          refundController
                                                              .text) -
                                                      double.parse(
                                                          cashCollectedcontroller
                                                              .text)) +
                                                  ((rentModel!.shift) *
                                                      (rentModel!.rent));

                                              await FirebaseFirestore.instance
                                                  .collection('organisations')
                                                  .doc(currentUser!
                                                      .organisationId)
                                                  .collection('rents')
                                                  .doc(rentModel!.rentId)
                                                  .update({
                                                'end_time': Timestamp.now(),
                                                'total_trips': int.parse(
                                                    totalTripsController.text),
                                                'total_earnings': double.parse(
                                                    totalEarningscontroller
                                                        .text),
                                                'cash_collected': double.parse(
                                                    cashCollectedcontroller
                                                        .text),
                                                'refund': double.parse(
                                                    refundController.text),
                                                'total_to_pay': totaltoPay,
                                                'rent_status': 'completed',
                                              });
                                              await FirebaseFirestore.instance
                                                  .collection('organisations')
                                                  .doc(currentUser!
                                                      .organisationId)
                                                  .collection('vehicles')
                                                  .doc(rentModel!.vehicleId)
                                                  .update({
                                                'driver': '',
                                                'on_duty': false,
                                                'start_time': Timestamp.now(),
                                                'last_driven': Timestamp.now(),
                                                'selected_shift': 0,
                                                'total_trips':
                                                    FieldValue.increment(
                                                        int.parse(
                                                            totalTripsController
                                                                .text)),
                                              });
                                              await FirebaseFirestore.instance
                                                  .collection('organisations')
                                                  .doc(currentUser!
                                                      .organisationId)
                                                  .collection('drivers')
                                                  .doc(currentUser!.userId)
                                                  .update({
                                                'on_rent': '',
                                                'cash_collected': FieldValue
                                                    .increment(double.parse(
                                                        cashCollectedcontroller
                                                            .text)),
                                                'total_earnings': FieldValue
                                                    .increment(double.parse(
                                                        totalEarningscontroller
                                                            .text)),
                                                'refund': FieldValue.increment(
                                                    double.parse(
                                                        refundController.text)),
                                                'total_shifts':
                                                    FieldValue.increment(
                                                        rentModel!.shift),
                                                'vehicle_rent':
                                                    FieldValue.increment(
                                                        rentModel!.shift *
                                                            rentModel!.rent),
                                                'total_trips':
                                                    FieldValue.increment(
                                                        int.parse(
                                                            totalTripsController
                                                                .text)),
                                                'wallet': FieldValue.increment(
                                                    -totaltoPay),
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Shift completed successfully!')));
                                              Navigator.pop(context);
                                              await getDriverDetails();
                                            }
                                          },
                                          child: const Text('Yes')),
                                    ],
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Fill the required fields!')));
                              }
                            },
                            child: const Text("End shift"))
                      ],
                    ),
                  ))
                ],
              ),
            ),
          );
  }

  _logOutDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorConst.boxColor,
        title: const Text('Log out?',
            style: TextStyle(color: ColorConst.primaryColor)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: ColorConst.primaryColor)),
        actions: [
          TextButton(
              style: const ButtonStyle(
                foregroundColor:
                    WidgetStatePropertyAll(ColorConst.primaryColor),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('No')),
          TextButton(
              style: const ButtonStyle(
                foregroundColor:
                    WidgetStatePropertyAll(ColorConst.backgroundColor),
                backgroundColor:
                    WidgetStatePropertyAll(ColorConst.primaryColor),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLogged', false);
                prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoDialogRoute(
                      builder: (context) => const AuthPage(), context: context),
                  (route) => false,
                );
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }
}
