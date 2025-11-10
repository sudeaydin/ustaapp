import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_input.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/analytics_service.dart';

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
  // bool _obscurePassword = true; // Unused field
  DateTime? _lastLoginAttempt;

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
        backgroundColor: DesignTokens.surfacePrimary,
        body: Container(
          decoration: BoxDecoration(
            gradient: DesignTokens.primaryCoralGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
                const SizedBox(height: DesignTokens.space24),
                Text(
                  'Giriş yapılıyor...',
                  style: TextStyle(
                    color: Colors.white,
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

    final locale = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // App Logo - Modern & Clean Design
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                DesignTokens.primaryCoral,
                                DesignTokens.primaryCoralDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: DesignTokens.primaryCoral.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.handyman_rounded,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'UstanBurada',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.gray900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Güvenilir Usta Bulma Platformu',
                          style: TextStyle(
                            fontSize: 14,
                            color: DesignTokens.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Header - Modern & Cartoon Style
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: const BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
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
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.userType == 'craftsman' ? 'Usta Girişi' : 'Müşteri Girişi',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: const BorderRadius.circular(DesignTokens.radius16),
                          ),
                          child: Text(
                            widget.userType == 'craftsman' 
                              ? 'Usta hesabınızla giriş yapın'
                              : 'Müşteri hesabınızla giriş yapın',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Email Field - Airbnb Style
                  AirbnbInput(
                    label: 'E-posta',
                    hintText: 'E-posta adresinizi girin',
                    controller: _emailController,
                    type: AirbnbInputType.email,
                    prefixIcon: Icons.email_outlined,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password Field - Airbnb Style
                  AirbnbInput(
                    label: 'Şifre',
                    hintText: 'Şifrenizi girin',
                    controller: _passwordController,
                    type: AirbnbInputType.password,
                    prefixIcon: Icons.lock_outlined,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button - Airbnb Style
                  AirbnbButton(
                    text: widget.userType == 'craftsman' ? 'Usta Olarak Giriş Yap' : 'Müşteri Olarak Giriş Yap',
                    onPressed: _isLoading ? null : _handleLogin,
                    type: AirbnbButtonType.primary,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: AirbnbButtonSize.large,
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Or Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      const Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                        child: Text(
                          'veya',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Google Sign-In Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.circular(DesignTokens.radius16),
                      boxShadow: [DesignTokens.getElevatedShadow()],
                    ),
                    child: _buildGoogleSignInButton(),
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Register Link
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'dont_have_account'.tr(locale),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: const BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
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
                            child: Text(
                              'register'.tr(locale),
                              style: TextStyle(
                                color: Colors.white,
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
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🧪 Test Hesapları',
                          style: TextStyle(
                            color: Colors.white,
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
                            color: Colors.white,
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
    );
  }

  Widget _buildLoginButton(Locale locale) {
    return InkWell(
      borderRadius: const BorderRadius.circular(DesignTokens.radius16),
      onTap: _isLoading ? null : () {
        debugPrint('🔥 Login button tapped!'); // Debug print
        _handleLogin();
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: DesignTokens.primaryCoralGradient,
          borderRadius: const BorderRadius.circular(DesignTokens.radius16),
          boxShadow: [DesignTokens.getElevatedShadow()],
        ),
        child: Center(
          child: _isLoading 
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                )
              : Text(
                  'login'.tr(locale),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.circular(DesignTokens.radius16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.circular(DesignTokens.radius16),
          onTap: _isLoading ? null : () {
            debugPrint('🔥 Google button tapped!'); // Debug print
            _handleGoogleSignIn();
          },
          child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google "G" logo with official colors
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4285F4), // Google Blue
                        Color(0xFFEA4335), // Google Red
                        Color(0xFFFBBC05), // Google Yellow
                        Color(0xFF34A853), // Google Green
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isLoading ? 'Google ile giriş yapılıyor...' : 'Google ile Giriş Yap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    letterSpacing: 0.25,
                  ),
                ),
                if (_isLoading) ...[
 SizedBox(width: 12),
 SizedBox(
                    width: 16,
                    height: 16,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
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

  void _handleLogin() async {
    debugPrint('🔥 _handleLogin called!'); // Debug print
    
    // Removed loading message per user request
    
    // Prevent multiple rapid taps
    final now = DateTime.now();
    if (_lastLoginAttempt != null && 
        now.difference(_lastLoginAttempt!).inMilliseconds < 2000) {
      debugPrint('🚫 Login blocked - too soon after last attempt');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('Lütfen bekleyin...'),
          duration: const Duration(seconds: 1),
          backgroundColor: DesignTokens.primaryCoral,
        ),
      );
      return;
    }
    
    _lastLoginAttempt = now;
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authNotifier = ref.read(authProvider.notifier);
        
        // Track login attempt
        AnalyticsService.getInstance().trackBusinessEvent('login_attempt', {
          'user_type': widget.userType,
          'email_domain': _emailController.text.split('@').length > 1 
              ? _emailController.text.split('@')[1] 
              : 'unknown',
        });
        
        debugPrint('Login attempt - User type: ${widget.userType}');
        debugPrint('📧 Email: ${_emailController.text}');
        
        // Login with auth provider
        final success = await authNotifier.login(
          _emailController.text,
          _passwordController.text,
          userType: widget.userType,
        );
        
        if (success && mounted) {
          debugPrint('✅ Login successful, navigating to dashboard');
          
          // Track successful login
          AnalyticsService.getInstance().trackBusinessEvent('login_success', {
            'user_type': widget.userType,
          });
          
          // Navigate to appropriate dashboard
          if (widget.userType == 'craftsman') {
            Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/customer-dashboard');
          }
        } else if (mounted) {
          // Track failed login
          AnalyticsService.getInstance().trackBusinessEvent('login_failed', {
            'user_type': widget.userType,
            'reason': 'invalid_credentials',
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: const Text('Giriş başarısız'),
              backgroundColor: DesignTokens.error,
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Login error: $e');
        
        // Track login error
        AnalyticsService.getInstance().trackError('login_error', e.toString(), {
          'user_type': widget.userType,
          'email': _emailController.text,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Giriş başarısız: $e'),
              backgroundColor: DesignTokens.error,
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
    } else {
      debugPrint('🚨 Form validation failed!'); // Debug print
    }
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('🔥 _handleGoogleSignIn called!'); // Debug print
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      
      // Track Google login attempt
      AnalyticsService.getInstance().trackBusinessEvent('google_login_attempt', {
        'user_type': widget.userType,
      });
      
      debugPrint('Google Sign-In attempt - User type: ${widget.userType}');
      
      final success = await authNotifier.signInWithGoogle(
        userType: widget.userType,
      );

      if (success && mounted) {
        debugPrint('✅ Google Sign-In successful, navigating to dashboard');
        
        // Track successful Google login
        AnalyticsService.getInstance().trackBusinessEvent('google_login_success', {
          'user_type': widget.userType,
        });

        final userType = ref.read(authProvider).userType;
        if (userType == 'customer') {
          Navigator.pushReplacementNamed(context, '/dashboard/customer');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard/craftsman');
        }
      } else {
        // Show error if available
        final authState = ref.read(authProvider);
        if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error!)),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      
      // Track failed Google login
      AnalyticsService.getInstance().trackBusinessEvent('google_login_failed', {
        'user_type': widget.userType,
        'error': e.toString(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: const Text('Google ile giriş sırasında hata oluştu')),
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