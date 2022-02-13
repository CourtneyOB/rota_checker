import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/template_title.dart';

class InactiveCalendarCard extends StatelessWidget {
  final String date;
  final String day;
  final bool isSelected;
  final List<Widget> duties;
  final Function() onPress;

  InactiveCalendarCard({
    required this.date,
    required this.day,
    required this.isSelected,
    required this.duties,
    required this.onPress,
  });

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
              RichText(
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
              ...duties,
            ],
          ),
        ),
      ),
    );
  }
}
