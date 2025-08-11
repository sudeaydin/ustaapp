import React, { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import { useTheme } from '../../context/ThemeContext';

const OnboardingTutorial = ({ onComplete }) => {
  const { user } = useAuth();
  const { t } = useLanguage();
  const { isDarkMode } = useTheme();
  const [currentStep, setCurrentStep] = useState(0);
  const [isVisible, setIsVisible] = useState(false);

  // Check if user has completed onboarding
  useEffect(() => {
    const hasCompletedOnboarding = localStorage.getItem(`onboarding_completed_${user?.id}`);
    if (!hasCompletedOnboarding && user) {
      setIsVisible(true);
    }
  }, [user]);

  const customerSteps = [
    {
      id: 'welcome',
      title: 'Hoş Geldiniz! 👋',
      description: 'UstamApp\'e hoş geldiniz! Size platformu tanıtmak istiyoruz.',
      target: null,
      position: 'center'
    },
    {
      id: 'dashboard',
      title: 'Dashboard\'unuz',
      description: 'Buradan tüm işlerinizi, tekliflerinizi ve mesajlarınızı takip edebilirsiniz.',
      target: '[data-tour="dashboard"]',
      position: 'bottom'
    },
    {
      id: 'search',
      title: 'Usta Arayın',
      description: 'İhtiyacınız olan ustayı kategorilere göre arayabilir ve filtreler kullanabilirsiniz.',
      target: '[data-tour="search"]',
      position: 'bottom'
    },
    {
      id: 'messages',
      title: 'Mesajlaşma',
      description: 'Ustalarla doğrudan mesajlaşabilir, teklif alabilir ve iş detaylarını konuşabilirsiniz.',
      target: '[data-tour="messages"]',
      position: 'bottom'
    },
    {
      id: 'profile',
      title: 'Profiliniz',
      description: 'Profil bilgilerinizi güncelleyebilir ve hesap ayarlarınızı yönetebilirsiniz.',
      target: '[data-tour="profile"]',
      position: 'bottom'
    }
  ];

  const craftsmanSteps = [
    {
      id: 'welcome',
      title: 'Usta Paneline Hoş Geldiniz! 🔨',
      description: 'UstamApp usta paneline hoş geldiniz! İşinizi büyütmenize yardımcı olacağız.',
      target: null,
      position: 'center'
    },
    {
      id: 'dashboard',
      title: 'Usta Dashboard\'u',
      description: 'Buradan gelen talepleri, aktif işlerinizi ve kazançlarınızı takip edebilirsiniz.',
      target: '[data-tour="dashboard"]',
      position: 'bottom'
    },
    {
      id: 'business-profile',
      title: 'İşletme Profiliniz',
      description: 'İşletme bilgilerinizi, portfolyonuzu ve hizmetlerinizi buradan yönetebilirsiniz.',
      target: '[data-tour="business-profile"]',
      position: 'bottom'
    },
    {
      id: 'quotes',
      title: 'Teklif Sistemi',
      description: 'Müşteri taleplerine teklif verebilir, detay isteyebilir veya reddedebilirsiniz.',
      target: '[data-tour="quotes"]',
      position: 'bottom'
    },
    {
      id: 'jobs',
      title: 'İş Takibi',
      description: 'Kabul ettiğiniz işleri takip edebilir, zaman kaydı tutabilir ve ilerleme raporlayabilirsiniz.',
      target: '[data-tour="jobs"]',
      position: 'bottom'
    }
  ];

  const steps = user?.user_type === 'craftsman' ? craftsmanSteps : customerSteps;

  const nextStep = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      completeTutorial();
    }
  };

  const prevStep = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const skipTutorial = () => {
    completeTutorial();
  };

  const completeTutorial = () => {
    localStorage.setItem(`onboarding_completed_${user?.id}`, 'true');
    setIsVisible(false);
    if (onComplete) {
      onComplete();
    }
  };

  const getStepPosition = (step) => {
    if (!step.target) return { top: '50%', left: '50%', transform: 'translate(-50%, -50%)' };
    
    const element = document.querySelector(step.target);
    if (!element) return { top: '50%', left: '50%', transform: 'translate(-50%, -50%)' };
    
    const rect = element.getBoundingClientRect();
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
    
    switch (step.position) {
      case 'top':
        return {
          top: rect.top + scrollTop - 10,
          left: rect.left + scrollLeft + rect.width / 2,
          transform: 'translate(-50%, -100%)'
        };
      case 'bottom':
        return {
          top: rect.bottom + scrollTop + 10,
          left: rect.left + scrollLeft + rect.width / 2,
          transform: 'translate(-50%, 0)'
        };
      case 'left':
        return {
          top: rect.top + scrollTop + rect.height / 2,
          left: rect.left + scrollLeft - 10,
          transform: 'translate(-100%, -50%)'
        };
      case 'right':
        return {
          top: rect.top + scrollTop + rect.height / 2,
          left: rect.right + scrollLeft + 10,
          transform: 'translate(0, -50%)'
        };
      default:
        return {
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)'
        };
    }
  };

  if (!isVisible || !user) return null;

  const currentStepData = steps[currentStep];
  const position = getStepPosition(currentStepData);

  return (
    <>
      {/* Overlay */}
      <div className="fixed inset-0 bg-black bg-opacity-60 z-50 transition-opacity duration-300">
        {/* Highlight target element */}
        {currentStepData.target && (
          <div
            className="absolute border-4 border-blue-400 rounded-lg pointer-events-none transition-all duration-300"
            style={{
              ...(() => {
                const element = document.querySelector(currentStepData.target);
                if (!element) return {};
                const rect = element.getBoundingClientRect();
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
                return {
                  top: rect.top + scrollTop - 4,
                  left: rect.left + scrollLeft - 4,
                  width: rect.width + 8,
                  height: rect.height + 8,
                };
              })()
            }}
          />
        )}
        
        {/* Tutorial Card */}
        <div
          className="absolute bg-white dark:bg-gray-800 rounded-xl shadow-2xl p-6 max-w-sm w-full mx-4 transition-all duration-300"
          style={position}
        >
          {/* Progress Bar */}
          <div className="mb-4">
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm font-medium text-gray-600 dark:text-gray-400">
                Adım {currentStep + 1} / {steps.length}
              </span>
              <button
                onClick={skipTutorial}
                className="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300"
              >
                Atla
              </button>
            </div>
            <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${((currentStep + 1) / steps.length) * 100}%` }}
              />
            </div>
          </div>

          {/* Content */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
              {currentStepData.title}
            </h3>
            <p className="text-gray-600 dark:text-gray-300 leading-relaxed">
              {currentStepData.description}
            </p>
          </div>

          {/* Navigation */}
          <div className="flex justify-between items-center">
            <button
              onClick={prevStep}
              disabled={currentStep === 0}
              className="px-4 py-2 text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {t('common.previous')}
            </button>
            
            <div className="flex space-x-1">
              {steps.map((_, index) => (
                <div
                  key={index}
                  className={`w-2 h-2 rounded-full transition-colors ${
                    index === currentStep
                      ? 'bg-blue-600'
                      : index < currentStep
                      ? 'bg-blue-300'
                      : 'bg-gray-300 dark:bg-gray-600'
                  }`}
                />
              ))}
            </div>
            
            <button
              onClick={nextStep}
              className="px-4 py-2 text-sm font-medium bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              {currentStep === steps.length - 1 ? t('common.finish') : t('common.next')}
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default OnboardingTutorial;