import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  Future<void> _loadProfile() async {
    try {
      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) {
        print('No auth token found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/profile/'),
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
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              // Navigate to appropriate dashboard based on user type
              if (_profileData?['user_type'] == 'craftsman') {
                Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
              } else {
                Navigator.pushReplacementNamed(context, '/customer-dashboard');
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
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: _profileData?['user_type'] == 'craftsman' ? 'İşletmem' : 'Arama',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mesajlar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }
}