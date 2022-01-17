import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomSnackBar extends ConsumerWidget {
  const CustomSnackBar({
    Key? key,
    required this.text,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);

  final String text;
  final Color backgroundColor;
  final Duration duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    return SnackBar(
        duration: duration,
        elevation: 20,
        backgroundColor: backgroundColor,
        content: Text(text, style: TextStyle(fontSize: 17, color: theme.colors.text)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ));
  }
}
