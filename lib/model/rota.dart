import 'package:rota_checker/constants.dart';
import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/on_call_template.dart';

class Rota {
  DateTime displayMonth = DateTime(2022, 1, 1);
  List<Template> templateLibrary = [
    ShiftTemplate('Normal Working Day', DateTime(2022, 1, 1, 9, 00), 8.5,
        kTemplateColors[0]),
    ShiftTemplate(
        'Long Day', DateTime(2022, 1, 1, 9, 00), 13.0, kTemplateColors[1]),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0,
        kTemplateColors[2], 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0,
        kTemplateColors[3], 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0,
        kTemplateColors[4], 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0,
        kTemplateColors[5], 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0,
        kTemplateColors[6], 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0,
        kTemplateColors[0], 4.0),
    OnCallTemplate('24 Hour On Call', DateTime(2022, 1, 1, 9, 30), 24.0,
        kTemplateColors[1], 4.0),
  ];
  Template? selectedTemplate;
  List<DateTime> selectedDates = [];

  Rota clone() {
    return Rota()
      ..displayMonth = this.displayMonth
      ..templateLibrary = this.templateLibrary
      ..selectedTemplate = this.selectedTemplate
      ..selectedDates = this.selectedDates;
  }
}
