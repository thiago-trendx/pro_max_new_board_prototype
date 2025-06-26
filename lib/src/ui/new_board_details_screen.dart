import 'dart:async';
import 'dart:typed_data';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

import '../constants/enums.dart';
import '../constants/pro_max_protocol.dart';
import '../constants/treadmill_values.dart';

class NewBoardDetailsWidget extends StatefulWidget {
  final SerialPort newBoardPort;
  const NewBoardDetailsWidget({
    required this.newBoardPort,
    Key? key,
  }) : super(key: key);

  @override
  State<NewBoardDetailsWidget> createState() => _PortDetailsScreenState();
}

class _PortDetailsScreenState extends State<NewBoardDetailsWidget> {
  String? response;

  late final SerialPort port;

  StreamSubscription<Uint8List>? subscription;

  @override
  void initState() {
    super.initState();

    port = widget.newBoardPort;

    AppLifecycleListener(
      onInactive: () => port.close(),
      onResume: () => port.openReadWrite(),
    );
  }

  @override
  void dispose() {
    port.close();
    port.dispose();
    subscription?.cancel();
    subscription = null;
    super.dispose();
  }

  void _initializePort() {
    if (port.isOpen) return;

    port.openReadWrite();

    port.config = SerialPortConfig()
      ..baudRate = 9600
      ..bits = 8
      ..stopBits = 1
      ..parity = SerialPortParity.none
      ..setFlowControl(SerialPortFlowControl.none);

    _listenToPort();
  }

  void _listenToPort() {
    SerialPortReader reader = SerialPortReader(port, timeout: 20);

    subscription = reader.stream.listen((data) {
      setState(() {
        response = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      });
      EasyThrottle.throttle(
        'command-throttler',
        const Duration(milliseconds: 100),
            () async => await _sendCommandToTreadmill(data)
      );
    });
  }

  Future<void> _sendCommandToTreadmill(List<int> intResponse) async {
    if (intResponse.isEmpty) return;
    if (intResponse[0] == 0xaa && intResponse[1] == 0x00) return;

    if (intResponse[0] == 0xaa && intResponse[1] == 0x01) {
      double currentSpeed = TreadmillValues.instance.speed.value;
      if (currentSpeed >= 22) return;
      await RM6T6Protocol.sendCommand(
        value: (currentSpeed * 10 + 1) / 10,
        commandType: WriteCommandType.speed,
      );
    }
    if (intResponse[0] == 0xaa && intResponse[1] == 0x02) {
      double currentSpeed = TreadmillValues.instance.speed.value;
      if (currentSpeed <= 0) return;
      await RM6T6Protocol.sendCommand(
          value: (currentSpeed * 10 - 1) / 10,
          commandType: WriteCommandType.speed,
      );
    }
    if (intResponse[0] == 0xaa && intResponse[1] == 0x04) {
      int currentInclination = TreadmillValues.instance.inclination.value;
      if (currentInclination >= 15) return;
      await RM6T6Protocol.sendCommand(
          value: currentInclination + 1,
          commandType: WriteCommandType.inclination,
      );
    }
    if (intResponse[0] == 0xaa && intResponse[1] == 0x08) {
      int currentInclination = TreadmillValues.instance.inclination.value;
      if (currentInclination <= 1) return;
      await RM6T6Protocol.sendCommand(
          value: currentInclination - 1,
          commandType: WriteCommandType.inclination,
      );
    }
  }

  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Text(
              '${widget.newBoardPort.name} Control Panel',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _initializePort,
              child: const Text('Initialize Port'),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                const Text(
                  'CURRENT VALUE:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '$response',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
