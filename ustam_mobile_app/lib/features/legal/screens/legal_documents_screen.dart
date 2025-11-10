import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/design_tokens.dart';

class LegalDocumentsScreen extends StatefulWidget {
  const LegalDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<LegalDocumentsScreen> createState() => _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends State<LegalDocumentsScreen> {
  List<LegalDocument> documents = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLegalDocuments();
  }

  Future<void> _loadLegalDocuments() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ApiService().get('/legal/documents/all');
      
      if (response.success && response.data != null) {
        final documentsData = response.data!['documents'] as List;
        setState(() {
          documents = documentsData
              .map((doc) => LegalDocument.fromJson(doc))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Legal dokümanlar yüklenemedi';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Bir hata oluştu: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Yasal Belgeler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: DesignTokens.primaryCoral,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: const CircularProgressIndicator(
          color: DesignTokens.primaryCoral,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLegalDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryCoral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return _buildDocumentCard(document);
      },
    );
  }

  Widget _buildDocumentCard(LegalDocument document) {
    IconData icon;
    Color iconColor;

    switch (document.type) {
      case 'terms_of_service':
        icon = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'privacy_policy':
        icon = Icons.privacy_tip;
        iconColor = Colors.green;
        break;
      case 'cookie_policy':
        icon = Icons.cookie;
        iconColor = Colors.orange;
        break;
      case 'user_agreement':
        icon = Icons.person;
        iconColor = Colors.purple;
        break;
      case 'corporate_agreement':
        icon = Icons.business;
        iconColor = Colors.indigo;
        break;
      case 'listing_rules':
        icon = Icons.rule;
        iconColor = Colors.red;
        break;
      case 'kvkk_summary':
        icon = Icons.security;
        iconColor = Colors.teal;
        break;
      default:
        icon = Icons.article;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: const Borderconst Radius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: const Borderconst Radius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          document.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DesignTokens.gray900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              document.description,
              style: TextStyle(
                fontSize: 14,
                color: DesignTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryCoral.withOpacity(0.1),
                    borderRadius: const Borderconst Radius.circular(6),
                  ),
                  child: Text(
                    'v${document.version}',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.primaryCoral,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Güncelleme: ${document.lastUpdated}',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.gray500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: DesignTokens.gray400,
        ),
        onTap: () => _openDocument(document),
      ),
    );
  }

  void _openDocument(LegalDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalDocumentViewerScreen(document: document),
      ),
    );
  }
}

class LegalDocumentViewerScreen extends StatefulWidget {
  final LegalDocument document;

  const LegalDocumentViewerScreen({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<LegalDocumentViewerScreen> createState() => _LegalDocumentViewerScreenState();
}

class _LegalDocumentViewerScreenState extends State<LegalDocumentViewerScreen> {
  String? documentContent;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocumentContent();
  }

  Future<void> _loadDocumentContent() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ApiService().get(widget.document.endpoint);
      
      if (response.success && response.data != null) {
        setState(() {
          documentContent = response.data!['content'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Doküman içeriği yüklenemedi';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Bir hata oluştu: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.document.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: DesignTokens.primaryCoral,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: const CircularProgressIndicator(
          color: DesignTokens.primaryCoral,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDocumentContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryCoral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignTokens.primaryCoral.withOpacity(0.1),
              borderRadius: const Borderconst Radius.circular(12),
              border: Border.all(
                color: DesignTokens.primaryCoral.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.document.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.document.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignTokens.gray600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const Borderconst Radius.circular(6),
                      ),
                      child: Text(
                        'Sürüm ${widget.document.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.primaryCoral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Son güncelleme: ${widget.document.lastUpdated}',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Document content
          if (documentContent != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const Borderconst Radius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                ),
              ),
              child: SelectableText(
                documentContent!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: DesignTokens.gray800,
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Kopyala'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignTokens.primaryCoral,
                    side: const BorderSide(color: DesignTokens.primaryCoral),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareDocument,
                  icon: const Icon(Icons.share),
                  label: const Text('Paylaş'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryCoral,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    if (documentContent != null) {
      Clipboard.setData(ClipboardData(text: documentContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('Doküman panoya kopyalandı'),
          backgroundColor: DesignTokens.primaryCoral,
        ),
      );
    }
  }

  void _shareDocument() {
    if (documentContent != null) {
      // Share functionality would be implemented here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('Paylaşım özelliği yakında eklenecek'),
          backgroundColor: DesignTokens.primaryCoral,
        ),
      );
    }
  }
}

class LegalDocument {
  final String id;
  final String title;
  final String description;
  final String endpoint;
  final List<String> requiredFor;
  final String version;
  final String lastUpdated;
  final String type;

  LegalDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.endpoint,
    required this.requiredFor,
    required this.version,
    required this.lastUpdated,
    required this.type,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      endpoint: json['endpoint'],
      requiredFor: List<String>.from(json['required_for']),
      version: json['version'],
      lastUpdated: json['last_updated'],
      type: json['id'], // Using id as type for consistency
    );
  }
}