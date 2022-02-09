import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';

class ResultsRow extends StatelessWidget {
  ResultsRow(
      {required this.title, required this.result, required this.explanation});

  final String title;
  final bool result;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  flex: 4,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: Text(
                      result ? 'PASS' : 'FAIL',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: result ? Colors.green : Colors.red),
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: Text(
                      explanation,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  flex: 6,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: kBackground)),
          )
        ],
      ),
    );
  }
}
