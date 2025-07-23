// Responsive breakpoints (matching Tailwind CSS)
export const breakpoints = {
  sm: 640,   // Small screens
  md: 768,   // Medium screens (tablets)
  lg: 1024,  // Large screens (small laptops)
  xl: 1280,  // Extra large screens (desktops)
  '2xl': 1536 // 2X large screens (large desktops)
};

// Mobile detection
export const isMobile = () => {
  if (typeof window === 'undefined') return false;
  return window.innerWidth < breakpoints.md;
};

export const isTablet = () => {
  if (typeof window === 'undefined') return false;
  return window.innerWidth >= breakpoints.md && window.innerWidth < breakpoints.lg;
};

export const isDesktop = () => {
  if (typeof window === 'undefined') return false;
  return window.innerWidth >= breakpoints.lg;
};

// Touch device detection
export const isTouchDevice = () => {
  if (typeof window === 'undefined') return false;
  return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
};

// iOS detection
export const isIOS = () => {
  if (typeof window === 'undefined') return false;
  return /iPad|iPhone|iPod/.test(navigator.userAgent);
};

// Android detection
export const isAndroid = () => {
  if (typeof window === 'undefined') return false;
  return /Android/.test(navigator.userAgent);
};

// Safe area utilities for newer phones (iPhone X+)
export const getSafeAreaInsets = () => {
  if (typeof window === 'undefined') return { top: 0, bottom: 0, left: 0, right: 0 };
  
  const style = getComputedStyle(document.documentElement);
  return {
    top: parseInt(style.getPropertyValue('--safe-area-inset-top') || '0'),
    bottom: parseInt(style.getPropertyValue('--safe-area-inset-bottom') || '0'),
    left: parseInt(style.getPropertyValue('--safe-area-inset-left') || '0'),
    right: parseInt(style.getPropertyValue('--safe-area-inset-right') || '0')
  };
};

// Responsive hook
export const useResponsive = () => {
  const [screenSize, setScreenSize] = React.useState({
    width: typeof window !== 'undefined' ? window.innerWidth : 0,
    height: typeof window !== 'undefined' ? window.innerHeight : 0
  });

  React.useEffect(() => {
    if (typeof window === 'undefined') return;

    const handleResize = () => {
      setScreenSize({
        width: window.innerWidth,
        height: window.innerHeight
      });
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return {
    ...screenSize,
    isMobile: screenSize.width < breakpoints.md,
    isTablet: screenSize.width >= breakpoints.md && screenSize.width < breakpoints.lg,
    isDesktop: screenSize.width >= breakpoints.lg,
    isTouchDevice: isTouchDevice(),
    isIOS: isIOS(),
    isAndroid: isAndroid()
  };
};

// Responsive classes generator
export const getResponsiveClasses = (classes) => {
  const { mobile = '', tablet = '', desktop = '' } = classes;
  return `${mobile} md:${tablet} lg:${desktop}`.trim();
};

// Performance optimization for mobile
export const optimizeForMobile = () => {
  if (!isMobile()) return;

  // Disable hover effects on mobile
  document.body.classList.add('mobile-device');
  
  // Add viewport meta tag if not exists
  if (!document.querySelector('meta[name="viewport"]')) {
    const viewport = document.createElement('meta');
    viewport.name = 'viewport';
    viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
    document.head.appendChild(viewport);
  }
};

// Image optimization for different screen sizes
export const getOptimizedImageSrc = (baseSrc, size = 'md') => {
  const sizeMap = {
    sm: '_sm',   // 480w
    md: '_md',   // 768w
    lg: '_lg',   // 1024w
    xl: '_xl'    // 1280w
  };
  
  const suffix = sizeMap[size] || '';
  const extension = baseSrc.split('.').pop();
  const nameWithoutExt = baseSrc.substring(0, baseSrc.lastIndexOf('.'));
  
  return `${nameWithoutExt}${suffix}.${extension}`;
};

// Lazy loading utility
export const setupLazyLoading = () => {
  if ('IntersectionObserver' in window) {
    const lazyImages = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.classList.remove('lazy');
          imageObserver.unobserve(img);
        }
      });
    });

    lazyImages.forEach(img => imageObserver.observe(img));
  }
};

export default {
  breakpoints,
  isMobile,
  isTablet,
  isDesktop,
  isTouchDevice,
  isIOS,
  isAndroid,
  getSafeAreaInsets,
  useResponsive,
  getResponsiveClasses,
  optimizeForMobile,
  getOptimizedImageSrc,
  setupLazyLoading
};