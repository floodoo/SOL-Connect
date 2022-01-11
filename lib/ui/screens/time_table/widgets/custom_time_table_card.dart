import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/services.dart';

class CustomTimeTableCard extends ConsumerWidget {
  const CustomTimeTableCard({Key? key, this.child, required this.color}) : super(key: key);
  final Widget? child;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: color,
      child: Center(
        child: child,
      ),
    );
  }
}
