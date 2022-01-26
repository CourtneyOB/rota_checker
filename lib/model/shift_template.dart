import 'package:rota_checker/model/template.dart';
import 'package:flutter/material.dart';

class ShiftTemplate extends Template {
  bool isNight = false;
  bool isLong = false;
  bool isEveningFinish = false;

  ShiftTemplate(String name, DateTime startTime, double length, Color colour)
      : super(name, startTime, length, colour) {
    isNight = isNightShift();
    if (!isNight) {
      if (endTime.hour >= 23 || endTime.hour < 2) {
        isEveningFinish = true;
      }
    }
    if (length > 10) {
      if (!isNight) {
        isLong = true;
      }
    }
  }
  bool isNightShift() {
    if (startTime.hour >= 23) {
      DateTime nextDay = startTime.add(Duration(days: 1));
      DateTime nextDay6AM =
          DateTime(nextDay.year, nextDay.month, nextDay.day, 6, 0);

      if (nextDay6AM.compareTo(endTime) <= 0) {
        Duration duration = nextDay6AM.difference(startTime);
        if (duration.inHours >= 3) {
          return true;
        }
      } else {
        Duration duration = endTime.difference(startTime);
        if (duration.inHours >= 3) {
          return true;
        }
      }
    } else if (startTime.hour < 6) {
      DateTime sameDay6AM =
          DateTime(startTime.year, startTime.month, startTime.day, 6, 0);
      if (sameDay6AM.compareTo(endTime) <= 0) {
        Duration duration = sameDay6AM.difference(startTime);
        if (duration.inHours >= 3) {
          return true;
        } else {
          Duration duration = endTime.difference(startTime);
          if (duration.inHours >= 3) {
            return true;
          }
        }
      }
    } else if (endTime.hour < 6) {
      DateTime previousDay = endTime.subtract(Duration(days: 1));
      DateTime previousDay11PM =
          DateTime(previousDay.year, previousDay.month, previousDay.day, 23, 0);

      if (previousDay11PM.compareTo(startTime) >= 0) {
        Duration duration = endTime.difference(previousDay11PM);
        if (duration.inHours >= 3) {
          return true;
        }
      } else {
        Duration duration = endTime.difference(startTime);
        if (duration.inHours >= 3) {
          return true;
        }
      }
    } else {
      if (DateTime(startTime.year, startTime.month, startTime.day)
              .add(Duration(days: 1)) ==
          DateTime(endTime.year, endTime.month, endTime.day)) {
        return true;
      }
    }
    return false;
  }
}
