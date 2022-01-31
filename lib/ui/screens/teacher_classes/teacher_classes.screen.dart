import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/schoolclass.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/time_table/time_table.screen.dart';
import 'package:sol_connect/util/logger.util.dart';

// ignore: must_be_immutable
class TeacherClassesScreen extends ConsumerStatefulWidget {
  TeacherClassesScreen({Key? key}) : super(key: key);
  static final routeName = (TeacherClassesScreen).toString();
  String searchString = "";

  @override
  _TeacherClassesScreenState createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends ConsumerState<TeacherClassesScreen> {
  late SearchBar searchBar;
  final Logger log = getLogger();

  @override
  void initState() {
    searchBar = SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: (String value) {
        widget.searchString = value;
        ref.read(teacherService).toggleReloading();
      },
      buildDefaultAppBar: (BuildContext context) {
        return AppBar(
          title: const Text("Ihre Klassen"),
          actions: [searchBar.getSearchAction(context)],
        );
      },
    );
    super.initState();
  }

  Future<List<Widget>> buildAllTeacherClasses(String searchString) async {
    List<Widget> list = [];
    List<SchoolClass> classesAsTeacher = await ref.read(timeTableService).session.getClassesAsTeacher();

    if (searchString != "") {
      classesAsTeacher = classesAsTeacher
          .where((element) =>
              element.name.toLowerCase().replaceAll(" ", "").contains(searchString.toLowerCase().replaceAll(" ", "")))
          .toList();
    }

    if (classesAsTeacher.isEmpty) {
      return list;
    }
    for (var i = 0; i < classesAsTeacher.length; i++) {
      list.add(
        ListTile(
          title: Text(classesAsTeacher[i].name),
          subtitle: Text(classesAsTeacher[i].classTeacherName),
          onTap: () {
            ref.read(timeTableService).session.setTimetableBehavior(classesAsTeacher[i].id, PersonTypes.klasse);
            ref.read(timeTableService).resetTimeTable();
            ref.read(timeTableService).weekCounter = 0;
            ref.read(timeTableService).getTimeTable();
            Navigator.pushNamed(context, TimeTableScreen.routeName);
          },
        ),
      );
      if (i == classesAsTeacher.length) {
        list.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(
              color: ref.watch(themeService).theme.colors.textInverted,
            ),
          ),
        );
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeService).theme;

    return Scaffold(
      appBar: searchBar.build(context),
      body: ref.watch(teacherService).isReloading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colors.progressIndicator,
              ),
            )
          : FutureBuilder(
              future: buildAllTeacherClasses(widget.searchString),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return (snapshot.data.length == 0)
                      ? Center(
                          child: Text(
                            "Keine Klassen gefunden",
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.colors.textInverted,
                            ),
                          ),
                        )
                      : ListView(children: snapshot.data);
                }
              },
            ),
    );
  }
}
