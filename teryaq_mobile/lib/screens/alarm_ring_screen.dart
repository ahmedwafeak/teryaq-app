import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/ai_verification_service.dart';

class AlarmRingScreen extends StatefulWidget {
  final String patientName;
  final String medicationName;
  final String caregiverPhone;

  const AlarmRingScreen({
    Key? key,
    required this.patientName,
    required this.medicationName,
    required this.caregiverPhone,
  }) : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  late String _doseId;
  bool _isCameraOpen = false;
  bool _isVerifying = false;
  String _statusMessage = 'المنبه يعمل الآن! التقط صورة لعلبة الدواء لإيقاف التنبيه.';
  Color _statusColor = Colors.amber;
  int _secondsRemaining = 600; // 10 minutes countdown
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _doseId = 'dose-${DateTime.now().millisecondsSinceEpoch}';
    _startAlarmFlow();
  }

  void _startAlarmFlow() async {
    // Notify Backend & Start 10-minute Escalation Timer
    await ApiService.triggerAlarm(_doseId, widget.patientName, widget.medicationName, widget.caregiverPhone);

    // Start 10-min countdown timer display
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _statusMessage = '🚨 تم انقضاء 10 دقائق! تم إرسال تنبيه طوارئ عاجل لمُشرف الرعاية.';
          _statusColor = Colors.red;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _processAiVerification(String simulatedOcrText) async {
    setState(() {
      _isVerifying = true;
    });

    final aiResult = await AiVerificationService.verifyMedicinePhoto(
      targetMedication: widget.medicationName,
      simulatedCapturedText: simulatedOcrText,
    );

    if (aiResult.isVerified) {
      // Notify backend to cancel 10-min timer
      await ApiService.submitVerification(_doseId, aiResult.confidenceScore, aiResult.detectedText);
      _countdownTimer?.cancel();

      setState(() {
        _isVerifying = false;
        _statusMessage = '✅ تم التحقق من الجرعة بنجاح! شفاك الله وعافاك.';
        _statusColor = Colors.green;
        _isCameraOpen = false;
      });

      // Close alarm screen after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      setState(() {
        _isVerifying = false;
        _statusMessage = aiResult.message;
        _statusColor = Colors.redAccent;
      });
    }
  }

  String _formatTimer(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing alarm via Back button!
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Column(
            children: [
              // Alarm Header & Timer Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red[900],
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.alarm_on, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'تنبيه الجرعة الصارم - منبه يعمل ⏰',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'المتبقي للتصعيد لمشرف الرعاية: ${_formatTimer(_secondsRemaining)}',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Medication Details
              Text(
                'الدواء المطلوب: ${widget.medicationName}',
                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Camera Viewfinder or Prompt Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _statusColor, width: 2),
                  ),
                  child: _isCameraOpen
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 60, color: Color(0xFF38BDF8)),
                            const SizedBox(height: 12),
                            const Text(
                              '[ الكاميرا نشطة - يتم فحص الإطار ]',
                              style: TextStyle(color: Colors.slate300, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            if (_isVerifying)
                              const CircularProgressIndicator(color: Color(0xFF38BDF8))
                            else ...[
                              const Text('اختر نتيجة محاكاة فحص العلبة:', style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                                label: const Text('تصوير علبة كابوتين الصحيحة', style: TextStyle(color: Colors.white)),
                                onPressed: () => _processAiVerification('CAPOTEN 25MG BOTTLE'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                icon: const Icon(Icons.error, color: Colors.white),
                                label: const Text('تصوير علبة دواء خاطئة (بندول)', style: TextStyle(color: Colors.white)),
                                onPressed: () => _processAiVerification('PANADOL EXTRA'),
                              ),
                            ],
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.center_focus_weak, size: 80, color: Colors.slate500),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                textAlign: TextAlign.center,
                                child: Text(
                                  'اضغط زر فتح الكاميرا بالأسفل والتقط صورة دقيقة لعلبة الدواء لإيقاف صوت المنبه.',
                                  style: TextStyle(color: Colors.slate300, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Status Banner Message
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _statusColor),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),

              // Camera Launch Action Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.camera_enhance, color: Colors.white, size: 28),
                  label: Text(
                    _isCameraOpen ? 'إعادة ضبط الكاميرا 📷' : 'فتح الكاميرا والتحقق من الدواء 📷',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      _isCameraOpen = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
