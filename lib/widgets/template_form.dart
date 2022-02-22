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
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();

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
      prefs.setString(
          'templates', ref.read(dataProvider.notifier).templatesAsJson());
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
                      : kTemplateColors[ref.read(dataProvider).getColour()],
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
      content: SingleChildScrollView(
        child: Form(
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
                        Wrap(children: [
                          Row(
                            children: [
                              Radio(
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: -4),
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
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 6.0),
                                      child: Text('Shift'),
                                    ),
                                    Tooltip(
                                      textStyle: TextStyle(fontSize: 12.0),
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: kLightGrey),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0))),
                                      preferBelow: false,
                                      message:
                                          'The period which the employer schedules the doctor to be at the work place performing their duties, excluding any on-call duty periods.',
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 16.0,
                                        color: kContrast,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            mainAxisSize: MainAxisSize.min,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
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
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 6.0),
                                      child: Text('On Call Period'),
                                    ),
                                    Tooltip(
                                      textStyle: TextStyle(fontSize: 12.0),
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: kLightGrey),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0))),
                                      preferBelow: false,
                                      message:
                                          'A doctor is on-call when they are required by the employer to be available to return to work or to give advice by telephone but are not normally expected to be working on site for the whole period. A doctor carrying an ‘on-call’ bleep whilst already present at their place of work as part of their scheduled duties does not meet the definition of on-call working.',
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 16.0,
                                        color: kContrast,
                                      ),
                                    ),
                                  ],
                                ),
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
                            style: Theme.of(context)
                                .inputDecorationTheme
                                .errorStyle,
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
                        context: context,
                        initialTime: widget.isEdit
                            ? widget.selectedStartTime!
                            : TimeOfDay.now());
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
                        color:
                            focusNodeStartTime.hasFocus ? kDarkPrimary : null),
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
                        context: context,
                        initialTime: widget.isEdit
                            ? widget.selectedEndTime!
                            : TimeOfDay.now());
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.expectedHours != null
                              ? widget.expectedHours.toString()
                              : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r"[0-9.]")),
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
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
                      ),
                      Tooltip(
                        textStyle: TextStyle(fontSize: 12.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: kLightGrey),
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        preferBelow: false,
                        message:
                            'On you work schedule, this may need to be calculated by adding together your “Resident Hours” with your “Estimated Call-out”. Resident hours themselves may have to be calculated as it is more frequent for work schedules to only display non-resident start and finish times (or just NR Start and NR Finish). The employer must provide a prospective estimate of the average amount of work that will occur during an on-call shift. Such work includes any actual clinical or non-clinical work undertaken either on or off site, including telephone calls, actively awaiting urgent results or updates, and travel time arising from any such calls.',
                        child: Icon(
                          Icons.info_outline,
                          size: 16.0,
                          color: kContrast,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
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
                text: widget.isEdit ? 'Save' : 'Add',
                icon: widget.isEdit ? Icons.check : Icons.add,
                colour: kDarkPrimary,
                onPress: submitForm,
                isActive: true),
          ]),
        ),
      ],
    );
  }
}
