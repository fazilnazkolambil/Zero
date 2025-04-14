import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/driver_model.dart';
import 'package:zero/models/rent_model.dart';
import 'package:zero/models/vehicle_model.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  DateTime weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime? weekEnd;
  bool isRentLoading = false;
  bool isVehiclesLoading = false;
  bool isDriversLoading = false;

  List<RentModel> rentModels = [];
  Future getRents() async {
    rentModels.clear();
    weekStart =
        DateTime(weekStart.year, weekStart.month, weekStart.day, 4, 0, 0);
    weekEnd = weekStart.add(const Duration(days: 6, hours: 24));
    setState(() {
      isRentLoading = true;
    });
    var rentcollection = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('rents')
        .where('start_time',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('start_time', isLessThan: Timestamp.fromDate(weekEnd!))
        .get();
    for (var rents in rentcollection.docs) {
      rentModels.add(RentModel.fromMap(rents.data()));
    }
    setState(() {
      isRentLoading = false;
    });
  }

  List<VehicleModel> vehicleModels = [];
  Future getVehicles() async {
    setState(() {
      isVehiclesLoading = true;
    });
    var vehicles = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('vehicles')
        .get();
    for (var vehicles in vehicles.docs) {
      vehicleModels.add(VehicleModel.fromJson(vehicles.data()));
    }
    setState(() {
      isVehiclesLoading = false;
    });
  }

  List<DriverModel> driverModels = [];
  Future getDrivers() async {
    setState(() {
      isDriversLoading = true;
    });
    var drivers = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('drivers')
        .get();
    for (var drivers in drivers.docs) {
      driverModels.add(DriverModel.fromJson(drivers.data()));
    }
    setState(() {
      isDriversLoading = false;
    });
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
  void initState() {
    getRents();
    getVehicles();
    getDrivers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) =>
              [appbar(), selectWeek()],
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [driverStats(), vehicleStats()],
                ),
                SizedBox(height: h * 0.01),
                revenueStats(),
                SizedBox(height: h * 0.01),
                revenueChart(),
                SizedBox(height: h * 0.01),
                buildRentList(),
              ],
            ),
          )),
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
        ));
  }

  Widget driverStats() {
    int activeDrivers =
        driverModels.where((e) => e.status.toUpperCase() == 'ACTIVE').length;
    int inActiveDrivers = driverModels.length - activeDrivers;
    List<DriverModel> onDutyDrivers =
        driverModels.where((e) => e.onRent.isNotEmpty).toList();
    return Expanded(
      child: Card(
        color: ColorConst.boxColor,
        child: Padding(
          padding: EdgeInsets.all(w * 0.02),
          child: isDriversLoading
              ? SizedBox(
                  height: h * 0.25,
                  width: w * 0.5,
                  child: const Center(
                    child: CupertinoActivityIndicator(
                      color: ColorConst.primaryColor,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drivers',
                      style: TextStyle(
                        color: ColorConst.textColor,
                        fontSize: w * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeDrivers.toString(),
                              style: TextStyle(
                                fontSize: w * 0.06,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.successColor,
                              ),
                            ),
                            Text(
                              'Active',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inActiveDrivers.toString(),
                              style: TextStyle(
                                fontSize: w * 0.06,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.errorColor,
                              ),
                            ),
                            Text(
                              'Inactive',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    onDutyDrivers.isEmpty
                        ? const Center(
                            child: Text(
                            'No drivers on duty',
                            style: TextStyle(color: ColorConst.textColor),
                          ))
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: onDutyDrivers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: h * 0.01),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: ColorConst.successColor,
                                      size: w * 0.035,
                                    ),
                                    SizedBox(width: w * 0.025),
                                    Expanded(
                                      child: Text(
                                        onDutyDrivers[index].driverName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorConst.textColor,
                                          fontSize: w * 0.04,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget vehicleStats() {
    int inUseVehicles = vehicleModels.where((e) => e.onDuty == true).length;
    int availableVehicles = vehicleModels.length - inUseVehicles;
    List<VehicleModel> onDutyVehicles =
        vehicleModels.where((e) => e.onDuty == true).toList();
    return Expanded(
      child: Card(
        color: ColorConst.boxColor,
        child: Padding(
          padding: EdgeInsets.all(w * 0.02),
          child: isVehiclesLoading
              ? SizedBox(
                  height: h * 0.25,
                  width: w * 0.5,
                  child: const Center(
                    child: CupertinoActivityIndicator(
                      color: ColorConst.primaryColor,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicles',
                      style: TextStyle(
                        color: ColorConst.textColor,
                        fontSize: w * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inUseVehicles.toString(),
                              style: TextStyle(
                                fontSize: w * 0.06,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.successColor,
                              ),
                            ),
                            Text(
                              'In use',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              availableVehicles.toString(),
                              style: TextStyle(
                                fontSize: w * 0.06,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.errorColor,
                              ),
                            ),
                            Text(
                              'Available',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    onDutyVehicles.isEmpty
                        ? const Center(
                            child: Text(
                              'No Vehicles on duty',
                              style: TextStyle(color: ColorConst.textColor),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: onDutyVehicles.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: h * 0.01),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: ColorConst.successColor,
                                      size: w * 0.035,
                                    ),
                                    SizedBox(width: w * 0.025),
                                    Expanded(
                                      child: Text(
                                        onDutyVehicles[index].vehicleNumber,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorConst.textColor,
                                          fontSize: w * 0.04,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget revenueStats() {
    // double pendingBalance
    double totalRent = rentModels
        .map((item) => item.selectedShift * item.vehicleRent)
        .reduce((rent, element) => rent + element);
    double totalToGet = rentModels.fold(0, (toGet, a) => toGet + a.totaltoPay);
    double yourEarnings = 200.54;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      color: ColorConst.boxColor,
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: isRentLoading
            ? SizedBox(
                height: h * 0.15,
                child: const Center(
                    child: CupertinoActivityIndicator(
                  color: ColorConst.primaryColor,
                )),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_chart,
                          color: ColorConst.textColor),
                      SizedBox(width: w * 0.03),
                      const Text(
                        'Revenue',
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
                            totalRent.toString(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.textColor),
                          ),
                          SizedBox(height: w * 0.03),
                          const Text(
                            'Vehicle rent',
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
                            totalToGet.toString(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorConst.textColor),
                          ),
                          SizedBox(height: w * 0.03),
                          const Text(
                            'Driver\'s balance',
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
                ],
              ),
      ),
    );
  }

  Widget revenueChart() {
    List chartData = [1051.0, 2000.0, 3500.0, 4700.0, 3825.80, 2956.0, 6847.0];
    return Card(
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      color: ColorConst.boxColor,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stacked_bar_chart_sharp,
                    color: ColorConst.textColor),
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
            SizedBox(height: h * 0.04),
            SizedBox(
              height: h * 0.35,
              child: BarChart(
                duration: Duration(seconds: 2),
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
                        reservedSize: w * 0.1,
                        minIncluded: false,
                        maxIncluded: false,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toString()[0]}k',
                            style: const TextStyle(color: ColorConst.textColor),
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
      ),
    );
  }

  Widget buildRentList() {
    return Card(
      color: ColorConst.boxColor,
      margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: w * 0.05, left: w * 0.03),
            child: Row(
              children: [
                const Icon(Icons.menu, color: ColorConst.textColor),
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
                  (rentModels[index].selectedShift *
                      rentModels[index].vehicleRent);
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
                    rentModels[index].rentStatus.toUpperCase() == 'COMPLETED'
                        ? "${DateFormat.jm().format(rentModels[index].startTime.toDate())} - ${DateFormat.jm().format(rentModels[index].endTime!.toDate())}"
                        : 'On going',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                collapsed: const SizedBox(),
                expanded: Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Column(
                    children: [
                      _textRow(
                          label: 'Total shift',
                          value: rentModels[index].selectedShift.toString()),
                      _textRow(
                          label: 'Total earnings',
                          value: rentModels[index]
                              .totalEarnings
                              .toStringAsFixed(2)),
                      _textRow(
                          label: 'Refund',
                          value: rentModels[index].refund.toStringAsFixed(2)),
                      _textRow(
                          label: 'Cash collected',
                          value: rentModels[index]
                              .cashCollected
                              .toStringAsFixed(2)),
                      _textRow(
                          label: 'Vehicle rent',
                          value: (rentModels[index].selectedShift *
                                  rentModels[index].vehicleRent)
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
