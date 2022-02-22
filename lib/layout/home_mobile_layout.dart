import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/template_bar.dart';
import 'package:rota_checker/widgets/calendar_week_view.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:rota_checker/widgets/coffee_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeMobileLayout extends ConsumerWidget {
  const HomeMobileLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Container(
                height: 100.0,
                child: DrawerHeader(
                    child: Row(
                  children: [
                    Image.asset(kLogo),
                    Expanded(
                      child: Text(
                        'Junior Doctor Rota Checker',
                        style: TextStyle(color: kDarkPrimary, fontSize: 22.0),
                      ),
                    ),
                  ],
                ))),
            ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about');
                },
                leading: Icon(Icons.help_outline, color: kContrast),
                title: Text(
                  'About',
                  style: TextStyle(color: kText),
                )),
            ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/results');
                },
                leading: Icon(Icons.arrow_forward, color: kDarkPrimary),
                title: Text(
                  'Get results',
                  style: TextStyle(color: kText),
                )),
            ListTile(
                onTap: ref.watch(dataProvider).duties.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
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
                                                  .read(dataProvider.notifier)
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
                leading: Icon(Icons.clear,
                    color: ref.watch(dataProvider).duties.isEmpty
                        ? kLightGrey
                        : kDarkPrimary),
                title: Text(
                  'Clear calendar',
                  style: TextStyle(
                      color: ref.watch(dataProvider).duties.isEmpty
                          ? kLightGrey
                          : kText),
                )),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: CoffeeButton(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image(
                filterQuality: FilterQuality.medium,
                image: AssetImage(kLogo),
              ),
            ),
            Text('Junior Doctor Rota Checker'),
          ],
        ),
      ),
      body: Container(
        color: kBackground,
        child: Column(
          children: [
            Expanded(
              child: CalendarWeekView(),
            ),
            TemplateBar(
              isMini: true,
            ),
          ],
        ),
      ),
    );
  }
}
