import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/design_tokens.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/widgets.dart';

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
  String _selectedUrgencyLevel = 'normal';
  DateTime? _preferredStartDate;
  DateTime? _preferredEndDate;
  bool _isFlexibleDates = true;
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

  final List<Map<String, String>> _urgencyLevels = [
    {'value': 'normal', 'label': 'Normal'},
    {'value': 'urgent', 'label': 'Acil'},
    {'value': 'emergency', 'label': 'Acil Durum'}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CustomAppBar(
        title: 'Teklif Al',
        type: AppBarType.standard,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Craftsman Info Card
                Container(
                  padding: EdgeInsets.all(DesignTokens.space16),
                  decoration: BoxDecoration(
                    color: DesignTokens.surfacePrimary,
                    borderRadius: const BorderRadius.circular(DesignTokens.radius16),
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.circular(30),
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.craftsman['avatar'] ?? 'https://picsum.photos/400/400?random=1',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.craftsman['name'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: DesignTokens.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.craftsman['business_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: DesignTokens.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: DesignTokens.space24),
                
                // Form Title
                const Text(
                  'İş Detayları',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.gray900,
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                
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
                
                const SizedBox(height: DesignTokens.space16),
                
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
                
                const SizedBox(height: DesignTokens.space16),
                
                // Square Meters (Optional)
                _buildTextField(
                  label: 'Metrekare (Opsiyonel)',
                  controller: _squareMetersController,
                  keyboardType: TextInputType.number,
                  validator: null,
                ),
                
                const SizedBox(height: DesignTokens.space16),
                
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
                
                const SizedBox(height: DesignTokens.space16),
                
                // Urgency Level Selection
                _buildDropdownFieldWithMap(
                  label: 'Aciliyet Durumu *',
                  value: _selectedUrgencyLevel,
                  items: _urgencyLevels,
                  onChanged: (value) {
                    setState(() {
                      _selectedUrgencyLevel = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Aciliyet durumu seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: DesignTokens.space16),
                
                // Date Range Selection
                _buildDateRangeSection(),
                
                const SizedBox(height: DesignTokens.space16),
                
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
                
                const SizedBox(height: DesignTokens.space16),
                
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
                CustomButton(
                  text: 'Teklif Gönder',
                  onPressed: _submitQuote,
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                  isFullWidth: true,
                  isLoading: _isLoading,
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DesignTokens.gray900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: DesignTokens.surfacePrimary,
            borderRadius: const BorderRadius.circular(DesignTokens.radius12),
            border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(DesignTokens.space16),
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: DesignTokens.gray900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: DesignTokens.surfacePrimary,
            borderRadius: const BorderRadius.circular(DesignTokens.radius12),
            border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(
              color: DesignTokens.gray900,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: DesignTokens.textMuted,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(DesignTokens.space16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tercih Ettiğiniz Tarih Aralığı',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: DesignTokens.gray900,
          ),
        ),
        const SizedBox(height: 12),
        
        // Date range cards
        Row(
          children: [
            Expanded(
              child: _buildDateCard(
                label: 'Başlangıç Tarihi',
                date: _preferredStartDate,
                onTap: () => _selectStartDate(),
              ),
            ),
            const SizedBox(width: DesignTokens.space16),
            Expanded(
              child: _buildDateCard(
                label: 'Bitiş Tarihi',
                date: _preferredEndDate,
                onTap: () => _selectEndDate(),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Flexible dates checkbox
        Row(
          children: [
            Checkbox(
              value: _isFlexibleDates,
              onChanged: (value) {
                setState(() {
                  _isFlexibleDates = value ?? true;
                });
              },
              activeColor: DesignTokens.primaryCoral,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Tarihlerim esnek, uygun olan tarihlerde çalışabilir',
                style: TextStyle(
                  fontSize: 14,
                  color: DesignTokens.gray900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateCard({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: DesignTokens.surfacePrimary,
          borderRadius: const BorderRadius.circular(DesignTokens.radius12),
          border: Border.all(
            color: date != null 
                ? DesignTokens.primaryCoral.withOpacity(0.5)
                : DesignTokens.nonPhotoBlue.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null ? DesignTokens.primaryCoral : Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  date != null 
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : 'Tarih seçin',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? DesignTokens.gray900 : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _preferredStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: DesignTokens.primaryCoral,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _preferredStartDate = picked;
        // If end date is before start date, clear it
        if (_preferredEndDate != null && _preferredEndDate!.isBefore(picked)) {
          _preferredEndDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _preferredEndDate ?? (_preferredStartDate ?? DateTime.now()),
      firstDate: _preferredStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: DesignTokens.primaryCoral,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _preferredEndDate = picked;
      });
    }
  }

  void _submitQuote() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory.isEmpty || _selectedAreaType.isEmpty || _selectedBudgetRange.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Lütfen zorunlu alanları doldurun'),
            backgroundColor: DesignTokens.error,
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
          Uri.parse(AppConfig.quoteRequestUrl),
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
            'preferred_start_date': _preferredStartDate?.toIso8601String(),
            'preferred_end_date': _preferredEndDate?.toIso8601String(),
            'is_flexible_dates': _isFlexibleDates,
            'urgency_level': _selectedUrgencyLevel,
          }),
        );

        final data = json.decode(response.body);
        
        if (mounted) {
          if (data['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: const Text('Teklif talebiniz başarıyla gönderildi!'),
                backgroundColor: DesignTokens.success,
              ),
            );
            Navigator.pushReplacementNamed(context, '/messages');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Teklif talebi gönderilirken bir hata oluştu'),
                backgroundColor: DesignTokens.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: const Text('Teklif talebi gönderilirken bir hata oluştu'),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DesignTokens.gray900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: DesignTokens.surfacePrimary,
            borderRadius: const BorderRadius.circular(DesignTokens.radius12),
            border: Border.all(color: DesignTokens.nonPhotoBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(DesignTokens.space16),
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