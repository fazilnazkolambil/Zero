class UserModel {
  String mobileNumber;
  String organisationId;
  String organisationName;
  String userCreatedOn;
  String userId;
  String userRole;
  String userName;
  bool isDeleted;
  int? totalTrips;
  double? totalEarnings;
  double? cashCollected;
  double? refund;
  double? wallet;
  String? onRent;
  String status;
  String isBlocked;
  int? targetTrips;
  int? totalShifts;
  double? vehicleRent;

  UserModel({
    required this.mobileNumber,
    required this.organisationId,
    required this.organisationName,
    required this.userCreatedOn,
    required this.userId,
    required this.userRole,
    required this.userName,
    required this.isDeleted,
    this.totalTrips,
    this.totalEarnings,
    this.cashCollected,
    this.refund,
    this.wallet,
    this.onRent,
    required this.status,
    required this.isBlocked,
    this.targetTrips,
    this.totalShifts,
    this.vehicleRent,
  });

  UserModel copyWith(
          {String? mobileNumber,
          String? organisationId,
          String? organisationName,
          String? userCreatedOn,
          String? userId,
          String? userRole,
          String? userName,
          bool? isDeleted,
          int? totalTrips,
          double? totalEarnings,
          double? cashCollected,
          double? refund,
          double? wallet,
          String? onRent,
          String? driverName,
          String? status,
          String? driverId,
          String? isBlocked,
          int? targetTrips,
          int? totalShifts,
          double? vehicleRent}) =>
      UserModel(
        mobileNumber: mobileNumber ?? this.mobileNumber,
        organisationId: organisationId ?? this.organisationId,
        organisationName: organisationName ?? this.organisationName,
        userCreatedOn: userCreatedOn ?? this.userCreatedOn,
        userId: userId ?? this.userId,
        userRole: userRole ?? this.userRole,
        userName: userName ?? this.userName,
        isDeleted: isDeleted ?? this.isDeleted,
        totalTrips: totalTrips ?? this.totalTrips,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        cashCollected: cashCollected ?? this.cashCollected,
        refund: refund ?? this.refund,
        wallet: wallet ?? this.wallet,
        onRent: onRent ?? this.onRent,
        status: status ?? this.status,
        isBlocked: isBlocked ?? this.isBlocked,
        targetTrips: targetTrips ?? this.targetTrips,
        totalShifts: totalShifts ?? this.totalShifts,
        vehicleRent: vehicleRent ?? this.vehicleRent,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        mobileNumber: json["mobile_number"] ?? '',
        organisationId: json["organisation_id"] ?? '',
        organisationName: json["organisation_name"] ?? '',
        userCreatedOn: json["user_created_on"] ?? DateTime.now().toString(),
        userId: json["user_id"] ?? '',
        userRole: json["user_role"] ?? '',
        userName: json["user_name"] ?? '',
        isDeleted: json["is_deleted"] ?? false,
        totalTrips: json["total_trips"] ?? 0,
        totalEarnings: json["total_earnings"]?.toDouble() ?? 0.0,
        cashCollected: json["cash_collected"]?.toDouble() ?? 0.0,
        refund: json["refund"]?.toDouble() ?? 0.0,
        wallet: json["wallet"]?.toDouble() ?? 0.0,
        onRent: json["on_rent"] ?? '',
        status: json["status"] ?? '',
        isBlocked: json["is_blocked"] ?? '',
        targetTrips: json["target_trips"] ?? 0,
        totalShifts: json["total_shifts"] ?? 0,
        vehicleRent: json["vehicle_rent"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "mobile_number": mobileNumber,
        "organisation_id": organisationId,
        "organisation_name": organisationName,
        "user_created_on": userCreatedOn,
        "user_id": userId,
        "user_role": userRole,
        "user_name": userName,
        "is_deleted": isDeleted,
        "total_trips": totalTrips,
        "total_earnings": totalEarnings,
        "cash_collected": cashCollected,
        "refund": refund,
        "wallet": wallet,
        "on_rent": onRent,
        "status": status,
        "is_blocked": isBlocked,
        "target_trips": targetTrips,
        "total_shifts": totalShifts,
        "vehicle_rent": vehicleRent,
      };
}
