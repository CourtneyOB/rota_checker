import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/model/on_call_template.dart';

enum WorkDutyType {
  shift,
  oncall,
}

class TemplateForm extends ConsumerStatefulWidget {
  TemplateForm({this.isEdit = false});
  TemplateForm.fromTemplate({required this.template, this.isEdit = true}) {
    if (template is OnCallTemplate) {
      dutyType = WorkDutyType.oncall;
      expectedHours = (template as OnCallTemplate).expectedHours;
    } else {
      dutyType = WorkDutyType.shift;
    }
    templateName = template!.name;
    selectedStartTime = TimeOfDay(
        hour: template!.startTime.hour, minute: template!.startTime.minute);
    selectedEndTime = TimeOfDay(
        hour: template!.endTime.hour, minute: template!.endTime.minute);
    length = template!.length;
    textEditingControllerStartTime.text =
        selectedStartTime!.timeFormatToString();
    textEditingControllerEndTime.text = selectedEndTime!.timeFormatToString();
    checkDayCount();
  }

  final TextEditingController textEditingControllerStartTime =
      TextEditingController();
  final TextEditingController textEditingControllerEndTime =
      TextEditingController();

  bool isEdit;
  Template? template;

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

  @override
  _TemplateFormState createState() => _TemplateFormState();
}

class _TemplateFormState extends ConsumerState<TemplateForm> {
  final formKey = GlobalKey<FormState>();
  late FocusNode focusNodeName;
  late FocusNode focusNodeStartTime;
  late FocusNode focusNodeEndTime;
  late FocusNode focusNodeExpectedHours;

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      if (!widget.isEdit) {
        //submit data
        ref.read(dataProvider.notifier).addTemplate(
            widget.templateName!,
            widget.selectedStartTime!,
            widget.length!,
            widget.dutyType == WorkDutyType.oncall ? true : false,
            widget.expectedHours);
      } else {
        if (ref
                .read(dataProvider)
                .duties
                .firstWhereOrNull((item) => item.template == widget.template) !=
            null) {
          //template has been used already
          bool confirm = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Are you sure?'),
                  content: Container(
                    width: screenWidth(context) * 0.4,
                    child: Text(
                        'If you edit this template, instances already added to the calendar will also be edited. If this overlaps with existing shifts it will be deleted from the calendar. Do you wish to edit this template?'),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextIconButton(
                              text: 'Cancel',
                              icon: Icons.close,
                              colour: kDarkPrimary,
                              onPress: () {
                                Navigator.of(context).pop(false);
                              },
                              isActive: true),
                          TextIconButton(
                              text: 'Confirm',
                              icon: Icons.check,
                              colour: kDarkPrimary,
                              onPress: () {
                                Navigator.of(context).pop(true);
                              },
                              isActive: true),
                        ],
                      ),
                    ),
                  ],
                );
              });
          if (!confirm) {
            return;
          }
        }
        //edit data
        ref.read(dataProvider.notifier).editTemplate(
            widget.template!,
            widget.templateName!,
            widget.selectedStartTime!,
            widget.length!,
            widget.dutyType == WorkDutyType.oncall ? true : false,
            widget.expectedHours);
      }
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
      title: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
        child: Row(
          children: [
            Container(
              height: 12.0,
              width: 8.0,
              decoration: BoxDecoration(
                  color: widget.isEdit
                      ? widget.template!.colour
                      : kTemplateColors[ref.watch(dataProvider).currentColour],
                  borderRadius: BorderRadius.all(Radius.circular(1.0))),
            ),
            SizedBox(
              width: 5.0,
            ),
            Text(widget.templateName == null
                ? 'New Template'
                : widget.templateName!),
          ],
        ),
      ),
      content: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio(
                                  visualDensity: VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  value: WorkDutyType.shift,
                                  groupValue: widget.dutyType,
                                  onChanged: (WorkDutyType? value) {
                                    setState(() {
                                      widget.dutyType = value;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, left: 8.0),
                                  child: Text('Shift'),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                    visualDensity: VisualDensity(
                                        horizontal: -4, vertical: -4),
                                    value: WorkDutyType.oncall,
                                    groupValue: widget.dutyType,
                                    onChanged: (WorkDutyType? value) {
                                      setState(() {
                                        widget.dutyType = value;
                                      });
                                    }),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, left: 8.0),
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
                  if (widget.dutyType == null) {
                    return 'Please choose an option';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: widget.templateName,
                focusNode: focusNodeName,
                onTap: () {
                  setState(() {
                    FocusScope.of(context).requestFocus(focusNodeName);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    widget.templateName = value;
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
                controller: widget.textEditingControllerStartTime,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '##:##',
                    filter: {"#": RegExp(r'[0-9]')},
                  )
                ],
                focusNode: focusNodeStartTime,
                onTap: () async {
                  widget.selectedStartTime = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  setState(() {
                    if (widget.selectedStartTime != null) {
                      widget.textEditingControllerStartTime.text =
                          widget.selectedStartTime!.timeFormatToString();
                      widget.checkDayCount();
                    }
                    FocusScope.of(context).requestFocus(focusNodeStartTime);
                  });
                },
                onChanged: (value) {
                  try {
                    widget.selectedStartTime = value.parseToTimeOfDay();
                  } catch (e) {}
                  widget.checkDayCount();
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
                controller: widget.textEditingControllerEndTime,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '##:## ####',
                    filter: {"#": RegExp(r'[0-9]')},
                  )
                ],
                focusNode: focusNodeEndTime,
                onTap: () async {
                  widget.selectedEndTime = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  setState(() {
                    if (widget.selectedEndTime != null) {
                      widget.textEditingControllerEndTime.text =
                          widget.selectedEndTime!.timeFormatToString();
                      widget.checkDayCount();
                    }
                    FocusScope.of(context).requestFocus(focusNodeEndTime);
                  });
                },
                onChanged: (value) {
                  try {
                    widget.selectedEndTime = value.parseToTimeOfDay();
                    widget.checkDayCount();
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
              if (widget.dutyType == WorkDutyType.oncall)
                SizedBox(
                  height: 16.0,
                ),
              if (widget.dutyType == WorkDutyType.oncall)
                TextFormField(
                  initialValue: widget.expectedHours != null
                      ? widget.expectedHours.toString()
                      : null,
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
                      FocusScope.of(context)
                          .requestFocus(focusNodeExpectedHours);
                    });
                  },
                  onChanged: (value) {
                    widget.expectedHours = double.parse(value);
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
                    if (widget.length != null) {
                      if (double.parse(value) > widget.length!) {
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
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextIconButton(
                text: 'Cancel',
                icon: Icons.close,
                colour: kContrast,
                onPress: () {
                  Navigator.pop(context);
                },
                isActive: true),
            TextIconButton(
                text: widget.isEdit ? 'Edit' : 'Add',
                icon: Icons.add,
                colour: kDarkPrimary,
                onPress: submitForm,
                isActive: true),
          ]),
        ),
      ],
    );
  }
}
