import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/model/rota.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/on_call.dart';

class DataProvider extends StateNotifier<Rota> {
  DataProvider(Rota rota) : super(rota);

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

  List<String> addTemplateToDates() {
    List<String> errorMessages = [];
    if (state.selectedTemplate is ShiftTemplate) {
      for (DateTime date in state.selectedDates) {
        try {
          state.addShift(date, state.selectedTemplate! as ShiftTemplate);
        } catch (e) {
          errorMessages.add(e.toString());
        }
      }
    } else {
      for (DateTime date in state.selectedDates) {
        try {
          state.addOnCall(date, state.selectedTemplate! as OnCallTemplate);
        } catch (e) {
          errorMessages.add(e.toString());
        }
      }
    }
    state.selectedDates.clear();
    state = state.clone();
    return errorMessages;
  }

  List<WorkDuty> getDutiesOnDate(DateTime date) {
    return state.duties
        .where((item) => item.startTime.isSameDate(date))
        .toList();
  }
}
