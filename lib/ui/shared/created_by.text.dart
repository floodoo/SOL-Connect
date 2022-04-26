import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CreatedByText extends ConsumerWidget {
  const CreatedByText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Created with 🔥 by ",
            style: TextStyle(color: theme.colors.textInverted, fontStyle: FontStyle.italic),
          ),
          TextSpan(
            text: "floodoo",
            style: const TextStyle(
              color: Colors.blue,
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrlString("https://github.com/floodoo");
              },
          ),
          TextSpan(
            text: " & ",
            style: TextStyle(color: theme.colors.textInverted, fontStyle: FontStyle.italic),
          ),
          TextSpan(
            text: "DevKevYT",
            style: const TextStyle(
              color: Colors.blue,
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrlString("https://github.com/DevKevYT");
              },
          ),
        ],
      ),
    );
  }
}
