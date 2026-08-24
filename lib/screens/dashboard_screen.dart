import 'package:flutter/material.dart';
import 'alarm_ring_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DashboardScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientName = userData['patientName'] ?? 'المريض';
    final medication = userData['medication'] ?? 'دواء عام';
    final caregiverPhone = userData['caregiverPhone'] ?? '+966500000000';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('أهلاً بك، $patientName'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نسبة الالتزام بالجرعات',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Icon(Icons.stars, color: Colors.amber, size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '100% - ممتاز! 🌟',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'مُشرف الرعاية المرتبط: $caregiverPhone',
                    style: const TextStyle(color: Colors.white90, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'جدول أدوية اليوم:',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Dose Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF0284C7),
                      child: Icon(Icons.medication, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'الموعد: 08:00 صباحاً (جرعة واحدة)',
                            style: TextStyle(color: Colors.slate400, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // Launch Smart Verification Alarm Ringing Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlarmRingScreen(
                              patientName: patientName,
                              medicationName: medication,
                              caregiverPhone: caregiverPhone,
                            ),
                          ),
                        );
                      },
                      child: const Text('محاكاة المنبه ⏰', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF334155).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'المنبه لن يتوقف عند الرنين حتى تقوم بفتح الكاميرا وتصوير علبة الدواء والتحقق منها.',
                      style: TextStyle(color: Colors.slate300, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
