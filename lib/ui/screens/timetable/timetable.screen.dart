import 'package:flutter/material.dart';
import 'package:untis_phasierung/core/api/timetable.dart';
import 'package:untis_phasierung/ui/screens/timetable/widgets/timeTable.arguments.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';

class TimeTableScreen extends StatefulWidget {
  TimeTableScreen({Key? key}) : super(key: key);
  static final routeName = (TimeTableScreen).toString();
  late TimeTableRange timeTable;
  bool _isLoading = true;

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TimetableArguments;
    // args.userSession.getTimeTableForThisWeek().then((value) => {
    //       print(value.getDays()[0].dayName),
    //       timeTable = value,
    //       // print(value.getDays()[0].hours[0].getTeacher().longName),
    //     });
    if (widget._isLoading) {
      args.userSession.getTimeTableForThisWeek().then((value) {
        // print(value.getDays()[0].dayName);
        widget.timeTable = value;
        setState(() {
          widget._isLoading = false;
        });
      });
    }
    int hourCounter = 0;
    int dayCounter = 0;
    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];
    List dayList = [7, 13, 19, 25, 31, 37, 43, 49];

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
                        if (dayList.contains(index)) {
                          dayCounter++;
                        }
                        return Container(
                          color: Colors.blue,
                          child: (index == 0)
                              ? const Icon(Icons.calendar_today)
                              : (index <= 5)
                                  ? Text(
                                      "${widget.timeTable.getDays()[index - 1].getDayName()} ${widget.timeTable.getDays()[index - 1].getDate()}")
                                  : (hourList.contains(index))
                                      ? Text("$hourCounter")
                                      : (index + 7 > 54)
                                          ? Text("test")
                                          : Text(
                                              "${widget.timeTable.getDays()[0].getHours()[0].getSubject().name} {teacher} {room}"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
