import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:pro_max_new_board_prototype/src/constants/treadmill_values.dart';
import 'package:pro_max_new_board_prototype/src/ui/new_board_details_screen.dart';
import 'package:pro_max_new_board_prototype/src/ui/pro_max_details_screen.dart';

class SerialPrototypeScreen extends StatefulWidget {
  const SerialPrototypeScreen({Key? key}) : super(key: key);

  @override
  State<SerialPrototypeScreen> createState() => _SerialScreenState();
}

class _SerialScreenState extends State<SerialPrototypeScreen> {
  List<String> availablePorts = SerialPort.availablePorts;
  List<GoperPort> goperPorts = [];
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _searchPorts();
  }

  void _searchPorts() async {
    isLoading.value = true;
    availablePorts = SerialPort.availablePorts;
    for (var port in SerialPort.availablePorts) {
      final SerialPort serialPort = SerialPort(port);
      await _validatePort(serialPort);
      serialPort.close();
    }
    isLoading.value = false;
    setState(() {});
  }

  Future<void> _validatePort(SerialPort serialPort) async {
    try {
      serialPort.openReadWrite();
      serialPort.write(Uint8List.fromList([0xf6, 0x1a, 0x8b, 0x3e, 0xf4]));
      await Future.delayed(const Duration(milliseconds: 200));
      final Uint8List response = serialPort.read(6);

      if (response[0] == 0xf1) {
        goperPorts.add(GoperPort(serialPort, PortType.proMax));
        return;
      }
      if (response[0] == 0xaa) {
        goperPorts.add(GoperPort(serialPort, PortType.newBoard));
        return;
      }
      goperPorts.add(GoperPort(serialPort, PortType.unidentified));
    } catch (e) {
      goperPorts.add(GoperPort(serialPort, PortType.notAvailable));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Max New Board Prototype'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _searchPorts,
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (BuildContext context, bool isLoading, Widget? child) {
          return isLoading
              ? const Center(
                child: CircularProgressIndicator())
              : SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                          'PORTS DETECTED:',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                      ),
                      Column(
                        children: List.generate(
                          goperPorts.length,
                              (index) {
                            final goperPort = goperPorts[index];
                            return Text(
                                '${goperPort.port.name} '
                                '-- ${goperPort.portType.portTypeText}',
                              style: TextStyle(
                                fontWeight: goperPort.portType == PortType.proMax ||
                                    goperPort.portType == PortType.newBoard
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: goperPort.portType == PortType.notAvailable ||
                                    goperPort.portType == PortType.unidentified
                                      ? Colors.red
                                      : Colors.black
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      Column(
                        children: List.generate(
                          goperPorts.length,
                              (index) {
                            final goperPort = goperPorts[index];
                            if (goperPort.portType == PortType.unidentified
                                || goperPort.portType == PortType.notAvailable) {
                              return Container();
                            }
                            if (goperPort.portType == PortType.newBoard) {
                              return NewBoardDetailsWidget(
                                  newBoardPort: goperPort.port,
                              );
                            }
                            TreadmillValues.instance.setProMaxSerialPort(goperPort.port);
                            return ProMaxDetailsScreen(
                                portName: TreadmillValues.instance.proMaxSerialPort.value!);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Text(
                        'Treadmill Data:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: TreadmillValues.instance.speed,
                            builder: (BuildContext context, double speed, Widget? child) {
                              return Text(
                                'SPEED: $speed',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: TreadmillValues.instance.inclination,
                            builder: (BuildContext context, int inclination, Widget? child) {
                              return Text(
                                'INCLINATION: $inclination',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
          );
        },
      ),
    );
  }
}

class GoperPort {
  SerialPort port;
  PortType portType;

  GoperPort(this.port, this.portType);
}

enum PortType { newBoard, proMax, unidentified, notAvailable }

extension PortTypeExtension on PortType {
  String get portTypeText {
    switch (this) {
      case PortType.newBoard:
        return 'Keyboard button board';
      case PortType.proMax:
        return 'Pro Max treadmill board';
      case PortType.unidentified:
        return 'Unidentified';
      case PortType.notAvailable:
        return 'Not available';
    }
  }
}