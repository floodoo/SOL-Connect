import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomTimeTableCard extends StatelessWidget {
  CustomTimeTableCard(
      {Key? key,
      required this.text,
      this.bottomText,
      this.topColor = Colors.black87,
      this.bottomColor = Colors.black87,
      this.textColor = Colors.white,
      this.iconColor = Colors.white,
      this.divider = false,
      this.center = false,
      this.textMaxLines,
      this.bottomTextMaxLines,
      this.icon})
      : super(key: key);
  String text;
  String? bottomText;
  Color topColor;
  Color bottomColor;
  Color textColor;
  Color iconColor;
  bool divider;
  bool center;
  int? textMaxLines;
  int? bottomTextMaxLines;
  IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    color: topColor,
                  ),
                  padding: const EdgeInsets.fromLTRB(2, 5, 2, 0),
                  child: (center || icon != null)
                      ? Container()
                      : AutoSizeText(
                          text,
                          maxLines: textMaxLines,
                          overflow: TextOverflow.clip,
                          softWrap: true,
                          style: TextStyle(color: textColor),
                        ),
                ),
              ),
              if (divider && center == false)
                const Divider(
                  color: Colors.white,
                  thickness: 0.5,
                  height: 0,
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                    color: bottomColor,
                  ),
                  child: (bottomText == null)
                      ? Container()
                      : AutoSizeText(
                          bottomText!,
                          maxLines: bottomTextMaxLines,
                          overflow: TextOverflow.clip,
                          softWrap: true,
                          style: TextStyle(color: textColor),
                        ),
                ),
              )
            ],
          ),
          if (center)
            Center(
              child: (icon == null)
                  ? AutoSizeText(
                      text,
                      maxLines: textMaxLines,
                      overflow: TextOverflow.clip,
                      softWrap: true,
                      style: TextStyle(color: textColor),
                    )
                  : Icon(
                      icon,
                      color: iconColor,
                    ),
            ),
        ],
      ),
    );
  }
}
