import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String userType) async {
    if (!_formKey.currentState!.validate()) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
      userType: userType,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 15,
                            offset: const Offset(-8, -8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.build_circle,
                                size: 40,
                                color: Colors.white,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'USTAM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hoş Geldiniz',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hesabınıza giriş yapın',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
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
                    
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
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
                    
                    const SizedBox(height: 24),
                    
                    // Error Message
                    if (authState.error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          authState.error!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    
                    // Şifremi Unuttum Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Şifre sıfırlama özelliği yakında eklenecek'),
                            ),
                          );
                        },
                        child: Text(
                          'Şifremi Unuttum',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Buttons
                    _buildLoginButton(
                      context: context,
                      title: 'BİREYSEL GİRİŞ',
                      subtitle: 'Müşteri olarak giriş yap',
                      icon: Icons.home_outlined,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E88E5), // Bright Blue
                          Color(0xFF42A5F5), // Light Blue
                          Color(0xFF64B5F6), // Lighter Blue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shadowColor: const Color(0xFF1E88E5),
                      onPressed: authState.isLoading ? null : () => _handleLogin('customer'),
                      isLoading: authState.isLoading,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildLoginButton(
                      context: context,
                      title: 'KURUMSAL GİRİŞ',
                      subtitle: 'Usta/Zanaatkar olarak giriş yap',
                      icon: Icons.build_circle_outlined,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF7043), // Bright Orange
                          Color(0xFFFF8A65), // Light Orange
                          Color(0xFFFFAB91), // Lighter Orange
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shadowColor: const Color(0xFFFF7043),
                      onPressed: authState.isLoading ? null : () => _handleLogin('craftsman'),
                      isLoading: authState.isLoading,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'veya',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Hesap Oluştur'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Demo Credentials
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Hesapları:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Müşteri: customer@example.com / password123',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Usta: craftsman@example.com / password123',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
          ),
        ),
    );
  }

  Widget _buildLoginButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required Color shadowColor,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => isPressed = true),
            onTapUp: (_) {
              setState(() => isPressed = false);
              // Mobile hover effect
              setState(() => isHovered = true);
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) setState(() => isHovered = false);
              });
            },
            onTapCancel: () => setState(() => isPressed = false),
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..scale(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0)),
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(isPressed ? 0.6 : (isHovered ? 0.4 : 0.3)),
                    blurRadius: isPressed ? 25 : (isHovered ? 20 : 15),
                    offset: Offset(0, isPressed ? 2 : (isHovered ? 8 : 6)),
                    spreadRadius: isPressed ? 0 : (isHovered ? 2 : 1),
                  ),
                  if (isHovered || isPressed) BoxShadow(
                    color: Colors.white.withOpacity(isPressed ? 0.9 : 0.7),
                    blurRadius: isPressed ? 20 : 15,
                    offset: Offset(isPressed ? -2 : -4, isPressed ? -2 : -4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(isPressed ? 0.4 : (isHovered ? 0.3 : 0.2)),
                  width: isPressed ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(isPressed ? 0.3 : (isHovered ? 0.25 : 0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: isPressed ? 0.9 : (isHovered ? 1.1 : 1.0),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isPressed ? 17 : (isHovered ? 16 : 15),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                      child: Text(title),
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: isPressed ? 13 : (isHovered ? 12 : 11),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      child: Text(subtitle),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: isPressed ? 0.05 : (isHovered ? -0.05 : 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}