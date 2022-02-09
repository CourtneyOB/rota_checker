import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rota_checker/widgets/numbered_bullet.dart';
import 'package:rota_checker/main.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool canSubmit = false;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('About'),
      ),
      body: Container(
        color: kBackground,
        child: Center(
          child: Container(
            width: screenWidth(context) * 0.85,
            height: screenHeight(context) * 0.9,
            child: Card(
              elevation: kCalendarCardElevation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[Icon] Junior Doctor Rota Checker',
                      style: kMainHeader,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Last updated 09 Feb 2022',
                      style: TextStyle(color: kLightGrey),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text:
                                      'This tool is free to use and share. It is designed to check if your junior doctor rota is compliant with all the requirements of the 2016 contract (available from the '),
                              TextSpan(
                                  text: 'NHS Employers website',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await launch(
                                          'https://www.nhsemployers.org/publications/doctors-and-dentists-training-terms-and-conditions-england-2016');
                                    }),
                              TextSpan(
                                  text:
                                      '). If you have any feedback about this tool, please submit a feedback form at the bottom of this page.'),
                            ])),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'How to use',
                              style: kSubHeader,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            NumberedBullet(
                              number: 1,
                              text:
                                  'Add a shift or on call template to the templates list at the bottom of the page. Input its start time, end time and expected work hours (if applicable). The tool will automatically calculate which rota rules are relevant to the shift type (e.g. night shifts, long days and evening finishes.',
                            ),
                            NumberedBullet(
                                number: 2,
                                text:
                                    'Select the template, and then select the dates on which you are working that shift pattern. Hit "Apply" to add these to the calendar.'),
                            NumberedBullet(
                                number: 3,
                                text:
                                    'Continue to add your shifts and on call duties to the rota. Once completed, hit "Get Results" at the top right of the page.'),
                            Text(
                              'What this tool does not do',
                              style: kSubHeader,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'Some aspects of the 2016 TCS cannot be checked for compliance using this tool:',
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            NumberedBullet(
                                text:
                                    '30 minute break for 5 hours work, a second 30 minute break for more than 9 hours, and a third 30 minute break during a night shift at least 8 hours long'),
                            NumberedBullet(
                                text:
                                    'If you have agreed to increase the limit of consecutive shifts with your employer'),
                            NumberedBullet(
                                text:
                                    'Ensuring that no trainee is rostered on-call for the same period being worked as a shift by another trainee on that rota'),
                            Text(
                              'Make sure you review your rota to ensure it is compliant with these above points.',
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'Feedback',
                              style: kSubHeader,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Container(
                                        height: 205,
                                        child: TextField(
                                          controller: textEditingController,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  'Does something not work? Did you find this tool useful?'),
                                          maxLines: 10,
                                          maxLength: 1500,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value != '') {
                                                canSubmit = true;
                                              } else {
                                                canSubmit = false;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: TextIconButton(
                                          text: 'Submit',
                                          icon: Icons.check,
                                          colour: kContrast,
                                          onPress: () {
                                            //TODO function to submit feedback
                                          },
                                          isActive: canSubmit ? true : false),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
