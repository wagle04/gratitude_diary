import 'package:get_it/get_it.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:gratitude_diary/services/google_drive/google_drive_const.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> headers;

  final http.Client _inner = http.Client();

  GoogleHttpClient(this.headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request..headers.addAll(headers));
  }

  @override
  void close() {
    _inner.close();
  }
}

Future<String> getFileName(String userEmail) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/gratitude_data_$userEmail.txt';
}

void setUpDriveApi(String brearerToken) {
  try {
    final client = GoogleHttpClient({'Authorization': brearerToken});
    GetIt.instance.registerSingleton<DriveApi>(DriveApi(client));
  } catch (_) {}
}

Future<File> createNewFolder() async {
  final File folder = File();
  folder.name = GDRIVEFOLDERNAME;
  folder.mimeType = GDRIVEFOLDERMIME;

  final driveApi = GetIt.instance<DriveApi>();
  return await driveApi.files.create(folder);
}

Future<String?> getFolderId() async {
  final driveApi = GetIt.instance<DriveApi>();

  final found = await driveApi.files.list(
    q: "mimeType = '$GDRIVEFOLDERMIME' and name = '$GDRIVEFOLDERNAME'",
    $fields: "files(id, name)",
  );
  final files = found.files;

  if (files == null) {
    return null;
  }
  if (files.isEmpty) {
    final newFolder = await createNewFolder();
    return newFolder.id;
  }

  return files.first.id;
}

Future<File?> isFileExist(String fileName) async {
  final folderId = await getFolderId();
  if (folderId == null) {
    return null;
  }

  final query =
      "name = '$fileName' and '$folderId' in parents and trashed = false";
  final driveApi = GetIt.instance<DriveApi>();

  final driveFileList = await driveApi.files.list(
    q: query,
    spaces: 'drive',
    $fields: 'files(id, name, mimeType, parents)',
  );

  if (driveFileList.files == null || driveFileList.files!.isEmpty) {
    return null;
  }

  return driveFileList.files!.first;
}

Future<void> uploadToGoogleDrive(io.File file) async {
  final File gDriveFile = File();

  gDriveFile.name = basename(file.absolute.path);
  final existingFile = await isFileExist(gDriveFile.name!);

  final driveApi = GetIt.instance<DriveApi>();
  if (existingFile != null) {
    try {
      await driveApi.files.update(gDriveFile, existingFile.id!,
          uploadMedia: Media(file.openRead(), file.lengthSync()));
    } catch (err) {
      rethrow;
    }
    return;
  }

  final folderId = await getFolderId();
  gDriveFile.parents = [folderId!];
  try {
    await driveApi.files.create(
      gDriveFile,
      uploadMedia: Media(file.openRead(), file.lengthSync()),
    );
  } catch (err) {
    rethrow;
  }
}
