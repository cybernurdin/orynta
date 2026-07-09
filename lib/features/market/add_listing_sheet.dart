import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/models/market_listing.dart';
import '../../data/services/app_repository.dart';

/// FR-4.3: farmer produce listing (crop, qty, location, ready-date).
class AddListingSheet extends StatefulWidget {
  const AddListingSheet({super.key});

  @override
  State<AddListingSheet> createState() => _AddListingSheetState();
}

class _AddListingSheetState extends State<AddListingSheet> {
  final _cropController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime _readyDate = DateTime.now().add(const Duration(days: 14));

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
            Text(strings('addListing'), style: Theme.of(context).textTheme.titleLarge),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final crop = _cropController.text.trim();
                  final qty = double.tryParse(_quantityController.text.trim());
                  if (crop.isEmpty || qty == null) return;
                  context.read<AppRepository>().addListing(
                        MarketListing(
                          id: 'listing_${DateTime.now().microsecondsSinceEpoch}',
                          cropName: crop,
                          quantity: qty,
                          unit: 'kg',
                          readyDate: _readyDate,
                          status: ListingStatus.active,
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
