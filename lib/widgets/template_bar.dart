import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:rota_checker/widgets/template_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemplateBar extends ConsumerStatefulWidget {
  TemplateBar({this.isMini = false});

  final bool isMini;

  @override
  TemplateBarState createState() => TemplateBarState();
}

class TemplateBarState extends ConsumerState<TemplateBar> {
  double fontSize = 14.0;
  Color fontColour = kText;
  FontWeight fontWeight = FontWeight.normal;
  Duration animationDuration = Duration(milliseconds: 600);

  void saveToPrefs(String string) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('duties', string);
  }

  void animateText() {
    //Enlarge and decrease the size of the text informing the user what to do
    setState(() {
      fontWeight = FontWeight.bold;
      fontColour = kContrast;
      fontSize = 14.5;
    });
    //Return text style to normal following completion of the animation
    Future.delayed(animationDuration, () {
      setState(() {
        fontSize = 14.0;
        fontColour = kText;
        fontWeight = FontWeight.normal;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
          color: kLightGrey,
          width: 1.5,
        )),
        color: Colors.white,
      ),
      height: widget.isMini ? kTemplateBarHeightMobile : kTemplateBarHeightWeb,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AnimatedDefaultTextStyle(
                    duration: animationDuration,
                    curve: Curves.ease,
                    style: TextStyle(
                        color: fontColour,
                        fontSize: fontSize,
                        fontWeight: fontWeight),
                    child: Text(
                      ref.watch(dataProvider).selectedTemplate == null
                          ? 'Choose a Template'
                          : 'Select dates',
                    ),
                  ),
                ),
                TextIconButton(
                  text: 'Apply',
                  colour: kDarkPrimary,
                  icon: Icons.check,
                  onPress: ref.watch(dataProvider).selectedTemplate != null &&
                          ref.watch(dataProvider).selectedDates.isNotEmpty
                      ? () {
                          List<String> errors = ref
                              .read(dataProvider.notifier)
                              .addTemplateToDates();
                          saveToPrefs(
                              ref.read(dataProvider.notifier).dutiesAsJson());
                          if (errors.isNotEmpty) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: kContrast,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text('There was a problem')
                                    ]),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: errors
                                          .map((item) => Text(item))
                                          .toList(),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          'OK',
                                          style: TextStyle(color: kPrimary),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        }
                      : () {
                          animateText();
                        },
                  isActive: ref.watch(dataProvider).selectedTemplate != null &&
                          ref.watch(dataProvider).selectedDates.isNotEmpty
                      ? true
                      : false,
                ),
              ],
            ),
          ),
          TemplateList(
            isMini: widget.isMini,
          ),
        ],
      ),
    );
  }
}
