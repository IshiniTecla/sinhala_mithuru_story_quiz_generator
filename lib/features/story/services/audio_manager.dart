import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _player = AudioPlayer();

  // හරි උත්තරේට (Correct Answer)
  static Future<void> playSuccess() async {
    try {
      await _player.stop(); // කලින් සද්දයක් තියෙනවා නම් නවත්තන්න
      await _player.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print("Audio Error: $e");
    }
  }

  // වැරදි උත්තරේට (Wrong Answer) - (Optional: ඔයාට කැමති නම් දාන්න)
  static Future<void> playWrong() async {
    try {
      await _player.stop();
      // ඔයා wrong.mp3 කියලා එකක් දැම්මේ නැත්නම් මේක වැඩ කරන්නේ නෑ
      // await _player.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print("Audio Error: $e");
    }
  }
}
