import 'package:cloud_firestore/cloud_firestore.dart';

class RentModel {
  String rentId;
  String driverId;
  String vehicleId;
  String vehicleNumber;
  Timestamp startTime;
  double rent;
  int shift;
  Timestamp? endTime;
  int totalTrips;
  double totalEarnings;
  double cashCollected;
  double totaltoPay;
  double refund;
  String rentStatus;
  RentModel({
    required this.rentId,
    required this.driverId,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.startTime,
    required this.rent,
    required this.shift,
    this.endTime,
    required this.totalTrips,
    required this.totalEarnings,
    required this.cashCollected,
    required this.refund,
    required this.totaltoPay,
    required this.rentStatus,
  });
  RentModel copywith(
          {String? rentId,
          String? driverId,
          String? vehicleId,
          String? vehicleNumber,
          Timestamp? startTime,
          double? rent,
          int? shift,
          Timestamp? endTime,
          int? totalTrips,
          double? totalEarnings,
          double? cashCollected,
          double? refund,
          double? totaltoPay,
          String? rentStatus}) =>
      RentModel(
        rentId: rentId ?? this.rentId,
        driverId: driverId ?? this.driverId,
        vehicleId: vehicleId ?? this.vehicleId,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        startTime: startTime ?? this.startTime,
        rent: rent ?? this.rent,
        shift: shift ?? this.shift,
        endTime: endTime ?? this.endTime,
        totalTrips: totalTrips ?? this.totalTrips,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        cashCollected: cashCollected ?? this.cashCollected,
        refund: refund ?? this.refund,
        totaltoPay: totaltoPay ?? this.totaltoPay,
        rentStatus: rentStatus ?? this.rentStatus,
      );
  factory RentModel.fromMap(Map<String, dynamic> json) {
    return RentModel(
      rentId: json['rent_id'] ?? '',
      driverId: json['driver_id'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      startTime: json['start_time'],
      rent: json['rent'] ?? 0,
      shift: json['shift'] ?? 0,
      endTime: json['end_time'],
      totalTrips: json['total_trips'] ?? 0,
      totalEarnings: json['total_earnings'] ?? 0,
      cashCollected: json['cash_collected'] ?? 0,
      refund: json['refund'] ?? 0,
      totaltoPay: json['total_to_pay'] ?? 0,
      rentStatus: json['rent_status'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'rent_id': rentId,
        'driver_id': driverId,
        'vehicle_id': vehicleId,
        'vehicle_number': vehicleNumber,
        'start_time': startTime,
        'rent': rent,
        'shift': shift,
        'end_time': endTime,
        'total_trips': totalTrips,
        'total_earnings': totalEarnings,
        'cash_collected': cashCollected,
        'refund': refund,
        'total_to_pay': totaltoPay,
        'rent_status': rentStatus,
      };
}
