import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:zero/adminPages/screens/admin_notifications.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/vehicle_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  bool isLoading = false;
  bool isVehicleLoading = false;
  List<VehicleModel> vehicleModels = [];
  Future getVehicles() async {
    vehicleModels.clear();
    setState(() {
      isVehicleLoading = true;
    });
    var vehicles = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('vehicles')
        .where('is_deleted', isEqualTo: false)
        .get();
    for (var vehicle in vehicles.docs) {
      vehicleModels.add(VehicleModel.fromJson(vehicle.data()));
    }
    setState(() {
      isVehicleLoading = false;
    });
  }

  @override
  void initState() {
    getVehicles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  [appbar(), vehicleStats()],
              body: SingleChildScrollView(
                child: Column(
                  children: [_buildVehiclesTab()],
                ),
              ))),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      toolbarHeight: h * 0.1,
      title: const Text('Vehicle details',
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

  Widget vehicleStats() {
    int inUseVehicles = vehicleModels.where((element) => element.onDuty).length;
    int availableVehicles = vehicleModels.length - inUseVehicles;
    return SliverAppBar(
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      toolbarHeight: h * 0.1,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Card(
          color: ColorConst.boxColor,
          child: isVehicleLoading
              ? const Center(
                  child: CupertinoActivityIndicator(
                  color: ColorConst.primaryColor,
                ))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vehicleModels.length.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor),
                        ),
                        SizedBox(height: w * 0.03),
                        const Text(
                          'Vehicles',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          inUseVehicles.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor),
                        ),
                        SizedBox(height: w * 0.03),
                        const Text(
                          'In use',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          availableVehicles.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConst.textColor),
                        ),
                        SizedBox(height: w * 0.03),
                        const Text(
                          'Idle',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () => _showVehicleForm(),
                        icon: const Icon(
                          Icons.add,
                          color: ColorConst.textColor,
                        )),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildVehiclesTab() {
    List<VehicleModel> vehicles = vehicleModels;
    return isVehicleLoading
        ? const SizedBox()
        : vehicleModels.isEmpty
            ? _buildEmptyState(
                'No vehicles added yet', Icons.directions_car_rounded)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final tripCompletion = vehicles[index].weeklyTrips /
                      (vehicles[index].targetTrips > 0
                          ? vehicles[index].targetTrips
                          : 1);
                  return Card(
                      color: ColorConst.boxColor,
                      margin: EdgeInsets.symmetric(
                          horizontal: w * 0.03, vertical: w * 0.03),
                      child: ExpandablePanel(
                        theme: const ExpandableThemeData(
                            hasIcon: false, useInkWell: false),
                        collapsed: const SizedBox(),
                        expanded: Padding(
                          padding: EdgeInsets.all(w * 0.03),
                          child: Column(
                            children: [
                              if (!vehicles[index].onDuty)
                                _textRow(
                                    label: 'Last online',
                                    value: timeago.format(
                                        vehicles[index].lastDriven.toDate())),
                              _textRow(
                                  label: 'Rent per shift',
                                  value:
                                      vehicles[index].rent.toStringAsFixed(0)),
                              _textRow(
                                  label: 'Rental plan',
                                  value: vehicles[index].rentalPlan),
                              _textRow(
                                  label: 'Added on',
                                  value: DateFormat('dd-MM-yyyy').format(
                                      vehicles[index].addedOn.toDate())),
                            ],
                          ),
                        ),
                        header: ListTile(
                            contentPadding: EdgeInsets.all(w * 0.03),
                            minLeadingWidth: w * 0.15,
                            leading: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: w * 0.03),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,
                                      size: w * 0.04,
                                      color: vehicles[index].onDuty
                                          ? ColorConst.successColor
                                          : ColorConst.errorColor),
                                  SizedBox(
                                    height: h * 0.01,
                                  ),
                                  Text(
                                    vehicles[index].onDuty ? 'On duty' : 'Idle',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: ColorConst.textColor,
                                        fontSize: w * 0.04),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              vehicles[index].vehicleNumber,
                              style: const TextStyle(
                                  color: ColorConst.textColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: h * 0.01),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: tripCompletion > 1
                                          ? 1
                                          : tripCompletion,
                                      minHeight: 5,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        tripCompletion >= 1
                                            ? ColorConst.successColor
                                            : ColorConst.errorColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: h * 0.01),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${vehicles[index].weeklyTrips.toString()} / ${vehicles[index].targetTrips.toString()} trips',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: PopupMenuButton(
                              color: ColorConst.boxColor,
                              child: const Icon(
                                Icons.more_vert_rounded,
                                color: ColorConst.textColor,
                              ),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                      onTap: () => _showVehicleForm(
                                          vehicle: vehicles[index]),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: ColorConst.textColor),
                                      )),
                                  PopupMenuItem(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  backgroundColor:
                                                      ColorConst.boxColor,
                                                  title: const Text(
                                                      'Delete vehicle?',
                                                      style: TextStyle(
                                                          color: ColorConst
                                                              .textColor)),
                                                  content: const Text(
                                                    'Are you sure you want to delete this vehicle?',
                                                    style: TextStyle(
                                                        color: ColorConst
                                                            .textColor),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        style:
                                                            const ButtonStyle(
                                                          side: WidgetStatePropertyAll(
                                                              BorderSide(
                                                                  color: ColorConst
                                                                      .primaryColor)),
                                                          foregroundColor:
                                                              WidgetStatePropertyAll(
                                                                  ColorConst
                                                                      .primaryColor),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child:
                                                            const Text('No')),
                                                    TextButton(
                                                        style:
                                                            const ButtonStyle(
                                                          foregroundColor:
                                                              WidgetStatePropertyAll(
                                                                  ColorConst
                                                                      .backgroundColor),
                                                          backgroundColor:
                                                              WidgetStatePropertyAll(
                                                                  ColorConst
                                                                      .primaryColor),
                                                        ),
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'organisations')
                                                              .doc(currentUser!
                                                                  .organisationId)
                                                              .collection(
                                                                  'vehicles')
                                                              .doc(vehicles[
                                                                      index]
                                                                  .vehicleId)
                                                              .update({
                                                            'is_deleted':
                                                                vehicles[index]
                                                                        .isDeleted
                                                                    ? false
                                                                    : true,
                                                            'status': 'DROPPED',
                                                            'dropped_on':
                                                                Timestamp.now()
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'Vehicle deleted!',
                                                              gravity:
                                                                  ToastGravity
                                                                      .TOP,
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT);
                                                          Navigator.pop(
                                                              context);
                                                          getVehicles();
                                                        },
                                                        child:
                                                            const Text('Yes')),
                                                  ],
                                                ));
                                      },
                                      child: const Text('Delete',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: ColorConst.textColor))),
                                ];
                              },
                            )),
                      ));
                });
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return SizedBox(
      height: h * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap the + button to add new',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleForm({VehicleModel? vehicle}) {
    final isEditing = vehicle != null;
    final plateController =
        TextEditingController(text: isEditing ? vehicle.vehicleNumber : '');
    final rentController =
        TextEditingController(text: isEditing ? vehicle.rent.toString() : '');
    final targetTrips = TextEditingController(
        text: isEditing ? vehicle.targetTrips.toString() : '');
    final formkey = GlobalKey<FormState>();
    String? rentalPlan = isEditing ? vehicle.rentalPlan : null;
    List plans = ['plan_wagonr'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorConst.boxColor,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Vehicle' : 'Add New Vehicle',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorConst.textColor),
                      ),
                      SizedBox(height: h * 0.05),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(w * 0.02),
                            border: Border.all(color: Colors.grey.shade800)),
                        child: DropdownButton<String>(
                          hint: const Text(
                            'Select rental plans',
                            style: TextStyle(color: Colors.grey),
                          ),
                          isExpanded: true,
                          dropdownColor: ColorConst.boxColor,
                          value: rentalPlan,
                          padding: EdgeInsets.symmetric(
                              horizontal: w * 0.05, vertical: w * 0.02),
                          underline: const SizedBox(),
                          items: List.generate(
                            plans.length,
                            (index) {
                              return DropdownMenuItem<String>(
                                value: plans[index],
                                child: Text(
                                  plans[index],
                                  style: const TextStyle(
                                      color: ColorConst.textColor),
                                ),
                              );
                            },
                          ),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                rentalPlan = value;
                                if (value == 'plan_wagonr') {
                                  rentController.text = '500';
                                }
                                getVehicles();
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      TextFormField(
                        controller: plateController,
                        decoration: InputDecoration(
                          labelText: 'Number plate',
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(w * 0.05),
                            child: const Icon(
                              Icons.time_to_leave_outlined,
                              color: ColorConst.primaryColor,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorConst.primaryColor),
                          ),
                          filled: true,
                          fillColor: ColorConst.boxColor,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: ColorConst.textColor),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.characters,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter vehicle's number plate";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: h * 0.02),
                      TextFormField(
                        controller: rentController,
                        decoration: InputDecoration(
                          labelText: 'Rent amount',
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(w * 0.05),
                            child: Text(
                              '₹',
                              style: TextStyle(
                                  color: ColorConst.primaryColor,
                                  fontSize: w * 0.06),
                            ),
                          ),
                          suffix: const Text('12 hrs'),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorConst.primaryColor),
                          ),
                          filled: true,
                          fillColor: ColorConst.boxColor,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: ColorConst.textColor),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter the rent amount";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: h * 0.02),
                      TextFormField(
                        controller: targetTrips,
                        decoration: InputDecoration(
                          labelText: 'Target',
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(w * 0.05),
                            child: const Icon(Icons.av_timer_sharp,
                                color: ColorConst.primaryColor),
                          ),
                          suffix: const Text('Trips'),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorConst.primaryColor),
                          ),
                          filled: true,
                          fillColor: ColorConst.boxColor,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: ColorConst.textColor),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter the target trips";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: h * 0.02),
                      isLoading
                          ? Padding(
                              padding: EdgeInsets.only(right: w * 0.15),
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: CupertinoActivityIndicator(
                                  color: ColorConst.primaryColor,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: ColorConst.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          ColorConst.primaryColor)),
                                  onPressed: () async {
                                    if (formkey.currentState!.validate() &&
                                        rentalPlan != null) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (isEditing) {
                                        await FirebaseFirestore.instance
                                            .collection('organisations')
                                            .doc(currentUser!.organisationId)
                                            .collection('vehicles')
                                            .doc(vehicle.vehicleId)
                                            .update({
                                          'vehicle_number':
                                              plateController.text.trim(),
                                          'rent':
                                              double.parse(rentController.text),
                                          'target_trips':
                                              int.parse(targetTrips.text),
                                          'rental_plan': rentalPlan.toString()
                                        });
                                        setState(() {
                                          isLoading = false;
                                        });
                                        await getVehicles();
                                        Navigator.pop(context);
                                      } else {
                                        var vehicleCollection =
                                            await FirebaseFirestore.instance
                                                .collection('organisations')
                                                .doc(
                                                    currentUser!.organisationId)
                                                .collection('vehicles')
                                                .get();
                                        var data = vehicleCollection.docs.where(
                                            (element) =>
                                                element['vehicle_number'] ==
                                                plateController.text);
                                        if (data.isNotEmpty) {
                                          Fluttertoast.showToast(
                                            msg: "Vehicle already exist!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                          );
                                          setState(() {
                                            isLoading = false;
                                          });
                                        } else {
                                          String vehicleId =
                                              'vehicle${vehicleCollection.size}';
                                          await FirebaseFirestore.instance
                                              .collection('organisations')
                                              .doc(currentUser!.organisationId)
                                              .collection('vehicles')
                                              .doc(vehicleId)
                                              .set(VehicleModel(
                                                      rent: double.parse(
                                                          rentController.text),
                                                      vehicleNumber:
                                                          plateController.text,
                                                      driver: '',
                                                      startTime:
                                                          Timestamp.now(),
                                                      lastDriven:
                                                          Timestamp.now(),
                                                      addedOn: Timestamp.now(),
                                                      onDuty: false,
                                                      status: 'ACTIVE',
                                                      vehicleId: vehicleId,
                                                      isDeleted: false,
                                                      totalTrips: 0,
                                                      targetTrips: int.parse(
                                                          targetTrips.text),
                                                      weeklyTrips: 0,
                                                      rentalPlan:
                                                          rentalPlan.toString())
                                                  .toJson());
                                          Fluttertoast.showToast(
                                            msg: "Vehicle added successfully!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                          );
                                          setState(() {
                                            isLoading = false;
                                          });
                                          await getVehicles();
                                          Navigator.pop(context);
                                        }
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Enter required details!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                      );
                                    }
                                  },
                                  child: Text(
                                    isEditing ? 'Update' : 'Add car',
                                    style: const TextStyle(
                                        color: ColorConst.backgroundColor),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
