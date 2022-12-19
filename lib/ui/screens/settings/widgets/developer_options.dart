import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/service/services.dart';

class DeveloperOptions extends ConsumerWidget {
  const DeveloperOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    final showDeveloperOptions = ref.watch(settingsService).showDeveloperOptions;

    final serverAdressTextController = TextEditingController();
    final textFieldFocus = FocusNode();

    return Padding(
      padding: EdgeInsets.only(left: 25.0, bottom: (showDeveloperOptions) ? 5 : 30, right: 25.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                ref.read(settingsService).toggleDeveloperOptions();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(showDeveloperOptions ? Icons.arrow_drop_down : Icons.arrow_right_rounded,
                      color: theme.colors.textInverted),
                  Text("Entwickleroptionen", style: TextStyle(color: theme.colors.textInverted)),
                ],
              ),
            ),
          ),
          showDeveloperOptions
              ? Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10.0),
                        child: Text(
                          "SOLC-API Server",
                          style: TextStyle(fontSize: 20, color: theme.colors.textInverted),
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: theme.colors.primary,
                      child: ListTile(
                        title: TextField(
                          focusNode: textFieldFocus,
                          controller: serverAdressTextController,
                          autocorrect: false,
                          onEditingComplete: () {
                            if (serverAdressTextController.text != "") {
                              ref.read(settingsService).saveServerAdress(serverAdressTextController.text);
                              ref.read(timeTableService).apiManager!.setBaseURL(serverAdressTextController.text);
                            }
                            serverAdressTextController.clear();
                            FocusManager.instance.primaryFocus?.unfocus();
                            textFieldFocus.unfocus();
                          },
                          style: TextStyle(color: theme.colors.text),
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: theme.colors.text,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: ref.watch(settingsService).serverAddress,
                            hintStyle: TextStyle(color: theme.colors.text),
                            suffixIcon: IconButton(
                              onPressed: () {
                                ref.read(settingsService).saveServerAdress("flo-dev.me");
                                FocusManager.instance.primaryFocus?.unfocus();
                                textFieldFocus.unfocus();
                              },
                              icon: Icon(Icons.settings_backup_restore, color: theme.colors.text),
                              tooltip: "Setzte Server URL zurück",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
