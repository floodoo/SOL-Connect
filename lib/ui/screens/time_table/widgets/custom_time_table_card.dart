import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomTimeTableCard extends ConsumerWidget {
  const CustomTimeTableCard({required this.color, this.child, Key? key}) : super(key: key);

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: child != null ? 5 : 0,
      shadowColor: child != null ? Colors.black : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      color: color,
      margin: const EdgeInsets.all(2),
      child: Center(child: child),
    );
  }
}
