import 'package:flutter/material.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Calendar extends StatelessWidget {
  Calendar(
      {required this.selectedDate,
      required this.forwardAction,
      required this.backwardAction});

  final DateTime selectedDate;
  final void Function() forwardAction;
  final void Function() backwardAction;
  final int numberOfColumns = 7;
  int numberOfRows = 0;

  List<Widget> generateRows() {
    //Providing a day value of zero for the next month gives you the previous month's last day
    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    //Returns integer corresponding to day of the week
    int firstDayOfWeek =
        DateTime(selectedDate.year, selectedDate.month, 1).weekday;
    int lastDayOfWeek =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).weekday;

    int numberOfCards =
        daysInMonth + (firstDayOfWeek - 1) + (7 - lastDayOfWeek);
    numberOfRows = (numberOfCards / 7).toInt();

    List<Expanded> cards = [];
    for (int i = 0; i < firstDayOfWeek - 1; i++) {
      //Add blank spaces if doesn't start on a Monday
      cards.add(Expanded(
        child: Card(
          elevation: kCardElevation,
          color: klightGrey,
        ),
      ));
    }
    for (int i = 1; i <= daysInMonth; i++) {
      cards.add(Expanded(
        child: Card(
          elevation: kCardElevation,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              i.toString(),
              style: TextStyle(color: kText, fontSize: kCardTextSize),
            ),
          ),
        ),
      ));
    }
    for (int i = 0; i < 7 - lastDayOfWeek; i++) {
      //Add blank spaces if doesn't end on a Sunday
      cards.add(Expanded(
        child: Card(
          elevation: kCardElevation,
          color: klightGrey,
        ),
      ));
    }

    List<Widget> rowList = [];
    //first row displays month
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    rowList.add(Row(
      children: [
        Expanded(
          child: Card(
            elevation: kCardElevation,
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${months[selectedDate.month - 1]} ${selectedDate.year}',
                    style: TextStyle(color: kText, fontSize: kCardTextSize),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: kText,
                    ),
                    splashRadius: 15.0,
                    onPressed: backwardAction,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: kText,
                    ),
                    splashRadius: 15.0,
                    onPressed: forwardAction,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));

    //Organise cards into rows
    for (int i = 0; i < numberOfRows; i++) {
      List<Expanded> rowCards = [];
      for (int j = 0; j < 7; j++) {
        rowCards.add(cards[j]);
      }
      cards = cards.sublist(7);
      rowList.add(Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rowCards,
        ),
      ));
    }

    return rowList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight(context) * 0.05,
          horizontal: screenWidth(context) * 0.05),
      child: Container(
        child: Column(
          children: generateRows(),
        ),
      ),
    );
  }
}
