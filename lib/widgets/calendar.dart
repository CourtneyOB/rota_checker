import 'package:flutter/material.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/widgets/calendar_card.dart';
import 'package:rota_checker/widgets/calendar_duty.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/widgets/calendar_day.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';

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
    List<Widget> dutiesOnDate(DateTime date) {
      return ref
          .read(dataProvider.notifier)
          .getDutiesOnDate(date)
          .map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: CalendarDuty(
                      colour: item.template.colour,
                      name: item.template.name,
                      textColour: kSecondaryText,
                      maxFontSize: 12.0,
                      time: '${item.startTime.timeFormatToString()}',
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Are you sure?'),
                                content: Container(
                                  width: screenWidth(context) * 0.2,
                                  child: Text(
                                      'Remove ${item.template.name} from ${date.dateFormatToString()}?'),
                                ),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextIconButton(
                                            text: 'Cancel',
                                            icon: Icons.close,
                                            colour: kContrast,
                                            onPress: () {
                                              Navigator.of(context).pop();
                                            },
                                            isActive: true),
                                        TextIconButton(
                                            text: 'Confirm',
                                            icon: Icons.check,
                                            colour: kDarkPrimary,
                                            onPress: () {
                                              ref
                                                  .read(dataProvider.notifier)
                                                  .removeTemplateFromDate(
                                                      item.template, date);
                                              Navigator.of(context).pop();
                                            },
                                            isActive: true),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Icon(
                        Icons.close,
                        size: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
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
          child: CalendarCard(
            duties: dutiesOnDate(date),
            isSelected: selectedDates.contains(date) ? true : false,
            isActiveMonth: false,
            date: date,
          ),
        ));
      }
      //requires reversal as iterating backwards
      cards = cards.reversed.toList();

      for (int i = 1; i <= daysInMonth; i++) {
        DateTime date = DateTime(focusDate.year, focusDate.month, i);
        cards.add(Expanded(
          child: CalendarCard(
            duties: dutiesOnDate(date),
            isSelected: selectedDates.contains(date) ? true : false,
            isActiveMonth: true,
            date: date,
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
            child: CalendarCard(
              duties: dutiesOnDate(date),
              isSelected: selectedDates.contains(date) ? true : false,
              isActiveMonth: false,
              date: date,
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
                            fontWeight: FontWeight.bold),
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextIconButton(
                            text: 'Clear Calendar',
                            icon: Icons.clear,
                            colour: kPrimary,
                            onPress: ref.watch(dataProvider).duties.isEmpty
                                ? () {}
                                : () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Are you sure?'),
                                            content: Container(
                                              width: screenWidth(context) * 0.2,
                                              child: Text(
                                                  'Remove all shifts from the calendar?'),
                                            ),
                                            actions: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    TextIconButton(
                                                        text: 'Cancel',
                                                        icon: Icons.close,
                                                        colour: kContrast,
                                                        onPress: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        isActive: true),
                                                    TextIconButton(
                                                        text: 'Confirm',
                                                        icon: Icons.check,
                                                        colour: kDarkPrimary,
                                                        onPress: () {
                                                          ref
                                                              .read(dataProvider
                                                                  .notifier)
                                                              .clearCalendar();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        isActive: true),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                            isActive: ref.watch(dataProvider).duties.isEmpty
                                ? false
                                : true,
                            isWide: true,
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          TextIconButton(
                              text: 'Get results',
                              icon: Icons.arrow_forward,
                              colour: kDarkPrimary,
                              onPress: () {
                                Navigator.pushNamed(context, '/results');
                              },
                              isActive: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ));

      rowList.add(Row(
        children: [
          CalendarDay(day: 'Mon'),
          CalendarDay(day: 'Tues'),
          CalendarDay(day: 'Weds'),
          CalendarDay(day: 'Thurs'),
          CalendarDay(day: 'Fri'),
          CalendarDay(day: 'Sat'),
          CalendarDay(day: 'Sun'),
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
          horizontal: screenWidth(context) * 0.035),
      child: Container(
        child: Column(
          children: generateRows(),
        ),
      ),
    );
  }
}
