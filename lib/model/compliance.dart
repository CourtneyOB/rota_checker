import 'package:rota_checker/model/rota.dart';
import 'package:rota_checker/model/on_call.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';
import 'package:week_of_year/week_of_year.dart';

class Compliance {
  final Rota rota;
  List<Shift> shiftsInRota = [];
  List<OnCall> onCallInRota = [];

  Compliance(this.rota);

  void CheckAll() {
    if (rota.duties[0].startTime.difference(rota.duties.last.startTime).inDays >
        182) {
      //TODO catch this exception
      throw Exception('Rota cannot be longer than 26 weeks');
    }
    shiftsInRota = rota.getAllShifts();
    onCallInRota = rota.getAllOnCalls();
  }

  Tuple2<bool, String> max48HourWeek() {
    List<double> allWeeklyHours = [];
    String result = '';

    void calculateWeeklyHours(List<WorkDuty> duties) {
      for (int i = duties[0].weekNumber; i <= duties.last.weekNumber; i++) {
        List<WorkDuty> thisWeekDuties =
            duties.where((item) => item.weekNumber == i).toList();

        double thisWeeklyHours = 0;

        for (WorkDuty duty in thisWeekDuties) {
          if (duty is Shift) {
            thisWeeklyHours += duty.length;
          } else {
            thisWeeklyHours += (duty as OnCall).expectedHours;
          }
        }

        result +=
            'Hours in Week $i, (${duties[0].startTime.year}): $thisWeeklyHours\n';
        allWeeklyHours.add(thisWeeklyHours);
      }
    }

    if (weekStart(rota.duties[0].startTime).year ==
        weekStart(rota.duties.last.startTime).year) {
      //all weeks are in the same year
      calculateWeeklyHours(rota.duties);
    } else {
      //weeks span across 2 years, so need to cycle through these seperately
      List<WorkDuty> lastYearDuties = [rota.duties[0]];
      List<WorkDuty> thisYearDuties = [];
      int currentWeekNumber = rota.duties[0].weekNumber;
      bool changeYear = false;
      for (int i = 1; i < rota.duties.length; i++) {
        if (!changeYear) {
          int previousWeekNumber = currentWeekNumber;
          currentWeekNumber = rota.duties[i].weekNumber;
          if (currentWeekNumber >= previousWeekNumber) {
            lastYearDuties.add(rota.duties[i]);
          } else {
            changeYear = true;
          }
        }
        if (changeYear) {
          thisYearDuties.add(rota.duties[i]);
        }
      }

      calculateWeeklyHours(lastYearDuties);
      calculateWeeklyHours(thisYearDuties);
    }

    double averageHours = allWeeklyHours.average;
    result += '\nAverage hours per week: $averageHours';

    if (averageHours <= 48.0) {
      //pass
      return Tuple2(true, result);
    } else {
      //fail
      return Tuple2(false, result);
    }
  }

  DateTime weekStart(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
