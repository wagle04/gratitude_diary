import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';

abstract class CalenderDataState {}

class CalenderDataInitial extends CalenderDataState {}

class CalenderDataLoading extends CalenderDataState {}

class CalenderDataLoaded extends CalenderDataState {
  final Set<String?> datesWithEntries;
  CalenderDataLoaded({required this.datesWithEntries});
}

class CalenderDataError extends CalenderDataState {
  final String message;
  CalenderDataError({required this.message});
}

class CalenderNotifiers extends StateNotifier<CalenderDataState> {
  CalenderNotifiers() : super(CalenderDataInitial()) {
    _isarDbService = GetIt.I.get<IsarDbService>();
    getCalenderData();
  }

  late IsarDbService _isarDbService;

  void getCalenderData() async {
    state = CalenderDataLoading();
    try {
      final datesWithEntries = await _isarDbService.getDatesOfEntries();

      state = CalenderDataLoaded(datesWithEntries: datesWithEntries);
    } catch (e) {
      state = CalenderDataError(message: e.toString());
    }
  }
}

final calenderNotifierProvider =
    StateNotifierProvider<CalenderNotifiers, CalenderDataState>(
        (ref) => CalenderNotifiers());
