import React, { useState, useEffect, useRef } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import QuoteResponseModal from '../components/QuoteResponseModal';
import CustomerQuoteDecisionModal from '../components/CustomerQuoteDecisionModal';

export const MessagesPage = () => {
  const navigate = useNavigate();
  const { conversationId } = useParams();
  const { user } = useAuth();
  
  const [conversations, setConversations] = useState([]);
  const [activeConversation, setActiveConversation] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef(null);
  const [showQuoteResponseModal, setShowQuoteResponseModal] = useState(false);
  const [showCustomerDecisionModal, setShowCustomerDecisionModal] = useState(false);
  const [selectedQuote, setSelectedQuote] = useState(null);

  // Mock conversations data
  const mockConversations = [
    {
      id: 1,
      participant: {
        id: 2,
        name: 'Ahmet Yılmaz',
        avatar: null,
        user_type: 'craftsman',
        business_name: 'Yılmaz Elektrik'
      },
      last_message: {
        content: 'LED aydınlatma işi için malzemeler geldi, yarın başlayabilirim.',
        created_at: '2025-01-21T16:30:00',
        sender_id: 2
      },
      unread_count: 2,
      job_title: 'LED Aydınlatma Montajı'
    },
    {
      id: 2,
      participant: {
        id: 3,
        name: 'Mehmet Kaya',
        avatar: null,
        user_type: 'craftsman',
        business_name: 'Kaya Tesisatçılık'
      },
      last_message: {
        content: 'Banyo tesisatı için önce keşif yapmam lazım. Uygun olduğunuz zaman?',
        created_at: '2025-01-21T14:15:00',
        sender_id: 3
      },
      unread_count: 0,
      job_title: 'Banyo Tesisatı Yenileme'
    },
    {
      id: 3,
      participant: {
        id: 4,
        name: 'Ali Demir',
        avatar: null,
        user_type: 'customer',
        business_name: null
      },
      last_message: {
        content: 'Teşekkürler, işiniz çok güzel oldu. 5 yıldız verdim.',
        created_at: '2025-01-20T18:45:00',
        sender_id: 4
      },
      unread_count: 0,
      job_title: 'Klima Montajı'
    }
  ];

  // Mock messages for active conversation
  const mockMessages = {
    1: [
      {
        id: 1,
        content: 'Merhaba, LED aydınlatma işi için teklif vermiştim. Ne zaman başlayabiliriz?',
        sender_id: 2,
        sender_name: 'Ahmet Yılmaz',
        created_at: '2025-01-21T10:00:00',
        message_type: 'text'
      },
      {
        id: 2,
        content: 'Merhaba Ahmet Bey, teklifi kabul ettim. Bu hafta içinde başlayabilir misiniz?',
        sender_id: 1,
        sender_name: 'Müşteri',
        created_at: '2025-01-21T10:15:00',
        message_type: 'text'
      },
      {
        id: 3,
        content: 'Tabii ki! Malzemeleri sipariş ettim, yarın gelecek. Perşembe günü başlayabilirim.',
        sender_id: 2,
        sender_name: 'Ahmet Yılmaz',
        created_at: '2025-01-21T10:30:00',
        message_type: 'text'
      },
      {
        id: 4,
        content: 'Perfect! Perşembe günü evde olacağım. Saat kaçta gelmeyi planlıyorsunuz?',
        sender_id: 1,
        sender_name: 'Müşteri',
        created_at: '2025-01-21T11:00:00',
        message_type: 'text'
      },
      {
        id: 5,
        content: 'Sabah 9:00 civarında gelebilirim. Size uygun mu?',
        sender_id: 2,
        sender_name: 'Ahmet Yılmaz',
        created_at: '2025-01-21T11:15:00',
        message_type: 'text'
      },
      {
        id: 6,
        content: 'LED aydınlatma malzemeleri geldi! 📦',
        sender_id: 2,
        sender_name: 'Ahmet Yılmaz',
        created_at: '2025-01-21T15:30:00',
        message_type: 'text'
      },
      {
        id: 7,
        content: 'LED aydınlatma işi için malzemeler geldi, yarın başlayabilirim.',
        sender_id: 2,
        sender_name: 'Ahmet Yılmaz',
        created_at: '2025-01-21T16:30:00',
        message_type: 'text'
      }
    ],
    2: [
      {
        id: 8,
        content: 'Banyo tesisatı için önce keşif yapmam lazım. Uygun olduğunuz zaman?',
        sender_id: 3,
        sender_name: 'Mehmet Kaya',
        created_at: '2025-01-21T14:15:00',
        message_type: 'text'
      }
    ],
    3: [
      {
        id: 9,
        content: 'Teşekkürler, işiniz çok güzel oldu. 5 yıldız verdim.',
        sender_id: 4,
        sender_name: 'Ali Demir',
        created_at: '2025-01-20T18:45:00',
        message_type: 'text'
      }
    ]
  };

  useEffect(() => {
    loadConversations();
  }, []);

  useEffect(() => {
    if (conversationId) {
      const conv = conversations.find(c => c.id === parseInt(conversationId));
      if (conv) {
        setActiveConversation(conv);
        loadMessages(parseInt(conversationId));
      }
    }
  }, [conversationId, conversations]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // Simulate real-time messages
  useEffect(() => {
    if (!activeConversation) return;

    const interval = setInterval(() => {
      // Randomly add new message (simulate real-time)
      if (Math.random() > 0.98) {
        const newMsg = {
          id: Date.now(),
          content: 'Yeni mesaj geldi! 📱',
          sender_id: activeConversation.participant.id,
          sender_name: activeConversation.participant.name,
          created_at: new Date().toISOString(),
          message_type: 'text'
        };
        
        setMessages(prev => [...prev, newMsg]);
        
        // Update conversation last message
        setConversations(prev => 
          prev.map(conv => 
            conv.id === activeConversation.id 
              ? { ...conv, last_message: newMsg, unread_count: conv.unread_count + 1 }
              : conv
          )
        );
      }
    }, 30000); // Check every 30 seconds

    return () => clearInterval(interval);
  }, [activeConversation]);

  const loadConversations = async () => {
    try {
      setLoading(true);
      // In real app, fetch from API
      setConversations(mockConversations);
    } catch (error) {
      console.error('Error loading conversations:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadMessages = async (convId) => {
    try {
      // In real app, fetch from API
      const convMessages = mockMessages[convId] || [];
      setMessages(convMessages);
      
      // Mark as read
      setConversations(prev => 
        prev.map(conv => 
          conv.id === convId 
            ? { ...conv, unread_count: 0 }
            : conv
        )
      );
    } catch (error) {
      console.error('Error loading messages:', error);
    }
  };

  const sendMessage = async (e) => {
    e.preventDefault();
    
    if (!newMessage.trim() || !activeConversation || sending) return;

    try {
      setSending(true);
      
      const message = {
        id: Date.now(),
        content: newMessage.trim(),
        sender_id: user?.id || 1,
        sender_name: user?.name || 'Siz',
        created_at: new Date().toISOString(),
        message_type: 'text'
      };

      // Add to messages
      setMessages(prev => [...prev, message]);
      
      // Update conversation
      setConversations(prev => 
        prev.map(conv => 
          conv.id === activeConversation.id 
            ? { ...conv, last_message: message }
            : conv
        )
      );

      setNewMessage('');
      
      // In real app, send to API
      console.log('Sending message:', message);
    } catch (error) {
      console.error('Error sending message:', error);
      alert('❌ Mesaj gönderilemedi!');
    } finally {
      setSending(false);
    }
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const formatTime = (dateString) => {
    return new Date(dateString).toLocaleTimeString('tr-TR', {
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    
    if (date.toDateString() === today.toDateString()) {
      return 'Bugün';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Dün';
    } else {
      return date.toLocaleDateString('tr-TR', {
        day: 'numeric',
        month: 'short'
      });
    }
  };

  const isMyMessage = (message) => {
    return message.sender_id === (user?.id || 1);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Mesajlar yükleniyor...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigate(-1)}
                className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 transition-colors"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
                <span>Geri</span>
              </button>
              <h1 className="text-2xl font-bold text-gray-900">💬 Mesajlar</h1>
              {activeConversation && (
                <div className="flex items-center space-x-2 bg-blue-50 px-3 py-1 rounded-full">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span className="text-sm text-blue-800 font-medium">
                    {activeConversation.participant.name}
                  </span>
                </div>
              )}
            </div>

            <div className="flex items-center space-x-2">
              <span className="text-sm text-gray-500">
                {conversations.filter(c => c.unread_count > 0).length} okunmamış
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 h-[calc(100vh-200px)]">
          {/* Conversations List */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-sm h-full flex flex-col">
              <div className="p-4 border-b">
                <h2 className="text-lg font-medium text-gray-900">Sohbetler</h2>
              </div>
              
              <div className="flex-1 overflow-y-auto">
                {conversations.length === 0 ? (
                  <div className="p-6 text-center">
                    <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                      </svg>
                    </div>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">Henüz mesaj yok</h3>
                    <p className="text-gray-600">İlk mesajınız geldiğinde burada görünecek.</p>
                  </div>
                ) : (
                  <div className="divide-y divide-gray-200">
                    {conversations.map((conversation) => (
                      <div
                        key={conversation.id}
                        onClick={() => {
                          setActiveConversation(conversation);
                          navigate(`/messages/${conversation.id}`);
                        }}
                        className={`p-4 hover:bg-gray-50 cursor-pointer transition-colors ${
                          activeConversation?.id === conversation.id ? 'bg-blue-50 border-r-4 border-blue-500' : ''
                        }`}
                      >
                        <div className="flex items-start space-x-3">
                          {/* Avatar */}
                          <div className="w-12 h-12 bg-gray-300 rounded-full flex items-center justify-center flex-shrink-0">
                            <span className="text-lg font-medium text-gray-600">
                              {conversation.participant.name.charAt(0)}
                            </span>
                          </div>
                          
                          {/* Content */}
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between mb-1">
                              <h3 className="font-medium text-gray-900 truncate">
                                {conversation.participant.name}
                              </h3>
                              <div className="flex items-center space-x-2">
                                <span className="text-xs text-gray-500">
                                  {formatDate(conversation.last_message.created_at)}
                                </span>
                                {conversation.unread_count > 0 && (
                                  <span className="bg-blue-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                                    {conversation.unread_count}
                                  </span>
                                )}
                              </div>
                            </div>
                            
                            {conversation.participant.business_name && (
                              <p className="text-sm text-blue-600 mb-1">
                                {conversation.participant.business_name}
                              </p>
                            )}
                            
                            <p className="text-sm text-gray-600 mb-1 truncate">
                              {conversation.job_title}
                            </p>
                            
                            <p className="text-sm text-gray-500 truncate">
                              {conversation.last_message.sender_id === (user?.id || 1) ? 'Siz: ' : ''}
                              {conversation.last_message.content}
                            </p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Chat Area */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow-sm h-full flex flex-col">
              {activeConversation ? (
                <>
                  {/* Chat Header */}
                  <div className="p-4 border-b">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        <div className="w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center">
                          <span className="text-sm font-medium text-gray-600">
                            {activeConversation.participant.name.charAt(0)}
                          </span>
                        </div>
                        <div>
                          <h3 className="font-medium text-gray-900">
                            {activeConversation.participant.name}
                          </h3>
                          <p className="text-sm text-gray-600">
                            {activeConversation.job_title}
                          </p>
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        <button
                          onClick={() => navigate(`/job/${activeConversation.id}`)}
                          className="px-3 py-1 text-sm bg-blue-100 text-blue-800 rounded-lg hover:bg-blue-200 transition-colors"
                        >
                          İş Detayları
                        </button>
                        <div className="flex items-center space-x-1 text-green-600">
                          <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                          <span className="text-xs">Çevrimiçi</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Messages */}
                  <div className="flex-1 overflow-y-auto p-4 space-y-4">
                    {messages.length === 0 ? (
                      <div className="text-center py-12">
                        <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                          <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                          </svg>
                        </div>
                        <h4 className="text-lg font-medium text-gray-900 mb-2">Henüz mesaj yok</h4>
                        <p className="text-gray-600">İlk mesajınızı gönderin!</p>
                      </div>
                    ) : (
                      messages.map((message) => (
                        <div
                          key={message.id}
                          className={`flex ${isMyMessage(message) ? 'justify-end' : 'justify-start'}`}
                        >
                          <div
                            className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                              message.message_type === 'quote_request' 
                                ? 'bg-orange-100 border border-orange-200 text-orange-900'
                                : message.message_type === 'quote_response'
                                ? 'bg-blue-100 border border-blue-200 text-blue-900'
                                : message.message_type === 'quote_decision'
                                ? 'bg-green-100 border border-green-200 text-green-900'
                                : isMyMessage(message)
                                ? 'bg-blue-500 text-white'
                                : 'bg-gray-200 text-gray-900'
                            }`}
                          >
                            {/* Quote message special handling */}
                            {message.message_type === 'quote_request' && (
                              <div className="mb-2">
                                <div className="flex items-center gap-2 mb-2">
                                  <span className="text-orange-600">📋</span>
                                  <span className="font-medium text-sm">Teklif Talebi</span>
                                </div>
                                {!isMyMessage(message) && user?.user_type === 'craftsman' && (
                                  <button
                                    onClick={() => {
                                      setSelectedQuote(message.quote);
                                      setShowQuoteResponseModal(true);
                                    }}
                                    className="mb-2 px-3 py-1 bg-orange-500 text-white text-xs rounded-full hover:bg-orange-600 transition-colors"
                                  >
                                    Formu İncele
                                  </button>
                                )}
                              </div>
                            )}
                            
                            {message.message_type === 'quote_response' && (
                              <div className="mb-2">
                                <div className="flex items-center gap-2 mb-2">
                                  <span className="text-blue-600">💰</span>
                                  <span className="font-medium text-sm">Teklif Yanıtı</span>
                                </div>
                                {!isMyMessage(message) && user?.user_type === 'customer' && message.quote?.status === 'quoted' && (
                                  <button
                                    onClick={() => {
                                      setSelectedQuote(message.quote);
                                      setShowCustomerDecisionModal(true);
                                    }}
                                    className="mb-2 px-3 py-1 bg-blue-500 text-white text-xs rounded-full hover:bg-blue-600 transition-colors"
                                  >
                                    Karar Ver
                                  </button>
                                )}
                              </div>
                            )}

                            <p className="text-sm whitespace-pre-line">{message.content}</p>
                            <p className={`text-xs mt-1 ${
                              message.message_type 
                                ? 'text-gray-500'
                                : isMyMessage(message) ? 'text-blue-100' : 'text-gray-500'
                            }`}>
                              {formatTime(message.created_at)}
                            </p>
                          </div>
                        </div>
                      ))
                    )}
                    <div ref={messagesEndRef} />
                  </div>

                  {/* Message Input */}
                  <div className="p-4 border-t">
                    <form onSubmit={sendMessage} className="flex items-center space-x-4">
                      <button
                        type="button"
                        className="p-2 text-gray-400 hover:text-gray-600 transition-colors"
                      >
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13" />
                        </svg>
                      </button>
                      
                      <div className="flex-1">
                        <input
                          type="text"
                          value={newMessage}
                          onChange={(e) => setNewMessage(e.target.value)}
                          placeholder="Mesajınızı yazın..."
                          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                          disabled={sending}
                        />
                      </div>
                      
                      <button
                        type="submit"
                        disabled={!newMessage.trim() || sending}
                        className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
                      >
                        {sending ? (
                          <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        ) : (
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                          </svg>
                        )}
                      </button>
                    </form>
                  </div>
                </>
              ) : (
                /* No Conversation Selected */
                <div className="flex-1 flex items-center justify-center">
                  <div className="text-center">
                    <div className="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
                      <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                      </svg>
                    </div>
                    <h3 className="text-xl font-medium text-gray-900 mb-2">Sohbet Seçin</h3>
                    <p className="text-gray-600">Mesajlaşmaya başlamak için sol taraftan bir sohbet seçin.</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Quote Response Modal */}
      <QuoteResponseModal
        isOpen={showQuoteResponseModal}
        onClose={() => setShowQuoteResponseModal(false)}
        quote={selectedQuote}
        onResponse={(updatedQuote) => {
          // Refresh messages or update quote in state
          console.log('Quote response:', updatedQuote);
        }}
      />

      {/* Customer Quote Decision Modal */}
      <CustomerQuoteDecisionModal
        isOpen={showCustomerDecisionModal}
        onClose={() => setShowCustomerDecisionModal(false)}
        quote={selectedQuote}
        onDecision={(updatedQuote) => {
          // Refresh messages or update quote in state
          console.log('Customer decision:', updatedQuote);
        }}
      />
    </div>
  );
};

export default MessagesPage;