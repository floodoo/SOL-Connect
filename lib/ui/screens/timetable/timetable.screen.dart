import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/shared/custom_drawer.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);
  static final routeName = (TimetableScreen).toString();

  @override
  Widget build(BuildContext context) {
    int hourCounter = 0;

    List hourList = [6, 12, 18, 24, 30, 36, 42, 48];

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

                        return Container(
                          color: Colors.blue,
                          child: (index == 0)
                              ? const Icon(Icons.calendar_today)
                              : (index <= 5)
                                  ? const Text("{days} {date}")
                                  : (hourList.contains(index))
                                      ? Text("$hourCounter")
                                      : const Text("{lesson} {teacher} {room}"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        );
  }
}
