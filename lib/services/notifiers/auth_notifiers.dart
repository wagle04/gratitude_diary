import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:gratitude_diary/services/auth/auth_services.dart';
import 'package:gratitude_diary/services/bot_toast/bot_toast_service.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifiers, AuthSate>(
    (ref) => AuthNotifiers(ref.watch(authServiceProvider)));

enum AuthSate {
  initial,
  loading,
  midauthenticated,
  authenticated,
  error,
  failure
}

class AuthNotifiers extends StateNotifier<AuthSate> {
  AuthNotifiers(this._authServices) : super(AuthSate.initial) {
    isarDbService = GetIt.I.get<IsarDbService>();
  }

  final AuthServices _authServices;
  late IsarDbService isarDbService;

  Future<void> login() async {
    state = AuthSate.loading;

    try {
      var authData = await _authServices.login();
      if (authData.success) {
        try {
          await isarDbService.setUserLoggedIn(authData);
          showToast(
            text: "Logged in successfully",
            time: 2,
            type: ToastType.success,
          );

          final hasBackup =
              await _authServices.hasBackupInGoogleDrive(authData.email!);

          if (hasBackup) {
            state = AuthSate.midauthenticated;
          } else {
            state = AuthSate.authenticated;
          }
        } catch (error) {
          throw Exception("Error in DB: $error");
        }
      } else {
        state = AuthSate.error;
        showToast(
          text: "Error- ${authData.error!}",
          time: 4,
          type: ToastType.error,
        );
      }
    } catch (error) {
      showToast(
        text: "Error- $error",
        time: 4,
        type: ToastType.warning,
      );
      state = AuthSate.failure;
    }
  }

  void getDataFromDrive() async {
    try {
      state = AuthSate.loading;
      await _authServices.getDataFromGoogleDrive();
      state = AuthSate.authenticated;
    } catch (e) {
      showToast(
        text: "Error- $e",
        time: 4,
        type: ToastType.warning,
      );
      state = AuthSate.failure;
    }
  }

  void logout() async {
    state = AuthSate.loading;

    try {
      await isarDbService.logout();
      state = AuthSate.initial;
      showToast(
        text: "Logged out",
        time: 2,
        type: ToastType.success,
      );
    } catch (error) {
      showToast(
        text: "Error- $error",
        time: 4,
        type: ToastType.warning,
      );
      state = AuthSate.initial;
    }
  }
}
