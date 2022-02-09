import 'package:rota_checker/model/rota.dart';
import 'package:rota_checker/model/on_call.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/shift_template.dart';
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
            .inDays,
        shiftsInRota = rota.getAllShifts(),
        onCallInRota = rota.getAllOnCalls();

  void CheckAll() {
    if (rotaLength > 182) {
      //TODO catch this exception
      throw Exception('Rota cannot be longer than 26 weeks');
    }
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
    return Tuple2<bool, String>(pass, result);
  }

  Tuple2<bool, String> max13HourShift() {
    String result = '';
    bool pass = true;
    for (Shift shift in shiftsInRota) {
      if (shift.length > 13) {
        result +=
            'Shift on ${shift.startTime.dateFormatToString()} has more than 13 hours';
        pass = false;
      }
    }
    return Tuple2<bool, String>(pass, result);
  }

  Tuple2<bool, String> max4LongShifts() {
    String result = '';
    bool pass = true;
    //Cycle through all shifts
    for (int i = 0; i < shiftsInRota.length - 1; i++) {
      //If a long shift is found
      if ((shiftsInRota[i].template as ShiftTemplate).isLong) {
        //If there are 4 more shifts after
        if (shiftsInRota.length >= i + 5) {
          List<Shift> setOfFive = shiftsInRota.getRange(i, i + 5).toList();
          print(setOfFive.length);
          //Check if consecutive

          DateTime day1 = new DateTime(setOfFive[0].startTime.year,
              setOfFive[0].startTime.month, setOfFive[0].startTime.day);
          DateTime day4 = new DateTime(setOfFive[3].startTime.year,
              setOfFive[3].startTime.month, setOfFive[3].startTime.day);
          DateTime day5 = new DateTime(setOfFive[4].startTime.year,
              setOfFive[4].startTime.month, setOfFive[4].startTime.day);

          if (day1.add(Duration(days: 3)).compareTo(day4) >= 0) {
            //5 in a row returns fail test
            if (day1.add(Duration(days: 4)).compareTo(day5) >= 0) {
              if ((shiftsInRota[i + 1].template as ShiftTemplate).isLong &&
                  (shiftsInRota[i + 2].template as ShiftTemplate).isLong &&
                  (shiftsInRota[i + 3].template as ShiftTemplate).isLong &&
                  (shiftsInRota[i + 4].template as ShiftTemplate).isLong) {
                pass = false;
                result +=
                    'More than 4 long days consecutively from ${shiftsInRota[i].startTime.dateFormatToString()}\n';
              }
            }
            //4 in a row will check whether breaks are adhered to
            if ((shiftsInRota[i + 1].template as ShiftTemplate).isLong &&
                (shiftsInRota[i + 2].template as ShiftTemplate).isLong &&
                (shiftsInRota[i + 3].template as ShiftTemplate).isLong) {
              //Check if break will be after 4th or 5th shift
              bool noEvenings = !(shiftsInRota[i].template as ShiftTemplate)
                      .isEveningFinish &&
                  !(shiftsInRota[i + 1].template as ShiftTemplate)
                      .isEveningFinish &&
                  !(shiftsInRota[i + 2].template as ShiftTemplate)
                      .isEveningFinish &&
                  !(shiftsInRota[i + 3].template as ShiftTemplate)
                      .isEveningFinish;
              bool noNights = !(shiftsInRota[i].template as ShiftTemplate)
                      .isNight &&
                  !(shiftsInRota[i + 1].template as ShiftTemplate).isNight &&
                  !(shiftsInRota[i + 2].template as ShiftTemplate).isNight &&
                  !(shiftsInRota[i + 3].template as ShiftTemplate).isNight;
              if (noEvenings && noNights) {
                if (shiftsInRota.length >= i + 6) {
                  //can work another as none are evening or night shifts
                  List<Shift> setOfSix =
                      shiftsInRota.getRange(i, i + 6).toList();

                  //Check if 5th is consecutive
                  DateTime day1b = new DateTime(setOfSix[0].startTime.year,
                      setOfSix[0].startTime.month, setOfSix[0].startTime.day);
                  DateTime day5b = new DateTime(setOfSix[4].startTime.year,
                      setOfSix[4].startTime.month, setOfSix[4].startTime.day);

                  if (day1b.add(Duration(days: 4)).compareTo(day5b) >= 0) {
                    bool breaks = checkBreakRule(setOfSix);
                    if (!breaks) {
                      result +=
                          'Break not given after shift on ${shiftsInRota[i + 4].startTime.dateFormatToString()}\n';
                      pass = false;
                    }
                  }
                }
              } else {
                //there is evening or night shift, check break rule
                bool breaks = checkBreakRule(setOfFive);
                if (!breaks) {
                  result +=
                      'Break not given after shift on ${shiftsInRota[i + 3].startTime.dateFormatToString()}\n';
                  pass = false;
                }
              }
            }
          }
        }
      }
    }

    return Tuple2<bool, String>(pass, result);
  }

  bool checkBreakRule(List<Shift> shifts) {
    int breakCode = 0;
    List<Shift> setOfFour = shifts.getRange(0, 4).toList();

    // 0 = 48hours after 5th shift
    // 1 = 48hours after 4th shift
    // 2 = 46hours after 4th shift

    for (Shift shift in setOfFour) {
      if ((shift.template as ShiftTemplate).isNight) {
        breakCode = 2;
        break;
      }
      if ((shift.template as ShiftTemplate).isEveningFinish) {
        breakCode = 1;
        break;
      }
    }

    if (breakCode == 0) {
      Duration gap = shifts[5].startTime.difference(shifts[4].endTime);
      if (gap.inHours >= 48) {
        return true;
      } else {
        return false;
      }
    }

    if (breakCode == 1) {
      Duration gap = shifts[4].startTime.difference(shifts[3].endTime);
      if (gap.inHours >= 48) {
        return true;
      } else {
        return false;
      }
    }

    if (breakCode == 2) {
      Duration gap = shifts[4].startTime.difference(shifts[3].endTime);
      if (gap.inHours >= 46) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Tuple2<bool, String> max7ConsecutiveDays() {
    String result = '';
    bool pass = true;

    for (int i = 0; i < shiftsInRota.length - 1; i++) {
      //If there are 7 more shifts after
      if (shiftsInRota.length >= i + 8) {
        List<Shift> setOfEight = shiftsInRota.getRange(i, i + 8).toList();

        //Check if consecutive

        DateTime day1 = new DateTime(setOfEight[0].startTime.year,
            setOfEight[0].startTime.month, setOfEight[0].startTime.day);
        DateTime day7 = new DateTime(setOfEight[6].startTime.year,
            setOfEight[6].startTime.month, setOfEight[6].startTime.day);
        DateTime day8 = new DateTime(setOfEight[7].startTime.year,
            setOfEight[7].startTime.month, setOfEight[7].startTime.day);

        if (day1.add(Duration(days: 7)).compareTo(day8) >= 0) {
          pass = false;
          result +=
              'More than 7 consecutive shifts starting ${shiftsInRota[i].startTime.dateFormatToString()}\n';
        } else if (day1.add(Duration(days: 6)).compareTo(day7) >= 0) {
          Duration gap = shiftsInRota[i + 7]
              .startTime
              .difference(shiftsInRota[i + 6].endTime);
          if (gap.inHours < 48) {
            pass = false;
            result +=
                'Less than 48 hours break after ${shiftsInRota[i + 6].endTime.dateFormatToString()}\n';
          }
        }
      }
    }

    return Tuple2<bool, String>(pass, result);
    //TODO implement below exception to rule
    //There is an exception for low intensity on-call –
    //where an on-call duty on a Saturday and Sunday contains less than 3 hours of work and no more than 3 episodes of work per day, up to 12 consecutive shifts
    //can be worked (provided that no other rule is breached).
  }

  Tuple2<bool, String> atLeast11HoursRest() {
    String result = '';
    bool pass = true;

    //Cycle through all shifts up to the last
    for (int i = 0; i < shiftsInRota.length - 1; i++) {
      Duration gap =
          shiftsInRota[i + 1].startTime.difference(shiftsInRota[i].endTime);
      if (gap.inHours < 11) {
        result +=
            'Less than 11 hours rest between shift on ${shiftsInRota[i].startTime.dateFormatToString()} and ${shiftsInRota[i + 1].startTime.dateFormatToString()}\n';
        pass = false;
      }
    }

    return Tuple2<bool, String>(pass, result);
  }

  Tuple2<bool, String> nightRestBreaks() {
    String result = '';
    bool pass = true;

    for (int i = 0; i < shiftsInRota.length - 1; i++) {
      if ((shiftsInRota[i].template as ShiftTemplate).isNight) {
        //Check the next one is not also a night shift
        if (!(shiftsInRota[i + 1].template as ShiftTemplate).isNight) {
          Duration gap =
              shiftsInRota[i + 1].startTime.difference(shiftsInRota[i].endTime);
          if (gap.inHours < 46) {
            result +=
                'Less than 46 hours rest after shift on ${shiftsInRota[i].startTime.dateFormatToString()}\n';
            pass = false;
          }
        }
      }
    }

    return Tuple2<bool, String>(pass, result);
  }

  Tuple2<bool, String> weekendFrequency() {
    String result = '';
    bool pass = true;

    List<int> weekendWork = [];

    void calculateWeekendsWorked(List<WorkDuty> duties) {
      for (int i = duties[0].weekNumber; i <= duties.last.weekNumber; i++) {
        List<WorkDuty> thisWeekDuties =
            duties.where((item) => item.weekNumber == i).toList();
        if (thisWeekDuties.any((item) => item.isWeekend)) {
          weekendWork.add(1);
        } else {
          weekendWork.add(0);
        }
      }
    }

    if (weekStart(rota.duties[0].startTime).year ==
        weekStart(rota.duties.last.startTime).year) {
      //all weeks are in the same year
      calculateWeekendsWorked(rota.duties);
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

      calculateWeekendsWorked(lastYearDuties);
      calculateWeekendsWorked(thisYearDuties);
    }

    if (weekendWork.average > 0.5) {
      pass = false;
    }

    result +=
        'Weekend frequency 1 in ${double.parse((1 / weekendWork.average).toStringAsFixed(2))}';

    return Tuple2<bool, String>(pass, result);
  }

  DateTime weekStart(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
