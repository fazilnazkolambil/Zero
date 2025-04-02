import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/driver_model.dart'; // For date formatting

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  DateTime currentWeekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DriverModel? driverData;
  bool isLoading = false;
  Future getDriver() async {
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
      driverData = DriverModel.fromJson(value.data() as Map<String, dynamic>);
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getDriver();
    super.initState();
  }

  // Go to previous week
  void previousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  // Go to next week
  void nextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    });
  }

  // Format week range for display
  String getWeekRange() {
    final DateFormat formatter = DateFormat('MMM d');
    final DateTime weekEnd = currentWeekStart.add(const Duration(days: 6));
    return '${formatter.format(currentWeekStart)} - ${formatter.format(weekEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: h * 0.1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly dashboard',
                style: TextStyle(
                    color: ColorConst.textColor, fontWeight: FontWeight.bold)),
            SizedBox(height: h * 0.01),
            Text(
              '(${getWeekRange()})',
              style: TextStyle(color: Colors.grey, fontSize: w * 0.045),
            )
          ],
        ),
        backgroundColor: ColorConst.boxColor,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
                color: ColorConst.primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // profileCard(),
                    // SizedBox(height: h * 0.03),
                    driverStats(),
                    SizedBox(height: h * 0.02),
                    stateBreakdown(),
                    // SizedBox(height: h * 0.02),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       vertical: 8, horizontal: 16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.1),
                    //         spreadRadius: 1,
                    //         blurRadius: 3,
                    //         offset: const Offset(0, 1),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       IconButton(
                    //         icon: const Icon(Icons.arrow_back_ios, size: 18),
                    //         onPressed: previousWeek,
                    //       ),
                    //       Column(
                    //         children: [
                    //           const Text(
                    //             'Weekly Activity',
                    //             style: TextStyle(
                    //               fontSize: 12,
                    //               color: Colors.grey,
                    //             ),
                    //           ),
                    //           Text(
                    //             getWeekRange(),
                    //             style: const TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       IconButton(
                    //         icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    //         onPressed: nextWeek,
                    //         // Disable next week button if trying to go beyond current week
                    //         color: DateTime.now()
                    //                     .difference(currentWeekStart)
                    //                     .inDays <
                    //                 7
                    //             ? Colors.grey
                    //             : null,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: h * 0.02),

                    // // Stats Title
                    // const Text(
                    //   'Weekly Stats & Earnings',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    // const SizedBox(height: 16),

                    // // Stats Cards - Row 1
                    // // Row(
                    // //   children: [
                    // //     // Total Trips Card
                    // //     Expanded(
                    // //       child: StatCard(
                    // //         title: 'Weekly Trips',
                    // //         value: driverData!.totalTrips.toString(),
                    // //         icon: Icons.local_taxi,
                    // //         color: Colors.blue,
                    // //         subtitle:
                    // //             'Remaining: ${driverData!.targetTrips - driverData!.totalTrips}',
                    // //       ),
                    // //     ),
                    // //     const SizedBox(width: 16),
                    // //     // Total Earnings Card
                    // //     Expanded(
                    // //       child: StatCard(
                    // //         title: 'Weekly Earnings',
                    // //         value: '₹${driverData!.totalEarnings!}',
                    // //         icon: Icons.payments,
                    // //         color: Colors.green,
                    // //       ),
                    // //     ),
                    // //   ],
                    // // ),

                    // const SizedBox(height: 16),

                    // // Stats Cards - Row 2
                    // // Row(
                    // //   children: [
                    // //     // Cash Collected Card
                    // //     Expanded(
                    // //       child: StatCard(
                    // //         title: 'Cash Collected',
                    // //         value: '₹${driverData!.cashCollected}',
                    // //         icon: Icons.account_balance_wallet,
                    // //         color: Colors.amber,
                    // //       ),
                    // //     ),
                    // //     const SizedBox(width: 16),
                    // //     // Wallet Card
                    // //     Expanded(
                    // //       child: StatCard(
                    // //         title: 'Wallet Balance',
                    // //         value: '₹${driverData!.wallet}',
                    // //         icon: Icons.credit_card,
                    // //         color: Colors.purple,
                    // //       ),
                    // //     ),
                    // //   ],
                    // // ),

                    // const SizedBox(height: 24),

                    // // Daily Activity for the Week
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     const Text(
                    //       'Daily Activity',
                    //       style: TextStyle(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {},
                    //       child: const Text('View Details'),
                    //     ),
                    //   ],
                    // ),

                    // const SizedBox(height: 8),

                    // // Daily Activity List
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.1),
                    //         spreadRadius: 1,
                    //         blurRadius: 3,
                    //         offset: const Offset(0, 1),
                    //       ),
                    //     ],
                    //   ),
                    //   child: ListView.builder(
                    //     shrinkWrap: true,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     itemCount: 7, // 7 days of the week
                    //     itemBuilder: (context, index) {
                    //       // Generate a date for each day of the selected week
                    //       final date =
                    //           currentWeekStart.add(Duration(days: index));
                    //       final isToday = DateFormat('yyyy-MM-dd')
                    //               .format(date) ==
                    //           DateFormat('yyyy-MM-dd').format(DateTime.now());

                    //       // Mock data - would be replaced with actual data in a real app
                    //       final dayTrips = index < 5
                    //           ? (5 - index)
                    //           : 0; // More trips on weekdays
                    //       final dayEarnings = dayTrips * 250.0;

                    //       return Container(
                    //         decoration: BoxDecoration(
                    //           border: index < 6
                    //               ? Border(
                    //                   bottom: BorderSide(
                    //                     color: Colors.grey.withOpacity(0.2),
                    //                     width: 1,
                    //                   ),
                    //                 )
                    //               : null,
                    //         ),
                    //         child: ListTile(
                    //           contentPadding: const EdgeInsets.symmetric(
                    //               horizontal: 16, vertical: 8),
                    //           leading: Container(
                    //             width: 50,
                    //             decoration: BoxDecoration(
                    //               color: isToday
                    //                   ? Colors.blue.withOpacity(0.1)
                    //                   : Colors.grey.withOpacity(0.1),
                    //               borderRadius: BorderRadius.circular(8),
                    //             ),
                    //             padding: const EdgeInsets.all(8),
                    //             alignment: Alignment.center,
                    //             child: Column(
                    //               mainAxisSize: MainAxisSize.min,
                    //               children: [
                    //                 Text(
                    //                   DateFormat('E').format(date),
                    //                   style: TextStyle(
                    //                     fontSize: 12,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: isToday
                    //                         ? Colors.blue
                    //                         : Colors.grey[700],
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   DateFormat('d').format(date),
                    //                   style: TextStyle(
                    //                     fontSize: 16,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: isToday
                    //                         ? Colors.blue
                    //                         : Colors.black,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           title: Text(
                    //             dayTrips > 0 ? '$dayTrips trips' : 'No trips',
                    //             style: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //               color:
                    //                   dayTrips > 0 ? Colors.black : Colors.grey,
                    //             ),
                    //           ),
                    //           subtitle: Text(
                    //             dayTrips > 0
                    //                 ? '${dayTrips > 1 ? "Multiple locations" : "Single location"}'
                    //                 : 'Day off',
                    //             style: const TextStyle(fontSize: 12),
                    //           ),
                    //           trailing: dayTrips > 0
                    //               ? Text(
                    //                   '₹${dayEarnings.toStringAsFixed(2)}',
                    //                   style: const TextStyle(
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.green,
                    //                   ),
                    //                 )
                    //               : null,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),

                    // const SizedBox(height: 24),

                    // Week Summary
                  ],
                ),
              ),
            ),
    );
  }

  Widget profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.boxColor,
        borderRadius: BorderRadius.circular(w * 0.03),
        // boxShadow: [
        //   BoxShadow(
        //       color: ColorConst.primaryColor.withOpacity(0.5),
        //       blurRadius: 5,
        //       spreadRadius: 2)
        // ]
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: ColorConst.primaryColor.withOpacity(0.3),
            child: Text(
              driverData!.driverName.toString()[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorConst.textColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Driver Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverData!.driverName.toString(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorConst.textColor),
                ),
                SizedBox(height: w * 0.03),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: w * 0.03),
                    Text(
                      driverData!.mobileNumber.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.03),
                Row(
                  children: [
                    Icon(
                      Icons.wallet,
                      size: 16,
                      color: driverData!.wallet > 0 ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: w * 0.03),
                    Text(
                      driverData!.wallet.toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            driverData!.wallet > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget driverStats() {
    int remainingTrips = driverData!.targetTrips - driverData!.totalTrips;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.boxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_chart, color: ColorConst.textColor),
              SizedBox(width: w * 0.03),
              const Text(
                'Stats',
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
                    driverData!.totalShifts.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor),
                  ),
                  SizedBox(height: w * 0.03),
                  const Text(
                    'Total shifts',
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
                    driverData!.totalTrips.toString(),
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
                    remainingTrips.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: remainingTrips < 0
                            ? ColorConst.successColor
                            : remainingTrips == 0
                                ? ColorConst.textColor
                                : ColorConst.errorColor),
                  ),
                  SizedBox(height: w * 0.03),
                  const Text(
                    'Remaining trips',
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
    );
  }

  Widget stateBreakdown() {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConst.boxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            buildBreakDown()
          ],
        ));
  }

  Widget buildBreakDown() {
    double totalIncome = driverData!.totalEarnings +
        driverData!.refund -
        driverData!.cashCollected;
    double balance = totalIncome - driverData!.vehicleRent;
    return Column(
      children: [
        _breakdown(
            label: 'Total earnings',
            value: '₹ ${driverData!.totalEarnings.toStringAsFixed(2)}'),
        _breakdown(
            label: 'Refund',
            value: '₹ ${driverData!.refund.toStringAsFixed(2)}'),
        _breakdown(
            label: 'Cash collected',
            value: '₹ ${driverData!.cashCollected.toStringAsFixed(2)}'),
        Divider(),
        Padding(
          padding: EdgeInsets.all(w * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total income',
                style: TextStyle(
                    color: ColorConst.textColor,
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                '₹ ${totalIncome.toStringAsFixed(2)}',
                style: TextStyle(
                    color: ColorConst.textColor,
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        _breakdown(
            label: 'Vehicle rent',
            value: '-${driverData!.vehicleRent.toStringAsFixed(2)}'),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your earning',
              style: TextStyle(
                  color: ColorConst.textColor,
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              '₹ ${balance.toStringAsFixed(2)}',
              style: TextStyle(
                  color: ColorConst.textColor,
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  _breakdown({required String label, required String value}) {
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
