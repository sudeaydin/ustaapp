import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/design_tokens.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/consent_preferences_sheet.dart';
import '../../../core/widgets/gdpr_rights_sheet.dart';
import '../../../core/widgets/common_bottom_navigation.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  int _currentIndex = 3; // Profile is fourth tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _navigateToCorrectDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('user_type');
      
      print('Checking user type from SharedPreferences: $userType');
      
      if (userType == 'craftsman') {
        print('✅ Navigating to craftsman dashboard');
        Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
      } else if (userType == 'customer') {
        print('✅ Navigating to customer dashboard');
        Navigator.pushReplacementNamed(context, '/customer-dashboard');
      } else {
        print('⚠️ No user type found, defaulting to customer dashboard');
        // Default fallback to customer dashboard
        Navigator.pushReplacementNamed(context, '/customer-dashboard');
      }
    } catch (e) {
      print('❌ Error navigating to dashboard: $e');
      // Default fallback
      Navigator.pushReplacementNamed(context, '/customer-dashboard');
    }
  }

  Future<void> _loadProfile() async {
    try {
      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) {
        print('No auth token found');
        // Even without token, try to get user type for navigation
        final userType = prefs.getString('user_type');
        print('User type from SharedPreferences: $userType');
        
        setState(() {
          _isLoading = false;
          // Set minimal profile data for navigation to work
          _profileData = {
            'user_type': userType ?? 'customer',
            'first_name': 'Kullanıcı',
            'last_name': '',
            'email': 'Bilinmiyor'
          };
        });
        return;
      }

      final response = await http.get(
        Uri.parse(AppConfig.profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('Profile API Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _profileData = data['data'];
            _isLoading = false;
          });
        } else {
          print('API Error: ${data['message']}');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radius16),
        border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignTokens.primaryCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radius12),
              ),
              child: Icon(icon, size: 20, color: DesignTokens.primaryCoral),
            ),
            const SizedBox(width: DesignTokens.space16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: DesignTokens.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radius16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          decoration: BoxDecoration(
                color: color ?? Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radius16),
                border: Border.all(color: DesignTokens.primaryCoral.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color != null ? Colors.white.withOpacity(0.2) : DesignTokens.primaryCoral.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radius12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color != null ? Colors.white : DesignTokens.primaryCoral,
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color != null ? Colors.white : DesignTokens.gray900,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color != null ? Colors.white : DesignTokens.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
                SizedBox(height: DesignTokens.space24),
                Text(
                  'Profil yükleniyor...',
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

    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      body: CustomScrollView(
        slivers: [
          // App Bar for customers
          if (_profileData?['user_type'] != 'craftsman')
            SliverAppBar(
              title: const Text(
                'Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: DesignTokens.primaryCoral,
              elevation: 0,
              automaticallyImplyLeading: true,
              pinned: true,
              floating: false,
            ),
          // Modern App Bar - Figma Design (sadece craftsman için)
          if (_profileData?['user_type'] == 'craftsman')
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: DesignTokens.surfacePrimary,
              elevation: 0,
              automaticallyImplyLeading: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DesignTokens.primaryCoral,
                        DesignTokens.primaryCoral,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          // Avatar - Figma Style (sadece craftsman için)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: DesignTokens.surfacePrimary, width: 4),
                              image: _profileData?['avatar'] != null && 
                                     _profileData!['avatar'].toString().isNotEmpty && 
                                     _profileData!['avatar'].toString() != 'null'
                                  ? DecorationImage(
                                      image: NetworkImage(_profileData!['avatar']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileData?['avatar'] == null || 
                                    _profileData!['avatar'].toString().isEmpty ||
                                    _profileData!['avatar'].toString() == 'null'
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: DesignTokens.surfacePrimary,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_profileData?['first_name'] ?? ''} ${_profileData?['last_name'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.surfacePrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profileData?['email'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: DesignTokens.surfacePrimary70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: DesignTokens.surfacePrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: DesignTokens.surfacePrimary.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'Usta',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.surfacePrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit, color: DesignTokens.surfacePrimary),
                  onPressed: () {
                    // Navigate to edit profile
                  },
                ),
              ],
            ),

          // Profile Content - Figma Design
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Section
                  const Text(
                    'Kişisel Bilgiler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  _buildInfoRow('Telefon', _profileData?['phone'] ?? 'Belirtilmemiş', icon: Icons.phone),
                  const SizedBox(height: 12),
                  _buildInfoRow('E-posta', _profileData?['email'] ?? 'Belirtilmemiş', icon: Icons.email),

                  // Craftsman Specific Info
                  if (_profileData?['user_type'] == 'craftsman' && _profileData?['profile'] != null) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'İşletme Bilgileri',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    _buildInfoRow('İşletme Adı', _profileData!['profile']['business_name'] ?? 'Belirtilmemiş', icon: Icons.business),
                    const SizedBox(height: 12),
                    _buildInfoRow('Şehir', _profileData!['profile']['city'] ?? 'Belirtilmemiş', icon: Icons.location_on),
                    const SizedBox(height: 12),
                    _buildInfoRow('İlçe', _profileData!['profile']['district'] ?? 'Belirtilmemiş', icon: Icons.location_city),
                    const SizedBox(height: 12),
                    _buildInfoRow('Saatlik Ücret', '${_profileData!['profile']['hourly_rate'] ?? 0}₺', icon: Icons.attach_money),
                    const SizedBox(height: 12),
                    _buildInfoRow('Deneyim', '${_profileData!['profile']['experience_years'] ?? 0} yıl', icon: Icons.work),

                    // Skills Section - Figma Style
                    if (_profileData!['profile']['skills'] != null && (_profileData!['profile']['skills'] as List).isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Yetenekler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.gray900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: DesignTokens.surfacePrimary,
                          borderRadius: BorderRadius.circular(DesignTokens.radius16),
                          border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: DesignTokens.shadowLight,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: (_profileData!['profile']['skills'] as List).map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: DesignTokens.primaryCoral.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: DesignTokens.primaryCoral),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.psychology,
                                    size: 16,
                                    color: DesignTokens.primaryCoral,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    skill.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: DesignTokens.primaryCoral,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],

                  // Customer Specific Info
                  if (_profileData?['user_type'] == 'customer' && _profileData?['profile'] != null) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Adres Bilgileri',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    _buildInfoRow('Adres', _profileData!['profile']['address'] ?? 'Belirtilmemiş', icon: Icons.home),
                    const SizedBox(height: 12),
                    _buildInfoRow('Şehir', _profileData!['profile']['city'] ?? 'Belirtilmemiş', icon: Icons.location_on),
                    const SizedBox(height: 12),
                    _buildInfoRow('İlçe', _profileData!['profile']['district'] ?? 'Belirtilmemiş', icon: Icons.location_city),
                  ],

                  // Action Buttons - Figma Style
                  const SizedBox(height: 40),
                  const Text(
                    'Hesap Ayarları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  _buildActionButton(
                    'Profili Düzenle',
                    Icons.edit,
                    () {
                      // Navigate to edit profile
                    },
                  ),
                  _buildActionButton(
                    'Şifre Değiştir',
                    Icons.lock,
                    () {
                      // Navigate to change password
                    },
                  ),
                  _buildActionButton(
                    'Yasal Belgeler',
                    Icons.gavel,
                    () {
                      Navigator.pushNamed(context, '/legal');
                    },
                  ),
                  _buildActionButton(
                    'Onay Tercihleri',
                    Icons.settings,
                    () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const ConsentPreferencesSheet(),
                      );
                    },
                  ),
                  _buildActionButton(
                    'KVKK Hakları',
                    Icons.privacy_tip,
                    () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const GDPRRightsSheet(),
                      );
                    },
                  ),
                  _buildActionButton(
                    'Hesabımı Sil',
                    Icons.delete_forever,
                    () {
                      _showDeleteAccountDialog();
                    },
                    color: DesignTokens.error,
                  ),
                  _buildActionButton(
                    'Çıkış Yap',
                    Icons.logout,
                    () async {
                      // Clear auth data and navigate to welcome
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('authToken');
                      await prefs.remove('user');
                      await prefs.remove('user_type');
                      await prefs.remove('userId');
                      await prefs.remove('userEmail');
                      await prefs.remove('userName');
                      
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          '/welcome', 
                          (route) => false
                        );
                      }
                    },
                    color: DesignTokens.error,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        userType: _profileData?['user_type'] ?? 'customer',
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String confirmText = '';
        bool isDeleting = false;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: DesignTokens.error, size: 28),
                  SizedBox(width: 8),
                  Text('Hesabımı Sil'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KVKK Uyarısı - Önemli Bilgilendirme:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Hesabınız kalıcı olarak silinecektir\n'
                    '• Tüm kişisel verileriniz sistemden kaldırılacaktır\n'
                    '• Mesaj geçmişiniz silinecektir\n'
                    '• Ödeme geçmişiniz silinecektir\n'
                    '• Bu işlem geri alınamaz',
                    style: TextStyle(fontSize: 12, color: DesignTokens.error),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  const Text(
                    'Hesabınızın kalıcı olarak silinmesini onaylıyor musunuz?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Onaylamak için "HESABIMI SIL" yazın:',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) {
                      confirmText = value;
                    },
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'HESABIMI SIL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: isDeleting ? null : () async {
                    if (confirmText != 'HESABIMI SIL') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen "HESABIMI SIL" yazarak onaylayın'),
                          backgroundColor: DesignTokens.error,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      isDeleting = true;
                    });

                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('authToken');
                      
                      final response = await http.delete(
                        Uri.parse(AppConfig.deleteAccountUrl),
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        },
                      );

                      final data = json.decode(response.body);

                      if (data['success'] == true) {
                        // Clear all data
                        await prefs.clear();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hesabınız başarıyla silindi. Güle güle!'),
                              backgroundColor: DesignTokens.success,
                            ),
                          );
                          
                          Navigator.pushNamedAndRemoveUntil(
                            context, 
                            '/welcome', 
                            (route) => false
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(data['message'] ?? 'Hesap silme işlemi başarısız oldu'),
                              backgroundColor: DesignTokens.error,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hesap silme işlemi sırasında bir hata oluştu'),
                            backgroundColor: DesignTokens.error,
                          ),
                        );
                      }
                    } finally {
                      setState(() {
                        isDeleting = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.error,
                    foregroundColor: Colors.white,
                  ),
                  child: isDeleting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Hesabımı Sil'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}