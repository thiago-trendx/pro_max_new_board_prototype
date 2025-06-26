import 'package:flutter/cupertino.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class TreadmillValues {
  static TreadmillValues instance = TreadmillValues();

  ValueNotifier<double> speed = ValueNotifier<double>(0.0);
  ValueNotifier<int> inclination = ValueNotifier<int>(1);
  ValueNotifier<String> lastCommandSent = ValueNotifier<String>('');
  ValueNotifier<SerialPort?> proMaxSerialPort = ValueNotifier<SerialPort?>(null);


  void setInclination(int newValue) => inclination.value = newValue;
  void setSpeed(double newValue) => speed.value = newValue;
  void setLastCommandSent(String newValue) => lastCommandSent.value = newValue;
  void setProMaxSerialPort(SerialPort port) => proMaxSerialPort.value = port;

}