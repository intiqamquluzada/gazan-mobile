import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../application/promotions_providers.dart';
import '../data/promotions_repository.dart';
import '../domain/story.dart';

/// Full-screen Instagram-style story viewer for one company.
///
/// - Auto-progresses through each story.
/// - Tap right half → next; tap left half → previous.
/// - Long-press anywhere → pause.
/// - Swipe down or X button → close.
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({super.key, required this.companyId});

  final String companyId;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with TickerProviderStateMixin {
  AnimationController? _progress;
  List<Story> _stories = const <Story>[];
  int _index = 0;
  bool _loading = true;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final PromotionsRepository repo = ref.read(promotionsRepositoryProvider);
    final List<Story> stories =
        await repo.fetchStoriesForCompany(widget.companyId);
    if (!mounted) return;
    setState(() {
      _stories = stories;
      _loading = false;
    });
    if (stories.isNotEmpty) _start();
  }

  void _start() {
    _progress?.dispose();
    final Story s = _stories[_index];
    _progress = AnimationController(vsync: this, duration: s.duration)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) _next();
      })
      ..forward();
    setState(() {});
  }

  void _next() {
    if (_index >= _stories.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index += 1);
    _start();
  }

  void _prev() {
    if (_index <= 0) {
      _progress?.value = 0;
      _progress?.forward();
      return;
    }
    setState(() => _index -= 1);
    _start();
  }

  void _setPaused(bool v) {
    setState(() => _paused = v);
    if (v) {
      _progress?.stop();
    } else {
      _progress?.forward();
    }
  }

  @override
  void dispose() {
    _progress?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Hekayə yoxdur',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final Story story = _stories[_index];
    final AsyncValue<Company?> companyAsync =
        ref.watch(companyByIdProvider(widget.companyId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (TapUpDetails d) {
          final double half = MediaQuery.sizeOf(context).width / 2;
          if (d.globalPosition.dx > half) {
            _next();
          } else {
            _prev();
          }
        },
        onLongPressStart: (_) => _setPaused(true),
        onLongPressEnd: (_) => _setPaused(false),
        onVerticalDragEnd: (DragEndDetails d) {
          if ((d.primaryVelocity ?? 0) > 300) Navigator.of(context).maybePop();
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _StoryBody(
            key: ValueKey<String>(story.id),
            story: story,
            company: companyAsync.value,
          ),
        ),
      ),
      // Top overlay: progress bars + brand row + close
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
          ),
          child: Column(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: Row(
                  children: <Widget>[
                    for (int i = 0; i < _stories.length; i++) ...<Widget>[
                      Expanded(
                        child: _ProgressBar(
                          completed: i < _index,
                          isCurrent: i == _index,
                          controller: i == _index ? _progress : null,
                        ),
                      ),
                      if (i < _stories.length - 1) const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  if (companyAsync.value != null) ...<Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Text(companyAsync.value!.logoEmoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        companyAsync.value!.name,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryBody extends StatelessWidget {
  const _StoryBody({super.key, required this.story, this.company});

  final Story story;
  final Company? company;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(story.gradientStartHex),
            Color(story.gradientEndHex),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 100, AppSpacing.xl, AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              Center(
                child: Text(
                  story.emoji,
                  style: const TextStyle(fontSize: 120),
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
              Text(
                story.headline,
                style: AppTextStyles.display.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                story.body,
                style: AppTextStyles.bodyLg.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              if (story.cta != null && company != null)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).maybePop();
                      Future<void>.microtask(() {
                        if (context.mounted) {
                          context.push('/companies/${company!.id}');
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            story.cta!,
                            style: AppTextStyles.button.copyWith(
                              color: Color(story.gradientStartHex),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Color(story.gradientStartHex),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.completed,
    required this.isCurrent,
    required this.controller,
  });

  final bool completed;
  final bool isCurrent;
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    final Color track = Colors.white.withValues(alpha: 0.3);
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: completed
            ? const ColoredBox(color: Colors.white)
            : isCurrent && controller != null
                ? AnimatedBuilder(
                    animation: controller!,
                    builder: (BuildContext _, __) => LinearProgressIndicator(
                      value: controller!.value,
                      backgroundColor: track,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : ColoredBox(color: track),
      ),
    );
  }
}

