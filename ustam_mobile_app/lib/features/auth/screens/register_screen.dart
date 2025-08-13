import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_input.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/analytics_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String userType;
  
  const RegisterScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreementAccepted = false;
  String? _taxDocumentPath;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _pickTaxDocument() async {
    // TODO: Implement file picker for tax document
    setState(() {
      _taxDocumentPath = 'tax_document.pdf'; // Mock for now
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vergi levhası seçildi'),
        backgroundColor: DesignTokens.success,
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreementAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı sözleşmesini kabul etmelisiniz'),
          backgroundColor: DesignTokens.error,
        ),
      );
      return;
    }

    if (widget.userType == 'craftsman' && _taxDocumentPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vergi levhası yüklemelisiniz'),
          backgroundColor: DesignTokens.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Track registration attempt
      await AnalyticsService.getInstance().trackBusinessEvent('registration_attempt', {
        'user_type': widget.userType,
      });

      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        userType: widget.userType,
      );

      if (success && mounted) {
        // Track successful registration
        await AnalyticsService.getInstance().trackBusinessEvent('registration_success', {
          'user_type': widget.userType,
        });

        // Navigate to appropriate dashboard
        final route = widget.userType == 'customer' 
            ? '/customer-dashboard' 
            : '/craftsman-dashboard';
        
        Navigator.pushReplacementNamed(context, route);
      }
    } catch (e) {
      // Track registration failure
      await AnalyticsService.getInstance().trackBusinessEvent('registration_failure', {
        'user_type': widget.userType,
        'error': e.toString(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
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
  }

  Widget _buildRegisterButton(Locale locale) {
    return InkWell(
      onTap: _isLoading ? null : () {
        print('🔥 Register button tapped!'); // Debug print
        _handleRegister();
      },
      borderRadius: BorderRadius.circular(DesignTokens.radius12),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: DesignTokens.primaryCoralGradient,
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                )
              : Text(
                  'register'.tr(locale),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final locale = ref.watch(languageProvider);

    if (authState?.isAuthenticated == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = widget.userType == 'customer' 
            ? '/customer-dashboard' 
            : '/craftsman-dashboard';
        Navigator.pushReplacementNamed(context, route);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: DesignTokens.getGradient(
            DesignTokens.primaryCoralGradient,
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
                  
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
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
                                borderRadius: BorderRadius.circular(DesignTokens.radius12),
                              ),
                              child: Icon(
                                widget.userType == 'customer' ? Icons.person : Icons.build,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: DesignTokens.space16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'register_title'.tr(locale),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.userType == 'customer' ? 'customer'.tr(locale) : 'craftsman'.tr(locale),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Form Fields
                  // First Name
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'first_name'.tr(locale),
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'first_name'.tr(locale) + ' gerekli';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Last Name
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'last_name'.tr(locale),
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'last_name'.tr(locale) + ' gerekli';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Email
                  CustomTextField(
                    controller: _emailController,
                    label: 'email'.tr(locale),
                    prefixIcon: const Icon(Icons.email_outlined),
                    type: TextFieldType.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'email'.tr(locale) + ' gerekli';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Phone
                  CustomTextField(
                    controller: _phoneController,
                    label: 'phone'.tr(locale),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    type: TextFieldType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'phone'.tr(locale) + ' gerekli';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    label: 'password'.tr(locale),
                    prefixIcon: const Icon(Icons.lock_outline),
                    type: TextFieldType.password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'password'.tr(locale) + ' gerekli';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  // Confirm Password
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'confirm_password'.tr(locale),
                    prefixIcon: const Icon(Icons.lock_outline),
                    type: TextFieldType.password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'confirm_password'.tr(locale) + ' gerekli';
                      }
                      if (value != _passwordController.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Tax Document Upload (only for craftsman)
                  if (widget.userType == 'craftsman') ...[
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.space16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radius12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vergi Levhası (Zorunlu)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickTaxDocument,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(DesignTokens.space16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(DesignTokens.radius8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _taxDocumentPath != null 
                                        ? Icons.check_circle_outline 
                                        : Icons.upload_file_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _taxDocumentPath != null 
                                          ? 'Vergi levhası seçildi' 
                                          : 'Vergi levhası yüklemek için tıklayın',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space24),
                  ],
                  
                  // User Agreement Checkbox
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radius12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreementAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              _agreementAccepted = value ?? false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: DesignTokens.primaryCoral,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/legal');
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Kabul ediyorum: '),
                                    TextSpan(
                                      text: 'Kullanıcı Sözleşmesi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ', '),
                                    TextSpan(
                                      text: 'Gizlilik Politikası',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' ve '),
                                    TextSpan(
                                      text: 'KVKK Aydınlatma Metni',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignTokens.radius12),
                      boxShadow: [DesignTokens.getElevatedShadow()],
                    ),
                    child: _buildRegisterButton(locale),
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  // Login Link
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'already_have_account'.tr(locale),
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
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'login'.tr(locale),
                              style: const TextStyle(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}