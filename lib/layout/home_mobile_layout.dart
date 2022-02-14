import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/template_bar.dart';
import 'package:rota_checker/widgets/calendar_week_view.dart';
import 'package:rota_checker/widgets/text_only_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileHoldingPage extends StatelessWidget {
  const MobileHoldingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            width: 28.0,
            height: 28.0,
            child: Image(
              filterQuality: FilterQuality.medium,
              image: AssetImage(kLogo),
            ),
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
          ],
        ),
      ),
      body: Container(
        color: kBackground,
        child: Center(
          child: Container(
              width: screenWidth(context) * 0.9,
              height: screenHeight(context) * 0.85,
              child: Card(
                elevation: kCalendarCardElevation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 36.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: kContrast,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Flexible(
                            child: Text(
                                'Sorry, Junior Doctor Rota Checker is not yet optimised for small screen sizes (height < 550px). Check back soon or visit using a different device.'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

class HomeMobileLayout extends ConsumerWidget {
  const HomeMobileLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            width: 28.0,
            height: 28.0,
            child: Image(
              filterQuality: FilterQuality.medium,
              image: AssetImage(kLogo),
            ),
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
          ],
        ),
      ),
      body: Container(
        color: kBackground,
        child: Column(
          children: [
            Expanded(
              child: CalendarWeekView(
                focusDate: ref.watch(dataProvider).displayDate,
                forwardAction: ref.read(dataProvider.notifier).addWeek,
                backwardAction: ref.read(dataProvider.notifier).subtractWeek,
              ),
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
