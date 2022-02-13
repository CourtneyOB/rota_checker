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
import 'package:rota_checker/widgets/template_form.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';

class TemplateList extends ConsumerWidget {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Template? selectedTemplate = ref.watch(dataProvider).selectedTemplate;
    List<Template> templateLibrary = ref.watch(dataProvider).templateLibrary;

    List<TemplateCard> templates = templateLibrary
        .map((item) => TemplateCard(
              template: item,
              isSelected: item == selectedTemplate ? true : false,
              editTemplate: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return TemplateForm.fromTemplate(template: item);
                    });
              },
              deleteTemplate: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Are you sure?'),
                        content: Container(
                          width: screenWidth(context) * 0.2,
                          child: Text(
                              'Deleting this template will also delete all instances of it on the calendar. Are you sure you wish to delete it?'),
                        ),
                        actions: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextIconButton(
                                    text: 'Cancel',
                                    icon: Icons.close,
                                    colour: kContrast,
                                    onPress: () {
                                      Navigator.of(context).pop();
                                    },
                                    isActive: true),
                                TextIconButton(
                                    text: 'Confirm',
                                    icon: Icons.check,
                                    colour: kDarkPrimary,
                                    onPress: () {
                                      ref
                                          .read(dataProvider.notifier)
                                          .deleteTemplate(item);
                                      Navigator.of(context).pop();
                                    },
                                    isActive: true),
                              ],
                            ),
                          ),
                        ],
                      );
                    });
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
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
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
