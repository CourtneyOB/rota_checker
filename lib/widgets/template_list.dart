import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/widgets/add_template_card.dart';
import 'package:rota_checker/widgets/template_card.dart';
import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/custom_scroll_behaviour.dart';
import 'package:rota_checker/constants.dart';

class TemplateList extends ConsumerWidget {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Template? selectedTemplate = ref.watch(dataProvider).selectedTemplate;
    List<Template> templateLibrary = ref.watch(dataProvider).templateLibrary;

    List<TemplateCard> templates = templateLibrary
        .map((item) => TemplateCard(
              name: item.name,
              colour: item.colour,
              startTime: item.startTime,
              endTime: item.endTime,
              isOnCall: item is OnCallTemplate ? true : false,
              expectedHours: item is OnCallTemplate ? item.expectedHours : null,
              isNight: item is ShiftTemplate ? item.isNight : false,
              isLong: item is ShiftTemplate ? item.isLong : false,
              isEveningFinish:
                  item is ShiftTemplate ? item.isEveningFinish : false,
              isSelected: item == selectedTemplate ? true : false,
              onPress: () {
                ref
                    .read(dataProvider.notifier)
                    .selectTemplate(templateLibrary.indexOf(item));
              },
            ))
        .toList();

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: kLightGrey)),
          color: kBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                itemCount: templates.length + 1,
                itemBuilder: (BuildContext context, index) {
                  if (index == templates.length) {
                    return AddTemplateCard();
                  }
                  return templates[index];
                }),
          ),
        ),
      ),
    );
  }
}
