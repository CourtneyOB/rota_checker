import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/custom_scroll_behaviour.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/model/on_call_template.dart';
import 'package:rota_checker/model/shift_template.dart';
import 'package:rota_checker/widgets/template_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateBar extends ConsumerWidget {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TemplateCard> templates = ref
        .watch(dataProvider)
        .templateLibrary
        .map((item) => TemplateCard(
              name: item.name,
              startTime: item.startTime,
              endTime: item.endTime,
              isOnCall: item is OnCallTemplate ? true : false,
              expectedHours: item is OnCallTemplate ? item.expectedHours : null,
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
            child: Text(
              'Choose a Template',
              style: TextStyle(color: kText),
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
