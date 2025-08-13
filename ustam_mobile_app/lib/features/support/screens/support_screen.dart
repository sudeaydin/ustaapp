import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_bottom_navigation.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/providers/language_provider.dart';
import '../providers/support_provider.dart';

class SupportScreen extends ConsumerStatefulWidget {
  final String userType;

  const SupportScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load user tickets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportProvider.notifier).loadUserTickets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    final supportState = ref.watch(supportProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Destek',
        showBackButton: true,
        userType: widget.userType,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: DesignTokens.headerGradient,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: const [
                Tab(
                  icon: Icon(Icons.add_circle_outline),
                  text: 'Yeni Talep',
                ),
                Tab(
                  icon: Icon(Icons.support_agent),
                  text: 'Taleplerim',
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCreateTicketTab(),
                _buildMyTicketsTab(supportState),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: 0, // No specific index for support
        onTap: (index) {
          // Handle navigation
        },
        userType: widget.userType,
      ),
    );
  }

  Widget _buildCreateTicketTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: CreateTicketForm(
        userType: widget.userType,
        onTicketCreated: () {
          // Switch to tickets tab when ticket is created
          _tabController.animateTo(1);
        },
      ),
    );
  }

  Widget _buildMyTicketsTab(SupportState supportState) {
    if (supportState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (supportState.tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_outlined,
              size: 80,
              color: DesignTokens.textLight,
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Henüz destek talebiniz yok',
              style: TextStyle(
                fontSize: 18,
                color: DesignTokens.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni Talep sekmesinden destek talebi oluşturabilirsiniz',
              style: TextStyle(
                fontSize: 14,
                color: DesignTokens.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: supportState.tickets.length,
      itemBuilder: (context, index) {
        final ticket = supportState.tickets[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? 'open';
    final priority = ticket['priority'] ?? 'medium';
    
    Color statusColor = DesignTokens.primaryCoral;
    String statusText = 'Açık';
    
    switch (status) {
      case 'open':
        statusColor = DesignTokens.primaryCoral;
        statusText = 'Açık';
        break;
      case 'in_progress':
        statusColor = DesignTokens.warning;
        statusText = 'İşlemde';
        break;
      case 'resolved':
        statusColor = DesignTokens.success;
        statusText = 'Çözüldü';
        break;
      case 'closed':
        statusColor = DesignTokens.textLight;
        statusText = 'Kapatıldı';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DesignTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radius16),
        border: Border.all(
          color: DesignTokens.primaryCoral.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [DesignTokens.getCardShadow()],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/support/ticket',
            arguments: ticket['id'],
          );
        },
        borderRadius: BorderRadius.circular(DesignTokens.radius16),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radius8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${ticket['ticket_number']}',
                    style: TextStyle(
                      color: DesignTokens.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Subject
              Text(
                ticket['subject'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.gray900,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Description preview
              Text(
                ticket['description'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: DesignTokens.gray600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: DesignTokens.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(ticket['created_at']),
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textLight,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: DesignTokens.textLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} gün önce';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} saat önce';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} dakika önce';
      } else {
        return 'Şimdi';
      }
    } catch (e) {
      return dateStr;
    }
  }
}

class CreateTicketForm extends ConsumerStatefulWidget {
  final String userType;
  final VoidCallback? onTicketCreated;

  const CreateTicketForm({
    super.key,
    required this.userType,
    this.onTicketCreated,
  });

  @override
  ConsumerState<CreateTicketForm> createState() => _CreateTicketFormState();
}

class _CreateTicketFormState extends ConsumerState<CreateTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.primaryCoral.withOpacity(0.1),
                  DesignTokens.primaryCoral.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radius16),
              border: Border.all(
                color: DesignTokens.primaryCoral.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: DesignTokens.primaryCoral,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Destek Talebi Oluştur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sorununuzu detaylı bir şekilde açıklayın, size yardımcı olalım',
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
          ),
          
          const SizedBox(height: DesignTokens.space24),
          
          // Category Selection
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.primaryCoral.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(DesignTokens.radius12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('Genel')),
                  DropdownMenuItem(value: 'technical', child: Text('Teknik Sorun')),
                  DropdownMenuItem(value: 'account', child: Text('Hesap Sorunları')),
                  DropdownMenuItem(value: 'billing', child: Text('Faturalama')),
                  DropdownMenuItem(value: 'feature_request', child: Text('Özellik İsteği')),
                  DropdownMenuItem(value: 'bug_report', child: Text('Hata Bildirimi')),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Priority Selection
          const Text(
            'Öncelik',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DesignTokens.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.primaryCoral.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(DesignTokens.radius12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPriority,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('🟢 Düşük')),
                  DropdownMenuItem(value: 'medium', child: Text('🟡 Orta')),
                  DropdownMenuItem(value: 'high', child: Text('🟠 Yüksek')),
                  DropdownMenuItem(value: 'urgent', child: Text('🔴 Acil')),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Subject
          CustomTextField(
            controller: _subjectController,
            label: 'Konu',
            hint: 'Sorununuzu kısaca özetleyin',
            prefixIcon: const Icon(Icons.subject),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konu gerekli';
              }
              return null;
            },
          ),
          
          const SizedBox(height: DesignTokens.space16),
          
          // Description
          CustomTextField(
            controller: _descriptionController,
            label: 'Açıklama',
            hint: 'Sorununuzu detaylı bir şekilde açıklayın...',
            prefixIcon: const Icon(Icons.description),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Açıklama gerekli';
              }
              if (value.length < 10) {
                return 'Açıklama en az 10 karakter olmalı';
              }
              return null;
            },
          ),
          
          const SizedBox(height: DesignTokens.space24),
          
          // Submit Button
          CustomButton(
            text: 'Destek Talebi Oluştur',
            onPressed: _handleCreateTicket,
            type: ButtonType.primary,
            size: ButtonSize.large,
            isFullWidth: true,
            isLoading: _isLoading,
            icon: const Icon(Icons.send, color: Colors.white),
          ),
          
          const SizedBox(height: DesignTokens.space16),
          
          // Info Card
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: DesignTokens.primaryCoral.withOpacity(0.05),
              borderRadius: BorderRadius.circular(DesignTokens.radius12),
              border: Border.all(
                color: DesignTokens.primaryCoral.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: DesignTokens.primaryCoral,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ℹ️ Bilgi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Destek talebiniz oluşturulduktan sonra size email ile bildirim gönderilecektir. Yanıtlar hem email hem de uygulama içinde görüntülenecektir.',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(supportProvider.notifier).createTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      );

      if (success && mounted) {
        // Clear form
        _subjectController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = 'general';
          _selectedPriority = 'medium';
        });

        // Switch to tickets tab via callback
        widget.onTicketCreated?.call();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Destek talebiniz oluşturuldu! Size email ile bildirim gönderilecektir.'),
            backgroundColor: DesignTokens.success,
          ),
        );
      } else {
        // Show error
        final supportState = ref.read(supportProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(supportState.error ?? 'Destek talebi oluşturulamadı'),
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