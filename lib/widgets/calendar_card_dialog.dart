import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarCardDialog extends ConsumerWidget {
  final List<Widget> duties;

  final DateTime date;

  CalendarCardDialog({
    required this.duties,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
                color: kText,
                fontWeight: FontWeight.bold,
                fontSize: screenHeight(context) > 550
                    ? kCalendarCardPrimaryTextSize
                    : kCalendarCardMiniPrimaryTextSize),
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
            child: Column(
              children: duties,
            ),
          )
        ],
      ),
    );
  }
}
