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
import 'package:zero/models/user_model.dart';
import 'package:zero/models/vehicle_model.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool isLoading = true;
  // DriverModel? currentDriver;
  RentModel? rentModel;
  TextEditingController searchController = TextEditingController();
  String searchkey = '';

  Future getDriverDetails() async {
    setState(() {
      isLoading = true;
    });
    // await FirebaseFirestore.instance
    //     .collection('organisations')
    //     .doc(currentUser!.organisationId)
    //     .collection('drivers')
    //     .doc(currentUser!.userId)
    //     .get()
    //     .then((value) {
    //   currentDriver =
    //       DriverModel.fromJson(value.data() as Map<String, dynamic>);
    // });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.userId)
        .get()
        .then((value) {
      currentUser = UserModel.fromJson(value.data() as Map<String, dynamic>);
    });
    log(currentUser!.toJson().toString());
    if (currentUser!.onRent!.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('organisations')
          .doc(currentUser!.organisationId)
          .collection('rents')
          .doc(currentUser!.onRent)
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
        .where('is_deleted', isEqualTo: false)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => VehicleModel.fromJson(e.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
                color: ColorConst.primaryColor,
              ),
            )
          : Scaffold(
              body: NestedScrollView(
                  physics: currentUser!.onRent!.isNotEmpty
                      ? const NeverScrollableScrollPhysics()
                      : const ScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) =>
                      [appBar(), if (currentUser!.onRent!.isEmpty) searchBar()],
                  body: currentUser!.onRent!.isNotEmpty
                      ? driverOnDuty()
                      : driverOffDuty())),
    );
  }

  Widget appBar() {
    return SliverAppBar(
      foregroundColor: ColorConst.textColor,
      toolbarHeight: h * 0.1,
      title: Text(currentUser!.onRent!.isNotEmpty
          ? 'You are on duty'
          : 'Select vehicle'),
      backgroundColor: ColorConst.boxColor,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: ColorConst.textColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.wallet, color: ColorConst.textColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget searchBar() {
    return SliverAppBar(
      leading: const SizedBox(),
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      toolbarHeight: h * 0.1,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.all(w * 0.03),
          child: TextFormField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchkey = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search vehicle',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(w * 0.05)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.05),
                borderSide:
                    BorderSide(color: ColorConst.primaryColor.withOpacity(0.3)),
              ),
              filled: true,
              fillColor: ColorConst.boxColor,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: ColorConst.textColor),
          ),
        ),
      ),
      pinned: true,
    );
  }

  Widget driverOffDuty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                        // shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          VehicleModel vehicle = snapshot.data![index];
                          return vehicle.vehicleNumber
                                  .toLowerCase()
                                  .contains(searchkey.toLowerCase())
                              ? Container(
                                  height: h * 0.2,
                                  padding: EdgeInsets.all(w * 0.03),
                                  margin: EdgeInsets.all(w * 0.03),
                                  decoration: BoxDecoration(
                                    color: ColorConst.boxColor,
                                    borderRadius:
                                        BorderRadius.circular(w * 0.03),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(vehicle.vehicleNumber,
                                          style: TextStyle(
                                              fontSize: w * 0.06,
                                              color: ColorConst.textColor,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Remaining trips : ${vehicle.targetTrips - vehicle.totalTrips}',
                                          style: const TextStyle(
                                              color: ColorConst.textColor,
                                              fontWeight: FontWeight.bold)),
                                      PopupMenuButton(
                                        color: ColorConst.boxColor,
                                        onSelected: (shiftValue) async {
                                          var getRents = await FirebaseFirestore
                                              .instance
                                              .collection('organisations')
                                              .doc(currentUser!.organisationId)
                                              .collection('rents')
                                              .get();
                                          String rentId =
                                              'rentid${getRents.size}';
                                          await FirebaseFirestore.instance
                                              .collection('organisations')
                                              .doc(currentUser!.organisationId)
                                              .collection('rents')
                                              .doc(rentId)
                                              .set(RentModel(
                                                      rentId: rentId,
                                                      driverId:
                                                          currentUser!.userId,
                                                      vehicleId:
                                                          vehicle.vehicleId,
                                                      vehicleNumber:
                                                          vehicle.vehicleNumber,
                                                      startTime:
                                                          Timestamp.now(),
                                                      rent: vehicle.rent,
                                                      shift:
                                                          int.parse(shiftValue),
                                                      totalTrips: 0,
                                                      totalEarnings: 0,
                                                      cashCollected: 0,
                                                      totaltoPay: 0,
                                                      refund: 0,
                                                      rentStatus: 'ongoing')
                                                  .toJson());
                                          await FirebaseFirestore.instance
                                              .collection('organisations')
                                              .doc(currentUser!.organisationId)
                                              .collection('vehicles')
                                              .doc(vehicle.vehicleId)
                                              .update({
                                            'driver': currentUser!.userId,
                                            'on_duty': true,
                                            'start_time': DateTime.now(),
                                            'selected_shift':
                                                int.parse(shiftValue)
                                          });
                                          // await FirebaseFirestore.instance
                                          //     .collection('organisations')
                                          //     .doc(currentUser!.organisationId)
                                          //     .collection('drivers')
                                          //     .doc(currentUser!.userId)
                                          //     .update({'on_rent': rentId});
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(currentUser!.userId)
                                              .update({'on_rent': rentId});
                                          await getDriverDetails();
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                              value: "1",
                                              child: Text(
                                                "12 hrs",
                                                style: TextStyle(
                                                    color:
                                                        ColorConst.textColor),
                                              )),
                                          const PopupMenuItem(
                                              value: "2",
                                              child: Text(
                                                "24 hrs",
                                                style: TextStyle(
                                                    color:
                                                        ColorConst.textColor),
                                              )),
                                        ],
                                        child: const ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        ColorConst
                                                            .primaryColor)),
                                            onPressed: null,
                                            child: Text(
                                              'Start duty',
                                              style: TextStyle(
                                                  color: ColorConst
                                                      .backgroundColor,
                                                  fontWeight: FontWeight.bold),
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
                              blurRadius: 4,
                              spreadRadius: 1)
                        ]),
                    child: Column(
                      children: [
                        Text(rentModel!.vehicleNumber,
                            style: TextStyle(
                                fontSize: w * 0.06,
                                color: ColorConst.textColor,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: h * 0.02),
                        Text(
                            'Started time : ${DateFormat.jm().format(rentModel!.startTime.toDate())}',
                            style: const TextStyle(
                                color: ColorConst.textColor,
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
                        if (Timestamp.now()
                                .toDate()
                                .difference(rentModel!.startTime.toDate())
                                .inHours <
                            2)
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
                                if (formkey.currentState!.validate()) {
                                  TextEditingController reasonController =
                                      TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: ColorConst.boxColor,
                                      title: const Text('Cancel shift?',
                                          style: TextStyle(
                                              color: ColorConst.textColor)),
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
                                              side: WidgetStatePropertyAll(
                                                  BorderSide(
                                                      color: ColorConst
                                                          .primaryColor)),
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
                                          color: ColorConst.textColor),
                                    ),
                                    actions: [
                                      TextButton(
                                          style: const ButtonStyle(
                                            side: WidgetStatePropertyAll(
                                                BorderSide(
                                                    color: ColorConst
                                                        .primaryColor)),
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
}
