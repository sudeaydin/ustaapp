import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/accessibility_utils.dart';
import '../../../core/theme/design_tokens.dart';

class AccessibilityTestScreen extends ConsumerStatefulWidget {
  const AccessibilityTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AccessibilityTestScreen> createState() => _AccessibilityTestScreenState();
}

class _AccessibilityTestScreenState extends ConsumerState<AccessibilityTestScreen> 
    with AccessibilityMixin, TickerProviderStateMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isLoading = false;
  bool _showModal = false;
  int _currentPage = 1;
  final int _totalPages = 5;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Announce screen load
    announceMount('Erişilebilirlik test sayfası yüklendi');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleLoadingDemo() {
    setState(() {
      _isLoading = true;
    });
    
    AccessibilityUtils.announce('Yükleme başladı');
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AccessibilityUtils.announce('Yükleme tamamlandı');
      }
    });
  }

  void _handleFormSubmit() {
    if (_formKey.currentState!.validate()) {
      AccessibilityUtils.announce('Form başarıyla gönderildi');
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form başarıyla gönderildi'),
          backgroundColor: DesignTokens.primaryCoral,
        ),
      );
    } else {
      AccessibilityUtils.announce('Form hatası: Gerekli alanları doldurun');
    }
  }

  void _handlePageChange(int page) {
    setState(() {
      _currentPage = page;
    });
    AccessibilityUtils.announce('$page. sayfaya geçildi');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Erişilebilirlik Testi').withSemantics(
          header: true,
          label: 'Erişilebilirlik test sayfası başlığı',
        ),
        backgroundColor: DesignTokens.uclaBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Geri git',
        ).withSemantics(
          button: true,
          label: 'Geri git butonu',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Description
            Card(
              child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Erişilebilirlik Özellikleri',
                      style: theme.textTheme.headlineSmall,
                    ).withSemantics(header: true),
                    const SizedBox(height: 8),
                    Text(
                      'Bu sayfa UstamApp\'in erişilebilirlik özelliklerini test etmek için tasarlanmıştır. '
                      'Ekran okuyucu, klavye navigasyonu ve diğer erişilebilirlik araçlarını test edebilirsiniz.',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: DesignTokens.space24),

            // Buttons Demo
            _buildButtonsDemo(),
            
            const SizedBox(height: DesignTokens.space24),

            // Form Demo
            _buildFormDemo(),
            
            const SizedBox(height: DesignTokens.space24),

            // Tabs Demo
            _buildTabsDemo(),
            
            const SizedBox(height: DesignTokens.space24),

            // Pagination Demo
            _buildPaginationDemo(),
            
            const SizedBox(height: DesignTokens.space24),

            // Color Contrast Demo
            _buildColorContrastDemo(),
            
            const SizedBox(height: DesignTokens.space24),

            // Loading Demo
            if (_isLoading) _buildLoadingDemo(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showModal = true;
          });
        },
        backgroundColor: DesignTokens.primaryCoral,
        child: const Icon(Icons.info),
        tooltip: 'Bilgi modalını aç',
      ).withSemantics(
        button: true,
        label: 'Erişilebilirlik bilgi modalını aç',
      ),
    );
  }

  Widget _buildButtonsDemo() {
    return Card(
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Erişilebilir Butonlar',
              style: Theme.of(context).textTheme.titleLarge,
            ).withSemantics(header: true),
            const SizedBox(height: DesignTokens.space16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AccessibleButton(
                  text: 'Birincil Buton',
                  onPressed: () => AccessibilityUtils.announce('Birincil buton tıklandı'),
                  semanticLabel: 'Birincil aksiyon butonu',
                ),
                
                AccessibleButton(
                  text: 'Yükleme Demo',
                  onPressed: _handleLoadingDemo,
                  isLoading: _isLoading,
                  isDisabled: _isLoading,
                  semanticLabel: 'Yükleme demo butonu',
                ),
                
                AccessibleButton(
                  text: 'Devre Dışı',
                  onPressed: null,
                  isDisabled: true,
                  semanticLabel: 'Devre dışı buton örneği',
                ),
                
                AccessibleButton(
                  text: 'İkon ile',
                  onPressed: () => AccessibilityUtils.announce('İkonlu buton tıklandı'),
                  icon: const Icon(Icons.star, size: 16),
                  semanticLabel: 'Yıldız ikonu ile buton',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormDemo() {
    return Card(
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Erişilebilir Form',
              style: Theme.of(context).textTheme.titleLarge,
            ).withSemantics(header: true),
            const SizedBox(height: DesignTokens.space16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AccessibleTextField(
                    label: 'Ad Soyad',
                    controller: _nameController,
                    isRequired: true,
                    hintText: 'Tam adınızı giriniz',
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  AccessibleTextField(
                    label: 'E-posta Adresi',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    hintText: 'ornek@email.com',
                  ),
                  
                  const SizedBox(height: DesignTokens.space16),
                  
                  AccessibleTextField(
                    label: 'Mesajınız',
                    controller: _messageController,
                    isRequired: true,
                    hintText: 'Mesajınızı buraya yazın...',
                  ),
                  
                  const SizedBox(height: DesignTokens.space24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: AccessibleButton(
                      text: 'Formu Gönder',
                      onPressed: _handleFormSubmit,
                      semanticLabel: 'Test formunu gönder',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsDemo() {
    return Card(
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Erişilebilir Sekmeler',
              style: Theme.of(context).textTheme.titleLarge,
            ).withSemantics(header: true),
            const SizedBox(height: DesignTokens.space16),
            
            AccessibleTabBar(
              tabs: const [
                Tab(text: 'Genel'),
                Tab(text: 'Detaylar'),
                Tab(text: 'Ayarlar'),
              ],
              controller: _tabController,
              semanticLabel: 'Demo sekmeleri',
            ),
            
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent('Genel sekme içeriği'),
                  _buildTabContent('Detaylar sekme içeriği'),
                  _buildTabContent('Ayarlar sekme içeriği'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Text(content).withSemantics(
        label: content,
      ),
    );
  }

  Widget _buildPaginationDemo() {
    return Card(
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sayfalama Örneği',
              style: Theme.of(context).textTheme.titleLarge,
            ).withSemantics(header: true),
            const SizedBox(height: DesignTokens.space16),
            
            Text('Şu anki sayfa: $_currentPage / $_totalPages'),
            const SizedBox(height: DesignTokens.space16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentPage > 1 ? () => _handlePageChange(_currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Önceki sayfa',
                ).withSemantics(
                  button: true,
                  label: 'Önceki sayfa',
                  enabled: _currentPage > 1,
                ),
                
                const SizedBox(width: DesignTokens.space16),
                
                Text(
                  '$_currentPage',
                  style: Theme.of(context).textTheme.titleMedium,
                ).withSemantics(
                  label: 'Şu anki sayfa $_currentPage',
                ),
                
                const SizedBox(width: DesignTokens.space16),
                
                IconButton(
                  onPressed: _currentPage < _totalPages ? () => _handlePageChange(_currentPage + 1) : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Sonraki sayfa',
                ).withSemantics(
                  button: true,
                  label: 'Sonraki sayfa',
                  enabled: _currentPage < _totalPages,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorContrastDemo() {
    return Card(
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Renk Kontrastı Örnekleri',
              style: Theme.of(context).textTheme.titleLarge,
            ).withSemantics(header: true),
            const SizedBox(height: DesignTokens.space16),
            
            Column(
              children: [
                _buildContrastExample(
                  'AA Uyumlu',
                  'Bu metin yeterli kontrasta sahip',
                  DesignTokens.uclaBlue,
                  Colors.white,
                ),
                const SizedBox(height: 8),
                _buildContrastExample(
                  'AAA Uyumlu',
                  'Bu metin maksimum kontrasta sahip',
                  Colors.black,
                  Colors.white,
                ),
                const SizedBox(height: 8),
                _buildContrastExample(
                  'Yüksek Kontrast',
                  'Bu metin çok iyi okunabilir',
                  Colors.white,
                  Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContrastExample(String title, String description, Color background, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.circular(DesignTokens.radius8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ).withSemantics(
            header: true,
            label: '$title kontrast örneği',
          ),
          Text(
            description,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDemo() {
    return Card(
      child: const Padding(
      padding: EdgeInsets.all(DesignTokens.space16),
        child: Column(
          children: [
            Text(
              'Yükleme Göstergesi',
              style: Theme.of(context).textTheme.titleLarge,
            ).withSemantics(header: true),
            const SizedBox(height: DesignTokens.space16),
            
            AccessibleProgressIndicator(
              semanticLabel: 'Demo yükleme işlemi',
              progressText: 'Lütfen bekleyin...',
            ),
          ],
        ),
      ),
    );
  }

  void _showAccessibilityInfo() {
    showDialog(
      context: context,
      builder: (context) => AccessibleModal(
        title: 'Erişilebilirlik Bilgisi',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu uygulama aşağıdaki erişilebilirlik özelliklerine sahiptir:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text('• Ekran okuyucu desteği'),
            Text('• Semantik etiketleme'),
            Text('• Klavye navigasyonu'),
            Text('• Yüksek kontrast desteği'),
            Text('• Dokunma hedefi boyutları'),
            Text('• Hareket azaltma desteği'),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Ekran okuyucu: ${AccessibilityUtils.isScreenReaderEnabled ? "Aktif" : "Pasif"}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Yüksek kontrast: ${AccessibilityUtils.isHighContrastEnabled ? "Aktif" : "Pasif"}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Hareket azaltma: ${AccessibilityUtils.isReduceMotionEnabled ? "Aktif" : "Pasif"}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Yazı tipi ölçeği: ${AccessibilityUtils.fontScale.toStringAsFixed(1)}x',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }
}