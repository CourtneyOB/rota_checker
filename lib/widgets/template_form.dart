import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/widgets/template_title.dart';

enum WorkDutyType {
  shift,
  oncall,
}

class TemplateForm extends ConsumerStatefulWidget {
  const TemplateForm({Key? key}) : super(key: key);

  @override
  _TemplateFormState createState() => _TemplateFormState();
}

class _TemplateFormState extends ConsumerState<TemplateForm> {
  final formKey = GlobalKey<FormState>();
  late FocusNode focusNodeName;
  late FocusNode focusNodeStartTime;
  late FocusNode focusNodeEndTime;
  late FocusNode focusNodeExpectedHours;
  final TextEditingController textEditingControllerStartTime =
      TextEditingController();
  final TextEditingController textEditingControllerEndTime =
      TextEditingController();

  WorkDutyType? dutyType;
  String? templateName;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  double? length;
  double? expectedHours;

  void checkDayCount() {
    if (selectedStartTime != null && selectedEndTime != null) {
      if (selectedEndTime!.compareTo(selectedStartTime!) <= 0) {
        textEditingControllerEndTime.text =
            '${selectedEndTime!.timeFormatToString()} (+1)';
        length = selectedStartTime!.getDifference(selectedEndTime!, true);
      } else {
        textEditingControllerEndTime.text =
            selectedEndTime!.timeFormatToString();
        length = selectedStartTime!.getDifference(selectedEndTime!, false);
      }
    }
  }

  void submitForm() {
    if (formKey.currentState!.validate()) {
      //submit data
      ref.read(dataProvider.notifier).addTemplate(
          templateName!,
          selectedStartTime!,
          length!,
          dutyType == WorkDutyType.oncall ? true : false,
          expectedHours);
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    focusNodeName = FocusNode();
    focusNodeStartTime = FocusNode();
    focusNodeEndTime = FocusNode();
    focusNodeExpectedHours = FocusNode();
  }

  @override
  void dispose() {
    focusNodeName.dispose();
    focusNodeStartTime.dispose();
    focusNodeEndTime.dispose();
    focusNodeExpectedHours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            height: 12.0,
            width: 8.0,
            decoration: BoxDecoration(
                color: kTemplateColors[ref.watch(dataProvider).currentColour],
                borderRadius: BorderRadius.all(Radius.circular(1.0))),
          ),
          SizedBox(
            width: 5.0,
          ),
          Text(templateName == null ? 'New Template' : templateName!),
        ],
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormField(
              builder: (FormFieldState<bool> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template Type',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Row(
                        children: [
                          Radio(
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4),
                            value: WorkDutyType.shift,
                            groupValue: dutyType,
                            onChanged: (WorkDutyType? value) {
                              setState(() {
                                dutyType = value;
                                state.setValue(true);
                              });
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 15.0, left: 8.0),
                            child: Text('Shift'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4),
                              value: WorkDutyType.oncall,
                              groupValue: dutyType,
                              onChanged: (WorkDutyType? value) {
                                setState(() {
                                  dutyType = value;
                                  state.setValue(true);
                                });
                              }),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 15.0, left: 8.0),
                            child: Text('On Call Period'),
                          ),
                        ],
                      ),
                    ]),
                    if (state.hasError)
                      SizedBox(
                        height: 10.0,
                      ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style:
                            Theme.of(context).inputDecorationTheme.errorStyle,
                      )
                  ],
                );
              },
              validator: (value) {
                if (value != true) {
                  return 'Please choose an option';
                }
                return null;
              },
            ),
            TextFormField(
              focusNode: focusNodeName,
              onTap: () {
                setState(() {
                  FocusScope.of(context).requestFocus(focusNodeName);
                });
              },
              onChanged: (value) {
                setState(() {
                  templateName = value;
                });
              },
              onFieldSubmitted: (value) {
                submitForm();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a name';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'e.g. normal working day',
                labelText: 'Title',
                labelStyle: TextStyle(
                    color: focusNodeName.hasFocus ? kDarkPrimary : null),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kDarkPrimary),
                ),
              ),
              style: TextStyle(color: kText),
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: textEditingControllerStartTime,
              inputFormatters: [
                MaskTextInputFormatter(
                  mask: '##:##',
                  filter: {"#": RegExp(r'[0-9]')},
                )
              ],
              focusNode: focusNodeStartTime,
              onTap: () async {
                selectedStartTime = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                setState(() {
                  if (selectedStartTime != null) {
                    textEditingControllerStartTime.text =
                        selectedStartTime!.timeFormatToString();
                    checkDayCount();
                  }
                  FocusScope.of(context).requestFocus(focusNodeStartTime);
                });
              },
              onChanged: (value) {
                try {
                  selectedStartTime = value.parseToTimeOfDay();
                } catch (e) {}
                checkDayCount();
              },
              onFieldSubmitted: (value) {
                submitForm();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a time';
                }
                if (int.parse(value.split(':')[0]) > 23) {
                  return 'Not a valid time';
                }
                if (int.parse(value.split(':')[1]) > 59) {
                  return 'Not a valid time';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Start time',
                hintText: '09:00',
                labelStyle: TextStyle(
                    color: focusNodeStartTime.hasFocus ? kDarkPrimary : null),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kDarkPrimary),
                ),
              ),
              style: TextStyle(color: kText),
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: textEditingControllerEndTime,
              inputFormatters: [
                MaskTextInputFormatter(
                  mask: '##:## ####',
                  filter: {"#": RegExp(r'[0-9]')},
                )
              ],
              focusNode: focusNodeEndTime,
              onTap: () async {
                selectedEndTime = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                setState(() {
                  if (selectedEndTime != null) {
                    textEditingControllerEndTime.text =
                        selectedEndTime!.timeFormatToString();
                    checkDayCount();
                  }
                  FocusScope.of(context).requestFocus(focusNodeEndTime);
                });
              },
              onChanged: (value) {
                try {
                  selectedEndTime = value.parseToTimeOfDay();
                  checkDayCount();
                } catch (e) {}
              },
              onFieldSubmitted: (value) {
                submitForm();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a time';
                }
                if (int.parse(value.split(':')[0]) > 23) {
                  return 'Not a valid time';
                }
                if (int.parse(value.split(':')[1].substring(0, 2)) > 59) {
                  return 'Not a valid time';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'End time',
                hintText: '17:00',
                labelStyle: TextStyle(
                    color: focusNodeEndTime.hasFocus ? kDarkPrimary : null),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kDarkPrimary),
                ),
              ),
              style: TextStyle(color: kText),
            ),
            if (dutyType == WorkDutyType.oncall)
              SizedBox(
                height: 16.0,
              ),
            if (dutyType == WorkDutyType.oncall)
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    try {
                      final text = newValue.text;
                      if (text.isNotEmpty) double.parse(text);
                      return newValue;
                    } catch (e) {}
                    return oldValue;
                  }),
                ],
                focusNode: focusNodeExpectedHours,
                onTap: () {
                  setState(() {
                    FocusScope.of(context).requestFocus(focusNodeExpectedHours);
                  });
                },
                onChanged: (value) {
                  expectedHours = double.parse(value);
                },
                onFieldSubmitted: (value) {
                  submitForm();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter number of expected work hours';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Number must be more than 0';
                  }
                  if (length != null) {
                    if (double.parse(value) > length!) {
                      return 'Cannot be longer than shift length';
                    }
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Expected work hours',
                  hintText: 'e.g. 4',
                  labelStyle: TextStyle(
                      color: focusNodeExpectedHours.hasFocus
                          ? kDarkPrimary
                          : null),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kDarkPrimary),
                  ),
                ),
                style: TextStyle(color: kText),
              ),
            SizedBox(
              height: 16.0,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextIconButton(
                  text: 'Add',
                  icon: Icons.add,
                  colour: kDarkPrimary,
                  onPress: submitForm,
                  isActive: true),
            ),
          ],
        ),
      ),
    );
  }
}
