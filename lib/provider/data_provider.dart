import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/empty_rota_exception.dart';
import 'package:rota_checker/model/rota.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/constants.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/rota_length_exception.dart';
import 'package:rota_checker/model/compliance_test.dart';
import 'package:rota_checker/model/compliance.dart';

class DataProvider extends StateNotifier<Rota> {
  DataProvider(Rota rota) : super(rota);

  List<ComplianceTest> checkCompliance() {
    List<ComplianceTest> results = [];

    try {
      results = Compliance(state).checkAll();
    } catch (e) {
      if (e is RotaLengthException) {
        throw RotaLengthException();
      } else {
        throw EmptyRotaException();
      }
    }

    return results;
  }

  void addMonth() {
    state.displayMonth = DateTime(state.displayMonth.year,
        state.displayMonth.month + 1, state.displayMonth.day);
    state = state.clone();
  }

  void subtractMonth() {
    state.displayMonth = DateTime(state.displayMonth.year,
        state.displayMonth.month - 1, state.displayMonth.day);
    state = state.clone();
  }

  void addTemplate(String name, TimeOfDay startTime, double length,
      bool isOnCall, double? expectedHours) {
    if (!isOnCall) {
      state.templateLibrary.add(ShiftTemplate(
          name,
          DateTime(2022, 1, 1, startTime.hour, startTime.minute),
          length,
          kTemplateColors[state.currentColour]));
    } else {
      state.templateLibrary.add(OnCallTemplate(
          name,
          DateTime(2022, 1, 1, startTime.hour, startTime.minute),
          length,
          kTemplateColors[state.currentColour],
          expectedHours!));
    }
    state.nextColour();
    state = state.clone();
  }

  void editTemplate(Template template, String name, TimeOfDay startTime,
      double length, bool isOnCall, double? expectedHours) {
    if (isOnCall) {
      Template newTemplate = OnCallTemplate(
          name,
          DateTime(2022, 1, 1, startTime.hour, startTime.minute),
          length,
          template.colour,
          expectedHours!);
      state.resetTemplate(template, newTemplate);
    } else {
      Template newTemplate = ShiftTemplate(
          name,
          DateTime(2022, 1, 1, startTime.hour, startTime.minute),
          length,
          template.colour);
      state.resetTemplate(template, newTemplate);
    }
    state = state.clone();
  }

  void deleteTemplate(Template template) {
    List<WorkDuty> duties = state.getDutiesByTemplate(template);
    for (WorkDuty duty in duties) {
      state.duties.remove(duty);
    }
    state.templateLibrary.remove(template);
    state = state.clone();
  }

  void selectTemplate(int index) {
    if (state.selectedTemplate == state.templateLibrary[index]) {
      state.selectedTemplate = null;
    } else {
      state.selectedTemplate = state.templateLibrary[index];
    }
    state = state.clone();
  }

  void selectDate(DateTime date) {
    if (state.selectedDates.contains(date)) {
      state.selectedDates.remove(date);
    } else {
      state.selectedDates.add(date);
    }
    state = state.clone();
  }

  List<String> addTemplateToDates({Template? template}) {
    List<String> errorMessages = [];
    Template templateToAdd =
        template == null ? state.selectedTemplate! : template;
    if (templateToAdd is ShiftTemplate) {
      for (DateTime date in state.selectedDates) {
        try {
          state.addShift(date, templateToAdd as ShiftTemplate);
        } catch (e) {
          errorMessages.add(e.toString());
        }
      }
    } else {
      for (DateTime date in state.selectedDates) {
        try {
          state.addOnCall(date, templateToAdd as OnCallTemplate);
        } catch (e) {
          errorMessages.add(e.toString());
        }
      }
    }
    state.selectedDates.clear();
    state = state.clone();
    return errorMessages;
  }

  List<String> addTemplateToDraggedDate(Template template, DateTime date) {
    List<String> errorMessages = [];
    if (template is ShiftTemplate) {
      try {
        state.addShift(date, template as ShiftTemplate);
      } catch (e) {
        errorMessages.add(e.toString());
      }
    } else {
      try {
        state.addOnCall(date, template as OnCallTemplate);
      } catch (e) {
        errorMessages.add(e.toString());
      }
    }
    state = state.clone();
    return errorMessages;
  }

  void removeTemplateFromDate(Template template, DateTime date) {
    WorkDuty dutyToRemove = state.duties.firstWhere(
        (item) => item.startTime.isSameDate(date) && item.template == template);
    state.duties.remove(dutyToRemove);
    state = state.clone();
  }

  void clearCalendar() {
    state.duties.clear();
    state.selectedDates.clear();
    state = state.clone();
  }

  List<WorkDuty> getDutiesOnDate(DateTime date) {
    return state.duties
        .where((item) => item.startTime.isSameDate(date))
        .toList();
  }
}
