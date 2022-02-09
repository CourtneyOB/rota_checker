import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/calendar.dart';
import 'package:rota_checker/widgets/template_bar.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:rota_checker/widgets/text_only_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('[Icon] Junior Doctor Rota Checker'),
              Row(
                children: [
                  TextOnlyButton(
                      text: 'About',
                      colour: kContrast,
                      onPress: () {
                        Navigator.pushNamed(context, '/about');
                      },
                      isActive: true),
                  SizedBox(
                    width: 20.0,
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
              )
            ],
          ),
        ),
      ),
      body: Container(
        color: kBackground,
        child: Column(
          children: [
            Expanded(
              child: Calendar(
                focusDate: ref.watch(dataProvider).displayMonth,
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
