import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/constants.dart';

class TemplateCard extends StatelessWidget {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final bool isOnCall;
  final double? expectedHours;

  TemplateCard(
      {required this.name,
      required this.startTime,
      required this.endTime,
      required this.isOnCall,
      required this.expectedHours});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: kCalendarCardElevation,
      child: Container(
        width: kTemplateCardWidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                name,
                maxLines: 1,
                style: TextStyle(
                  color: kText,
                ),
              ),
              Text(
                'Type: ${isOnCall ? 'On Call' : 'Shift'}',
                style: TextStyle(color: kSecondaryText),
              ),
              SizedBox(
                height: 8.0,
              ),
              RichText(
                text: TextSpan(
                  text: 'Start time: ',
                  children: [
                    TextSpan(
                        text: startTime.dateFormatToString(),
                        style: TextStyle(color: kSecondaryText)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'End time: ',
                  children: [
                    TextSpan(
                        text:
                            '${endTime.dateFormatToString()} ${startTime.isSameDate(endTime) ? '' : '(+1)'}',
                        style: TextStyle(color: kSecondaryText)),
                  ],
                ),
              ),
              if (isOnCall)
                RichText(
                  text: TextSpan(
                    text: 'Expected Hours: ',
                    children: [
                      TextSpan(
                          text: expectedHours.toString(),
                          style: TextStyle(color: kSecondaryText)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
