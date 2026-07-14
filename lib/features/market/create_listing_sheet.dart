import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/models/farmer_profile.dart';
import '../../data/models/marketplace_model.dart';
import '../../data/services/app_repository.dart';

class CreateListingSheet extends StatefulWidget {
  final MarketplaceProduct? existing;
  const CreateListingSheet({super.key, this.existing});

  @override
  State<CreateListingSheet> createState() => _CreateListingSheetState();
}

class _CreateListingSheetState extends State<CreateListingSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locationController;
  late ProductType _type;
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.productName ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _priceController = TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '');
    _quantityController = TextEditingController(text: existing?.quantity.toString() ?? '');
    _unitController = TextEditingController(text: existing?.unit ?? 'kg');
    _categoryController = TextEditingController(text: existing?.category ?? '');
    _locationController = TextEditingController(
      text: existing?.location ?? context.read<AppRepository>().profile.region,
    );
    _type = existing?.productType ?? ProductType.crop;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _typeLabel(dynamic strings, ProductType type) => switch (type) {
        ProductType.crop => strings('typeCrop'),
        ProductType.material => strings('typeMaterial'),
        ProductType.equipment => strings('typeEquipment'),
        ProductType.service => strings('typeService'),
      };

  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
      if (file != null) setState(() => _photo = file);
    } catch (_) {
      // Optional — skip silently on platforms without a picker.
    }
  }

  void _save(BuildContext context) {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (name.isEmpty || price <= 0 || quantity <= 0) return;

    final repo = context.read<AppRepository>();
    final profile = repo.profile;
    final existing = widget.existing;
    final imageUrls = _photo != null ? [_photo!.path] : (existing?.imageUrls ?? const <String>[]);

    final product = MarketplaceProduct(
      productId: existing?.productId ?? 'product_${DateTime.now().microsecondsSinceEpoch}',
      sellerId: existing?.sellerId ?? profile.email,
      sellerName: existing?.sellerName ?? profile.name,
      sellerPhotoUrl: existing?.sellerPhotoUrl ?? (profile.photoPath ?? ''),
      sellerLevel: existing?.sellerLevel ?? profile.farmerType.forumLevel,
      productName: name,
      description: _descriptionController.text.trim(),
      price: price,
      currency: 'XAF',
      productType: _type,
      category: _categoryController.text.trim().isEmpty ? _typeLabel(context.read<LocaleProvider>().strings, _type) : _categoryController.text.trim(),
      quantity: quantity,
      unit: _unitController.text.trim().isEmpty ? 'unit' : _unitController.text.trim(),
      imageUrls: imageUrls,
      listingDate: existing?.listingDate ?? DateTime.now(),
      isActive: true,
      rating: existing?.rating ?? 0,
      reviewsCount: existing?.reviewsCount ?? 0,
      location: _locationController.text.trim(),
    );

    if (_isEditing) {
      repo.updateProduct(product);
    } else {
      repo.addProduct(product);
    }
    Navigator.of(context).pop();
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
            Text(
              _isEditing ? strings('editListing') : strings('createListing'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProductType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: strings('category')),
              items: ProductType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(strings, t))))
                  .toList(),
              onChanged: (t) => setState(() => _type = t ?? _type),
            ),
            const SizedBox(height: 12),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: strings('productName'))),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: strings('description')),
            ),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category label (e.g. Vegetable, Tool)')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '${strings('price')} (XAF)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: strings('quantity')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _unitController, decoration: InputDecoration(labelText: strings('unit')))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _locationController, decoration: InputDecoration(labelText: strings('location')))),
              ],
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
                onPressed: () => _save(context),
                child: Text(strings('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
