import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-In error: $error');
      }
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-Out error: $error');
      }
    }
  }

  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      if (kDebugMode) {
        print('Google Silent Sign-In error: $error');
      }
      return null;
    }
  }

  static Future<String?> getIdToken() async {
    try {
      final GoogleSignInAccount? account = await getCurrentUser();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        return auth.idToken;
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Google ID Token error: $error');
      }
      return null;
    }
  }

  static Future<Map<String, String>?> getUserInfo() async {
    try {
      final GoogleSignInAccount? account = await getCurrentUser();
      if (account != null) {
        return {
          'id': account.id,
          'email': account.email,
          'displayName': account.displayName ?? '',
          'photoUrl': account.photoUrl ?? '',
        };
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Google User Info error: $error');
      }
      return null;
    }
  }
}