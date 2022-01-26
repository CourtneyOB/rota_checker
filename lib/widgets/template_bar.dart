import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/custom_scroll_behaviour.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/shift.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/widgets/template_card.dart';
import 'package:rota_checker/model/template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateBar extends ConsumerWidget {
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

    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
          color: kLightGrey,
          width: 1.5,
        )),
        color: Colors.white,
      ),
      height: kTemplateBarHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref.watch(dataProvider).selectedTemplate == null
                      ? 'Choose a Template'
                      : 'Select dates',
                  style: TextStyle(color: kText),
                ),
                if (ref.watch(dataProvider).selectedTemplate != null &&
                    ref.watch(dataProvider).selectedDates.isNotEmpty)
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text('Apply'),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
          Expanded(
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
                      itemCount: templates.length,
                      itemBuilder: (BuildContext context, index) {
                        return templates[index];
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
