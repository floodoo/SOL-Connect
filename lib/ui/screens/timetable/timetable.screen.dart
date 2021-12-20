import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);
  static final routeName = (TimetableScreen).toString();

  @override
  Widget build(BuildContext context) {
    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

    List timetableData = [
      {
        'title': 'Montag',
        'data': [
          {
            'title': '8:00 - 9:00',
            'subject': 'Mathe',
            'teacher': 'Prof. Dr. Hans',
            'room': 'A1',
          },
          {
            'title': '9:00 - 10:00',
            'subject': 'Mathe',
            'teacher': 'Prof. Dr. Hans',
            'room': 'A1',
          },
          {
            'title': '10:00 - 11:00',
            'subject': 'Mathe',
            'teacher': 'Prof. Dr. Hans',
            'room': 'A1',
          },
          {
            'title': '11:00 - 12:00',
            'subject': 'Mathe',
            'teacher': 'Prof. Dr. Hans',
            'room': 'A1',
          },
          {
            'title': '12:00 - 13:00',
            'subject': 'Mathe',
            'teacher': 'Prof. Dr. Hans',
            'room': 'A1',
          },
          {
            'title': '13:00 - 14:00',
            'subject': 'Mathe',
            'teacher': 'Prof. Dr. Hans',
            'room': 'A1',
          },
          {
            'title': '14:00 - 15:00',
            'subject': 'Mathe',
            'teacher': 'Prof. Dr. Hans',
            'room': 'A1',
          },
        ]
      },
    ];

    int hourCounter = 0;
    int subjectCounter = 0;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Timetable"),
        ),
        drawer: const CustomDrawer(),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 54,
                      itemBuilder: (context, index) {
                        if (hourList.contains(index)) {
                          hourCounter++;
                        }

                        if (index != 0 && index >= 5 && hourList.contains(index) != true) {
                          subjectCounter++;
                        }

                        return Container(
                          color: Colors.blue,
                          child: (index == 0)
                              ? const Icon(Icons.calendar_today)
                              : (index <= 5)
                                  ? Text("${timetableData[0]["title"]}")
                                  : (hourList.contains(index))
                                      ? Text("$hourCounter")
                                      : Text("$subjectCounter"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        // body: SingleChildScrollView(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         children: const [
        //           Text("Monday"),
        //           Text("Tuesday"),
        //           Text("Wednesday"),
        //           Text("Thursday"),
        //           Text("Friday"),
        //           Text("Saturday"),
        //         ],
        //       ),
        //       Column(
        //         children: [
        //           Container(
        //             color: Colors.tealAccent,
        //             child: Column(
        //               children: const [
        //                 Padding(
        //                   padding: EdgeInsets.only(right: 20),
        //                   child: Text(
        //                     "8:00",
        //                     style: TextStyle(
        //                       fontSize: 13,
        //                     ),
        //                     textAlign: TextAlign.left,
        //                   ),
        //                 ),
        //                 Text(
        //                   "1.",
        //                   style: TextStyle(
        //                     fontSize: 20,
        //                   ),
        //                   textAlign: TextAlign.center,
        //                 ),
        //                 Padding(
        //                   padding: EdgeInsets.only(left: 20),
        //                   child: Text(
        //                     "8:45",
        //                     style: TextStyle(
        //                       fontSize: 13,
        //                     ),
        //                     textAlign: TextAlign.right,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           Text("2"),
        //           Text("3"),
        //           Text("4"),
        //           Text("5"),
        //           Text("6"),
        //           Text("7"),
        //           Text("8"),
        //           Text("9"),
        //           Text("10"),
        //           Text("11"),
        //           Text("12")
        //         ],
        //       )
        //     ],
        //   ),
        // ),
        );
  }
}
