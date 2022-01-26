import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/model/rota.dart';

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
}
