import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/adminPages/screens/admin_bottom_page.dart';
import 'package:zero/auth/auth_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/adminPages/screens/_admin_dashboard.dart';
import 'package:zero/welcome_page.dart';

class DriverProfilePage extends StatelessWidget {
  final bool isDeleted;
  final int totalTrips;
  final double totalEarnings;
  final double cashCollected;
  final double refund;
  final double wallet;
  final String onRent;
  final String driverName;
  final String mobileNumber;
  final String status;
  final String driverId;
  final String isBlocked;
  final String organisationId;
  final String organisationName;
  final int targetTrips;
  final int totalShifts;
  final double vehicleRent;
  final Timestamp createdOn;

  const DriverProfilePage({
    super.key,
    required this.isDeleted,
    required this.totalTrips,
    required this.totalEarnings,
    required this.cashCollected,
    required this.refund,
    required this.wallet,
    required this.onRent,
    required this.driverName,
    required this.mobileNumber,
    required this.status,
    required this.driverId,
    required this.isBlocked,
    required this.organisationId,
    required this.organisationName,
    required this.targetTrips,
    required this.totalShifts,
    required this.vehicleRent,
    required this.createdOn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [appBar()],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: h * 0.02,
            ),
            progressDetails(),
            _buildProfileDetails(),
            _buildFinancialDetails(),
            SizedBox(height: h * 0.03),
            logoutButton(context),
            versionText()
          ],
        ),
      ),
    ));
  }

  Widget appBar() {
    return SliverAppBar(
      backgroundColor: ColorConst.boxColor,
      surfaceTintColor: ColorConst.boxColor,
      foregroundColor: ColorConst.textColor,
      expandedHeight: h * 0.25,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        titlePadding: EdgeInsets.only(left: w * 0.07, bottom: w * 0.05),
        title: Text(
          driverName,
          style: TextStyle(
            color: ColorConst.textColor,
            fontWeight: FontWeight.bold,
            fontSize: w * 0.055,
          ),
        ),
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: h * 0.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: ColorConst.primaryColor,
                          child: Text(
                            driverName[0],
                            style: TextStyle(
                              fontSize: w * 0.15,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Your wallet',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: h * 0.01,
                      ),
                      Text(
                        wallet.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: w * 0.06,
                            color: wallet > 0
                                ? ColorConst.successColor
                                : wallet == 0
                                    ? Colors.grey
                                    : ColorConst.errorColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: h * 0.01,
                      ),
                      if (wallet < 0)
                        ElevatedButton(
                            style: const ButtonStyle(
                                shadowColor: WidgetStatePropertyAll(
                                    ColorConst.successColor),
                                foregroundColor: WidgetStatePropertyAll(
                                    ColorConst.successColor),
                                backgroundColor: WidgetStatePropertyAll(
                                    ColorConst.boxColor)),
                            onPressed: () {},
                            child: const Text('Pay now'))
                    ],
                  )
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         const Icon(Icons.call, color: Colors.grey),
                  //         SizedBox(width: w * 0.02),
                  //         Text(mobileNumber,
                  //             style: const TextStyle(
                  //                 color: Colors.grey,
                  //                 fontWeight: FontWeight.bold))
                  //       ],
                  //     ),
                  //     Row(
                  //       children: [
                  //         const Icon(Icons.online_prediction,
                  //             color: Colors.grey),
                  //         SizedBox(width: w * 0.02),
                  //         Text(status.toUpperCase(),
                  //             style: TextStyle(
                  //                 color: status.toUpperCase() == 'ACTIVE'
                  //                     ? ColorConst.successColor
                  //                     : status.toUpperCase() == 'ONLEAVE'
                  //                         ? Colors.grey
                  //                         : ColorConst.errorColor,
                  //                 fontWeight: FontWeight.bold))
                  //       ],
                  //     ),
                  //     Row(
                  //       children: [
                  //         const Icon(
                  //           Icons.wallet,
                  //           color: Colors.grey,
                  //         ),
                  //         SizedBox(width: w * 0.02),
                  //         Text(
                  //           wallet.toStringAsFixed(2),
                  //           style: TextStyle(
                  //               color: wallet > 0
                  //                   ? ColorConst.successColor
                  //                   : wallet == 0
                  //                       ? Colors.grey
                  //                       : ColorConst.errorColor,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget progressDetails() {
    double totalEarning = totalEarnings + refund + wallet;
    return Card(
        margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
        color: ColorConst.boxColor,
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up_outlined,
                      color: ColorConst.textColor),
                  SizedBox(width: w * 0.03),
                  const Text(
                    'Your progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorConst.textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        totalShifts.toString(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorConst.textColor),
                      ),
                      SizedBox(height: w * 0.03),
                      const Text(
                        'Total Duties',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        totalTrips.toString(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorConst.textColor),
                      ),
                      SizedBox(height: w * 0.03),
                      const Text(
                        'Total trips',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        totalEarning.toString(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorConst.textColor),
                      ),
                      SizedBox(height: w * 0.03),
                      const Text(
                        'Total earnings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildProfileDetails() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      color: ColorConst.boxColor,
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.person_2_outlined,
                    color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Your profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.textColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: h * 0.02,
            ),
            _buildTextRow('Name', driverName),
            _buildTextRow('Mobile number', mobileNumber),
            _buildTextRow('status', status.toUpperCase()),
            _buildTextRow('Organisation', organisationName),
            _buildTextRow(
                'Created on', DateFormat.yMMMEd().format(createdOn.toDate())),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDetails() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      color: ColorConst.boxColor,
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_outlined,
                    color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Financial details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.textColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: h * 0.02,
            ),
            _buildTextRow('Total Earnings', "₹ $totalEarnings"),
            _buildTextRow('Total Refund', '₹ $refund'),
            _buildTextRow('Total Cash Collected', '₹ $cashCollected'),
          ],
        ),
      ),
    );
  }

  // Widget _buildTripDetails() {
  //   double tripCompletion = totalTrips / (targetTrips > 0 ? targetTrips : 1);
  //   return Card(
  //     margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
  //     color: ColorConst.boxColor,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               const Icon(Icons.directions_subway_outlined,
  //                   color: ColorConst.textColor),
  //               SizedBox(width: w * 0.03),
  //               const Text(
  //                 'Trip details',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   color: ColorConst.textColor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(
  //             height: h * 0.02,
  //           ),
  //           const Divider(),
  //           _buildTextRow('Total Trips', totalTrips.toString()),
  //           _buildTextRow('Target Trips', targetTrips.toString()),
  //           _buildTextRow('Total Shifts', totalShifts.toString()),
  //           // ClipRRect(
  //           //   borderRadius: BorderRadius.circular(10),
  //           //   child: LinearProgressIndicator(
  //           //     value: tripCompletion > 1 ? 1 : tripCompletion,
  //           //     minHeight: 15,
  //           //     backgroundColor: Colors.grey.shade200,
  //           //     valueColor: AlwaysStoppedAnimation<Color>(
  //           //       tripCompletion >= 1 ? Colors.green : Colors.blue,
  //           //     ),
  //           //   ),
  //           // ),
  //           // const SizedBox(height: 4),
  //           // Text(
  //           //   '${(tripCompletion * 100).toStringAsFixed(0)}%',
  //           //   style: TextStyle(
  //           //     color: tripCompletion >= 1 ? Colors.green : Colors.blue,
  //           //     fontWeight: FontWeight.bold,
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTextRow(String label, String value) {
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

  Widget logoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _logOutDialog(context),
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => AdminDashboard()
      //         // WelcomePage(
      //         //     userRole: UserRole.admin,
      //         //     userName: 'Fazil naz Kolambil',
      //         //     userData: {
      //         //       'cashCollected': 1000.00,
      //         //       'driverId': 'driver_id',
      //         //       'driverName': 'Fazil naz kolambil',
      //         //       'isBlocked': 'Not blocked',
      //         //       'isDeleted': false,
      //         //       'mobileNumber': '+919487022519',
      //         //       'onRent': 'rentId1',
      //         //       'organisationId': 'organisation_id',
      //         //       'organisationName': 'Zero uber',
      //         //       'refund': 500.50,
      //         //       'status': 'active',
      //         //       'targetTrips': 70,
      //         //       'totalEarnings': 3500.50,
      //         //       'totalShifts': 7,
      //         //       'totalTrips': 35,
      //         //       'vehicleRent': 500,
      //         //       'wallet': -1500.50,
      //         //       'createdOn': Timestamp.now(),
      //         //       'openIssues': 1
      //         //     }),
      //         )),

      icon: Icon(
        Icons.logout,
        color: ColorConst.primaryColor,
        size: w * 0.06,
      ),
      label: Text(
        "Logout",
        style: TextStyle(color: ColorConst.primaryColor, fontSize: w * 0.045),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(w * 0.9, h * 0.065),
        backgroundColor: Colors.transparent,
        elevation: 2,
        side: const BorderSide(color: ColorConst.primaryColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
      ),
    );
  }

  Widget versionText() {
    return Padding(
      padding: EdgeInsets.all(w * 0.05),
      child: Text(
        'App version : $version',
        style: TextStyle(color: Colors.grey, fontSize: w * 0.035),
      ),
    );
  }

  _logOutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorConst.boxColor,
        title: const Text('Log out?',
            style: TextStyle(color: ColorConst.primaryColor)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: ColorConst.textColor)),
        actions: [
          TextButton(
              style: const ButtonStyle(
                side: WidgetStatePropertyAll(
                    BorderSide(color: ColorConst.primaryColor)),
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
