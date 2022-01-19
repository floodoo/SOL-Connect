import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/excel/models/phaseelement.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table_detail/time_table_detail.screen.dart';

class CustomPhaseCard extends ConsumerWidget {
  const CustomPhaseCard({required this.phase, Key? key}) : super(key: key);
  final PhaseCodes? phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;
    final blockWeek = ref.watch(timeTableService).weekInBlock;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Card(
        shadowColor: Colors.black87,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Container(
                color: (!blockWeek
                    ? theme.colors.phaseOutOfBlock
                    : phase == null
                        ? theme.colors.phaseUnknown
                        : phase == PhaseCodes.feedback
                            ? theme.colors.phaseFeedback
                            : phase == PhaseCodes.free
                                ? theme.colors.phaseFree
                                : phase == PhaseCodes.orienting
                                    ? theme.colors.phaseOrienting
                                    : phase == PhaseCodes.reflection
                                        ? theme.colors.phaseReflection
                                        : phase == PhaseCodes.structured
                                            ? theme.colors.phaseStructured
                                            : theme.colors.phaseUnknown),
                padding: const EdgeInsets.fromLTRB(25, 5, 0, 5),
                alignment: const Alignment(-1, 0),
                child: Text(
                  !blockWeek
                      ? "Woche außerhab des Blocks"
                      : phase == null
                          ? "Keine Phasierung geladen"
                          : phase!.readableName,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: theme.colors.textInverted, fontSize: 23),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
                child: Text(
                  !blockWeek
                      ? "Diese Woche ist nicht teil des Blocks für den die Phasierung geladen wurde."
                      : phase == null
                          ? "Du kannst die Phasierung für diesen Block unter \"Einstellungen\" > \"Add Phase Plan\" laden"
                          : phase!.description,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: theme.colors.textInverted),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
