import 'package:flutter/material.dart';

extension toStringTimeOfDay on TimeOfDay {
  String timeFormatToString() {
    return '${this.hour < 10 ? '0${this.hour}' : this.hour}:${this.minute < 10 ? '0${this.minute}' : this.minute}';
  }
}

extension compareTime on TimeOfDay {
  int compareTo(TimeOfDay other) {
    double current = this.hour + this.minute / 60.0;
    double compare = other.hour + other.minute / 60.0;
    if (current < compare) {
      return -1;
    }
    if (current == compare) {
      return 0;
    } else {
      return 1;
    }
  }
}

extension parse on String {
  TimeOfDay parseToTimeOfDay() {
    if (this.length == 5) {
      return TimeOfDay(
          hour: int.parse(this.split(':')[0]),
          minute: int.parse(this.split(':')[1]));
    }
    throw Exception('cannot convert to time of day');
  }
}

extension calculateLength on TimeOfDay {
  double getDifference(TimeOfDay other, bool nextDay) {
    double current = this.hour + this.minute / 60.0;
    double compare = other.hour + other.minute / 60.0;
    if (!nextDay) {
      return compare - current;
    } else {
      return compare + (24 - current);
    }
  }
}

extension toStringDateTime on DateTime {
  String timeFormatToString() {
    return '${this.hour < 10 ? '0${this.hour}' : this.hour}:${this.minute < 10 ? '0${this.minute}' : this.minute}';
  }

  String dateFormatToString() {
    return '${this.day} ${this.monthToString()} ${this.year}';
  }

  String dayOfWeekToString() {
    List<String> days = ['Mon', 'Tues', 'Weds', 'Thurs', 'Fri', 'Sat', 'Sun'];
    return days[this.weekday - 1];
  }

  String monthToString() {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[this.month - 1];
  }
}

extension dateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
