// To parse this JSON data, do
//
//     final organisationModel = organisationModelFromJson(jsonString);

import 'dart:convert';

OrganisationModel organisationModelFromJson(String str) =>
    OrganisationModel.fromJson(json.decode(str));

String organisationModelToJson(OrganisationModel data) =>
    json.encode(data.toJson());

class OrganisationModel {
  String adminId;
  DateTime createdOn;
  String organisationId;
  String organisationName;
  int roomRent;
  Fleet fleet;

  OrganisationModel({
    required this.adminId,
    required this.createdOn,
    required this.organisationId,
    required this.organisationName,
    required this.roomRent,
    required this.fleet,
  });

  factory OrganisationModel.fromJson(Map<String, dynamic> json) =>
      OrganisationModel(
        adminId: json["admin_id"],
        createdOn: DateTime.parse(json["created_on"]),
        organisationId: json["organisation_id"],
        organisationName: json["organisation_name"],
        roomRent: json["room_rent"],
        fleet: Fleet.fromJson(json["fleet"]),
      );

  Map<String, dynamic> toJson() => {
        "admin_id": adminId,
        "created_on": createdOn.toIso8601String(),
        "organisation_id": organisationId,
        "organisation_name": organisationName,
        "room_rent": roomRent,
        "fleet": fleet.toJson(),
      };
}

class Fleet {
  String fleetName;
  FleetPlan fleetPlan;

  Fleet({
    required this.fleetName,
    required this.fleetPlan,
  });

  factory Fleet.fromJson(Map<String, dynamic> json) => Fleet(
        fleetName: json["fleet_name"],
        fleetPlan: FleetPlan.fromJson(json["fleet_plan"]),
      );

  Map<String, dynamic> toJson() => {
        "fleet_name": fleetName,
        "fleet_plan": fleetPlan.toJson(),
      };
}

class FleetPlan {
  String plan;
  int insurance;
  List<Rent> rent;

  FleetPlan({
    required this.plan,
    required this.insurance,
    required this.rent,
  });

  factory FleetPlan.fromJson(Map<String, dynamic> json) => FleetPlan(
        plan: json["plan"],
        insurance: json["insurance"],
        rent: List<Rent>.from(json["rent"].map((x) => Rent.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plan": plan,
        "insurance": insurance,
        "rent": List<dynamic>.from(rent.map((x) => x.toJson())),
      };
}

class Rent {
  int trip;
  int rent;

  Rent({
    required this.trip,
    required this.rent,
  });

  factory Rent.fromJson(Map<String, dynamic> json) => Rent(
        trip: json["trip"],
        rent: json["rent"],
      );

  Map<String, dynamic> toJson() => {
        "trip": trip,
        "rent": rent,
      };
}
