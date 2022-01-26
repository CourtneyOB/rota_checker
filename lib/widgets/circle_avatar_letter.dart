import 'package:flutter/material.dart';

class CircleAvatarLetter extends StatelessWidget {
  final String text;
  final Color colour;

  CircleAvatarLetter({required this.text, required this.colour});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      maxRadius: 8.0,
      backgroundColor: colour,
      child: CircleAvatar(
        maxRadius: 7.0,
        backgroundColor: Colors.white,
        child: Text(
          text,
          style: TextStyle(fontSize: 10.0, color: colour),
        ),
      ),
    );
  }
}
