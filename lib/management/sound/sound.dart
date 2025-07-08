import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static List<bool> isSoundOn = [true, true];

  static final AudioPlayer player1 = AudioPlayer();
  static final AudioPlayer player2 = AudioPlayer();
  static final AudioPlayer checkt = AudioPlayer();
  static final AudioPlayer checkf = AudioPlayer();

  static Future<void> playClickSound() async {
    if (isSoundOn[1]) {
      await player1.play(AssetSource('sounds/click.mp3'));
    }
  }

  static Future<void> playClick8BitSound() async {
    if (isSoundOn[1]) {
      await player2.play(AssetSource('sounds/click8bit.mp3'));
    }
  }

  static Future<void> playChecktrueSound() async {
    if (isSoundOn[0]) {
      await checkt.play(AssetSource('sounds/checktrue.wav'));
    }
  }

  static Future<void> playCheckfalseSound() async {
    if (isSoundOn[0]) {
      await checkf.play(AssetSource('sounds/checkfalse.mp3'));
    }
  }
}
