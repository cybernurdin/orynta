import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/confidence_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/leaf_diagnosis.dart';
import '../../data/models/supplier.dart';
import '../../data/services/market_service.dart';
import '../shell/app_shell.dart';

/// FR-2.1–2.3: diagnosis + confidence + treatment guidance, with an
/// escalation notice whenever confidence falls under threshold.
class LeafResultScreen extends StatefulWidget {
  final LeafDiagnosis diagnosis;
  const LeafResultScreen({super.key, required this.diagnosis});

  @override
  State<LeafResultScreen> createState() => _LeafResultScreenState();
}

class _LeafResultScreenState extends State<LeafResultScreen> {
  final MarketService _marketService = MarketService();
  List<Supplier>? _suppliers;

  @override
  void initState() {
    super.initState();
    _marketService.getNearbySuppliers().then((s) {
      if (mounted) setState(() => _suppliers = s.take(2).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final diagnosis = widget.diagnosis;
    final isEscalated = diagnosis.escalationStatus == EscalationStatus.pending;

    return Scaffold(
      appBar: AppBar(title: Text(strings('scanLeafTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConfidenceBadge(confidence: diagnosis.confidence, strings: strings),
                  const SizedBox(height: 16),
                  Text(strings('diagnosis'), style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    diagnosis.predictedClass,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          if (isEscalated) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.confidenceLow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, color: AppColors.confidenceLow, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(strings('escalationNotice'), style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SectionHeader(title: strings('treatment')),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(diagnosis.treatment, style: const TextStyle(fontSize: 14, height: 1.4)),
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 18, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diagnosis.safetyNotes,
                          style: const TextStyle(fontSize: 13, color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_suppliers != null && _suppliers!.isNotEmpty) ...[
            const SizedBox(height: 20),
            SectionHeader(title: strings('nearestSuppliers')),
            const SizedBox(height: 10),
            ..._suppliers!.map(
              (s) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.storefront_rounded, color: AppColors.forest),
                  title: Text(s.name),
                  subtitle: Text('${s.productCategories.join(", ")} · ${s.distanceKm.toStringAsFixed(1)} km'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(strings('scanAnother')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppShell()),
                    (route) => false,
                  ),
                  child: Text(strings('backToHome')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
