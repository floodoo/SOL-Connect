import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/service/services.dart';

class InfoDialog extends ConsumerWidget {
  const InfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    return IconButton(
      onPressed: () {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.noHeader,
          animType: AnimType.bottomSlide,
          headerAnimationLoop: false,
          body: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(
                    "Die Phasierung",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                Text(
                  "Die Phasierung ist eine einfache Excel Datei die deinem Stundenplan gleicht und zusätzlich die SOL Phasen des aktuellen Blocks enthält.",
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15, top: 5),
                  child: Text(
                    "Welche Excel Datei?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Text(
                  "Diese wird üblicherweise am anfang deines Schulblocks vorgestellt und von deinem Lehrer zur Verfügung gestellt."
                  "\nDiesen Plan kannst du dann als Excel Datei hier laden und in deinen Stundenplan einfügen.",
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15, top: 5),
                  child: Text(
                    "Ist die immer gültig?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Text(
                  "Wenn du eine Phasierung laden willst, wird sie immer für den nächsten aktuellen Block geladen. "
                  "Der gültigkeits Zeitraum wird auch grün angezeigt."
                  "\nDu wirst benachrichtigt, wenn du noch die Phasierung eines alten Blocks geladen hast.",
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          btnOkOnPress: () {},
        ).show();
      },
      icon: Icon(
        Icons.info_outline,
        color: theme.colors.textInverted,
      ),
      iconSize: 25,
    );
  }
}
