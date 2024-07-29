import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/gratitude_loaded_widget.dart';
import 'package:gratitude_diary/features/jourmal/presentation/widgets/loading_animated_widget.dart';
import 'package:gratitude_diary/services/notifiers/gratitude_view_notifiers.dart';
import 'package:gratitude_diary/services/page_router/router.dart';
import 'package:screenshot/screenshot.dart';

// ignore: must_be_immutable
class RevisitGratitudePage extends ConsumerWidget {
  RevisitGratitudePage({super.key}) {
    screenshotController = ScreenshotController();
  }

  //Create an instance of ScreenshotController
  late ScreenshotController screenshotController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gratitudeViewNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('Gratitude Diary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.home);
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state is GratitudeViewInitial) {
            return const Center(
              child: LoadingAnimatedWidget(color: AppTheme.mainColor),
            );
          } else if (state is GratitudeViewLoading) {
            return const Center(
              child: LoadingAnimatedWidget(color: AppTheme.mainColor),
            );
          } else if (state is GratitudeViewLoaded) {
            return Screenshot(
              controller: screenshotController,
              child: GratitudeLoadedWidget(
                entry: state.entry,
                emoji: state.emoji,
                screenshotController: screenshotController,
              ),
            );
          } else if (state is GratitudeViewError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
