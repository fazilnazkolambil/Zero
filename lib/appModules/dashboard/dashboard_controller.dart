import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  var weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).obs;
  DateTime? weekEnd;
  void previousWeek() {
    weekStart.value = weekStart.value.subtract(const Duration(days: 7));
    // getRents();
  }

  void nextWeek() {
    if (DateTime.now().difference(weekStart.value).inDays < 7) {
      null;
    } else {
      weekStart.value = weekStart.value.add(const Duration(days: 7));

      // getRents();
    }
  }

  String getWeekRange() {
    final DateFormat formatter = DateFormat('MMM d');
    final DateTime weekEnd = weekStart.value.add(const Duration(days: 6));
    return '${formatter.format(weekStart.value)} - ${formatter.format(weekEnd)}';
  }
}
