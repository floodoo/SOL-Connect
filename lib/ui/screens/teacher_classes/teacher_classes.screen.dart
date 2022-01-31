import 'package:auto_size_text/auto_size_text.dart';
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
      setState: setState,
      onSubmitted: (String value) {
        widget.searchString = value;
        ref.read(teacherService).toggleReloading();
        setState(() {
          widget.searchString = value;
        });
        searchBar.buildDefaultAppBar(context);
      },
      showClearButton: true,
      clearOnSubmit: false,
      buildDefaultAppBar: (BuildContext context) {
        return AppBar(
          title: const Text("Ihre Klassen"),
          actions: [
            widget.searchString == ""
                ? searchBar.getSearchAction(context)
                : IconButton(
                    onPressed: () {
                      searchBar.controller.clear();
                      setState(() {
                        widget.searchString = "";
                      });
                      searchBar.buildDefaultAppBar(context);
                    },
                    icon: const Icon(Icons.clear),
                  )
          ],
        );
      },
    );
    super.initState();
  }

  Future<List<Widget>> buildAllTeacherClasses(String searchString) async {
    List<Widget> list = [];
    List<SchoolClass> allClassesAsTeacher = await ref.read(timeTableService).session.getClassesAsTeacher();
    List<SchoolClass> ownClassesAsTeacher = await ref.read(timeTableService).session.getOwnClassesAsClassteacher();

    if (searchString != "") {
      allClassesAsTeacher = allClassesAsTeacher
          .where((element) =>
              element.name.toLowerCase().replaceAll(" ", "").contains(searchString.toLowerCase().replaceAll(" ", "")))
          .toList();
      ownClassesAsTeacher.clear();
    }

    if (allClassesAsTeacher.isEmpty) {
      return list;
    }

    if (ownClassesAsTeacher.isNotEmpty) {
      list.add(
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: AutoSizeText(
              "Ihre Klassen als Klassenlehrer:in",
              style: TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      for (var i = 0; i < ownClassesAsTeacher.length; i++) {
        list.add(
          ListTile(
            title: Text(ownClassesAsTeacher[i].name),
            subtitle: Text(ownClassesAsTeacher[i].classTeacherName),
            onTap: () {
              ref.read(timeTableService).session.setTimetableBehavior(ownClassesAsTeacher[i].id, PersonTypes.klasse);
              ref.read(timeTableService).resetTimeTable();
              ref.read(timeTableService).weekCounter = 0;
              ref.read(timeTableService).getTimeTable();
              Navigator.pushNamed(context, TimeTableScreen.routeName);
            },
          ),
        );
        if (i != ownClassesAsTeacher.length - 1) {
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
    }

    if (allClassesAsTeacher.isNotEmpty) {
      list.add(
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: AutoSizeText(
              "Alle Klassen, in denen Sie unterrichten",
              style: TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
      for (var i = 0; i < allClassesAsTeacher.length; i++) {
        list.add(
          ListTile(
            title: Text(allClassesAsTeacher[i].name),
            subtitle: Text(allClassesAsTeacher[i].classTeacherName),
            onTap: () {
              ref.read(timeTableService).session.setTimetableBehavior(allClassesAsTeacher[i].id, PersonTypes.klasse);
              ref.read(timeTableService).resetTimeTable();
              ref.read(timeTableService).weekCounter = 0;
              ref.read(timeTableService).getTimeTable();
              Navigator.pushNamed(context, TimeTableScreen.routeName);
            },
          ),
        );
        if (i != allClassesAsTeacher.length - 1) {
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
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colors.progressIndicator,
                    ),
                  );
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
