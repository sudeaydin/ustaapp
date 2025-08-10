import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/app_colors.dart';

class QuoteFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> craftsman;
  
  const QuoteFormScreen({super.key, required this.craftsman});

  @override
  ConsumerState<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends ConsumerState<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = '';
  String _selectedAreaType = '';
  String _selectedBudgetRange = '';
  final _squareMetersController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  bool _isLoading = false;

  final List<String> _categories = [
    'Elektrikçi',
    'Tesisatçı',
    'Boyacı',
    'Marangoz',
    'Cam Ustası',
    'Klima Teknisyeni',
    'Temizlik',
    'Taşıma',
    'Diğer'
  ];

  final List<Map<String, String>> _areaTypes = [
    {'value': 'salon', 'label': 'Salon'},
    {'value': 'mutfak', 'label': 'Mutfak'},
    {'value': 'yatak_odası', 'label': 'Yatak Odası'},
    {'value': 'banyo', 'label': 'Banyo'},
    {'value': 'balkon', 'label': 'Balkon'},
    {'value': 'bahçe', 'label': 'Bahçe'},
    {'value': 'ofis', 'label': 'Ofis'},
    {'value': 'diger', 'label': 'Diğer'}
  ];

  final List<Map<String, String>> _budgetRanges = [
    {'value': '0-1000', 'label': '0 - 1.000 TL'},
    {'value': '1000-2000', 'label': '1.000 - 2.000 TL'},
    {'value': '2000-5000', 'label': '2.000 - 5.000 TL'},
    {'value': '5000-10000', 'label': '5.000 - 10.000 TL'},
    {'value': '10000-20000', 'label': '10.000 - 20.000 TL'},
    {'value': '20000+', 'label': '20.000+ TL'}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Teklif Al',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Craftsman Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.nonPhotoBlue.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.craftsman['avatar'] ?? 'https://picsum.photos/400/400?random=1',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.craftsman['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.craftsman['business_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Form Title
                const Text(
                  'İş Detayları',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category Selection
                _buildDropdownField(
                  label: 'İş Kategorisi *',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kategori seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Area Type Selection
                _buildDropdownFieldWithMap(
                  label: 'Çalışılacak Alan *',
                  value: _selectedAreaType,
                  items: _areaTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedAreaType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alan türü seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Square Meters (Optional)
                _buildTextField(
                  label: 'Metrekare (Opsiyonel)',
                  controller: _squareMetersController,
                  keyboardType: TextInputType.number,
                  validator: null,
                ),
                
                const SizedBox(height: 16),
                
                // Budget Range Selection
                _buildDropdownFieldWithMap(
                  label: 'Bütçe Aralığı *',
                  value: _selectedBudgetRange,
                  items: _budgetRanges,
                  onChanged: (value) {
                    setState(() {
                      _selectedBudgetRange = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bütçe aralığı seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description
                _buildTextField(
                  label: 'İş Açıklaması *',
                  controller: _descriptionController,
                  maxLines: 4,
                  hint: 'Yaptırmak istediğiniz işi detaylı olarak açıklayın...',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İş açıklaması gerekli';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Additional Details
                _buildTextField(
                  label: 'Ek Detaylar (Opsiyonel)',
                  controller: _additionalDetailsController,
                  maxLines: 3,
                  hint: 'Varsa ek bilgiler, özel istekler...',
                  validator: null,
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitQuote,
                    style: AppColors.getPrimaryButtonStyle().copyWith(
                      minimumSize: MaterialStateProperty.all(const Size(double.infinity, 56)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Teklif Gönder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.nonPhotoBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
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
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.nonPhotoBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
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
              hintStyle: TextStyle(color: AppColors.textMuted),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  void _submitQuote() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory.isEmpty || _selectedAreaType.isEmpty || _selectedBudgetRange.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen zorunlu alanları doldurun'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');
        
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/quote-requests/request'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'craftsman_id': widget.craftsman['id'],
            'category': _selectedCategory,
            'area_type': _selectedAreaType,
            'square_meters': _squareMetersController.text.isNotEmpty 
                ? int.tryParse(_squareMetersController.text) 
                : null,
            'budget_range': _selectedBudgetRange,
            'description': _descriptionController.text,
            'additional_details': _additionalDetailsController.text.isNotEmpty 
                ? _additionalDetailsController.text 
                : null,
          }),
        );

        final data = json.decode(response.body);
        
        if (mounted) {
          if (data['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Teklif talebiniz başarıyla gönderildi!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushReplacementNamed(context, '/messages');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Teklif talebi gönderilirken bir hata oluştu'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teklif talebi gönderilirken bir hata oluştu'),
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

  Widget _buildDropdownFieldWithMap({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.nonPhotoBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
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
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }
}