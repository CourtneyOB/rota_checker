import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';
import 'package:rota_checker/widgets/template_form.dart';

class AddTemplateCard extends StatelessWidget {
  const AddTemplateCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Add template'),
                  content: TemplateForm(),
                );
              });
        },
        child: Card(
          elevation: kCalendarCardElevation,
          color: kBackground,
          child: Container(
            width: kTemplateCardWidth,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.add,
                size: 80.0,
                color: kLightGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
