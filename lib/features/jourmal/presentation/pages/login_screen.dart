import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/animated_logo.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/google_signin_button.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/loading_animated_widget.dart';
import 'package:gratitude_diary/services/notifiers/auth_notifiers.dart';
import 'package:gratitude_diary/services/page_router/router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  showBackupDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Restore previous entries'),
            content: const Text(
                'It seems like you have previous entries backed up in your Google Drive. Would you like to restore your previous entries?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  context.pop();
                  ref.read(authNotifierProvider.notifier).getDataFromDrive();
                },
                child: const Text('Yes'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  context.pop();

                  showCupertinoDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text(
                              'You will lose all your previous entries. Are you sure you want to continue without restoring?'),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () {
                                context.pop();
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  context.go(AppRoutes.home);
                                });
                              },
                              child: const Text('Yes'),
                            ),
                            CupertinoDialogAction(
                              onPressed: () {
                                context.pop();
                                showBackupDialog(context, ref);
                              },
                              child: const Text('No'),
                            ),
                          ],
                        );
                      });
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState == AuthSate.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
    }

    if (authState == AuthSate.midauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBackupDialog(context, ref);
      });
    }

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Gratitude Diary',
                style: AppTheme.theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 30),
              const AnimatedLogo(),
              const SizedBox(height: 30),
              Text(
                ' "Reflect, Record, Rejoice "',
                style: AppTheme.theme.textTheme.bodyMedium!.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Capture your daily moments of gratitude \n  and reflect on them over time !",
                style: AppTheme.theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              authState == AuthSate.loading
                  ? const LoadingAnimatedWidget()
                  : GestureDetector(
                      onTap: () {
                        ref.read(authNotifierProvider.notifier).login();
                      },
                      child: const GoogleSignInButton(),
                    ),
              const SizedBox(height: 150.00),
            ],
          ),
        ),
      ),
    );
  }
}
