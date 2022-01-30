import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/template_title.dart';

class CalendarCard extends StatelessWidget {
  final String date;
  final String day;
  final List<TemplateTitle> duties;
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
    return GestureDetector(
      onTap: onPress,
      child: Card(
        color: isSelected ? kPrimary : Colors.white,
        elevation: kCalendarCardElevation,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: '$date ',
                  style: TextStyle(
                      color: isSelected ? Colors.white : kText,
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight(context) > 550
                          ? kCalendarCardPrimaryTextSize
                          : kCalendarCardMiniPrimaryTextSize),
                  children: [
                    TextSpan(
                        text: day,
                        style: TextStyle(
                            color: isSelected ? Colors.white : kSecondaryText,
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
  }
}
