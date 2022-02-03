import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/template.dart';

class OnCall extends WorkDuty {
  double expectedHours = 0;
  OnCall(DateTime startTime, Template template)
      : expectedHours = (template as OnCallTemplate).expectedHours,
        super(startTime, template);
}
