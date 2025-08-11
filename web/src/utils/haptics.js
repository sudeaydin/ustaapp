// Haptic feedback utility for mobile web
class HapticManager {
  constructor() {
    this.isSupported = 'vibrate' in navigator;
    this.isEnabled = this.getHapticPreference();
  }

  // Check if haptic feedback is supported
  isHapticSupported() {
    return this.isSupported;
  }

  // Get user preference for haptic feedback
  getHapticPreference() {
    const preference = localStorage.getItem('haptic_enabled');
    return preference !== null ? JSON.parse(preference) : true;
  }

  // Set user preference for haptic feedback
  setHapticPreference(enabled) {
    this.isEnabled = enabled;
    localStorage.setItem('haptic_enabled', JSON.stringify(enabled));
  }

  // Basic vibration patterns
  patterns = {
    light: [10],
    medium: [20],
    heavy: [30],
    success: [10, 50, 10],
    error: [20, 100, 20, 100, 20],
    warning: [15, 80, 15],
    notification: [10, 30, 10, 30, 10],
    click: [5],
    longPress: [25],
    swipe: [8],
    selection: [12],
    impact: [40],
    heartbeat: [10, 50, 10, 50],
    tick: [3],
  };

  // Trigger haptic feedback
  vibrate(pattern = 'light') {
    if (!this.isSupported || !this.isEnabled) {
      return false;
    }

    try {
      const vibrationPattern = typeof pattern === 'string' 
        ? this.patterns[pattern] || this.patterns.light
        : pattern;

      navigator.vibrate(vibrationPattern);
      return true;
    } catch (error) {
      console.warn('Haptic feedback failed:', error);
      return false;
    }
  }

  // Convenience methods for common interactions
  impact(intensity = 'medium') {
    return this.vibrate(intensity);
  }

  notification(type = 'success') {
    return this.vibrate(type);
  }

  selection() {
    return this.vibrate('selection');
  }

  click() {
    return this.vibrate('click');
  }

  longPress() {
    return this.vibrate('longPress');
  }

  swipe() {
    return this.vibrate('swipe');
  }

  error() {
    return this.vibrate('error');
  }

  success() {
    return this.vibrate('success');
  }

  warning() {
    return this.vibrate('warning');
  }

  // Stop all vibrations
  stop() {
    if (this.isSupported) {
      navigator.vibrate(0);
    }
  }

  // Custom pattern builder
  createPattern(durations) {
    if (!Array.isArray(durations)) {
      throw new Error('Pattern must be an array of durations');
    }
    return durations;
  }

  // Conditional haptic feedback based on user action
  onUserAction(actionType, data = {}) {
    const actionMap = {
      buttonPress: 'click',
      buttonLongPress: 'longPress',
      swipeLeft: 'swipe',
      swipeRight: 'swipe',
      swipeUp: 'swipe',
      swipeDown: 'swipe',
      pullToRefresh: 'medium',
      formSubmit: 'success',
      formError: 'error',
      itemSelect: 'selection',
      itemDeselect: 'tick',
      toggleOn: 'light',
      toggleOff: 'tick',
      modalOpen: 'light',
      modalClose: 'tick',
      tabSwitch: 'tick',
      pageTransition: 'light',
      notification: 'notification',
      alert: 'warning',
      confirmAction: 'medium',
      deleteAction: 'heavy',
      saveAction: 'success',
      cancelAction: 'tick',
    };

    const pattern = actionMap[actionType] || 'light';
    return this.vibrate(pattern);
  }

  // Adaptive haptic feedback based on context
  contextualFeedback(context, action) {
    const contextPatterns = {
      messaging: {
        send: 'success',
        receive: 'light',
        typing: 'tick',
      },
      navigation: {
        forward: 'light',
        back: 'tick',
        swipe: 'swipe',
      },
      forms: {
        focus: 'tick',
        blur: null,
        submit: 'success',
        error: 'error',
        validate: 'light',
      },
      jobs: {
        accept: 'success',
        reject: 'warning',
        complete: 'success',
        start: 'medium',
        pause: 'light',
      },
      quotes: {
        request: 'medium',
        receive: 'notification',
        accept: 'success',
        reject: 'warning',
      }
    };

    const pattern = contextPatterns[context]?.[action];
    if (pattern) {
      return this.vibrate(pattern);
    }
    return false;
  }
}

// Create singleton instance
const haptics = new HapticManager();

// React hook for haptic feedback
export const useHaptics = () => {
  const triggerHaptic = (pattern) => haptics.vibrate(pattern);
  const triggerAction = (actionType, data) => haptics.onUserAction(actionType, data);
  const triggerContextual = (context, action) => haptics.contextualFeedback(context, action);

  return {
    isSupported: haptics.isHapticSupported(),
    isEnabled: haptics.isEnabled,
    setEnabled: (enabled) => haptics.setHapticPreference(enabled),
    vibrate: triggerHaptic,
    impact: haptics.impact.bind(haptics),
    notification: haptics.notification.bind(haptics),
    selection: haptics.selection.bind(haptics),
    click: haptics.click.bind(haptics),
    longPress: haptics.longPress.bind(haptics),
    swipe: haptics.swipe.bind(haptics),
    error: haptics.error.bind(haptics),
    success: haptics.success.bind(haptics),
    warning: haptics.warning.bind(haptics),
    stop: haptics.stop.bind(haptics),
    onAction: triggerAction,
    onContextual: triggerContextual,
    patterns: haptics.patterns,
  };
};

// Higher-order component for adding haptic feedback to components
export const withHaptics = (WrappedComponent, hapticConfig = {}) => {
  return function HapticComponent(props) {
    const haptics = useHaptics();
    
    const enhancedProps = {
      ...props,
      haptics,
      onHapticClick: (e) => {
        haptics.click();
        props.onClick?.(e);
      },
      onHapticLongPress: (e) => {
        haptics.longPress();
        props.onLongPress?.(e);
      },
    };

    return <WrappedComponent {...enhancedProps} />;
  };
};

export default haptics;