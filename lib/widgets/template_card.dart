import 'package:flutter/material.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/widgets/circle_avatar_letter.dart';
import 'package:rota_checker/widgets/template_title.dart';
import 'package:rota_checker/model/template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateCard extends ConsumerWidget {
  final Template template;
  final Function() editTemplate;
  final Function() deleteTemplate;

  final bool isSelected;
  final bool isMini;

  TemplateCard(
      {required this.isSelected,
      required this.editTemplate,
      required this.deleteTemplate,
      required this.template,
      this.isMini = false});

  Card buildCard() {
    return Card(
      shape: isSelected
          ? RoundedRectangleBorder(
              side: BorderSide(color: kPrimary, width: 1.5),
              borderRadius: BorderRadius.circular(4.0))
          : null,
      elevation: kCalendarCardElevation,
      child: Container(
        width: kTemplateCardWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 8.0, vertical: isMini ? 4.0 : 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TemplateTitle(
                      colour: template.colour,
                      name: template.name,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: editTemplate,
                      child: Icon(
                        Icons.edit,
                        size: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: deleteTemplate,
                      child: Icon(
                        Icons.close,
                        size: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 2.0,
              ),
              Row(
                children: [
                  Text(
                    'Type: ${template is OnCallTemplate ? 'On Call' : 'Shift'}',
                    style: TextStyle(
                        color: kSecondaryText, fontSize: isMini ? 12.0 : 14.0),
                  ),
                  SizedBox(
                    width: 2.0,
                  ),
                  if (template is ShiftTemplate &&
                      (template as ShiftTemplate).isNight)
                    CircleAvatarLetter(
                      text: 'N',
                      colour: Colors.red,
                    ),
                  SizedBox(
                    width: 2.0,
                  ),
                  if (template is ShiftTemplate &&
                      (template as ShiftTemplate).isLong)
                    CircleAvatarLetter(
                      text: 'L',
                      colour: Colors.green,
                    ),
                  SizedBox(
                    width: 2.0,
                  ),
                  if (template is ShiftTemplate &&
                      (template as ShiftTemplate).isEveningFinish)
                    CircleAvatarLetter(
                      text: 'E',
                      colour: Colors.blue,
                    ),
                ],
              ),
              SizedBox(
                height: isMini ? 2.0 : 8.0,
              ),
              RichText(
                text: TextSpan(
                  text: 'Start time: ',
                  style: TextStyle(fontSize: isMini ? 12.0 : 14.0),
                  children: [
                    TextSpan(
                        text: template.startTime.timeFormatToString(),
                        style: TextStyle(
                            color: kSecondaryText,
                            fontSize: isMini ? 12.0 : 14.0)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'End time: ',
                  style: TextStyle(fontSize: isMini ? 12.0 : 14.0),
                  children: [
                    TextSpan(
                        text:
                            '${template.endTime.timeFormatToString()} ${template.startTime.isSameDate(template.endTime) ? '' : '(+1)'}',
                        style: TextStyle(
                            color: kSecondaryText,
                            fontSize: isMini ? 12.0 : 14.0)),
                  ],
                ),
              ),
              if (template is OnCallTemplate && !isMini)
                RichText(
                  text: TextSpan(
                    text: 'Expected Hours: ',
                    style: TextStyle(fontSize: isMini ? 12.0 : 14.0),
                    children: [
                      TextSpan(
                          text: (template as OnCallTemplate)
                              .expectedHours
                              .toString(),
                          style: TextStyle(
                              color: kSecondaryText,
                              fontSize: isMini ? 12.0 : 14.0)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Template> templateLibrary = ref.watch(dataProvider).templateLibrary;
    return LayoutBuilder(builder: (context, constraints) {
      return Draggable<Template>(
        data: template,
        feedback: Container(height: constraints.maxHeight, child: buildCard()),
        child: GestureDetector(
            onTap: () {
              ref
                  .read(dataProvider.notifier)
                  .selectTemplate(templateLibrary.indexOf(template));
            },
            child: buildCard()),
      );
    });
  }
}
