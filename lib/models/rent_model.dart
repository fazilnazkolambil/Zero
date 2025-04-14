import 'package:cloud_firestore/cloud_firestore.dart';

class RentModel {
  String rentId;
  String driverId;
  String driverName;
  String vehicleId;
  String vehicleNumber;
  Timestamp startTime;
  double vehicleRent;
  int selectedShift;
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
    required this.driverName,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.startTime,
    required this.vehicleRent,
    required this.selectedShift,
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
          String? driverName,
          String? vehicleId,
          String? vehicleNumber,
          Timestamp? startTime,
          double? vehicleRent,
          int? selectedShift,
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
        driverName: driverName ?? this.driverName,
        vehicleId: vehicleId ?? this.vehicleId,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        startTime: startTime ?? this.startTime,
        vehicleRent: vehicleRent ?? this.vehicleRent,
        selectedShift: selectedShift ?? this.selectedShift,
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
      driverName: json['driver_name'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      startTime: json['start_time'],
      vehicleRent: json['vehicle_rent'] ?? 0,
      selectedShift: json['selected_shift'] ?? 0,
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
        'driver_name': driverName,
        'vehicle_id': vehicleId,
        'vehicle_number': vehicleNumber,
        'start_time': startTime,
        'vehicle_rent': vehicleRent,
        'selected_shift': selectedShift,
        'end_time': endTime,
        'total_trips': totalTrips,
        'total_earnings': totalEarnings,
        'cash_collected': cashCollected,
        'refund': refund,
        'total_to_pay': totaltoPay,
        'rent_status': rentStatus,
      };
}
