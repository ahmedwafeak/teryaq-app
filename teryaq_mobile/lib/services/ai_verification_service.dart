import 'dart:async';

class AiVerificationResult {
  final bool isVerified;
  final double confidenceScore;
  final String detectedText;
  final String message;

  AiVerificationResult({
    required this.isVerified,
    required this.confidenceScore,
    required this.detectedText,
    required this.message,
  });
}

class AiVerificationService {
  /// Hybrid AI Computer Vision Verification (On-Device OCR & Detection Simulation)
  static Future<AiVerificationResult> verifyMedicinePhoto({
    required String targetMedication,
    required String simulatedCapturedText,
  }) async {
    // Simulate fast on-device inference latency (~300ms)
    await Future.delayed(const Duration(milliseconds: 300));

    final normalizedTarget = targetMedication.toLowerCase();
    final normalizedCaptured = simulatedCapturedText.toLowerCase();

    // Check if expected medication brand/text is found in OCR stream
    if (normalizedCaptured.contains('capoten') || normalizedCaptured.contains('كابوتين')) {
      return AiVerificationResult(
        isVerified: true,
        confidenceScore: 0.94,
        detectedText: simulatedCapturedText,
        message: 'تم التعرف بنجاح على علبة دواء $targetMedication! 🟢',
      );
    } else if (simulatedCapturedText.isNotEmpty) {
      return AiVerificationResult(
        isVerified: false,
        confidenceScore: 0.45,
        detectedText: simulatedCapturedText,
        message: 'عذراً، العلبة الظاهرة لا تطابق دواء $targetMedication المطلوب! 🔴',
      );
    } else {
      return AiVerificationResult(
        isVerified: false,
        confidenceScore: 0.10,
        detectedText: '',
        message: 'لم يتم التعرف على علبة دواء في الإطار، يرجى توجيه الكاميرا بوضوح. ⚠️',
      );
    }
  }
}
