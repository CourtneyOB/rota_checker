import 'package:week_of_year/week_of_year.dart';
import 'package:rota_checker/model/template.dart';

abstract class WorkDuty {
  DateTime startTime;
  DateTime endTime = DateTime(2000, 0, 0);
  double length = 0;
  bool isWeekend = false;
  int weekNumber = 0;
  Template template;

  WorkDuty(DateTime date, this.template)
      : startTime = DateTime(date.year, date.month, date.day,
            template.startTime.hour, template.startTime.minute) {
    endTime = startTime.add(Duration(minutes: (template.length * 60).toInt()));
    length = template.length;
    isWeekend =
        (startTime.weekday == 6 || startTime.weekday == 7) ? true : false;
    weekNumber = startTime.weekOfYear;
  }
}
