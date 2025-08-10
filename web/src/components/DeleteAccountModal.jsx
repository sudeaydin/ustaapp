import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';

const DeleteAccountModal = ({ isOpen, onClose }) => {
  const [confirmText, setConfirmText] = useState('');
  const [isDeleting, setIsDeleting] = useState(false);
  const { logout } = useAuth();

  const handleDeleteAccount = async () => {
    if (confirmText !== 'HESABIMI SIL') {
      alert('Lütfen "HESABIMI SIL" yazarak onaylayın');
      return;
    }

    setIsDeleting(true);
    
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/auth/delete-account', {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      const data = await response.json();

      if (data.success) {
        alert('Hesabınız başarıyla silindi. Güle güle!');
        logout();
        window.location.href = '/';
      } else {
        alert(data.message || 'Hesap silme işlemi başarısız oldu');
      }
    } catch (error) {
      console.error('Hesap silme hatası:', error);
      alert('Hesap silme işlemi sırasında bir hata oluştu');
    } finally {
      setIsDeleting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-md w-full p-6">
        <div className="text-center mb-6">
          <div className="text-red-500 text-6xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-gray-800 mb-2">
            Hesabımı Sil
          </h2>
          <p className="text-gray-600">
            Bu işlem geri alınamaz!
          </p>
        </div>

        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <h3 className="font-semibold text-red-800 mb-2">
            KVKK Uyarısı - Önemli Bilgilendirme:
          </h3>
          <ul className="text-sm text-red-700 space-y-1">
            <li>• Hesabınız kalıcı olarak silinecektir</li>
            <li>• Tüm kişisel verileriniz sistemden kaldırılacaktır</li>
            <li>• Mesaj geçmişiniz silinecektir</li>
            <li>• Ödeme geçmişiniz silinecektir</li>
            <li>• Bu işlem geri alınamaz</li>
          </ul>
        </div>

        <div className="mb-6">
          <p className="text-gray-700 mb-3">
            <strong>Hesabınızın kalıcı olarak silinmesini onaylıyor musunuz?</strong>
          </p>
          <p className="text-sm text-gray-600 mb-3">
            Onaylamak için aşağıya <strong>"HESABIMI SIL"</strong> yazın:
          </p>
          <input
            type="text"
            value={confirmText}
            onChange={(e) => setConfirmText(e.target.value)}
            placeholder="HESABIMI SIL"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
          />
        </div>

        <div className="flex space-x-3">
          <button
            onClick={onClose}
            disabled={isDeleting}
            className="flex-1 px-4 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400 transition-colors disabled:opacity-50"
          >
            İptal
          </button>
          <button
            onClick={handleDeleteAccount}
            disabled={isDeleting || confirmText !== 'HESABIMI SIL'}
            className="flex-1 px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isDeleting ? (
              <div className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Siliniyor...
              </div>
            ) : (
              'Hesabımı Sil'
            )}
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeleteAccountModal;