import 'dart:typed_data';

abstract class TreadmillCommands {

  static Uint8List get readNormalDataPacket =>
      Uint8List.fromList([0xff, 0x41, 0x01, 0x8f, 0xbe, 0xfe]);

}
