import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:expandable/expandable.dart';
import 'package:zero/models/rent_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime? weekEnd;
  bool isLoading = false;
  List<RentModel> rentModels = [];
  Future getRents() async {
    rentModels.clear();
    weekStart =
        DateTime(weekStart.year, weekStart.month, weekStart.day, 4, 0, 0);
    weekEnd = weekStart.add(const Duration(days: 6, hours: 24));
    setState(() {
      isLoading = true;
    });
    var rentcollection = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('rents')
        .where('rent_status', isEqualTo: 'completed')
        .where('start_time',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('start_time', isLessThan: Timestamp.fromDate(weekEnd!))
        .get();
    for (var rents in rentcollection.docs) {
      rentModels.add(RentModel.fromMap(rents.data()));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getRents();
    super.initState();
  }

  void previousWeek() {
    setState(() {
      weekStart = weekStart.subtract(const Duration(days: 7));
    });
    getRents();
  }

  void nextWeek() {
    if (DateTime.now().difference(weekStart).inDays < 7) {
      null;
    } else {
      setState(() {
        weekStart = weekStart.add(const Duration(days: 7));
      });
      getRents();
    }
  }

  String getWeekRange() {
    final DateFormat formatter = DateFormat('MMM d');
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));
    return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) =>
          [appbar(), selectWeek()],
      body: isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
                color: ColorConst.primaryColor,
              ),
            )
          : rentModels.isEmpty
              ? const Center(
                  child: Text(
                  'You were on Leave!',
                  style: TextStyle(
                      color: ColorConst.textColor, fontWeight: FontWeight.bold),
                ))
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tripStats(),
                        SizedBox(height: h * 0.02),
                        stateBreakdown(),
                        SizedBox(height: h * 0.02),
                        buildRentList(),
                      ],
                    ),
                  ),
                ),
    ));
  }

  Widget appbar() {
    return SliverAppBar(
      toolbarHeight: h * 0.1,
      title: const Text('Weekly dashboard',
          style: TextStyle(
              color: ColorConst.textColor, fontWeight: FontWeight.bold)),
      backgroundColor: ColorConst.boxColor,
      elevation: 2,
    );
  }

  Widget selectWeek() {
    return SliverAppBar(
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      pinned: true,
      leadingWidth: w,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: ColorConst.textColor,
            ),
            onPressed: previousWeek,
          ),
          Text(
            getWeekRange(),
            style: const TextStyle(
              color: ColorConst.textColor,
              // fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: nextWeek,
            color: DateTime.now().difference(weekStart).inDays < 7
                ? Colors.grey
                : ColorConst.textColor,
          ),
        ],
      ),
    );
  }

  Widget tripStats() {
    int totalShifts = rentModels.fold(0, (shift, a) => shift + a.shift);
    int totalTrips = rentModels.fold(0, (trips, a) => trips + a.totalTrips);
    double totalEarnings =
        rentModels.fold(0, (earnings, a) => earnings + a.totalEarnings);
    double totalRefund = rentModels.fold(0, (refund, a) => refund + a.refund);
    double totalCashCollected = rentModels.fold(
        0, (cashCollected, a) => cashCollected + a.cashCollected);
    double totalRent = rentModels
        .map((item) => item.shift * item.rent)
        .reduce((rent, element) => rent + element);
    double yourEarnings = totalEarnings + totalRefund;
    double totaltoPay = yourEarnings - totalCashCollected - totalRent;
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
                    totalShifts.toString(),
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
                    yourEarnings.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor),
                  ),
                  SizedBox(height: w * 0.03),
                  const Text(
                    'Your earnings',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: h * 0.03),
          Column(
            children: [
              Text(
                totaltoPay.toString(),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: totaltoPay > 0
                        ? ColorConst.successColor
                        : ColorConst.errorColor),
              ),
              SizedBox(height: w * 0.03),
              const Text(
                'Total to pay',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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
    double totalEarnings =
        rentModels.fold(0, (earnings, a) => earnings + a.totalEarnings);
    double totalRefund = rentModels.fold(0, (refund, a) => refund + a.refund);
    double totalCashCollected = rentModels.fold(
        0, (cashCollected, a) => cashCollected + a.cashCollected);
    double totalRent = rentModels
        .map((item) => item.shift * item.rent)
        .reduce((rent, element) => rent + element);
    double balance = totalEarnings + totalRefund - totalCashCollected;
    double toPay = balance - totalRent;
    return Column(
      children: [
        _breakdown(
            label: 'Total earnings',
            value: '₹ ${totalEarnings.toStringAsFixed(2)}'),
        _breakdown(
            label: 'Refund', value: '₹ ${totalRefund.toStringAsFixed(2)}'),
        _breakdown(
            label: 'Cash collected',
            value: '₹ ${totalCashCollected.toStringAsFixed(2)}'),
        const Divider(color: Colors.grey),
        Padding(
          padding: EdgeInsets.all(w * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance',
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
        ),
        _breakdown(
            label: 'Vehicle rent', value: '-${totalRent.toStringAsFixed(2)}'),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total to pay',
              style: TextStyle(
                  color: ColorConst.textColor,
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              '₹ ${toPay.toStringAsFixed(2)}',
              style: TextStyle(
                  color: toPay > 0
                      ? ColorConst.successColor
                      : ColorConst.errorColor,
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

  Widget buildRentList() {
    return Container(
        decoration: BoxDecoration(
          color: ColorConst.boxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: w * 0.05, left: w * 0.03),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded,
                      color: ColorConst.textColor),
                  SizedBox(width: w * 0.03),
                  const Text(
                    'Weekly activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorConst.textColor,
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rentModels.length,
              itemBuilder: (context, index) {
                DateTime date = rentModels[index].startTime.toDate();
                double totalEarning = rentModels[index].totalEarnings +
                    rentModels[index].refund -
                    rentModels[index].cashCollected;
                double balance = totalEarning -
                    (rentModels[index].shift * rentModels[index].rent);
                return ExpandablePanel(
                  theme: ExpandableThemeData(
                    useInkWell: false,
                    iconColor: ColorConst.textColor,
                    iconSize: w * 0.06,
                  ),
                  header: ListTile(
                    leading: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('E').format(date),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          Text(
                            DateFormat('d').format(date),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.textColor),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      rentModels[index].vehicleNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor,
                      ),
                    ),
                    subtitle: Text(
                      "${DateFormat.jm().format(rentModels[index].startTime.toDate())} - ${DateFormat.jm().format(rentModels[index].endTime!.toDate())}",
                      style: TextStyle(color: Colors.grey),
                    ),
                    // trailing: Text(
                    //   '₹${(balance).toStringAsFixed(2)}',
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       color: balance < 0
                    //           ? ColorConst.errorColor
                    //           : ColorConst.successColor),
                    // ),
                  ),
                  collapsed: const SizedBox(),
                  expanded: Padding(
                    padding: EdgeInsets.all(w * 0.03),
                    child: Column(
                      children: [
                        _breakdown(
                            label: 'Total shift',
                            value: rentModels[index].shift.toString()),
                        _breakdown(
                            label: 'Total earnings',
                            value: rentModels[index]
                                .totalEarnings
                                .toStringAsFixed(2)),
                        _breakdown(
                            label: 'Refund',
                            value: rentModels[index].refund.toStringAsFixed(2)),
                        _breakdown(
                            label: 'Cash collected',
                            value: rentModels[index]
                                .cashCollected
                                .toStringAsFixed(2)),
                        _breakdown(
                            label: 'Vehicle rent',
                            value: (rentModels[index].shift *
                                    rentModels[index].rent)
                                .toStringAsFixed(2)),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[700],
              ),
            ),
          ],
        ));
  }
}
