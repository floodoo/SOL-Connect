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
  // ignore: library_private_types_in_public_api
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
        final theme = ref.watch(themeService).theme;

        return AppBar(
          title: const Text("Meine Klassen"),
          backgroundColor: theme.colors.primary,
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
    final timeTableServiceInstance = ref.read(timeTableService);
    final theme = ref.watch(themeService).theme;

    List<Widget> list = [];
    //_timeTableService.session.setTimetableBehaviour(308, PersonTypes.teacher);
    List<SchoolClass> allClassesAsTeacher = await timeTableServiceInstance.session.getClassesAsTeacher(checkRange: 2);
    List<SchoolClass> ownClassesAsTeacher = await timeTableServiceInstance.session.getOwnClassesAsClassteacher();

    //Remove duplicates
    outer:
    for (SchoolClass own in ownClassesAsTeacher) {
      for (SchoolClass teaching in allClassesAsTeacher) {
        if (teaching.id == own.id) {
          allClassesAsTeacher.remove(teaching);
          continue outer;
        }
      }
    }

    if (searchString != "") {
      allClassesAsTeacher = allClassesAsTeacher
          .where((element) =>
              element.name.toLowerCase().replaceAll(" ", "").contains(searchString.toLowerCase().replaceAll(" ", "")))
          .toList();
      ownClassesAsTeacher.clear();
    }

    if (ownClassesAsTeacher.isNotEmpty) {
      list.add(
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20.0, 5),
          child: Center(
            child: AutoSizeText(
              "Ihre Klassen als Klassenleitung",
              style: TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            color: ref.watch(themeService).theme.colors.textInverted,
          ),
        ),
      );

      for (var i = 0; i < ownClassesAsTeacher.length; i++) {
        PhaseStatus? status;
        try {
          status =
              await ref.read(timeTableService).apiManager!.getSchoolClassInfo(schoolClassId: ownClassesAsTeacher[i].id);
        } catch (e) {
          log.e(e);
        }

        list.add(TeacherClassCard(schoolClass: ownClassesAsTeacher[i], phaseStatus: status));
      }
    }

    if (allClassesAsTeacher.isNotEmpty) {
      list.add(
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20.0, 5),
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
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            color: theme.colors.textInverted,
          ),
        ),
      );

      for (var i = 0; i < allClassesAsTeacher.length; i++) {
        PhaseStatus? status;
        try {
          status =
              await ref.read(timeTableService).apiManager!.getSchoolClassInfo(schoolClassId: allClassesAsTeacher[i].id);
        } catch (e) {
          log.e(e);
        }

        list.add(TeacherClassCard(schoolClass: allClassesAsTeacher[i], phaseStatus: status));
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
