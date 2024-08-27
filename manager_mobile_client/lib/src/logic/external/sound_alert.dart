export 'package:audioplayers/audioplayers.dart';

import 'package:audioplayers/audioplayers.dart';

Future<void> playSound(AudioCache audioCache, String soundName) async {
  await audioCache.play('sounds/$soundName.mp3');
}
