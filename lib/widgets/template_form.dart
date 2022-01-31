import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';

class TemplateForm extends StatefulWidget {
  const TemplateForm({Key? key}) : super(key: key);

  @override
  _TemplateFormState createState() => _TemplateFormState();
}

class _TemplateFormState extends State<TemplateForm> {
  final formKey = GlobalKey<FormState>();
  late FocusNode focusNode;

  int? choice;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            focusNode: focusNode,
            onTap: () {
              setState(() {
                FocusScope.of(context).requestFocus(focusNode);
              });
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
              labelStyle:
                  TextStyle(color: focusNode.hasFocus ? kDarkPrimary : null),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kDarkPrimary),
              ),
            ),
            style: TextStyle(color: kText),
          ),
          SizedBox(
            height: 16.0,
          ),
          FormField(
            builder: (FormFieldState<bool> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Row(
                      children: [
                        Radio(
                            value: 1,
                            groupValue: choice,
                            onChanged: (int? value) {
                              setState(() {
                                choice = value;
                                state.setValue(true);
                              });
                            }),
                        Text('Choice 1'),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      children: [
                        Radio(
                            value: 2,
                            groupValue: choice,
                            onChanged: (int? value) {
                              setState(() {
                                choice = value;
                                state.setValue(true);
                              });
                            }),
                        Text('Choice 2'),
                      ],
                    )),
                  ]),
                  if (state.hasError)
                    SizedBox(
                      height: 10.0,
                    ),
                  if (state.hasError)
                    Text(
                      state.errorText!,
                      style: Theme.of(context).inputDecorationTheme.errorStyle,
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
          SizedBox(
            height: 16.0,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextIconButton(
                text: 'Add',
                icon: Icons.add,
                colour: kDarkPrimary,
                onPress: () {
                  if (formKey.currentState!.validate()) {
                    //submit data
                    Navigator.of(context).pop();
                  }
                },
                isActive: true),
          ),
        ],
      ),
    );
  }
}
