import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zero/core/global_variables.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  Future<void> leaveFleet() async {
    String fleetId = currentFleet!.fleetId;
    final userRef = _firestore.collection('users').doc(currentUser!.uid);
    final fleetRef = _firestore.collection('fleets').doc(fleetId);

    _firestore.runTransaction(
      (transaction) async {
        var userSnap = await transaction.get(userRef);
        var fleetSnap = await transaction.get(fleetRef);
        if (!userSnap.exists || !fleetSnap.exists) {
          throw Exception('Documents not found!');
        }
        transaction.update(userRef, {'fleet': null, 'user_role': 'USER'});
        transaction.update(fleetRef, {
          'drivers': FieldValue.arrayRemove([currentUser!.uid])
        });
      },
    );
    currentUser = currentUser!.copyWith(fleetId: null);
    Get.offAllNamed('/splash');
  }
}
