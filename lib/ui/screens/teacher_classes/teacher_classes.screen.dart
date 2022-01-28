import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sol_connect/core/service/services.dart';
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

  @override
  void initState() {
    searchBar = SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: (String value) {
        log.d(value);
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

  Future<List<Widget>> buildAllTeacherClasses() async {
    List<Widget> list = [];
    final classesAsTeacher = await ref.read(timeTableService).session.getClassesAsTeacher();

    for (var i = 0; i < classesAsTeacher.length; i++) {
      list.add(
        ListTile(
          title: Text(classesAsTeacher[i].name),
          subtitle: Text(classesAsTeacher[i].classTeacherName),
          onTap: () {},
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
    return Scaffold(
      appBar: searchBar.build(context),
      body: FutureBuilder(
        future: buildAllTeacherClasses(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView(children: snapshot.data);
          }
        },
      ),
    );
  }
}
