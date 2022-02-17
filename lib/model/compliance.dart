import 'package:rota_checker/empty_rota_exception.dart';
import 'package:rota_checker/model/rota.dart';
import 'package:rota_checker/model/on_call.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/model/compliance_test.dart';
import 'package:collection/collection.dart';
import 'package:rota_checker/rota_length_exception.dart';

class Compliance {
  final Rota rota;
  final int rotaLength;
  List<Shift> shiftsInRota = [];
  List<OnCall> onCallInRota = [];

  Compliance(this.rota)
      : rotaLength = rota.duties.last.endTime
                .difference(rota.duties[0].startTime)
                .inDays +
            1,
        shiftsInRota = rota.getAllShifts(),
        onCallInRota = rota.getAllOnCalls();

  List<ComplianceTest> checkAll() {
    List<ComplianceTest> responses = [];
    if (rotaLength > 182) {
      throw RotaLengthException();
    }
    if (rota.duties.isEmpty) {
      throw EmptyRotaException();
    }

    responses.add(max48HourWeek());
    responses.add(max72HoursPer168());
    responses.add(max13HourShift());
    responses.add(max4LongShifts());
    responses.add(max7ConsecutiveDays());
    responses.add(atLeast11HoursRest());
    responses.add(nightRestBreaks());
    responses.add(weekendFrequency());
    responses.add(max24HourOnCall());
    responses.add(noConsecutiveOnCalls());
    responses.add(noMoreThan3OnCallsIn7Days());
    responses.add(dayAfterOnCallMustNotHaveWorkLongerThan10Hours());
    responses.add(eightHoursRestPer24HourOnCall());

    return responses;
  }

  ComplianceTest max48HourWeek() {
    List<double> allWeeklyHours = [];
    String result = '';
    String name = 'Max 48 hours work per week';
    String about =
        'No doctor should be rostered for more than an average of 48 hours of actual work per week.';

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
    result += 'Average hours per week: $averageHours';

    if (averageHours <= 48.0) {
      //pass
      return ComplianceTest(name, true, result, about);
    } else {
      //fail
      return ComplianceTest(name, false, result, about);
    }
  }

  ComplianceTest max72HoursPer168() {
    bool pass = true;
    String result = '';
    String name = 'Max 72 hours week per 168 hours';
    String about =
        'No more than 72 hours’ actual work should be rostered for or undertaken by any doctor, working on any working pattern, in any period of 168 consecutive hours.';
    double maxHours = 0;
    //Get midnight on the first day to be checked
    DateTime setMidnight = DateTime(rota.duties[0].startTime.year,
        rota.duties[0].startTime.month, rota.duties[0].startTime.day);

    for (int i = 0; i <= rotaLength; i++) {
      //Select the next date to be cycled through and add 7 days
      DateTime startDateTime = setMidnight.add(Duration(days: i));
      DateTime endDateTime = startDateTime.add(Duration(days: 7));

      //If there are less than 7 days remaining, then there is no need to check further
      if (rota.duties.last.endTime
              .compareTo(endDateTime.subtract(Duration(days: 1))) <
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

    if (rotaLength >= 7) {
      result +=
          'Max hours per 168 hour period is ${maxHours.toStringAsFixed(1)}';
    }

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest max13HourShift() {
    String result = '';
    bool pass = true;
    String name = 'Max 13 hour shifts';
    String about =
        'No shift (other than an on-call period) shall be rostered to exceed 13 hours in duration.';
    for (Shift shift in shiftsInRota) {
      if (shift.length > 13) {
        result +=
            'Shift on ${shift.startTime.dateFormatToString()} has more than 13 hours\n';
        pass = false;
      }
    }
    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest max4LongShifts() {
    String result = '';
    bool pass = true;
    String name = 'Max 4 long shifts in a row';
    String about =
        'No more than four long shifts (where a long shift is defined as being a shift rostered to last longer than 10 hours) shall be rostered or worked on consecutive days. Where four long shifts are rostered on consecutive days, there must be a minimum 48-hour rest period rostered immediately following the conclusion of the fourth long shift. Where shifts (excluding non-resident on-call shifts) have at least 3 hours of work that falls into the period between 23:00 and 06:00 and are rostered singularly, or consecutively, then there must be a minimum 46-hour rest period rostered immediately following the conclusion of the shift(s).';
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

    return ComplianceTest(name, pass, result, about);
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

  ComplianceTest max7ConsecutiveDays() {
    String result = '';
    bool pass = true;
    String name = 'Max 7 consecutive days (with weekend on call exception)';
    String about =
        'A maximum of seven shifts of any length can be rostered or worked on seven consecutive days. Where seven shifts of any length are rostered or worked on seven consecutive days, there must be a minimum 48-hours’ rest rostered immediately following the conclusion of the seventh shift. Where the work schedule of a doctor rostered for on-call duty on a Saturday and Sunday contains 3 hours or fewer of work on each day, and no more than 3 episodes of work on each day, then such duty is defined as ‘low intensity’. In such a ‘low intensity’ working pattern a maximum of 12 days can be rostered or worked consecutively.';

    for (int i = 0; i < rota.duties.length - 1; i++) {
      //If there are 7 more work duties after
      if (rota.duties.length >= i + 8) {
        List<WorkDuty> setOfEight = rota.duties.getRange(i, i + 8).toList();

        //Check if consecutive

        DateTime day1 = new DateTime(setOfEight[0].startTime.year,
            setOfEight[0].startTime.month, setOfEight[0].startTime.day);
        DateTime day7 = new DateTime(setOfEight[6].startTime.year,
            setOfEight[6].startTime.month, setOfEight[6].startTime.day);
        DateTime day8 = new DateTime(setOfEight[7].startTime.year,
            setOfEight[7].startTime.month, setOfEight[7].startTime.day);

        WorkDuty? saturdayDuty = setOfEight.firstWhereOrNull(
            (item) => item.startTime.weekday == 6 && item is OnCall);
        WorkDuty? sundayDuty = setOfEight.firstWhereOrNull(
            (item) => item.startTime.weekday == 7 && item is OnCall);

        if ((saturdayDuty == null || sundayDuty == null) ||
            ((saturdayDuty as OnCall).expectedHours > 3 ||
                (saturdayDuty as OnCall).expectedHours > 3)) {
          if (day1.add(Duration(days: 7)).compareTo(day8) >= 0) {
            pass = false;
            result +=
                'More than 7 consecutive shifts starting ${rota.duties[i].startTime.dateFormatToString()}\n';
          } else if (day1.add(Duration(days: 6)).compareTo(day7) >= 0) {
            Duration gap = rota.duties[i + 7].startTime
                .difference(rota.duties[i + 6].endTime);
            if (gap.inHours < 48) {
              pass = false;
              result +=
                  'Less than 48 hours break after ${rota.duties[i + 6].endTime.dateFormatToString()}\n';
            }
          }
        } else {
          if (rota.duties.length >= i + 13) {
            List<WorkDuty> setOfThirteen =
                rota.duties.getRange(i, i + 13).toList();
            DateTime day12 = new DateTime(
                setOfThirteen[11].startTime.year,
                setOfThirteen[11].startTime.month,
                setOfThirteen[11].startTime.day);
            DateTime day13 = new DateTime(
                setOfThirteen[12].startTime.year,
                setOfThirteen[12].startTime.month,
                setOfThirteen[12].startTime.day);

            if (day1.add(Duration(days: 12)).compareTo(day13) >= 0) {
              pass = false;
              result +=
                  'More than 12 consecutive shifts starting ${rota.duties[i].startTime.dateFormatToString()} (Low intensity on call over Saturday/Sunday)\n';
            } else if (day1.add(Duration(days: 11)).compareTo(day12) >= 0) {
              Duration gap = rota.duties[i + 12].startTime
                  .difference(rota.duties[i + 11].endTime);
              if (gap.inHours < 48) {
                pass = false;
                result +=
                    'Less than 48 hours break after ${rota.duties[i + 11].endTime.dateFormatToString()}\n';
              }
            }
          }
        }
      }
    }

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest atLeast11HoursRest() {
    String result = '';
    bool pass = true;
    String name = 'At least 11 hours rest between shifts';
    String about =
        'Unless other rest rules apply, there should normally be at least 11 hours’ continuous rest between rostered shifts, other than on-call duty periods.';

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

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest nightRestBreaks() {
    String result = '';
    bool pass = true;
    String name = 'At least 46 hours rest after night shifts';
    String about =
        'Where shifts (excluding non-resident on-call shifts) have at least 3 hours of work that falls into the period between 23:00 and 06:00 and are rostered singularly, or consecutively, then there must be a minimum 46-hour rest period rostered immediately following the conclusion of the shift(s).';

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

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest weekendFrequency() {
    String result = '';
    bool pass = true;
    String name = 'Max 1 in 2 weekend frequency';
    String about =
        'No doctor shall be rostered for work at the weekend (defined for this purpose as any shifts or on-call duty periods where any work takes place between 00.01 Saturday and 23.59 Sunday) at a frequency of greater than 1 week in 2.';

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

    if (!weekendWork.contains(1)) {
      result += 'No weekends worked';
    } else {
      result +=
          'Weekend frequency 1 in ${double.parse((1 / weekendWork.average).toStringAsFixed(2))}';
    }

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest max24HourOnCall() {
    String result = '';
    bool pass = true;
    String name = 'Max 24 hour on call';
    String about =
        'The maximum length of an individual on-call duty period is 24 hours.';

    for (OnCall onCall in onCallInRota) {
      if (onCall.length > 24) {
        result +=
            'On call on ${onCall.startTime.dateFormatToString()} is longer than 24 hours\n';
        pass = false;
      }
    }

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest noConsecutiveOnCalls() {
    String result = '';
    bool pass = true;
    String name = 'No consecutive on calls (with exception of weekends)';
    String about =
        'On-call periods cannot be worked consecutively, other than at the weekend when two consecutive on-call periods (beginning on Saturday and Sunday respectively) are permitted.';

    //Cycle through all on calls
    for (int i = 0; i < onCallInRota.length - 1; i++) {
      if (onCallInRota[i]
          .startTime
          .add(Duration(days: 1))
          .isSameDate(onCallInRota[i + 1].startTime)) {
        if (onCallInRota[i].startTime.weekday != 6) {
          //this would mean it is not a saturday and sunday
          result +=
              'Consecutive on calls on ${onCallInRota[i].startTime.dateFormatToString()} and ${onCallInRota[i + 1].startTime.dateFormatToString()} (not Saturday & Sunday)\n';
          pass = false;
        }
      }
    }

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest noMoreThan3OnCallsIn7Days() {
    String result = '';
    bool pass = true;
    String name = 'No more than 3 on calls in 7 days';
    String about =
        'There must be no more than three on-call periods in any period of seven consecutive days.';

    for (int i = 0; i < rotaLength; i++) {
      //Get midnight on the first day to be checked
      DateTime setMidnight = DateTime(rota.duties[0].startTime.year,
          rota.duties[0].startTime.month, rota.duties[0].startTime.day);

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

      //Selects all the on calls with start or end time within window
      List<OnCall> thisWeekOnCalls = onCallInRota
          .where((item) =>
              startDateTime.compareTo(item.startTime) <= 0 &&
                  endDateTime.compareTo(item.startTime) > 0 ||
              startDateTime.compareTo(item.endTime) < 0 &&
                  endDateTime.compareTo(item.endTime) >= 0)
          .toList();

      if (thisWeekOnCalls.length > 3) {
        result +=
            '${thisWeekOnCalls.length} on calls in 7 day period (midnight ${startDateTime.dateFormatToString()} to midnight ${endDateTime.dateFormatToString()})\n';
        pass = false;
      }
    }

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest dayAfterOnCallMustNotHaveWorkLongerThan10Hours() {
    String result = '';
    bool pass = true;
    String name = 'Day after on call must not have work longer than 10 hours';
    String about =
        'The day following an on-call period (or following the last on-call period, where more than one 24-hour period is rostered consecutively) must not be rostered to last longer than 10 hours.';

    //Cycle through all on calls
    for (int i = 0; i < onCallInRota.length; i++) {
      if (i < onCallInRota.length - 1) {
        if (onCallInRota[i]
            .startTime
            .add(Duration(days: 1))
            .isSameDate(onCallInRota[i + 1].startTime)) {
          if (onCallInRota[i].startTime.weekday == 6) {
            //ignore the rest if it is consecutive weekend on calls
            continue;
          }
        }
      }

      //find if there is a shift or on call the next day
      WorkDuty? nextDayWork = rota.duties.firstWhereOrNull((item) => item
          .startTime
          .isSameDate(onCallInRota[i].startTime.add(Duration(days: 1))));
      if (nextDayWork != null) {
        if (nextDayWork is Shift) {
          if (nextDayWork.length > 10) {
            result +=
                'More than 10 hours work on day after on call on ${onCallInRota[i].startTime.dateFormatToString()}\n';
            pass = false;
          }
        } else {
          if ((nextDayWork as OnCall).expectedHours > 10) {
            result +=
                'More than 10 hours work on day after on call on ${onCallInRota[i].startTime.dateFormatToString()}\n';
            pass = false;
          }
        }
      }
    }

    return ComplianceTest(name, pass, result, about);
  }

  ComplianceTest eightHoursRestPer24HourOnCall() {
    String result = '';
    bool pass = true;
    String name = 'At least 8 hours rest during 24 hour on calls';
    String about =
        'Whilst on-call, a doctor should expect to get eight hours rest per 24-hour period, of which at least five should be continuous rest between 22:00 and 07:00.';

    //Cycle through all on calls
    for (int i = 0; i < onCallInRota.length; i++) {
      if (onCallInRota[i].length == 24) {
        if (onCallInRota[i].expectedHours > 16) {
          result +=
              'Less than 8 hours rest expected during on call on ${onCallInRota[i].startTime.dateFormatToString()}\n';
          pass = false;
        }
      }
    }

    return ComplianceTest(name, pass, result, about);
  }

  DateTime weekStart(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
