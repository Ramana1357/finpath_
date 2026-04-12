import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import '../../data/models/auth_user_model.dart' as model;
import '../../data/models/profile_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/biometric_service.dart';

class AuthProvider extends ChangeNotifier with WidgetsBindingObserver {
  final UserRepository _userRepository;
  final BiometricService _biometricService = BiometricService();

  User? _user;
  ProfileModel? _profile;
  bool _isLoading = false;
  bool _isBiometricAuthenticated = false;

  User? get user => _user;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isBiometricAuthenticated => _isBiometricAuthenticated;
  bool get hasProfile => _profile != null;

  AuthProvider(this._userRepository) {
    WidgetsBinding.instance.addObserver(this);
    _userRepository.authStateChanges.listen((user) async {
      print("Auth State Changed: ${user?.uid}"); // DEBUG LOG
      _user = user;
      if (user != null) {
        await _loadProfile(user.uid);
      } else {
        _profile = null;
        _isBiometricAuthenticated = false;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile(String uid) async {
    _setLoading(true);
    try {
      _profile = await _userRepository.getProfile(uid);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProfile(String uid) async {
    await _loadProfile(uid);
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final profileExists = await _userRepository.signInWithGoogle();
      _isBiometricAuthenticated = true;
      _setLoading(false);
      return profileExists;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final profileExists = await _userRepository.signInWithEmail(email, password);
      _isBiometricAuthenticated = true;
      _setLoading(false);
      return profileExists;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final profileExists = await _userRepository.signUpWithEmail(email, password);
      _isBiometricAuthenticated = true;
      _setLoading(false);
      return profileExists;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (await _biometricService.isBiometricAvailable()) {
      _isBiometricAuthenticated = await _biometricService.authenticate();
      notifyListeners();
      return _isBiometricAuthenticated;
    }
    return false;
  }

  Future<void> saveProfile(ProfileModel profile) async {
    _setLoading(true);
    try {
      await _userRepository.saveProfile(profile);
      _profile = profile;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final uid = _user?.uid;
    
    // 1. Clear state immediately for instant UI response
    _user = null;
    _profile = null;
    _isBiometricAuthenticated = false;
    _isLoading = false; 
    notifyListeners();

    // 2. Perform background cleanup
    if (uid != null) {
      try {
        await _userRepository.logout(uid);
      } catch (e) {
        debugPrint("Background logout cleanup error: $e");
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached && _user != null) {
      // Best-effort log for app cleanup/exit
      _userRepository.logout(_user!.uid); 
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
