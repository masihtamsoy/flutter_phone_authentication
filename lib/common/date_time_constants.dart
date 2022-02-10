import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeConstants {
  DateTimeConstants._();

  static Iterable<TimeOfDay> getTimesUtil(
      TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;

    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour ||
        (hour == endTime.hour && minute <= endTime.minute));
  }

  static getTimes(context) {
    /// get time slots
    final startTime = TimeOfDay(hour: 9, minute: 0);
    final endTime = TimeOfDay(hour: 22, minute: 0);
    final step = Duration(minutes: 30);

    final times = getTimesUtil(startTime, endTime, step)
        .map((tod) => tod.format(context))
        .toList();

    return times;
  }

  static getDates() {
    final _currentDate = DateTime.now();
    final _dayFormatter = DateFormat('d');
    final _monthFormatter = DateFormat('MMM');
    final dates = [];

    for (int i = 0; i < 7; i++) {
      final date = _currentDate.add(Duration(days: i));
      String readDate =
          _dayFormatter.format(date) + " " + _monthFormatter.format(date);

      dates.add(readDate);
      // dates.add(Column(
      //   children: [
      //     Text(_dayFormatter.format(date)),
      //     Text(_monthFormatter.format(date)),
      //   ],
      // ));
    }

    // print("---------${dates}");

    return dates;
  }
}
