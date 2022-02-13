import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';

class CalendarCard extends StatelessWidget {
  final String date;
  final String day;
  final List<Widget> duties;
  final bool isSelected;
  final Function() onPress;
  final bool isActiveMonth;

  CalendarCard(
      {required this.date,
      required this.day,
      required this.duties,
      required this.isSelected,
      required this.onPress,
      required this.isActiveMonth});

  @override
  Widget build(BuildContext context) {
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
              Text(
                '$date ',
                style: TextStyle(
                    color: isActiveMonth ? kText : kSecondaryText,
                    fontWeight:
                        isActiveMonth ? FontWeight.bold : FontWeight.normal,
                    fontSize: screenHeight(context) > 550
                        ? kCalendarCardPrimaryTextSize
                        : kCalendarCardMiniPrimaryTextSize),
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
  }
}
