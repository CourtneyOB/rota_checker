import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/text_only_button.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: Container(
              width: screenWidth(context) * 0.85,
              height: screenHeight(context) * 0.9,
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
                                'Sorry, Junior Doctor Rota Checker is not yet optimised for mobile or tablet screen sizes. Check back soon or visit on the web.'),
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
