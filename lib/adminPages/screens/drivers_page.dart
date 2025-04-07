import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/user_model.dart';
import 'package:zero/models/vehicle_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  bool isLoading = false;
  bool isDriversLoading = false;
  List<UserModel> driverModels = [];
  Future getDrivers() async {
    driverModels.clear();
    setState(() {
      isDriversLoading = true;
    });
    var drivers = await FirebaseFirestore.instance
        // .collection('organisations')
        // .doc(currentUser!.organisationId)
        // .collection('drivers')
        .collection('users')
        .where('organisation_id', isEqualTo: currentUser!.organisationId)
        .where('user_role', isEqualTo: 'Driver')
        .get();
    for (var driver in drivers.docs) {
      driverModels.add(UserModel.fromJson(driver.data()));
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
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                [appbar(), driverStats()],
            body: SingleChildScrollView(
              child: Column(
                children: [_buildDriverTab()],
              ),
            )));
  }

  Widget appbar() {
    return SliverAppBar(
      toolbarHeight: h * 0.1,
      title: const Text('Drivers',
          style: TextStyle(
              color: ColorConst.textColor, fontWeight: FontWeight.bold)),
      backgroundColor: ColorConst.boxColor,
      elevation: 2,
    );
  }

  Widget driverStats() {
    int onDutyDrivers =
        driverModels.where((element) => element.onRent!.isNotEmpty).length;
    int availableDrivers = driverModels.length - onDutyDrivers;
    return SliverAppBar(
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      toolbarHeight: h * 0.1,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.only(top: w * 0.05),
          child: Card(
            color: ColorConst.boxColor,
            margin:
                EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
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
                            'Total drivers',
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
                      Column(
                        children: [
                          IconButton(
                              onPressed: () => _showDriverForm(),
                              icon: const Icon(
                                Icons.add,
                                color: ColorConst.textColor,
                              )),
                          const Text(
                            'Add Driver',
                            style: TextStyle(color: ColorConst.textColor),
                          )
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverTab() {
    List<UserModel> drivers = driverModels;
    return isDriversLoading
        ? const SizedBox()
        : driverModels.isEmpty
            ? _buildEmptyState(
                'No Drivers added yet', Icons.directions_car_outlined)
            : ListView.builder(
                padding: const EdgeInsets.only(top: 0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final tripCompletion = drivers[index].totalTrips! /
                      (drivers[index].targetTrips! > 0
                          ? drivers[index].targetTrips!
                          : 1);
                  return Card(
                    color: ColorConst.boxColor,
                    margin: EdgeInsets.symmetric(
                        horizontal: w * 0.03, vertical: w * 0.03),
                    child: ListTile(
                        leading: Column(
                          children: [
                            Icon(Icons.circle,
                                size: w * 0.04,
                                color: drivers[index].onRent!.isNotEmpty
                                    ? ColorConst.successColor
                                    : ColorConst.errorColor),
                            SizedBox(
                              height: h * 0.01,
                            ),
                            Text(
                              drivers[index].onRent!.isNotEmpty
                                  ? 'on duty'
                                  : 'Idle',
                              style: TextStyle(
                                  color: ColorConst.textColor,
                                  fontSize: w * 0.04),
                            ),
                          ],
                        ),
                        title: Text(
                          drivers[index].userName,
                          style: const TextStyle(
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
                                  value:
                                      tripCompletion > 1 ? 1 : tripCompletion,
                                  minHeight: 15,
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
                                  '${drivers[index].totalTrips.toString()} / ${drivers[index].targetTrips.toString()} trips',
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
                              PopupMenuItem(
                                  onTap: () =>
                                      _showDriverForm(driver: drivers[index]),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: ColorConst.textColor),
                                  )),
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
                                                    color:
                                                        ColorConst.textColor),
                                              ),
                                              actions: [
                                                TextButton(
                                                    style: const ButtonStyle(
                                                      foregroundColor:
                                                          WidgetStatePropertyAll(
                                                              ColorConst
                                                                  .primaryColor),
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
                                                              ColorConst
                                                                  .primaryColor),
                                                    ),
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(drivers[index]
                                                              .userId)
                                                          .update({
                                                        'organisation_id': '',
                                                        'organisation_name': ''
                                                      });
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'organisations')
                                                          .doc(currentUser!
                                                              .organisationId)
                                                          .collection('drivers')
                                                          .doc(drivers[index]
                                                              .userId)
                                                          .update({
                                                        'is_removed': true
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Yes')),
                                              ],
                                            ));
                                  },
                                  child: const Text('Remove',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: ColorConst.textColor))),
                            ];
                          },
                        )),
                  );
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

  void _showDriverForm({UserModel? driver}) {
    final isEditing = driver != null;
    final nameController =
        TextEditingController(text: isEditing ? driver.userName : '');
    final phoneController = TextEditingController(
        text: isEditing ? driver.mobileNumber.substring(3) : '');
    final walletController =
        TextEditingController(text: isEditing ? driver.wallet.toString() : '');
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
                        hintText: 'Name',
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
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: ColorConst.textColor),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUnfocus,
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
                        hintText: 'Mobile number',
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
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: ColorConst.textColor),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUnfocus,
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
                      controller: walletController,
                      decoration: InputDecoration(
                        hintText: 'Advance amount',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(w * 0.05),
                          child: const Text('₹',
                              style: TextStyle(color: ColorConst.primaryColor)),
                        ),
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
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetTripsController,
                      decoration: InputDecoration(
                        hintText: 'Target trips',
                        prefixIcon: Padding(
                            padding: EdgeInsets.all(w * 0.05),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              color: ColorConst.primaryColor,
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
                                          .doc(driver.userId)
                                          .update({
                                        'user_name': nameController.text.trim(),
                                        'mobile_number':
                                            '+91${phoneController.text}',
                                        'wallet':
                                            double.parse(walletController.text),
                                        'target_trips': int.parse(
                                            targetTripsController.text)
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Details updated successfully!')));
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
                                            'status': 'ACTIVE',
                                            'target_trips': int.parse(
                                                targetTripsController.text),
                                            'wallet': double.parse(
                                                walletController.text)
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('organisations')
                                              .doc(currentUser!.organisationId)
                                              .collection('drivers')
                                              .doc(data.first['user_id'])
                                              .set({
                                            'organisation_id':
                                                currentUser!.organisationId,
                                            'user_id': data.first['user_id'],
                                            'joined_on': DateTime.now(),
                                            'is_removed': false
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Driver registered successfully!')));
                                          await getDrivers();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'User is already working in other Organisation!')));
                                        }
                                        setState(() {
                                          isLoading = false;
                                        });
                                      } else {
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
                                                    wallet: 0)
                                                .toJson());
                                        await FirebaseFirestore.instance
                                            .collection('organisations')
                                            .doc(currentUser!.organisationId)
                                            .collection('drivers')
                                            .doc(userId)
                                            .set({
                                          'organisation_id':
                                              currentUser!.organisationId,
                                          'user_id': userId,
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Driver registered successfully!')));
                                        setState(() {
                                          isLoading = false;
                                        });
                                        await getDrivers();
                                        Navigator.pop(context);
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Enter required details!')));
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
