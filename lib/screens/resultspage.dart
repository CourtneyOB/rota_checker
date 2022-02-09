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
                title: item.item2,
                result: item.item1,
                explanation: item.item3,
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: errorText != null
                        ? [Text(errorText)]
                        : results.isEmpty
                            ? [Text('No shifts entered')]
                            : results,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
