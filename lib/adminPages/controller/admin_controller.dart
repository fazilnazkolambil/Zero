import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero/core/repositories.dart';
import 'package:zero/models/vehicle_model.dart';

final adminControllerProvider = Provider<AdminController>((ref) {
  return AdminController();
});

final vehicleStreamProvider =
    StreamProvider.autoDispose<List<VehicleModel>>((ref) {
  return ref.watch(adminControllerProvider).getVehicles();
});

class AdminController extends Notifier<bool> {
  Stream<List<VehicleModel>> getVehicles() {
    return ref.watch(repositoryProvider).vehicleStream();
  }

  @override
  bool build() {
    return false;
  }
}
