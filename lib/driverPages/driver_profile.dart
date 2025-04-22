import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/auth/auth_page.dart';
import 'package:zero/auth/switch_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/razorpay_page.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
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
              versionText(),
              if (currentUser!.userRole.toUpperCase() == 'ADMIN')
                SizedBox(
                  height: h * 0.08,
                )
            ],
          ),
        ),
      ),
      floatingActionButton: currentUser!.userRole.toUpperCase() == 'ADMIN'
          ? GestureDetector(
              onTap: () async {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SwitchModePage(isDriving: false),
                    ));
              },
              child: Container(
                width: w * 0.6,
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.03, vertical: h * 0.01),
                margin: EdgeInsets.only(right: w * 0.03),
                decoration: BoxDecoration(
                    color: ColorConst.primaryColor,
                    borderRadius: BorderRadius.circular(w * 0.05)),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.swap_horiz_outlined,
                        color: ColorConst.backgroundColor,
                      ),
                      Text('Switch to Admin',
                          style: TextStyle(
                              color: ColorConst.backgroundColor,
                              fontWeight: FontWeight.bold))
                    ]),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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
          currentDriver!.driverName,
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
                            currentDriver!.driverName[0],
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
                        currentDriver!.wallet.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: w * 0.06,
                            color: currentDriver!.wallet > 0
                                ? ColorConst.successColor
                                : currentDriver!.wallet == 0
                                    ? Colors.grey
                                    : ColorConst.errorColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: h * 0.01,
                      ),
                      if (currentDriver!.wallet < 0)
                        ElevatedButton(
                            style: ButtonStyle(
                                elevation: const WidgetStatePropertyAll(3),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(w * 0.03))),
                                shadowColor: const WidgetStatePropertyAll(
                                    ColorConst.successColor),
                                foregroundColor: const WidgetStatePropertyAll(
                                    ColorConst.successColor),
                                backgroundColor: const WidgetStatePropertyAll(
                                    ColorConst.boxColor)),
                            onPressed: () => showModalBottomSheet(
                                context: context,
                                isDismissible: false,
                                backgroundColor: ColorConst.boxColor,
                                builder: (context) => RazorPayBottomSheet(
                                    amount: -currentDriver!.wallet)),
                            child: const Text('Pay now'))
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  razorPayBottomSheet() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: ColorConst.boxColor,
        isDismissible: false,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(w * 0.03),
            child: Column(
              children: [],
            ),
          );
        });
  }

  Widget progressDetails() {
    double totalEarning = currentDriver!.totalEarnings -
        currentDriver!.vehicleRent -
        currentDriver!.fuelExpense;
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
                        currentDriver!.totalShifts.toString(),
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
                        currentDriver!.totalTrips.toString(),
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
                        totalEarning.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: totalEarning >= 0
                                ? ColorConst.successColor
                                : ColorConst.errorColor),
                      ),
                      SizedBox(height: w * 0.03),
                      const Text(
                        'Total income',
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
            _buildTextRow('Name', currentDriver!.driverName),
            _buildTextRow('Mobile number', currentDriver!.mobileNumber),
            _buildTextRow('status', currentDriver!.status.toUpperCase()),
            if (currentDriver!.organisationName.isNotEmpty)
              _buildTextRow('Organisation', currentDriver!.organisationName),
            _buildTextRow(
                'Joined on',
                DateFormat.yMMMEd()
                    .format(DateTime.parse(currentDriver!.driverAddedOn))),
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
            _buildTextRow('Total Earnings',
                "₹ ${currentDriver!.totalEarnings.toStringAsFixed(2)}"),
            _buildTextRow('Total Refund',
                '₹ ${currentDriver!.refund.toStringAsFixed(2)}'),
            _buildTextRow('Total Cash Collected',
                '₹ ${currentDriver!.cashCollected.toStringAsFixed(2)}'),
            _buildTextRow('Total Expense on fuel',
                '₹ ${currentDriver!.fuelExpense.toStringAsFixed(2)}'),
            _buildTextRow('Total rent',
                '₹ ${currentDriver!.vehicleRent.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

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
