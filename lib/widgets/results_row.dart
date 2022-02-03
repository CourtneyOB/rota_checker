import 'package:flutter/material.dart';

class ResultsRow extends StatelessWidget {
  ResultsRow(
      {required this.title, required this.result, required this.explanation});

  final String title;
  final bool result;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: Text(title),
          ),
          flex: 2,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: Text(result ? 'PASS' : 'FAIL'),
          ),
          flex: 1,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: Text(explanation),
          ),
          flex: 5,
        ),
      ],
    );
  }
}
