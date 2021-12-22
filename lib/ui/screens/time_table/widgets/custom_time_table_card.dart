import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomTimeTableCard extends StatelessWidget {
  CustomTimeTableCard(
      {Key? key,
      required this.text,
      this.divider = false,
      this.center = false,
      this.colorTop = Colors.grey,
      this.textMaxLines})
      : super(key: key);
  String text;
  bool divider;
  bool center;
  Color colorTop;
  int? textMaxLines;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: (center) ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                color: colorTop,
              ),
              padding: const EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: AutoSizeText(
                text,
                maxLines: textMaxLines,
                overflow: TextOverflow.clip,
                softWrap: true,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          (divider)
              ? const Divider(
                  color: Colors.black,
                  height: 0,
                )
              : Container(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
