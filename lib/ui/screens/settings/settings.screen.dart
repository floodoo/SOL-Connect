import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/ui/screens/settings/widgets/custom_settings_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static final routeName = (SettingsScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.black87,
        ),
        body: Container(
          color: Colors.black87,
          child: ListView(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    "Phase plan",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
              CustomSettingsCard(
                  leading: const Icon(
                    Icons.add,
                    color: Colors.black87,
                  ),
                  text: "Add phase plan"),
              CustomSettingsCard(
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.black87,
                  ),
                  text: "Delete phase plan"),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    "App info",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
              CustomSettingsCard(
                leading: const Icon(
                  FontAwesome.github_circled,
                  color: Colors.black87,
                ),
                text: "Github repo",
                onTap: () async {
                  String _url = "https://github.com/floodoo/untis_phasierung";
                  if (!await launch(_url)) {
                    throw "Could not launch $_url";
                  }
                },
              ),
              CustomSettingsCard(
                  leading: const Icon(
                    Icons.info,
                    color: Colors.black87,
                  ),
                  text: "Build number"),
            ],
          ),
        ));
  }
}
