extension toString on DateTime {
  String dateFormatToString() {
    return '${this.hour < 10 ? '0${this.hour}' : this.hour}:${this.minute < 10 ? '0${this.minute}' : this.minute}';
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
