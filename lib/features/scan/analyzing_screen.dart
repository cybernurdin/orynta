import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/app_repository.dart';
import '../../data/services/inference_service.dart';
import '../../data/services/location_service.dart';
import 'leaf_result_screen.dart';
import 'scan_type.dart';
import 'soil_result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final ScanType type;
  final String? imagePath;

  const AnalyzingScreen({super.key, required this.type, this.imagePath});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  final InferenceService _inference = InferenceService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final repo = context.read<AppRepository>();

    if (widget.type == ScanType.soil) {
      final region = await _currentLocationLabel();
      final result = await _inference.analyzeSoil(
        imagePath: widget.imagePath,
        region: region,
      );
      await repo.addSoilScan(result);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SoilResultScreen(scan: result)),
      );
    } else {
      final result = await _inference.analyzeLeaf(imagePath: widget.imagePath);
      await repo.addLeafDiagnosis(result);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LeafResultScreen(diagnosis: result)),
      );
    }
  }

  Future<String> _currentLocationLabel() async {
    try {
      final position = await _locationService.getCurrentLocation();
      return _locationService.getLocationAddress(position.latitude, position.longitude);
    } catch (_) {
      return 'Not set';
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.forest),
            const SizedBox(height: 20),
            Text(
              strings('analyzing'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              strings('analyzingSub'),
              style: const TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
