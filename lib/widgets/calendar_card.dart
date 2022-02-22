import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/model/template.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/calendar_card_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarCard extends ConsumerWidget {
  final List<Widget> duties;
  final bool isSelected;
  final bool isActiveMonth;
  final bool horizontalView;

  final DateTime date;

  CalendarCard(
      {required this.duties,
      required this.isSelected,
      required this.isActiveMonth,
      required this.date,
      this.horizontalView = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void expandDuties() {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                height: 100.0,
                width: 100.0,
                child: CalendarCardDialog(duties: this.duties, date: date),
              ),
            );
          });
    }

    Widget _buildContents() {
      if (horizontalView) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                  color: isActiveMonth ? kText : kSecondaryText,
                  fontWeight:
                      isActiveMonth ? FontWeight.bold : FontWeight.normal,
                  fontSize: kCalendarCardPrimaryTextSize),
            ),
            SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxHeight < duties.length * 18.0) {
                  return GestureDetector(
                    onTap: () {
                      expandDuties();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 2.0, top: 2.0),
                      child: Text(
                        '${duties.length} shifts',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: kSecondaryText,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: duties,
                  );
                }
              }),
            )
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                  color: isActiveMonth ? kText : kSecondaryText,
                  fontWeight:
                      isActiveMonth ? FontWeight.bold : FontWeight.normal,
                  fontSize: screenHeight(context) > 700
                      ? kCalendarCardPrimaryTextSize
                      : kCalendarCardMiniPrimaryTextSize),
            ),
            SizedBox(
              height: 2.0,
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxHeight < duties.length * 18.0) {
                  return GestureDetector(
                    onTap: () {
                      expandDuties();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 2.0, top: 2.0),
                      child: Text(
                        '${duties.length} shifts',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: kSecondaryText,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: duties,
                  );
                }
              }),
            )
          ],
        );
      }
    }

    Widget _buildCard() {
      return GestureDetector(
        onTap: () {
          ref.read(dataProvider.notifier).selectDate(date);
        },
        child: Card(
          shape: isSelected
              ? RoundedRectangleBorder(
                  side: BorderSide(color: kPrimary, width: 2.0),
                  borderRadius: BorderRadius.circular(4.0))
              : null,
          elevation: isSelected
              ? kCalendarCardSelectedElevation
              : kCalendarCardElevation,
          child: Padding(
              padding: const EdgeInsets.all(8.0), child: _buildContents()),
        ),
      );
    }

    if (horizontalView) {
      return _buildCard();
    } else {
      return DragTarget<Template>(
        onWillAccept: (data) {
          return true;
        },
        onAccept: (data) {
          List<String> errors = [];
          if (ref.read(dataProvider).selectedDates.isEmpty) {
            errors = ref
                .read(dataProvider.notifier)
                .addTemplateToDraggedDate(data, date);
          } else {
            errors = ref
                .read(dataProvider.notifier)
                .addTemplateToDates(template: data);
          }
          if (errors.isNotEmpty) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(children: [
                      Icon(
                        Icons.error_outline,
                        color: kContrast,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text('There was a problem')
                    ]),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: errors.map((item) => Text(item)).toList(),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          'OK',
                          style: TextStyle(color: kPrimary),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          }
        },
        builder: (context, candidateData, rejectedData) {
          return _buildCard();
        },
      );
    }
  }
}
