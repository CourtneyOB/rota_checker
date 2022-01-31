class ShiftOverlapException implements Exception {
  String newShift;
  String date;

  ShiftOverlapException(this.newShift, this.date);

  @override
  String toString() =>
      '\u2022 $newShift cannot overlap with existing shift on $date';
}
