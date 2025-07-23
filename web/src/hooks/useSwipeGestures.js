import { useState, useEffect, useRef } from 'react';

export const useSwipeGestures = (onSwipeLeft, onSwipeRight, onSwipeUp, onSwipeDown) => {
  const [touchStart, setTouchStart] = useState(null);
  const [touchEnd, setTouchEnd] = useState(null);
  const elementRef = useRef(null);

  const minSwipeDistance = 50;

  const onTouchStart = (e) => {
    setTouchEnd(null);
    setTouchStart({
      x: e.targetTouches[0].clientX,
      y: e.targetTouches[0].clientY
    });
  };

  const onTouchMove = (e) => {
    setTouchEnd({
      x: e.targetTouches[0].clientX,
      y: e.targetTouches[0].clientY
    });
  };

  const onTouchEnd = () => {
    if (!touchStart || !touchEnd) return;

    const distanceX = touchStart.x - touchEnd.x;
    const distanceY = touchStart.y - touchEnd.y;
    const isLeftSwipe = distanceX > minSwipeDistance;
    const isRightSwipe = distanceX < -minSwipeDistance;
    const isUpSwipe = distanceY > minSwipeDistance;
    const isDownSwipe = distanceY < -minSwipeDistance;

    // Determine if horizontal or vertical swipe is more prominent
    if (Math.abs(distanceX) > Math.abs(distanceY)) {
      // Horizontal swipe
      if (isLeftSwipe && onSwipeLeft) {
        onSwipeLeft();
      }
      if (isRightSwipe && onSwipeRight) {
        onSwipeRight();
      }
    } else {
      // Vertical swipe
      if (isUpSwipe && onSwipeUp) {
        onSwipeUp();
      }
      if (isDownSwipe && onSwipeDown) {
        onSwipeDown();
      }
    }
  };

  useEffect(() => {
    const element = elementRef.current;
    if (!element) return;

    element.addEventListener('touchstart', onTouchStart);
    element.addEventListener('touchmove', onTouchMove);
    element.addEventListener('touchend', onTouchEnd);

    return () => {
      element.removeEventListener('touchstart', onTouchStart);
      element.removeEventListener('touchmove', onTouchMove);
      element.removeEventListener('touchend', onTouchEnd);
    };
  }, [touchStart, touchEnd]);

  return elementRef;
};

export const usePinchZoom = (onZoomIn, onZoomOut) => {
  const [initialDistance, setInitialDistance] = useState(null);
  const elementRef = useRef(null);

  const getDistance = (touch1, touch2) => {
    const dx = touch1.clientX - touch2.clientX;
    const dy = touch1.clientY - touch2.clientY;
    return Math.sqrt(dx * dx + dy * dy);
  };

  const onTouchStart = (e) => {
    if (e.touches.length === 2) {
      const distance = getDistance(e.touches[0], e.touches[1]);
      setInitialDistance(distance);
    }
  };

  const onTouchMove = (e) => {
    if (e.touches.length === 2 && initialDistance) {
      e.preventDefault(); // Prevent default zoom
      const currentDistance = getDistance(e.touches[0], e.touches[1]);
      const scale = currentDistance / initialDistance;

      if (scale > 1.1 && onZoomIn) {
        onZoomIn(scale);
        setInitialDistance(currentDistance);
      } else if (scale < 0.9 && onZoomOut) {
        onZoomOut(scale);
        setInitialDistance(currentDistance);
      }
    }
  };

  const onTouchEnd = () => {
    setInitialDistance(null);
  };

  useEffect(() => {
    const element = elementRef.current;
    if (!element) return;

    element.addEventListener('touchstart', onTouchStart);
    element.addEventListener('touchmove', onTouchMove, { passive: false });
    element.addEventListener('touchend', onTouchEnd);

    return () => {
      element.removeEventListener('touchstart', onTouchStart);
      element.removeEventListener('touchmove', onTouchMove);
      element.removeEventListener('touchend', onTouchEnd);
    };
  }, [initialDistance]);

  return elementRef;
};

export const useLongPress = (onLongPress, delay = 500) => {
  const [longPressTriggered, setLongPressTriggered] = useState(false);
  const timeout = useRef();
  const target = useRef();

  const start = (event) => {
    if (event.target) {
      target.current = event.target;
    }
    timeout.current = setTimeout(() => {
      onLongPress(event);
      setLongPressTriggered(true);
    }, delay);
  };

  const clear = (event, shouldTriggerClick = true) => {
    timeout.current && clearTimeout(timeout.current);
    shouldTriggerClick && !longPressTriggered && onClick && onClick(event);
    setLongPressTriggered(false);
  };

  return {
    onMouseDown: start,
    onTouchStart: start,
    onMouseUp: clear,
    onMouseLeave: clear,
    onTouchEnd: clear
  };
};

export default useSwipeGestures;