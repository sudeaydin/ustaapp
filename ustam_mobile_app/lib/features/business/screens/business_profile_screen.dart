import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../../auth/providers/auth_provider.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _websiteController = TextEditingController();
  final _responseTimeController = TextEditingController();
  
  String _selectedCity = '';
  String _selectedDistrict = '';
  List<String> _selectedSkills = [];
  List<String> _selectedServiceAreas = [];
  List<String> _portfolioImages = [];
  bool _isLoading = false;
  bool _isUploading = false;
  int _currentIndex = 1; // Business profile is second tab for craftsman
  final ImagePicker _picker = ImagePicker();

  final List<String> _cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya'];
  final List<String> _districts = ['Kadıköy', 'Ataşehir', 'Üsküdar', 'Beşiktaş', 'Şişli'];
  final List<String> _availableSkills = [
    'Temizlik', 'Marangoz', 'Elektrik', 'Tesisat', 'Boya', 'Bahçe', 'Taşıma',
    'Mobilya Montajı', 'Tamir', 'Bakım', 'Kurulum', 'Demontaj', 'Restorasyon'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    // Load existing profile data
    _businessNameController.text = 'Özkan Marangoz';
    _descriptionController.text = '10 yıllık deneyimim ile ahşap işleri, mobilya yapımı ve restorasyon konularında uzman hizmet veriyorum.';
    _hourlyRateController.text = '180';
    _experienceController.text = '10';
    _websiteController.text = 'www.ozkanmarangoz.com';
    _responseTimeController.text = '4 saat';
    _selectedCity = 'İstanbul';
    _selectedDistrict = 'Üsküdar';
    _selectedSkills = ['Mobilya Yapımı', 'Ahşap Restorasyon', 'Dekoratif İşler'];
    _selectedServiceAreas = ['Üsküdar', 'Kadıköy', 'Ataşehir'];
    
    // Load portfolio images
    await _loadPortfolioImages();
  }

  Future<void> _loadPortfolioImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data']['craftsman_profile']?['portfolio_images'] != null) {
          final portfolioImagesJson = data['data']['craftsman_profile']['portfolio_images'];
          if (portfolioImagesJson != null && portfolioImagesJson.isNotEmpty) {
            final List<dynamic> imagesList = json.decode(portfolioImagesJson);
            setState(() {
              _portfolioImages = imagesList.cast<String>();
            });
          }
        }
      }
    } catch (e) {
      print('Portfolio görselleri yüklenemedi: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image == null) return;
      
      // Check file size (max 5MB)
      final file = File(image.path);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showSnackBar('Dosya boyutu 5MB\'dan küçük olmalıdır', Colors.red);
        return;
      }
      
      setState(() {
        _isUploading = true;
      });
      
      await _uploadImage(file);
      
    } catch (e) {
      _showSnackBar('Görsel seçme hatası: $e', Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) {
        _showSnackBar('Oturum süresi dolmuş, lütfen tekrar giriş yapın', Colors.red);
        return;
      }
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/auth/upload-portfolio-image'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200 && data['success']) {
        final List<dynamic> imagesList = data['portfolio_images'];
        setState(() {
          _portfolioImages = imagesList.cast<String>();
        });
        _showSnackBar('Görsel başarıyla yüklendi!', const Color(0xFF10B981));
      } else {
        _showSnackBar(data['message'] ?? 'Görsel yükleme başarısız oldu', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Görsel yükleme hatası: $e', Colors.red);
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görseli Sil'),
        content: const Text('Bu görseli silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      if (token == null) {
        _showSnackBar('Oturum süresi dolmuş, lütfen tekrar giriş yapın', Colors.red);
        return;
      }
      
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/auth/delete-portfolio-image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'image_url': imageUrl}),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        final List<dynamic> imagesList = data['portfolio_images'];
        setState(() {
          _portfolioImages = imagesList.cast<String>();
        });
        _showSnackBar('Görsel başarıyla silindi!', const Color(0xFF10B981));
      } else {
        _showSnackBar(data['message'] ?? 'Görsel silme başarısız oldu', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Görsel silme hatası: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button
        title: const Text(
          'İşletmem',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Kaydet',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Stats Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF1E40AF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İşletme İstatistikleri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('Tamamlanan İş', '127'),
                          ),
                          Expanded(
                            child: _buildStatItem('Ortalama Puan', '4.8'),
                          ),
                          Expanded(
                            child: _buildStatItem('Müşteri Memnuniyeti', '%98'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Business Details Section
                const Text(
                  'İşletme Detayları',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _businessNameController,
                  label: 'İşletme Adı',
                  hint: 'İşletme adınızı girin',
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _descriptionController,
                  label: 'İşletme Açıklaması',
                  hint: 'İşletmeniz hakkında bilgi verin',
                  maxLines: 3,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _hourlyRateController,
                  label: 'Saatlik Ücret (₺)',
                  hint: 'Saatlik ücretinizi girin',
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _experienceController,
                  label: 'Deneyim (Yıl)',
                  hint: 'Deneyim yılınızı girin',
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 32),
                
                // Location Section
                const Text(
                  'Konum Bilgileri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildDropdownField(
                  label: 'Şehir',
                  value: _selectedCity,
                  items: _cities,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value ?? '';
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildDropdownField(
                  label: 'İlçe',
                  value: _selectedDistrict,
                  items: _districts,
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value ?? '';
                    });
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Skills Section
                const Text(
                  'Yetenekler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSkills.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSkills.add(skill);
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFEFF6FF),
                      checkmarkColor: const Color(0xFF3B82F6),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Portfolio Images Section
                const Text(
                  'İşletme Portföy Görselleri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 İpucu:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'İşletmenize ait görselleri, tamamladığınız işleri ve çalışma alanınızı gösteren fotoğrafları yükleyebilirsiniz.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Maksimum 10 görsel yükleyebilirsiniz\n• Desteklenen formatlar: JPG, PNG\n• Maksimum dosya boyutu: 5MB',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                    icon: _isUploading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_a_photo, color: Colors.white),
                    label: Text(
                      _isUploading ? 'Yükleniyor...' : 'Görsel Ekle',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Portfolio Images Grid
                _portfolioImages.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _portfolioImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage('http://localhost:5000${_portfolioImages[index]}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _deleteImage(_portfolioImages[index]),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Henüz portfolyo görseli eklenmemiş',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                
                const SizedBox(height: 32),
                
                // Contact Information
                const Text(
                  'İletişim Bilgileri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _websiteController,
                  label: 'Website',
                  hint: 'Website adresinizi girin',
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _responseTimeController,
                  label: 'Yanıt Süresi',
                  hint: 'Ortalama yanıt sürenizi girin',
                ),
                
                const SizedBox(height: 100), // Extra padding for bottom navigation
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/craftsman-dashboard');
              break;
            case 1:
              // Already on business profile
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/messages');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'İşletmem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            hint: Text('$label seçiniz'),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Save profile logic here
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil başarıyla güncellendi!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
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