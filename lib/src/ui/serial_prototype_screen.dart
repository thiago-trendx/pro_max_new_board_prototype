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

  @override
  void initState() {
    super.initState();
    _validatePorts();
  }

  void _validatePorts() async {
    availablePorts = SerialPort.availablePorts;

    print('Available ports: ${SerialPort.availablePorts}');

    for (var port in SerialPort.availablePorts) {
      final SerialPort serialPort = SerialPort(port);
      late bool proMaxAvailable;
      late bool newBoardAvailable;
      try {
        // verificar disponibilidade das placas na porta em questão:
        proMaxAvailable = await _checkProMaxTreadmill(serialPort);
        if (!proMaxAvailable) {
          newBoardAvailable = await _checkNewBoard(serialPort);
        }
        // se a porta não tem nenhuma das placas conectadas, retirar da lista:
        if (!proMaxAvailable && !newBoardAvailable) availablePorts.remove(port);
      } catch (e) {
        availablePorts.remove(port);
        continue;
      } finally {
        serialPort.close();
      }
    }

    setState(() {});
  }

  Future<bool> _checkProMaxTreadmill(SerialPort serialPort) async {
    try {
      serialPort.openReadWrite();
      serialPort.write(Uint8List.fromList([0xf6, 0x10, 0x8c, 0xbe, 0xf4]));
      await Future.delayed(const Duration(milliseconds: 250));
      final Uint8List proMaxResponse = serialPort.read(7);
      if (proMaxResponse.isEmpty) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkNewBoard(SerialPort serialPort) async {
    try {
      serialPort.openReadWrite();
      await Future.delayed(const Duration(milliseconds: 250));
      final Uint8List newBoardResponse = serialPort.read(7);
      if (newBoardResponse.isEmpty) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
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
            onPressed: _validatePorts,
          )
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(
              availablePorts.length,
                  (index) {
                final port = availablePorts[index];
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(port),
                      ),
                      availablePorts[index].contains('S3')
                          ? NewBoardDetailsWidget(portName: port)
                          : ProMaxDetailsScreen(portName: port),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
