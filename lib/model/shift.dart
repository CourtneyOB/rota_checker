import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/template.dart';

class Shift extends WorkDuty {
  Shift(DateTime startTime, DateTime endTime, Template template)
      : super(startTime, endTime, template);
}
