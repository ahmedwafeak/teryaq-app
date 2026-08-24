import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({Key? key}) : super(key: key);

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final TextEditingController _codeController = TextEditingController(text: 'TRQ-7788');
  bool _isLoading = false;
  String? _errorMessage;

  void _handleVerifyInvite() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.verifyInvite(_codeController.text.trim(), 'device-mobile-uuid-001');

    setState(() {
      _isLoading = false;
    });

    if (res['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(userData: res['user']),
        ),
      );
    } else {
      setState(() {
        _errorMessage = res['message'] ?? 'كود الدعوة غير صحيح.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: Main me: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_outlined, size: 80, color: Color(0xFF38BDF8)),
              const SizedBox(height: 16),
              const Text(
                'تطبيق ترياق - Teryaq',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تطبيق منبه الأدوية الذكي بالدخول المقيد (Invite-Only)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.slate300),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'أدخل كود الدعوة الخاص بك:',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'TRQ-XXXX',
                        hintStyle: const TextStyle(color: Colors.slate500),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleVerifyInvite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'تفعيل الحساب والبدء',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'الوصول لهذا التطبيق مقتصر على مرضى محددين يتم إضافتهم عبر المشرف الصحي.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.slate400, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
