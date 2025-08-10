import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/app_colors.dart';

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
      
      print('🔍 Checking user type from SharedPreferences: $userType');
      
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
        print('🔍 User type from SharedPreferences: $userType');
        
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
        Uri.parse('http://localhost:5000/api/auth/profile'),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E293B),
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
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
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
                    color: color != null ? Colors.white.withOpacity(0.2) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color != null ? Colors.white : const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color != null ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color != null ? Colors.white : const Color(0xFF94A3B8),
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
                  '✨ Profil yükleniyor...',
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar - Figma Design (sadece craftsman için)
          if (_profileData?['user_type'] == 'craftsman')
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF1E40AF),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Avatar - Figma Style (sadece craftsman için)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.white, width: 4),
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
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_profileData?['first_name'] ?? ''} ${_profileData?['last_name'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profileData?['email'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'Usta',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
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
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
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
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFDBEAFE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.psychology,
                                    size: 16,
                                    color: Color(0xFF1E40AF),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    skill.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E40AF),
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
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    'Hesabımı Sil',
                    Icons.delete_forever,
                    () {
                      _showDeleteAccountDialog();
                    },
                    color: const Color(0xFFEF4444),
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
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getGradient([
            _profileData?['user_type'] == 'craftsman' ? AppColors.accentYellow : AppColors.primaryPurple,
            (_profileData?['user_type'] == 'craftsman' ? AppColors.accentYellow : AppColors.primaryPurple).withOpacity(0.9),
          ]),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [AppColors.getElevatedShadow()],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                // Navigate to appropriate dashboard based on user type
                print('🏠 Ana Sayfa tıklandı - User type: ${_profileData?['user_type']}');
                
                if (_profileData?['user_type'] == 'craftsman') {
                  print('✅ Craftsman dashboard\'a yönlendiriliyor');
                  Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
                } else if (_profileData?['user_type'] == 'customer') {
                  print('✅ Customer dashboard\'a yönlendiriliyor');
                  Navigator.pushReplacementNamed(context, '/customer-dashboard');
                } else {
                  print('⚠️ Profile data\'da user type bulunamadı, SharedPreferences kontrol ediliyor');
                  // Fallback - check user type from SharedPreferences
                  _navigateToCorrectDashboard();
                }
                break;
              case 1:
                if (_profileData?['user_type'] == 'craftsman') {
                  Navigator.pushReplacementNamed(context, '/business-profile');
                } else {
                  Navigator.pushReplacementNamed(context, '/search');
                }
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/messages');
                break;
              case 3:
                // Already on profile
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.textWhite,
          unselectedItemColor: AppColors.textWhite.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded, size: 28),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(_profileData?['user_type'] == 'craftsman' ? Icons.business_rounded : Icons.search_rounded),
              activeIcon: Icon(_profileData?['user_type'] == 'craftsman' ? Icons.business_rounded : Icons.search_rounded, size: 28),
              label: _profileData?['user_type'] == 'craftsman' ? 'İşletmem' : 'Arama',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded, size: 28),
              label: 'Mesajlar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded, size: 28),
              label: 'Profilim',
            ),
          ],
        ),
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
                  Icon(Icons.warning, color: Colors.red, size: 28),
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
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Hesabınız kalıcı olarak silinecektir\n'
                    '• Tüm kişisel verileriniz sistemden kaldırılacaktır\n'
                    '• Mesaj geçmişiniz silinecektir\n'
                    '• Ödeme geçmişiniz silinecektir\n'
                    '• Bu işlem geri alınamaz',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
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
                          backgroundColor: Colors.red,
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
                        Uri.parse('http://localhost:5000/api/auth/delete-account'),
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
                              backgroundColor: Colors.green,
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
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hesap silme işlemi sırasında bir hata oluştu'),
                            backgroundColor: Colors.red,
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
                    backgroundColor: Colors.red,
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