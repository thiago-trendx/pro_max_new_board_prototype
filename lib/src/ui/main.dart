import 'package:flutter/material.dart';
import 'package:pro_max_new_board_prototype/src/ui/pro_max_new_board_screen.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProMaxNewBoardScreen(),
    );
  }
}
