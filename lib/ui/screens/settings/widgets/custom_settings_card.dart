import 'package:flutter/material.dart';

class CustomSettingsCard extends StatelessWidget {
  CustomSettingsCard({Key? key, required this.text, this.leading}) : super(key: key);

  String text;
  Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 0.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: Text(
            text,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          leading: leading,
        ),
      ),
    );
  }
}
