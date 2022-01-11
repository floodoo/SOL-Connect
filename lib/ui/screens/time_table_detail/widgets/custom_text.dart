import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomText extends ConsumerWidget {
  const CustomText({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          style: TextStyle(color: theme.colors.textBackground, fontSize: 16),
        ),
      ),
    );
  }
}
