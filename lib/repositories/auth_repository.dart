import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository extends ChangeNotifier {
  static const String _pinKey = 'user_pin_v1';
  static const String _userNameKey = 'user_name_v1';
  static const String _biometricEnabledKey = 'biometric_enabled_v1';
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  String? _pin;
  String? _userName;
  bool _isBiometricEnabled = false;
  bool _isAuthenticated = false;

  String? get pin => _pin;
  String? get userName => _userName;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasPin => _pin != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _pin = prefs.getString(_pinKey);
    _userName = prefs.getString(_userNameKey);
    _isBiometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    notifyListeners();
  }

  Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
    _pin = newPin;
    _isAuthenticated = true; // Authenticate session so router allows access to setup-name
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    _userName = name;
    _isAuthenticated = true; // User is "fully logged in" once name is set
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    _isBiometricEnabled = enabled;
    notifyListeners();
  }

  void authenticate() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> verifyBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric security',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric verification error: $e');
      rethrow; // Let caller handle specific error codes
    } catch (e) {
      debugPrint('Biometric verification error: $e');
      return false;
    }
  }

  Future<bool> authenticateBiometrically() async {
    if (!_isBiometricEnabled) return false;
    
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock Laune',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (didAuthenticate) {
        _isAuthenticated = true;
        notifyListeners();
      }
      return didAuthenticate;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  Future<bool> canUseBiometrics() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    return canAuthenticate;
  }
}
