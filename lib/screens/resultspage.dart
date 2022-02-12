import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/widgets/results_row.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({Key? key}) : super(key: key);

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
        title: Text('Results'),
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
                      'Your Rota Compliance',
                      style: kMainHeader,
                    ),
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
