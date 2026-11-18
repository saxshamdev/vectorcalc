import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'state/calc_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = CalcState();
  // Show the boot screen immediately; settings restore in the background.
  runApp(VectorCalcApp(state: state));
  unawaited(state.load());
}
