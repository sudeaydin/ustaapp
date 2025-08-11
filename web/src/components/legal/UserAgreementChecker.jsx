import React, { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import UserAgreementModal from './UserAgreementModal';
import api from '../../utils/api';

/**
 * Component that checks if user has accepted mandatory agreements
 * and shows the agreement modal if needed
 */
function UserAgreementChecker() {
  const { user } = useAuth();
  const [showModal, setShowModal] = useState(false);
  const [isChecking, setIsChecking] = useState(false);

  useEffect(() => {
    // Only check for logged-in users
    if (user && !isChecking) {
      checkUserAgreement();
    }
  }, [user]);

  const checkUserAgreement = async () => {
    setIsChecking(true);
    
    try {
      // Check if user has given mandatory consents
      const consentsResponse = await api.getUserConsents();
      const consents = consentsResponse.data || [];
      
      // Check for mandatory consent
      const mandatoryConsent = consents.find(c => c.consent_type === 'mandatory');
      const hasAcceptedAgreement = localStorage.getItem('user_agreement_accepted') === 'true';
      
      // Show modal if no mandatory consent or agreement not accepted
      if (!mandatoryConsent || !mandatoryConsent.granted || !hasAcceptedAgreement) {
        setShowModal(true);
      }
    } catch (error) {
      // If we can't check consents, assume user needs to accept
      console.warn('Could not check user consents:', error);
      const hasAcceptedAgreement = localStorage.getItem('user_agreement_accepted') === 'true';
      if (!hasAcceptedAgreement) {
        setShowModal(true);
      }
    } finally {
      setIsChecking(false);
    }
  };

  const handleAgreementAccepted = () => {
    localStorage.setItem('user_agreement_accepted', 'true');
    setShowModal(false);
  };

  const handleAgreementRejected = () => {
    // User rejected agreement - log them out
    localStorage.removeItem('authToken');
    localStorage.removeItem('userType');
    localStorage.removeItem('userId');
    localStorage.removeItem('user_agreement_accepted');
    window.location.href = '/login';
  };

  if (!showModal) {
    return null;
  }

  return (
    <UserAgreementModal
      isOpen={showModal}
      onAccept={handleAgreementAccepted}
      onReject={handleAgreementRejected}
    />
  );
}

export default UserAgreementChecker;