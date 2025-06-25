import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import '../constants/pro_max_commands.dart';

class ProMaxDetailsScreen extends StatefulWidget {
  final SerialPort portName;
  const ProMaxDetailsScreen({
    required this.portName,
    Key? key,
  }) : super(key: key);

  @override
  State<ProMaxDetailsScreen> createState() => _PortDetailsScreenState();
}

class _PortDetailsScreenState extends State<ProMaxDetailsScreen> {
  String? response;
  String? lastCommandSent;
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
    SerialPortReader reader = SerialPortReader(port);

    subscription = reader.stream.listen((data) {
      setState(() {
        response = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      });
    });
  }

  // ==========================================================

  void _sendData(Uint8List data) {
    port.write(data);

    setState(() {
      lastCommandSent = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    });
  }

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
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.initialize),
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.verifyError),
              child: const Text('Verify Error'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.stop0xff),
              child: const Text('Stop 0xff'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.stop0x00),
              child: const Text('Stop 0x00'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.speed1200hz),
              child: const Text('Speed 1200hz'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.speed4000hz),
              child: const Text('Speed 4000hz'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.speed6000hz),
              child: const Text('Speed 6000hz'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.inclination1),
              child: const Text('Inclination 1'),
            ),
            ElevatedButton(
              onPressed: () => _sendData(TreadmillCommands.inclination4),
              child: const Text('Inclination 4'),
            ),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'ULTIMO COMANDO:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      lastCommandSent ?? '',
                      style: const TextStyle(
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
