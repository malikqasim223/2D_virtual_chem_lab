part of chem_lab;

// ============================================================
// VOICE SERVICE - TTS (Teacher Speaks) + STT (User Speaks)
// ============================================================

class VoiceService {
  static final FlutterTts _tts = FlutterTts();
  static final SpeechToText _stt = SpeechToText();

  static bool _ttsReady = false;
  static bool _sttReady = false;
  static bool _voiceEnabled = true;
  static bool _isListening = false;
  static bool _isSpeaking = false;
  static bool _awaitCompletionEnabled = false;
  static Completer<void>? _speakCompleter;

  static bool get isListening => _isListening;
  static bool get voiceEnabled => _voiceEnabled;

  static Future<void> initTts() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.6);
      await _tts.setVolume(0.9);
      await _tts.setPitch(0.95);
      // Windows: Auto-select Zira (natural female) - fallback to any female
      if (Platform.isWindows) {
        try {
          final voices = await _tts.getVoices;
          if (voices is List && voices.isNotEmpty) {
            String? best;
            for (var v in voices) {
              final name = (v['name'] ?? '').toString().toLowerCase();
              if (name.contains('david')) { best = v['name']; break; }
            }
            if (best == null) {
              for (var v in voices) {
                final name = (v['name'] ?? '').toString().toLowerCase();
                if (name.contains('male') || name.contains('mark') || name.contains('george')) {
                  best = v['name']; break;
                }
              }
            }
            if (best != null) {
              await _tts.setVoice({'name': best, 'locale': 'en-US'});
              // print('TTS Voice: $best');
            }
          }
        } catch (e) { print('Voice select failed: $e'); }
      }
      _tts.setCompletionHandler(() {
        if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
          _speakCompleter!.complete();
        }
      });
      // awaitSpeakCompletion: iOS/Android only - causes native crash on Windows
      if (!Platform.isWindows) {
        try { await _tts.awaitSpeakCompletion(true); } catch (_) {}
      }
      _ttsReady = true;
    } catch (e) {
      // print('TTS init failed: ' + e.toString());
    }
  }

  static Future<bool> initStt() async {
    if (_sttReady) return true;
    try {
      final available = await _stt.initialize(
        // onError: (err) => print('STT error: ' + err.toString()),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
      _sttReady = available;
      return available;
    } catch (e) {
      // print('STT init failed: ' + e.toString());
      return false;
    }
  }

  static Future<void> speak(String text) async {
    if (!_voiceEnabled || !_ttsReady) { print('[TTS] SKIP: enabled=$_voiceEnabled ready=$_ttsReady'); return; }
    if (_isListening) { print('[TTS] SKIP: listening'); return; }
    // INSTANT CANCEL: kill previous voice + unblock its waiter
    if (_isSpeaking) {
      try { await _tts.stop(); } catch (_) {}
      if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
        _speakCompleter!.complete();
      }
      _isSpeaking = false;
    }
    final clean = _cleanTextForSpeech(text);
    if (clean.isEmpty) return;
    _isSpeaking = true;
    final wordCount = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    _speakCompleter = Completer<void>();
    final myCompleter = _speakCompleter!;
    // print('[TTS START] words=$wordCount text=${clean.substring(0, clean.length > 40 ? 40 : clean.length)}...');
    try {
      try { await _tts.stop(); } catch (_) {}
      try { await _tts.speak(clean); } catch (e) { print('[TTS ERR] $e'); }
    } catch (e) { print('[TTS OUTER ERR] $e'); }
    try {
      await myCompleter.future.timeout(Duration(milliseconds: (wordCount * 600) + 5000));
    } catch (_) {
      // print('[TTS TIMEOUT] fallback');
    }
    if (identical(_speakCompleter, myCompleter)) {
      _isSpeaking = false;
      _speakCompleter = null;
    }
    // print('[TTS END]');
  }

  static List<String> _splitIntoSegments(String text) {
    final parts = text.split(RegExp(r'(?<=[.!?])\s+'));
    final segments = <String>[];
    for (var part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.length > 160) {
        final subParts = trimmed.split(RegExp(r'(?<=,)\s+'));
        for (var sub in subParts) {
          if (sub.trim().isNotEmpty) segments.add(sub.trim());
        }
      } else {
        segments.add(trimmed);
      }
    }
    return segments.isEmpty ? [text] : segments;
  }

  static Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {}
  }

  static String _cleanTextForSpeech(String text) {
    return text
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('_', '')
        .replaceAll('->', ' yields ')
        .replaceAll('->', ' yields ')
        .replaceAll('(s)', '')
        .replaceAll('(l)', '')
        .replaceAll('(g)', '')
        .replaceAll('(aq)', ' aqueous ')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .replaceAll('[', ' ')
        .replaceAll(']', ' ')
        .replaceAll('°C', ' degrees Celsius ')
        .replaceAll('°', ' degrees ')
        .replaceAll('+', ' plus ')
        .replaceAll('=', ' equals ')
        .replaceAll('/', ' or ')
        .replaceAll('&', ' and ')
        .replaceAll('@', ' at ').replaceAll('~', ' approximately ').replaceAll('%', ' percent ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Future<void> startListening(Function(String) onResult) async {
    if (!await initStt()) {
      onResult('__STT_UNAVAILABLE__');
      return;
    }
    if (_isListening) return;
    _isListening = true;
    try {
      await _stt.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        localeId: 'en_US',
      );
    } catch (e) {
      _isListening = false;
      onResult('__STT_ERROR__');
    }
  }

  static Future<void> stopListening() async {
    try {
      await _stt.stop();
      _isListening = false;
    } catch (e) {}
  }

  static void toggleVoice() {
    _voiceEnabled = !_voiceEnabled;
    if (!_voiceEnabled) {
      stopSpeaking();
    }
  }

  static void setVoiceEnabled(bool enabled) {
    _voiceEnabled = enabled;
    if (!enabled) stopSpeaking();
  }
}

