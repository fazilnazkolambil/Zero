import 'package:zero/models/driver_model.dart';
import 'package:zero/models/user_model.dart';

String version = '1.0.0';
double w = 0;
double h = 0;
UserModel? currentUser;
DriverModel? currentDriver;
Map org = {
  'admin_id': 'pRFe253kGCGKp1RhU0or',
  'created_on': "2025-04-07 11:46:55.151905",
  'organisation_id': 'N5DGSiAVziV3dOtuuewi',
  'organisation_name': 'Zero uber',
  'room_rent': 50,
  'fleet': {
    'fleet_name': 'Carrum Mobility',
    'fleet_plan': {
      'plan': 'plan_wagonr',
      'insurance': 15,
      'rent': [
        {'trip': 0, 'rent': 900},
        {'trip': 65, 'rent': 770},
        {'trip': 80, 'rent': 660},
        {'trip': 110, 'rent': 500},
        {'trip': 125, 'rent': 350},
        {'trip': 140, 'rent': 300},
      ]
    }
  }
};

class CommonWidgets {
  int calculateRent({required int tripsCompleted, required List rentalPlan}) {
    int rent = 0;

    for (var plan in rentalPlan) {
      if (tripsCompleted >= plan['trip']) {
        rent = plan['rent'] ?? 0;
      } else {
        break;
      }
    }
    return rent;
  }

  double calculateWeeklyRent(
      {required List<int> tripsPerDay,
      required List rentalPlan,
      required List<int> rentalDays}) {
    double totalRent = 0;

    for (int trips in tripsPerDay) {
      for (int days in rentalDays) {
        totalRent +=
            calculateRent(rentalPlan: rentalPlan, tripsCompleted: trips) * days;
      }
    }

    return totalRent;
  }
}
