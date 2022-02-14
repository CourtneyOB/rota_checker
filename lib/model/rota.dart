import 'package:collection/collection.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/model/on_call.dart';
import 'package:rota_checker/shift_overlap_exception.dart';
import 'package:rota_checker/extension_methods.dart';

class Rota {
  DateTime displayDate;
  List<Template> templateLibrary = [
    ShiftTemplate(
        'Example Shift', DateTime(2022, 1, 1, 9, 00), 8.5, kTemplateColors[0]),
    OnCallTemplate('Example On Call', DateTime(2022, 1, 1, 9, 00), 24.0,
        kTemplateColors[1], 4.0),
  ];
  int currentColour = 3;
  Template? selectedTemplate;
  List<DateTime> selectedDates = [];
  List<WorkDuty> duties = [];

  Rota() : this.displayDate = DateTime.now() {
    addShift(DateTime(2022, 2, 14), templateLibrary[0] as ShiftTemplate);
  }

  Rota clone() {
    return Rota()
      ..displayDate = this.displayDate
      ..templateLibrary = this.templateLibrary
      ..selectedTemplate = this.selectedTemplate
      ..selectedDates = this.selectedDates
      ..duties = this.duties
      ..currentColour = this.currentColour;
  }

  void addShift(DateTime date, ShiftTemplate template) {
    Shift newShift = Shift(date, template);
    if (checkDutyOverlaps(newShift)) {
      duties.add(newShift);
      duties.sort((a, b) {
        return a.startTime.compareTo(b.startTime);
      });
    } else {
      throw ShiftOverlapException(
          newShift.template.name, date.dateFormatToString());
    }
  }

  void addOnCall(DateTime date, OnCallTemplate template) {
    OnCall newOnCall = OnCall(date, template);
    if (checkDutyOverlaps(newOnCall)) {
      duties.add(newOnCall);
      duties.sort((a, b) {
        return a.startTime.compareTo(b.startTime);
      });
    } else {
      throw ShiftOverlapException(
          newOnCall.template.name, date.dateFormatToString());
    }
  }

  bool checkDutyOverlaps(WorkDuty newDuty) {
    List<WorkDuty> existingDuties = [];
    if (newDuty is Shift) {
      existingDuties = getAllShifts();
    } else {
      existingDuties = getAllOnCalls();
    }
    for (WorkDuty existingDuty in existingDuties) {
      if (existingDuty.startTime.compareTo(newDuty.startTime) <= 0 &&
          newDuty.startTime.compareTo(existingDuty.endTime) < 0) {
        return false;
      } else if (existingDuty.endTime.compareTo(newDuty.endTime) >= 0 &&
          newDuty.endTime.compareTo(existingDuty.startTime) > 0) {
        return false;
      } else if (existingDuty.startTime.compareTo(newDuty.startTime) >= 0 &&
          newDuty.endTime.compareTo(existingDuty.endTime) >= 0) {
        return false;
      }
    }
    return true;
  }

  List<Shift> getAllShifts() {
    return duties.whereType<Shift>().toList();
  }

  List<OnCall> getAllOnCalls() {
    return duties.whereType<OnCall>().toList();
  }

  List<WorkDuty> getDutiesByTemplate(Template template) {
    return duties.where((item) => item.template == template).toList();
  }

  void resetTemplate(Template oldTemplate, Template newTemplate) {
    List<WorkDuty> dutiesUsingTemplate = getDutiesByTemplate(oldTemplate);
    int index = templateLibrary.indexOf(oldTemplate);
    templateLibrary[index] = newTemplate;
    for (WorkDuty duty in dutiesUsingTemplate) {
      duties.remove(duty);
      if (duty is Shift) {
        try {
          addShift(duty.startTime, newTemplate as ShiftTemplate);
        } catch (e) {}
      } else {
        try {
          addOnCall(duty.startTime, newTemplate as OnCallTemplate);
        } catch (e) {}
      }
    }
  }

  void nextColour() {
    currentColour++;
    if (currentColour >= kTemplateColors.length) {
      currentColour = 0;
    }
  }
}
