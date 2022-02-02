import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rota_checker/constants.dart';

class TemplateTitle extends StatelessWidget {
  const TemplateTitle({
    Key? key,
    required this.colour,
    required this.name,
    required this.canEdit,
    this.textColour = kText,
    this.maxFontSize = 14.0,
    this.editTemplate = null,
  }) : super(key: key);

  final Color colour;
  final String name;
  final bool canEdit;
  final Color textColour;
  final double maxFontSize;
  final Function()? editTemplate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 12.0,
          width: 8.0,
          decoration: BoxDecoration(
              color: colour,
              borderRadius: BorderRadius.all(Radius.circular(1.0))),
        ),
        SizedBox(
          width: 5.0,
        ),
        Expanded(
          child: AutoSizeText(
            name,
            maxLines: 1,
            maxFontSize: maxFontSize,
            style: TextStyle(
              color: textColour,
            ),
          ),
        ),
        if (canEdit)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: editTemplate,
              child: Icon(
                Icons.edit,
                size: 16.0,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
