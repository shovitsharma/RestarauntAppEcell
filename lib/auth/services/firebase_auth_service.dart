import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2/auth/models/user_model.dart';


class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Send OTP (Updated with safe Error Callback)
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String errorMessage) onError, // <--- ADDED THIS
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      
      // A. Automatic Auto-fill (Android only)
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optional: specific logic if you want auto-login
        // await _auth.signInWithCredential(credential);
      },

      // B. Handle Errors Safely (No more crashing!)
      verificationFailed: (FirebaseAuthException e) {
        String message = "Verification failed";
        if (e.code == 'invalid-phone-number') {
          message = "The phone number is invalid.";
        } else if (e.code == "too-many-requests") {
          message = "Too many attempts. Try again later.";
        } else {
          message = e.message ?? "Unknown error occurred";
        }
        // Send error back to UI instead of crashing app
        onError(message); 
      },

      // C. Success!
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out...
      },
    );
  }

  // 2. Verify OTP
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      // Sign in
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Create Admin Doc if needed
      if (userCredential.user != null) {
        await _createAdminDocumentIfNotExists(userCredential.user!);
      } else {
        throw FirebaseAuthException(code: 'user-not-found', message: 'Sign in failed');
      }
    } on FirebaseAuthException {
      rethrow; 
    }
  }

  // 3. Create Admin Document
  Future<void> _createAdminDocumentIfNotExists(User user) async {
    
    final userDocRef = _firestore.collection('admins').doc(user.uid);
    
    try {
      final doc = await userDocRef.get();
      
      if (!doc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          phoneNumber: user.phoneNumber ?? '',
          createdAt: Timestamp.now(),
          // Add any default fields like role if needed
          // role: 'admin', 
        );
        
        await userDocRef.set(newUser.toMap());
      }
    } catch (e) {
      // Print error for debugging but rethrow so Login Screen stops loading
      print("Database Error: $e");
      throw Exception("Failed to save user data: $e");
    }
  }

  // 4. Helpers
  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}