class UserModel {
  String mobileNumber;
  String organisationId;
  String organisationName;
  String userCreatedOn;
  String userId;
  String userRole;
  String userName;
  bool isDeleted;
  // int? totalTrips;
  // double? totalEarnings;
  // double? wallet;
  String status;
  String isBlocked;
  // int? targetTrips;
  // int? totalShifts;

  UserModel({
    required this.mobileNumber,
    required this.organisationId,
    required this.organisationName,
    required this.userCreatedOn,
    required this.userId,
    required this.userRole,
    required this.userName,
    required this.isDeleted,
    // this.totalTrips,
    // this.totalEarnings,
    // this.wallet,
    required this.status,
    required this.isBlocked,
    // this.targetTrips,
    // this.totalShifts,
  });

  UserModel copyWith({
    String? mobileNumber,
    String? organisationId,
    String? organisationName,
    String? userCreatedOn,
    String? userId,
    String? userRole,
    String? userName,
    bool? isDeleted,
    // int? totalTrips,
    // double? totalEarnings,
    // double? wallet,
    String? status,
    String? isBlocked,
    // int? targetTrips,
    // int? totalShifts,
  }) =>
      UserModel(
        mobileNumber: mobileNumber ?? this.mobileNumber,
        organisationId: organisationId ?? this.organisationId,
        organisationName: organisationName ?? this.organisationName,
        userCreatedOn: userCreatedOn ?? this.userCreatedOn,
        userId: userId ?? this.userId,
        userRole: userRole ?? this.userRole,
        userName: userName ?? this.userName,
        isDeleted: isDeleted ?? this.isDeleted,
        // totalTrips: totalTrips ?? this.totalTrips,
        // totalEarnings: totalEarnings ?? this.totalEarnings,
        // wallet: wallet ?? this.wallet,
        status: status ?? this.status,
        isBlocked: isBlocked ?? this.isBlocked,
        // targetTrips: targetTrips ?? this.targetTrips,
        // totalShifts: totalShifts ?? this.totalShifts,
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
        // totalTrips: json["total_trips"] ?? 0,
        // totalEarnings: json["total_earnings"]?.toDouble() ?? 0.0,
        // wallet: json["wallet"]?.toDouble() ?? 0.0,
        status: json["status"] ?? '',
        isBlocked: json["is_blocked"] ?? '',
        // targetTrips: json["target_trips"] ?? 0,
        // totalShifts: json["total_shifts"] ?? 0,
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
        // "total_trips": totalTrips,
        // "total_earnings": totalEarnings,
        // "wallet": wallet,
        "status": status,
        "is_blocked": isBlocked,
        // "target_trips": targetTrips,
        // "total_shifts": totalShifts,
      };
}
