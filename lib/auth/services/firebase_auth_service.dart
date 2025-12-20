import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart'
    as app_user; // Use a prefix to avoid name clashes

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  /// Sends or resends an OTP. Throws a FirebaseAuthException on failure.
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    int? forceResendingToken,
  }) async {
    // The try-catch is not needed here because verifyPhoneNumber's callbacks handle it.
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // As requested: throw the error up to the UI layer to handle.
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Verifies the OTP. Completes successfully or throws a FirebaseAuthException on failure.
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _createUserDocumentIfNotExists(userCredential.user!);
      } else {
        throw FirebaseAuthException(code: 'user-not-found');
      }
    } on FirebaseAuthException {
      // As requested: rethrow the caught exception to be handled by the UI.
      rethrow;
    }
  }

  /// Helper function to create a user document in Firestore after first sign-in.
  Future<void> _createUserDocumentIfNotExists(User user) async {
    final userDocRef = _firestore.collection('admins').doc(user.uid);
    final doc = await userDocRef.get();
    if (!doc.exists) {
      final newUser = app_user.UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber!,
        createdAt: firestore.Timestamp.now(),
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
