import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuoteFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> craftsman;
  
  const QuoteFormScreen({super.key, required this.craftsman});

  @override
  ConsumerState<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends ConsumerState<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = '';
  String _selectedJobType = '';
  String _selectedLocation = '';
  String _selectedAreaType = '';
  String _selectedRoomCount = '';
  final _squareMetersController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  final List<String> _categories = [
    'Temizlik',
    'Marangoz',
    'Elektrik',
    'Tesisat',
    'Boya',
    'Bahçe',
    'Taşıma',
    'Diğer'
  ];

  final List<String> _jobTypes = [
    'Tamir',
    'Montaj',
    'Temizlik',
    'Bakım',
    'Kurulum',
    'Demontaj',
    'Diğer'
  ];

  final List<String> _areaTypes = [
    'Ev',
    'İş Yeri',
    'Ofis',
    'Dükkan',
    'Villa',
    'Apartman',
    'Diğer'
  ];

  final List<String> _roomCounts = [
    '1 Oda',
    '2 Oda',
    '3 Oda',
    '4 Oda',
    '5+ Oda',
    'Stüdyo'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Teklif Al',
          style: TextStyle(
            color: Color(0xFF1E293B),
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.craftsman['avatar'] ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
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
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.craftsman['business_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
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
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category Selection
                _buildDropdownField(
                  label: 'Kategori',
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
                
                // Job Type Selection
                _buildDropdownField(
                  label: 'İş Tipi',
                  value: _selectedJobType,
                  items: _jobTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedJobType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İş tipi seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Location Selection
                _buildDropdownField(
                  label: 'Konum',
                  value: _selectedLocation,
                  items: ['Kadıköy', 'Ataşehir', 'Üsküdar', 'Beşiktaş', 'Şişli', 'Diğer'],
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konum seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Area Type Selection
                _buildDropdownField(
                  label: 'Alan Tipi',
                  value: _selectedAreaType,
                  items: _areaTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedAreaType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alan tipi seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Room Count Selection
                _buildDropdownField(
                  label: 'Oda Sayısı',
                  value: _selectedRoomCount,
                  items: _roomCounts,
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomCount = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Oda sayısı seçiniz';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Square Meters
                _buildTextField(
                  label: 'Metrekare (Opsiyonel)',
                  controller: _squareMetersController,
                  keyboardType: TextInputType.number,
                  hint: 'Örn: 120',
                ),
                
                const SizedBox(height: 16),
                
                // Description
                _buildTextField(
                  label: 'İş Açıklaması',
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
                
                const SizedBox(height: 32),
                
                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitQuote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
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

  void _submitQuote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Submit quote logic here
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teklif başarıyla gönderildi!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context);
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