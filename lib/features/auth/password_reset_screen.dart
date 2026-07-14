import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/local_auth_service.dart';

enum _ResetStep { requestCode, resetPassword, done }

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _localAuth = LocalAuthService();
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  late final TextEditingController _newPasswordController;

  _ResetStep _step = _ResetStep.requestCode;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestCode() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _localAuth.sendPasswordResetCode(_emailController.text.trim());
      if (mounted) setState(() => _step = _ResetStep.resetPassword);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    if (_codeController.text.isEmpty || _newPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _localAuth.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      setState(() => _step = _ResetStep.done);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } on LocalAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Reset password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                if (_step == _ResetStep.done) ...[
                  const Icon(Icons.check_circle_rounded, color: AppColors.confidenceHigh, size: 48),
                  const SizedBox(height: 16),
                  Text('Password updated', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'You can now sign in with your new password.',
                    style: TextStyle(color: AppColors.grey, height: 1.5),
                  ),
                ] else ...[
                  Text(
                    _step == _ResetStep.requestCode ? 'Forgot your password?' : 'Enter your reset code',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _step == _ResetStep.requestCode
                        ? "Enter your email address and we'll send you a code to reset your password."
                        : 'Enter the code we sent and choose a new password.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.grey,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24),

                  if (_step == _ResetStep.resetPassword) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.12),
                        border: Border.all(color: AppColors.amber),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Demo mode: no email is actually sent. Your code is 123456.',
                              style: TextStyle(color: AppColors.ink, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.confidenceLow.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.confidenceLow),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.confidenceLow, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_step == _ResetStep.requestCode) ...[
                    TextField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email address',
                        hintText: 'you@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRequestCode,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.white)),
                              )
                            : const Text('Send reset code'),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _codeController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Reset code',
                        hintText: '123456',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      enabled: !_isLoading,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        hintText: 'At least 6 characters',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.white)),
                              )
                            : const Text('Reset password'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Back to sign in'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
