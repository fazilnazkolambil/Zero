import 'package:zero/models/fleet_model.dart';

class InvitationModel {
  final String id;
  final FleetModel? fleet;
  final String senderId;
  final String receiverId;
  final String status;
  final int timestamp;

  InvitationModel({
    required this.id,
    this.fleet,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] ?? '',
      fleet: json['fleet'] == null ? null : FleetModel.fromMap(json['fleet']),
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      status: json['status'] ?? 'pending',
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

// class FleetInvitation {
//   final String fleetId;
//   final String fleetName;
//   final int fleetSize;
//   final String address;
//   final String contactNumber;
//   FleetInvitation({
//     required this.fleetId,
//     required this.fleetName,
//     required this.fleetSize,
//     required this.address,
//     required this.contactNumber,
//   });
//   factory FleetInvitation.fromJson(Map<String, dynamic> map) {
//     return FleetInvitation(
//         fleetId: map['fleet_id'] ?? '',
//         fleetName: map['fleet_name'],
//         fleetSize: map['fleet_size'],
//         address: map['address'],
//         contactNumber: map['contact_number']);
//   }
//   Map<String, dynamic> toMap() {
//     return {
//       'fleet_id': fleetId,
//       'fleet_name': fleetName,
//       'fleet_size': fleetSize,
//       'address': address,
//       'contact_number': contactNumber,
//     };
//   }
// }
