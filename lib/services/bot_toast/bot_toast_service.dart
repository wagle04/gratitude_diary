import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';

enum ToastType { success, error, warning }

void showToast({required String text, int? time, ToastType? type}) {
  Color cardColor = Colors.white;
  Color textColor = AppTheme.secondaryColor;
  String icon = "";

  if (type == ToastType.success) {
    cardColor = Colors.white;
    textColor = AppTheme.secondaryColor;
    icon = " ✅ ";
  }
  if (type == ToastType.error) {
    cardColor = AppTheme.secondaryColor;
    textColor = Colors.white;
    icon = " ✖️ ";
  }
  if (type == ToastType.warning) {
    cardColor = Colors.yellow;
    textColor = Colors.black;
    icon = " ⚠️ ";
  }

  BotToast.showCustomText(
    align: Alignment.bottomCenter,
    clickClose: false,
    ignoreContentClick: true,
    enableKeyboardSafeArea: true,
    duration: Duration(seconds: time ?? 5),
    onlyOne: true,
    toastBuilder: (_) {
      return Container(
        padding: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        child: Card(
          elevation: 5.0,
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              icon + text,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );
    },
  );
}
