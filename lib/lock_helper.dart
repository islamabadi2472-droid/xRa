import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Hash a PIN using SHA-256
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // Verify PIN
  static bool verifyPin(String enteredPin, String storedHash) {
    return hashPin(enteredPin) == storedHash;
  }

  // Check if biometrics available
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to unlock',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // App-level lock
  static Future<void> setAppPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin_hash', hashPin(pin));
    await prefs.setBool('app_lock_enabled', true);
  }

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('app_lock_enabled') ?? false;
  }

  static Future<bool> verifyAppPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString('app_pin_hash');
    if (storedHash == null) return false;
    return verifyPin(pin, storedHash);
  }

  static Future<void> removeAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_pin_hash');
    await prefs.setBool('app_lock_enabled', false);
  }
}
