export 'package:audioplayers/audioplayers.dart';

import 'package:audioplayers/audioplayers.dart';

Future<void> playSound(AudioPlayer audioPlayer, String soundName) async {
  await audioPlayer.play(UrlSource('sounds/$soundName.mp3'));
}
