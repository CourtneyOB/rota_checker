import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/main.dart';
import 'package:rota_checker/widgets/calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDarkPrimary,
      ),
      body: Container(
        color: kBackground,
        child: Calendar(
          selectedDate: ref.watch(dataProvider).displayMonth,
          forwardAction: ref.read(dataProvider.notifier).addMonth,
          backwardAction: ref.read(dataProvider.notifier).subtractMonth,
        ),
      ),
    );
  }
}
