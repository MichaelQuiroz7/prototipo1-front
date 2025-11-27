

import 'package:flutter/material.dart';
import 'package:prototipo1_app/presentation/client/Components/title_with_custom_underline.dart';

class TitleWithMoreBtn extends StatelessWidget {
  const TitleWithMoreBtn({
    super.key,
    required this.text,
    required this.press,
  });

  final String text;
  //final Function press;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: <Widget>[
          TitleWithCustomUnderline(text: text),
          const Spacer(),
          TextButton(
            onPressed: press,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Ver todo'),
          ),
        ],
      ),
    );
  }
}