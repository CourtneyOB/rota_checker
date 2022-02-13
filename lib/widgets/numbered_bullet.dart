import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';

class NumberedBullet extends StatelessWidget {
  NumberedBullet({this.number, required this.text});

  final int? number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${number == null ? '-' : '$number.'} ',
            style: kStandardText,
          ),
          Flexible(
            child: Text(
              text,
              style: kStandardText,
            ),
          ),
        ],
      ),
    );
  }
}
