import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/dashboard/dashboard_controller.dart';
import 'package:zero/appModules/transactions/transaction_controller.dart';
import 'package:zero/core/global_variables.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController dashboardController = Get.isRegistered()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());
  final TransactionController transactionController = Get.isRegistered()
      ? Get.find<TransactionController>()
      : Get.put(TransactionController());
  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
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
                    onPressed: dashboardController.previousWeek),
                Text(dashboardController.getWeekRange()),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: dashboardController.nextWeek,
                  color: DateTime.now()
                              .difference(dashboardController.weekStart.value)
                              .inDays <
                          7
                      ? Colors.grey
                      : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _statCard(
                        value:
                            transactionController.onlinePaid.value.toString(),
                        title: 'Cash received',
                        subtitle: 'Total cash received',
                        color: Colors.green),
                  ),
                ),
                Expanded(
                  child: _statCard(
                      value: '1500.00',
                      title: 'Pending',
                      subtitle: 'Drivers to pay',
                      color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _incomeBreakdown(),
            const SizedBox(height: 10),
            _rentBreakdown()
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      {required String title,
      required String value,
      required Color color,
      required String subtitle}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(value,
                style: Get.textTheme.headlineSmall!.copyWith(color: color)),
            const SizedBox(height: 5),
            Text(title, style: Get.textTheme.bodyLarge!),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _incomeBreakdown() {
    double onlineAmount = 2000;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart_sharp),
                    SizedBox(width: 10),
                    Text('Income breakdown'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetails(value: 1500, label: 'Cash received'),
                _buildDetails(
                    value: 1200,
                    label:
                        onlineAmount >= 0 ? 'Online balance' : 'Cash balance'),
                _buildDetails(value: 1800, label: 'Total revenue'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rentBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up_outlined),
                const SizedBox(width: 10),
                const Text('Rent Details'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetails(value: 5000, label: 'Earnnings'),
                _buildDetails(value: 1200, label: 'Tolls'),
                _buildDetails(value: 6500, label: 'Cash collected'),
              ],
            ),
            TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('View activities', style: Get.textTheme.bodySmall),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.play_arrow,
                      size: Get.textTheme.bodySmall!.fontSize,
                      color: Get.textTheme.bodySmall!.color,
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _rentList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        // DateTime date = rentModels[index].startTime.toDate();
        DateTime date = DateTime.now();

        return ExpandablePanel(
          theme: ExpandableThemeData(
            useInkWell: false,
            iconColor: Get.textTheme.bodyLarge!.color,
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
                    DateFormat('E').format(date),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(date),
                  ),
                ],
              ),
            ),
            title: Text('KA03AM3257 '),
            subtitle: Text(
              'Driver name',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          collapsed: const SizedBox(),
          expanded: Padding(
            padding: EdgeInsets.all(w * 0.03),
            child: Column(
              children: [
                CustomWidgets().textRow(
                  label: 'Time',
                  value:
                      // rentModels[index].rentStatus.toUpperCase() ==
                      //         'COMPLETED'
                      //     ? "${DateFormat('EEE, h:mm a').format(rentModels[index].startTime.toDate())} - ${DateFormat('EEE, h:mm a').format(rentModels[index].endTime!.toDate())}"
                      //     :
                      '${DateFormat('EEE, h:mm a').format(date)} - On going',
                ),
                CustomWidgets().textRow(
                  label: 'Total shift',
                  value: 2.toString(),
                ),
                CustomWidgets().textRow(
                  label: 'Total trips',
                  value: 10.toString(),
                ),
                CustomWidgets().textRow(
                  label: 'Total earnings',
                  value: 3500.toStringAsFixed(2),
                ),
                CustomWidgets().textRow(
                  label: 'Toll',
                  value: 250.toStringAsFixed(2),
                ),
                CustomWidgets().textRow(
                  label: 'Cash collected',
                  value: 1500.toStringAsFixed(2),
                ),
                CustomWidgets().textRow(
                  label: 'Vehicle rent',
                  value: (2 * 500).toStringAsFixed(2),
                ),
                CustomWidgets().textRow(
                  label: 'Balance to pay',
                  value: (-500).toStringAsFixed(2),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(color: Colors.grey[700]),
    );
  }

  Widget _buildDetails({required num value, required String label}) {
    return Column(
      children: [
        Text(value.toStringAsFixed(2)),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
