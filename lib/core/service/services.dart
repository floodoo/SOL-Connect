import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/service/time_table.service.dart';

final timeTableService = ChangeNotifierProvider<TimeTableService>((ref) => TimeTableService());
