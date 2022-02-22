import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/template.dart';
import 'dart:convert';

class Shift extends WorkDuty {
  Shift(DateTime startTime, Template template) : super(startTime, template);

  factory Shift.fromJson(Map<String, dynamic> jsonMap) {
    return Shift(
        DateTime(
            jsonMap['startYear'], jsonMap['startMonth'], jsonMap['startDay']),
        ShiftTemplate.fromJson(json.decode(jsonMap['template'])));
  }

  Map<String, dynamic> toJson() => {
        'type': 'shift',
        'startYear': startTime.year,
        'startMonth': startTime.month,
        'startDay': startTime.day,
        'template': json.encode(template.toJson())
      };
}
