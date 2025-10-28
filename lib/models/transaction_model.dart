import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String transactionId;
  String userId;
  String fleetId;
  int paymentTime;
  double amount;
  String status;
  String senderName;
  String paymentMethod;
  TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.fleetId,
    required this.paymentTime,
    required this.amount,
    required this.status,
    required this.senderName,
    required this.paymentMethod,
  });
  TransactionModel copywith({
    String? transactionId,
    String? userId,
    String? fleetId,
    int? paymentTime,
    double? amount,
    String? status,
    String? senderName,
    String? paymentMethod,
  }) =>
      TransactionModel(
        transactionId: transactionId ?? this.transactionId,
        userId: userId ?? this.userId,
        fleetId: fleetId ?? this.fleetId,
        paymentTime: paymentTime ?? this.paymentTime,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        senderName: senderName ?? this.senderName,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );
  factory TransactionModel.fromMap(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] ?? '',
      userId: json['user_id'] ?? '',
      fleetId: json['fleet_id'] ?? '',
      paymentTime: json['payment_time'],
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
      senderName: json['sender_name'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'sender_id': userId,
        'fleet_id': fleetId,
        'payment_time': paymentTime,
        'amount': amount,
        'status': status,
        'sender_name': senderName,
        'payment_method': paymentMethod,
      };
}
