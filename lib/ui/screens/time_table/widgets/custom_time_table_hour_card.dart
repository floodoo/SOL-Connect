import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomTimeTableHourCard extends StatelessWidget {
  CustomTimeTableHourCard({
    Key? key,
    required this.centerText,
    required this.bottomText,
    required this.topText,
    this.cardColor = Colors.black87,
    this.textColor = Colors.white,
    this.textMaxLines,
  }) : super(key: key);

  String centerText;
  String bottomText;
  String topText;
  Color cardColor;
  Color textColor;
  int? textMaxLines;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: cardColor,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 5),
                    child: AutoSizeText(
                      topText,
                      textAlign: TextAlign.start,
                      maxLines: textMaxLines,
                      overflow: TextOverflow.clip,
                      softWrap: true,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5, left: 5),
                        child: AutoSizeText(
                          bottomText,
                          textAlign: TextAlign.right,
                          maxLines: textMaxLines,
                          overflow: TextOverflow.clip,
                          softWrap: true,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: AutoSizeText(
                centerText,
                maxLines: textMaxLines,
                overflow: TextOverflow.clip,
                softWrap: true,
                style: TextStyle(color: textColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
