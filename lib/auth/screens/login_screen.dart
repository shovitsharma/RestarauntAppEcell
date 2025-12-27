import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2/utils/snackbar_helper.dart';
import 'package:untitled2/inventory/screens/inventory_list_screen.dart'; 
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

  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _verificationId;
  int? _resendToken;

  void _onSendOtp() async {
    _otpController.clear();
    
    if (_phoneController.text.length < 10) {
      showCustomSnackBar(context, message: 'Please enter a valid 10-digit phone number.', isError: true);
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      String phoneNumber = "+91${_phoneController.text.trim()}";
      
      // CALL THE SERVICE
      await _authService.sendOtp(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        
        // 1. SUCCESS CALLBACK
        onCodeSent: (verificationId, resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _resendToken = resendToken;
              _isOtpSent = true;
              _isLoading = false; 
            });
            showCustomSnackBar(context, message: 'OTP has been sent!');
          }
        },
        
        
        onError: (errorMessage) {
          if (mounted) {
            setState(() => _isLoading = false); 
            showCustomSnackBar(context, message: errorMessage, isError: true);
          }
        },
      );
      
    } catch (e) {
     
      if (mounted) {
        setState(() => _isLoading = false);
        showCustomSnackBar(context, message: 'An unknown error occurred.', isError: true);
      }
    }

  }
  void _onVerifyOtp() async {
  if (_verificationId == null || _otpController.text.isEmpty) {
    showCustomSnackBar(context, message: 'Please enter the OTP.', isError: true);
    return;
  }
  setState(() => _isLoading = true);
  print("--- Starting OTP Verification ---");

  try {
    await _authService.verifyOtp(
      verificationId: _verificationId!,
      smsCode: _otpController.text.trim(),
    );
    
    print(">>> STEP 1: Firebase verification SUCCEEDED.");

    showCustomSnackBar(context, message: 'Login Successful!');

    print(">>> STEP 2: 'Login Successful' SnackBar has been shown.");

    if (mounted) {
      print(">>> STEP 3: Widget is mounted. Attempting to navigate NOW...");
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const InventoryListScreen()),
      );

      print(">>> STEP 4: Navigation call has completed. If you see this, the screen should have changed.");

    } else {
      print(">>> ERROR: WIDGET WAS NOT MOUNTED! Cannot navigate.");
    }

  } on FirebaseAuthException catch (e, stackTrace) {
    print(">>> ERROR: A FIREBASE AUTH EXCEPTION was caught!");
    print(e.toString());
    print(stackTrace);
    showCustomSnackBar(context, message: e.message ?? 'Invalid OTP or an error occurred.', isError: true);
  } catch (e, stackTrace) {
    print(">>> ERROR: A GENERAL EXCEPTION was caught! This might be the navigation error.");
    print(e.toString());
    print(stackTrace);
    showCustomSnackBar(context, message: 'An unknown error occurred. Please try again.', isError: true);
  } finally {
    print("--- FINALLY BLOCK: Setting isLoading to false. ---");
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Admin Login",
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isOtpSent ? Icons.vpn_key : Icons.manage_accounts,
                  size: 100,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 25),
                Text(
                  _isOtpSent ? 'Enter Your OTP' : 'Sign in to your Admin Panel',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  obscureText: false,
                  enabled: !_isOtpSent,
                ),
                const SizedBox(height: 10),
                if (_isOtpSent)
                  MyTextField(
                    controller: _otpController,
                    hintText: '6-Digit OTP',
                    obscureText: false,
                    keyboardType: TextInputType.number,
                  ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: _isOtpSent ? _onVerifyOtp : _onSendOtp,
                  text: _isOtpSent ? 'Verify OTP' : 'Send OTP',
                  isLoading: _isLoading,
                ),
                if (_isOtpSent)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextButton(
                      onPressed: _isLoading ? null : _onSendOtp,
                      child: Text(
                        'Resend OTP',
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