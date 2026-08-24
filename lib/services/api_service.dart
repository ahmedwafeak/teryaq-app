import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // للتشغيل على المحاكي (Android Emulator): استخدم 'http://10.0.2.2:3000/api'
  // للتشغيل على هاتف حقيقي بنفس شبكة Wi-Fi: استبدل localhost برقم IP كمبيوترك (مثال: 'http://192.168.1.10:3000/api')
  static String baseUrl = 'http://10.0.2.2:3000/api';


  /// Verify invite code & bind device
  static Future<Map<String, dynamic>> verifyInvite(String code, String deviceUuid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-invite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'inviteCode': code, 'deviceUuid': deviceUuid}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالخادم: $e'};
    }
  }

  /// Notify backend that alarm started ringing (starts 10-min escalation timer)
  static Future<Map<String, dynamic>> triggerAlarm(String doseId, String patientName, String medName, String caregiverPhone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alarm/trigger'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doseId': doseId,
          'patientName': patientName,
          'medicationName': medName,
          'caregiverPhone': caregiverPhone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'فشل تفعيل المنبه بالخادم'};
    }
  }

  /// Submit AI Photo verification
  static Future<Map<String, dynamic>> submitVerification(String doseId, double confidence, String detectedText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alarm/verify-dose'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doseId': doseId,
          'confidenceScore': confidence,
          'detectedText': detectedText,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'فشل إرسال نتائج التحقق'};
    }
  }
}
