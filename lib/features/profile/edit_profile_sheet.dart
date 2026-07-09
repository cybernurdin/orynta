import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/models/farmer_profile.dart';
import '../../data/services/app_repository.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _regionController;
  late final TextEditingController _cropController;
  late FarmerType _farmerType;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppRepository>().profile;
    _nameController = TextEditingController(text: profile.name);
    _regionController = TextEditingController(text: profile.region);
    _cropController = TextEditingController(text: profile.cropFocus);
    _farmerType = profile.farmerType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  String _typeLabel(dynamic strings, FarmerType type) => switch (type) {
        FarmerType.beginner => strings('farmerTypeBeginner'),
        FarmerType.advanced => strings('farmerTypeAdvanced'),
        FarmerType.commercial => strings('farmerTypeCommercial'),
        FarmerType.subsistence => strings('farmerTypeSubsistence'),
        FarmerType.organic => strings('farmerTypeOrganic'),
        FarmerType.agronomist => strings('farmerTypeAgronomist'),
        FarmerType.officer => strings('farmerTypeOfficer'),
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
            Text(strings('editProfile'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: strings('name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _regionController,
              decoration: InputDecoration(labelText: strings('region')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cropController,
              decoration: InputDecoration(labelText: strings('cropFocus')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FarmerType>(
              initialValue: _farmerType,
              decoration: InputDecoration(labelText: strings('farmerType')),
              items: FarmerType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(strings, t))))
                  .toList(),
              onChanged: (t) => setState(() => _farmerType = t ?? _farmerType),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final region = _regionController.text.trim();
                  final crop = _cropController.text.trim();
                  if (name.isEmpty || region.isEmpty || crop.isEmpty) return;
                  final repo = context.read<AppRepository>();
                  repo.updateProfile(
                    repo.profile.copyWith(
                      name: name,
                      region: region,
                      cropFocus: crop,
                      farmerType: _farmerType,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(strings('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
