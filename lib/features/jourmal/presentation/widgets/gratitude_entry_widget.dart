import 'package:flutter/material.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';

class GratitdueEntryWidget extends StatelessWidget {
  const GratitdueEntryWidget({
    super.key,
    required this.onPressed,
    required this.textController,
  });
  final Function onPressed;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20.0),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextFormField(
            decoration: const InputDecoration(
              hintText: 'Today, I am grateful for...',
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.multiline,
            cursorColor: Colors.black,
            maxLines: 5,
            style: AppTheme.theme.textTheme.bodyMedium,
            controller: textController,
          ),
        ),
        const SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: () async {
            await onPressed();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
