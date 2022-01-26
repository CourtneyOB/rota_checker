abstract class Template {
  String name;
  DateTime startTime;
  double length;
  DateTime endTime;

  Template(this.name, this.startTime, this.length)
      : endTime = startTime.add(Duration(minutes: (length * 60).toInt()));
}
