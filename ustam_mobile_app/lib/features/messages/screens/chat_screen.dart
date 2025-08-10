import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> conversation;
  
  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': '''📋 Teklif Talebi:

Kategori: Elektrikçi
Alan: yatak_odası
Bütçe: 1000-2000 TL
Açıklama: Yatak odası elektrik tesisatı yenilenmesi gerekiyor.''',
      'timestamp': '10:00',
      'isMe': true,
      'messageType': 'quote_request',
      'quote': {
        'id': 1,
        'status': 'accepted',
        'category': 'Elektrikçi',
        'area_type': 'yatak_odası',
        'budget_range': '1000-2000',
        'description': 'Yatak odası elektrik tesisatı yenilenmesi gerekiyor.'
      }
    },
    {
      'id': '2',
      'text': '''💰 Teklif Yanıtı:

Fiyat: ₺1800
Tahmini Süre: 2 gün
Başlangıç: 25.01.2025
Bitiş: 26.01.2025

Notlar: Elektrik tesisatını tamamen yenileyeceğim. Kaliteli malzeme kullanacağım.''',
      'timestamp': '14:30',
      'isMe': false,
      'messageType': 'quote_response',
      'quote': {
        'id': 1,
        'status': 'quoted',
        'quoted_price': 1800,
        'estimated_duration_days': 2
      }
    },
    {
      'id': '3',
      'text': '''✅ Teklif Kararı:

Teklifinizi kabul ediyorum. Ödeme yapmaya hazırım.''',
      'timestamp': '16:00',
      'isMe': true,
      'messageType': 'quote_decision',
    },
    {
      'id': '4',
      'text': 'Harika! Ödeme onaylandıktan sonra Perşembe sabahı 9:00\'da başlayabilirim.',
      'timestamp': '16:15',
      'isMe': false,
      'messageType': 'text',
    },
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
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(widget.conversation['avatar']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    widget.conversation['business_name'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Mesajınızı yazın...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(widget.conversation['avatar']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getMessageBackgroundColor(message, isMe),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                border: _getMessageBorder(message, isMe),
                boxShadow: isMe ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote message action buttons
                  if (message['messageType'] == 'quote_request' && !isMe) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          _showQuoteFormDialog(message['quote']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Formu İncele',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                  if (message['messageType'] == 'quote_response' && isMe && message['quote']?['status'] == 'quoted') ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          _showQuoteDecisionDialog(message['quote']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Karar Ver',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                  Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 14,
                      color: _getMessageTextColor(message, isMe),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['timestamp'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': _messageController.text.trim(),
          'timestamp': _getCurrentTime(),
          'isMe': true,
        });
      });
      
      _messageController.clear();
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Color _getMessageBackgroundColor(Map<String, dynamic> message, bool isMe) {
    if (message['messageType'] == 'quote_request') {
      return const Color(0xFFFED7AA); // Orange background
    } else if (message['messageType'] == 'quote_response') {
      return const Color(0xFFBFDBFE); // Blue background
    } else if (message['messageType'] == 'quote_decision') {
      return const Color(0xFFBBF7D0); // Green background
    }
    return isMe ? const Color(0xFF3B82F6) : Colors.white;
  }

  Border? _getMessageBorder(Map<String, dynamic> message, bool isMe) {
    if (message['messageType'] == 'quote_request') {
      return Border.all(color: const Color(0xFFEA580C));
    } else if (message['messageType'] == 'quote_response') {
      return Border.all(color: const Color(0xFF3B82F6));
    } else if (message['messageType'] == 'quote_decision') {
      return Border.all(color: const Color(0xFF059669));
    }
    return isMe ? null : Border.all(color: const Color(0xFFE2E8F0));
  }

  Color _getMessageTextColor(Map<String, dynamic> message, bool isMe) {
    if (message['messageType'] == 'quote_request') {
      return const Color(0xFF9A3412);
    } else if (message['messageType'] == 'quote_response') {
      return const Color(0xFF1E40AF);
    } else if (message['messageType'] == 'quote_decision') {
      return const Color(0xFF065F46);
    }
    return isMe ? Colors.white : const Color(0xFF1E293B);
  }

  void _showQuoteFormDialog(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📋 Teklif Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuoteDetailRow('Kategori', quote['category'] ?? ''),
            _buildQuoteDetailRow('Alan', quote['area_type'] ?? ''),
            _buildQuoteDetailRow('Bütçe', '${quote['budget_range']} TL'),
            _buildQuoteDetailRow('Açıklama', quote['description'] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to quote response screen
            },
            child: const Text('Teklif Ver'),
          ),
        ],
      ),
    );
  }

  void _showQuoteDecisionDialog(Map<String, dynamic>? quote) {
    if (quote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💰 Teklif Kararı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuoteDetailRow('Fiyat', '₺${quote['quoted_price']}'),
            _buildQuoteDetailRow('Süre', '${quote['estimated_duration_days']} gün'),
            const SizedBox(height: 16),
            const Text('Bu teklifi kabul ediyor musunuz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Reject quote
            },
            child: const Text('Reddet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Accept quote and navigate to payment
            },
            child: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}