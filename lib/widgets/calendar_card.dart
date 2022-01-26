import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';

class CalendarCard extends StatelessWidget {
  String date;

  CalendarCard({required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: kCalendarCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          date,
          style: TextStyle(
              color: kText,
              fontSize: screenHeight(context) > 550
                  ? kCalendarCardTextSize
                  : kCalendarCardMiniTextSize),
        ),
      ),
    );
  }
}
