import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import '../constants/enums.dart';
import '../constants/runway_commands.dart';
import '../constants/runway_protocol.dart';
import '../constants/treadmill_values.dart';

class RunWayDetailsScreen extends StatefulWidget {
  final SerialPort portName;
  const RunWayDetailsScreen({
    required this.portName,
    Key? key,
  }) : super(key: key);

  @override
  State<RunWayDetailsScreen> createState() => _PortDetailsScreenState();
}

class _PortDetailsScreenState extends State<RunWayDetailsScreen> {
  String? response;
  late final SerialPort port;
  StreamSubscription<Uint8List>? subscription;
  Timer? _normalPacketTimer;

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
    _cancelPacketTimer();
    _normalPacketTimer = null;
    super.dispose();
  }

  void _initializePort() {
    if (port.isOpen) return;

    port.openReadWrite();

    port.config = SerialPortConfig()
      ..baudRate = 38400
      ..bits = 8
      ..stopBits = 1
      ..parity = SerialPortParity.none
      ..setFlowControl(SerialPortFlowControl.none);

    _initNormalPacketTimer();
    _listenToPort();
  }

  Future<void> _initNormalPacketTimer() async {
    _cancelPacketTimer();
    print('aqui iniciando timer');
    _normalPacketTimer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) async {
      List<int> normalDataPacket = [0xff, 0x41, 0x01, 0x8f, 0xbe, 0xfe];
      port.write(Uint8List.fromList(normalDataPacket));
    });
  }

  void _cancelPacketTimer() {
    print('aqui cancelando timer');
    _normalPacketTimer?.cancel();
  }


  void _listenToPort() {
    SerialPortReader reader = SerialPortReader(port);
    subscription = reader.stream.listen((data) {
      if (data[2] == 0x41) return;
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
                    A133Protocol.sendControlCommand(
                      instructionType: A133InstructionTypes.startTreadmill,
                      commandType: A133CommandTypes.writeControlCommand,
                    );
                  },
                  child: const Text('START'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendControlCommand(
                    instructionType: A133InstructionTypes.stopTreadmill,
                    commandType: A133CommandTypes.writeControlCommand,
                  ),
                  child: const Text('STOP'),
                ),
                // const SizedBox(width: 30),
                // ElevatedButton(
                //   onPressed: () => _reservedCommand(TreadmillCommands.readNormalDataPacket),
                //   child: const Text('Verify Error'),
                // ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 1,
                      parameterIndex: A133ParameterIndexTypes.setSpeed,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 01'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 2,
                      parameterIndex: A133ParameterIndexTypes.setSpeed,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 02'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 3,
                      parameterIndex: A133ParameterIndexTypes.setSpeed,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 03'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 4,
                      parameterIndex: A133ParameterIndexTypes.setSpeed,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 04'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 5,
                      parameterIndex: A133ParameterIndexTypes.setSpeed,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 05'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 6,
                    parameterIndex: A133ParameterIndexTypes.setSpeed,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 06'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 7,
                    parameterIndex: A133ParameterIndexTypes.setSpeed,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 07'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 8,
                    parameterIndex: A133ParameterIndexTypes.setSpeed,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 08'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 9,
                    parameterIndex: A133ParameterIndexTypes.setSpeed,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Speed 09'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 10,
                    parameterIndex: A133ParameterIndexTypes.setSpeed,
                    commandType: A133CommandTypes.writeOneParam,
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
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 1,
                    parameterIndex: A133ParameterIndexTypes.setInclination,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Inclination 01'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 2,
                    parameterIndex: A133ParameterIndexTypes.setInclination,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Inclination 02'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 3,
                    parameterIndex: A133ParameterIndexTypes.setInclination,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Inclination 03'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                    value: 4,
                    parameterIndex: A133ParameterIndexTypes.setInclination,
                    commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Inclination 04'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 5,
                      parameterIndex: A133ParameterIndexTypes.setInclination,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Inclination 05'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 6,
                      parameterIndex: A133ParameterIndexTypes.setInclination,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Inclination 06'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 7,
                      parameterIndex: A133ParameterIndexTypes.setInclination,
                      commandType: A133CommandTypes.writeOneParam,
                  ),
                  child: const Text('Inclination 07'),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => A133Protocol.sendOneParamCommand(
                      value: 8,
                      parameterIndex: A133ParameterIndexTypes.setInclination,
                      commandType: A133CommandTypes.writeOneParam,
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
                    ValueListenableBuilder(
                      valueListenable: TreadmillValues.instance.lastCommandSent,
                      builder: (BuildContext context, String? lastCmd, Widget? child) {
                        return Text(
                          lastCmd ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        );
                      },
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
}
