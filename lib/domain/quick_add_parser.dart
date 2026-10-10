import 'package:intl/intl.dart';

import '../models/event.dart';

/// What [parseQuickAdd] understood from a line of text like
/// "Trip to Japan on Dec 25" or "in 3 weeks".
class QuickAddResult {
  const QuickAddResult({required this.title, required this.target});

  final String title;

  /// The moment being counted down to.
  final DateTime target;
}

const _monthNames = {
  'january': 1, 'jan': 1,
  'february': 2, 'feb': 2,
  'march': 3, 'mar': 3,
  'april': 4, 'apr': 4,
  'may': 5,
  'june': 6, 'jun': 6,
  'july': 7, 'jul': 7,
  'august': 8, 'aug': 8,
  'september': 9, 'sept': 9, 'sep': 9,
  'october': 10, 'oct': 10,
  'november': 11, 'nov': 11,
  'december': 12, 'dec': 12,
};

const _weekdayNames = {
  'monday': DateTime.monday, 'mon': DateTime.monday,
  'tuesday': DateTime.tuesday, 'tues': DateTime.tuesday, 'tue': DateTime.tuesday,
  'wednesday': DateTime.wednesday, 'wed': DateTime.wednesday,
  'thursday': DateTime.thursday, 'thurs': DateTime.thursday, 'thu': DateTime.thursday,
  'friday': DateTime.friday, 'fri': DateTime.friday,
  'saturday': DateTime.saturday, 'sat': DateTime.saturday,
  'sunday': DateTime.sunday, 'sun': DateTime.sunday,
};

const _numberWords = {
  'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
  'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
};

/// Longest names first, so "september" wins over "sep" in an alternation.
String _alternation(Iterable<String> names) {
  final sorted = names.toList()..sort((a, b) => b.length.compareTo(a.length));
  return sorted.join('|');
}

final _month = _alternation(_monthNames.keys);
final _weekday = _alternation(_weekdayNames.keys);

final _timeAmPm = RegExp(
  r'(?:\bat\s+)?\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b',
  caseSensitive: false,
);
final _time24 = RegExp(r'(?:\bat\s+)?\b([01]?\d|2[0-3]):([0-5]\d)\b');
final _relative = RegExp(
  r'\bin\s+(\d+|an?|one|two|three|four|five|six|seven|eight|nine|ten)\s+'
  r'(minute|hour|day|week|month|year)s?\b',
  caseSensitive: false,
);
final _tomorrow = RegExp(r'\btomorrow\b', caseSensitive: false);
final _weekdayRef = RegExp(
  r'\b(?:next\s+|this\s+)?(' + _weekday + r')\b',
  caseSensitive: false,
);
final _iso = RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b');
final _monthDay = RegExp(
  r'\b(' + _month + r')\.?\s+(\d{1,2})(?:st|nd|rd|th)?\b(?:,?\s+(\d{4})\b)?',
  caseSensitive: false,
);
final _dayMonth = RegExp(
  r'\b(\d{1,2})(?:st|nd|rd|th)?\s+(?:of\s+)?(' +
      _month +
      r')\b\.?(?:,?\s+(\d{4})\b)?',
  caseSensitive: false,
);
final _slash = RegExp(r'\b(\d{1,2})/(\d{1,2})(?:/(\d{2,4}))?\b');

final _leadingFiller = RegExp(
  r'^(?:(?:on|until|till|by|to|for|at|is|the|in|-|,)\s+)+',
  caseSensitive: false,
);
final _trailingFiller = RegExp(
  r'(?:\s+(?:on|until|till|by|to|for|at|is|the|in|-|,))+$',
  caseSensitive: false,
);

/// Parses a casual one-liner into a title and a target moment, or null if
/// no date could be found. Understands:
///
/// - relative: "in 3 weeks", "in 2 hours", "in a month"
/// - "tomorrow", and weekdays: "friday", "next monday" (always the
///   upcoming one, never today)
/// - "Dec 25", "25 December", "Dec 25 2027", "2027-01-01", "12/25",
///   "25/12/2027" (month first, unless the first number can only be a day)
/// - an optional time: "at 5pm", "17:30"
///
/// A date without a year means its next occurrence. A date without a time
/// means the start of that day. Whatever text is left over (minus filler
/// like "on"/"until") becomes the title.
QuickAddResult? parseQuickAdd(String input, DateTime now) {
  var text = input.trim();
  if (text.isEmpty) return null;

  // Time of day first, so its digits can't be misread as part of a date.
  int? hour;
  int? minute;
  final ampm = _timeAmPm.firstMatch(text);
  if (ampm != null) {
    final h = int.parse(ampm.group(1)!);
    if (h >= 1 && h <= 12) {
      hour = h % 12 + (ampm.group(3)!.toLowerCase() == 'pm' ? 12 : 0);
      minute = int.parse(ampm.group(2) ?? '0');
      text = text.replaceRange(ampm.start, ampm.end, ' ');
    }
  }
  if (hour == null) {
    final t24 = _time24.firstMatch(text);
    if (t24 != null) {
      hour = int.parse(t24.group(1)!);
      minute = int.parse(t24.group(2)!);
      text = text.replaceRange(t24.start, t24.end, ' ');
    }
  }

  final today = DateTime(now.year, now.month, now.day);

  DateTime nextOccurrence(int month, int day, int? year) {
    if (year != null) return DateTime(year, month, day);
    final thisYear = DateTime(now.year, month, day);
    return thisYear.isAfter(today) ? thisYear : DateTime(now.year + 1, month, day);
  }

  bool validDate(int year, int month, int day) {
    final d = DateTime(year, month, day);
    return d.year == year && d.month == month && d.day == day;
  }

  DateTime? target;
  Match? matched;

  final rel = _relative.firstMatch(text);
  if (rel != null) {
    matched = rel;
    final raw = rel.group(1)!.toLowerCase();
    final amount = int.tryParse(raw) ?? _numberWords[raw]!;
    switch (rel.group(2)!.toLowerCase()) {
      case 'minute':
        target = now.add(Duration(minutes: amount));
        hour = null;
      case 'hour':
        target = now.add(Duration(hours: amount));
        hour = null;
      case 'day':
        target = DateTime(today.year, today.month, today.day + amount);
      case 'week':
        target = DateTime(today.year, today.month, today.day + 7 * amount);
      case 'month':
        target = DateTime(today.year, today.month + amount, today.day);
      case 'year':
        target = DateTime(today.year + amount, today.month, today.day);
    }
  }

  if (target == null) {
    final m = _tomorrow.firstMatch(text);
    if (m != null) {
      matched = m;
      target = DateTime(today.year, today.month, today.day + 1);
    }
  }

  if (target == null) {
    final m = _iso.firstMatch(text);
    if (m != null) {
      final y = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final d = int.parse(m.group(3)!);
      if (validDate(y, mo, d)) {
        matched = m;
        target = DateTime(y, mo, d);
      }
    }
  }

  if (target == null) {
    final m = _monthDay.firstMatch(text);
    if (m != null) {
      final mo = _monthNames[m.group(1)!.toLowerCase()]!;
      final d = int.parse(m.group(2)!);
      final y = m.group(3) == null ? null : int.parse(m.group(3)!);
      if (validDate(y ?? 2000, mo, d)) {
        matched = m;
        target = nextOccurrence(mo, d, y);
      }
    }
  }

  if (target == null) {
    final m = _dayMonth.firstMatch(text);
    if (m != null) {
      final d = int.parse(m.group(1)!);
      final mo = _monthNames[m.group(2)!.toLowerCase()]!;
      final y = m.group(3) == null ? null : int.parse(m.group(3)!);
      if (validDate(y ?? 2000, mo, d)) {
        matched = m;
        target = nextOccurrence(mo, d, y);
      }
    }
  }

  if (target == null) {
    final m = _slash.firstMatch(text);
    if (m != null) {
      final a = int.parse(m.group(1)!);
      final b = int.parse(m.group(2)!);
      // "25/12" can only be day/month; otherwise default to month/day.
      final mo = a > 12 ? b : a;
      final d = a > 12 ? a : b;
      var y = m.group(3) == null ? null : int.parse(m.group(3)!);
      if (y != null && y < 100) y += 2000;
      if (validDate(y ?? 2000, mo, d)) {
        matched = m;
        target = nextOccurrence(mo, d, y);
      }
    }
  }

  if (target == null) {
    final m = _weekdayRef.firstMatch(text);
    if (m != null) {
      matched = m;
      final wanted = _weekdayNames[m.group(1)!.toLowerCase()]!;
      var ahead = (wanted - today.weekday) % 7;
      if (ahead == 0) ahead = 7;
      target = DateTime(today.year, today.month, today.day + ahead);
    }
  }

  if (target == null || matched == null) return null;

  text = text.replaceRange(matched.start, matched.end, ' ');
  if (hour != null) {
    target = DateTime(target.year, target.month, target.day, hour, minute ?? 0);
  }

  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  text = text.replaceFirst(_leadingFiller, '').replaceFirst(_trailingFiller, '');
  text = text.trim();

  final title = text.isEmpty
      ? DateFormat.MMMd().format(target)
      : '${text[0].toUpperCase()}${text.substring(1)}';
  return QuickAddResult(title: title, target: target);
}

/// Picks a grid granularity that gives a readable number of dots between
/// [start] and [end]: hours for the next couple of days, down to months for
/// spans of several years.
Granularity granularityForSpan(DateTime start, DateTime end) {
  final span = end.difference(start);
  if (span <= const Duration(days: 2)) return Granularity.hour;
  if (span <= const Duration(days: 120)) return Granularity.day;
  if (span <= const Duration(days: 365 * 3)) return Granularity.week;
  return Granularity.month;
}
