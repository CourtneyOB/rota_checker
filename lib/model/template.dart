import 'package:flutter/material.dart';

abstract class Template {
  String name;
  DateTime startTime;
  double length;
  DateTime endTime;
  Color colour;

  Template(this.name, this.startTime, this.length, this.colour)
      : endTime = startTime.add(Duration(minutes: (length * 60).toInt()));
}
