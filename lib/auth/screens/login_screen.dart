import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/form_helpers.dart';

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
  String? _errorMessage; // For displaying errors to the user

  void _onSendOtp() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _errorMessage = "Please enter a phone number");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    String phoneNumber = "+91${_phoneController.text.trim()}";

    try {
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
    } catch (e) {
      // Handle errors thrown by the service
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onVerifyOtp() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      setState(() => _errorMessage = "Please enter the OTP");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });
    bool success = false;
    try {
      success = await _authService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
        context: context,
      );
    } catch (e) {
      // Handle errors thrown by the service
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
    

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to your admin home screen on successful login
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful!"),
          backgroundColor: Colors.green, // Themed success message
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  // --- End of your logic ---

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Admin Login",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(
          color: colorScheme.onSurface, // Icon color for back button
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Restaurant/Admin themed Icon
                Icon(
                  _isOtpSent ? Icons.vpn_key : Icons.manage_accounts,
                  size: 100,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 25),

                // Title
                Text(
                  _isOtpSent
                      ? 'Enter Your OTP'
                      : 'Sign in to your Admin Panel',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // --- Phone Number Input ---
               
                MyTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  obscureText: false,
                  
                ),
                const SizedBox(height: 10),

                // --- OTP Input (conditional) ---
                if (_isOtpSent)
                  MyTextField(
                    controller: _otpController,
                    hintText: '6-Digit OTP',
                    obscureText: false,
                    // keyboardType: TextInputType.number,
                  ),
                const SizedBox(height: 25),

                // --- Error Message Display ---
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      _errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // --- Button ---
                
                MyButton(
                  onTap: _isOtpSent ? _onVerifyOtp : _onSendOtp,
                  text: _isOtpSent ? 'Verify OTP' : 'Send OTP',
                  isLoading: _isLoading,
                ),

                // --- Resend OTP / Change Number ---
                if (_isOtpSent)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isOtpSent = false;
                                _errorMessage = null; // Clear error
                                _verificationId = null;
                                _otpController.clear();
                              });
                            },
                      child: Text(
                        'Change Phone Number',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

