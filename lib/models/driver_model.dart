class DriverModel {
  bool isDeleted;
  int totalTrips;
  double totalEarnings;
  double cashCollected;
  double refund;
  double wallet;
  String onRent;
  String driverName;
  String mobileNumber;
  String status;
  String driverId;
  String isBlocked;
  String organisationId;
  int targetTrips;
  int weeklyTrips;
  int totalShifts;
  int weeklyShifts;
  String organisationName;
  String driverAddedOn;
  double fuelExpense;
  double vehicleRent;

  DriverModel(
      {required this.isDeleted,
      required this.totalTrips,
      required this.totalEarnings,
      required this.cashCollected,
      required this.refund,
      required this.wallet,
      required this.onRent,
      required this.driverName,
      required this.mobileNumber,
      required this.status,
      required this.driverId,
      required this.isBlocked,
      required this.organisationId,
      required this.targetTrips,
      required this.weeklyTrips,
      required this.weeklyShifts,
      required this.totalShifts,
      required this.organisationName,
      required this.driverAddedOn,
      required this.fuelExpense,
      required this.vehicleRent});
  DriverModel copyWith({
    bool? isDeleted,
    int? totalTrips,
    int? weeklyTrips,
    double? totalEarnings,
    double? cashCollected,
    double? refund,
    double? wallet,
    String? onRent,
    String? driverName,
    String? mobileNumber,
    String? status,
    String? driverId,
    String? isBlocked,
    String? organisationId,
    int? targetTrips,
    int? weeklyShifts,
    int? totalShifts,
    String? organisationName,
    String? driverAddedOn,
    double? fuelExpense,
    double? vehicleRent,
  }) =>
      DriverModel(
        isDeleted: isDeleted ?? this.isDeleted,
        totalTrips: totalTrips ?? this.totalTrips,
        weeklyTrips: weeklyTrips ?? this.weeklyTrips,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        cashCollected: cashCollected ?? this.cashCollected,
        refund: refund ?? this.refund,
        wallet: wallet ?? this.wallet,
        onRent: onRent ?? this.onRent,
        driverName: driverName ?? this.driverName,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        status: status ?? this.status,
        driverId: driverId ?? this.driverId,
        isBlocked: isBlocked ?? this.isBlocked,
        organisationId: organisationId ?? this.organisationId,
        targetTrips: targetTrips ?? this.targetTrips,
        totalShifts: totalShifts ?? this.totalShifts,
        weeklyShifts: weeklyShifts ?? this.weeklyShifts,
        driverAddedOn: driverAddedOn ?? this.driverAddedOn,
        organisationName: organisationName ?? this.organisationName,
        fuelExpense: fuelExpense ?? this.fuelExpense,
        vehicleRent: vehicleRent ?? this.vehicleRent,
      );

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        isDeleted: json["is_deleted"] ?? false,
        totalTrips: json["total_trips"] ?? 0,
        weeklyTrips: json["weekly_trips"] ?? 0,
        totalEarnings: json["total_earnings"] ?? 0,
        cashCollected: json["cash_collected"] ?? 0,
        refund: json["refund"] ?? 0,
        wallet: json["wallet"] ?? 0,
        onRent: json["on_rent"] ?? '',
        driverName: json["driver_name"] ?? '',
        mobileNumber: json["mobile_number"] ?? '',
        status: json["status"] ?? '',
        driverId: json["driver_id"] ?? '',
        isBlocked: json["is_blocked"] ?? '',
        organisationId: json["organisation_id"] ?? '',
        targetTrips: json["target_trips"] ?? 0,
        totalShifts: json["total_shifts"] ?? 0,
        weeklyShifts: json["weekly_shifts"] ?? 0,
        driverAddedOn: json["driver_added_on"] ?? DateTime.now().toString(),
        organisationName: json["organisation_name"] ?? '',
        fuelExpense: json["fuel_expense"] ?? 0,
        vehicleRent: json["vehicle_rent"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "is_deleted": isDeleted,
        "total_trips": totalTrips,
        "weekly_trips": weeklyTrips,
        "total_earnings": totalEarnings,
        "cash_collected": cashCollected,
        "refund": refund,
        "wallet": wallet,
        "on_rent": onRent,
        "driver_name": driverName,
        "mobile_number": mobileNumber,
        "status": status,
        "driver_id": driverId,
        "is_blocked": isBlocked,
        "organisation_id": organisationId,
        "target_trips": targetTrips,
        "weekly_shifts": weeklyShifts,
        "total_shifts": totalShifts,
        "driver_added_on": driverAddedOn,
        "organisation_name": organisationName,
        "fuel_expense": fuelExpense,
        "vehicle_rent": vehicleRent,
      };
}
