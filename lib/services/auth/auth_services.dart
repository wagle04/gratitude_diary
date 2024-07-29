import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:gratitude_diary/core/utils/encryption_util.dart';
import 'package:gratitude_diary/features/jourmal/data/models/auth_data.dart';
import 'package:gratitude_diary/services/google_drive/google_drive_service.dart';
import 'package:gratitude_diary/services/isar/isar_collections.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';
import 'dart:convert';

final authServiceProvider = Provider<AuthServices>((ref) => AuthServices());

class AuthServices {
  bool isLoggedIn = false;
  Future<GoogleAuthData> login() async {
    final googleLoginData = await googleLogin();
    return GoogleAuthData.fromJson(googleLoginData);
  }

  Future<Map<String, dynamic>> googleLogin() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/drive',
        ],
      );
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final x = await googleSignInAccount!.authentication;
      final y = googleSignIn.currentUser;

      final authHeaders = await googleSignInAccount.authHeaders;
      final bearerToken = authHeaders["Authorization"];

      setUpDriveApi(bearerToken!);

      if (y == null) {
        return {"success": false, "error": "User Not Found"};
      }

      return {
        "success": true,
        "token": x.accessToken,
        "id": y.id,
        "name": y.displayName,
        "email": y.email,
        "image": y.photoUrl,
        "brearerToken": bearerToken,
      };
    } catch (e) {
      return {"success": false, "error": "Login Failed"};
    }
  }

  Future<void> getDataFromGoogleDrive() async {
    try {
      final dbservice = GetIt.I.get<IsarDbService>();
      final String email = dbservice.user!.email!;
      final fullFileName = await getFileName(email);
      final fileName = fullFileName.split('/').last;

      try {
        setUpDriveApi(dbservice.user!.brearerToken!);
      } catch (_) {}

      final driveApi = GetIt.I.get<DriveApi>();

      final existingFile = await isFileExist(fileName);

      if (existingFile == null) {
        throw Exception("Error getting file from Google Drive");
      }

      Media? downloadedFile;

      downloadedFile = await driveApi.files.get(existingFile.id!,
          downloadOptions: DownloadOptions.fullMedia) as Media;

      final gratidtudeEntries = await decryptFile(downloadedFile, email);

      await addEntriesToDatabase(gratidtudeEntries);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> addEntriesToDatabase(List<GratitudeEntry> entries) async {
    final isarDbService = GetIt.I.get<IsarDbService>();
    await isarDbService.saveAllGratitudeEntries(entries);
  }

  Future<List<GratitudeEntry>> decryptFile(
    Media mediaFile,
    String email,
  ) async {
    final StringBuffer stringBuffer = StringBuffer();
    await for (var chunk in mediaFile.stream) {
      stringBuffer.write(utf8.decode(chunk));
    }
    String fileContent = stringBuffer.toString();

    final decryptedContent =
        await EncryptionUtil.decryptJson(fileContent, email);

    if (decryptedContent == null) {
      throw Exception("Error in decryption");
    }

    final jsonList =
        jsonDecode(EncryptionUtil.validJsonString(decryptedContent));

    final List<GratitudeEntry> gratitudeEntries = [];

    for (var e in jsonList["entries"]) {
      gratitudeEntries.add(GratitudeEntry().fromJson(e));
    }

    return gratitudeEntries;
  }

  Future<bool> hasBackupInGoogleDrive(String email) async {
    try {
      final fullFileName = await getFileName(email);
      final fileName = fullFileName.split('/').last;
      final existingFile = await isFileExist(fileName);

      if (existingFile == null) {
        return false;
      }

      return true;
    } catch (_) {
      rethrow;
    }
  }
}
