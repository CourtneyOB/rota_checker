import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';

class CalendarDuty extends StatelessWidget {
  const CalendarDuty({
    Key? key,
    required this.colour,
    required this.name,
    required this.time,
    this.textColour = kText,
  }) : super(key: key);

  final MaterialColor colour;
  final String name;
  final Color textColour;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
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
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 12.0, color: textColour),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0,
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
