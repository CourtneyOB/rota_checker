import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/constants.dart';

class TemplateCard extends StatelessWidget {
  final String name;
  final Color colour;
  final DateTime startTime;
  final DateTime endTime;
  final bool isOnCall;
  final double? expectedHours;

  final Function() onPress;

  final bool isSelected;

  TemplateCard(
      {required this.name,
      required this.colour,
      required this.startTime,
      required this.endTime,
      required this.isOnCall,
      required this.expectedHours,
      required this.isSelected,
      required this.onPress});

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
        child: Container(
          width: kTemplateCardWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 12.0,
                      width: 8.0,
                      decoration: BoxDecoration(
                          color: colour,
                          borderRadius: BorderRadius.all(Radius.circular(1.0))),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: AutoSizeText(
                        name,
                        maxLines: 1,
                        style: TextStyle(
                          color: kText,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.0,
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
      ),
    );
  }
}
