import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:zero/adminPages/screens/admin_notifications.dart';
import 'package:zero/auth/auth_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/organisation_model.dart';

class GOrganisationPage extends StatefulWidget {
  const GOrganisationPage({super.key});

  @override
  State<GOrganisationPage> createState() => _GOrganisationPageState();
}

class _GOrganisationPageState extends State<GOrganisationPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [appbar()],
          body: SingleChildScrollView(
            child: Column(
              children: [
                _organisationDetails(),
                _fleetDetails(),
                _buildAdminDetails(),
                SizedBox(height: h * 0.03),
                logoutButton(context),
                versionText(),
                SizedBox(
                  height: h * 0.08,
                )
              ],
            ),
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () async {
            Fluttertoast.showToast(msg: 'Cannot switch in trial mode');
          },
          child: Container(
            width: w * 0.6,
            padding:
                EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.01),
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
                  Text('Switch to driving',
                      style: TextStyle(
                          color: ColorConst.backgroundColor,
                          fontWeight: FontWeight.bold))
                ]),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      toolbarHeight: h * 0.1,
      title: const Text('Organization',
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

  Widget _organisationDetails() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      color: ColorConst.boxColor,
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.assured_workload_rounded,
                    color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Organization details',
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
            _buildTextRow('Organisation Name', 'ABC'),
            _buildTextRow('Fleet', org.fleet.fleetName),
            _buildTextRow(
                'Created on', DateFormat('dd-MM-yyyy').format(DateTime.now())),
          ],
        ),
      ),
    );
  }

  Widget _fleetDetails() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      color: ColorConst.boxColor,
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_city_rounded,
                    color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Fleet details',
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
            _buildTextRow('Current Plan', 'Fleet_plan'),
            _buildTextRow('Insurance', '15'.toString()),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: w * 0.03, horizontal: w * 0.02),
              child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                      useInkWell: false, iconColor: ColorConst.textColor),
                  header: const Text(
                    'Rent details',
                    style: TextStyle(color: Colors.grey),
                  ),
                  collapsed: const SizedBox(),
                  expanded: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: org.fleet.fleetPlan.rent.length,
                    itemBuilder: (context, index) {
                      List<Rent> plan = org.fleet.fleetPlan.rent;
                      return index == plan.length - 1
                          ? _buildTextRow(
                              '${plan[index].trip}+ ', "${plan[index].rent}/-")
                          : _buildTextRow(
                              '${plan[index].trip} - ${plan[index + 1].trip - 1} trips',
                              '${plan[index].rent}/-');
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDetails() {
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
                  'Admin profile',
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
            _buildTextRow('Mobile number', '+911234567890'),
            _buildTextRow('Admin', 'Admin_name'),
            _buildTextRow(
                'Created on', DateFormat.yMMMEd().format(DateTime.now())),
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
