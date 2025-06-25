import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:pro_max_new_board_prototype/src/ui/port_details_screen.dart';

class ProMaxNewBoardScreen extends StatefulWidget {
  const ProMaxNewBoardScreen({Key? key}) : super(key: key);

  @override
  State<ProMaxNewBoardScreen> createState() => _SerialScreenState();
}

class _SerialScreenState extends State<ProMaxNewBoardScreen> {
  List<String> availablePorts = SerialPort.availablePorts;

  @override
  void initState() {
    super.initState();
    _initPorts();
  }

  void _initPorts() {
    setState(() => availablePorts = SerialPort.availablePorts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initPorts,
          )
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: List.generate(
            availablePorts.length,
                (index) {
              final port = availablePorts[index];
              return ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PortDetailsScreen(
                      portName: port,
                    ),
                  ),
                ),
                child: Text(port),
              );
            },
          ),
        ),
      ),
    );
  }
}
