import 'package:flutter/material.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingAnimatedWidget extends StatelessWidget {
  const LoadingAnimatedWidget({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.inkDrop(
      color: color ?? AppTheme.secondaryColor,
      size: 50.0,
    );
  }
}
