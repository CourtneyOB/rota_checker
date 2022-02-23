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
      ref.read(dataProvider.notifier).addDefaultTemplate();
      prefs.setString(
          'templates', ref.read(dataProvider.notifier).templatesAsJson());
      prefs.setBool('first_time', false);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Welcome'),
              content: Container(
                width: screenWidth(context) * 0.2,
                child: Text(
                    'Thank you for visiting Junior Doctor Rota Checker v${kVersionNumber.toStringAsFixed(1)}. This tool is designed for use by junior doctors in England in training on the 2016 contract. For help or information about using this tool, click "About".'),
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
    } else {
      //LOAD TEMPLATES
      var templates = prefs.getString('templates');
      if (templates != null) {
        //convert
        ref.read(dataProvider.notifier).loadTemplatesFromString(templates);
      }
      //LOAD DUTIES
      var duties = prefs.getString('duties');
      if (duties != null) {
        //convert
        ref.read(dataProvider.notifier).loadDutiesFromString(duties);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    showDialogIfFirstTime();
    return LayoutController(
      webLayout: HomeWebLayout(),
      mobileLayout: HomeMobileLayout(),
    );
  }
}
