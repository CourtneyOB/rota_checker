import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';

class CalendarCard extends StatelessWidget {
  final String date;
  final String day;
  final List<Widget> duties;
  final bool isSelected;
  final Function() onPress;

  CalendarCard(
      {required this.date,
      required this.day,
      required this.duties,
      required this.isSelected,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: onPress,
        child: Card(
          shape: isSelected
              ? RoundedRectangleBorder(
                  side: BorderSide(color: kPrimary, width: 2.0),
                  borderRadius: BorderRadius.circular(4.0))
              : null,
          elevation: isSelected
              ? kCalendarCardSelectedElevation
              : kCalendarCardElevation,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: '$date ',
                    style: TextStyle(
                        color: kText,
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight(context) > 550
                            ? kCalendarCardPrimaryTextSize
                            : kCalendarCardMiniPrimaryTextSize),
                    children: [
                      TextSpan(
                          text: day,
                          style: TextStyle(
                              color: kSecondaryText,
                              fontWeight: FontWeight.normal,
                              fontSize: screenHeight(context) > 550
                                  ? kCalendarCardSecondaryTextSize
                                  : kCalendarCardMiniSecondaryTextSize)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                ...duties,
              ],
            ),
          ),
        ),
      );
    });
  }
}
