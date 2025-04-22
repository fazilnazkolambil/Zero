import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({super.key});

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  List notifications = [];
  bool isLoading = false;
  getNotifications() async {
    setState(() {
      isLoading = true;
    });
    var data = await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .get();
    if (data.data()!['notifications'] != null) {
      notifications = data.data()!['notifications'];
    } else {
      notifications = [];
    }

    log(notifications.toString());
    setState(() {
      isLoading = false;
    });
  }

  acceptPayment(
      {required String paymentId,
      required String driverId,
      required double amount}) async {
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('payments')
        .doc(paymentId)
        .update({'status': 'SUCCESS'});
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('drivers')
        .doc(driverId)
        .update({'wallet': FieldValue.increment(amount)});
    final updatedNotifications = notifications.map((notif) {
      if (notif['payment_id'] == paymentId) {
        return {
          ...notif,
          'read': true,
        };
      }
      return notif;
    }).toList();

    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .update({
      'notifications': updatedNotifications,
    });
    Fluttertoast.showToast(msg: 'Payment accepted');
    getNotifications();
  }

  rejectPayment({required String paymentId}) async {
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .collection('payments')
        .doc(paymentId)
        .update({'status': 'REJECTED'});
    final updatedNotifications = notifications.map((notif) {
      if (notif['payment_id'] == paymentId) {
        return {
          ...notif,
          'read': true,
        };
      }
      return notif;
    }).toList();

    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .update({
      'notifications': updatedNotifications,
    });
    Fluttertoast.showToast(msg: 'Payment rejected');
    getNotifications();
  }

  clearNotifications() async {
    final List<Map<String, dynamic>> unreadNotifications = notifications
        .where(
            (notif) => notif is Map<String, dynamic> && notif['read'] != true)
        .cast<Map<String, dynamic>>()
        .toList();
    await FirebaseFirestore.instance
        .collection('organisations')
        .doc(currentUser!.organisationId)
        .update({
      'notifications': unreadNotifications,
    });
    Fluttertoast.showToast(msg: 'Cleared all the read notifications!');
    getNotifications();
  }

  @override
  void initState() {
    getNotifications();
    super.initState();
  }

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
                    [appbar(), notificationsStats()],
                body: notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'No new notifications',
                          style: TextStyle(
                              color: ColorConst.textColor,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [paymentNotifications()],
                      )),
      ),
    );
  }

  Widget appbar() {
    return SliverAppBar(
      foregroundColor: ColorConst.textColor,
      toolbarHeight: h * 0.1,
      title: const Text('Notifications',
          style: TextStyle(
              color: ColorConst.textColor, fontWeight: FontWeight.bold)),
      backgroundColor: ColorConst.boxColor,
      elevation: 2,
      actions: const [
        IconButton(
          icon: Icon(Icons.notifications, color: ColorConst.textColor),
          onPressed: null,
        ),
      ],
    );
  }

  Widget notificationsStats() {
    int unreadNotifications =
        notifications.where((element) => element['read'] == false).length;
    return SliverAppBar(
      leading: const SizedBox(),
      backgroundColor: ColorConst.backgroundColor,
      surfaceTintColor: ColorConst.backgroundColor,
      toolbarHeight: h * 0.1,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Card(
          color: ColorConst.boxColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    unreadNotifications.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor),
                  ),
                  SizedBox(height: w * 0.03),
                  const Text(
                    'Unread',
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
                    (notifications.length - unreadNotifications).toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textColor),
                  ),
                  SizedBox(height: w * 0.03),
                  const Text(
                    'Read',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () =>
                      unreadNotifications != 0 ? clearNotifications() : null,
                  icon: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.delete_forever_outlined,
                          color: ColorConst.errorColor),
                      Text(
                        'Clear',
                        style: TextStyle(color: ColorConst.errorColor),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentNotifications() {
    List paymentNotifications = notifications
        .where((element) => element['title'] == 'Payment request')
        .where((element) => element['read'] == false)
        .toList()
      ..sort((a, b) => b['time'].toDate().compareTo(a['time'].toDate()));
    return Padding(
      padding: EdgeInsets.all(w * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment requests (${paymentNotifications.length})',
              style: TextStyle(
                  color: ColorConst.textColor,
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: h * 0.02),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paymentNotifications.length,
            itemBuilder: (context, index) {
              String _getFormattedTime() {
                final now = DateTime.now();
                final difference = now
                    .difference(paymentNotifications[index]['time'].toDate());
                if (difference.inMinutes < 60) {
                  return '${difference.inMinutes} min ago';
                } else if (difference.inHours < 24) {
                  return '${difference.inHours} hours ago';
                } else {
                  return '${difference.inDays} days ago';
                }
              }

              return Card(
                color: ColorConst.boxColor,
                child: Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            _getFormattedTime(),
                            style: const TextStyle(color: Colors.grey),
                          )),
                      _textRow(
                          label: 'Driver name',
                          value: paymentNotifications[index]['driver_name']),
                      _textRow(
                          label: 'Amount',
                          value:
                              "₹ ${paymentNotifications[index]['amount'].toStringAsFixed(2)}"),
                      Padding(
                        padding: EdgeInsets.all(w * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    // fixedSize: WidgetStatePropertyAll(
                                    //     Size(w * 0.4, h * 0.03)),
                                    elevation: const WidgetStatePropertyAll(3),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                w * 0.03))),
                                    shadowColor: const WidgetStatePropertyAll(
                                        ColorConst.errorColor),
                                    foregroundColor:
                                        const WidgetStatePropertyAll(
                                            ColorConst.errorColor),
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                            ColorConst.boxColor)),
                                onPressed: () => _showRejectDialog(
                                    paymentId: paymentNotifications[index]
                                        ['payment_id']),
                                child: const Text('Reject')),
                            ElevatedButton(
                                style: ButtonStyle(
                                    // fixedSize: WidgetStatePropertyAll(
                                    //     Size(w * 0.4, h * 0.03)),
                                    elevation: const WidgetStatePropertyAll(3),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                w * 0.03))),
                                    shadowColor: const WidgetStatePropertyAll(
                                        ColorConst.successColor),
                                    foregroundColor:
                                        const WidgetStatePropertyAll(
                                            ColorConst.successColor),
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                            ColorConst.boxColor)),
                                onPressed: () => _showAcceptDialog(
                                    paymentId: paymentNotifications[index]
                                        ['payment_id'],
                                    driverId: paymentNotifications[index]
                                        ['driver_id'],
                                    amount: paymentNotifications[index]
                                        ['amount']),
                                child: const Text('Accept')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: h * 0.02),
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

  _showAcceptDialog(
      {required String paymentId,
      required String driverId,
      required double amount}) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: ColorConst.boxColor,
              title: const Text('Accept payment?',
                  style: TextStyle(color: ColorConst.primaryColor)),
              content: const Text(
                'Are you sure you want to accept this payment?',
                style: TextStyle(color: ColorConst.textColor),
              ),
              actions: [
                TextButton(
                    style: const ButtonStyle(
                      side: WidgetStatePropertyAll(
                          BorderSide(color: ColorConst.primaryColor)),
                      foregroundColor:
                          WidgetStatePropertyAll(ColorConst.primaryColor),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No')),
                TextButton(
                    style: const ButtonStyle(
                      foregroundColor:
                          WidgetStatePropertyAll(ColorConst.backgroundColor),
                      backgroundColor:
                          WidgetStatePropertyAll(ColorConst.primaryColor),
                    ),
                    onPressed: () async {
                      await acceptPayment(
                          paymentId: paymentId,
                          driverId: driverId,
                          amount: amount);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes')),
              ],
            ));
  }

  _showRejectDialog({required String paymentId}) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: ColorConst.boxColor,
              title: const Text('Reject payment?',
                  style: TextStyle(color: ColorConst.primaryColor)),
              content: const Text(
                'Are you sure you want to reject this payment?',
                style: TextStyle(color: ColorConst.textColor),
              ),
              actions: [
                TextButton(
                    style: const ButtonStyle(
                      side: WidgetStatePropertyAll(
                          BorderSide(color: ColorConst.primaryColor)),
                      foregroundColor:
                          WidgetStatePropertyAll(ColorConst.primaryColor),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No')),
                TextButton(
                    style: const ButtonStyle(
                      foregroundColor:
                          WidgetStatePropertyAll(ColorConst.backgroundColor),
                      backgroundColor:
                          WidgetStatePropertyAll(ColorConst.primaryColor),
                    ),
                    onPressed: () async {
                      await rejectPayment(paymentId: paymentId);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes')),
              ],
            ));
  }
}
