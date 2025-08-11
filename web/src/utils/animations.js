import { useRef, useEffect } from 'react';

// Animation utilities and presets
export const animations = {
  // Entrance animations
  fadeIn: 'animate-fade-in',
  slideUp: 'animate-slide-up',
  slideDown: 'animate-slide-down',
  slideLeft: 'animate-slide-left',
  slideRight: 'animate-slide-right',
  scaleIn: 'animate-scale-in',
  bounceIn: 'animate-bounce-in',
  rotateIn: 'animate-rotate-in',
  flipIn: 'animate-flip-in',
  
  // Exit animations
  fadeOut: 'animate-fade-out',
  slideUpOut: 'animate-slide-up-out',
  slideDownOut: 'animate-slide-down-out',
  slideLeftOut: 'animate-slide-left-out',
  slideRightOut: 'animate-slide-right-out',
  scaleOut: 'animate-scale-out',
  bounceOut: 'animate-bounce-out',
  rotateOut: 'animate-rotate-out',
  flipOut: 'animate-flip-out',
  
  // Attention animations
  pulse: 'animate-pulse',
  bounce: 'animate-bounce',
  shake: 'animate-shake',
  wobble: 'animate-wobble',
  swing: 'animate-swing',
  tada: 'animate-tada',
  heartbeat: 'animate-heartbeat',
  
  // Loading animations
  spin: 'animate-spin',
  ping: 'animate-ping',
  
  // Hover animations
  hoverScale: 'hover:scale-105 transition-transform duration-200',
  hoverLift: 'hover:-translate-y-1 hover:shadow-lg transition-all duration-200',
  hoverGlow: 'hover:shadow-glow transition-shadow duration-200',
  hoverRotate: 'hover:rotate-3 transition-transform duration-200',
};

// Animation durations
export const durations = {
  fast: 'duration-150',
  normal: 'duration-200',
  slow: 'duration-300',
  slower: 'duration-500',
  slowest: 'duration-700',
};

// Easing functions
export const easings = {
  linear: 'ease-linear',
  in: 'ease-in',
  out: 'ease-out',
  inOut: 'ease-in-out',
  bounce: 'ease-bounce',
  elastic: 'ease-elastic',
};

// Animation presets for common UI patterns
export const presets = {
  modal: {
    enter: 'animate-scale-in',
    exit: 'animate-scale-out',
    backdrop: 'animate-fade-in',
  },
  dropdown: {
    enter: 'animate-slide-down',
    exit: 'animate-slide-up-out',
  },
  sidebar: {
    enterLeft: 'animate-slide-right',
    exitLeft: 'animate-slide-left-out',
    enterRight: 'animate-slide-left',
    exitRight: 'animate-slide-right-out',
  },
  toast: {
    enter: 'animate-slide-up',
    exit: 'animate-slide-down-out',
  },
  card: {
    hover: 'hover:scale-105 hover:-translate-y-2 hover:shadow-xl transition-all duration-200',
    tap: 'active:scale-95 transition-transform duration-100',
  },
  button: {
    hover: 'hover:scale-105 hover:shadow-lg transition-all duration-200',
    tap: 'active:scale-95 transition-transform duration-100',
    loading: 'animate-pulse',
  },
  list: {
    item: 'hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors duration-150',
    stagger: 'animate-slide-up',
  },
};

// React hook for managing animations
export const useAnimation = () => {
  const animate = (element, animationClass, options = {}) => {
    const {
      duration = durations.normal,
      easing = easings.inOut,
      onComplete,
      onStart,
      delay = 0,
    } = options;

    if (!element) return Promise.resolve();

    return new Promise((resolve) => {
      const cleanup = () => {
        element.classList.remove(animationClass, duration, easing);
        element.removeEventListener('animationend', handleAnimationEnd);
        element.removeEventListener('animationstart', handleAnimationStart);
      };

      const handleAnimationEnd = () => {
        cleanup();
        onComplete?.();
        resolve();
      };

      const handleAnimationStart = () => {
        onStart?.();
      };

      // Add animation classes
      element.classList.add(animationClass, duration, easing);
      
      // Add event listeners
      element.addEventListener('animationend', handleAnimationEnd, { once: true });
      element.addEventListener('animationstart', handleAnimationStart, { once: true });

      // Handle delay
      if (delay > 0) {
        element.style.animationDelay = `${delay}ms`;
      }
    });
  };

  const animateSequence = async (animations) => {
    for (const animation of animations) {
      await animate(animation.element, animation.class, animation.options);
    }
  };

  const staggerAnimation = (elements, animationClass, staggerDelay = 100) => {
    return Promise.all(
      elements.map((element, index) =>
        animate(element, animationClass, { delay: index * staggerDelay })
      )
    );
  };

  return {
    animate,
    animateSequence,
    staggerAnimation,
    animations,
    durations,
    easings,
    presets,
  };
};

// Performance-optimized animation utilities
export const performanceOptimized = {
  // Use transform instead of changing layout properties
  translateX: (element, distance) => {
    element.style.transform = `translateX(${distance}px)`;
  },
  
  translateY: (element, distance) => {
    element.style.transform = `translateY(${distance}px)`;
  },
  
  scale: (element, scale) => {
    element.style.transform = `scale(${scale})`;
  },
  
  rotate: (element, degrees) => {
    element.style.transform = `rotate(${degrees}deg)`;
  },
  
  // Batch DOM updates
  batchUpdate: (updates) => {
    requestAnimationFrame(() => {
      updates.forEach(update => update());
    });
  },
  
  // Smooth scroll with easing
  smoothScrollTo: (element, top, duration = 500) => {
    const start = element.scrollTop;
    const change = top - start;
    const startTime = performance.now();
    
    const animateScroll = (currentTime) => {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      // Easing function (ease-out-cubic)
      const easeOutCubic = 1 - Math.pow(1 - progress, 3);
      
      element.scrollTop = start + change * easeOutCubic;
      
      if (progress < 1) {
        requestAnimationFrame(animateScroll);
      }
    };
    
    requestAnimationFrame(animateScroll);
  },
};

// Intersection Observer for scroll animations
export const useScrollAnimation = (options = {}) => {
  const { threshold = 0.1, rootMargin = '0px', once = true } = options;
  
  const observe = (element, animationClass) => {
    if (!element) return;
    
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add(animationClass);
            if (once) {
              observer.unobserve(entry.target);
            }
          } else if (!once) {
            entry.target.classList.remove(animationClass);
          }
        });
      },
      { threshold, rootMargin }
    );
    
    observer.observe(element);
    return observer;
  };
  
  return { observe };
};

// React component for animated containers
export const AnimatedContainer = ({ 
  children, 
  animation = 'fadeIn', 
  duration = 'duration-300',
  delay = 0,
  className = '',
  ...props 
}) => {
  const containerRef = useRef(null);
  
  useEffect(() => {
    const element = containerRef.current;
    if (!element) return;
    
    if (delay > 0) {
      setTimeout(() => {
        element.classList.add(animations[animation], duration);
      }, delay);
    } else {
      element.classList.add(animations[animation], duration);
    }
  }, [animation, duration, delay]);
  
  return (
    <div ref={containerRef} className={className} {...props}>
      {children}
    </div>
  );
};

// Higher-order component for adding animations
export const withAnimation = (WrappedComponent, defaultAnimation = 'fadeIn') => {
  return function AnimatedComponent({ animation = defaultAnimation, ...props }) {
    return (
      <AnimatedContainer animation={animation}>
        <WrappedComponent {...props} />
      </AnimatedContainer>
    );
  };
};

export default animations;