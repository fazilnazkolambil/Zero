class FleetModel {
  final String fleetId;
  final String ownerId;
  final String fleetName;
  final bool isHiring;
  final String contactNumber;
  final String officeAddress;
  final String parkingLocation;
  final List? drivers;
  final List? vehicles;
  final int addedOn;
  final int updatedOn;
  final Map<String, dynamic> targets;

  FleetModel({
    required this.fleetId,
    required this.ownerId,
    required this.fleetName,
    required this.isHiring,
    required this.contactNumber,
    required this.officeAddress,
    required this.parkingLocation,
    this.drivers,
    this.vehicles,
    required this.addedOn,
    required this.updatedOn,
    required this.targets,
  });

  FleetModel copyWith({
    String? fleetId,
    String? ownerId,
    String? fleetName,
    bool? isHiring,
    String? contactNumber,
    String? officeAddress,
    String? parkingLocation,
    List<String>? drivers,
    List<String>? vehicles,
    int? addedOn,
    int? updatedOn,
    Map<String, dynamic>? targets,
  }) {
    return FleetModel(
      fleetId: fleetId ?? this.fleetId,
      ownerId: ownerId ?? this.ownerId,
      fleetName: fleetName ?? this.fleetName,
      isHiring: isHiring ?? this.isHiring,
      contactNumber: contactNumber ?? this.contactNumber,
      officeAddress: officeAddress ?? this.officeAddress,
      parkingLocation: parkingLocation ?? this.parkingLocation,
      drivers: drivers ?? this.drivers,
      vehicles: vehicles ?? this.vehicles,
      addedOn: addedOn ?? this.addedOn,
      updatedOn: updatedOn ?? this.updatedOn,
      targets: targets ?? this.targets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fleet_id': fleetId,
      'owner_id': ownerId,
      'fleet_name': fleetName,
      'is_hiring': isHiring,
      'contact_number': contactNumber,
      'office_address': officeAddress,
      'parking_location': parkingLocation,
      'drivers': drivers,
      'vehicles': vehicles,
      'added_on': addedOn,
      'updated_on': updatedOn,
      'targets': targets,
    };
  }

  factory FleetModel.fromMap(Map<String, dynamic> map) {
    return FleetModel(
      fleetId: map['fleet_id'] ?? '',
      ownerId: map['owner_id'] ?? '',
      fleetName: map['fleet_name'] ?? '',
      isHiring: map['is_hiring'] ?? false,
      contactNumber: map['contact_number'] ?? '',
      officeAddress: map['office_address'] ?? '',
      parkingLocation: map['parking_location'] ?? '',
      drivers: map['drivers'] ?? [],
      vehicles: map['vehicles'] ?? [],
      addedOn: map['added_on'] ?? 0,
      updatedOn: map['updated_on'] ?? 0,
      targets: map['targets'] ?? {'driver': 0, 'vehicle': 0},
    );
  }
}
