import 'package:zero/models/driver_model.dart';
import 'package:zero/models/organisation_model.dart';
import 'package:zero/models/user_model.dart';

String version = '1.0.1';
double w = 0;
double h = 0;
UserModel? currentUser;
DriverModel? currentDriver;
OrganisationModel org = OrganisationModel.fromJson({
  'admin_id': 'pRFe253kGCGKp1RhU0or',
  'created_on': "2025-04-07 11:46:55.151905",
  'organisation_id': 'N5DGSiAVziV3dOtuuewi',
  'organisation_name': 'Zero uber',
  'room_rent': 50,
  'fleet': {
    'fleet_name': 'XYZ',
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
});

class CommonWidgets {
  Map<String, Map<String, dynamic>> calculateWeeklyFleetRent(
      {required Map<String, Map<String, dynamic>> vehicleStats,
      required DateTime startDate,
      required DateTime endDate}) {
    final List<Rent> rentPlan = org.fleet.fleetPlan.rent;
    final int insurancePerDay = org.fleet.fleetPlan.insurance;

    final Map<String, Map<String, dynamic>> rentBreakdown = {};

    // final now = DateTime.now();
    // final thisMonday = DateTime(now.year, now.month, now.day).subtract(
    //     Duration(days: now.weekday - 1)); // Start of the week (Monday)
    // final nextMonday = thisMonday.add(const Duration(days: 7)); // End of week

    vehicleStats.forEach((vehicleId, data) {
      int totalTrips = data['trips'] ?? 0;
      DateTime? deletedOn = data['deleted_on'];
      DateTime? addedOn = data['added_on'];

      // Set start and end for calculating rent
      DateTime rentStart =
          addedOn != null && addedOn.isAfter(startDate) ? addedOn : startDate;
      DateTime rentEnd = deletedOn != null && deletedOn.isBefore(endDate)
          ? deletedOn
          : endDate;

      // Make sure rentStart is before rentEnd
      int rentalDays = rentEnd.difference(rentStart).inDays;
      if (rentalDays < 0) rentalDays = 0;
      if (rentalDays > 7) rentalDays = 7;

      // Find applicable rent based on trips
      int rent = 0;
      for (final plan in rentPlan) {
        if (totalTrips >= plan.trip) {
          rent = plan.rent;
        } else {
          break;
        }
      }

      int totalRent = (rent + insurancePerDay) * rentalDays;

      rentBreakdown[vehicleId] = {
        'trips': totalTrips,
        'rent': totalRent,
        'deleted_on': deletedOn,
        'added_on': addedOn,
        'rental_days': rentalDays,
        'insurance': insurancePerDay,
        'per_day_rent': rent,
      };
    });

    return rentBreakdown;
  }
}
