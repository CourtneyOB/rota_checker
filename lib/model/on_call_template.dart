import 'package:rota_checker/model/template.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';

class OnCallTemplate extends Template {
  double expectedHours;
  OnCallTemplate(String name, DateTime startTime, double length,
      MaterialColor colour, this.expectedHours)
      : super(name, startTime, length, colour);

  factory OnCallTemplate.fromJson(Map<String, dynamic> json) {
    return OnCallTemplate(
        json['name'],
        DateTime(2022, 1, 1, json['startHour'], json['startMinute']),
        json['length'],
        kTemplateColors[json['colour']],
        json['expectedHours']);
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': 'onCall',
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'length': length,
        'expectedHours': expectedHours,
        'colour': kTemplateColors.indexOf(colour)
      };
}
