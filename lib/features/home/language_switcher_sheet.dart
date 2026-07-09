import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';

class LanguageSwitcherSheet extends StatelessWidget {
  const LanguageSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final strings = locale.strings;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings('chooseLanguage'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _LanguageTile(
              label: strings('english'),
              selected: locale.languageCode == 'en',
              onTap: () {
                locale.setLanguage('en');
                Navigator.of(context).pop();
              },
            ),
            _LanguageTile(
              label: strings('french'),
              selected: locale.languageCode == 'fr',
              onTap: () {
                locale.setLanguage('fr');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.forest) : null,
    );
  }
}
