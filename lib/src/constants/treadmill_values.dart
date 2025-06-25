import 'package:flutter/cupertino.dart';

class TreadmillValues {
  static TreadmillValues instance = TreadmillValues();

  ValueNotifier<double> speed = ValueNotifier<double>(0.0);
  ValueNotifier<int> inclination = ValueNotifier<int>(1);
  ValueNotifier<String> lastCommandSent = ValueNotifier<String>('');

  void setInclination(int newValue) => inclination.value = newValue;
  void setSpeed(double newValue) => speed.value = newValue;
  void setLastCommandSent(String newValue) => lastCommandSent.value = newValue;

}