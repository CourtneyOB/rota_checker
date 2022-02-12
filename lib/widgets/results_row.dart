import 'package:flutter/material.dart';
import 'package:rota_checker/constants.dart';

class ResultsRow extends StatelessWidget {
  ResultsRow(
      {required this.title,
      required this.result,
      required this.explanation,
      required this.about});

  final String title;
  final bool result;
  final String explanation;
  final String about;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        Tooltip(
                          textStyle: TextStyle(fontSize: 12.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: kLightGrey),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          preferBelow: false,
                          message: about,
                          child: Icon(
                            Icons.info_outline,
                            size: 16.0,
                            color: kContrast,
                          ),
                        ),
                      ],
                    ),
                  ),
                  flex: 4,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: Text(
                      result ? 'PASS' : 'FAIL',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: result ? Colors.green : Colors.red),
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: Text(
                      explanation,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  flex: 6,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: kBackground)),
          )
        ],
      ),
    );
  }
}
