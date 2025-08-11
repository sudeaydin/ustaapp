import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/api_service.dart';

class CostCalculator extends StatefulWidget {
  const CostCalculator({super.key});

  @override
  State<CostCalculator> createState() => _CostCalculatorState();
}

class _CostCalculatorState extends State<CostCalculator> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCategory;
  String? _selectedAreaType;
  String? _selectedBudgetRange;
  String? _selectedUrgency = 'normal';
  String _description = '';
  String _location = '';
  
  Map<String, dynamic>? _estimate;
  bool _isLoading = false;
  String? _error;

  final List<String> _categories = [
    'Elektrik',
    'Tesisat',
    'Boyama',
    'Temizlik',
    'Klima',
    'Tamirat',
    'Montaj',
    'Diğer'
  ];

  final List<String> _areaTypes = [
    'Ev',
    'Ofis',
    'Mağaza',
    'Fabrika',
    'Diğer'
  ];

  final List<String> _budgetRanges = [
    '0-500',
    '500-1000',
    '1000-2500',
    '2500-5000',
    '5000+'
  ];

  final List<Map<String, dynamic>> _urgencyLevels = [
    {'value': 'low', 'label': 'Acil Değil'},
    {'value': 'normal', 'label': 'Normal'},
    {'value': 'high', 'label': 'Acil'},
    {'value': 'emergency', 'label': 'Çok Acil'},
  ];

  Future<void> _calculateCost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Track cost calculation attempt
      AnalyticsService.getInstance().trackBusinessEvent('cost_calculation', {
        'category': _selectedCategory,
        'area_type': _selectedAreaType,
        'urgency': _selectedUrgency,
      });

      final response = await ApiService.getInstance().post(
        '/analytics/cost-estimate',
        body: {
          'category': _selectedCategory,
          'area_type': _selectedAreaType,
          'budget_range': _selectedBudgetRange,
          'urgency': _selectedUrgency,
          'description': _description,
          'location': _location,
        },
        requiresAuth: true,
      );

      if (response.success) {
        setState(() {
          _estimate = response.data;
        });
        
        AnalyticsService.getInstance().trackBusinessEvent('cost_calculation_success', {
          'estimated_cost': response.data['estimated_cost'],
          'category': _selectedCategory,
        });
      } else {
        setState(() {
          _error = 'Maliyet hesaplanamadı';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bir hata oluştu, lütfen tekrar deneyin';
      });
      AnalyticsService.getInstance().trackError('cost_calculation_failed', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetCalculator() {
    setState(() {
      _selectedCategory = null;
      _selectedAreaType = null;
      _selectedBudgetRange = null;
      _selectedUrgency = 'normal';
      _description = '';
      _location = '';
      _estimate = null;
      _error = null;
    });
    AnalyticsService.getInstance().trackInteraction('tap', 'cost_calculator_reset');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.calculate, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Maliyet Hesaplayıcı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_estimate != null)
                TextButton(
                  onPressed: _resetCalculator,
                  child: Text(
                    'Yeniden Hesapla',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_estimate == null) ...[
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'İş Kategorisi *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen kategori seçin';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Area Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedAreaType,
                    decoration: InputDecoration(
                      labelText: 'Alan Türü *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _areaTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAreaType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen alan türü seçin';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Budget Range Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedBudgetRange,
                    decoration: InputDecoration(
                      labelText: 'Bütçe Aralığı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _budgetRanges.map((range) {
                      return DropdownMenuItem(
                        value: range,
                        child: Text('₺$range'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBudgetRange = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Urgency Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedUrgency,
                    decoration: InputDecoration(
                      labelText: 'Aciliyet Durumu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _urgencyLevels.map((level) {
                      return DropdownMenuItem(
                        value: level['value'],
                        child: Text(level['label']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUrgency = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description Field
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'İş Açıklaması',
                      hintText: 'İş hakkında detayları yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _description = value;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Konum',
                      hintText: 'İl/İlçe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _location = value;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Error Message
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: AppColors.error, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _calculateCost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Maliyeti Hesapla',
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
          ] else ...[
            // Results
            _buildEstimateResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildEstimateResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Estimate
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tahmini Maliyet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₺${_estimate!['estimated_cost']?.toStringAsFixed(0) ?? '0'}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (_estimate!['min_cost'] != null && _estimate!['max_cost'] != null)
                Text(
                  '₺${_estimate!['min_cost']} - ₺${_estimate!['max_cost']} arasında değişebilir',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Breakdown
        if (_estimate!['breakdown'] != null) ...[
          Text(
            'Maliyet Dağılımı',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: (_estimate!['breakdown'] as Map<String, dynamic>)
                  .entries
                  .map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₺${entry.value}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Factors
        if (_estimate!['factors'] != null && (_estimate!['factors'] as List).isNotEmpty) ...[
          Text(
            'Maliyet Etkileyen Faktörler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Column(
              children: (_estimate!['factors'] as List).map<Widget>((factor) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          factor.toString(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Recommendations
        if (_estimate!['recommendations'] != null && (_estimate!['recommendations'] as List).isNotEmpty) ...[
          Text(
            'Öneriler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(
              children: (_estimate!['recommendations'] as List).map<Widget>((rec) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec.toString(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '* Bu tahmin ortalama piyasa fiyatlarına dayalıdır. Gerçek fiyatlar değişebilir.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ] else ...[
        // Form Fields
        _buildFormFields(),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Category
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'İş Kategorisi *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen kategori seçin';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Area Type
        DropdownButtonFormField<String>(
          value: _selectedAreaType,
          decoration: InputDecoration(
            labelText: 'Alan Türü *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: _areaTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAreaType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen alan türü seçin';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Budget Range
        DropdownButtonFormField<String>(
          value: _selectedBudgetRange,
          decoration: InputDecoration(
            labelText: 'Bütçe Aralığı',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: _budgetRanges.map((range) {
            return DropdownMenuItem(
              value: range,
              child: Text('₺$range'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBudgetRange = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Urgency
        DropdownButtonFormField<String>(
          value: _selectedUrgency,
          decoration: InputDecoration(
            labelText: 'Aciliyet Durumu',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: _urgencyLevels.map((level) {
            return DropdownMenuItem(
              value: level['value'],
              child: Text(level['label']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedUrgency = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Description
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'İş Açıklaması',
            hintText: 'İş hakkında detayları yazın...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            _description = value;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Location
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Konum',
            hintText: 'İl/İlçe',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            _location = value;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Error Message
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        
        // Calculate Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _calculateCost,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Maliyeti Hesapla',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}