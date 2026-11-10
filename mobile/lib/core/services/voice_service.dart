import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _sttInitialized = false;
  bool _ttsInitialized = false;

  Future<bool> startListening({
    required ValueChanged<String> onTranscript,
    VoidCallback? onError,
  }) async {
    try {
      if (!_sttInitialized) {
        _sttInitialized = await _stt.initialize(
          onError: (_) => onError?.call(),
        );
      }
      if (!_sttInitialized || !_stt.isAvailable) {
        return false;
      }
      await _stt.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onTranscript(result.recognizedWords);
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_stt.isListening) {
        await _stt.stop();
      }
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    try {
      if (!_ttsInitialized) {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(0.5);
        _ttsInitialized = true;
      }
      await _tts.speak(text);
    } catch (_) {
      // Safe no-op on unsupported test/headless targets
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
