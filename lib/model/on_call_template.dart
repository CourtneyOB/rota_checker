import 'package:rota_checker/model/template.dart';

class OnCallTemplate extends Template {
  double expectedHours;
  OnCallTemplate(
      String name, DateTime startTime, double length, this.expectedHours)
      : super(name, startTime, length);
}
