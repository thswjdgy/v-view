import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../domain/session_setup/session_input.dart';
import '../../../domain/interview/interview_question.dart';
import '../../../domain/report/session_report.dart';
import '../../../domain/gaze/gaze_metrics.dart';

// OpenAI API 기반 AI 서비스 (gpt-4o-mini)
class ClaudeApiService {
  static const _baseUrl = 'https://api.openai.com/v1';
  static const _model = 'gpt-4o-mini';
  static const _timeoutSeconds = 30;

  late final Dio _dio;

  ClaudeApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: _timeoutSeconds),
      receiveTimeout: const Duration(seconds: _timeoutSeconds),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY'] ?? ''}',
        'Content-Type': 'application/json',
      },
    ));
    _dio.interceptors.add(_NetworkErrorInterceptor());
  }

  static const _jsonSystem =
      '반드시 유효한 JSON만 반환하세요. 설명이나 마크다운 코드블록을 포함하지 마세요.';

  Future<List<InterviewQuestion>> generateQuestions(SessionInput input) async {
    final response = await _dio.post('/chat/completions', data: {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _jsonSystem},
        {'role': 'user', 'content': _buildQuestionPrompt(input)},
      ],
    });
    return _parseQuestions(response.data);
  }

  /// 꼬리질문이 필요하면 반환, 불필요하면 null 반환
  Future<InterviewQuestion?> generateFollowUp({
    required InterviewQuestion question,
    required String userAnswer,
  }) async {
    final response = await _dio.post('/chat/completions', data: {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _jsonSystem},
        {'role': 'user', 'content': _buildFollowUpPrompt(question, userAnswer)},
      ],
    });
    return _parseFollowUp(response.data, question.id);
  }

  Future<List<ImprovementPoint>> generateFeedback({
    required List<QuestionAnswer> qaList,
    required GazeMetrics gazeMetrics,
  }) async {
    final response = await _dio.post('/chat/completions', data: {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _jsonSystem},
        {'role': 'user', 'content': _buildFeedbackPrompt(qaList, gazeMetrics)},
      ],
    });
    return _parseFeedback(response.data);
  }

  String _buildQuestionPrompt(SessionInput input) {
    final typeName = switch (input.type) {
      InterviewType.job => '직무면접',
      InterviewType.personality => '인성면접',
      InterviewType.university => '대학입시면접',
    };
    return '''당신은 면접관입니다. 아래 정보를 바탕으로 $typeName 예상 질문 ${input.questionCount}개를 JSON 배열로 생성하세요.
직종/전공: ${input.position}
회사/학교: ${input.company}
자기소개서: ${input.selfIntroduction}

응답 형식 (JSON만 반환):
[{"id":"q1","text":"질문 내용","intent":"평가 포인트"},...]''';
  }

  String _buildFollowUpPrompt(InterviewQuestion q, String answer) {
    return '''면접 질문: ${q.text}
지원자 답변: $answer

위 답변을 분석하여 꼬리 질문이 필요한지 판단하세요.

꼬리 질문이 필요한 경우 (모두 해당 시):
- 답변이 모호하거나 두루뭉술한 경우
- 구체적인 사례나 근거가 없는 경우
- 질문의 핵심을 회피하거나 벗어난 경우
- 언급한 내용에 대해 추가 설명이 필요한 경우

꼬리 질문이 불필요한 경우 (하나라도 해당 시):
- 답변이 구체적이고 완결성이 있는 경우
- 이미 충분한 근거와 사례를 포함한 경우
- 단순 확인 질문에 명확히 답한 경우

필요한 경우: {"needsFollowUp":true,"text":"꼬리 질문 내용","intent":"평가 포인트"}
불필요한 경우: {"needsFollowUp":false}''';
  }

  String _buildFeedbackPrompt(List<QuestionAnswer> qaList, GazeMetrics gaze) {
    final qaText = qaList
        .map((qa) => '질문: ${qa.question.text}\n답변: ${qa.userAnswer}')
        .join('\n\n');
    return '''면접 세션 분석 결과입니다.

[Q&A]
$qaText

[시선 지표]
화면 응시율: ${gaze.gazeRate.toStringAsFixed(1)}%
시선 분산 횟수: ${gaze.distractionCount}회
시선 분산 총 시간: ${gaze.totalDistractionSeconds.toStringAsFixed(1)}초
최장 분산 시간: ${gaze.maxDistractionSeconds.toStringAsFixed(1)}초
측정 품질: ${gaze.quality.name}

개선 포인트 TOP3를 JSON 배열로 반환하세요.
형식: [{"title":"개선항목","description":"상세설명","evidenceMetric":"근거지표"},...]''';
  }

  // OpenAI 응답: choices[0].message.content
  String _extractContent(Map<String, dynamic> data) =>
      data['choices'][0]['message']['content'] as String;

  List<InterviewQuestion> _parseQuestions(Map<String, dynamic> data) {
    final text = _extractContent(data);
    final list = (_extractJson(text) as List).cast<Map<String, dynamic>>();
    return list
        .map((q) => InterviewQuestion(
              id: q['id'] as String,
              text: q['text'] as String,
              intent: q['intent'] as String,
            ))
        .toList();
  }

  InterviewQuestion? _parseFollowUp(Map<String, dynamic> data, String parentId) {
    final text = _extractContent(data);
    final q = _extractJson(text) as Map<String, dynamic>;
    if (q['needsFollowUp'] == false) return null;
    return InterviewQuestion(
      id: 'fu_${DateTime.now().millisecondsSinceEpoch}',
      text: q['text'] as String,
      intent: q['intent'] as String,
      isFollowUp: true,
      parentQuestionId: parentId,
    );
  }

  List<ImprovementPoint> _parseFeedback(Map<String, dynamic> data) {
    final text = _extractContent(data);
    final list = (_extractJson(text) as List).cast<Map<String, dynamic>>();
    return list
        .map((p) => ImprovementPoint(
              title: p['title'] as String,
              description: p['description'] as String,
              evidenceMetric: p['evidenceMetric'] as String,
            ))
        .toList();
  }

  dynamic _extractJson(String text) {
    final startBracket = text.indexOf('[');
    final startBrace = text.indexOf('{');
    final int start;
    final int end;
    if (startBracket != -1 && (startBrace == -1 || startBracket < startBrace)) {
      start = startBracket;
      end = text.lastIndexOf(']') + 1;
    } else {
      start = startBrace;
      end = text.lastIndexOf('}') + 1;
    }
    if (start == -1 || end <= start) throw const FormatException('No JSON found');
    return json.decode(text.substring(start, end));
  }
}

class _NetworkErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final enriched = switch (err.type) {
      DioExceptionType.connectionError => err.copyWith(
          message: '인터넷 연결을 확인해주세요. (연결 오류)',
        ),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        err.copyWith(
          message: 'AI 서버 응답이 지연되고 있습니다. ($_timeoutSeconds초 초과)',
        ),
      DioExceptionType.badResponse => err.copyWith(
          message: 'API 오류: ${err.response?.statusCode}',
        ),
      _ => err,
    };
    handler.next(enriched);
  }
}

const _timeoutSeconds = ClaudeApiService._timeoutSeconds;
