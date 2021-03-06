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
import 'package:shared_preferences/shared_preferences.dart';

class CalendarWeekView extends ConsumerWidget {
  void saveToPrefs(String string) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('duties', string);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime focusDate = ref.watch(dataProvider).displayDate;
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
                                              saveToPrefs(ref
                                                  .read(dataProvider.notifier)
                                                  .dutiesAsJson());
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
              Expanded(
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
                onPressed: ref.read(dataProvider.notifier).subtractWeek,
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: kDarkPrimary,
                ),
                splashRadius: 15.0,
                onPressed: ref.read(dataProvider.notifier).addWeek,
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
