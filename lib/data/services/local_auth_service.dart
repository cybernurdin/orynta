import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer_profile.dart';
import '../models/local_account.dart';

class LocalAuthException implements Exception {
  final String message;
  const LocalAuthException(this.message);
  @override
  String toString() => message;
}

/// Local, on-device stand-in for real account auth. Firebase (firebase_auth
/// + cloud_firestore) is already a dependency and was previously written
/// against directly, but no Firebase project has ever been connected
/// (no firebase_options.dart, Firebase.initializeApp() never called) —
/// this service lets registration/login/logout/reset genuinely work today
/// without one, ready to be swapped for a real backend later.
///
/// A plain singleton, not a ChangeNotifier: session state is read once at
/// startup / on explicit navigation rather than watched reactively,
/// matching the existing WeatherService/InferenceService/MarketService
/// convention.
class LocalAuthService {
  static const _accountsKey = 'orynta_accounts';
  static const _sessionKey = 'orynta_session_email';

  /// Shown on-screen during password reset — there's no backend to send a
  /// real email, so the flow stays honest about being simulated while
  /// still being genuinely completable end-to-end.
  static const demoResetCode = '123456';

  static const _demoGoogleEmail = 'demo.farmer@gmail.com';
  static const _demoGoogleName = 'Amara N.';

  LocalAccount? _findByEmail(List<LocalAccount> accounts, String email) {
    for (final a in accounts) {
      if (a.email == email) return a;
    }
    return null;
  }

  Future<List<LocalAccount>> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_accountsKey);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map((e) => LocalAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAccounts(List<LocalAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _accountsKey,
      jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  String _generateSalt() {
    final rand = Random.secure();
    return List.generate(16, (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  String _hash(String password, String salt) => sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<void> _setSession(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, email);
    }
  }

  Future<LocalAccount> register({
    required String email,
    required String password,
    required String displayName,
    required FarmerType farmerType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();
    if (_findByEmail(accounts, normalizedEmail) != null) {
      throw const LocalAuthException('An account already exists for that email.');
    }
    final salt = _generateSalt();
    final account = LocalAccount(
      email: normalizedEmail,
      passwordHash: _hash(password, salt),
      salt: salt,
      displayName: displayName,
      farmerType: farmerType,
      provider: 'email',
      createdAt: DateTime.now(),
    );
    await _saveAccounts([...accounts, account]);
    await _setSession(normalizedEmail);
    return account;
  }

  Future<LocalAccount> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();
    final account = _findByEmail(accounts, normalizedEmail);
    if (account == null) {
      throw const LocalAuthException('No account found for that email.');
    }
    if (_hash(password, account.salt) != account.passwordHash) {
      throw const LocalAuthException('Incorrect password.');
    }
    await _setSession(normalizedEmail);
    return account;
  }

  /// One fixed, deterministic demo identity — there's no real OAuth behind
  /// this, so a fake multi-account picker would add UI weight for no
  /// benefit. Creates the demo account on first use, reuses it after.
  Future<LocalAccount> simulateGoogleSignIn() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final accounts = await _loadAccounts();
    var account = _findByEmail(accounts, _demoGoogleEmail);
    if (account == null) {
      account = LocalAccount(
        email: _demoGoogleEmail,
        passwordHash: '',
        salt: '',
        displayName: _demoGoogleName,
        farmerType: FarmerType.beginner,
        provider: 'google',
        createdAt: DateTime.now(),
      );
      await _saveAccounts([...accounts, account]);
    }
    await _setSession(account.email);
    return account;
  }

  /// Always "succeeds" cosmetically without revealing whether the account
  /// exists — the demo code is what actually gates `resetPassword`.
  Future<void> sendPasswordResetCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (code.trim() != demoResetCode) {
      throw const LocalAuthException('Incorrect code. Check the demo code shown on screen.');
    }
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();
    final index = accounts.indexWhere((a) => a.email == normalizedEmail);
    if (index == -1) {
      throw const LocalAuthException('No account found for that email.');
    }
    final salt = _generateSalt();
    accounts[index] = accounts[index].copyWith(passwordHash: _hash(newPassword, salt), salt: salt);
    await _saveAccounts(accounts);
  }

  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();
    final index = accounts.indexWhere((a) => a.email == normalizedEmail);
    if (index == -1) {
      throw const LocalAuthException('No account found for that email.');
    }
    if (_hash(oldPassword, accounts[index].salt) != accounts[index].passwordHash) {
      throw const LocalAuthException('Current password is incorrect.');
    }
    final salt = _generateSalt();
    accounts[index] = accounts[index].copyWith(passwordHash: _hash(newPassword, salt), salt: salt);
    await _saveAccounts(accounts);
  }

  Future<void> logout() async {
    await _setSession(null);
  }

  Future<LocalAccount?> currentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    final accounts = await _loadAccounts();
    return _findByEmail(accounts, email);
  }
}
