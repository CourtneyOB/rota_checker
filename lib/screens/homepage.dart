import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/calendar.dart';
import 'package:rota_checker/widgets/template_bar.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:rota_checker/widgets/text_only_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  showDialogIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isFirstTime = prefs.getBool('first_time');
    if (isFirstTime == null || isFirstTime) {
      prefs.setBool('first_time', false);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Welcome'),
              content: Text(
                  'Welcome to Junior Doctor Rota Checker v${kVersionNumber.toStringAsFixed(1)}. For help or information about using this tool, click "About".'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextIconButton(
                      text: 'Thanks!',
                      icon: Icons.check,
                      colour: kDarkPrimary,
                      onPress: () {
                        Navigator.pop(context);
                      },
                      isActive: true),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    showDialogIfFirstTime();
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                ],
              ),
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
