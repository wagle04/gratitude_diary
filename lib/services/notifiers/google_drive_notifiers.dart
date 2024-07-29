import 'dart:developer';
import 'dart:io' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:gratitude_diary/core/utils/encryption_util.dart';
import 'package:gratitude_diary/services/google_drive/google_drive_service.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';

abstract class GoogleDriveDataState {}

class GoogleDriveDataInitial extends GoogleDriveDataState {}

class GoogleDriveDataLoading extends GoogleDriveDataState {}

class GoogleDriveDataUploadSuccess extends GoogleDriveDataState {}

class GoogleDriveDataError extends GoogleDriveDataState {
  final String message;
  GoogleDriveDataError({required this.message});
}

class GoogleDriveNotifiers extends StateNotifier<GoogleDriveDataState> {
  GoogleDriveNotifiers() : super(GoogleDriveDataInitial()) {
    _isarDbService = GetIt.I.get<IsarDbService>();
  }

  late IsarDbService _isarDbService;

  Future<void> uploadDataToGoogleDrive() async {
    try {
      state = GoogleDriveDataLoading();
      final user = _isarDbService.user;
      final encryptedJson = await getEncryptedData(user);
      final file = await getFile(user!.email!, encryptedJson);

      try {
        setUpDriveApi(user.brearerToken!);
      } catch (_) {}

      await uploadToGoogleDrive(file);

      state = GoogleDriveDataUploadSuccess();
      await Future.delayed(const Duration(seconds: 1));
      state = GoogleDriveDataInitial();
    } catch (e) {
      log(e.toString());
      state = GoogleDriveDataError(message: e.toString());
    }
  }

  Future<io.File> getFile(String email, String encryptedJson) async {
    try {
      final filePath = await getFileName(email);
      final file = io.File(filePath);
      await file.writeAsString(encryptedJson);
      return file;
    } catch (_) {
      rethrow;
    }
  }

  Future<String> getEncryptedData(user) async {
    try {
      final j = await _isarDbService.getAllEntriesString();
      final encryptedJson =
          await EncryptionUtil.encryptJson(j.toString(), user!.email!);
      return encryptedJson!;
    } catch (_) {
      rethrow;
    }
  }

  // String? decryptedData = await decryptJson(encryptedJson, user.email!);

  // log(decryptedData!);

  // if (decryptedData == null) {
  //   throw Exception("Error in decryption");
  // }
}

final googleDriveNotifierProvider =
    StateNotifierProvider<GoogleDriveNotifiers, GoogleDriveDataState>(
        (ref) => GoogleDriveNotifiers());
