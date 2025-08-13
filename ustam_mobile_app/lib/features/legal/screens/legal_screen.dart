import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/legal_utils.dart';
import '../../../core/utils/accessibility_utils.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({Key? key}) : super(key: key);

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> 
    with LegalComplianceMixin, AccessibilityMixin, TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final List<LegalDocumentType> _documentTypes = [
    LegalDocumentType.userAgreement,
    LegalDocumentType.privacyPolicy,
    LegalDocumentType.cookiePolicy,
    LegalDocumentType.terms,
    LegalDocumentType.kvkk,
    LegalDocumentType.communicationRules,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yasal Belgeler'),
        backgroundColor: const Color(0xFF467599), // ucla-blue
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: TabController(
                length: _documentTypes.length,
                vsync: this,
                initialIndex: _selectedTabIndex,
              ),
              isScrollable: true,
              onTap: (index) => setState(() => _selectedTabIndex = index),
              labelColor: const Color(0xFF467599),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF467599),
              tabs: _documentTypes.map((type) => Tab(
                icon: Icon(type.icon, size: 20),
                text: type.displayName,
              )).toList(),
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: TabController(
                length: _documentTypes.length,
                vsync: this,
                initialIndex: _selectedTabIndex,
              ),
              children: _documentTypes.map((type) => 
                LegalDocumentView(documentType: type)
              ).toList(),
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AccessibleButton(
                        onPressed: showConsentPreferences,
                        semanticLabel: 'Onay tercihlerini yönet',
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 8),
                            Text('Onay Tercihleri'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AccessibleButton(
                        onPressed: showGDPRRights,
                        semanticLabel: 'KVKK haklarını görüntüle',
                        variant: 'secondary',
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.privacy_tip),
                            SizedBox(width: 8),
                            Text('KVKK Hakları'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Legal document view widget
class LegalDocumentView extends StatefulWidget {
  final LegalDocumentType documentType;

  const LegalDocumentView({
    Key? key,
    required this.documentType,
  }) : super(key: key);

  @override
  State<LegalDocumentView> createState() => _LegalDocumentViewState();
}

class _LegalDocumentViewState extends State<LegalDocumentView> {
  LegalDocument? _document;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final document = await LegalManager().getLegalDocument(widget.documentType);
      
      setState(() {
        _document = document;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Belge yüklenemedi',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space16),
            ElevatedButton(
              onPressed: _loadDocument,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_document == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Belge bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document header
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: const Color(0xFF467599).withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radius8),
            ),
            child: Row(
              children: [
                Icon(
                  widget.documentType.icon,
                  size: 32,
                  color: const Color(0xFF467599),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _document!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF467599),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Versiyon: ${_document!.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Son güncelleme: ${_formatDate(_document!.lastUpdated)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_document!.mandatory)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ZORUNLU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignTokens.space16),
          
          // Document content
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radius8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _document!.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: DesignTokens.space24),
          
          // Contact information
          Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: DesignTokens.primaryCoral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radius8),
              border: Border.all(color: DesignTokens.primaryCoral.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.contact_support,
                      color: DesignTokens.primaryCoral,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'İletişim Bilgileri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.primaryCoral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildContactRow(Icons.business, 'Şirket', LegalConstants.companyName),
                _buildContactRow(Icons.location_on, 'Adres', LegalConstants.companyAddress),
                _buildContactRow(Icons.email, 'E-posta', LegalConstants.contactEmail),
                _buildContactRow(Icons.security, 'KVKK Sorumlusu', LegalConstants.dpoEmail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: DesignTokens.primaryCoral,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DesignTokens.primaryCoral,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
           '${date.month.toString().padLeft(2, '0')}.'
           '${date.year}';
  }
}

/// User Agreement Modal Widget
class UserAgreementModal extends StatefulWidget {
  const UserAgreementModal({Key? key}) : super(key: key);

  @override
  State<UserAgreementModal> createState() => _UserAgreementModalState();
}

class _UserAgreementModalState extends State<UserAgreementModal> {
  LegalDocument? _agreement;
  bool _isLoading = true;
  bool _hasScrolledToEnd = false;
  bool _mandatoryConsent = false;
  bool _marketingConsent = false;
  bool _analyticsConsent = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAgreement();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 50) {
        if (!_hasScrolledToEnd) {
          setState(() => _hasScrolledToEnd = true);
        }
      }
    });
  }

  Future<void> _loadAgreement() async {
    try {
      final agreement = await LegalManager().getLegalDocument(
        LegalDocumentType.userAgreement
      );
      setState(() {
        _agreement = agreement;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı sözleşmesi yüklenemedi')),
        );
      }
    }
  }

  Future<void> _acceptAgreement() async {
    if (!_mandatoryConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zorunlu onayları kabul etmelisiniz')),
      );
      return;
    }

    try {
      // Record consents
      await LegalManager().recordConsent(ConsentType.mandatory, _mandatoryConsent);
      if (_marketingConsent) {
        await LegalManager().recordConsent(ConsentType.marketing, true);
      }
      if (_analyticsConsent) {
        await LegalManager().recordConsent(ConsentType.analytics, true);
      }

      // Accept user agreement
      await LegalManager().acceptUserAgreement();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Kullanıcı Sözleşmesi ve KVKK Onayı',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(DesignTokens.radius8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _agreement?.content ?? 'Kullanıcı sözleşmesi yüklenemedi.',
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Column(
                    children: [
                      CheckboxListTile(
                        title: const Text(
                          'Kullanıcı sözleşmesini ve KVKK aydınlatma metnini okudum, anladım ve kabul ediyorum. (Zorunlu)',
                          style: TextStyle(fontSize: 11),
                        ),
                        value: _mandatoryConsent,
                        onChanged: _hasScrolledToEnd 
                            ? (value) => setState(() => _mandatoryConsent = value ?? false) 
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Pazarlama ve tanıtım amaçlı iletişim için onay veriyorum. (İsteğe bağlı)',
                          style: TextStyle(fontSize: 11),
                        ),
                        value: _marketingConsent,
                        onChanged: (value) => setState(() => _marketingConsent = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Uygulama analitikleri ve performans iyileştirmeleri için onay veriyorum. (İsteğe bağlı)',
                          style: TextStyle(fontSize: 11),
                        ),
                        value: _analyticsConsent,
                        onChanged: (value) => setState(() => _analyticsConsent = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ],
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Reddet'),
        ),
        ElevatedButton(
          onPressed: _hasScrolledToEnd && _mandatoryConsent ? _acceptAgreement : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF467599),
            foregroundColor: Colors.white,
          ),
          child: const Text('Kabul Et'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Consent Preferences Sheet
class ConsentPreferencesSheet extends StatefulWidget {
  const ConsentPreferencesSheet({Key? key}) : super(key: key);

  @override
  State<ConsentPreferencesSheet> createState() => _ConsentPreferencesSheetState();
}

class _ConsentPreferencesSheetState extends State<ConsentPreferencesSheet> {
  Map<ConsentType, bool> _consents = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    try {
      final consents = await LegalManager().getUserConsents();
      final consentMap = <ConsentType, bool>{};
      
      for (final type in ConsentType.values) {
        final consent = consents.where((c) => c.type == type).lastOrNull;
        consentMap[type] = consent?.granted ?? false;
      }
      
      setState(() {
        _consents = consentMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateConsent(ConsentType type, bool granted) async {
    if (LegalManager().isConsentRequired(type) && !granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu onay zorunludur')),
      );
      return;
    }

    try {
      await LegalManager().recordConsent(type, granted);
      setState(() => _consents[type] = granted);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${type.displayName} onayı güncellendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: const Color(0xFF467599),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Onay Tercihleri',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: DesignTokens.space16),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: ConsentType.values.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final type = ConsentType.values[index];
                          final isRequired = LegalManager().isConsentRequired(type);
                          
                          return ListTile(
                            leading: Icon(
                              type.icon,
                              color: isRequired ? Colors.red[600] : const Color(0xFF467599),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  type.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                if (isRequired) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'ZORUNLU',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              LegalManager().getConsentDescription(type),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Switch(
                              value: _consents[type] ?? false,
                              onChanged: isRequired 
                                  ? null 
                                  : (value) => _updateConsent(type, value),
                              activeColor: const Color(0xFF467599),
                            ),
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// GDPR Rights Sheet
class GDPRRightsSheet extends StatelessWidget {
  const GDPRRightsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.8,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      color: const Color(0xFF467599),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'KVKK/GDPR Hakları',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: DesignTokens.space16),
              
              // Content
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: GDPRRight.values.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final right = GDPRRight.values[index];
                    return ListTile(
                      leading: Icon(
                        _getGDPRRightIcon(right),
                        color: const Color(0xFF467599),
                      ),
                      title: Text(
                        LegalConstants.gdprRightDescriptions[right] ?? right.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _getGDPRRightDescription(right),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _handleGDPRRequest(context, right),
                    );
                  },
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getGDPRRightIcon(GDPRRight right) {
    switch (right) {
      case GDPRRight.access:
        return Icons.visibility;
      case GDPRRight.rectification:
        return Icons.edit;
      case GDPRRight.erasure:
        return Icons.delete_forever;
      case GDPRRight.portability:
        return Icons.import_export;
      case GDPRRight.restriction:
        return Icons.block;
      case GDPRRight.objection:
        return Icons.report_problem;
      case GDPRRight.withdraw:
        return Icons.undo;
    }
  }

  String _getGDPRRightDescription(GDPRRight right) {
    switch (right) {
      case GDPRRight.access:
        return 'Hangi verilerinizin işlendiğini öğrenin';
      case GDPRRight.rectification:
        return 'Yanlış veya eksik verilerinizi düzeltin';
      case GDPRRight.erasure:
        return 'Hesabınızı ve verilerinizi kalıcı olarak silin';
      case GDPRRight.portability:
        return 'Verilerinizi indirin veya başka servise taşıyın';
      case GDPRRight.restriction:
        return 'Veri işlemeyi geçici olarak durdurun';
      case GDPRRight.objection:
        return 'Belirli veri işleme faaliyetlerine itiraz edin';
      case GDPRRight.withdraw:
        return 'Verdiğiniz izinleri geri çekin';
    }
  }

  Future<void> _handleGDPRRequest(BuildContext context, GDPRRight right) async {
    switch (right) {
      case GDPRRight.access:
      case GDPRRight.portability:
        await _requestDataExport(context);
        break;
      case GDPRRight.erasure:
        await _requestAccountDeletion(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${right.name} talebi için ${LegalConstants.contactEmail} adresine başvurunuz'
            ),
          ),
        );
    }
  }

  Future<void> _requestDataExport(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri Dışa Aktarımı'),
        content: const Text(
          'Kişisel verilerinizin bir kopyasını talep etmek istediğinizden emin misiniz? '
          'Veriler e-posta adresinize gönderilecektir.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF467599),
              foregroundColor: Colors.white,
            ),
            child: const Text('Talep Et'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await LegalManager().requestDataExport();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Veri dışa aktarım talebi alındı. E-posta ile bilgilendirileceksiniz.'
                : 'Talep gönderilemedi. Lütfen tekrar deneyin.'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _requestAccountDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesap Silme'),
        content: const Text(
          'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz ve tüm verileriniz silinir. '
          'Aktif işleriniz varsa önce bunları tamamlamanız önerilir.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await LegalManager().requestAccountDeletion();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Hesap silme talebi alındı. 30 gün içinde hesabınız silinecektir.'
                : 'Talep gönderilemedi. Lütfen tekrar deneyin.'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}

/// Cookie Consent Banner Widget
class CookieConsentBanner extends StatefulWidget {
  const CookieConsentBanner({Key? key}) : super(key: key);

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<CookieConsentBanner> {
  bool _showBanner = false;
  static const String _cookieConsentKey = 'cookie_consent_given';

  @override
  void initState() {
    super.initState();
    _checkCookieConsent();
  }

  Future<void> _checkCookieConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool(_cookieConsentKey) ?? false;
    
    if (!hasConsent) {
      setState(() => _showBanner = true);
    }
  }

  Future<void> _acceptCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cookieConsentKey, true);
    await LegalManager().recordConsent(ConsentType.cookies, true);
    setState(() => _showBanner = false);
  }

  Future<void> _rejectCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cookieConsentKey, true);
    await LegalManager().recordConsent(ConsentType.cookies, false);
    setState(() => _showBanner = false);
  }

  Future<void> _showCookiePreferences() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ConsentPreferencesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBanner) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(DesignTokens.space16),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radius12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cookie,
                  color: const Color(0xFF467599),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bu uygulama çerezler kullanır',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Deneyiminizi iyileştirmek için çerezler kullanıyoruz. '
              'Devam ederek çerez kullanımını kabul etmiş olursunuz.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: DesignTokens.space16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _rejectCookies,
                    child: const Text('Reddet'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showCookiePreferences,
                    child: const Text('Özelleştir'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acceptCookies,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF467599),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kabul Et'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}