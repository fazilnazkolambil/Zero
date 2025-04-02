import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/driver_model.dart';
import 'package:zero/models/vehicle_model.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final repositoryProvider = Provider((ref) {
  return Repositories(firestore: ref.watch(firestoreProvider));
});

class Repositories {
  final FirebaseFirestore _firestore;
  Repositories({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _vehicles => _firestore
      .collection('organisations')
      .doc('N5DGSiAVziV3dOtuuewi')
      // .doc(currentUser!.organisationId)
      .collection('vehicles');
  CollectionReference get _drivers => _firestore
      .collection('Organisations')
      .doc(currentUser!.organisationId)
      .collection('drivers');
  CollectionReference get _rentals => _firestore
      .collection('Organisations')
      .doc(currentUser!.organisationId)
      .collection('rents');
  CollectionReference get _payments => _firestore
      .collection('Organisations')
      .doc(currentUser!.organisationId)
      .collection('payments');

  Stream<List<VehicleModel>> vehicleStream() {
    print('aaaaaaaaaaaaa');
    return _vehicles.where('is_deleted', isEqualTo: false).snapshots().map(
        (event) => event.docs
            .map((e) => VehicleModel.fromJson(e.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<DriverModel>> driverStream() {
    return _drivers.snapshots().map((event) => event.docs
        .map((e) => DriverModel.fromJson(e.data() as Map<String, dynamic>))
        .toList());
  }
}
