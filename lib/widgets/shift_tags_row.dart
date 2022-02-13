import 'package:flutter/material.dart';
import 'package:rota_checker/widgets/circle_avatar_letter.dart';

class ShiftTagsRow extends StatelessWidget {
  const ShiftTagsRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(width: 14.0),
          CircleAvatarLetter(
            text: 'N',
            colour: Colors.red,
          ),
          SizedBox(
            width: 4.0,
          ),
          Text('Night shift'),
          SizedBox(
            width: 10.0,
          ),
          CircleAvatarLetter(
            text: 'L',
            colour: Colors.green,
          ),
          SizedBox(
            width: 4.0,
          ),
          Text('Long shift (> 10 hours)'),
          SizedBox(
            width: 10.0,
          ),
          CircleAvatarLetter(
            text: 'E',
            colour: Colors.blue,
          ),
          SizedBox(
            width: 4.0,
          ),
          Text('Evening finish (finish between 23:00 - 02:00)'),
        ],
      ),
    );
  }
}
