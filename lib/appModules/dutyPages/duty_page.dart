import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/dutyPages/duty_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/customWidgets/slider_widget.dart';
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
                    CustomWidgets().textRow(
                        label: 'End by',
                        value:
                            '${DateFormat('EEE dd/MMM, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(duty.startTime).add(Duration(hours: duty.selectedShift * 12)))} (${duty.selectedShift} Shift)'),
                  ],
                ),
              ),
            ),
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
            SlideToConfirm(
              label: 'End duty',
              onConfirmed: () async {
                bool isDriverReached = await controller.isDriverinLocation();
                if (!controller.formkey.currentState!.validate()) {
                  return false;
                } else if (!isDriverReached) {
                  Fluttertoast.showToast(
                      msg:
                          'You\'re not at the location!. Go to your fleet parking location before ending duty.',
                      backgroundColor: Colors.red);
                  return false;
                } else {
                  await controller.endDuty(duty: duty);
                  if (controller.finalValues.isNotEmpty) {
                    _showSummary();
                  }
                  return true;
                }
              },
            ),
            const SizedBox(height: 20),
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
