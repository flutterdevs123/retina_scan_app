import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/components/custom_button.dart';
import 'package:retina_scan_app/res/components/custom_text_field.dart';
import 'package:retina_scan_app/res/components/fundus_visualizer.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/res/routes/app_routes.dart';
import 'package:retina_scan_app/res/services/responsive_service.dart';
import 'package:retina_scan_app/view_models/screening_view_model.dart';

class NewScanView extends StatefulWidget {
  const NewScanView({super.key});

  @override
  State<NewScanView> createState() => _NewScanViewState();
}

class _NewScanViewState extends State<NewScanView> {
  final TextEditingController _notesController = TextEditingController();
  final ScreeningViewModel _screeningVm = Get.find<ScreeningViewModel>();
  final ImagePicker _picker = ImagePicker();

  String _selectedEye = 'Right Eye (OD)';
  String _selectedImagePath = 'sample://fundus_1';
  int _sampleIndex = 1;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _selectedImagePath = file.path);
      }
    } catch (_) {
      Get.snackbar(
        'Camera Unavailable',
        'Switched to clinical sample fundus capture for offline simulation.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _cycleSampleFundus() {
    setState(() {
      _sampleIndex = (_sampleIndex % 3) + 1;
      _selectedImagePath = 'sample://fundus_$_sampleIndex';
    });
  }

  Future<void> _submitScan() async {
    final ScreeningModel? created = await _screeningVm.submitNewScan(
      eyeSide: _selectedEye,
      imagePath: _selectedImagePath,
      symptomNotes: _notesController.text,
    );
    if (created != null && mounted) {
      Get.offNamed(AppRoutes.screeningDetail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = ResponsiveService.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Retinal Fundus Scan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FundusVisualizer(
                    imagePath: _selectedImagePath,
                    detectionPoints: const <DetectionPoint>[],
                    showGradCam: false,
                    height: 220,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      CustomButton(
                        label: 'Gallery',
                        icon: Icons.photo_library_outlined,
                        isOutlined: true,
                        expand: false,
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                      CustomButton(
                        label: 'Camera',
                        icon: Icons.camera_alt_outlined,
                        isOutlined: true,
                        expand: false,
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      CustomButton(
                        label: 'Cycle Sample Scan',
                        icon: Icons.autorenew_rounded,
                        isOutlined: true,
                        expand: false,
                        onPressed: _cycleSampleFundus,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Laterality / Eye Examined',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: <String>[
                      'Right Eye (OD)',
                      'Left Eye (OS)',
                      'Bilateral',
                    ].map((String eye) {
                      return ChoiceChip(
                        label: Text(eye),
                        selected: _selectedEye == eye,
                        selectedColor: AppColors.primaryTeal.withAlpha(45),
                        onSelected: (_) => setState(() => _selectedEye = eye),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _notesController,
                    label: 'Clinical Symptoms & Diabetic History',
                    hint: 'Describe blurred vision, floaters, glare, or HbA1c notes...',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 22),
                  Obx(
                    () => CustomButton(
                      label: 'Run AI Diagnostic & Submit',
                      icon: Icons.biotech_rounded,
                      isLoading: _screeningVm.isSubmitting.value,
                      onPressed: _submitScan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}