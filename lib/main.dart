import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/screens/homepage.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
          textSelectionTheme:
              TextSelectionThemeData(cursorColor: kDarkPrimary)),
    );
  }
}
