import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
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
      // await _initialOne(serialPort);
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
              child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: List.generate(
                      goperPorts.length,
                          (index) {
                        final goperPort = goperPorts[index];
                        return Text('${goperPort.port.name} '
                            '-- ${goperPort.portType}');
                      },
                    ),
                  ),
                  Column(
                    children: List.generate(
                      goperPorts.length,
                          (index) {
                        final goperPort = goperPorts[index];
                        if (goperPort.portType == PortType.unidentified
                            || goperPort.portType == PortType.notAvailable) {
                          return Container();
                        }
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text(goperPort.port.name ?? ''),
                              ),
                              availablePorts[index].contains('S3')
                                  ? NewBoardDetailsWidget(portName: goperPort.port)
                                  : ProMaxDetailsScreen(portName: goperPort.port),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
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