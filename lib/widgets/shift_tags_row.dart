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
      child: Wrap(
        runSpacing: 5.0,
        spacing: 10.0,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatarLetter(
                text: 'N',
                colour: Colors.red,
              ),
              SizedBox(
                width: 4.0,
              ),
              Text('Night shift'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatarLetter(
                text: 'L',
                colour: Colors.green,
              ),
              SizedBox(
                width: 4.0,
              ),
              Text('Long shift (> 10 hours)'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        ],
      ),
    );
  }
}
