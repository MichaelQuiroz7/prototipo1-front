
import 'package:flutter/material.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final String body;
  final Color color;
  final Color accent;
  final IconData icon;

  const ExpandableCard({super.key, 
    required this.title,
    required this.body,
    required this.color,
    required this.accent,
    required this.icon,
  });

  @override
  State<ExpandableCard> createState() => ExpandableCardState();
}

class ExpandableCardState extends State<ExpandableCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: widget.accent, width: 4),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(widget.icon, color: widget.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() => expanded = !expanded);
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: Text(
              widget.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            secondChild: SizedBox(
              height: 120,
              child: SingleChildScrollView(
                child: Text(
                  widget.body,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}
