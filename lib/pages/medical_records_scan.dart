import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  List<Map<String, dynamic>> mlResults = [];

  String? mlFilename;

  String? mlError;

  // ============================================================
  // SHOW AI RESULT PAGE
  // ============================================================

  void _showAnalysisResult() {
    if (mlResults.isEmpty) {
      _showError(
        'No disease risk result was returned from the ML model.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicalAnalysisResultPage(
          filename: mlFilename ?? 'Medical Report',
          results: mlResults,
        ),
      ),
    );
  }

  // ============================================================
  // TAKE PHOTO
  // ============================================================

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        selectedImage = image;
        mlResults = [];
        mlFilename = null;
        mlError = null;
      });
    } catch (e) {
      _showError(
        'Unable to access camera. Please allow camera permission.',
      );
    }
  }

  // ============================================================
  // GALLERY
  // ============================================================

  Future<void> _chooseFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        selectedImage = image;
        mlResults = [];
        mlFilename = null;
        mlError = null;
      });
    } catch (e) {
      _showError(
        'Unable to select the image.',
      );
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void _removeImage() {
    setState(() {
      selectedImage = null;
      mlResults = [];
      mlFilename = null;
      mlError = null;
    });
  }

  // ============================================================
  // ANALYZE MEDICAL REPORT
  // ============================================================

  Future<void> _analyzeRecord() async {
    if (selectedImage == null) return;

    setState(() {
      isAnalyzing = true;
      mlError = null;
      mlResults = [];
    });

    try {
      final uri = Uri.parse(
        'https://hospital-api-ml.onrender.com/predict-report',
      );

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      final bytes = await selectedImage!.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: selectedImage!.name,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'ML API failed: ${response.statusCode}\n${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      if (data['status'] != 'success') {
        throw Exception(
          data['detail']?.toString() ??
              'Unable to analyze the medical report.',
        );
      }

      final results = data['results'];

      setState(() {
        mlFilename = data['filename']?.toString();

        mlResults = results is List
            ? results
                .whereType<Map>()
                .map(
                  (item) =>
                      Map<String, dynamic>.from(item),
                )
                .toList()
            : [];

        isAnalyzing = false;
      });

      if (mounted) {
        _showAnalysisResult();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isAnalyzing = false;
        mlError = e.toString();
      });

      _showError(
        'Unable to analyze the medical report.',
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

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
          mainAxisAlignment:
              MainAxisAlignment.center,
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

  // ============================================================
  // ACTION BUTTON
  // ============================================================

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
                borderRadius:
                    BorderRadius.circular(12),
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
                      fontWeight:
                          FontWeight.w700,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5FAFD),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF5FAFD),
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
                  icon:
                      Icons.photo_library_outlined,
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
                    fontWeight:
                        FontWeight.w700,
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
                    onPressed: isAnalyzing
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
                          ? 'AI Analysis...'
                          : 'Analyze Medical Record',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2589E8),
                      foregroundColor:
                          Colors.white,
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

// ================================================================
// AI ANALYSIS RESULT PAGE
// ================================================================

class MedicalAnalysisResultPage
    extends StatelessWidget {
  final String filename;
  final List<Map<String, dynamic>> results;

  const MedicalAnalysisResultPage({
    super.key,
    required this.filename,
    required this.results,
  });

  // ============================================================
  // RISK COLOR
  // ============================================================

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;

      case 'moderate':
        return Colors.orange;

      case 'low':
        return Colors.green;

      default:
        return const Color(0xFF2589E8);
    }
  }

  // ============================================================
  // RISK ICON
  // ============================================================

  IconData _riskIcon(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Icons.warning_amber_rounded;

      case 'moderate':
        return Icons.info_outline;

      case 'low':
        return Icons.check_circle_outline;

      default:
        return Icons.health_and_safety_outlined;
    }
  }

  // ============================================================
  // BUILD RESULT CARD
  // ============================================================

  Widget _resultCard(
    Map<String, dynamic> result,
  ) {
    final disease =
        result['disease']?.toString() ??
            'Unknown Disease';

    final level =
        result['risk_level']?.toString() ??
            'Unknown';

    final rawRisk = result['risk_percent'];

    final double risk =
        rawRisk is num
            ? rawRisk.toDouble()
            : double.tryParse(
                  rawRisk?.toString() ?? '0',
                ) ??
                0;

    final color = _riskColor(level);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFDCE8F2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _riskIcon(level),
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  disease,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(0xFF123E68),
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Risk Probability',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6685A0),
                ),
              ),
              Text(
                '${risk.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child:
                LinearProgressIndicator(
              value:
                  (risk / 100).clamp(
                0.0,
                1.0,
              ),
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFEAF1F6),
              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                color,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            level.toLowerCase() == 'high'
                ? 'Higher risk detected. Please consult a doctor for professional evaluation.'
                : level.toLowerCase() ==
                        'moderate'
                    ? 'Moderate risk detected. Consider discussing these results with a doctor.'
                    : level.toLowerCase() ==
                            'low'
                        ? 'Low risk detected based on the available report information.'
                        : 'Risk information was returned by the AI model.',
            style: const TextStyle(
              fontSize: 10,
              height: 1.5,
              color: Color(0xFF6685A0),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5FAFD),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF5FAFD),
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
          'AI Analysis Result',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF123E68),
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color:
                      const Color(0xFFDCE8F2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        const BoxDecoration(
                      color:
                          Color(0xFFE7F3FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color:
                          Color(0xFF2589E8),
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Medical Risk Analysis',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Color(0xFF123E68),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          filename,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 10,
                            color:
                                Color(0xFF8A9BAB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Detected Conditions',
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w700,
                color: Color(0xFF123E68),
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // RESULTS
            // ==================================================

            ...results.map(
              (result) => _resultCard(result),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // DISCLAIMER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE7F3FF),
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
                    color:
                        Color(0xFF2589E8),
                  ),

                  SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      'This AI analysis is an automated risk assessment and should not be treated as a medical diagnosis. Consult a qualified doctor for clinical advice.',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.5,
                        color:
                            Color(0xFF456174),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // DONE
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2589E8),
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}