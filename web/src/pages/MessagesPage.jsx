import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const MessagesPage = () => {
  const navigate = useNavigate();
  const { partnerId } = useParams();
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [conversations, setConversations] = useState([]);
  const [currentConversation, setCurrentConversation] = useState([]);
  const [selectedPartner, setSelectedPartner] = useState(null);
  const [newMessage, setNewMessage] = useState('');
  const [sending, setSending] = useState(false);

  useEffect(() => {
    fetchConversations();
    if (partnerId) {
      fetchConversation(partnerId);
    }
  }, [partnerId]);

  const fetchConversations = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('authToken');
      const response = await fetch('/api/messages/conversations', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      const data = await response.json();
      if (data.success) {
        setConversations(data.data);
      }
    } catch (error) {
      console.error('Conversations fetch error:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchConversation = async (partnerIdParam) => {
    try {
      const token = localStorage.getItem('authToken');
      const response = await fetch(`/api/messages/conversation/${partnerIdParam}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      const data = await response.json();
      if (data.success) {
        setCurrentConversation(data.data);
        // Find partner info from conversations
        const partner = conversations.find(conv => conv.partner_id == partnerIdParam);
        if (partner) {
          setSelectedPartner({
            id: partner.partner_id,
            name: partner.partner_name,
            type: partner.partner_type
          });
        }
      }
    } catch (error) {
      console.error('Conversation fetch error:', error);
    }
  };

  const sendMessage = async () => {
    if (!newMessage.trim() || !selectedPartner) return;

    try {
      setSending(true);
      const token = localStorage.getItem('authToken');
      const response = await fetch('/api/messages/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          receiver_id: selectedPartner.id,
          content: newMessage.trim()
        })
      });
      
      const data = await response.json();
      if (data.success) {
        setCurrentConversation(prev => [...prev, data.data]);
        setNewMessage('');
        fetchConversations(); // Refresh conversations list
      } else {
        alert(data.message || 'Mesaj gönderilemedi');
      }
    } catch (error) {
      alert('Bir hata oluştu');
    } finally {
      setSending(false);
    }
  };

  const formatTime = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = (now - date) / (1000 * 60 * 60);

    if (diffInHours < 1) {
      return 'Şimdi';
    } else if (diffInHours < 24) {
      return `${Math.floor(diffInHours)} saat önce`;
    } else {
      return date.toLocaleDateString('tr-TR');
    }
  };

  // If no partner selected, show conversations list
  if (!partnerId) {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-md mx-auto px-4 py-4">
            <div className="flex items-center justify-between">
              <button 
                onClick={() => navigate(-1)}
                className="p-2 hover:bg-gray-100 rounded-full"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              <h1 className="text-xl font-semibold text-gray-900">Mesajlar</h1>
              <div className="w-10"></div>
            </div>
          </div>
        </div>

        <div className="max-w-md mx-auto">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            </div>
          ) : conversations.length === 0 ? (
            <div className="text-center py-12 px-4">
              <svg className="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
              <h3 className="text-lg font-medium text-gray-900 mb-2">Henüz mesajınız yok</h3>
              <p className="text-gray-600">Ustalarla mesajlaşmaya başlamak için onların profilinden iletişime geçin.</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-200">
              {conversations.map((conversation) => (
                <button
                  key={conversation.partner_id}
                  onClick={() => navigate(`/messages/${conversation.partner_id}`)}
                  className="w-full p-4 text-left hover:bg-gray-50 focus:outline-none focus:bg-gray-50"
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                      <svg className="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                      </svg>
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between">
                        <p className="text-sm font-medium text-gray-900 truncate">
                          {conversation.partner_name}
                        </p>
                        <p className="text-xs text-gray-500">
                          {formatTime(conversation.last_message?.created_at)}
                        </p>
                      </div>
                      <div className="flex items-center justify-between">
                        <p className="text-sm text-gray-600 truncate">
                          {conversation.last_message?.content}
                        </p>
                        {conversation.unread_count > 0 && (
                          <span className="inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white bg-red-600 rounded-full">
                            {conversation.unread_count}
                          </span>
                        )}
                      </div>
                      <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium mt-1 ${
                        conversation.partner_type === 'craftsman' 
                          ? 'bg-blue-100 text-blue-800' 
                          : 'bg-green-100 text-green-800'
                      }`}>
                        {conversation.partner_type === 'craftsman' ? 'Usta' : 'Müşteri'}
                      </span>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
    );
  }

  // Show conversation view
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center space-x-3">
            <button 
              onClick={() => navigate('/messages')}
              className="p-2 hover:bg-gray-100 rounded-full"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
              <svg className="w-5 h-5 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
              </svg>
            </div>
            <div className="flex-1">
              <h1 className="text-lg font-semibold text-gray-900">
                {selectedPartner?.name || 'Mesajlar'}
              </h1>
              {selectedPartner && (
                <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${
                  selectedPartner.type === 'craftsman' 
                    ? 'bg-blue-100 text-blue-800' 
                    : 'bg-green-100 text-green-800'
                }`}>
                  {selectedPartner.type === 'craftsman' ? 'Usta' : 'Müşteri'}
                </span>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 max-w-md mx-auto w-full px-4 py-4 overflow-y-auto">
        {currentConversation.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Henüz mesaj yok. İlk mesajı gönderin!</p>
          </div>
        ) : (
          <div className="space-y-4">
            {currentConversation.map((message) => (
              <div
                key={message.id}
                className={`flex ${message.sender_id === user?.id ? 'justify-end' : 'justify-start'}`}
              >
                <div
                  className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                    message.sender_id === user?.id
                      ? 'bg-blue-500 text-white'
                      : 'bg-white text-gray-900 shadow-sm border'
                  }`}
                >
                  <p className="text-sm">{message.content}</p>
                  <p className={`text-xs mt-1 ${
                    message.sender_id === user?.id ? 'text-blue-100' : 'text-gray-500'
                  }`}>
                    {formatTime(message.created_at)}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Message Input */}
      <div className="bg-white border-t">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center space-x-2">
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
              placeholder="Mesajınızı yazın..."
              className="flex-1 px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <button
              onClick={sendMessage}
              disabled={sending || !newMessage.trim()}
              className="p-2 bg-blue-500 text-white rounded-full hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50"
            >
              {sending ? (
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
              ) : (
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
                </svg>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};