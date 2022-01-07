import 'package:flutter/material.dart';

class CustomTimeTableDayCard extends StatelessWidget {
  CustomTimeTableDayCard({Key? key, this.child}) : super(key: key);
  Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
          color: Colors.black87,
          child: Center(
            child: child,
          )),
    );
  }
}
