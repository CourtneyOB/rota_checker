import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/coffee_button.dart';
import 'package:rota_checker/widgets/text_only_button.dart';
import 'package:rota_checker/widgets/calendar_month_view.dart';
import 'package:rota_checker/widgets/template_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeWebLayout extends ConsumerWidget {
  const HomeWebLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image(
            filterQuality: FilterQuality.medium,
            image: AssetImage(kLogo),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Junior Doctor Rota Checker'),
            SizedBox(
              width: 20.0,
            ),
            TextOnlyButton(
                text: 'About',
                colour: kContrast,
                onPress: () {
                  Navigator.pushNamed(context, '/about');
                },
                isActive: true),
            SizedBox(
              width: 10,
            ),
            CoffeeButton(),
          ],
        ),
      ),
      body: Container(
        color: kBackground,
        child: Column(
          children: [
            Expanded(
              child: CalendarMonthView(
                focusDate: ref.watch(dataProvider).displayDate,
                forwardAction: ref.read(dataProvider.notifier).addMonth,
                backwardAction: ref.read(dataProvider.notifier).subtractMonth,
              ),
            ),
            TemplateBar(),
          ],
        ),
      ),
    );
  }
}
