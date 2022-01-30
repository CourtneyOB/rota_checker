import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/model/rota.dart';
import 'package:rota_checker/model/work_duty.dart';
import 'package:rota_checker/extension_methods.dart';

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

  void addTemplateToDates() {}

  List<WorkDuty> getDutiesOnDate(DateTime date) {
    return state.duties
        .where((item) => item.startTime.isSameDate(date))
        .toList();
  }
}
