import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import '../constants/enums.dart';
import '../constants/pro_max_commands.dart';
import '../constants/pro_max_protocol.dart';
import '../constants/treadmill_values.dart';

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              '${widget.portName.name} Control Panel',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _initializePort,
                  child: const Text('Initialize Port'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () {
                    if (TreadmillValues.instance.speed.value == 0) {
                      TreadmillValues.instance.setSpeed(1);
                    }
                    _reservedCommand(TreadmillCommands.initialize);
                  },
                  child: const Text('START'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => _reservedCommand(TreadmillCommands.stop0x00),
                  child: const Text('STOP'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => _reservedCommand(TreadmillCommands.verifyError),
                  child: const Text('Verify Error'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 1, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 01'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 2, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 02'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 3, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 03'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 4, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 04'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 5, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 05'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 6, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 06'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 7, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 07'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 8, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 08'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 9, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 09'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 10, commandType: WriteCommandType.speed
                  ),
                  child: const Text('Speed 10'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 1, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 01'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 2, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 02'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 3, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 03'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                    value: 4, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 04'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 5, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 05'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 6, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 06'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 7, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 07'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => sendCommand(
                      value: 8, commandType: WriteCommandType.inclination
                  ),
                  child: const Text('Inclination 08'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'LAST COMMAND:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      lastCommandSent ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'LAST RESPONSE:',
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
            const SizedBox(height: 10),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> sendCommand({
    required int value,
    required WriteCommandType commandType
  }) async => await RM6T6Protocol.sendCommand(
      value: value,
      commandType: commandType,
      port: port
  );

  Future<void> _reservedCommand(command) async {
    port.write(Uint8List.fromList(command));
    setState(() {
      lastCommandSent = command.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    });
  }
}
