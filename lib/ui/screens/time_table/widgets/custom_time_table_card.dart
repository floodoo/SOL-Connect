import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomTimeTableCard extends ConsumerWidget {
  const CustomTimeTableCard({required this.color, this.child, Key? key}) : super(key: key);

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: color,
      child: Center(child: child),
    );
  }
}
