import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({required this.title, required this.icon, required this.child, this.color, super.key});

  final String title;
  final IconData icon;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
