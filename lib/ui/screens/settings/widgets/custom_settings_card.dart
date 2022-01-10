import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomSettingsCard extends ConsumerWidget {
  CustomSettingsCard({Key? key, required this.text, this.leading, this.onTap}) : super(key: key);

  String text;
  Widget? leading;
  void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 0.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: theme.colors.primary,
        child: ListTile(
          title: Text(
            text,
            style: TextStyle(color: theme.colors.text),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          leading: leading,
          onTap: onTap,
        ),
      ),
    );
  }
}
