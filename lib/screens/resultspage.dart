import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:rota_checker/widgets/coffee_button.dart';
import 'package:rota_checker/widgets/download_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rota_checker/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/widgets/results_row.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ResultsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? errorText;
    List<ResultsRow> results = [];

    try {
      results = ref
          .read(dataProvider.notifier)
          .checkCompliance()
          .map((item) => ResultsRow(
                title: item.name,
                result: item.result,
                explanation: item.text,
                about: item.about,
              ))
          .toList();
    } catch (e) {
      errorText = e.toString();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Your Rota Results'),
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
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: AutoSizeText(
                              'Your Rota Compliance',
                              style: kMainHeader,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        if (errorText == null)
                          DownloadButton(contents: results),
                      ],
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text:
                            'For more information about these rota rules, visit the ',
                        style: TextStyle(color: kLightGrey),
                      ),
                      TextSpan(
                          text: 'NHS Employers website',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launch(kNHSEmployersURL);
                            }),
                    ])),
                    SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: errorText != null
                              ? [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: kContrast,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(errorText),
                                    ],
                                  )
                                ]
                              : results,
                        ),
                      ),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Was this information useful? '),
                        CoffeeButton(),
                      ],
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
