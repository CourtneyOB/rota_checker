import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/template.dart';

class OnCall extends WorkDuty {
  OnCall(DateTime startTime, Template template) : super(startTime, template);
}
