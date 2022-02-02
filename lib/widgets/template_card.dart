import 'package:flutter/material.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/widgets/circle_avatar_letter.dart';
import 'package:rota_checker/widgets/template_title.dart';

class TemplateCard extends StatelessWidget {
  final String name;
  final Color colour;
  final DateTime startTime;
  final DateTime endTime;
  final bool isOnCall;
  final double? expectedHours;
  final bool isNight;
  final bool isLong;
  final bool isEveningFinish;

  final Function() onPress;
  final Function() editTemplate;

  final bool isSelected;

  TemplateCard(
      {required this.name,
      required this.colour,
      required this.startTime,
      required this.endTime,
      required this.isOnCall,
      required this.expectedHours,
      required this.isNight,
      required this.isLong,
      required this.isEveningFinish,
      required this.isSelected,
      required this.onPress,
      required this.editTemplate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Card(
        shape: isSelected
            ? RoundedRectangleBorder(
                side: BorderSide(color: kPrimary, width: 1.5),
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
                TemplateTitle(
                  colour: colour,
                  name: name,
                  canEdit: true,
                  editTemplate: editTemplate,
                ),
                SizedBox(
                  height: 2.0,
                ),
                Row(
                  children: [
                    Text(
                      'Type: ${isOnCall ? 'On Call' : 'Shift'}',
                      style: TextStyle(color: kSecondaryText),
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    if (isNight)
                      CircleAvatarLetter(
                        text: 'N',
                        colour: Colors.red,
                      ),
                    SizedBox(
                      width: 2.0,
                    ),
                    if (isLong)
                      CircleAvatarLetter(
                        text: 'L',
                        colour: Colors.green,
                      ),
                    SizedBox(
                      width: 2.0,
                    ),
                    if (isEveningFinish)
                      CircleAvatarLetter(
                        text: 'E',
                        colour: Colors.blue,
                      ),
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Start time: ',
                    children: [
                      TextSpan(
                          text: startTime.timeFormatToString(),
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
                              '${endTime.timeFormatToString()} ${startTime.isSameDate(endTime) ? '' : '(+1)'}',
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
