import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String userType;
  
  const LoginScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Set default values for testing
    if (widget.userType == 'craftsman') {
      _emailController.text = 'ahmet@test.com';
      _passwordController.text = '123456';
    } else {
      _emailController.text = 'customer@test.com';
      _passwordController.text = '123456';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.getGradient(AppColors.primaryGradient),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                  strokeWidth: 4,
                ),
                SizedBox(height: 24),
                Text(
                  'Giriş yapılıyor...',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getGradient(
            AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header - Modern & Cartoon Style
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.textWhite.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.textWhite.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.userType == 'craftsman' ? 'Usta Girişi' : '👤 Müşteri Girişi',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 60),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.userType == 'craftsman' 
                              ? 'Usta hesabınızla giriş yapın'
                              : 'Müşteri hesabınızla giriş yapın',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.textWhite.withOpacity(0.2)),
                      boxShadow: [AppColors.getCardShadow()],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: '📧 E-posta',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(Icons.email_rounded, color: AppColors.uclaBlue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E-posta gerekli';
                        }
                        if (!value.contains('@')) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.textWhite.withOpacity(0.2)),
                      boxShadow: [AppColors.getCardShadow()],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: '🔒 Şifre',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                                                  prefixIcon: Icon(Icons.lock_rounded, color: AppColors.uclaBlue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre gerekli';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.getGradient(AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [AppColors.getElevatedShadow()],
                    ),
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Register Link
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Hesabınız yok mu?',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.textWhite.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.textWhite.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context, 
                                '/register',
                                arguments: widget.userType,
                              );
                            },
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Test Credentials
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textWhite.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🧪 Test Hesapları',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.userType == 'craftsman' 
                              ? 'E-posta: ahmet@test.com\nŞifre: 123456'
                              : 'E-posta: customer@test.com\nŞifre: 123456',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authNotifier = ref.read(authProvider.notifier);
        
        print('Login attempt - User type: ${widget.userType}');
        print('📧 Email: ${_emailController.text}');
        
        // Login with auth provider
        final success = await authNotifier.login(
          _emailController.text,
          _passwordController.text,
          userType: widget.userType,
        );
        
        if (success && mounted) {
          print('✅ Login successful, navigating to dashboard');
          // Navigate to appropriate dashboard
          if (widget.userType == 'craftsman') {
            Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/customer-dashboard');
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Giriş başarısız'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        print('❌ Login error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Giriş başarısız: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}