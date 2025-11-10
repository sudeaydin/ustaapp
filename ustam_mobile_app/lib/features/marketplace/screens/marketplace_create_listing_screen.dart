import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_input.dart';
import '../models/marketplace_listing.dart';
import '../repositories/marketplace_repository.dart';
import '../providers/marketplace_provider.dart';
import '../../auth/providers/auth_provider.dart';

class MarketplaceCreateListingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? listingToEdit;
  
  const MarketplaceCreateListingScreen({
    super.key,
    this.listingToEdit,
  });

  @override
  ConsumerState<MarketplaceCreateListingScreen> createState() =>
      _MarketplaceCreateListingScreenState();
}

class _MarketplaceCreateListingScreenState
    extends ConsumerState<MarketplaceCreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = '';
  String _selectedBudgetType = 'range'; // 'fixed' or 'range'
  DateTime? _startDate;
  DateTime? _endDate;
  bool _publishToMarketplace = true;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Elektrik',
    'Su Tesisatı',
    'Boyacı',
    'Temizlik',
    'Taşıma',
    'Tadilat',
    'Bahçe',
    'Klima',
    'Cam',
    'Diğer',
  ];

  final List<String> _cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Adana',
    'Konya',
    'Gaziantep',
    'Kayseri',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.listingToEdit != null) {
      _initializeEditMode();
    }
  }

  void _initializeEditMode() {
    final listing = widget.listingToEdit!;
    _titleController.text = listing['title'] ?? '';
    _descriptionController.text = listing['description'] ?? '';
    _selectedCategory = listing['category'] ?? '';
    
    // Handle location - extract city from full location or set to default
    final fullLocation = listing['location'] ?? '';
    String selectedCity = '';
    
    // Try to extract city from location like "Beşiktaş, İstanbul" -> "İstanbul"
    if (fullLocation.contains(',')) {
      final parts = fullLocation.split(',');
      final cityPart = parts.last.trim();
      if (_cities.contains(cityPart)) {
        selectedCity = cityPart;
      }
    } else if (_cities.contains(fullLocation)) {
      selectedCity = fullLocation;
    }
    
    // If no match found, use first city as default
    if (selectedCity.isEmpty) {
      selectedCity = _cities.first;
    }
    
    _locationController.text = selectedCity;
    
    // Parse budget
    final budget = listing['budget'] ?? '';
    if (budget.contains('-')) {
      final parts = budget.replaceAll('₺', '').split('-');
      if (parts.length == 2) {
        _minBudgetController.text = parts[0].trim();
        _maxBudgetController.text = parts[1].trim();
        _selectedBudgetType = 'range';
      }
    } else {
      _minBudgetController.text = budget.replaceAll('₺', '').trim();
      _selectedBudgetType = 'fixed';
    }
  }

  bool get _isEditMode => widget.listingToEdit != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userType = authState.user?['user_type'] ?? 'customer';

    return Scaffold(
      backgroundColor: DesignTokens.surfacePrimary,
      appBar: CommonAppBar(
        title: _isEditMode ? 'İlan Düzenle' : 'İlan Oluştur',
        userType: userType,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header section
              _buildHeaderSection(),

              // Basic info section
              _buildBasicInfoSection(),

              // Category section
              _buildCategorySection(),

              // Location section
              _buildLocationSection(),

              // Budget section
              _buildBudgetSection(),

              // Date range section
              _buildDateRangeSection(),

              // Marketplace settings
              _buildMarketplaceSettings(),

              // Submit section
              _buildSubmitSection(),

              const SizedBox(height: DesignTokens.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return AirbnbCard(
      margin: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignTokens.primaryCoral,
                      DesignTokens.primaryCoralDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.add_business_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: DesignTokens.space16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yeni İş İlanı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'İhtiyacınızı paylaşın, teklifler alın',
                      style: TextStyle(
                        fontSize: 14,
                        color: DesignTokens.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return AirbnbCard(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temel Bilgiler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space20),

          // Title
          AirbnbInput(
            label: 'İş Başlığı',
            controller: _titleController,
            prefixIcon: Icons.title,
            hintText: 'Örn: Salon boyası yaptırılacak',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'İş başlığı gereklidir';
              }
              if (value.trim().length < 10) {
                return 'İş başlığı en az 10 karakter olmalıdır';
              }
              if (value.trim().length > 100) {
                return 'İş başlığı en fazla 100 karakter olabilir';
              }
              return null;
            },
          ),

          const SizedBox(height: DesignTokens.space20),

          // Description
          AirbnbInput(
            label: 'İş Açıklaması',
            controller: _descriptionController,
            maxLines: 5,
            prefixIcon: Icons.description_outlined,
            hintText: 'İş detaylarını, beklentilerinizi ve özel gereksinimlerinizi açıklayın...',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'İş açıklaması gereklidir';
              }
              if (value.trim().length < 20) {
                return 'İş açıklaması en az 20 karakter olmalıdır';
              }
              if (value.trim().length > 1000) {
                return 'İş açıklaması en fazla 1000 karakter olabilir';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return AirbnbCard(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori Seçimi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),

          // Category chips
          Wrap(
            spacing: DesignTokens.space8,
            runSpacing: DesignTokens.space8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space16,
                    vertical: DesignTokens.space12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignTokens.primaryCoral
                        : DesignTokens.gray100,
                    borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                    border: Border.all(
                      color: isSelected
                          ? DesignTokens.primaryCoral
                          : DesignTokens.gray300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : DesignTokens.gray700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedCategory.isEmpty) ...[
 SizedBox(height: DesignTokens.space8),
 Text(
              'Lütfen bir kategori seçin',
              style: TextStyle(
                fontSize: 12,
                color: DesignTokens.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return AirbnbCard(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konum',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),

          // City dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.circular(DesignTokens.radius12),
              border: Border.all(
                color: DesignTokens.gray300,
                width: 1,
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _locationController.text.isEmpty || !_cities.contains(_locationController.text) 
                  ? null 
                  : _locationController.text,
              decoration: InputDecoration(
                labelText: 'Şehir',
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                  vertical: DesignTokens.space12,
                ),
              ),
              items: _cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _locationController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen şehir seçin';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return AirbnbCard(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bütçe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),

          // Budget type selection
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBudgetType = 'fixed';
                      _maxBudgetController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.space12),
                    decoration: BoxDecoration(
                      color: _selectedBudgetType == 'fixed'
                          ? DesignTokens.primaryCoral.withOpacity(0.1)
                          : DesignTokens.gray100,
                      borderRadius: const BorderRadius.circular(DesignTokens.radius8),
                      border: Border.all(
                        color: _selectedBudgetType == 'fixed'
                            ? DesignTokens.primaryCoral
                            : DesignTokens.gray300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedBudgetType == 'fixed'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _selectedBudgetType == 'fixed'
                              ? DesignTokens.primaryCoral
                              : DesignTokens.gray600,
                        ),
                        const SizedBox(width: DesignTokens.space8),
                        const Text(
                          'Sabit Bütçe',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBudgetType = 'range';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.space12),
                    decoration: BoxDecoration(
                      color: _selectedBudgetType == 'range'
                          ? DesignTokens.primaryCoral.withOpacity(0.1)
                          : DesignTokens.gray100,
                      borderRadius: const BorderRadius.circular(DesignTokens.radius8),
                      border: Border.all(
                        color: _selectedBudgetType == 'range'
                            ? DesignTokens.primaryCoral
                            : DesignTokens.gray300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedBudgetType == 'range'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _selectedBudgetType == 'range'
                              ? DesignTokens.primaryCoral
                              : DesignTokens.gray600,
                        ),
                        const SizedBox(width: DesignTokens.space8),
                        const Text(
                          'Bütçe Aralığı',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.space16),

          // Budget inputs
          if (_selectedBudgetType == 'fixed') ...[
            AirbnbInput(
              label: 'Bütçe (TL)',
              controller: _minBudgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              prefixIcon: Icons.attach_money,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bütçe gereklidir';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Geçerli bir tutar girin';
                }
                if (amount < 50) {
                  return 'Minimum bütçe 50 TL\'dir';
                }
                return null;
              },
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: AirbnbInput(
                    label: 'Min Bütçe (TL)',
                    controller: _minBudgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Min bütçe gereklidir';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Geçerli bir tutar girin';
                      }
                      if (amount < 50) {
                        return 'Minimum bütçe 50 TL\'dir';
                      }
                      return null;
                    },
                  ),
                ),
 SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: AirbnbInput(
                    label: 'Max Bütçe (TL)',
                    controller: _maxBudgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Max bütçe gereklidir';
                      }
                      final maxAmount = double.tryParse(value);
                      final minAmount = double.tryParse(_minBudgetController.text);
                      
                      if (maxAmount == null || maxAmount <= 0) {
                        return 'Geçerli bir tutar girin';
                      }
                      if (minAmount != null && maxAmount <= minAmount) {
                        return 'Max bütçe min bütçeden büyük olmalı';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
 Text(
            'İş Tarihi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
 SizedBox(height: DesignTokens.space16),

          // Date selection
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartDate(),
                  child: Container(
                    padding: EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: DesignTokens.gray50,
                      borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                      border: Border.all(
                        color: DesignTokens.gray300,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: DesignTokens.gray600,
                            ),
 SizedBox(width: DesignTokens.space4),
 Text(
                              'Başlangıç',
                              style: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.gray600,
                              ),
                            ),
                          ],
                        ),
 SizedBox(height: 4),
                        Text(
                          _startDate != null
                              ? DateFormat('dd MMM yyyy').format(_startDate!)
                              : 'Tarih seçin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _startDate != null
                                ? DesignTokens.gray900
                                : DesignTokens.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
 SizedBox(width: DesignTokens.space12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndDate(),
                  child: Container(
                    padding: EdgeInsets.all(DesignTokens.space16),
                    decoration: BoxDecoration(
                      color: DesignTokens.gray50,
                      borderRadius: const BorderRadius.circular(DesignTokens.radius12),
                      border: Border.all(
                        color: DesignTokens.gray300,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 16,
                              color: DesignTokens.gray600,
                            ),
 SizedBox(width: DesignTokens.space4),
 Text(
                              'Bitiş',
                              style: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.gray600,
                              ),
                            ),
                          ],
                        ),
 SizedBox(height: 4),
                        Text(
                          _endDate != null
                              ? DateFormat('dd MMM yyyy').format(_endDate!)
                              : 'Tarih seçin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _endDate != null
                                ? DesignTokens.gray900
                                : DesignTokens.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_startDate == null || _endDate == null) ...[
 SizedBox(height: DesignTokens.space8),
 Text(
              'Lütfen başlangıç ve bitiş tarihlerini seçin',
              style: TextStyle(
                fontSize: 12,
                color: DesignTokens.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarketplaceSettings() {
    return AirbnbCard(
      margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16)
          .copyWith(bottom: DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
 Text(
            'Yayınlama Ayarları',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
 SizedBox(height: DesignTokens.space16),

          // Marketplace toggle
          Container(
            padding: EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: DesignTokens.primaryCoral.withOpacity(0.05),
              borderRadius: const BorderRadius.circular(DesignTokens.radius12),
              border: Border.all(
                color: DesignTokens.primaryCoral.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: DesignTokens.primaryCoral,
                  size: 24,
                ),
 SizedBox(width: DesignTokens.space12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pazar Yerinde Yayınla',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.gray900,
                        ),
                      ),
 SizedBox(height: 4),
                      Text(
                        'İlanınız tüm ustaların görebileceği pazar yerinde yayınlanacak',
                        style: TextStyle(
                          fontSize: 13,
                          color: DesignTokens.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _publishToMarketplace,
                  onChanged: (value) {
                    setState(() {
                      _publishToMarketplace = value;
                    });
                  },
                  activeColor: DesignTokens.primaryCoral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.space16),
      child: Column(
        children: [
          // Summary info
          Container(
            padding: EdgeInsets.all(DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.info.withOpacity(0.05),
              borderRadius: const BorderRadius.circular(DesignTokens.radius8),
              border: Border.all(
                color: DesignTokens.info.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: DesignTokens.info,
                ),
 SizedBox(width: DesignTokens.space8),
                const Expanded(
                  child: Text(
                    'İlanınız yayınlandıktan sonra ustalar teklif verebilecek ve sizinle iletişime geçebilecek.',
                    style: TextStyle(
                      fontSize: 13,
                      color: DesignTokens.gray700,
                    ),
                  ),
                ),
              ],
            ),
          ),

 SizedBox(height: DesignTokens.space16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: AirbnbButton(
              text: _isSubmitting 
                  ? (_isEditMode ? 'Güncelleniyor...' : 'Yayınlanıyor...') 
                  : (_isEditMode ? 'İlanı Güncelle' : 'İlanı Yayınla'),
              onPressed: _isSubmitting ? null : _submitListing,
              type: AirbnbButtonType.primary,
              size: AirbnbButtonSize.large,
              icon: _isSubmitting ? null : (_isEditMode ? Icons.update : Icons.publish_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final firstDate = _startDate ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? firstDate.add(const Duration(days: 7)),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir kategori seçin'),
          backgroundColor: DesignTokens.error,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tarih aralığını seçin'),
          backgroundColor: DesignTokens.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final minBudget = double.parse(_minBudgetController.text);
      final maxBudget = _selectedBudgetType == 'fixed' 
          ? minBudget 
          : double.parse(_maxBudgetController.text);

      final request = CreateListingRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        location: ListingLocation(
          city: _locationController.text,
          lat: 0.0, // TODO: Get actual coordinates
          lng: 0.0,
        ),
        budget: ListingBudget(
          type: _selectedBudgetType,
          min: minBudget,
          max: maxBudget,
        ),
        dateRange: ListingDateRange(
          start: _startDate!.toIso8601String(),
          end: _endDate!.toIso8601String(),
        ),
      );

      await ref.read(createListingProvider.notifier).createListing(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'İlanınız başarıyla güncellendi!' : 'İlanınız başarıyla yayınlandı!'),
            backgroundColor: DesignTokens.success,
          ),
        );

        // Navigate back
        if (_isEditMode) {
          Navigator.pop(context); // Go back to listing detail
        } else {
          // Navigate back to marketplace
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/marketplace',
            (route) => route.isFirst,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}