import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rota_checker/constants.dart';

class CalendarDuty extends StatelessWidget {
  const CalendarDuty({
    Key? key,
    required this.colour,
    required this.name,
    required this.time,
    this.textColour = kText,
    this.maxFontSize = 14.0,
  }) : super(key: key);

  final MaterialColor colour;
  final String name;
  final Color textColour;
  final double maxFontSize;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 16.0,
            width: 8.0,
            decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.all(Radius.circular(1.0))),
          ),
          Expanded(
            child: Container(
              height: 16.0,
              decoration: BoxDecoration(
                color: colour.shade50,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: AutoSizeText(
                      time,
                      style: TextStyle(color: textColour),
                      maxFontSize: maxFontSize,
                      maxLines: 1,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      name,
                      maxLines: 1,
                      maxFontSize: maxFontSize,
                      style: TextStyle(
                        color: textColour,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
