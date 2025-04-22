import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/driverPages/driver_notifications.dart';
import 'package:zero/driverPages/razorpay_page.dart';
import 'package:zero/models/transaction_model.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isLoading = false;
  List<TransactionModel> transactionModel = [];
  Future getPayments() async {
    transactionModel.clear();
    setState(() {
      isLoading = true;
    });
    var transactions = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('payments')
        .where('driver_id', isEqualTo: currentDriver!.driverId)
        .get();
    for (var transaction in transactions.docs) {
      transactionModel.add(TransactionModel.fromMap(transaction.data()));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getPayments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                [appbar(), walletDetails()],
            body: SingleChildScrollView(
              child: Column(
                children: [
                  amountReceived(),
                  SizedBox(height: h * 0.02),
                  transactions()
                ],
              ),
            )),
      ),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      foregroundColor: ColorConst.textColor,
      toolbarHeight: h * 0.1,
      title: const Text('Your wallet',
          style: TextStyle(
              color: ColorConst.textColor, fontWeight: FontWeight.bold)),
      backgroundColor: ColorConst.boxColor,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: ColorConst.textColor),
          onPressed: () => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) => const DriverNotifications())),
        ),
        const IconButton(
          icon: Icon(Icons.wallet, color: ColorConst.textColor),
          onPressed: null,
        ),
      ],
    );
  }

  Widget walletDetails() {
    return SliverAppBar(
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      toolbarHeight: h * 0.16,
      leading: const SizedBox(),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          background: Card(
        color: ColorConst.boxColor,
        margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.03),
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    currentDriver!.wallet.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: currentDriver!.wallet <= 0
                            ? ColorConst.errorColor
                            : ColorConst.successColor),
                  ),
                  SizedBox(height: w * 0.03),
                  const Text(
                    'Your wallet',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(3),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.03))),
                      shadowColor:
                          const WidgetStatePropertyAll(ColorConst.successColor),
                      foregroundColor:
                          const WidgetStatePropertyAll(ColorConst.successColor),
                      backgroundColor:
                          const WidgetStatePropertyAll(ColorConst.boxColor)),
                  onPressed: () => showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      backgroundColor: ColorConst.boxColor,
                      builder: (context) =>
                          RazorPayBottomSheet(amount: -currentDriver!.wallet)),
                  child: Text(currentDriver!.wallet < 0 ? 'Pay now' : 'Top up'))
            ],
          ),
        ),
      )),
    );
  }

  Widget amountReceived() {
    double paidAmount = transactionModel
        .where((element) => element.status.toUpperCase() == 'SUCCESS')
        .fold(0, (amount, a) => amount + a.amount);
    double pendingAmount = transactionModel
        .where((element) => element.status.toUpperCase() == 'PENDING')
        .fold(0, (amount, a) => amount + a.amount);
    return Row(
      children: [
        SizedBox(
          width: w * 0.5,
          height: w * 0.5,
          child: Card(
            elevation: 2,
            margin:
                EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.01),
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
                    pendingAmount.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  SizedBox(height: h * 0.01),
                  const Text(
                    'Amount pending for approval',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: w * 0.5,
          height: w * 0.5,
          child: Card(
            elevation: 2,
            margin:
                EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.01),
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
                    paidAmount.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.successColor),
                  ),
                  SizedBox(height: h * 0.01),
                  const Text(
                    'Total amount paid',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget transactions() {
    double onlinePayment = transactionModel
        .where((element) => element.paymentMethod.toUpperCase() == 'ONLINE')
        .where((element) => element.status.toUpperCase() == 'SUCCESS')
        .fold(0, (online, a) => online + a.amount);
    double cashPayment = transactionModel
        .where((element) => element.paymentMethod.toUpperCase() == 'CASH')
        .where((element) => element.status.toUpperCase() == 'SUCCESS')
        .fold(0, (online, a) => online + a.amount);
    return Card(
      margin: EdgeInsets.all(w * 0.03),
      color: ColorConst.boxColor,
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz_sharp, color: ColorConst.textColor),
                SizedBox(width: w * 0.03),
                const Text(
                  'Transactions',
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
                      transactionModel.length.toString(),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
                    ),
                    SizedBox(height: w * 0.03),
                    const Text(
                      'Transactions',
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
                      onlinePayment.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
                    ),
                    SizedBox(height: w * 0.03),
                    const Text(
                      'Online payment',
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
                      cashPayment.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
                    ),
                    SizedBox(height: w * 0.03),
                    const Text(
                      'Cash payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
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
                          Icon(Icons.circle,
                              size: w * 0.04,
                              color: transactionModel[index]
                                          .status
                                          .toUpperCase() ==
                                      'SUCCESS'
                                  ? ColorConst.successColor
                                  : transactionModel[index]
                                              .status
                                              .toUpperCase() ==
                                          'REJECTED'
                                      ? ColorConst.errorColor
                                      : transactionModel[index]
                                                  .status
                                                  .toUpperCase() ==
                                              'PENDING'
                                          ? Colors.orange
                                          : ColorConst.textColor)
                        ],
                      ),
                    ),
                    title: Text(
                      '₹ ${transactionModel[index].amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('EEE, dd/MM, hh:mm a')
                          .format(transactionModel[index].paymentTime.toDate()),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      transactionModel[index].paymentMethod,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorConst.textColor),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                    ),
                itemCount: transactionModel.length),
          ],
        ),
      ),
    );
  }
}
