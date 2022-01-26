import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';

class CalendarCard extends StatelessWidget {
  final String date;
  final bool isSelected;
  final Function() onPress;

  CalendarCard(
      {required this.date, required this.isSelected, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Card(
        shape: isSelected
            ? RoundedRectangleBorder(
                side: BorderSide(color: kDarkPrimary, width: 1.5),
                borderRadius: BorderRadius.circular(4.0))
            : null,
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
      ),
    );
  }
}
