import 'package:flutter/material.dart';
import 'package:gratitude_diary/resources/resources.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage(Images.google),
              height: 30,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 50,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
