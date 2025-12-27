import 'package:flutter/material.dart';

class CounterState {
  int? counterValue;
  String? alpha;

  CounterState({this.counterValue, this.alpha});



  CounterState copyWith({int? counterValue, String? alpha}) {
    return CounterState(
      counterValue: counterValue ?? this.counterValue,
      alpha: alpha ?? this.alpha,
    );
  }
}



