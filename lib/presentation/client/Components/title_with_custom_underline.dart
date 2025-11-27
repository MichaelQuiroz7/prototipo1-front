

import 'package:flutter/material.dart';

class TitleWithCustomUnderline extends StatelessWidget {
  const TitleWithCustomUnderline({
    super.key,
    required this.text
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0 / 4),
            child: Text(
              text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 20.0 / 4),
              height: 7,
              color: Theme.of(
                context,
              ).colorScheme.primary.withAlpha((0.23 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
}
