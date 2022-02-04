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
  final int rotaLength;
  List<Shift> shiftsInRota = [];
  List<OnCall> onCallInRota = [];

  Compliance(this.rota)
      : rotaLength = rota.duties.last.endTime
            .difference(rota.duties[0].startTime)
            .inDays;

  void CheckAll() {
    if (rotaLength > 182) {
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

  Tuple2<bool, String> max72HoursPer168() {
    bool pass = true;
    String result = '';
    double maxHours = 0;
    //Get midnight on the first day to be checked
    DateTime setMidnight = DateTime(rota.duties[0].startTime.year,
        rota.duties[0].startTime.month, rota.duties[0].startTime.day);

    for (int i = 0; i < rotaLength; i++) {
      //Select the next date to be cycled through and add 7 days
      DateTime startDateTime = setMidnight.add(Duration(days: i));
      DateTime endDateTime = startDateTime.add(Duration(days: 7));

      //If there are less than 7 days remaining, then there is no need to check further
      if (rota.duties.last.endTime
              .add(Duration(days: 1))
              .compareTo(endDateTime) <
          0) {
        break;
      }

      double thisWeeklyHours = 0;

      //Selects all the shifts/on calls with start or end time within window
      List<WorkDuty> thisWeekDuties = rota.duties
          .where((item) =>
              startDateTime.compareTo(item.startTime) <= 0 &&
                  endDateTime.compareTo(item.startTime) > 0 ||
              startDateTime.compareTo(item.endTime) < 0 &&
                  endDateTime.compareTo(item.endTime) >= 0)
          .toList();

      for (WorkDuty duty in thisWeekDuties) {
        //check whether it is fully in the time period
        if (startDateTime.compareTo(duty.startTime) <= 0 &&
            endDateTime.compareTo(duty.endTime) >= 0) {
          thisWeeklyHours +=
              duty is Shift ? duty.length : (duty as OnCall).expectedHours;
        } else if (startDateTime.compareTo(duty.startTime) > 0 &&
            endDateTime.compareTo(duty.endTime) >= 0) {
          //starts before start but finishes after
          Duration partialDuty = duty.endTime.difference(startDateTime);
          if (duty is Shift) {
            thisWeeklyHours += partialDuty.inHours;
          } else {
            //find the proportion of the on call within the specified time period
            double proportion = partialDuty.inHours / duty.length;
            //apply that proportion to the expected work hours
            double partialHours = (duty as OnCall).expectedHours * proportion;
            thisWeeklyHours += partialHours;
          }
        } else if (startDateTime.compareTo(duty.startTime) <= 0 &&
            endDateTime.compareTo(duty.endTime) < 0) {
          //starts before end but finishes after
          Duration partialDuty = endDateTime.difference(duty.startTime);
          if (duty is Shift) {
            thisWeeklyHours += partialDuty.inHours;
          } else {
            //find the proportion of the on call within the specified time period
            double proportion = partialDuty.inHours / duty.length;
            //apply that proportion to the expected work hours
            double partialHours = (duty as OnCall).expectedHours * proportion;
            thisWeeklyHours += partialHours;
          }
        }
      }

      if (thisWeeklyHours > 72) {
        pass = false;
      }
      if (thisWeeklyHours > maxHours) {
        maxHours = thisWeeklyHours;
      }
    }
    result += 'Max hours per 168 hour period is ${maxHours}';
    return Tuple2(pass, result);
  }

  DateTime weekStart(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
