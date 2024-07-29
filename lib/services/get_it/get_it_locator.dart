import 'package:get_it/get_it.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';

void setupGetItLocator() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<IsarDbService>(IsarDbService());
}
