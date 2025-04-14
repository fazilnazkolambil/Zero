import 'package:zero/models/driver_model.dart';
import 'package:zero/models/user_model.dart';

String version = '1.0.0';
double w = 0;
double h = 0;
UserModel? currentUser;
DriverModel? currentDriver;

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
