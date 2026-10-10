import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../domain/progress_calculator.dart';
import '../../models/event.dart';
import '../../platform/chrome_extension_bridge.dart';
import '../../utils/date_utils.dart';
import 'dot_grid.dart';

/// Side length of the share image in logical pixels; captured at 2x for a
/// crisp 1080px square.
const _cardSize = 540.0;

/// Shows a preview of a shareable progress image for [event] with
/// Download and Copy actions (Chrome extension only - the actions need the
/// browser's download/clipboard APIs; see the bridge).
Future<void> showShareProgressDialog(
  BuildContext context, {
  required Event event,
  required ProgressResult result,
  required DateTime now,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        _ShareDialog(event: event, result: result, now: now),
  );
}

class _ShareDialog extends StatefulWidget {
  const _ShareDialog({
    required this.event,
    required this.result,
    required this.now,
  });

  final Event event;
  final ProgressResult result;
  final DateTime now;

  @override
  State<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<_ShareDialog> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;

  Future<ui.Image?> _capture() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    return boundary?.toImage(pixelRatio: 2);
  }

  Future<void> _run(Future<bool> Function(Uint8List png) action, String ok) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final image = await _capture();
    final data = await image?.toByteData(format: ui.ImageByteFormat.png);
    var success = false;
    if (data != null) {
      success = await action(data.buffer.asUint8List());
    }
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(
      SnackBar(content: Text(success ? ok : 'Could not create the image')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileName =
        '${widget.event.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-timeuntil.png';

    return AlertDialog(
      title: const Text('Share progress'),
      content: SizedBox(
        width: 360,
        child: AspectRatio(
          aspectRatio: 1,
          child: FittedBox(
            fit: BoxFit.contain,
            child: RepaintBoundary(
              key: _boundaryKey,
              child: ShareCard(
                event: widget.event,
                result: widget.result,
                now: widget.now,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Copy'),
          onPressed: _busy
              ? null
              : () => _run(
                    copyPngToClipboard,
                    'Image copied',
                  ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.download_outlined),
          label: const Text('Download'),
          onPressed: _busy
              ? null
              : () => _run(
                    (png) => downloadPng(png, fileName),
                    'Image saved',
                  ),
        ),
      ],
    );
  }
}

/// The image itself: a fixed-size, theme-independent card so the shared
/// picture looks the same no matter the viewer's light/dark mode.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.event,
    required this.result,
    required this.now,
  });

  final Event event;
  final ProgressResult result;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final base = event.color;
    final hsl = HSLColor.fromColor(base);
    final dark = hsl.withLightness(math.min(hsl.lightness, 0.28)).toColor();
    final darker = hsl.withLightness(0.12).toColor();
    final percent = (result.fraction * 100).round();
    final remaining = result.status == TaskStatus.done
        ? 'Done'
        : '${formatCountdown(now, result.cycleEnd)} left';
    final dateFormat = DateFormat.yMMMd();

    // Dark theme so DotGrid's "empty" dots read against the dark gradient
    // regardless of the app's own theme.
    return Theme(
      data: ThemeData.dark(),
      child: SizedBox(
      width: _cardSize,
      height: _cardSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [dark, darker],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(result.cycleStart)} - ${dateFormat.format(result.cycleEnd)}',
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: DotGrid(
                      filled: result.filled,
                      total: result.total,
                      color: Colors.white,
                      shape: event.shape,
                      maxUnitsRendered: 400,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 64,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          remaining,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'TimeUntil',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
