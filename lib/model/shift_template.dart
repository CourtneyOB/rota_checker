import 'package:rota_checker/model/template.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';

class ShiftTemplate extends Template {
  bool isNight = false;
  bool isLong = false;
  bool isEveningFinish = false;

  ShiftTemplate(
      String name, DateTime startTime, double length, MaterialColor colour)
      : super(name, startTime, length, colour) {
    allocateTags();
  }

  factory ShiftTemplate.fromJson(Map<String, dynamic> json) {
    return ShiftTemplate(
        json['name'],
        DateTime(2022, 1, 1, json['startHour'], json['startMinute']),
        json['length'],
        kTemplateColors[json['colour']]);
  }

  void allocateTags() {
    DateTime sameDay6AM =
        DateTime(startTime.year, startTime.month, startTime.day, 6, 0, 0);
    DateTime sameDay11PM =
        DateTime(startTime.year, startTime.month, startTime.day, 23, 0, 0);
    DateTime nextDay6AM =
        DateTime(startTime.year, startTime.month, startTime.day + 1, 6, 0, 0);

    if (startTime.compareTo(sameDay11PM) <= 0 &&
        startTime.compareTo(sameDay6AM) >= 0) {
      if (endTime.difference(sameDay11PM).inMinutes >= 180) {
        isNight = true;
      }
    } else if (startTime.compareTo(sameDay11PM) > 0 &&
        startTime.compareTo(nextDay6AM) < 0) {
      print('2');
      if (endTime.compareTo(nextDay6AM) >= 0) {
        if (nextDay6AM.difference(startTime).inMinutes >= 180) {
          isNight = true;
        }
      } else if (endTime.difference(startTime).inMinutes >= 180) {
        isNight = true;
      }
    }

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

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': 'shift',
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'length': length,
        'colour': kTemplateColors.indexOf(colour)
      };
}
