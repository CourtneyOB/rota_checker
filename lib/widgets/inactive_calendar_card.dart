import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';

class InactiveCalendarCard extends StatelessWidget {
  final String date;
  final String day;

  InactiveCalendarCard({
    required this.date,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kLightGrey,
      elevation: kCalendarCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          text: TextSpan(
            text: '$date ',
            style: TextStyle(
                color: kSecondaryText,
                fontSize: screenHeight(context) > 550
                    ? kCalendarCardPrimaryTextSize
                    : kCalendarCardMiniPrimaryTextSize),
            children: [
              TextSpan(
                  text: day,
                  style: TextStyle(
                      color: kSecondaryText,
                      fontSize: screenHeight(context) > 550
                          ? kCalendarCardSecondaryTextSize
                          : kCalendarCardMiniSecondaryTextSize)),
            ],
          ),
        ),
      ),
    );
  }
}
