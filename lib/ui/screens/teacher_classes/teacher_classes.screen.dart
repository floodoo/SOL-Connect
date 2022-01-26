import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
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
          title: const Text('My Home Page'),
          actions: [searchBar.getSearchAction(context)],
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: const Center(
        child: Text("Teacher Classes Screen"),
      ),
    );
  }
}
