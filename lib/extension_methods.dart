extension toString on DateTime {
  String dateFormatToString() {
    return '${this.hour < 10 ? '0${this.hour}' : this.hour}:${this.minute < 10 ? '0${this.minute}' : this.minute}';
  }
}

extension dateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
