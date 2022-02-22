import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/empty_rota_exception.dart';
import 'package:rota_checker/model/rota.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/constants.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/on_call.dart';
import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/rota_length_exception.dart';
import 'package:rota_checker/model/compliance_test.dart';
import 'package:rota_checker/model/compliance.dart';
import 'dart:convert';

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
    state.displayDate = DateTime(state.displayDate.year,
        state.displayDate.month + 1, state.displayDate.day);
    state = state.clone();
  }

  void subtractMonth() {
    state.displayDate = DateTime(state.displayDate.year,
        state.displayDate.month - 1, state.displayDate.day);
    state = state.clone();
  }

  void addWeek() {
    state.displayDate = DateTime(state.displayDate.year,
        state.displayDate.month, state.displayDate.day + 7);
    state = state.clone();
  }

  void subtractWeek() {
    state.displayDate = DateTime(state.displayDate.year,
        state.displayDate.month, state.displayDate.day - 7);
    state = state.clone();
  }

  void loadTemplatesFromString(String jsonString) {
    List<dynamic> parsed = json.decode(jsonString) as List;
    List<Template> templates = [];
    for (dynamic item in parsed) {
      Map<String, dynamic> result = json.decode(item);
      if (result['type'] == 'shift') {
        ShiftTemplate template = ShiftTemplate.fromJson(result);
        templates.add(template);
      } else {
        OnCallTemplate template = OnCallTemplate.fromJson(result);
        templates.add(template);
      }
    }
    for (Template template in templates) {
      state.colourTracker[kTemplateColors.indexOf(template.colour)]++;
    }
    state.templateLibrary = templates;
    state = state.clone();
  }

  void addTemplate(String name, TimeOfDay startTime, double length,
      bool isOnCall, double? expectedHours) {
    if (!isOnCall) {
      ShiftTemplate template = ShiftTemplate(
          name,
          DateTime(2022, 1, 1, startTime.hour, startTime.minute),
          length,
          kTemplateColors[state.getColour()]);
      state.templateLibrary.add(template);
    } else {
      OnCallTemplate template = OnCallTemplate(
          name,
          DateTime(2022, 1, 1, startTime.hour, startTime.minute),
          length,
          kTemplateColors[state.getColour()],
          expectedHours!);
      state.templateLibrary.add(template);
    }
    state.colourTracker[state.getColour()]++;
    state = state.clone();
  }

  void addDefaultTemplate() {
    addTemplate(
        'Example Shift', TimeOfDay(hour: 9, minute: 0), 8.5, false, null);
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
    state.colourTracker[kTemplateColors.indexOf(template.colour)]--;
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

  String dutiesAsJson() {
    List<String> dutiesJsons = [];
    for (WorkDuty duty in state.duties) {
      dutiesJsons.add(json.encode(duty.toJson()));
    }
    return json.encode(dutiesJsons);
  }

  String templatesAsJson() {
    List<String> templateJsons = [];
    for (Template template in state.templateLibrary) {
      templateJsons.add(json.encode(template.toJson()));
    }
    return json.encode(templateJsons);
  }

  void loadDutiesFromString(String jsonString) {
    List<dynamic> parsed = json.decode(jsonString) as List;
    List<WorkDuty> duties = [];
    for (dynamic item in parsed) {
      Map<String, dynamic> result = json.decode(item);
      if (result['type'] == 'shift') {
        Shift shift = Shift.fromJson(result);
        duties.add(shift);
      } else {
        OnCall onCall = OnCall.fromJson(result);
        duties.add(onCall);
      }
    }
    state.duties = duties;
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
