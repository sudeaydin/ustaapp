import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/legal_utils.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Widget that checks if user has accepted mandatory agreements
/// and shows the agreement modal if needed
class LegalComplianceChecker extends ConsumerStatefulWidget {
  final Widget child;

  const LegalComplianceChecker({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<LegalComplianceChecker> createState() => _LegalComplianceCheckerState();
}

class _LegalComplianceCheckerState extends ConsumerState<LegalComplianceChecker> {
  bool _isChecking = false;
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    // Delay the check to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLegalCompliance();
    });
  }

  @override
  void didUpdateWidget(LegalComplianceChecker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check again if user state changed
    final currentUser = ref.read(authProvider);
    if (currentUser.user != null && !_hasChecked) {
      _checkLegalCompliance();
    }
  }

  Future<void> _checkLegalCompliance() async {
    final authState = ref.read(authProvider);
    
    // Only check for logged-in users
    if (authState.user == null || _isChecking || _hasChecked) {
      return;
    }

    setState(() => _isChecking = true);

    try {
      final hasConsents = await LegalManager().hasMandatoryConsents();
      
      if (!hasConsents && mounted) {
        await _showUserAgreementModal();
      }
      
      setState(() => _hasChecked = true);
    } catch (e) {
      debugPrint('Error checking legal compliance: $e');
      // On error, assume user needs to accept agreements
      if (mounted) {
        await _showUserAgreementModal();
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _showUserAgreementModal() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UserAgreementModal(),
    );

    if (result != true) {
      // User rejected agreement - log them out
      await _handleRejection();
    } else {
      setState(() => _hasChecked = true);
    }
  }

  Future<void> _handleRejection() async {
    // Clear auth data
    ref.read(authProvider.notifier).logout();
    
    // Navigate to welcome screen
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/welcome',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: DesignTokens.space16),
              Text(
                'Yasal uygunluk kontrol ediliyor...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Cookie consent banner widget for Flutter
class CookieConsentBanner extends StatefulWidget {
  const CookieConsentBanner({Key? key}) : super(key: key);

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<CookieConsentBanner> {
  bool _showBanner = false;
  bool _isLoading = true;
  static const String _cookieConsentKey = 'cookie_consent_given';

  @override
  void initState() {
    super.initState();
    _checkCookieConsent();
  }

  Future<void> _checkCookieConsent() async {
    try {
      // Check local storage first
      final prefs = await SharedPreferences.getInstance();
      final localConsent = prefs.getBool(_cookieConsentKey);
      
      if (localConsent == true) {
        setState(() {
          _showBanner = false;
          _isLoading = false;
        });
        return;
      }

      // Check backend consents
      try {
        final consentsResponse = await LegalManager().getUserConsents();
        final cookieConsent = consentsResponse
            .where((c) => c.type == ConsentType.cookies)
            .lastOrNull;
        
        if (cookieConsent != null) {
          // Sync with local storage
          await prefs.setBool(_cookieConsentKey, cookieConsent.granted);
          setState(() {
            _showBanner = false;
            _isLoading = false;
          });
        } else {
          // No cookie consent found, show banner
          setState(() {
            _showBanner = true;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Backend error, check local storage only
        setState(() {
          _showBanner = localConsent != true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking cookie consent: $e');
      setState(() {
        _showBanner = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cookieConsentKey, true);
      await LegalManager().recordConsent(ConsentType.cookies, true);
      
      setState(() => _showBanner = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çerez tercihleri kaydedildi'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _rejectCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cookieConsentKey, true);
      await LegalManager().recordConsent(ConsentType.cookies, false);
      
      setState(() => _showBanner = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çerez kullanımı reddedildi'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _showCookiePreferences() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ConsentPreferencesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (!_showBanner) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(DesignTokens.space16),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cookie,
                  color: const Color(0xFF467599),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bu uygulama çerezler kullanır',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Deneyiminizi iyileştirmek için çerezler kullanıyoruz. '
              'Devam ederek çerez kullanımını kabul etmiş olursunuz.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: DesignTokens.space16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _rejectCookies,
                    child: const Text('Reddet'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showCookiePreferences,
                    child: const Text('Özelleştir'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptCookies,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF467599),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kabul Et'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}