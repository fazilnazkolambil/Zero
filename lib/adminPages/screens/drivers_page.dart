import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zero/adminPages/screens/admin_notifications.dart';
import 'package:zero/adminPages/screens/driver_details.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/driver_model.dart';
import 'package:zero/models/user_model.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  bool isLoading = false;
  bool isDriversLoading = false;
  List<DriverModel> driverModels = [];
  Future getDrivers() async {
    driverModels.clear();
    setState(() {
      isDriversLoading = true;
    });
    var drivers = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('drivers')
        .where('is_deleted', isEqualTo: false)
        .get();
    for (var driver in drivers.docs) {
      driverModels.add(DriverModel.fromJson(driver.data()));
    }
    setState(() {
      isDriversLoading = false;
    });
  }

  @override
  void initState() {
    getDrivers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  [appbar(), driverStats()],
              body: SingleChildScrollView(
                child: Column(
                  children: [_buildDriverTab()],
                ),
              ))),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      toolbarHeight: h * 0.1,
      title: const Text('Drivers',
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

  Widget driverStats() {
    int onDutyDrivers =
        driverModels.where((element) => element.onRent.isNotEmpty).length;
    int availableDrivers = driverModels.length - onDutyDrivers;
    return SliverAppBar(
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      toolbarHeight: h * 0.1,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Card(
          color: ColorConst.boxColor,
          child: isDriversLoading
              ? const Center(
                  child: CupertinoActivityIndicator(
                  color: ColorConst.primaryColor,
                ))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          driverModels.length.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor),
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
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor),
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
                        onPressed: () => _showDriverForm(),
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

  Widget _buildDriverTab() {
    List<DriverModel> drivers = driverModels;
    return isDriversLoading
        ? const SizedBox()
        : driverModels.isEmpty
            ? _buildEmptyState(
                'No Drivers added yet', Icons.directions_car_outlined)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  int targetTrips =
                      drivers[index].targetTrips * drivers[index].weeklyShifts;
                  final tripCompletion = drivers[index].weeklyTrips /
                      (targetTrips > 0 ? targetTrips : 1);
                  return Card(
                      color: ColorConst.boxColor,
                      margin: EdgeInsets.symmetric(
                          horizontal: w * 0.03, vertical: w * 0.03),
                      child: ListTile(
                          onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    DriverDetails(driverData: drivers[index]),
                              )),
                          contentPadding: EdgeInsets.all(w * 0.03),
                          minLeadingWidth: w * 0.15,
                          leading: drivers[index].isBlocked.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.03),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.circle,
                                          size: w * 0.04,
                                          color:
                                              drivers[index].onRent.isNotEmpty
                                                  ? ColorConst.successColor
                                                  : ColorConst.errorColor),
                                      SizedBox(
                                        height: h * 0.01,
                                      ),
                                      Text(
                                        drivers[index].onRent.isNotEmpty
                                            ? 'on duty'
                                            : 'Idle',
                                        style: TextStyle(
                                            color: ColorConst.textColor,
                                            fontSize: w * 0.04),
                                      ),
                                    ],
                                  ),
                                )
                              : const Icon(
                                  Icons.block,
                                  color: ColorConst.errorColor,
                                ),
                          title: Text(
                            drivers[index].driverName,
                            style: const TextStyle(
                                color: ColorConst.textColor,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: drivers[index].isBlocked.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(top: h * 0.01),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: tripCompletion > 1
                                              ? 1
                                              : tripCompletion,
                                          minHeight: 5,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                                          '${drivers[index].weeklyTrips.toString()} / ${targetTrips.toString()} trips',
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
                          trailing: PopupMenuButton(
                            color: ColorConst.boxColor,
                            child: const Icon(
                              Icons.more_vert_rounded,
                              color: ColorConst.textColor,
                            ),
                            itemBuilder: (context) {
                              return [
                                if (drivers[index].isBlocked.isEmpty)
                                  PopupMenuItem(
                                      onTap: () => _showDriverForm(
                                          driver: drivers[index]),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: ColorConst.textColor),
                                      )),
                                PopupMenuItem(
                                    onTap: () async {
                                      TextEditingController reasonController =
                                          TextEditingController(
                                              text: drivers[index].isBlocked);
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                backgroundColor:
                                                    ColorConst.boxColor,
                                                title: Text(
                                                    drivers[index]
                                                            .isBlocked
                                                            .isEmpty
                                                        ? 'Block driver?'
                                                        : 'Ublock driver?',
                                                    style: const TextStyle(
                                                        color: ColorConst
                                                            .textColor)),
                                                content: drivers[index]
                                                        .isBlocked
                                                        .isEmpty
                                                    ? TextField(
                                                        controller:
                                                            reasonController,
                                                        style: const TextStyle(
                                                            color: ColorConst
                                                                .textColor),
                                                        decoration:
                                                            const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              ColorConst.primaryColor),
                                                                ),
                                                                filled: true,
                                                                fillColor:
                                                                    ColorConst
                                                                        .boxColor,
                                                                labelStyle: TextStyle(
                                                                    color: ColorConst
                                                                        .textColor),
                                                                labelText:
                                                                    'Reason'),
                                                      )
                                                    : Text(
                                                        'Reason : ${drivers[index].isBlocked}',
                                                        style: const TextStyle(
                                                            color: ColorConst
                                                                .textColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                                ColorConst
                                                                    .primaryColor),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text('No')),
                                                  TextButton(
                                                      style: const ButtonStyle(
                                                        foregroundColor:
                                                            WidgetStatePropertyAll(
                                                                ColorConst
                                                                    .backgroundColor),
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                ColorConst
                                                                    .primaryColor),
                                                      ),
                                                      onPressed: () async {
                                                        if (reasonController
                                                            .text.isNotEmpty) {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(
                                                                  drivers[index]
                                                                      .driverId)
                                                              .update({
                                                            'organisation_id':
                                                                '',
                                                            'organisation_name':
                                                                '',
                                                            'status': drivers[
                                                                        index]
                                                                    .isBlocked
                                                                    .isEmpty
                                                                ? 'BLOCKED'
                                                                : 'ACTIVE',
                                                            'is_blocked': drivers[
                                                                        index]
                                                                    .isBlocked
                                                                    .isEmpty
                                                                ? reasonController
                                                                    .text
                                                                : ''
                                                          });
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'organisations')
                                                              .doc(currentUser!
                                                                  .organisationId)
                                                              .collection(
                                                                  'drivers')
                                                              .doc(
                                                                  drivers[index]
                                                                      .driverId)
                                                              .update({
                                                            'is_blocked': drivers[
                                                                        index]
                                                                    .isBlocked
                                                                    .isEmpty
                                                                ? reasonController
                                                                    .text
                                                                : ''
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg: drivers[
                                                                          index]
                                                                      .isBlocked
                                                                      .isEmpty
                                                                  ? 'Driver blocked!'
                                                                  : 'Driver unblocked');
                                                          Navigator.pop(
                                                              context);
                                                          getDrivers();
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'Enter the reason!',
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT);
                                                        }
                                                      },
                                                      child: const Text('Yes')),
                                                ],
                                              ));
                                    },
                                    child: Text(
                                        drivers[index].isBlocked.isEmpty
                                            ? 'Block'
                                            : 'Unblock',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                drivers[index].isBlocked.isEmpty
                                                    ? ColorConst.textColor
                                                    : ColorConst.errorColor))),
                                if (drivers[index].isBlocked.isEmpty)
                                  PopupMenuItem(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  backgroundColor:
                                                      ColorConst.boxColor,
                                                  title: const Text(
                                                      'Remove driver?',
                                                      style: TextStyle(
                                                          color: ColorConst
                                                              .textColor)),
                                                  content: const Text(
                                                    'Are you sure you want to remove this driver?',
                                                    style: TextStyle(
                                                        color: ColorConst
                                                            .textColor),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        style:
                                                            const ButtonStyle(
                                                          foregroundColor:
                                                              WidgetStatePropertyAll(
                                                                  ColorConst
                                                                      .primaryColor),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child:
                                                            const Text('No')),
                                                    TextButton(
                                                        style:
                                                            const ButtonStyle(
                                                          foregroundColor:
                                                              WidgetStatePropertyAll(
                                                                  ColorConst
                                                                      .backgroundColor),
                                                          backgroundColor:
                                                              WidgetStatePropertyAll(
                                                                  ColorConst
                                                                      .primaryColor),
                                                        ),
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(
                                                                  drivers[index]
                                                                      .driverId)
                                                              .update({
                                                            'organisation_id':
                                                                '',
                                                            'organisation_name':
                                                                '',
                                                            'status':
                                                                'LEFT_COMPANY'
                                                          });
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'organisations')
                                                              .doc(currentUser!
                                                                  .organisationId)
                                                              .collection(
                                                                  'drivers')
                                                              .doc(
                                                                  drivers[index]
                                                                      .driverId)
                                                              .update({
                                                            'is_deleted': true
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'Driver have been removed!',
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .TOP_LEFT);
                                                          Navigator.pop(
                                                              context);
                                                          getDrivers();
                                                        },
                                                        child:
                                                            const Text('Yes')),
                                                  ],
                                                ));
                                      },
                                      child: const Text('Remove',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: ColorConst.textColor))),
                              ];
                            },
                          )));
                });
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
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

  void _showDriverForm({DriverModel? driver}) {
    final isEditing = driver != null;
    final nameController =
        TextEditingController(text: isEditing ? driver.driverName : '');
    final phoneController = TextEditingController(
        text: isEditing ? driver.mobileNumber.substring(3) : '');
    final targetTripsController = TextEditingController(
        text: isEditing ? driver.targetTrips.toString() : '');
    final formkey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorConst.boxColor,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Driver' : 'Add New Driver',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(w * 0.05),
                          child: const Icon(
                            Icons.person_2_outlined,
                            color: ColorConst.primaryColor,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorConst.primaryColor),
                        ),
                        filled: true,
                        fillColor: ColorConst.boxColor,
                      ),
                      style: const TextStyle(color: ColorConst.textColor),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter driver's name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Mobile number',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(w * 0.05),
                          child: const Text('+91',
                              style: TextStyle(color: ColorConst.primaryColor)),
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorConst.primaryColor),
                        ),
                        filled: true,
                        fillColor: ColorConst.boxColor,
                      ),
                      style: const TextStyle(color: ColorConst.textColor),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 10) {
                          return "Please enter driver's Mobile number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetTripsController,
                      maxLength: 2,
                      decoration: InputDecoration(
                        hintText: 'Target trips per shift',
                        labelText: 'Target trips',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                            padding: EdgeInsets.all(w * 0.05),
                            child: const Icon(
                              Icons.info_outline,
                              color: ColorConst.primaryColor,
                            )),
                        suffixText: '/shift',
                        suffixStyle: const TextStyle(color: Colors.grey),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorConst.primaryColor),
                        ),
                        filled: true,
                        fillColor: ColorConst.boxColor,
                      ),
                      style: const TextStyle(color: ColorConst.textColor),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: ColorConst.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        isLoading
                            ? const Center(
                                child: CupertinoActivityIndicator(
                                  color: ColorConst.primaryColor,
                                ),
                              )
                            : ElevatedButton(
                                style: const ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        ColorConst.primaryColor)),
                                onPressed: () async {
                                  if (formkey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (isEditing) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(driver.driverId)
                                          .update({
                                        'user_name': nameController.text.trim(),
                                        'mobile_number':
                                            '+91${phoneController.text}'
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('organisations')
                                          .doc(currentUser!.organisationId)
                                          .collection('drivers')
                                          .doc(driver.driverId)
                                          .update({
                                        'driver_name':
                                            nameController.text.trim(),
                                        'mobile_number':
                                            '+91${phoneController.text}',
                                        'target_trips': int.parse(
                                            targetTripsController.text)
                                      });
                                      Fluttertoast.showToast(
                                        msg: "Details updated successfully!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                      await getDrivers();
                                      Navigator.pop(context);
                                    } else {
                                      var users = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .get();
                                      var data = users.docs.where((element) =>
                                          element['mobile_number'] ==
                                          '+91${phoneController.text}');
                                      if (data.isNotEmpty) {
                                        print('MOBILE NUMBER ALREADY EXIST');
                                        if (data
                                            .first['organisation_id'].isEmpty) {
                                          //TODO: Check this with status
                                          print('ORGANISATION ID IS EMPTY');
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(data.first['user_id'])
                                              .update({
                                            'organisation_id':
                                                currentUser!.organisationId,
                                            'user_role': 'Driver',
                                            'user_name':
                                                nameController.text.trim(),
                                            'status': 'JOINED',
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('organisations')
                                              .doc(currentUser!.organisationId)
                                              .collection('drivers')
                                              .doc(data.first['user_id'])
                                              .set(DriverModel(
                                                      isDeleted: false,
                                                      totalTrips: 0,
                                                      totalEarnings: 0,
                                                      cashCollected: 0,
                                                      refund: 0,
                                                      wallet: 0,
                                                      onRent: '',
                                                      driverName: nameController
                                                          .text
                                                          .trim(),
                                                      mobileNumber:
                                                          '+91${phoneController.text}',
                                                      status: 'ACTIVE',
                                                      driverId:
                                                          data.first['user_id'],
                                                      isBlocked: '',
                                                      organisationId:
                                                          currentUser!
                                                              .organisationId,
                                                      targetTrips: int.parse(
                                                          targetTripsController
                                                              .text),
                                                      totalShifts: 0,
                                                      organisationName:
                                                          currentUser!
                                                              .organisationName,
                                                      weeklyTrips: 0,
                                                      weeklyShifts: 0,
                                                      fuelExpense: 0,
                                                      vehicleRent: 0,
                                                      driverAddedOn:
                                                          DateTime.now()
                                                              .toString())
                                                  .toJson());
                                          Fluttertoast.showToast(
                                            msg:
                                                "Driver registered successfully!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                          );
                                          Navigator.pop(context);
                                          await getDrivers();
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                "User is already registered in other organization!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                          );
                                        }
                                        setState(() {
                                          isLoading = false;
                                        });
                                      } else {
                                        print('MOBILE NUMBER NOT EXIST');
                                        String userId = 'zer0user${users.size}';
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .set(UserModel(
                                                    mobileNumber:
                                                        '+91${phoneController.text}',
                                                    organisationId: currentUser!
                                                        .organisationId,
                                                    organisationName:
                                                        currentUser!
                                                            .organisationName,
                                                    userCreatedOn:
                                                        DateTime.now()
                                                            .toString(),
                                                    userId: userId,
                                                    userRole: 'Driver',
                                                    userName: nameController
                                                        .text
                                                        .trim(),
                                                    isDeleted: false,
                                                    status: 'JOINED',
                                                    isBlocked: '')
                                                .toJson());
                                        await FirebaseFirestore.instance
                                            .collection('organisations')
                                            .doc(currentUser!.organisationId)
                                            .collection('drivers')
                                            .doc(userId)
                                            .set(DriverModel(
                                                    mobileNumber:
                                                        '+91${phoneController.text}',
                                                    organisationId: currentUser!
                                                        .organisationId,
                                                    organisationName:
                                                        currentUser!
                                                            .organisationName,
                                                    driverAddedOn:
                                                        DateTime.now()
                                                            .toString(),
                                                    driverId: userId,
                                                    driverName: nameController
                                                        .text
                                                        .trim(),
                                                    isBlocked: '',
                                                    isDeleted: false,
                                                    status: 'ACTIVE',
                                                    onRent: '',
                                                    targetTrips:
                                                        targetTripsController
                                                                .text.isEmpty
                                                            ? 0
                                                            : int.parse(
                                                                targetTripsController
                                                                    .text),
                                                    totalEarnings: 0,
                                                    totalShifts: 0,
                                                    totalTrips: 0,
                                                    wallet: 0,
                                                    cashCollected: 0,
                                                    refund: 0,
                                                    fuelExpense: 0,
                                                    vehicleRent: 0,
                                                    weeklyTrips: 0,
                                                    weeklyShifts: 0)
                                                .toJson());
                                        Fluttertoast.showToast(
                                          msg:
                                              "Driver registered successfully!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.TOP,
                                        );

                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        await getDrivers();
                                      }
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Enter required details!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                    );
                                  }
                                },
                                child: Text(
                                  isEditing ? 'Update' : 'Add Driver',
                                  style: const TextStyle(
                                      color: ColorConst.backgroundColor),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
