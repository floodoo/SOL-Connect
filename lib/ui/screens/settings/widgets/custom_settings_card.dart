import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomSettingsCard extends ConsumerWidget {
  CustomSettingsCard({Key? key, 
    required this.text, this.leading, this.onTap,
    this.padTop = 19, this.padLeft = 25, this.padRight = 25, this.padBottom = 0}) : super(key: key);

  double padTop, padLeft, padRight, padBottom;
  String text;
  Widget? leading;
  void Function()? onTap;
  bool disabled = false;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    return Padding(
      padding: EdgeInsets.fromLTRB(padLeft, padTop, padRight, padBottom),
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
