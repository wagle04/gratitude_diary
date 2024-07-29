import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';
import 'package:gratitude_diary/services/isar/isar_collections.dart';
import 'package:gratitude_diary/services/notifiers/gratitude_view_notifiers.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class GratitudeLoadedWidget extends ConsumerWidget {
  const GratitudeLoadedWidget({
    super.key,
    required this.entry,
    this.emoji,
    required this.screenshotController,
  });

  final GratitudeEntry entry;
  final String? emoji;
  final ScreenshotController screenshotController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oldDate = entry.date;
    String newDateFormatted = "";

    try {
      newDateFormatted =
          DateFormat('MMM dd, yyyy').format(DateTime.parse((oldDate!)));
    } catch (_) {}

    return ListView(
      key: key,
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(height: 40.0),
        Center(
          child: Text(
            'On $newDateFormatted',
            style: AppTheme.theme.textTheme.displayLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            "You wrote",
            style: AppTheme.theme.textTheme.displayMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.center,
          height: 40,
          child: Builder(builder: (context) {
            if (emoji == null) {
              return LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 30.0,
              );
            }
            return Center(
              child: Text(
                emoji ?? '😊',
                style: AppTheme.theme.textTheme.displayMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Today I am grateful for',
            style: AppTheme.theme.textTheme.displayMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            entry.text!,
            style: AppTheme.theme.textTheme.displaySmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 25.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await screenshotController
                      .captureFromWidget(
                          ScreenShotGratitudeWidget(
                            entry: entry,
                            emoji: emoji,
                            height: MediaQuery.of(context).size.height * 0.60,
                          ),
                          delay: const Duration(milliseconds: 10))
                      .then((Uint8List? image) async {
                    if (image != null) {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final imagePath = await File(
                              '${directory.path}/gratitude-${DateTime.now().microsecondsSinceEpoch}.png')
                          .create();
                      await imagePath.writeAsBytes(image);

                      await Share.shareXFiles([XFile(imagePath.path)]);
                    }
                  });
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .watch(gratitudeViewNotifierProvider.notifier)
                      .getRandomGratitudeEntry();
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                icon: const Icon(Icons.navigate_next),
                label: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ScreenShotGratitudeWidget extends StatelessWidget {
  const ScreenShotGratitudeWidget({
    super.key,
    required this.entry,
    required this.emoji,
    required this.height,
  });

  final GratitudeEntry entry;
  final String? emoji;
  final double height;

  @override
  Widget build(BuildContext context) {
    final oldDate = entry.date;
    String newDateFormatted = "";

    try {
      newDateFormatted =
          DateFormat('MMM dd, yyyy').format(DateTime.parse((oldDate!)));
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 40.0),
          Text(
            'On $newDateFormatted',
            style: AppTheme.theme.textTheme.displayLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "I wrote",
            style: AppTheme.theme.textTheme.displayMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            height: 40,
            child: Builder(builder: (context) {
              if (emoji == null) {
                return LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 30.0,
                );
              }
              return Text(
                emoji ?? '😊',
                style: AppTheme.theme.textTheme.displayMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            'Today I am grateful for',
            style: AppTheme.theme.textTheme.displayMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            entry.text!,
            style: AppTheme.theme.textTheme.displaySmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}
