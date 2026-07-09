import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/models/forum_post.dart';
import '../../data/services/app_repository.dart';

/// AgriForum: ask a question or share an experience with other farmers.
class NewPostSheet extends StatefulWidget {
  const NewPostSheet({super.key});

  @override
  State<NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<NewPostSheet> {
  final _bodyController = TextEditingController();
  ForumCategory _category = ForumCategory.general;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  String _categoryLabel(dynamic strings, ForumCategory category) => switch (category) {
        ForumCategory.pestControl => strings('categoryPestControl'),
        ForumCategory.soilHealth => strings('categorySoilHealth'),
        ForumCategory.weather => strings('categoryWeather'),
        ForumCategory.market => strings('categoryMarket'),
        ForumCategory.general => strings('categoryGeneral'),
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings('askQuestion'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<ForumCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: strings('category')),
              items: ForumCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(_categoryLabel(strings, c))))
                  .toList(),
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: strings('shareYourThoughts'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final body = _bodyController.text.trim();
                  if (body.isEmpty) return;
                  final repo = context.read<AppRepository>();
                  repo.addForumPost(
                    ForumPost(
                      id: 'forum_${DateTime.now().microsecondsSinceEpoch}',
                      author: repo.profile.name,
                      category: _category,
                      body: body,
                      postedAt: DateTime.now(),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(strings('post')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
