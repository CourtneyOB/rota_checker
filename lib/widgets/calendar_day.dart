import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';

class CalendarDay extends StatelessWidget {
  const CalendarDay({Key? key, required this.day}) : super(key: key);

  final String day;

  @override
  Widget build(BuildContext context) {
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
