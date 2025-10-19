import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart'
    as app_user; // Use a prefix to avoid name clashes

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  /// Sends an OTP to the provided phone number.
  ///
  /// Callbacks are used to handle UI updates in the calling widget.
  Future<void> sendOtp({
    required String phoneNumber,
    required BuildContext context, // For showing snackbars
    required Function(String verificationId) codeSent,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This is for auto-retrieval on some Android devices.
          await _auth.signInWithCredential(credential);
          // Optional: You can navigate to the home screen here
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Verification failed")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // This callback is crucial. It gives you the ID needed to verify the OTP.
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    }
  }

  /// Verifies the OTP and signs the user in.
  ///
  /// Creates a new user document in Firestore if it's the first time.
  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
    required BuildContext context,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        // User is signed in. Now check if they exist in Firestore.
        await _createUserDocumentIfNotExists(userCredential.user!);
        return true; // Indicate success
      }
      return false; // Indicate failure
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Failed to sign in")));
      return false;
    }
  }

  /// Helper function to create a user document in Firestore after first sign-in.
  Future<void> _createUserDocumentIfNotExists(User user) async {
    final userDocRef = _firestore.collection('admins').doc(user.uid);
    final doc = await userDocRef.get();

    if (!doc.exists) {
      // User is new, create a document for them
      final newUser = app_user.UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber!,
        createdAt: firestore.Timestamp.now(),
        // 'role' will use the default 'admin'
      );
      await userDocRef.set(newUser.toMap());
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Gets the current authenticated user.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
