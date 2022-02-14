import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';

class CalendarDay extends StatelessWidget {
  const CalendarDay({Key? key, required this.day, this.vertical = false})
      : super(key: key);

  final String day;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return RotatedBox(
        quarterTurns: 1,
        child: Card(
          color: kDarkPrimary,
          child: Text(
            screenHeight(context) < 600 ? day.substring(0, 1) : day,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0, color: Colors.white),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Card(
          color: kDarkPrimary,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0, color: Colors.white),
          ),
        ),
      );
    }
  }
}
