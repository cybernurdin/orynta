import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import 'analyzing_screen.dart';
import 'scan_type.dart';

/// FR-1.1: capture soil/leaf photo. Camera capture isn't available on
/// every platform this app targets (e.g. Windows desktop) — picks fail
/// gracefully to a friendly message rather than crashing, and a sample
/// photo path lets the demo continue on devices with no camera/gallery.
class CaptureScreen extends StatefulWidget {
  final ScanType type;
  const CaptureScreen({super.key, required this.type});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _picked;
  bool _picking = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() => _picked = file);
      }
    } catch (_) {
      if (!mounted) return;
      final strings = context.read<LocaleProvider>().strings;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings('takePhoto')}: unavailable on this device')),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _startAnalysis() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(type: widget.type, imagePath: _picked?.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final isSoil = widget.type == ScanType.soil;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSoil ? strings('scanSoilTitle') : strings('scanLeafTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.25)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _picked == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSoil ? Icons.grass_rounded : Icons.eco_rounded,
                              size: 64,
                              color: AppColors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isSoil ? strings('scanSoilDesc') : strings('scanLeafDesc'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      )
                    : (kIsWeb
                        ? Image.network(_picked!.path, fit: BoxFit.cover)
                        : Image.file(File(_picked!.path), fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 16),
            if (_picking) const CircularProgressIndicator(),
            if (!_picking) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(strings('takePhoto')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(strings('chooseFromGallery')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startAnalysis,
                  child: Text(strings('scanTitle')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
