import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/models/market_listing.dart';
import '../../data/services/app_repository.dart';

/// FR-4.3: farmer produce listing (crop, qty, location, ready-date).
/// Pass [existing] to edit and update a listing in place instead of
/// creating a new one.
class AddListingSheet extends StatefulWidget {
  final MarketListing? existing;

  const AddListingSheet({super.key, this.existing});

  @override
  State<AddListingSheet> createState() => _AddListingSheetState();
}

class _AddListingSheetState extends State<AddListingSheet> {
  late final _cropController = TextEditingController(text: widget.existing?.cropName);
  late final _quantityController = TextEditingController(
    text: widget.existing?.quantity.toStringAsFixed(0),
  );
  late DateTime _readyDate = widget.existing?.readyDate ?? DateTime.now().add(const Duration(days: 14));
  late ListingStatus _status = widget.existing?.status ?? ListingStatus.active;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _cropController.dispose();
    _quantityController.dispose();
    super.dispose();
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
              strings(_isEditing ? 'editListing' : 'addListing'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cropController,
              decoration: InputDecoration(labelText: strings('crop')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: '${strings('quantity')} (kg)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings('readyDate')),
              subtitle: Text('${_readyDate.year}-${_readyDate.month.toString().padLeft(2, '0')}-${_readyDate.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _readyDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _readyDate = picked);
              },
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              Text(strings('status'), style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<ListingStatus>(
                segments: [
                  ButtonSegment(value: ListingStatus.active, label: Text(strings('statusActive'))),
                  ButtonSegment(value: ListingStatus.pending, label: Text(strings('statusPending'))),
                  ButtonSegment(value: ListingStatus.sold, label: Text(strings('statusSold'))),
                ],
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final crop = _cropController.text.trim();
                  final qty = double.tryParse(_quantityController.text.trim());
                  if (crop.isEmpty || qty == null) return;
                  final repo = context.read<AppRepository>();
                  if (_isEditing) {
                    repo.updateListing(
                      MarketListing(
                        id: widget.existing!.id,
                        cropName: crop,
                        quantity: qty,
                        unit: widget.existing!.unit,
                        readyDate: _readyDate,
                        status: _status,
                        priceExpectation: widget.existing!.priceExpectation,
                      ),
                    );
                  } else {
                    repo.addListing(
                      MarketListing(
                        id: 'listing_${DateTime.now().microsecondsSinceEpoch}',
                        cropName: crop,
                        quantity: qty,
                        unit: 'kg',
                        readyDate: _readyDate,
                        status: ListingStatus.active,
                      ),
                    );
                  }
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
