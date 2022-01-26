import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/on_call_template.dart';

class Rota {
  DateTime displayMonth = DateTime(2022, 1, 1);
  List<Template> templateLibrary = [
    ShiftTemplate('Normal Working Day', DateTime(2022, 1, 1, 9, 00), 8.5),
    ShiftTemplate('Long Day', DateTime(2022, 1, 1, 9, 00), 13.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0, 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0, 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0, 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0, 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0, 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0, 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0, 4.0),
  ];

  Rota clone() {
    return Rota()
      ..displayMonth = this.displayMonth
      ..templateLibrary = this.templateLibrary;
  }
}
