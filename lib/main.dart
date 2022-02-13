import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/screens/homepage.dart';
import 'package:rota_checker/screens/resultspage.dart';
import 'package:rota_checker/screens/about_page.dart';
import 'package:rota_checker/provider/data_provider.dart';
import 'package:rota_checker/model/rota.dart';

double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

final dataProvider =
    StateNotifierProvider<DataProvider, Rota>((ref) => DataProvider(Rota()));

void main() {
  runApp(
    ProviderScope(child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomePage(),
        '/results': (context) => ResultsPage(),
        '/about': (context) => AboutPage(),
      },
      initialRoute: '/',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
            elevation: 1,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: kDarkPrimary),
            titleTextStyle: TextStyle(color: kDarkPrimary, fontSize: 18.0),
          ),
          textSelectionTheme: TextSelectionThemeData(cursorColor: kDarkPrimary),
          inputDecorationTheme: InputDecorationTheme(
            errorStyle: TextStyle(color: Colors.red[700], fontSize: 12.0),
          ),
          colorScheme: ThemeData.light().colorScheme.copyWith(
                primary: kDarkPrimary,
                secondary: kPrimary,
              )),
    );
  }
}
