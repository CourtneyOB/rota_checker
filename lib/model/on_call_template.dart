import 'package:rota_checker/model/template.dart';
import 'package:flutter/material.dart';

class OnCallTemplate extends Template {
  double expectedHours;
  OnCallTemplate(String name, DateTime startTime, double length,
      MaterialColor colour, this.expectedHours)
      : super(name, startTime, length, colour);
}
