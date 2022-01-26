import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/template.dart';

class OnCall extends WorkDuty {
  double expectedHours;

  OnCall(DateTime startTime, DateTime endTime, this.expectedHours,
      Template template)
      : super(startTime, endTime, template);
}
