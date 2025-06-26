import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:pro_max_new_board_prototype/src/constants/treadmill_values.dart';
import 'enums.dart';
import 'package:collection/collection.dart';

abstract class RM6T6Protocol {

  // formatará os dados que serão enviados para o inversor RM6T6,
  // de acordo com o manual (req => ins => data => crc => end)
  static List<int> formatWriteRequisition(
      {required num value, required WriteCommandType type}) {
    List<int> reqAndIns = [0xf6, type.toINS()];
    List<int> dataRaw =
    _getDataFormatted(value: value, multFactor: type.toMultiFactor());
    List<int> dataSplit = _splitCode(dataRaw);
    List<int> crcRaw = _getCrc(type.toINS(), dataRaw);
    List<int> crcSplit = _splitCode(crcRaw);
    List<int> end = [0xf4];

    List<int> finalData = reqAndIns + dataSplit + crcSplit + end;
    return finalData;
  }

  // formatará os dados que serão enviados para o inversor RM6T6,
  // com protocolo de leitura: req => ins => crc => end
  static List<int> formatReadRequisition({required ReadCommandType type}) {
    List<int> reqAndIns = [0xf6, type.toINS()];
    List<int> crc = _getCrc(type.toINS(), []);
    List<int> end = [0xf4];

    List<int> finalData = reqAndIns + crc + end;
    return finalData;
  }

  // formatará os dados de retorno do inversor RM6T6,
  // no padrão ans => ins => data(2 ou 3 bytes) => stu => crc(2 ou 3 bytes) => end
  static double? formatDataReceived(
      {required List<int> answer, required ReadCommandType type}) {
    bool hasSplitOnData = answer[2] == 0xf7 || answer[3] == 0xf7;
    bool hasSplitOnCrc = hasSplitOnData
        ? answer[6] == 0xf7 || answer[7] == 0xf7
        : answer[5] == 0xf7 || answer[6] == 0xf7;
    int stu = hasSplitOnData ? answer[5] : answer[4];
    List<int> data = _getDataBytes(answer, hasSplitOnData);
    List<int> dataRawAndStu = _getDataRaw(data) + [stu];
    List<int> crcCalculated = _splitCode(_getCrc(type.toINS(), dataRawAndStu));
    List<int> crcfromInverter = _getCrcBytes(answer, hasSplitOnData, hasSplitOnCrc);

    bool canContinue = _confirmCRC(crcCalculated, crcfromInverter);

    if (canContinue) {
      int result = int.parse(data.map((n) => n.toString()).join());
      double finalValue = (result / type.toDivideFactor()).toDouble();
      return finalValue;
    } else {
      debugPrint('bytes corrompidos');
      return null;
    }
  }

  static List<int> _getDataBytes(List<int> answer, bool hasSplitOnData) {
    // Determine the number of items to include based on the hasSplitOnData flag
    int endIndex = hasSplitOnData ? 5 : 4;
    return answer.sublist(2, endIndex+1);
  }

  static List<int> _getCrcBytes(List<int> answer, bool hasSplitOnData, bool hasSplitOnCrc) {
    int startIndex = hasSplitOnData ? 6 : 5;
    int endIndex = hasSplitOnData
        ? (hasSplitOnCrc ? 8 : 7)
        : (hasSplitOnCrc ? 7 : 6);
    return answer.sublist(startIndex, endIndex+1);
  }

  static List<int> _getDataRaw(List<int> data) {
    List<int> dataList = data;
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i] == 0xf7) {
        dataList[i] = dataList[i + 1] + 0xf0;
        dataList.removeAt(i + 1);
        break;
      }
    }
    return dataList;
  }

  // formata os bytes referentes ao Data na escrita de comandos
  static List<int> _getDataFormatted({required num value, required num multFactor}) {
    int convertedValue = (value * multFactor).round();

    int partOne = convertedValue >> 8 & 0xFF;
    int partTwo = convertedValue & 0xFF;

    return [partOne, partTwo];
  }

  // faz o split de comandos começando com 0xf para diferenciar dos comandos reservados
  static List<int> _splitCode(List<int> value) {
    final List<int> command = [];

    for (int hexNum in value) {
      if (hexNum >= 0xf0 && hexNum <= 0xf7) {
        int part1 = 0xf7;
        int part2 = hexNum - 0xf0;
        command.add(part1);
        command.add(part2);
      } else {
        command.add(hexNum);
      }
    }

    return command;
  }

  // calcula o CRC (check sum)
  static List<int> _getCrc(int ins, List<int>? data) {
    List<int> command = [ins] + data!;

    int length = command.length;

    int regCRC = 0xffff;
    int index = 0;

    while (length > 0) {
      regCRC ^= command[index]++;

      for (int i = 0; i < 8; i++) {
        if (regCRC & 0x01 == 1) {
          regCRC = (regCRC >> 1) ^ 0xa001;
        } else {
          regCRC = regCRC >> 1;
        }
      }
      length--;
      index++;
    }
    return [regCRC >> 8 & 0xFF, regCRC & 0xFF];
  }

  // confirma o CRC (check sum)
  static bool _confirmCRC(List<int> crcCalculated, List<int> crcFromInverter) {
    Function eq = const ListEquality().equals;
    if (eq(crcCalculated, crcFromInverter)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> sendCommand({
    required num value,
    required WriteCommandType commandType,
  }) async {
    if (TreadmillValues.instance.proMaxSerialPort.value == null) return;
    List<int>? command = formatWriteRequisition(value: value, type: commandType);

    TreadmillValues.instance.proMaxSerialPort.value!.write(Uint8List.fromList(command));
    TreadmillValues.instance.setLastCommandSent(
        command.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));
    if (commandType == WriteCommandType.speed) {
      TreadmillValues.instance.setSpeed(value.toDouble());
    } else {
      TreadmillValues.instance.setInclination(value.toInt());
    }
  }
}