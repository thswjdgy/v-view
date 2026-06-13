import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.smart_toy_rounded,
      illustrationColor: Color(0xFFE0FBF5),
      iconColor: Color(0xFF00C9A7),
      decorColor: Color(0xFFB2F2E8),
      title: 'AI가 자기소개서로\n맞춤 면접 질문을 만들어줘요',
      body:
          '자기소개서를 붙여넣으면 Claude AI가\n직무·인성·대학입시 유형에 딱 맞는\n예상 질문을 자동으로 생성해줘요.',
    ),
    _SlideData(
      icon: Icons.center_focus_strong_rounded,
      illustrationColor: Color(0xFFE8F0FF),
      iconColor: Color(0xFF005DB8),
      decorColor: Color(0xFFBDD4FF),
      title: '카메라로 시선을 분석해\n점수를 알려줘요',
      body:
          '면접 중 카메라가 시선을 실시간 감지해요.\n영상은 저장되지 않고, 응시율 점수만\n결과에 반영됩니다.',
    ),
    _SlideData(
      icon: Icons.auto_awesome_rounded,
      illustrationColor: Color(0xFFFFECEC),
      iconColor: Color(0xFFFF6B6B),
      decorColor: Color(0xFFFFCCCC),
      title: 'AI가 최종 피드백을\n줘요',
      body:
          '면접이 끝나면 답변·시선·개선 포인트를\nAI가 한눈에 정리해줘요.\n다음 면접은 더 잘 할 수 있어요!',
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    HiveService.settingsBox.put('onboarding_seen', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    '건너뛰기',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            // ── Slides ───────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlidePage(data: _slides[i]),
              ),
            ),
            // ── Dot indicator ─────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // ── CTA button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: _DuoButton(
                label: isLast ? '시작하기' : '다음',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide page ─────────────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  final _SlideData data;
  const _SlidePage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // ── Illustration ──
          _Illustration(data: data),
          const SizedBox(height: 40),
          // ── Title ──
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              height: 1.35,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // ── Body ──
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.65,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ── Illustration widget ────────────────────────────────────────────────────
class _Illustration extends StatelessWidget {
  final _SlideData data;
  const _Illustration({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative circle
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: data.decorColor.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          // Middle circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: data.illustrationColor,
              shape: BoxShape.circle,
            ),
          ),
          // Inner accent ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: data.iconColor.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
          ),
          // Icon
          Icon(
            data.icon,
            size: 72,
            color: data.iconColor,
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────
class _SlideData {
  final IconData icon;
  final Color illustrationColor;
  final Color iconColor;
  final Color decorColor;
  final String title;
  final String body;

  const _SlideData({
    required this.icon,
    required this.illustrationColor,
    required this.iconColor,
    required this.decorColor,
    required this.title,
    required this.body,
  });
}

// ── Duo Button ────────────────────────────────────────────────────────────
class _DuoButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _DuoButton({required this.label, required this.onPressed});

  @override
  State<_DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<_DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        margin: EdgeInsets.only(top: _pressed ? 4 : 0),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(
              color: AppColors.primaryShadow,
              width: _pressed ? 0 : 4,
            ),
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: AppColors.onPrimaryContainer,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
