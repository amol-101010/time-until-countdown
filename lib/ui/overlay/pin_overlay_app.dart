import 'dart:async';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../../domain/progress_calculator.dart';
import '../../overlay/pin_overlay_controller.dart';
import '../../state/providers/clock_provider.dart';
import '../../state/providers/event_list_provider.dart';
import '../../utils/date_utils.dart';

/// Size of the floating pin overlay window. Small and wide, like a Loom
/// recording bubble sitting in the corner of the screen rather than a full
/// app window.
const Size pinOverlaySize = Size(260, 88);

/// The minimal app run inside the pin-overlay sub-window (see
/// lib/main.dart's multi_window branch). Deliberately not [DashApp] - this
/// window has its own Flutter engine and shows exactly one event's live
/// progress, transparent and always-on-top so it stays visible over other
/// applications (e.g. while screen recording).
class PinOverlayApp extends ConsumerStatefulWidget {
  const PinOverlayApp({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<PinOverlayApp> createState() => _PinOverlayAppState();
}

class _PinOverlayAppState extends ConsumerState<PinOverlayApp> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await windowManager.ensureInitialized();

    final controller = await WindowController.fromCurrentEngine();
    await PinOverlayWindowHandler.register(controller, () async {
      await windowManager.close();
    });

    const options = WindowOptions(
      size: pinOverlaySize,
      minimumSize: pinOverlaySize,
      maximumSize: pinOverlaySize,
      center: false,
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.show();
    });
  }

  Future<void> _unpinAndClose() async {
    // A separate isolate from the main window - write the setting directly
    // via shared_preferences (same on-disk store) rather than trying to
    // round-trip through the main window's Riverpod state.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pinnedEventId');
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: _OverlayContent(eventId: widget.eventId, onClose: _unpinAndClose),
      ),
    );
  }
}

class _OverlayContent extends ConsumerWidget {
  const _OverlayContent({required this.eventId, required this.onClose});

  final String eventId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventListProvider);
    final nowAsync = ref.watch(clockProvider);

    return eventsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (events) {
        final matches = events.where((e) => e.id == eventId);
        final event = matches.isEmpty ? null : matches.first;
        if (event == null) {
          // The pinned event was deleted elsewhere - nothing sensible to
          // show, so unpin and let the window close itself.
          WidgetsBinding.instance.addPostFrameCallback((_) => onClose());
          return const SizedBox.shrink();
        }

        final now = nowAsync.value ?? DateTime.now();
        final result = ProgressCalculator.compute(event, now);

        return DragToMoveArea(
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: event.color.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                if (event.icon != null) ...[
                  Icon(event.icon, color: event.color, size: 18),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MarqueeText(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: result.fraction,
                          minHeight: 5,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(event.color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${(result.fraction * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          _LiveCountdown(end: result.cycleEnd),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Unpin',
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Countdown to [end] down to the second. [clockProvider] only ticks once a
/// minute, so this keeps its own once-a-second timer and rebuilds just this
/// text.
class _LiveCountdown extends StatefulWidget {
  const _LiveCountdown({required this.end});

  final DateTime end;

  @override
  State<_LiveCountdown> createState() => _LiveCountdownState();
}

class _LiveCountdownState extends State<_LiveCountdown> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCountdownFull(DateTime.now(), widget.end),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Single-line text that sits still when it fits, and scrolls right-to-left
/// in a continuous loop, LED-ticker style, when it's wider than the space
/// it's given.
class _MarqueeText extends StatefulWidget {
  const _MarqueeText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  static const double _gap = 40;
  static const double _pixelsPerSecond = 40;

  late final AnimationController _controller = AnimationController(vsync: this);
  double? _loopWidth;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation(double loopWidth) {
    if (_loopWidth == loopWidth) return;
    _loopWidth = loopWidth;
    _controller
      ..duration = Duration(
        milliseconds: (loopWidth / _pixelsPerSecond * 1000).round(),
      )
      ..repeat();
  }

  @override
  void didUpdateWidget(_MarqueeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text || old.style != widget.style) {
      _loopWidth = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final textWidth = painter.width;
        final textHeight = painter.height;

        if (textWidth <= constraints.maxWidth) {
          if (_controller.isAnimating) _controller.stop();
          _loopWidth = null;
          return Text(widget.text, maxLines: 1, style: widget.style);
        }

        final loopWidth = textWidth + _gap;
        _syncAnimation(loopWidth);
        return SizedBox(
          height: textHeight,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: 0,
                  maxWidth: double.infinity,
                  child: Transform.translate(
                    offset: Offset(-_controller.value * loopWidth, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.text, maxLines: 1, style: widget.style),
                        const SizedBox(width: _gap),
                        Text(widget.text, maxLines: 1, style: widget.style),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
