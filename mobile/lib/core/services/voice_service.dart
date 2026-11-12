import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _sttInitialized = false;
  bool _ttsInitialized = false;

  bool get isListening => _stt.isListening;

  Future<bool> startListening({
    required ValueChanged<String> onTranscript,
    ValueChanged<double>? onSoundLevel,
    ValueChanged<String>? onStatus,
    ValueChanged<String>? onError,
  }) async {
    try {
      if (!_sttInitialized) {
        final ok = await _stt.initialize(
          onError: (err) => onError?.call(err.errorMsg),
          onStatus: (status) => onStatus?.call(status),
        );
        _sttInitialized = ok;
      }
      if (!_sttInitialized || !_stt.isAvailable) {
        onError?.call('Speech recognition unavailable on this device.');
        return false;
      }

      if (_stt.isListening) {
        await _stt.stop();
      }

      await _stt.listen(
        onSoundLevelChange: (level) => onSoundLevel?.call(level),
        onResult: (result) {
          if (result.recognizedWords.trim().isNotEmpty) {
            onTranscript(result.recognizedWords);
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          cancelOnError: false,
        ),
      );
      return true;
    } catch (e) {
      _sttInitialized = false;
      onError?.call(e.toString());
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
