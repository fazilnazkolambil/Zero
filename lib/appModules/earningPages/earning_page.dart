import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/earningPages/earnings_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zero/core/global_variables.dart';

class EarningPage extends StatelessWidget {
  final EarningsController controller = Get.isRegistered()
      ? Get.find<EarningsController>()
      : Get.put(EarningsController());
  EarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            tripCompletiontracking(),
            const SizedBox(height: 10),
            _chartView(),
            const SizedBox(height: 10),
            _weeklyStats(),
            const SizedBox(height: 10),
            stateBreakdown(),
            const SizedBox(height: 10),
            buildRentList()
          ],
        ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      flexibleSpace: FlexibleSpaceBar(
          background: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 18,
              ),
              onPressed: controller.previousWeek,
            ),
            Text(controller.getWeekRange()),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              onPressed: controller.nextWeek,
              color:
                  DateTime.now().difference(controller.weekStart.value).inDays <
                          7
                      ? Colors.grey
                      : Colors.white,
            ),
          ],
        ),
      )),
    );
  }

  Widget tripCompletiontracking() {
    // int totalTrips = rentModels.fold(0, (trips, a) => trips + a.totalTrips);
    // int totalShifts = rentModels.fold(0, (shift, a) => shift + a.selectedShift);
    // int targetTrips = currentDriver!.targetTrips * totalShifts;
    int totalTrips = 20;
    int totalShifts = 5;
    int targetTrips = 10 * totalShifts;
    final tripCompletion = totalTrips / (targetTrips > 0 ? targetTrips : 1);
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart),
                SizedBox(width: w * 0.03),
                Text('Trip completion',
                    style: Get.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: h * 0.02),
            Padding(
              padding: EdgeInsets.only(top: h * 0.01),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: tripCompletion > 1 ? 1 : tripCompletion,
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tripCompletion >= 1 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${totalTrips.toString()} / ${targetTrips.toString()} trips',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartView() {
    List<double> chartData = List.filled(7, 2230.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: h * 0.3,
            width: w,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(
                  show: false,
                ),
                // maxY: (chartData.reduce((a, b) => a > b ? a : b)),
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
                      reservedSize: 45,
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index > 6) {
                          return const SizedBox.shrink();
                        }
                        final date = controller.weekStart.value
                            .add(Duration(days: index));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd').format(date),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('E').format(date),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      minIncluded: true,
                      maxIncluded: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0));
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
                        color: Get.theme.primaryColor,
                        width: 30,
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyStats() {
    int totalShifts = 5;
    int totalTrips = 45;
    double totalRent = 1500;
    double fuelExpenses = 1200;
    double totalEarnings = 3500;
    double balance = 450;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly stats',
            style: Get.textTheme.headlineSmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStaticValues(value: totalShifts, label: 'Total duties'),
              _buildStaticValues(value: totalTrips, label: 'Total trips'),
              _buildStaticValues(value: totalEarnings, label: 'Total earnings'),
            ],
          ),
          const SizedBox(
            height: 20,
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStaticValues(value: totalRent, label: 'Total rent'),
              _buildStaticValues(value: fuelExpenses, label: 'Fuel expenses'),
              _buildStaticValues(value: balance, label: 'Total balance'),
            ],
          ),
        ],
      ),
    );
  }

  _buildStaticValues({required num value, required String label}) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Get.textTheme.bodyLarge!,
        ),
        const SizedBox(height: 5),
        Text(label,
            style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget stateBreakdown() {
    //  double totalEarnings =
    //     rentModels.fold(0, (earnings, a) => earnings + a.totalEarnings);
    // double totalRefund = rentModels.fold(0, (refund, a) => refund + a.refund);
    // double totalCashCollected = rentModels.fold(
    //     0, (cashCollected, a) => cashCollected + a.cashCollected);
    // double totalRent = rentModels
    //     .map((item) => item.selectedShift * item.vehicleRent)
    //     .reduce((rent, element) => rent + element);
    double totalEarnings = 3500;
    double totalRefund = 252;
    double totalCashCollected = 3500;
    double totalRent = 2000;
    double balance = totalEarnings + totalRefund - totalCashCollected;
    double toPay = balance - totalRent;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rent details',
              style: Get.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          CustomWidgets().textRow(
              label: 'Total earnings',
              value: '₹ ${totalEarnings.toStringAsFixed(2)}'),
          CustomWidgets().textRow(
              label: 'Refund', value: '₹ ${totalRefund.toStringAsFixed(2)}'),
          CustomWidgets().textRow(
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
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹ ${balance.toStringAsFixed(2)}',
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          CustomWidgets().textRow(
              label: 'Platform fees', value: '-${250.toStringAsFixed(2)}'),
          CustomWidgets().textRow(
              label: 'Vehicle rent', value: '-${totalRent.toStringAsFixed(2)}'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(toPay > 0 ? 'To get' : 'To pay',
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
              Text('₹ ${(-toPay).toStringAsFixed(2)}',
                  style: Get.textTheme.bodyLarge!.copyWith(
                      color: toPay > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRentList() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly activity',
              style: Get.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          ListView.separated(
            padding: EdgeInsets.only(top: h * 0.02),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              // DateTime date = rentModels[index].startTime.toDate();
              DateTime date = DateTime.now();

              return ExpandablePanel(
                theme: const ExpandableThemeData(
                  useInkWell: false,
                  iconSize: 15,
                ),
                header: ListTile(
                  leading: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
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
                        ),
                      ],
                    ),
                  ),
                  title: Text('KA03AM3257'),
                  subtitle: Text(
                    // "${DateFormat.jm().format(rentModels[index].startTime.toDate())} - ${DateFormat.jm().format(rentModels[index].endTime!.toDate())}",
                    '04:00 AM - 04:00 PM',
                    style: const TextStyle(color: Colors.grey),
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
                      CustomWidgets()
                          .textRow(label: 'Total shift', value: 2.toString()),
                      CustomWidgets().textRow(
                          label: 'Total earnings',
                          value: 3500.toStringAsFixed(2)),
                      CustomWidgets().textRow(
                          label: 'Refund', value: 252.toStringAsFixed(2)),
                      CustomWidgets().textRow(
                          label: 'Cash collected',
                          value: 1500.toStringAsFixed(2)),
                      CustomWidgets().textRow(
                          label: 'Fuel expense', value: 750.toStringAsFixed(2)),
                      CustomWidgets().textRow(
                          label: 'Vehicle rent',
                          value: (2 * 500).toStringAsFixed(2)),
                      CustomWidgets().textRow(
                          label: 'To pay', value: (450).toStringAsFixed(2)),
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
    );
  }
}
