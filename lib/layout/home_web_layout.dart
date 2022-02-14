import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
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
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Image(
                    filterQuality: FilterQuality.medium,
                    image: AssetImage(kLogo),
                  ),
                ),
              ),
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
            ],
          ),
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
