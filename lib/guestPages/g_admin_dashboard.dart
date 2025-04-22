import 'package:expandable/expandable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zero/adminPages/screens/admin_notifications.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class GAdminDashboard extends StatefulWidget {
  const GAdminDashboard({super.key});

  @override
  State<GAdminDashboard> createState() => _GAdminDashboardState();
}

class _GAdminDashboardState extends State<GAdminDashboard> {
  DateTime weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime? weekEnd;
  bool isLoading = false;

  void previousWeek() {
    setState(() {
      weekStart = weekStart.subtract(const Duration(days: 7));
    });
  }

  void nextWeek() {
    if (DateTime.now().difference(weekStart).inDays < 7) {
      null;
    } else {
      setState(() {
        weekStart = weekStart.add(const Duration(days: 7));
      });
    }
  }

  String getWeekRange() {
    final DateFormat formatter = DateFormat('MMM d');
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));
    return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
  }

  double fleetRent = 2100;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CupertinoActivityIndicator(
                  color: ColorConst.primaryColor,
                ),
              )
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) =>
                    [appbar(), selectWeek()],
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      rentStats(),
                      SizedBox(height: h * 0.01),
                      incomeStats(),
                      SizedBox(height: h * 0.01),
                      revenueStats(),
                      SizedBox(height: h * 0.01),
                      buildRentList(),
                    ],
                  ),
                )),
      ),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      toolbarHeight: h * 0.1,
      title: const Text('Weekly dashboard',
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

  Widget selectWeek() {
    return SliverAppBar(
        backgroundColor: ColorConst.backgroundColor,
        surfaceTintColor: ColorConst.backgroundColor,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: ColorConst.textColor,
                ),
                onPressed: previousWeek,
              ),
              Text(
                getWeekRange(),
                style: const TextStyle(
                  color: ColorConst.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: nextWeek,
                color: DateTime.now().difference(weekStart).inDays < 7
                    ? Colors.grey
                    : ColorConst.textColor,
              ),
            ],
          ),
        ));
  }

  Widget rentStats() {
    double onlineAmount = 500;
    double totaltoPay = fleetRent - onlineAmount;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      color: ColorConst.boxColor,
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.car_rental_outlined,
                        color: ColorConst.textColor),
                    SizedBox(width: w * 0.03),
                    const Text(
                      'Fleet Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(2),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(w * 0.03))),
                        shadowColor: const WidgetStatePropertyAll(
                            ColorConst.primaryColor),
                        foregroundColor: const WidgetStatePropertyAll(
                            ColorConst.primaryColor),
                        backgroundColor:
                            const WidgetStatePropertyAll(ColorConst.boxColor)),
                    onPressed: () => showRentBreakdownBottomSheet(),
                    child: const Text('Details'))
              ],
            ),
            SizedBox(height: h * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      fleetRent.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
                    ),
                    SizedBox(height: w * 0.03),
                    const Text(
                      'Fleet rent',
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
                      (-onlineAmount).toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
                    ),
                    SizedBox(height: w * 0.03),
                    Text(
                      onlineAmount <= 0 ? 'Online balance' : 'Cash balance',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      totaltoPay.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
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
          ],
        ),
      ),
    );
  }

  Widget incomeStats() {
    double driversWallet = 1000;
    double paymentReceived = 2000;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard(
            title: 'Drivers to pay',
            value: '₹ ${(-driversWallet).toStringAsFixed(2)}',
            subtitle: 'Pending balance of drivers'),
        _buildSummaryCard(
            title: 'Available balance',
            value: '₹ ${paymentReceived.toStringAsFixed(2)}',
            subtitle: 'Payment received this week'),
      ],
    );
  }

  Widget _buildSummaryCard(
      {required String title,
      required String value,
      required String subtitle}) {
    return SizedBox(
      width: w * 0.5,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.01),
        shadowColor: Colors.black26,
        color: ColorConst.boxColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(w * 0.03)),
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.textColor),
              ),
              SizedBox(height: h * 0.01),
              Text(
                title,
                style: const TextStyle(
                  color: ColorConst.textColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget revenueStats() {
    double vehicleRent = 1500;
    double totalRevenue = vehicleRent - fleetRent;
    List<double> chartData = List.filled(7, 0.0);
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
                const Icon(Icons.insert_chart, color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Revenue Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          vehicleRent.toStringAsFixed(2),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor),
                        ),
                        SizedBox(height: w * 0.03),
                        const Text(
                          'Rent income',
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
                          fleetRent.toStringAsFixed(2),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor),
                        ),
                        SizedBox(height: w * 0.03),
                        const Text(
                          'Fleet rent',
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
                          totalRevenue.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: totalRevenue <= 0
                                  ? ColorConst.errorColor
                                  : ColorConst.successColor),
                        ),
                        SizedBox(height: w * 0.03),
                        const Text(
                          'Total revenue',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: h * 0.04),
                SizedBox(
                  height: h * 0.35,
                  child: BarChart(
                    duration: const Duration(seconds: 2),
                    BarChartData(
                      backgroundColor: ColorConst.boxColor,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(drawVerticalLine: false),
                      maxY: (chartData.reduce((a, b) => a > b ? a : b)) + 1000,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '₹ ${rod.toY.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index > 6) {
                                return const SizedBox.shrink();
                              }
                              final date = weekStart.add(Duration(days: index));
                              return Padding(
                                padding: EdgeInsets.only(top: w * 0.02),
                                child: Text(
                                  DateFormat('E').format(date),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: ColorConst.textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: w * 0.13,
                            minIncluded: false,
                            maxIncluded: false,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                    color: ColorConst.textColor),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: chartData[index],
                              color: ColorConst.primaryColor,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showRentBreakdownBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: ColorConst.boxColor,
        builder: (context) {
          return Container(
              padding: EdgeInsets.all(w * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(w * 0.03),
                      child: Text('Vehicle level calculation',
                          style: TextStyle(
                              color: ColorConst.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: w * 0.05)),
                    ),
                    SizedBox(
                      height: h * 0.01,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return ExpandablePanel(
                            theme: const ExpandableThemeData(
                                useInkWell: false,
                                iconColor: ColorConst.textColor),
                            header: _textRow(
                                label: 'AB12CD3456', value: "₹ 2100.00"),
                            collapsed: const SizedBox(),
                            expanded: Column(
                              children: [
                                _textRow(
                                    label: 'Total trips',
                                    value: 140.toString()),
                                _textRow(
                                    label: 'rent per day',
                                    value: 300.toString()),
                                _textRow(
                                    label: 'Total weekdays',
                                    value: 7.toString()),
                                _textRow(
                                    label: 'Insurance',
                                    value: 105.toStringAsFixed(2)),
                              ],
                            ));
                      },
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: h * 0.01),
                    const Divider(color: ColorConst.textColor),
                    SizedBox(height: h * 0.01),
                    _textRow(
                        label: 'Fleet rent',
                        value: fleetRent.toStringAsFixed(2)),
                    _textRow(
                        label: 'Online balance', value: 500.toStringAsFixed(2)),
                    SizedBox(height: h * 0.01),
                    Padding(
                      padding: EdgeInsets.all(w * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total rent',
                              style: TextStyle(
                                  color: ColorConst.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: w * 0.04)),
                          Text("₹ ${1705.toStringAsFixed(2)} /-",
                              style: TextStyle(
                                  color: ColorConst.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: w * 0.04)),
                        ],
                      ),
                    )
                  ],
                ),
              ));
        });
  }

  Widget buildRentList() {
    return Card(
      color: ColorConst.boxColor,
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      child: Padding(
        padding: EdgeInsets.only(top: w * 0.05, left: w * 0.03),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up_outlined,
                    color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Rent Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.textColor,
                  ),
                ),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
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
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('E').format(DateTime.now()),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          Text(
                            DateFormat('d').format(DateTime.now()),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.textColor),
                          ),
                        ],
                      ),
                    ),
                    title: const Text(
                      'AB12CD3456',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor,
                      ),
                    ),
                    subtitle: const Text(
                      'DRIVER1',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  collapsed: const SizedBox(),
                  expanded: Padding(
                    padding: EdgeInsets.all(w * 0.03),
                    child: Column(
                      children: [
                        _textRow(
                            label: 'Time',
                            value: index != 1
                                ? "${DateFormat('EEE, h:mm a').format(DateTime.now().add(const Duration(hours: 12)))} - ${DateFormat('EEE, h:mm a').format(DateTime.now())}"
                                : 'On going'),
                        _textRow(label: 'Total shift', value: 1.toString()),
                        _textRow(label: 'Total trips', value: 10.toString()),
                        _textRow(
                            label: 'Total earnings',
                            value: 2000.toStringAsFixed(2)),
                        _textRow(
                            label: 'Refund', value: 100.toStringAsFixed(2)),
                        _textRow(
                            label: 'Cash collected',
                            value: 1000.toStringAsFixed(2)),
                        _textRow(
                            label: 'Vehicle rent',
                            value: 500.toStringAsFixed(2)),
                        _textRow(
                            label: 'Balance to pay',
                            value: (-600).toStringAsFixed(2))
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
        ),
      ),
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
