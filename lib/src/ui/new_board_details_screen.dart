import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class NewBoardDetailsWidget extends StatefulWidget {
  final SerialPort portName;
  const NewBoardDetailsWidget({
    required this.portName,
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

    port = widget.portName;

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
    });
  }

  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _initializePort,
              child: const Text('Initialize Port'),
            ),
            // ElevatedButton(
            //   onPressed: () => _sendData(),
            //   child: const Text('Start'),
            // ),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Column(
                  children: [
                    Text(
                      'ULTIMO COMANDO:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'RESPOSTA:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      '$response',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
