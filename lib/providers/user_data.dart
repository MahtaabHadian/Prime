import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData extends ChangeNotifier {
  static const String _nameKey = 'user_name';
  static const String _pfpKey = 'user_pfp_path';
  static const String _setupCompleteKey = 'user_setup_complete';

  String _userName = '';
  String _pfpPath = 'assets/img/pfp/1.png'; // Default PFP
  bool _isSetupComplete = false;
  bool _isLoading = true;

  String get userName => _userName;
  String get pfpPath => _pfpPath;
  bool get isSetupComplete => _isSetupComplete;
  bool get isLoading => _isLoading;
  bool get isInitialized => !_isLoading;

  UserData() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // ... (کد loadUserData بدون تغییر) ...
    _isLoading = true;
    // notifyListeners(); // Don't notify start, only end

    try {
      final prefs = await SharedPreferences.getInstance();
      _isSetupComplete = prefs.getBool(_setupCompleteKey) ?? false;

      if (_isSetupComplete) {
        _userName = prefs.getString(_nameKey) ?? 'User'; // Default if somehow missing
        _pfpPath = prefs.getString(_pfpKey) ?? 'assets/img/pfp/1.png'; // Default PFP if missing
      } else {
        // Ensure defaults if setup is not complete
        _userName = '';
        _pfpPath = 'assets/img/pfp/1.png';
      }
      print("User data loaded: SetupComplete=$_isSetupComplete, Name=$_userName, PFP=$_pfpPath");
    } catch (e) {
      print("Error loading user data: $e");
      _isSetupComplete = false;
      _userName = '';
      _pfpPath = 'assets/img/pfp/1.png';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI when loading is done
    }
  }

  // --- متد saveUserProfile اصلاح شد تا bool برگرداند ---
  Future<bool> saveUserProfile(String name, String pfpPath) async {
    if (name.trim().isEmpty || pfpPath.isEmpty) {
      print("Validation Error: Cannot save empty name or PFP path.");
      return false; // Indicate failure due to validation
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      print("Attempting to save name: $name");
      await prefs.setString(_nameKey, name.trim());
      print("Attempting to save PFP path: $pfpPath");
      await prefs.setString(_pfpKey, pfpPath);
      print("Attempting to save setup complete flag");
      await prefs.setBool(_setupCompleteKey, true);
      print("All preferences saved successfully.");

      // Update internal state
      _userName = name.trim();
      _pfpPath = pfpPath;
      _isSetupComplete = true;

      print("User profile saved: Name=$name, PFP=$pfpPath");
      notifyListeners();
      return true; // Indicate success

    } catch (e, stackTrace) {
      // --- لاگ دقیق خطا حفظ شد ---
      print("*****************************************");
      print("!!! ERROR saving user profile !!!");
      print("Original Error Type: ${e.runtimeType}");
      print("Original Error Message: $e");
      print("Stack Trace:\n$stackTrace");
      print("*****************************************");
      return false; // Indicate failure
    }
  }

  Future<void> resetSetup() async {
    // ... (کد resetSetup بدون تغییر) ...
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_pfpKey);
    await prefs.setBool(_setupCompleteKey, false);
    _userName = '';
    _pfpPath = 'assets/img/pfp/1.png';
    _isSetupComplete = false;
    _isLoading = false;
    print("User setup reset.");
    notifyListeners();
  }
}