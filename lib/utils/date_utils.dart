import '../models/event.dart';

String granularityLabel(Granularity granularity, {required bool plural}) {
  final singular = switch (granularity) {
    Granularity.minute => 'minute',
    Granularity.hour => 'hour',
    Granularity.day => 'day',
    Granularity.week => 'week',
    Granularity.month => 'month',
    Granularity.year => 'year',
  };
  return plural ? '${singular}s' : singular;
}

/// e.g. "14/31 days (45%)".
String formatProgressSummary({
  required int filled,
  required int total,
  required Granularity granularity,
}) {
  final unit = granularityLabel(granularity, plural: total != 1);
  final percent = total == 0 ? 0 : ((filled / total) * 100).round();
  return '$filled/$total $unit ($percent%)';
}

/// Countdown to [end] from [now], scaled to however much time remains:
///
/// - 1 day or more: "2 days 5hr" (largest two units, day+hour) - no
///   seconds, since a seconds digit is meaningless noise at that range.
/// - under a day ("the last day"): always includes seconds as the finest
///   ticking unit, e.g. "3hr 25min 10sec", "42min 05sec", "08sec" - this
///   is what makes the countdown visibly tick for a year/month/week/day
///   event once it's down to its final day, not just for short-granularity
///   events. Requires a once-a-second rebuild to actually animate (see
///   EventListTile's local ticker - [clockProvider] alone only fires once
///   a minute, which would otherwise freeze the seconds digit).
///
/// The second unit is dropped when it's zero at the day scale (e.g.
/// "2 days" not "2 days 0hr"); at the sub-day scale every unit down to
/// seconds is always shown, including zero, so the display doesn't jump
/// between one and two segments as it ticks. "Done" once passed.
/// Like [formatCountdown], but always carries every unit down to seconds
/// (e.g. `3d 04h 12m 09s`) no matter how far away [end] is - for the pinned
/// overlay, where a ticking seconds digit is the point.
String formatCountdownFull(DateTime now, DateTime end) {
  final remaining = end.difference(now);
  if (remaining.isNegative) return 'Done';

  String two(int n) => n.toString().padLeft(2, '0');
  final days = remaining.inDays;
  final hours = two(remaining.inHours % 24);
  final minutes = two(remaining.inMinutes % 60);
  final seconds = two(remaining.inSeconds % 60);
  return days >= 1
      ? '${days}d ${hours}h ${minutes}m ${seconds}s'
      : '${hours}h ${minutes}m ${seconds}s';
}

String formatCountdown(DateTime now, DateTime end) {
  final remaining = end.difference(now);
  if (remaining.isNegative) return 'Done';

  final days = remaining.inDays;
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes;
  final seconds = remaining.inSeconds;

  if (days >= 1) {
    final remHours = hours % 24;
    final daysLabel = '$days day${days == 1 ? '' : 's'}';
    return remHours == 0
        ? daysLabel
        : '$daysLabel ${remHours}hr${remHours == 1 ? '' : 's'}';
  }

  final secondsLabel = '${(seconds % 60).toString().padLeft(2, '0')}sec';
  if (hours >= 1) {
    final minutesLabel = '${(minutes % 60).toString().padLeft(2, '0')}min';
    return '${hours}hr $minutesLabel $secondsLabel';
  }
  if (minutes >= 1) {
    return '${minutes}min $secondsLabel';
  }
  return secondsLabel;
}
