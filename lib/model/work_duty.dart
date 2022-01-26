import 'package:week_of_year/week_of_year.dart';
import 'package:rota_checker/model/template.dart';

abstract class WorkDuty {
  DateTime startTime;
  DateTime endTime;
  double length;
  bool isWeekend;
  int weekNumber;
  Template template;

  WorkDuty(this.startTime, this.endTime, this.template)
      : length = (endTime.difference(startTime).inMinutes / 60),
        isWeekend =
            (startTime.weekday == 6 || startTime.weekday == 7) ? true : false,
        weekNumber = startTime.weekOfYear;
}
