import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_practices/cubit/counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(counterValue: 0, alpha: "ITBRIDGE"));

  void increment() =>
      emit(state.copyWith(counterValue: (state.counterValue ?? 0) + 1));

  void decrement() =>
      emit(state.copyWith(counterValue: (state.counterValue ?? 0) - 1));

  void addLetter(String letter) =>
      emit(state.copyWith(alpha: (state.alpha ?? "") + letter));

  void removeLetter() {
    if (state.alpha != null && state.alpha!.isNotEmpty) {
      emit(
        state.copyWith(
          alpha: state.alpha!.substring(0, state.alpha!.length - 1),
        ),
      );
    }
    
  }

  void resetLetter() {
    emit(state.copyWith(alpha: "ITBRIDGE"));
  }
}
