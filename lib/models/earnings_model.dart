class EarningsModel {
  final int totalTrips;
  final int weeklyTrips;
  final double totalEarnings;
  final double rentPaid;
  EarningsModel(
      {required this.totalTrips,
      required this.weeklyTrips,
      required this.totalEarnings,
      required this.rentPaid});

  factory EarningsModel.fromMap(Map<String, dynamic> json) {
    return EarningsModel(
      totalTrips: json['total_trips'],
      weeklyTrips: json['weekly_trips'],
      totalEarnings: json['total_earnings'],
      rentPaid: json['rent_paid'],
    );
  }
}
