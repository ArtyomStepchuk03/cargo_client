import 'dart:math';

class Uuid {
  String generateV4() {
    final special = 8 + _random.nextInt(4);

    return '${_getDigitsString(16, 4)}${_getDigitsString(16, 4)}-'
      '${_getDigitsString(16, 4)}-'
      '4${_getDigitsString(12, 3)}-'
      '${_digitsToString(special, 1)}${_getDigitsString(12, 3)}-'
      '${_getDigitsString(16, 4)}${_getDigitsString(16, 4)}${_getDigitsString(16, 4)}';
  }

  final Random _random = Random();

  String _getDigitsString(int bitCount, int digitCount) => _digitsToString(_generateBits(bitCount), digitCount);
  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);
  String _digitsToString(int value, int count) => value.toRadixString(16).padLeft(count, '0');
}
