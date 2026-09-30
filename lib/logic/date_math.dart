/// Calendar arithmetic on dates (the time of day is ignored).
///
/// All maths is done on UTC calendar dates so daylight-saving changes in the
/// device time zone never produce off-by-one day counts.
library;

DateTime _utcDate(DateTime d) => DateTime.utc(d.year, d.month, d.day);

int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

class DateDifference {
  const DateDifference({
    required this.totalDays,
    required this.years,
    required this.months,
    required this.days,
    required this.businessDays,
  });

  /// Signed number of days from start to end (negative when end is earlier).
  final int totalDays;

  /// Calendar breakdown of the absolute difference.
  final int years;
  final int months;
  final int days;

  /// Signed Monday–Friday count in the half-open range [start, end).
  final int businessDays;

  int get weeks => totalDays.abs() ~/ 7;
  int get remainderDays => totalDays.abs() % 7;
  bool get isNegative => totalDays < 0;

  String get calendarLabel {
    String unit(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
    return '${unit(years, 'year')}, ${unit(months, 'month')}, '
        '${unit(days, 'day')}';
  }
}

DateDifference difference(DateTime start, DateTime end) {
  final a = _utcDate(start);
  final b = _utcDate(end);
  final totalDays = b.difference(a).inDays;
  final early = totalDays < 0 ? b : a;
  final late = totalDays < 0 ? a : b;

  var totalMonths = (late.year - early.year) * 12 + late.month - early.month;
  if (late.day < early.day) totalMonths -= 1;
  final anchorYear = early.year + (early.month - 1 + totalMonths) ~/ 12;
  final anchorMonth = (early.month - 1 + totalMonths) % 12 + 1;
  final anchorDay = early.day.clamp(1, daysInMonth(anchorYear, anchorMonth));
  final anchor = DateTime.utc(anchorYear, anchorMonth, anchorDay);
  final years = totalMonths ~/ 12;
  final months = totalMonths % 12;
  final days = late.difference(anchor).inDays;
  final business = businessDaysBetween(early, late);
  return DateDifference(
    totalDays: totalDays,
    years: years,
    months: months,
    days: days,
    businessDays: totalDays < 0 ? -business : business,
  );
}

/// Counts Monday–Friday days in [start, end); returns 0 if end <= start.
int businessDaysBetween(DateTime start, DateTime end) {
  final a = _utcDate(start);
  final b = _utcDate(end);
  final total = b.difference(a).inDays;
  if (total <= 0) return 0;
  final fullWeeks = total ~/ 7;
  var count = fullWeeks * 5;
  var day = a.add(Duration(days: fullWeeks * 7));
  while (day.isBefore(b)) {
    if (day.weekday <= DateTime.friday) count++;
    day = day.add(const Duration(days: 1));
  }
  return count;
}

/// Adds [days] (may be negative) to [date], returning a local calendar date.
DateTime addDays(DateTime date, int days) {
  final shifted = _utcDate(date).add(Duration(days: days));
  return DateTime(shifted.year, shifted.month, shifted.day);
}

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
  'Sunday',
];

/// ISO-style date plus weekday, e.g. `2026-10-01 (Thursday)`.
String formatDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} '
      '(${_weekdayNames[d.weekday - 1]})';
}
