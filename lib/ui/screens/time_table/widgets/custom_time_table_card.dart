import 'package:flutter/material.dart';

class CustomTimeTableCard extends StatelessWidget {
  const CustomTimeTableCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.calendar_today_rounded),
          )),
    );
  }
}
