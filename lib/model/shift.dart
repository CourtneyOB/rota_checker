import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/template.dart';

class Shift extends WorkDuty {
  Shift(DateTime startTime, Template template) : super(startTime, template);
}
