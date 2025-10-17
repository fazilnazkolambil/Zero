import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/dutyPages/duty_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/user_model.dart';

class DutyPage extends StatelessWidget {
  final DutyController controller = Get.isRegistered()
      ? Get.find<DutyController>()
      : Get.put(DutyController());
  DutyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DriverOnDuty duty = currentUser!.onDuty!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: controller.formkey,
          child: Column(children: [
            Text(
              duty.vehicleNumber,
              style: Get.textTheme.titleLarge,
            ),
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidgets().textRow(
                        label: 'Started time',
                        value: DateFormat('EEE dd/MMM, hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                duty.startTime))),
                    // Text(
                    //     'Started time : ${DateFormat('EEE dd/MMM, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(duty.startTime))}'),
                    CustomWidgets().textRow(
                        label: 'End by',
                        value:
                            '${DateFormat('EEE dd/MMM, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(duty.startTime).add(Duration(hours: duty.selectedShift * 12)))} (${duty.selectedShift} Shift)'),
                  ],
                ),
              ),
            ),
            // if (addShift)
            //   Container(
            //     width: w,
            //     margin: EdgeInsets.symmetric(vertical: w * 0.02),
            //     padding: EdgeInsets.all(w * 0.02),
            //     decoration: BoxDecoration(
            //         color: ColorConst.backgroundColor,
            //         borderRadius: BorderRadius.circular(w * 0.03),
            //         boxShadow: [
            //           BoxShadow(
            //               color: ColorConst.errorColor.withValues(alpha: 0.5),
            //               blurRadius: 4,
            //               spreadRadius: 1)
            //         ]),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         const Icon(
            //           Icons.info_outline,
            //           color: Colors.grey,
            //         ),
            //         SizedBox(
            //           width: w * 0.03,
            //         ),
            //         Expanded(
            //           child: Column(
            //             children: [
            //               const Text(
            //                 'It has been more than 2 hours of the selected shift. 1 extra shift will be added',
            //                 textAlign: TextAlign.start,
            //                 style: TextStyle(color: Colors.grey),
            //               ),
            //               SizedBox(height: h * 0.01),
            //               Text(
            //                 'End by : ${DateFormat('EEE dd, hh:mm a').format(rentModel!.startTime.toDate().add(Duration(hours: (rentModel!.selectedShift + 1) * 12)))} (${rentModel!.selectedShift + 1} Shift)',
            //                 textAlign: TextAlign.start,
            //                 style: const TextStyle(
            //                     color: ColorConst.textColor,
            //                     fontWeight: FontWeight.bold),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // SizedBox(height: h * 0.02),

            _textField(
              textInputType: TextInputType.number,
              labelText: 'Total trips',
              textController: controller.totalTripsController,
              maxLength: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total trips';
                } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Only numbers are allowed';
                }
                return null;
              },
            ),
            _textField(
              textInputType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelText: 'Total earnings',
              textController: controller.totalEarningController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total earnings';
                } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                  return 'Only numbers are allowed';
                }
                return null;
              },
            ),
            _textField(
              textInputType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelText: 'Refund',
              textController: controller.refundController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter refund';
                } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                  return 'Only numbers are allowed';
                }
                return null;
              },
            ),
            _textField(
              textInputType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelText: 'Cash collected',
              textController: controller.cashCollectedController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the cash collected';
                } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                  return 'Only numbers are allowed';
                }
                return null;
              },
            ),

            _textField(
              textInputType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelText: 'Fuel Expense (optional)',
              textController: controller.fuelExpenseController,
              validator: (value) {
                if (!RegExp(r'^\d*\.?\d*$').hasMatch(value!)) {
                  return 'Only numbers are allowed';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromWidth(250),
                    backgroundColor: ColorConst.primaryColor,
                    foregroundColor: Colors.black),
                onLongPress: () async {
                  if (controller.formkey.currentState!.validate()) {
                    await controller.endDuty(duty: duty);
                    if (controller.finalValues.isNotEmpty) {
                      _showSummary();
                    }
                  }
                },
                onPressed: () {
                  if (controller.formkey.currentState!.validate()) {
                    Fluttertoast.showToast(
                        msg: 'Long press to end the duty',
                        gravity: ToastGravity.SNACKBAR);
                  }
                },
                child: const Text("End shift")),
            // SizedBox(height: h * 0.02),
            // if (!isLate) ...[
            //   ElevatedButton(
            //       style: ButtonStyle(
            //         side: const WidgetStatePropertyAll(
            //             BorderSide(color: ColorConst.primaryColor)),
            //         backgroundColor:
            //             const WidgetStatePropertyAll(ColorConst.boxColor),
            //         fixedSize: WidgetStatePropertyAll(Size(w, h * 0.06)),
            //         foregroundColor:
            //             const WidgetStatePropertyAll(ColorConst.primaryColor),
            //       ),
            //       onPressed: () async {
            //         showDialog(
            //           context: context,
            //           builder: (context) => AlertDialog(
            //             backgroundColor: ColorConst.boxColor,
            //             title: const Text('Add extra shift?',
            //                 style: TextStyle(color: ColorConst.primaryColor)),
            //             content: Text(
            //                 'Currently selected ${rentModel!.selectedShift} shift. Add an extra 12 hrs?',
            //                 style:
            //                     const TextStyle(color: ColorConst.textColor)),
            //             actions: [
            //               TextButton(
            //                   style: const ButtonStyle(
            //                     side: WidgetStatePropertyAll(
            //                         BorderSide(color: ColorConst.primaryColor)),
            //                     foregroundColor: WidgetStatePropertyAll(
            //                         ColorConst.primaryColor),
            //                   ),
            //                   onPressed: () => Navigator.pop(context),
            //                   child: const Text('No')),
            //               TextButton(
            //                   style: const ButtonStyle(
            //                     foregroundColor: WidgetStatePropertyAll(
            //                         ColorConst.backgroundColor),
            //                     backgroundColor: WidgetStatePropertyAll(
            //                         ColorConst.primaryColor),
            //                   ),
            //                   onPressed: () async {
            //                     await FirebaseFirestore.instance
            //                         .collection('organisations')
            //                         .doc(currentUser!.organisationId)
            //                         .collection('rents')
            //                         .doc(rentModel!.rentId)
            //                         .update({
            //                       'selected_shift': FieldValue.increment(1)
            //                     });
            //                     Fluttertoast.showToast(
            //                       msg: "Extra shift added",
            //                       toastLength: Toast.LENGTH_SHORT,
            //                       gravity: ToastGravity.TOP,
            //                     );
            //                     Navigator.pop(context);
            //                     await getDriverDetails();
            //                   },
            //                   child: const Text('Yes')),
            //             ],
            //           ),
            //         );
            //       },
            //       child: const Text('Add an extra shift')),
            //   SizedBox(
            //     height: h * 0.02,
            //   )
            // ],
            // if (Timestamp.now()
            //         .toDate()
            //         .difference(rentModel!.startTime.toDate())
            //         .inHours <
            //     2)
            //   ElevatedButton(
            //       style: ButtonStyle(
            //         side: const WidgetStatePropertyAll(
            //             BorderSide(color: ColorConst.primaryColor)),
            //         backgroundColor:
            //             const WidgetStatePropertyAll(ColorConst.boxColor),
            //         fixedSize: WidgetStatePropertyAll(Size(w, h * 0.06)),
            //         foregroundColor:
            //             const WidgetStatePropertyAll(ColorConst.primaryColor),
            //       ),
            //       onPressed: () async {
            //         if (formkey.currentState!.validate()) {
            //           TextEditingController reasonController =
            //               TextEditingController();
            //           showDialog(
            //             context: context,
            //             builder: (context) => AlertDialog(
            //               backgroundColor: ColorConst.boxColor,
            //               title: const Text('Cancel shift?',
            //                   style: TextStyle(color: ColorConst.primaryColor)),
            //               content: TextField(
            //                 controller: reasonController,
            //                 style: const TextStyle(color: ColorConst.textColor),
            //                 decoration: const InputDecoration(
            //                     border: OutlineInputBorder(),
            //                     focusedBorder: OutlineInputBorder(
            //                       borderSide: BorderSide(
            //                           color: ColorConst.primaryColor),
            //                     ),
            //                     filled: true,
            //                     fillColor: ColorConst.boxColor,
            //                     labelStyle:
            //                         TextStyle(color: ColorConst.textColor),
            //                     labelText: 'Reason'),
            //               ),
            //               actions: [
            //                 TextButton(
            //                     style: const ButtonStyle(
            //                       side: WidgetStatePropertyAll(BorderSide(
            //                           color: ColorConst.primaryColor)),
            //                       foregroundColor: WidgetStatePropertyAll(
            //                           ColorConst.primaryColor),
            //                     ),
            //                     onPressed: () => Navigator.pop(context),
            //                     child: const Text('No')),
            //                 TextButton(
            //                     style: const ButtonStyle(
            //                       foregroundColor: WidgetStatePropertyAll(
            //                           ColorConst.backgroundColor),
            //                       backgroundColor: WidgetStatePropertyAll(
            //                           ColorConst.primaryColor),
            //                     ),
            //                     onPressed: () async {
            //                       if (reasonController.text.isEmpty) {
            //                         Fluttertoast.showToast(
            //                           msg: "Enter the reason!",
            //                           toastLength: Toast.LENGTH_SHORT,
            //                           gravity: ToastGravity.TOP,
            //                         );
            //                       } else {
            //                         await FirebaseFirestore.instance
            //                             .collection('organisations')
            //                             .doc(currentUser!.organisationId)
            //                             .collection('rents')
            //                             .doc(rentModel!.rentId)
            //                             .update({
            //                           'end_time': Timestamp.now(),
            //                           'total_trips': FieldValue.increment(
            //                               int.parse(totalTripsController.text)),
            //                           'total_earnings': FieldValue.increment(
            //                               double.parse(
            //                                   totalEarningscontroller.text)),
            //                           'cash_collected': FieldValue.increment(
            //                               double.parse(
            //                                   cashCollectedcontroller.text)),
            //                           'refund': FieldValue.increment(
            //                               double.parse(refundController.text)),
            //                           'total_to_pay': 0,
            //                           'rent_status':
            //                               'canceled:${reasonController.text}',
            //                           'fuel_expense':
            //                               fuelExpensesController.text.isEmpty
            //                                   ? 0
            //                                   : double.parse(
            //                                       fuelExpensesController.text)
            //                         });
            //                         await FirebaseFirestore.instance
            //                             .collection('organisations')
            //                             .doc(currentUser!.organisationId)
            //                             .collection('vehicles')
            //                             .doc(rentModel!.vehicleId)
            //                             .update({
            //                           'on_duty': false,
            //                           'start_time': Timestamp.now(),
            //                           'last_driven': Timestamp.now(),
            //                           'selected_shift': 0,
            //                           'total_trips': FieldValue.increment(
            //                               int.parse(totalTripsController.text)),
            //                         });
            //                         await FirebaseFirestore.instance
            //                             .collection('organisations')
            //                             .doc(currentUser!.organisationId)
            //                             .collection('drivers')
            //                             .doc(currentUser!.userId)
            //                             .update({
            //                           'on_rent': '',
            //                           'cash_collected': FieldValue.increment(
            //                               double.parse(
            //                                   cashCollectedcontroller.text)),
            //                           'total_earnings': FieldValue.increment(
            //                               double.parse(
            //                                   totalEarningscontroller.text)),
            //                           'refund': FieldValue.increment(
            //                               double.parse(refundController.text)),
            //                           'total_trips': FieldValue.increment(
            //                               int.parse(totalTripsController.text)),
            //                           'fuel_expense': FieldValue.increment(
            //                               fuelExpensesController.text.isEmpty
            //                                   ? 0
            //                                   : double.parse(
            //                                       fuelExpensesController.text)),
            //                         });
            //                         Fluttertoast.showToast(
            //                           msg: "Shift canceled!",
            //                           toastLength: Toast.LENGTH_SHORT,
            //                           gravity: ToastGravity.TOP,
            //                         );
            //                         Navigator.pop(context);
            //                         await getDriverDetails();
            //                       }
            //                     },
            //                     child: const Text('Yes')),
            //               ],
            //             ),
            //           );
            //         } else {
            //           Fluttertoast.showToast(
            //             msg: "Fill the required fields!",
            //             toastLength: Toast.LENGTH_SHORT,
            //             gravity: ToastGravity.TOP,
            //           );
            //         }
            //       },
            //       child: const Text("Cancel shift")),
          ]),
        ),
      ),
    );
  }

  Widget _textField({
    String? Function(String?)? validator,
    required TextInputType textInputType,
    required String labelText,
    required TextEditingController textController,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        controller: textController,
        style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
        cursorColor: Colors.white,
        textInputAction: TextInputAction.next,
        keyboardType: textInputType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        validator: validator,
        maxLength: maxLength,
        decoration: InputDecoration(
            counterText: '',
            fillColor: Colors.white12,
            label: Text(labelText),
            labelStyle:
                Get.textTheme.bodyMedium!.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showSummary() {
    double topay = controller.finalValues['total_to_pay'];
    Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: const Text('Duty summary'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomWidgets().textRow(
                    label: 'Total earnings',
                    value: controller.totalEarningController.text),
                CustomWidgets().textRow(
                    label: 'Refund', value: controller.refundController.text),
                CustomWidgets().textRow(
                    label: 'Cash collected',
                    value: controller.cashCollectedController.text),
                const Divider(color: Colors.grey),
                CustomWidgets().textRow(
                    label: 'Other fees (-14%)',
                    value:
                        "-${controller.finalValues['other_fees'].toStringAsFixed(2)}"),
                CustomWidgets().textRow(
                    label: 'Vehicle rent',
                    value: "-${controller.finalValues['vehicle_rent']}"),
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02, vertical: w * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(topay < 0 ? 'TO PAY' : 'BALANCE'),
                      Text(
                        topay.toStringAsFixed(2),
                        style: Get.textTheme.bodyMedium!.copyWith(
                            color: topay < 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromWidth(200),
                        backgroundColor: ColorConst.primaryColor,
                        foregroundColor: Colors.black),
                    onPressed: () {
                      Get.offAllNamed('/splash');
                    },
                    child: const Text('Done'))
              ],
            ),
          ),
        ));
  }
}
