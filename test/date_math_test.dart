import 'package:date_calculator/logic/date_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('difference gives total days, weeks and calendar breakdown', () {
    final d = difference(DateTime(2024, 1, 31), DateTime(2025, 3, 1));
    expect(d.totalDays, 395);
    expect(d.weeks, 56);
    expect(d.remainderDays, 3);
    expect(d.years, 1);
    expect(d.months, 1);
    expect(d.days, 1);
    expect(d.calendarLabel, '1 year, 1 month, 1 day');
  });

  test('difference is signed when end is before start', () {
    final d = difference(DateTime(2026, 10, 10), DateTime(2026, 10, 1));
    expect(d.totalDays, -9);
    expect(d.isNegative, isTrue);
    expect(d.days, 9);
    expect(d.businessDays, -7);
  });

  test('ignores time of day', () {
    final d = difference(
      DateTime(2026, 3, 28, 23, 59),
      DateTime(2026, 3, 30, 0, 1),
    );
    expect(d.totalDays, 2);
  });

  test('businessDaysBetween counts Mon-Fri in [start, end)', () {
    // 2026-10-05 is a Monday.
    expect(
        businessDaysBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 12)), 5);
    expect(
        businessDaysBetween(DateTime(2026, 10, 3), DateTime(2026, 10, 5)), 0);
    expect(
        businessDaysBetween(DateTime(2026, 10, 2), DateTime(2026, 10, 20)), 12);
    expect(
        businessDaysBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 5)), 0);
  });

  test('addDays crosses months, leap days and supports negatives', () {
    expect(addDays(DateTime(2028, 2, 28), 1), DateTime(2028, 2, 29));
    expect(addDays(DateTime(2026, 1, 1), -1), DateTime(2025, 12, 31));
    expect(addDays(DateTime(2026, 10, 1), 30), DateTime(2026, 10, 31));
  });

  test('daysInMonth and formatDate', () {
    expect(daysInMonth(2024, 2), 29);
    expect(daysInMonth(2026, 2), 28);
    expect(formatDate(DateTime(2026, 10, 1)), '2026-10-01 (Thursday)');
  });

  test('calendar breakdown clamps month ends', () {
    final d = difference(DateTime(2026, 1, 31), DateTime(2026, 2, 28));
    expect(d.calendarLabel, '0 years, 0 months, 28 days');
    final e = difference(DateTime(2026, 1, 15), DateTime(2026, 3, 15));
    expect(e.calendarLabel, '0 years, 2 months, 0 days');
    final f = difference(DateTime(2020, 2, 29), DateTime(2021, 2, 28));
    expect(f.calendarLabel, '0 years, 11 months, 30 days');
  });
}
