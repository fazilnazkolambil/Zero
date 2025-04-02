import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  String vehicleNumber;
  String driver;
  Timestamp startTime;
  Timestamp lastDriven;
  bool onDuty;
  String status;
  String vehicleId;
  bool isDeleted;
  int totalTrips;
  int targetTrips;
  double rent;
  int? selectedShift;

  VehicleModel(
      {required this.vehicleNumber,
      required this.driver,
      required this.startTime,
      required this.lastDriven,
      required this.onDuty,
      required this.status,
      required this.vehicleId,
      required this.isDeleted,
      required this.totalTrips,
      required this.targetTrips,
      required this.rent,
      this.selectedShift});
  VehicleModel copyWith(
          {String? vehicleNumber,
          String? driver,
          Timestamp? startTime,
          Timestamp? lastDriven,
          bool? onDuty,
          String? status,
          String? vehicleId,
          bool? isDeleted,
          int? totalTrips,
          int? targetTrips,
          double? rent,
          int? selectedShift}) =>
      VehicleModel(
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        driver: driver ?? this.driver,
        startTime: startTime ?? this.startTime,
        lastDriven: lastDriven ?? this.lastDriven,
        onDuty: onDuty ?? this.onDuty,
        status: status ?? this.status,
        vehicleId: vehicleId ?? this.vehicleId,
        isDeleted: isDeleted ?? this.isDeleted,
        totalTrips: totalTrips ?? this.totalTrips,
        targetTrips: targetTrips ?? this.targetTrips,
        rent: rent ?? this.rent,
        selectedShift: selectedShift ?? this.selectedShift,
      );

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        vehicleNumber: json["vehicle_number"] ?? '',
        driver: json["driver"] ?? '',
        startTime: json["start_time"] ?? '',
        lastDriven: json["last_driven"] ?? '',
        status: json["status"] ?? '',
        vehicleId: json["vehicle_id"] ?? '',
        isDeleted: json["is_deleted"] ?? false,
        onDuty: json["on_duty"] ?? false,
        totalTrips: json["total_trips"] ?? false,
        targetTrips: json["target_trips"] ?? false,
        rent: json["rent"] ?? 0,
        selectedShift: json["selected_shift"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "vehicle_number": vehicleNumber,
        "driver": driver,
        "start_time": startTime,
        "last_driven": lastDriven,
        "status": status,
        "vehicle_id": vehicleId,
        "is_deleted": onDuty,
        "on_duty": onDuty,
        "total_trips": totalTrips,
        "target_trips": targetTrips,
        "rent": rent,
        "selected_shift": selectedShift,
      };
}
