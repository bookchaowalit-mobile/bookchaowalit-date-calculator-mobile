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

  group('edge cases (pass 3)', () {
    test('century leap rules', () {
      expect(daysInMonth(1900, 2), 28);
      expect(daysInMonth(2000, 2), 29);
      expect(daysInMonth(2100, 2), 28);
      expect(daysInMonth(2026, 12), 31);
      expect(addDays(DateTime(2100, 2, 28), 1), DateTime(2100, 3, 1));
    });

    test('same day is zero everywhere', () {
      final d = difference(DateTime(2026, 5, 5, 23), DateTime(2026, 5, 5, 1));
      expect(d.totalDays, 0);
      expect(d.isNegative, isFalse);
      expect(d.calendarLabel, '0 years, 0 months, 0 days');
      expect(d.businessDays, 0);
    });

    test('year boundary and exact anniversaries', () {
      expect(difference(DateTime(2025, 12, 31), DateTime(2026, 1, 1)).totalDays,
          1);
      expect(
        difference(DateTime(2024, 2, 29), DateTime(2028, 2, 29)).calendarLabel,
        '4 years, 0 months, 0 days',
      );
      expect(
        difference(DateTime(2026, 3, 31), DateTime(2026, 4, 30)).calendarLabel,
        '0 years, 0 months, 30 days',
      );
    });

    test('negative breakdown mirrors the positive one', () {
      final forward = difference(DateTime(2024, 1, 31), DateTime(2025, 3, 1));
      final back = difference(DateTime(2025, 3, 1), DateTime(2024, 1, 31));
      expect(back.totalDays, -forward.totalDays);
      expect(back.calendarLabel, forward.calendarLabel);
      expect(back.businessDays, -forward.businessDays);
    });

    test('business-day formula matches a day-by-day count', () {
      final start = DateTime(2026, 1, 1);
      for (var span = 0; span < 40; span++) {
        for (var shift = 0; shift < 7; shift++) {
          final a = addDays(start, shift);
          final b = addDays(a, span);
          var brute = 0;
          for (var i = 0; i < span; i++) {
            if (addDays(a, i).weekday <= DateTime.friday) brute++;
          }
          expect(businessDaysBetween(a, b), brute, reason: '$a +$span');
        }
      }
    });

    test('UTC and local inputs give the same calendar answer', () {
      expect(
        difference(DateTime.utc(2026, 3, 1), DateTime(2026, 3, 31)).totalDays,
        30,
      );
    });

    test('parseDayOffset accepts signed decimals only, within range', () {
      expect(parseDayOffset(' 30 '), 30);
      expect(parseDayOffset('-7'), -7);
      expect(parseDayOffset('+14'), 14);
      expect(parseDayOffset('$maxDayOffset'), maxDayOffset);
      expect(parseDayOffset('-$maxDayOffset'), -maxDayOffset);
      for (final bad in [
        '',
        ' ',
        '-',
        '1.5',
        '1e3',
        '0x10',
        '1 000',
        '${maxDayOffset + 1}',
        '99999999999999999999',
        '٣'
      ]) {
        expect(parseDayOffset(bad), isNull, reason: bad);
      }
      // Largest accepted offset never makes DateTime throw.
      expect(addDays(DateTime(2026), maxDayOffset).year, greaterThan(4700));
      expect(addDays(DateTime(2026), -maxDayOffset).year, lessThan(-700));
    });
  });
}
