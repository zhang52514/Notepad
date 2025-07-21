import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const SettingsTile({
    required this.icon,
    required this.label,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.titleSmall;

    return  ListTile(
      leading: HugeIcon(icon: icon, size: 24),
      title: Text(label, style: body),
      trailing: child,
    );
  }
}
