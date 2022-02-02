import 'package:flutter/material.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/widgets/calendar_card.dart';
import 'package:rota_checker/widgets/inactive_calendar_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/widgets/template_title.dart';

class Calendar extends ConsumerWidget {
  Calendar(
      {required this.focusDate,
      required this.forwardAction,
      required this.backwardAction});

  final DateTime focusDate;
  final void Function() forwardAction;
  final void Function() backwardAction;
  final int numberOfColumns = 7;
  int numberOfRows = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DateTime> selectedDates = ref.watch(dataProvider).selectedDates;
    List<TemplateTitle> dutiesOnDate(DateTime date) {
      return ref
          .read(dataProvider.notifier)
          .getDutiesOnDate(date)
          .map((item) => TemplateTitle(
                colour: item.template.colour,
                name: item.template.name,
                textColour: selectedDates.contains(date)
                    ? Colors.white
                    : kSecondaryText,
                maxFontSize: 12.0,
                canEdit: false,
              ))
          .toList();
    }

    List<Widget> generateRows() {
      //Providing a day value of zero for the next month gives you the previous month's last day
      int daysInMonth = DateTime(focusDate.year, focusDate.month + 1, 0).day;

      //Returns integer corresponding to day of the week
      int firstDayOfWeek = DateTime(focusDate.year, focusDate.month, 1).weekday;
      int lastDayOfWeek =
          DateTime(focusDate.year, focusDate.month + 1, 0).weekday;

      int numberOfCards =
          daysInMonth + (firstDayOfWeek - 1) + (7 - lastDayOfWeek);
      numberOfRows = (numberOfCards / 7).toInt();

      List<Expanded> cards = [];
      for (int i = 0; i < firstDayOfWeek - 1; i++) {
        //Add previous month's dates if doesn't start on a Monday

        //calculates the relevant date from the previous month
        DateTime lastMonth =
            DateTime(focusDate.year, focusDate.month - 1, focusDate.day);
        DateTime date = DateTime(lastMonth.year, lastMonth.month,
            DateTime(focusDate.year, focusDate.month, 0).day - i);

        cards.add(Expanded(
          child: InactiveCalendarCard(
            date: date.day.toString(),
            day: date.dayOfWeekToString(),
            duties: dutiesOnDate(date),
            onPress: () {
              ref.read(dataProvider.notifier).selectDate(date);
            },
            isSelected: selectedDates.contains(date) ? true : false,
          ),
        ));
      }
      //requires reversal as iterating backwards
      cards = cards.reversed.toList();

      for (int i = 1; i <= daysInMonth; i++) {
        DateTime date = DateTime(focusDate.year, focusDate.month, i);
        cards.add(Expanded(
          child: CalendarCard(
            onPress: () {
              ref.read(dataProvider.notifier).selectDate(date);
            },
            date: i.toString(),
            day: date.dayOfWeekToString(),
            duties: dutiesOnDate(date),
            isSelected: selectedDates.contains(date) ? true : false,
          ),
        ));
      }

      for (int i = 0; i < 7 - lastDayOfWeek; i++) {
        //calculates the relevant date for the next month
        DateTime lastMonth =
            DateTime(focusDate.year, focusDate.month + 1, focusDate.day);
        DateTime date = DateTime(lastMonth.year, lastMonth.month, i + 1);
        //Add blank spaces if doesn't end on a Sunday
        cards.add(
          Expanded(
            child: InactiveCalendarCard(
              date: date.day.toString(),
              day: date.dayOfWeekToString(),
              duties: dutiesOnDate(date),
              onPress: () {
                ref.read(dataProvider.notifier).selectDate(date);
              },
              isSelected: selectedDates.contains(date) ? true : false,
            ),
          ),
        );
      }

      List<Widget> rowList = [];
      //first row displays month
      rowList.add(Row(
        children: [
          Expanded(
            child: Card(
              elevation: kCalendarCardElevation,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      //Fixed width to allow for all month texts of varying lengths
                      width: 180.0,
                      child: Text(
                        '${focusDate.monthToString()} ${focusDate.year}',
                        style: TextStyle(
                            color: kDarkPrimary,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: kDarkPrimary,
                      ),
                      splashRadius: 15.0,
                      onPressed: backwardAction,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: kDarkPrimary,
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

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight(context) * 0.02,
          horizontal: screenWidth(context) * 0.02),
      child: Container(
        child: Column(
          children: generateRows(),
        ),
      ),
    );
  }
}
