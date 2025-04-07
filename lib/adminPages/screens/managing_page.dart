// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:zero/auth/auth_page.dart';
// import 'package:zero/core/const_page.dart';
// import 'package:zero/core/global_variables.dart';
// import 'package:zero/models/user_model.dart';
// import 'package:zero/models/vehicle_model.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class ManagingPage extends StatefulWidget {
//   const ManagingPage({super.key});

//   @override
//   State<ManagingPage> createState() => _ManagingPageState();
// }

// class _ManagingPageState extends State<ManagingPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isLoading = false;
//   // List<DriverModel> drivers = [];
//   // List<VehicleModel> vehicles = [];
//   Stream<List<UserModel>> getUsers() {
//     return FirebaseFirestore.instance
//         .collection('users')
//         .where('organisation_id', isEqualTo: currentUser!.organisationId)
//         .snapshots()
//         .map((event) =>
//             event.docs.map((e) => UserModel.fromJson(e.data())).toList());
//   }

//   Stream<List<VehicleModel>> getVehicles() {
//     return FirebaseFirestore.instance
//         .collection('organisations')
//         .doc(currentUser!.organisationId)
//         .collection('vehicles')
//         .snapshots()
//         .map((event) =>
//             event.docs.map((e) => VehicleModel.fromJson(e.data())).toList());
//   }

//   @override
//   void initState() {
//     // getDrivers();
//     // getVehicles();
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           IconButton(
//               onPressed: () {
//                 if (_tabController.index == 0) {
//                   _showDriverForm();
//                 } else {
//                   _showVehicleForm();
//                 }
//               },
//               icon: Icon(
//                 Icons.add,
//                 size: w * 0.08,
//               )),
//           IconButton(
//               onPressed: () {
//                 _logOutDialog();
//               },
//               icon: Icon(
//                 Icons.logout_outlined,
//                 size: w * 0.08,
//               ))
//         ],
//         backgroundColor: ColorConst.primaryColor,
//         title: const Text(
//           'Management',
//           style: TextStyle(color: ColorConst.backgroundColor),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicator: const UnderlineTabIndicator(
//               borderSide: BorderSide(color: ColorConst.backgroundColor)),
//           labelStyle: const TextStyle(color: ColorConst.backgroundColor),
//           tabs: const [
//             Tab(icon: Icon(Icons.person), text: 'Drivers'),
//             Tab(icon: Icon(Icons.directions_car), text: 'Vehicles'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildDriversTab(),
//           _buildVehiclesTab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDriversTab() {
//     return StreamBuilder(
//       stream: getUsers(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CupertinoActivityIndicator(
//               color: ColorConst.primaryColor,
//             ),
//           );
//         }
//         List<UserModel> drivers = snapshot.data!;
//         return drivers.isEmpty
//             ? _buildEmptyState('No drivers added yet', Icons.person_outline)
//             : ListView.builder(
//                 itemCount: drivers.length,
//                 itemBuilder: (context, index) => Container(
//                     margin: EdgeInsets.all(w * 0.05),
//                     decoration: BoxDecoration(
//                         color: ColorConst.backgroundColor,
//                         borderRadius: BorderRadius.circular(w * 0.03),
//                         boxShadow: [
//                           BoxShadow(
//                               color: ColorConst.primaryColor.withOpacity(0.5),
//                               blurRadius: 10,
//                               spreadRadius: 5)
//                         ]),
//                     child: ListTile(
//                         leading: Text(
//                           '${index + 1}.',
//                           style: TextStyle(
//                               color: ColorConst.primaryColor,
//                               fontSize: w * 0.04),
//                         ),
//                         title: Text(
//                           'Driver name : ${drivers[index].userName}',
//                           style:
//                               const TextStyle(color: ColorConst.primaryColor),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Text(
//                             //   'Total trip : ${drivers[index].totalTrips}',
//                             //   style: const TextStyle(color: ColorConst.primaryColor),
//                             // ),
//                             Text(
//                               'Remaining trips : ${(drivers[index].targetTrips!) - (drivers[index].totalTrips!)}',
//                               style: const TextStyle(
//                                   color: ColorConst.primaryColor),
//                             ),
//                             Text(
//                               'Wallet : ${drivers[index].wallet}',
//                               style: const TextStyle(
//                                   color: ColorConst.primaryColor),
//                             ),
//                           ],
//                         ),
//                         trailing: PopupMenuButton(
//                           color: ColorConst.boxColor,
//                           child: const Icon(
//                             Icons.more_vert_rounded,
//                             color: ColorConst.primaryColor,
//                           ),
//                           itemBuilder: (context) {
//                             return [
//                               PopupMenuItem(
//                                   onTap: () =>
//                                       _showDriverForm(driver: drivers[index]),
//                                   child: const Text(
//                                     'Edit',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         color: ColorConst.primaryColor),
//                                   )),
//                               PopupMenuItem(
//                                   onTap: () async {
//                                     TextEditingController
//                                         blockReasonController =
//                                         TextEditingController();
//                                     showDialog(
//                                         context: context,
//                                         builder: (context) => AlertDialog(
//                                               backgroundColor:
//                                                   ColorConst.boxColor,
//                                               title: Text(
//                                                   drivers[index].isBlocked == ''
//                                                       ? 'Block driver?'
//                                                       : 'Unblock driver?',
//                                                   style: const TextStyle(
//                                                       color: ColorConst
//                                                           .primaryColor)),
//                                               content: drivers[index]
//                                                           .isBlocked ==
//                                                       ''
//                                                   ? TextField(
//                                                       controller:
//                                                           blockReasonController,
//                                                       style: const TextStyle(
//                                                           color: ColorConst
//                                                               .textColor),
//                                                       decoration:
//                                                           const InputDecoration(
//                                                               border:
//                                                                   OutlineInputBorder(),
//                                                               focusedBorder:
//                                                                   OutlineInputBorder(
//                                                                 borderSide: BorderSide(
//                                                                     color: ColorConst
//                                                                         .primaryColor),
//                                                               ),
//                                                               filled: true,
//                                                               fillColor:
//                                                                   ColorConst
//                                                                       .boxColor,
//                                                               labelStyle: TextStyle(
//                                                                   color: ColorConst
//                                                                       .textColor),
//                                                               labelText:
//                                                                   'Reason'),
//                                                     )
//                                                   : Text(
//                                                       'Reason: ${drivers[index].isBlocked}',
//                                                       style: const TextStyle(
//                                                           color: ColorConst
//                                                               .primaryColor)),
//                                               actions: [
//                                                 TextButton(
//                                                     style: const ButtonStyle(
//                                                       foregroundColor:
//                                                           WidgetStatePropertyAll(
//                                                               ColorConst
//                                                                   .primaryColor),
//                                                     ),
//                                                     onPressed: () =>
//                                                         Navigator.pop(context),
//                                                     child: const Text('No')),
//                                                 TextButton(
//                                                     style: const ButtonStyle(
//                                                       foregroundColor:
//                                                           WidgetStatePropertyAll(
//                                                               ColorConst
//                                                                   .backgroundColor),
//                                                       backgroundColor:
//                                                           WidgetStatePropertyAll(
//                                                               ColorConst
//                                                                   .primaryColor),
//                                                     ),
//                                                     onPressed: () async {
//                                                       if (blockReasonController
//                                                           .text.isNotEmpty) {
//                                                         await FirebaseFirestore
//                                                             .instance
//                                                             .collection('users')
//                                                             .doc(drivers[index]
//                                                                 .userId)
//                                                             .update({
//                                                           'is_blocked': drivers[
//                                                                           index]
//                                                                       .isBlocked ==
//                                                                   ''
//                                                               ? blockReasonController
//                                                                   .text
//                                                               : ''
//                                                         });
//                                                         Navigator.pop(context);
//                                                       } else {
//                                                         ScaffoldMessenger.of(
//                                                                 context)
//                                                             .showSnackBar(
//                                                                 const SnackBar(
//                                                                     content: Text(
//                                                                         'Enter a reason')));
//                                                       }
//                                                     },
//                                                     child: const Text('Yes')),
//                                               ],
//                                             ));
//                                   },
//                                   child: Text(
//                                       drivers[index].isBlocked == ''
//                                           ? 'Block'
//                                           : 'Unblock',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           color: ColorConst.primaryColor))),
//                               PopupMenuItem(
//                                   onTap: () async {
//                                     showDialog(
//                                         context: context,
//                                         builder: (context) => AlertDialog(
//                                               backgroundColor:
//                                                   ColorConst.boxColor,
//                                               title: Text(
//                                                   drivers[index].isDeleted
//                                                       ? 'Recover driver?'
//                                                       : 'Delete driver?',
//                                                   style: const TextStyle(
//                                                       color: ColorConst
//                                                           .primaryColor)),
//                                               content: Text(
//                                                 drivers[index].isDeleted
//                                                     ? 'Are you sure you want to recover this driver?'
//                                                     : 'Are you sure you want to delete this driver?',
//                                                 style: const TextStyle(
//                                                     color: ColorConst
//                                                         .primaryColor),
//                                               ),
//                                               actions: [
//                                                 TextButton(
//                                                     style: const ButtonStyle(
//                                                       foregroundColor:
//                                                           WidgetStatePropertyAll(
//                                                               ColorConst
//                                                                   .primaryColor),
//                                                     ),
//                                                     onPressed: () =>
//                                                         Navigator.pop(context),
//                                                     child: const Text('No')),
//                                                 TextButton(
//                                                     style: const ButtonStyle(
//                                                       foregroundColor:
//                                                           WidgetStatePropertyAll(
//                                                               ColorConst
//                                                                   .backgroundColor),
//                                                       backgroundColor:
//                                                           WidgetStatePropertyAll(
//                                                               ColorConst
//                                                                   .primaryColor),
//                                                     ),
//                                                     onPressed: () async {
//                                                       await FirebaseFirestore
//                                                           .instance
//                                                           .collection('users')
//                                                           .doc(drivers[index]
//                                                               .userId)
//                                                           .update({
//                                                         'is_deleted':
//                                                             drivers[index]
//                                                                     .isDeleted
//                                                                 ? false
//                                                                 : true
//                                                       });
//                                                       Navigator.pop(context);
//                                                     },
//                                                     child: const Text('Yes')),
//                                               ],
//                                             ));
//                                   },
//                                   child: Text(
//                                       drivers[index].isDeleted
//                                           ? 'Recover'
//                                           : 'Delete',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           color: ColorConst.primaryColor))),
//                             ];
//                           },
//                         ))),
//               );
//       },
//     );
//   }

//   Widget _buildVehiclesTab() {
//     return StreamBuilder(
//         stream: getVehicles(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(
//               child: CupertinoActivityIndicator(
//                 color: ColorConst.primaryColor,
//               ),
//             );
//           }
//           List<VehicleModel> vehicles = snapshot.data!;
//           return vehicles.isEmpty
//               ? _buildEmptyState(
//                   'No vehicles added yet', Icons.directions_car_outlined)
//               : ListView.builder(
//                   itemCount: vehicles.length,
//                   itemBuilder: (context, index) => Container(
//                       margin: EdgeInsets.all(w * 0.05),
//                       decoration: BoxDecoration(
//                           color: ColorConst.backgroundColor,
//                           borderRadius: BorderRadius.circular(w * 0.03),
//                           boxShadow: [
//                             BoxShadow(
//                                 color: ColorConst.primaryColor.withOpacity(0.5),
//                                 blurRadius: 10,
//                                 spreadRadius: 5)
//                           ]),
//                       child: ListTile(
//                           leading: Text(
//                             '${index + 1}.',
//                             style: TextStyle(
//                                 color: ColorConst.primaryColor,
//                                 fontSize: w * 0.04),
//                           ),
//                           title: Text(
//                             'Vehicle : ${vehicles[index].vehicleNumber}',
//                             style:
//                                 const TextStyle(color: ColorConst.primaryColor),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Remaining trips : ${vehicles[index].targetTrips - vehicles[index].totalTrips}',
//                                 style: const TextStyle(
//                                     color: ColorConst.primaryColor),
//                               ),
//                               Text(
//                                 'Last online : ${timeago.format(vehicles[index].lastDriven.toDate())}',
//                                 style: const TextStyle(
//                                     color: ColorConst.primaryColor),
//                               ),
//                               Text(
//                                 'Status : ${vehicles[index].status}',
//                                 style:
//                                     TextStyle(color: ColorConst.primaryColor),
//                               ),
//                             ],
//                           ),
//                           trailing: PopupMenuButton(
//                             color: ColorConst.boxColor,
//                             child: const Icon(
//                               Icons.more_vert_rounded,
//                               color: ColorConst.primaryColor,
//                             ),
//                             itemBuilder: (context) {
//                               return [
//                                 PopupMenuItem(
//                                     onTap: () => _showVehicleForm(
//                                         vehicle: vehicles[index]),
//                                     child: const Text(
//                                       'Edit',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           color: ColorConst.primaryColor),
//                                     )),
//                                 PopupMenuItem(
//                                     onTap: () async {
//                                       showDialog(
//                                           context: context,
//                                           builder: (context) => AlertDialog(
//                                                 backgroundColor:
//                                                     ColorConst.boxColor,
//                                                 title: Text(
//                                                     vehicles[index].isDeleted
//                                                         ? 'Recover driver?'
//                                                         : 'Delete driver?',
//                                                     style: const TextStyle(
//                                                         color: ColorConst
//                                                             .primaryColor)),
//                                                 content: Text(
//                                                   vehicles[index].isDeleted
//                                                       ? 'Are you sure you want to recover this driver?'
//                                                       : 'Are you sure you want to delete this driver?',
//                                                   style: const TextStyle(
//                                                       color: ColorConst
//                                                           .primaryColor),
//                                                 ),
//                                                 actions: [
//                                                   TextButton(
//                                                       style: const ButtonStyle(
//                                                         foregroundColor:
//                                                             WidgetStatePropertyAll(
//                                                                 ColorConst
//                                                                     .primaryColor),
//                                                       ),
//                                                       onPressed: () =>
//                                                           Navigator.pop(
//                                                               context),
//                                                       child: const Text('No')),
//                                                   TextButton(
//                                                       style: const ButtonStyle(
//                                                         foregroundColor:
//                                                             WidgetStatePropertyAll(
//                                                                 ColorConst
//                                                                     .backgroundColor),
//                                                         backgroundColor:
//                                                             WidgetStatePropertyAll(
//                                                                 ColorConst
//                                                                     .primaryColor),
//                                                       ),
//                                                       onPressed: () async {
//                                                         await FirebaseFirestore
//                                                             .instance
//                                                             .collection(
//                                                                 'organisations')
//                                                             .doc(currentUser!
//                                                                 .organisationId)
//                                                             .collection(
//                                                                 'drivers')
//                                                             .doc(vehicles[index]
//                                                                 .vehicleId)
//                                                             .update({
//                                                           'is_deleted':
//                                                               vehicles[index]
//                                                                       .isDeleted
//                                                                   ? false
//                                                                   : true
//                                                         });
//                                                         Navigator.pop(context);
//                                                       },
//                                                       child: const Text('Yes')),
//                                                 ],
//                                               ));
//                                     },
//                                     child: Text(
//                                         vehicles[index].isDeleted
//                                             ? 'Recover'
//                                             : 'Delete',
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: ColorConst.primaryColor))),
//                               ];
//                             },
//                           ))));
//         });
//   }

//   Widget _buildEmptyState(String message, IconData icon) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 80, color: Colors.grey),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: const TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Tap the + button to add new',
//             style: TextStyle(color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDriverForm({UserModel? driver}) {
//     final isEditing = driver != null;
//     final nameController =
//         TextEditingController(text: isEditing ? driver.userName : '');
//     final phoneController = TextEditingController(
//         text: isEditing ? driver.mobileNumber.substring(3) : '');
//     final walletController =
//         TextEditingController(text: isEditing ? driver.wallet.toString() : '');
//     final targetTripsController = TextEditingController(
//         text: isEditing ? driver.targetTrips.toString() : '');
//     final formkey = GlobalKey<FormState>();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: ColorConst.boxColor,
//       isDismissible: false,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 top: 16,
//                 left: 16,
//                 right: 16,
//               ),
//               child: Form(
//                 key: formkey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       isEditing ? 'Edit Driver' : 'Add New Driver',
//                       style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: ColorConst.primaryColor),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         hintText: 'Name',
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.all(w * 0.05),
//                           child: const Icon(
//                             Icons.person_2_outlined,
//                             color: ColorConst.primaryColor,
//                           ),
//                         ),
//                         border: const OutlineInputBorder(),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: ColorConst.primaryColor),
//                         ),
//                         filled: true,
//                         fillColor: ColorConst.boxColor,
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       style: const TextStyle(color: ColorConst.textColor),
//                       keyboardType: TextInputType.name,
//                       textCapitalization: TextCapitalization.words,
//                       autovalidateMode: AutovalidateMode.onUnfocus,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return "Please enter driver's name";
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: phoneController,
//                       maxLength: 10,
//                       decoration: InputDecoration(
//                         counterText: '',
//                         hintText: 'Mobile number',
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.all(w * 0.05),
//                           child: const Text('+91',
//                               style: TextStyle(color: ColorConst.primaryColor)),
//                         ),
//                         border: const OutlineInputBorder(),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: ColorConst.primaryColor),
//                         ),
//                         filled: true,
//                         fillColor: ColorConst.boxColor,
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       style: const TextStyle(color: ColorConst.textColor),
//                       keyboardType: TextInputType.number,
//                       autovalidateMode: AutovalidateMode.onUnfocus,
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                       validator: (value) {
//                         if (value == null ||
//                             value.isEmpty ||
//                             value.length < 10) {
//                           return "Please enter driver's Mobile number";
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: walletController,
//                       decoration: InputDecoration(
//                         hintText: 'Advance amount',
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.all(w * 0.05),
//                           child: const Text('₹',
//                               style: TextStyle(color: ColorConst.primaryColor)),
//                         ),
//                         border: const OutlineInputBorder(),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: ColorConst.primaryColor),
//                         ),
//                         filled: true,
//                         fillColor: ColorConst.boxColor,
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       style: const TextStyle(color: ColorConst.textColor),
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: walletController,
//                       decoration: InputDecoration(
//                         hintText: 'Target trips',
//                         prefixIcon: Padding(
//                             padding: EdgeInsets.all(w * 0.05),
//                             child: const Icon(
//                               Icons.trending_up_rounded,
//                               color: ColorConst.primaryColor,
//                             )),
//                         border: const OutlineInputBorder(),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: ColorConst.primaryColor),
//                         ),
//                         filled: true,
//                         fillColor: ColorConst.boxColor,
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       style: const TextStyle(color: ColorConst.textColor),
//                       keyboardType: TextInputType.number,
//                       // autovalidateMode: AutovalidateMode.onUnfocus,
//                       // validator: (value) {
//                       //   if (value == null ||
//                       //       value.isEmpty ||
//                       //       value.length < 10) {
//                       //     return "Please enter driver's Mobile number";
//                       //   }
//                       //   return null;
//                       // },
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(color: ColorConst.primaryColor),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         isLoading
//                             ? const Center(
//                                 child: CupertinoActivityIndicator(
//                                   color: ColorConst.primaryColor,
//                                 ),
//                               )
//                             : ElevatedButton(
//                                 style: const ButtonStyle(
//                                     backgroundColor: WidgetStatePropertyAll(
//                                         ColorConst.primaryColor)),
//                                 onPressed: () async {
//                                   if (formkey.currentState!.validate()) {
//                                     setState(() {
//                                       isLoading = true;
//                                     });
//                                     if (isEditing) {
//                                       await FirebaseFirestore.instance
//                                           .collection('users')
//                                           .doc(driver.userId)
//                                           .update({
//                                         'user_name': nameController.text.trim(),
//                                         'mobile_number':
//                                             '+91${phoneController.text}',
//                                         'wallet':
//                                             double.parse(walletController.text)
//                                       });
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(const SnackBar(
//                                               content: Text(
//                                                   'Details updated successfully!')));
//                                       setState(() {
//                                         isLoading = false;
//                                       });
//                                       Navigator.pop(context);
//                                     } else {
//                                       var users = await FirebaseFirestore
//                                           .instance
//                                           .collection('users')
//                                           .get();
//                                       var data = users.docs.where((element) =>
//                                           element['mobile_number'] ==
//                                           '+91${phoneController.text}');
//                                       if (data.isNotEmpty) {
//                                         print('MOBILE NUMBER ALREADY EXIST');
//                                         if (data
//                                             .first['organisation_id'].isEmpty) {
//                                           print('ORGANISATION ID IS EMPTY');
//                                           await FirebaseFirestore.instance
//                                               .collection('users')
//                                               .doc(data.first['user_id'])
//                                               .update({
//                                             'organisation_id':
//                                                 currentUser!.organisationId,
//                                             'user_role': 'Driver',
//                                             'user_name':
//                                                 nameController.text.trim(),
//                                             'status': 'ACTIVE',
//                                             'target_trips': int.parse(
//                                                 targetTripsController.text),
//                                           });
//                                           await FirebaseFirestore.instance
//                                               .collection('organisations')
//                                               .doc(currentUser!.organisationId)
//                                               .collection('drivers')
//                                               .doc(data.first['user_id'])
//                                               .set({
//                                             'organisation_id':
//                                                 currentUser!.organisationId,
//                                             'user_id': data.first['user_id'],
//                                           });
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(const SnackBar(
//                                                   content: Text(
//                                                       'Driver registered successfully!')));
//                                         } else {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(const SnackBar(
//                                                   content: Text(
//                                                       'User is already working in other Organisation!')));
//                                         }
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                       } else {
//                                         String userId = 'zer0user${users.size}';
//                                         await FirebaseFirestore.instance
//                                             .collection('users')
//                                             .doc(userId)
//                                             .set(UserModel(
//                                                     mobileNumber:
//                                                         '+91${phoneController.text}',
//                                                     organisationId: currentUser!
//                                                         .organisationId,
//                                                     organisationName:
//                                                         currentUser!
//                                                             .organisationName,
//                                                     userCreatedOn:
//                                                         DateTime.now()
//                                                             .toString(),
//                                                     userId: userId,
//                                                     userRole: 'Driver',
//                                                     userName: nameController
//                                                         .text
//                                                         .trim(),
//                                                     isBlocked: '',
//                                                     isDeleted: false,
//                                                     status: 'ACTIVE',
//                                                     cashCollected: 0,
//                                                     onRent: '',
//                                                     refund: 0,
//                                                     targetTrips: int.parse(
//                                                         targetTripsController
//                                                             .text),
//                                                     totalEarnings: 0,
//                                                     totalShifts: 0,
//                                                     totalTrips: 0,
//                                                     vehicleRent: 0,
//                                                     wallet: 0)
//                                                 .toJson());
//                                         await FirebaseFirestore.instance
//                                             .collection('organisations')
//                                             .doc(currentUser!.organisationId)
//                                             .collection('drivers')
//                                             .doc(userId)
//                                             .set({
//                                           'organisation_id':
//                                               currentUser!.organisationId,
//                                           'user_id': userId,
//                                         });
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(const SnackBar(
//                                                 content: Text(
//                                                     'Driver registered successfully!')));
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                         Navigator.pop(context);
//                                       }
//                                     }
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(
//                                             content: Text(
//                                                 'Enter required details!')));
//                                   }
//                                 },
//                                 child: Text(
//                                   isEditing ? 'Update' : 'Add Driver',
//                                   style: const TextStyle(
//                                       color: ColorConst.backgroundColor),
//                                 ),
//                               ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showVehicleForm({VehicleModel? vehicle}) {
//     final isEditing = vehicle != null;
//     final plateController =
//         TextEditingController(text: isEditing ? vehicle.vehicleNumber : '');
//     final rentController =
//         TextEditingController(text: isEditing ? vehicle.rent.toString() : '');
//     final targetTrips =
//         TextEditingController(text: isEditing ? vehicle.rent.toString() : '');

//     final formkey = GlobalKey<FormState>();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: ColorConst.boxColor,
//       isDismissible: false,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 top: 16,
//                 left: 16,
//                 right: 16,
//               ),
//               child: Form(
//                 key: formkey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       isEditing ? 'Edit Driver' : 'Add New Driver',
//                       style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: ColorConst.primaryColor),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: plateController,
//                       decoration: InputDecoration(
//                         hintText: 'Number plate',
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.all(w * 0.05),
//                           child: const Icon(
//                             CupertinoIcons.car_detailed,
//                             color: ColorConst.primaryColor,
//                           ),
//                         ),
//                         border: const OutlineInputBorder(),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: ColorConst.primaryColor),
//                         ),
//                         filled: true,
//                         fillColor: ColorConst.boxColor,
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       style: const TextStyle(color: ColorConst.textColor),
//                       keyboardType: TextInputType.name,
//                       textCapitalization: TextCapitalization.characters,
//                       autovalidateMode: AutovalidateMode.onUnfocus,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return "Please enter vehicle's number plate";
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: rentController,
//                       decoration: InputDecoration(
//                         hintText: 'Rent amount',
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.all(w * 0.05),
//                           child: const Text(
//                             '₹',
//                             style: TextStyle(color: ColorConst.primaryColor),
//                           ),
//                         ),
//                         suffix: const Text('12 hrs'),
//                         border: const OutlineInputBorder(),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: ColorConst.primaryColor),
//                         ),
//                         filled: true,
//                         fillColor: ColorConst.boxColor,
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       style: const TextStyle(color: ColorConst.textColor),
//                       keyboardType: TextInputType.name,
//                       textCapitalization: TextCapitalization.characters,
//                       autovalidateMode: AutovalidateMode.onUnfocus,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return "Please enter the rent amount";
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: rentController,
//                       decoration: InputDecoration(
//                         hintText: 'Target',
//                         prefixIcon: Padding(
//                           padding: EdgeInsets.all(w * 0.05),
//                           child: const Icon(Icons.perm_device_info,
//                               color: ColorConst.primaryColor),
//                         ),
//                         suffix: const Text('Trips'),
//                         border: const OutlineInputBorder(),
//                         focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: ColorConst.primaryColor),
//                         ),
//                         filled: true,
//                         fillColor: ColorConst.boxColor,
//                         hintStyle: const TextStyle(color: Colors.grey),
//                       ),
//                       style: const TextStyle(color: ColorConst.textColor),
//                       keyboardType: TextInputType.name,
//                       textCapitalization: TextCapitalization.characters,
//                       autovalidateMode: AutovalidateMode.onUnfocus,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return "Please enter the target trips";
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(color: ColorConst.primaryColor),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         isLoading
//                             ? const Center(
//                                 child: CupertinoActivityIndicator(
//                                   color: ColorConst.primaryColor,
//                                 ),
//                               )
//                             : ElevatedButton(
//                                 style: const ButtonStyle(
//                                     backgroundColor: WidgetStatePropertyAll(
//                                         ColorConst.primaryColor)),
//                                 onPressed: () async {
//                                   if (formkey.currentState!.validate()) {
//                                     setState(() {
//                                       isLoading = true;
//                                     });
//                                     if (isEditing) {
//                                       await FirebaseFirestore.instance
//                                           .collection('organisations')
//                                           .doc(currentUser!.organisationId)
//                                           .collection('vehicles')
//                                           .doc(vehicle.vehicleId)
//                                           .update({
//                                         'vehicle_number':
//                                             plateController.text.trim(),
//                                         'rent':
//                                             double.parse(rentController.text),
//                                         'target_trips':
//                                             int.parse(targetTrips.text)
//                                       });
//                                       setState(() {
//                                         isLoading = false;
//                                       });
//                                       Navigator.pop(context);
//                                     } else {
//                                       var vehicleCollection =
//                                           await FirebaseFirestore.instance
//                                               .collection('organisations')
//                                               .doc(currentUser!.organisationId)
//                                               .collection('vehicles')
//                                               .get();
//                                       var data = vehicleCollection.docs.where(
//                                           (element) =>
//                                               element['vehicle_number'] ==
//                                               plateController.text);
//                                       if (data.isNotEmpty) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(const SnackBar(
//                                                 content: Text(
//                                                     'Vehicle already exist!')));
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                       } else {
//                                         String vehicleId =
//                                             'vehicle${vehicleCollection.size}';
//                                         await FirebaseFirestore.instance
//                                             .collection('organisations')
//                                             .doc(currentUser!.organisationId)
//                                             .collection('vehicles')
//                                             .doc(vehicleId)
//                                             .set(VehicleModel(
//                                                     rent: double.parse(
//                                                         rentController.text),
//                                                     vehicleNumber:
//                                                         plateController.text,
//                                                     driver: '',
//                                                     startTime: Timestamp.now(),
//                                                     lastDriven: Timestamp.now(),
//                                                     onDuty: false,
//                                                     status: 'active',
//                                                     vehicleId: vehicleId,
//                                                     isDeleted: false,
//                                                     totalTrips: 0,
//                                                     targetTrips: int.parse(
//                                                         targetTrips.text))
//                                                 .toJson());
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(const SnackBar(
//                                                 content: Text(
//                                                     'Driver registered successfully!')));
//                                         setState(() {
//                                           isLoading = false;
//                                         });
//                                         Navigator.pop(context);
//                                       }
//                                     }
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(
//                                             content: Text(
//                                                 'Enter required details!')));
//                                   }
//                                 },
//                                 child: Text(
//                                   isEditing ? 'Update' : 'Add car',
//                                   style: const TextStyle(
//                                       color: ColorConst.backgroundColor),
//                                 ),
//                               ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   _logOutDialog() {
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: ColorConst.boxColor,
//         title:
//             Text('Log out?', style: TextStyle(color: ColorConst.primaryColor)),
//         content: Text('Are you sure you want to log out?',
//             style: TextStyle(color: ColorConst.primaryColor)),
//         actions: [
//           TextButton(
//               style: const ButtonStyle(
//                 foregroundColor:
//                     WidgetStatePropertyAll(ColorConst.primaryColor),
//               ),
//               onPressed: () => Navigator.pop(context),
//               child: const Text('No')),
//           TextButton(
//               style: const ButtonStyle(
//                 foregroundColor:
//                     WidgetStatePropertyAll(ColorConst.backgroundColor),
//                 backgroundColor:
//                     WidgetStatePropertyAll(ColorConst.primaryColor),
//               ),
//               onPressed: () async {
//                 await FirebaseAuth.instance.signOut();
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 prefs.setBool('isLogged', false);
//                 prefs.clear();
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   CupertinoDialogRoute(
//                       builder: (context) => const AuthPage(), context: context),
//                   (route) => false,
//                 );
//               },
//               child: const Text('Yes')),
//         ],
//       ),
//     );
//   }
// }

// // Extension to capitalize first letter
// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1)}";
//   }
// }
