import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MedicalRecordPage extends StatefulWidget {
  const MedicalRecordPage({super.key});

  @override
  State<MedicalRecordPage> createState() =>
      _MedicalRecordPageState();
}

class _MedicalRecordPageState
    extends State<MedicalRecordPage> {
  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;
  bool isAnalyzing = false;

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      _showError(
        'Unable to access camera. Please allow camera permission.',
      );
    }
  }

  Future<void> _chooseFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      _showError(
        'Unable to select the image.',
      );
    }
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> _analyzeRecord() async {
    if (selectedImage == null) return;

    setState(() {
      isAnalyzing = true;
    });

    // ML integration will be added here later.
    //
    // For now we only prepare the complete UI flow.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      isAnalyzing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Medical record captured successfully. '
          'AI analysis will be connected next.',
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _imagePreview() {
    if (selectedImage == null) {
      return Container(
        width: double.infinity,
        height: 260,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD5E6F2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE0F0FF),
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 35,
                color: Color(0xFF2589E8),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Capture your medical report',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Make sure the report is clear and readable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF6685A0),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 300,
        color: const Color(0xFFEFF6FB),
        child: Stack(
          children: [
            Positioned.fill(
              child: kIsWeb
                  ? Image.network(
                      selectedImage!.path,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      File(selectedImage!.path),
                      fit: BoxFit.contain,
                    ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.6,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFDCE8F2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2589E8),
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF123E68),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF8A9BAB),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF9AAEBD),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFD),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF123E68),
          ),
        ),
        title: const Text(
          'Scan Medical Record',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF123E68),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            5,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Medical Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF123E68),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Capture or upload your medical report. '
                'AI analysis will use the information from '
                'your report.',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xFF6685A0),
                ),
              ),

              const SizedBox(height: 20),

              _imagePreview(),

              const SizedBox(height: 20),

              if (selectedImage == null) ...[
                _actionButton(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take Photo',
                  subtitle:
                      'Use your camera to capture the report',
                  onTap: _takePhoto,
                ),

                _actionButton(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  subtitle:
                      'Select an existing medical report',
                  onTap: _chooseFromGallery,
                ),
              ] else ...[
                const Text(
                  'Report captured',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF123E68),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Check that all important information '
                  'is visible and readable.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6685A0),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                        isAnalyzing
                            ? null
                            : _analyzeRecord,
                    icon: isAnalyzing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome,
                            size: 19,
                          ),
                    label: Text(
                      isAnalyzing
                          ? 'Preparing Analysis...'
                          : 'Analyze Medical Record',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2589E8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF8ABCE8),
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton.icon(
                    onPressed: isAnalyzing
                        ? null
                        : _removeImage,
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                    ),
                    label: const Text(
                      'Choose Another',
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF2589E8),
                      side: const BorderSide(
                        color: Color(0xFF2589E8),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3FF),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 19,
                      color: Color(0xFF2589E8),
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'For better results, capture a clear '
                        'image with good lighting. Make sure '
                        'the medical values are completely visible.',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.5,
                          color: Color(0xFF456174),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}