import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rota_checker/constants.dart';

class TextOnlyButton extends StatelessWidget {
  final String text;
  final Color colour;
  final Function() onPress;
  final bool isActive;

  TextOnlyButton({
    required this.text,
    required this.colour,
    required this.onPress,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: MouseRegion(
        cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onPress,
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  color: isActive ? colour : kLightGrey),
              height: 24.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    text,
                    style: TextStyle(
                        color: isActive ? Colors.white : kSecondaryText),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
