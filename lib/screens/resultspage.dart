import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:rota_checker/widgets/results_row.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Tuple2<bool, String> someTest =
        ref.read(dataProvider.notifier).checkCompliance();

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
                    children: [
                      ResultsRow(
                          title: 'Some test',
                          result: someTest.item1,
                          explanation: someTest.item2)
                    ],
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
