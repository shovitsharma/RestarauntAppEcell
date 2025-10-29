import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _onSendOtp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a phone number")),
      );
      return;
    }
    setState(() { _isLoading = true; });

    // IMPORTANT: Add your country code!
    String phoneNumber = "+91${_phoneController.text.trim()}";

    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      context: context,
      codeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
        });
      },
    );
  }

  void _onVerifyOtp() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP")),
      );
      return;
    }
    setState(() { _isLoading = true; });

    bool success = await _authService.verifyOtp(
      verificationId: _verificationId!,
      smsCode: _otpController.text.trim(),
      context: context,
    );

    setState(() { _isLoading = false; });

    if (success) {
      // Navigate to your home screen or dashboard on successful login
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Phone Number Input ---
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixText: "+91 ",
                border: OutlineInputBorder(),
              ),
              enabled: !_isOtpSent,
            ),
            const SizedBox(height: 20),

            // --- OTP Input (conditional) ---
            if (_isOtpSent)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 30),

            // --- Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_isOtpSent ? _onVerifyOtp : _onSendOtp),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isOtpSent ? "Verify OTP" : "Send OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}