import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/driver_bottom_page.dart';

class RazorPayBottomSheet extends StatefulWidget {
  final double amount;
  const RazorPayBottomSheet({super.key, required this.amount});

  @override
  State<RazorPayBottomSheet> createState() => _RazorPayBottomSheetState();
}

class _RazorPayBottomSheetState extends State<RazorPayBottomSheet> {
  late Razorpay _razorpay;
  TextEditingController amountController = TextEditingController();
  String paymentId = '';
  payments() async {
    var payments = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .collection('payments')
        .get();
    paymentId = 'zer0transactions${payments.size}';
  }

  @override
  void initState() {
    super.initState();
    payments();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    amountController.text =
        widget.amount > 0 ? widget.amount.toStringAsFixed(2) : '0';
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout() async {
    print(paymentId);
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .collection('payments')
        .doc(paymentId)
        .set({
      'amount': double.parse(amountController.text),
      'payment_time': Timestamp.now(),
      'driver_id': currentDriver!.driverId,
      'driver_name': currentDriver!.driverName,
      'payment_method': 'ONLINE',
      'status': 'PENDING',
      'transaction_id': paymentId,
    });
    var options = {
      'key': 'rzp_test_JhsArnUhSwrXWP',
      'amount': (double.parse(amountController.text) * 100).toInt(),
      'name': 'Zero App',
      'description':
          '${amountController.text} paid by ${currentUser!.userName}. Balance ${currentDriver!.wallet + double.parse(amountController.text)}',
      'prefill': {
        'contact': currentDriver!.mobileNumber,
        'email': '${currentDriver!.driverName}@zero.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

//TODO: INITIATE THE TRANSACTION COLLECTION WHEN TAPPING THE  BUTTON

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('PAYMNT ID ON SUCESS == $paymentId');
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .collection('drivers')
        .doc(currentUser!.userId)
        .update({
      'wallet': FieldValue.increment(double.parse(amountController.text)),
    });
    // var payments = await FirebaseFirestore.instance
    //     .collection('organisations')
    //     .doc(currentDriver!.organisationId)
    //     .collection('payments')
    //     .get();
    // String paymentId = 'zer0transactions${payments.size}';
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .collection('payments')
        .doc(paymentId)
        .update({
      // 'amount': double.parse(amountController.text),
      // 'payment_time': Timestamp.now(),
      // 'driver_id': currentDriver!.driverId,
      // 'driver_name': currentDriver!.driverName,
      // 'payment_method': 'ONLINE',
      'status': 'SUCCESS',
      // 'transaction_id': paymentId,
    });
    Fluttertoast.showToast(msg: 'Payment successfull');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DriverBottomBar(),
      ),
      (route) => false,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .collection('payments')
        .doc(paymentId)
        .update({
      'status': 'REJECTED',
    });
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "External Wallet Selected: ${response.walletName}");
  }

  void cashPayment() async {
    var payments = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .collection('payments')
        .get();
    String paymentId = 'zer0transactions${payments.size}';
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .collection('payments')
        .doc(paymentId)
        .set({
      'amount': double.parse(amountController.text),
      'payment_time': Timestamp.now(),
      'driver_id': currentDriver!.driverId,
      'driver_name': currentDriver!.driverName,
      'payment_method': 'CASH',
      'status': 'PENDING',
      'transaction_id': paymentId,
    });
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentDriver!.organisationId)
        .update({
      'notifications': FieldValue.arrayUnion([
        {
          'title': 'Payment request',
          'payment_id': paymentId,
          'driver_name': currentDriver!.driverName,
          'driver_id': currentDriver!.driverId,
          'read': false,
          'time': Timestamp.now(),
          'amount': double.parse(amountController.text)
        }
      ])
    });
    Fluttertoast.showToast(msg: 'Payment requested successfully!');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DriverBottomBar(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: w * 0.03,
        right: w * 0.03,
        left: w * 0.03,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: h * 0.01, horizontal: w * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment',
                    style: TextStyle(
                        color: ColorConst.textColor,
                        fontSize: w * 0.05,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: ColorConst.textColor,
                      ))
                ],
              ),
            ),
            SizedBox(height: h * 0.02),
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: 'Enter the amount',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(w * 0.05),
                  child: Text('₹',
                      style: TextStyle(
                          color: ColorConst.primaryColor, fontSize: w * 0.06)),
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConst.primaryColor),
                ),
                filled: true,
                fillColor: ColorConst.boxColor,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: ColorConst.textColor),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(w * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              WidgetStatePropertyAll(Size(w * 0.4, h * 0.03)),
                          elevation: const WidgetStatePropertyAll(3),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(w * 0.03))),
                          shadowColor: const WidgetStatePropertyAll(
                              ColorConst.successColor),
                          foregroundColor: const WidgetStatePropertyAll(
                              ColorConst.successColor),
                          backgroundColor: const WidgetStatePropertyAll(
                              ColorConst.boxColor)),
                      onPressed: () {
                        if (double.parse(amountController.text) > 0 &&
                            amountController.text.isNotEmpty) {
                          openCheckout();
                          // Fluttertoast.showToast(
                          //     msg: "Online payment will be available soon!");
                        } else {
                          Fluttertoast.showToast(
                              msg: "Enter an amount to pay!");
                        }
                      },
                      child: const Text('Pay online')),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              WidgetStatePropertyAll(Size(w * 0.4, h * 0.03)),
                          elevation: const WidgetStatePropertyAll(3),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(w * 0.03))),
                          shadowColor: const WidgetStatePropertyAll(
                              ColorConst.primaryColor),
                          foregroundColor: const WidgetStatePropertyAll(
                              ColorConst.primaryColor),
                          backgroundColor: const WidgetStatePropertyAll(
                              ColorConst.boxColor)),
                      onPressed: () {
                        if (double.parse(amountController.text) > 0 &&
                            amountController.text.isNotEmpty) {
                          cashPayment();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Enter an amount to pay!");
                        }
                      },
                      child: const Text('Pay cash')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
