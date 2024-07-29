import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';
import 'package:gratitude_diary/features/jourmal/data/models/auth_data.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/calender_widget.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/gratitude_entry_widget.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/loading_animated_widget.dart';
import 'package:gratitude_diary/services/bot_toast/bot_toast_service.dart';
import 'package:gratitude_diary/services/isar/isar_collections.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';
import 'package:gratitude_diary/services/notifiers/auth_notifiers.dart';
import 'package:gratitude_diary/services/notifiers/calender_notifiers.dart';
import 'package:gratitude_diary/services/notifiers/google_drive_notifiers.dart';
import 'package:gratitude_diary/services/notifiers/gratitude_view_notifiers.dart';
import 'package:gratitude_diary/services/notifiers/home_notifiers.dart';
import 'package:gratitude_diary/services/page_router/router.dart';

// ignore: must_be_immutable
class HomePage extends ConsumerWidget {
  HomePage({super.key});

  static String defaultImage =
      'https://static.vecteezy.com/system/resources/thumbnails/020/765/399/small_2x/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg';

  showConfirmationDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Logout'),
            content: const Text(
                'Are you sure you want to logout? \n Make suer you back up your daily gratitude dairies to Google drive before logging out.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  context.pop();
                  ref.read(authNotifierProvider.notifier).logout();
                },
                child: const Text('Yes'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  context.pop();
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  showProfileModalSheet(
      BuildContext context, WidgetRef ref, GoogleAuthData? user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(user == null ? defaultImage : user.image!),
                ),
                title: Text(user!.name!),
                subtitle: Text(user.email!),
                trailing: IconButton(
                  onPressed: () {
                    context.pop();
                    showConfirmationDialog(context, ref);
                  },
                  icon: const Icon(
                    CupertinoIcons.chevron_right_circle_fill,
                    size: 30.0,
                    color: AppTheme.mainColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final gratitudeTextController = TextEditingController();
  final dbService = GetIt.I.get<IsarDbService>();
  late GoogleAuthData? user;
  late List<GratitudeEntry> gratitudeEntries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState != AuthSate.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.login);
      });
    }
    user = dbService.user;

    final gratitudeBoxProvider = ref.watch(homeGratitudeBoxState);

    final googleDriveProvider = ref.watch(googleDriveNotifierProvider);

    if (googleDriveProvider is GoogleDriveDataUploadSuccess) {
      showToast(
        text: "Data uploaded to Google Drive successfully!",
        time: 4,
        type: ToastType.success,
      );
    } else if (googleDriveProvider is GoogleDriveDataError) {
      showToast(
        text:
            "Error in uploading data to Google Drive: ${googleDriveProvider.message}",
        time: 4,
        type: ToastType.error,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Gratitude Diary'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage:
                  NetworkImage(user == null ? defaultImage : user!.image!),
            ),
            onPressed: () {
              showProfileModalSheet(context, ref, user);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () async {
                final bool hasEnteredToday = await dbService.hasEnteredToday();
                if (hasEnteredToday) {
                  showToast(
                    text:
                        "You have already entered your gratitude for today! Come back tomorrow !!",
                    time: 4,
                    type: ToastType.warning,
                  );
                } else {
                  ref.read(homeGratitudeBoxState.notifier).state =
                      !gratitudeBoxProvider;
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.mainColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.light_mode_rounded,
                          color: Colors.yellow,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          'Today, I am grateful for...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          CupertinoIcons.arrow_down_circle_fill,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    gratitudeBoxProvider
                        ? FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            animate: true,
                            from: 25.0,
                            child: GratitdueEntryWidget(
                              onPressed: () async {
                                await dbService.saveGratitudeEntry(
                                    gratitudeTextController.text);
                                gratitudeTextController.clear();
                                ref.read(homeGratitudeBoxState.notifier).state =
                                    !gratitudeBoxProvider;
                                ref
                                    .read(calenderNotifierProvider.notifier)
                                    .getCalenderData();
                              },
                              textController: gratitudeTextController,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final bool hasMoreThanTenEntries =
                    await dbService.hasMoreThanTenEntries();
                if (!hasMoreThanTenEntries) {
                  showToast(
                    text:
                        "You don't have enough entries to revisit your past gratitude! Come back after you have entered gratitudes for 10 days!!",
                    time: 4,
                    type: ToastType.warning,
                  );
                } else {
                  ref
                      .watch(gratitudeViewNotifierProvider.notifier)
                      .getRandomGratitudeEntry();
                  // ignore: use_build_context_synchronously
                  context.go(AppRoutes.revisit);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.mainColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(10.0),
                child: const Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          CupertinoIcons.bolt_fill,
                          color: Colors.yellow,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          'Revisit your past gratitude ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const CalenderWidget(),
            const SizedBox(height: 20.0),
            googleDriveProvider is GoogleDriveDataLoading
                ? const LoadingAnimatedWidget(color: AppTheme.mainColor)
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      ref
                          .read(googleDriveNotifierProvider.notifier)
                          .uploadDataToGoogleDrive();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.mainColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                CupertinoIcons.cloud_upload_fill,
                                color: Colors.yellow,
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                'Save to Google Drive',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                CupertinoIcons.arrow_up_circle_fill,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
