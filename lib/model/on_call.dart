import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/template.dart';
import 'dart:convert';

class OnCall extends WorkDuty {
  double expectedHours = 0;
  OnCall(DateTime startTime, Template template)
      : expectedHours = (template as OnCallTemplate).expectedHours,
        super(startTime, template);

  factory OnCall.fromJson(Map<String, dynamic> jsonMap) {
    return OnCall(
        DateTime(
            jsonMap['startYear'], jsonMap['startMonth'], jsonMap['startDay']),
        OnCallTemplate.fromJson(json.decode(jsonMap['template'])));
  }

  Map<String, dynamic> toJson() => {
        'type': 'onCall',
        'startYear': startTime.year,
        'startMonth': startTime.month,
        'startDay': startTime.day,
        'template': json.encode(template.toJson())
      };
}
