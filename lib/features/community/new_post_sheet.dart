import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/models/farmer_profile.dart';
import '../../data/models/forum_post.dart';
import '../../data/services/app_repository.dart';
import 'forum_screen.dart';

/// AgriForum: ask a question or share an experience with other farmers.
class NewPostSheet extends StatefulWidget {
  const NewPostSheet({super.key});

  @override
  State<NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<NewPostSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  ForumCategory _category = ForumCategory.plantHealth;
  XFile? _photo;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
      if (file != null) setState(() => _photo = file);
    } catch (_) {
      // Photo attachment is optional — silently skip on platforms without a picker.
    }
  }

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
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: strings('postTitle')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ForumCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: strings('category')),
              items: ForumCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(categoryLabel(strings, c))))
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
            const SizedBox(height: 12),
            if (_photo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: kIsWeb ? Image.network(_photo!.path, fit: BoxFit.cover) : Image.file(File(_photo!.path), fit: BoxFit.cover),
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(strings('addPhoto')),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final body = _bodyController.text.trim();
                  if (title.isEmpty || body.isEmpty) return;
                  final repo = context.read<AppRepository>();
                  repo.addForumPost(
                    ForumPost(
                      id: 'forum_${DateTime.now().microsecondsSinceEpoch}',
                      author: repo.profile.name,
                      userId: repo.profile.email,
                      userLevel: repo.profile.farmerType.forumLevel,
                      title: title,
                      category: _category,
                      body: body,
                      postedAt: DateTime.now(),
                      imageUrl: _photo?.path,
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
