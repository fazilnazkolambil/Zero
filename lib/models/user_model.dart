class UserModel {
  String mobileNumber;
  String organisationId;
  String userCreatedOn;
  String userId;
  String userRole;
  String userName;

  UserModel({
    required this.mobileNumber,
    required this.organisationId,
    required this.userCreatedOn,
    required this.userId,
    required this.userRole,
    required this.userName,
  });
  UserModel copyWith({
    String? mobileNumber,
    String? organisationId,
    String? userCreatedOn,
    String? userId,
    String? userRole,
    String? userName,
  }) =>
      UserModel(
        mobileNumber: mobileNumber ?? this.mobileNumber,
        organisationId: organisationId ?? this.organisationId,
        userCreatedOn: userCreatedOn ?? this.userCreatedOn,
        userId: userId ?? this.userId,
        userRole: userRole ?? this.userRole,
        userName: userName ?? this.userName,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        mobileNumber: json["mobile_number"] ?? '',
        organisationId: json["organisation_id"] ?? '',
        userCreatedOn: json["user_created_on"] ?? '',
        userId: json["user_id"] ?? '',
        userRole: json["user_role"] ?? '',
        userName: json["user_name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "mobile_number": mobileNumber,
        "organisation_id": organisationId,
        "user_created_on": userCreatedOn,
        "user_id": userId,
        "user_role": userRole,
        "user_name": userName,
      };
}
