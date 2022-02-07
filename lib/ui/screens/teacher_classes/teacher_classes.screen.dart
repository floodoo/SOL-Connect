import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/schoolclass.dart';
import 'package:sol_connect/core/excel/models/phasestatus.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/teacher_classes/widgets/teacher_class_card.dart';
import 'package:sol_connect/util/logger.util.dart';

class TeacherClassesScreen extends ConsumerStatefulWidget {
  const TeacherClassesScreen({Key? key}) : super(key: key);
  static final routeName = (TeacherClassesScreen).toString();

  @override
  _TeacherClassesScreenState createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends ConsumerState<TeacherClassesScreen> {
  late SearchBar searchBar;
  final Logger log = getLogger();
  String searchString = "";

  @override
  void initState() {
    searchBar = SearchBar(
      setState: setState,
      onSubmitted: (String value) {
        searchString = value;
        ref.read(teacherService).toggleReloading();
        setState(() {
          searchString = value;
        });
        searchBar.buildDefaultAppBar(context);
      },
      showClearButton: true,
      clearOnSubmit: false,
      buildDefaultAppBar: (BuildContext context) {
        return AppBar(
          title: const Text("Ihre Klassen"),
          actions: [
            searchString == ""
                ? searchBar.getSearchAction(context)
                : IconButton(
                    onPressed: () {
                      searchBar.controller.clear();
                      setState(() {
                        searchString = "";
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
    final theme = ref.watch(themeService).theme;
    final _timeTableService = ref.read(timeTableService);

    List<Widget> list = [];
    List<SchoolClass> allClassesAsTeacher = await _timeTableService.session.getClassesAsTeacher(checkRange: 3);
    List<SchoolClass> ownClassesAsTeacher =
        await _timeTableService.session.getOwnClassesAsClassteacher(simulateTeacher: "CAG");

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
        PhaseStatus? status;
        try {
          status = await ref.read(timeTableService).apiManager!.getKlasseInfo(klasseId: allClassesAsTeacher[i].id);
        } catch (e) {
          log.e(e);
        }

        list.add(TeacherClassCard(schoolClass: ownClassesAsTeacher[i], phaseStatus: status));

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
              "Unterrichtete Klassen",
              style: TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      for (var i = 0; i < allClassesAsTeacher.length; i++) {
        PhaseStatus? status;
        try {
          status = await ref.read(timeTableService).apiManager!.getKlasseInfo(klasseId: allClassesAsTeacher[i].id);
        } catch (e) {
          log.e(e);
        }

        list.add(TeacherClassCard(schoolClass: allClassesAsTeacher[i], phaseStatus: status));

        if (i != allClassesAsTeacher.length - 1) {
          list.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                color: theme.colors.textInverted,
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
              future: buildAllTeacherClasses(searchString),
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
