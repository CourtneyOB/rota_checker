import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rota_checker/constants.dart';

class TextIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color colour;
  final Function() onPress;
  final bool isActive;
  final bool isWide;

  TextIconButton(
      {required this.text,
      required this.icon,
      required this.colour,
      required this.onPress,
      required this.isActive,
      this.isWide = false});

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0),
                      ),
                      color: isActive ? colour : kLightGrey),
                  height: 24.0,
                  width: isWide ? 110 : 80.0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        text,
                        style: TextStyle(
                            color: isActive ? Colors.white : kSecondaryText),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 24.0,
                  child: Icon(
                    icon,
                    color: isActive ? colour : kLightGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
