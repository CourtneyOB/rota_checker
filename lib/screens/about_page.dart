import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rota_checker/widgets/numbered_bullet.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/shift_tags_row.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  bool canSubmit = false;
  String feedbackText = '';

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
            width: screenWidth(context) < 1000
                ? screenWidth(context) * 0.95
                : screenWidth(context) * 0.85,
            height: screenHeight(context) * 0.9,
            child: Card(
              elevation: kCalendarCardElevation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          filterQuality: FilterQuality.medium,
                          image: AssetImage(kLogo),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            'Junior Doctor Rota Checker',
                            style: kMainHeader,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Version v${kVersionNumber.toStringAsFixed(1)}. Last updated $kLastUpdate',
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
                                  style: kStandardText,
                                  text:
                                      'This tool is free to use and share. It is designed to check if your junior doctor rota is compliant with all the requirements of the 2016 contract (available from the '),
                              TextSpan(
                                  text: 'NHS Employers website',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await launch(kNHSEmployersURL);
                                    }),
                              TextSpan(
                                  style: kStandardText,
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
                            ShiftTagsRow(),
                            NumberedBullet(
                                number: 2,
                                text:
                                    'Either click and drag template onto desired date (web only), or select the template and then select the dates on which you are working that shift pattern. Hit "Apply" to add these to the calendar.'),
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
                              style: kStandardText,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            NumberedBullet(
                                text:
                                    'Ensuring that you get appropriate breaks e.g. 30 minute break for 5 hours work, a second at more than 9 hours etc. It also cannot account for ensuring adequate consecutive rest periods during low intensity on call'),
                            NumberedBullet(
                                text:
                                    'If you have made any local agreements with your employer to adjust the restrictions on your working hours'),
                            NumberedBullet(
                                text:
                                    'Ensuring that no trainee is rostered on-call for the same period being worked as a shift by another trainee on that rota'),
                            Text(
                              'Make sure you review your rota to ensure it is compliant with these above points and exception report if there are any discrepancies with your actual working hours.',
                              style: kStandardText,
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
                                          controller: _controller,
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
                                              feedbackText = value;
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
                                            if (canSubmit) {
                                              _firestore
                                                  .collection('feedback')
                                                  .add({'text': feedbackText});

                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      'Thanks for your feedback!'));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);

                                              feedbackText = '';
                                              _controller.text = '';
                                            }
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
