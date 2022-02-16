import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/widgets/calendar_card.dart';
import 'package:rota_checker/widgets/calendar_duty.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/extension_methods.dart';
import 'package:rota_checker/widgets/calendar_day.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';

class CalendarWeekView extends ConsumerWidget {
  CalendarWeekView(
      {required this.focusDate,
      required this.forwardAction,
      required this.backwardAction});

  final DateTime focusDate;
  final void Function() forwardAction;
  final void Function() backwardAction;

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
                                              Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(Navigator
                                                      .defaultRouteName));
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

    //get first day of the week during the focus date week
    int dayOfWeek = focusDate.weekday;
    DateTime firstDayOfWeek = dayOfWeek != 1
        ? DateTime(
            focusDate.year, focusDate.month, focusDate.day - (dayOfWeek - 1))
        : focusDate;
    DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));

    Card buildTopCard() {
      return Card(
        elevation: kCalendarCardElevation,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                //Fixed width to allow for all month texts of varying lengths
                width: 120.0,
                child: AutoSizeText(
                  '${firstDayOfWeek.day}${firstDayOfWeek.month == lastDayOfWeek.month ? '' : ' ${firstDayOfWeek.monthToString().substring(0, 3)}'} - ${lastDayOfWeek.day} ${lastDayOfWeek.monthToString().substring(0, 3)} ${lastDayOfWeek.year}',
                  style: TextStyle(
                      color: kDarkPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                  minFontSize: 12.0,
                  maxLines: 1,
                ),
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
                child: Wrap(
                  spacing: 10.0,
                  alignment: WrapAlignment.end,
                  children: [
                    TextIconButton(
                      text: 'Clear all',
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
                                                        .read(dataProvider
                                                            .notifier)
                                                        .clearCalendar();
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
                      isActive:
                          ref.watch(dataProvider).duties.isEmpty ? false : true,
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
      );
    }

    Widget generateRows(bool scrollable) {
      List<Widget> dateList = [];

      for (int i = 0; i < 7; i++) {
        DateTime date = firstDayOfWeek.add(Duration(days: i));
        if (scrollable) {
          Container container = Container(
            height: 50.0,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              CalendarDay(
                day: date.dayOfWeekToString(),
                vertical: true,
              ),
              Expanded(
                child: CalendarCard(
                  duties: dutiesOnDate(date),
                  isSelected: selectedDates.contains(date) ? true : false,
                  isActiveMonth: true,
                  date: date,
                  horizontalView: true,
                ),
              ),
            ]),
          );
          dateList.add(container);
        } else {
          Expanded row = Expanded(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              CalendarDay(
                day: date.dayOfWeekToString(),
                vertical: true,
              ),
              Expanded(
                child: CalendarCard(
                  duties: dutiesOnDate(date),
                  isSelected: selectedDates.contains(date) ? true : false,
                  isActiveMonth: true,
                  date: date,
                  horizontalView: true,
                ),
              ),
            ]),
          );
          dateList.add(row);
        }
      }

      return Expanded(
        child: scrollable
            ? SingleChildScrollView(
                child: Column(
                  children: dateList,
                  mainAxisSize: MainAxisSize.min,
                ),
              )
            : Column(
                children: dateList,
              ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight(context) * 0.005,
          horizontal: screenWidth(context) * 0.035),
      child: Container(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight > 400) {
              return Column(children: [
                buildTopCard(),
                generateRows(false),
              ]);
            } else {
              return Column(children: [
                buildTopCard(),
                generateRows(true),
              ]);
            }
          },
        ),
      ),
    );
  }
}
