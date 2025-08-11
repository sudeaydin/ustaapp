import { useEffect, useRef, useState } from 'react';

export const useGestures = (options = {}) => {
  const {
    onSwipeLeft,
    onSwipeRight,
    onSwipeUp,
    onSwipeDown,
    onTap,
    onDoubleTap,
    onLongPress,
    onPinch,
    swipeThreshold = 50,
    tapTimeout = 300,
    longPressTimeout = 500,
    doubleTapTimeout = 300,
  } = options;

  const elementRef = useRef(null);
  const [gestureState, setGestureState] = useState({
    startX: 0,
    startY: 0,
    endX: 0,
    endY: 0,
    startTime: 0,
    isPressed: false,
    lastTap: 0,
    touches: [],
    initialDistance: 0,
    currentDistance: 0,
  });

  const longPressTimer = useRef(null);
  const tapTimer = useRef(null);

  useEffect(() => {
    const element = elementRef.current;
    if (!element) return;

    const handleTouchStart = (e) => {
      const touch = e.touches[0];
      const now = Date.now();
      
      setGestureState(prev => ({
        ...prev,
        startX: touch.clientX,
        startY: touch.clientY,
        startTime: now,
        isPressed: true,
        touches: Array.from(e.touches),
      }));

      // Calculate initial distance for pinch
      if (e.touches.length === 2) {
        const touch1 = e.touches[0];
        const touch2 = e.touches[1];
        const distance = Math.sqrt(
          Math.pow(touch2.clientX - touch1.clientX, 2) +
          Math.pow(touch2.clientY - touch1.clientY, 2)
        );
        setGestureState(prev => ({
          ...prev,
          initialDistance: distance,
          currentDistance: distance,
        }));
      }

      // Start long press timer
      if (onLongPress) {
        longPressTimer.current = setTimeout(() => {
          onLongPress(e);
        }, longPressTimeout);
      }
    };

    const handleTouchMove = (e) => {
      if (!gestureState.isPressed) return;

      const touch = e.touches[0];
      setGestureState(prev => ({
        ...prev,
        endX: touch.clientX,
        endY: touch.clientY,
      }));

      // Handle pinch
      if (e.touches.length === 2 && onPinch) {
        const touch1 = e.touches[0];
        const touch2 = e.touches[1];
        const distance = Math.sqrt(
          Math.pow(touch2.clientX - touch1.clientX, 2) +
          Math.pow(touch2.clientY - touch1.clientY, 2)
        );
        
        const scale = distance / gestureState.initialDistance;
        onPinch({
          scale,
          distance,
          initialDistance: gestureState.initialDistance,
          center: {
            x: (touch1.clientX + touch2.clientX) / 2,
            y: (touch1.clientY + touch2.clientY) / 2,
          }
        });
        
        setGestureState(prev => ({
          ...prev,
          currentDistance: distance,
        }));
      }

      // Clear long press timer on move
      if (longPressTimer.current) {
        clearTimeout(longPressTimer.current);
        longPressTimer.current = null;
      }
    };

    const handleTouchEnd = (e) => {
      const now = Date.now();
      const deltaX = gestureState.endX - gestureState.startX;
      const deltaY = gestureState.endY - gestureState.startY;
      const deltaTime = now - gestureState.startTime;
      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

      // Clear timers
      if (longPressTimer.current) {
        clearTimeout(longPressTimer.current);
        longPressTimer.current = null;
      }

      // Handle swipes
      if (distance > swipeThreshold) {
        const angle = Math.atan2(deltaY, deltaX) * 180 / Math.PI;
        
        if (Math.abs(angle) <= 45) {
          // Swipe right
          onSwipeRight?.(e);
        } else if (Math.abs(angle) >= 135) {
          // Swipe left
          onSwipeLeft?.(e);
        } else if (angle > 45 && angle < 135) {
          // Swipe down
          onSwipeDown?.(e);
        } else if (angle < -45 && angle > -135) {
          // Swipe up
          onSwipeUp?.(e);
        }
      } else if (deltaTime < tapTimeout && distance < 10) {
        // Handle taps
        const timeSinceLastTap = now - gestureState.lastTap;
        
        if (timeSinceLastTap < doubleTapTimeout && timeSinceLastTap > 0) {
          // Double tap
          if (tapTimer.current) {
            clearTimeout(tapTimer.current);
            tapTimer.current = null;
          }
          onDoubleTap?.(e);
        } else {
          // Single tap (delayed to check for double tap)
          if (onTap) {
            tapTimer.current = setTimeout(() => {
              onTap(e);
            }, doubleTapTimeout);
          }
        }
        
        setGestureState(prev => ({
          ...prev,
          lastTap: now,
        }));
      }

      setGestureState(prev => ({
        ...prev,
        isPressed: false,
        touches: [],
      }));
    };

    const handleTouchCancel = () => {
      if (longPressTimer.current) {
        clearTimeout(longPressTimer.current);
        longPressTimer.current = null;
      }
      
      if (tapTimer.current) {
        clearTimeout(tapTimer.current);
        tapTimer.current = null;
      }

      setGestureState(prev => ({
        ...prev,
        isPressed: false,
        touches: [],
      }));
    };

    // Mouse events for desktop testing
    const handleMouseDown = (e) => {
      const now = Date.now();
      setGestureState(prev => ({
        ...prev,
        startX: e.clientX,
        startY: e.clientY,
        startTime: now,
        isPressed: true,
      }));
    };

    const handleMouseMove = (e) => {
      if (!gestureState.isPressed) return;
      setGestureState(prev => ({
        ...prev,
        endX: e.clientX,
        endY: e.clientY,
      }));
    };

    const handleMouseUp = (e) => {
      const now = Date.now();
      const deltaX = gestureState.endX - gestureState.startX;
      const deltaY = gestureState.endY - gestureState.startY;
      const deltaTime = now - gestureState.startTime;
      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

      if (distance > swipeThreshold) {
        const angle = Math.atan2(deltaY, deltaX) * 180 / Math.PI;
        
        if (Math.abs(angle) <= 45) {
          onSwipeRight?.(e);
        } else if (Math.abs(angle) >= 135) {
          onSwipeLeft?.(e);
        } else if (angle > 45 && angle < 135) {
          onSwipeDown?.(e);
        } else if (angle < -45 && angle > -135) {
          onSwipeUp?.(e);
        }
      } else if (deltaTime < tapTimeout && distance < 10) {
        onTap?.(e);
      }

      setGestureState(prev => ({
        ...prev,
        isPressed: false,
      }));
    };

    // Add event listeners
    element.addEventListener('touchstart', handleTouchStart, { passive: false });
    element.addEventListener('touchmove', handleTouchMove, { passive: false });
    element.addEventListener('touchend', handleTouchEnd, { passive: false });
    element.addEventListener('touchcancel', handleTouchCancel, { passive: false });
    
    // Mouse events for desktop
    element.addEventListener('mousedown', handleMouseDown);
    element.addEventListener('mousemove', handleMouseMove);
    element.addEventListener('mouseup', handleMouseUp);

    return () => {
      element.removeEventListener('touchstart', handleTouchStart);
      element.removeEventListener('touchmove', handleTouchMove);
      element.removeEventListener('touchend', handleTouchEnd);
      element.removeEventListener('touchcancel', handleTouchCancel);
      element.removeEventListener('mousedown', handleMouseDown);
      element.removeEventListener('mousemove', handleMouseMove);
      element.removeEventListener('mouseup', handleMouseUp);
      
      if (longPressTimer.current) {
        clearTimeout(longPressTimer.current);
      }
      if (tapTimer.current) {
        clearTimeout(tapTimer.current);
      }
    };
  }, [gestureState, options]);

  return elementRef;
};

// Gesture utilities
export const useSwipeNavigation = (onSwipeLeft, onSwipeRight) => {
  return useGestures({
    onSwipeLeft,
    onSwipeRight,
    swipeThreshold: 100,
  });
};

export const usePullToRefresh = (onRefresh) => {
  const [isPulling, setIsPulling] = useState(false);
  const [pullDistance, setPullDistance] = useState(0);
  
  const gestureRef = useGestures({
    onSwipeDown: (e) => {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      if (scrollTop === 0) {
        setIsPulling(true);
        // Trigger haptic feedback if available
        if (navigator.vibrate) {
          navigator.vibrate(50);
        }
        onRefresh?.();
        setTimeout(() => setIsPulling(false), 1000);
      }
    },
    swipeThreshold: 80,
  });

  return { gestureRef, isPulling, pullDistance };
};

export const useDoubleTapZoom = (onZoomIn, onZoomOut) => {
  const [zoomLevel, setZoomLevel] = useState(1);
  
  const gestureRef = useGestures({
    onDoubleTap: () => {
      const newZoomLevel = zoomLevel === 1 ? 2 : 1;
      setZoomLevel(newZoomLevel);
      if (newZoomLevel > 1) {
        onZoomIn?.(newZoomLevel);
      } else {
        onZoomOut?.(newZoomLevel);
      }
    },
    onPinch: ({ scale }) => {
      const newZoomLevel = Math.max(0.5, Math.min(3, scale));
      setZoomLevel(newZoomLevel);
    },
  });

  return { gestureRef, zoomLevel };
};