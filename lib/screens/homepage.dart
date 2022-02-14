import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/layout/layout_controller.dart';
import 'package:rota_checker/layout/home_mobile_layout.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/text_icon_button.dart';
import 'package:rota_checker/layout/home_web_layout.dart';
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
              content: Container(
                width: screenWidth(context) * 0.2,
                child: Text(
                    'Welcome to Junior Doctor Rota Checker v${kVersionNumber.toStringAsFixed(1)}. For help or information about using this tool, click "About".'),
              ),
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
    return LayoutController(
      webLayout: HomeWebLayout(),
      mobileLayout: HomeMobileLayout(),
      unableToView: MobileHoldingPage(),
    );
  }
}
