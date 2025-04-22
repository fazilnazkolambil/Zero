import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String transactionId;
  String driverId;
  Timestamp paymentTime;
  double amount;
  String status;
  String driverName;
  String paymentMethod;
  TransactionModel({
    required this.transactionId,
    required this.driverId,
    required this.paymentTime,
    required this.amount,
    required this.status,
    required this.driverName,
    required this.paymentMethod,
  });
  TransactionModel copywith({
    String? transactionId,
    String? driverId,
    Timestamp? paymentTime,
    double? amount,
    String? status,
    String? driverName,
    String? paymentMethod,
  }) =>
      TransactionModel(
        transactionId: transactionId ?? this.transactionId,
        driverId: driverId ?? this.driverId,
        paymentTime: paymentTime ?? this.paymentTime,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        driverName: driverName ?? this.driverName,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );
  factory TransactionModel.fromMap(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] ?? '',
      driverId: json['driver_id'] ?? '',
      paymentTime: json['payment_time'],
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
      driverName: json['driver_name'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'driver_id': driverId,
        'payment_time': paymentTime,
        'amount': amount,
        'status': status,
        'driver_name': driverName,
        'payment_method': paymentMethod,
      };
}
