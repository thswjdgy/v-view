import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final _stt = SpeechToText();
  final _textCtrl = StreamController<String>.broadcast();

  bool _isListening = false;
  bool _available = false;
  String _accumulated = '';

  Stream<String> get textStream => _textCtrl.stream;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    _available = await _stt.initialize(
      onError: (_) {
        _isListening = false;
      },
      onStatus: (status) {
        // 인식이 자동 종료되면 사용자가 멈추지 않은 경우 재시작
        if (status == SpeechToText.doneStatus && _isListening) {
          _listen();
        }
      },
    );
    return _available;
  }

  Future<void> startListening() async {
    if (!_available || _isListening) return;
    _isListening = true;
    _accumulated = '';
    _textCtrl.add('');
    _listen();
  }

  // 내부 listen 루프 — onDone 재시작 시에도 재사용
  void _listen() {
    if (!_isListening) return;
    _stt.listen(
      onResult: (result) {
        final words = result.recognizedWords;
        if (result.finalResult) {
          if (words.isNotEmpty) {
            _accumulated =
                _accumulated.isEmpty ? words : '$_accumulated $words';
          }
          _textCtrl.add(_accumulated);
        } else {
          // 부분 결과를 실시간으로 미리보기
          final preview =
              _accumulated.isEmpty ? words : '$_accumulated $words';
          _textCtrl.add(preview);
        }
      },
      localeId: 'ko_KR',
      listenFor: const Duration(seconds: 120),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
  }

  Future<void> dispose() async {
    _isListening = false;
    await _stt.cancel();
    await _textCtrl.close();
  }
}
