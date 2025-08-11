import React, { forwardRef } from 'react';
import { useHaptics } from '../../utils/haptics';
import { useTheme } from '../../context/ThemeContext';

const Button = forwardRef(({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  loading = false,
  hapticFeedback = true,
  hapticPattern = 'click',
  className = '',
  onClick,
  onLongPress,
  ...props
}, ref) => {
  const { click: hapticClick, longPress: hapticLongPress } = useHaptics();
  const { colors } = useTheme();

  const handleClick = (e) => {
    if (disabled || loading) return;
    
    if (hapticFeedback) {
      hapticClick();
    }
    
    onClick?.(e);
  };

  const handleLongPress = (e) => {
    if (disabled || loading) return;
    
    if (hapticFeedback) {
      hapticLongPress();
    }
    
    onLongPress?.(e);
  };

  // Variant styles
  const variantStyles = {
    primary: 'bg-poppy-500 hover:bg-poppy-600 text-white shadow-md hover:shadow-lg dark:bg-poppy-600 dark:hover:bg-poppy-700',
    secondary: 'bg-delft-blue-500 hover:bg-delft-blue-600 text-white shadow-md hover:shadow-lg dark:bg-delft-blue-600 dark:hover:bg-delft-blue-700',
    outline: 'border-2 border-poppy-500 text-poppy-500 hover:bg-poppy-500 hover:text-white dark:border-poppy-400 dark:text-poppy-400 dark:hover:bg-poppy-400 dark:hover:text-white',
    ghost: 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800',
    danger: 'bg-red-500 hover:bg-red-600 text-white shadow-md hover:shadow-lg dark:bg-red-600 dark:hover:bg-red-700',
    success: 'bg-green-500 hover:bg-green-600 text-white shadow-md hover:shadow-lg dark:bg-green-600 dark:hover:bg-green-700',
    warning: 'bg-yellow-500 hover:bg-yellow-600 text-white shadow-md hover:shadow-lg dark:bg-yellow-600 dark:hover:bg-yellow-700',
    info: 'bg-blue-500 hover:bg-blue-600 text-white shadow-md hover:shadow-lg dark:bg-blue-600 dark:hover:bg-blue-700',
  };

  // Size styles
  const sizeStyles = {
    xs: 'px-2 py-1 text-xs',
    sm: 'px-3 py-2 text-sm',
    md: 'px-4 py-3 text-base',
    lg: 'px-6 py-4 text-lg',
    xl: 'px-8 py-5 text-xl',
  };

  const baseStyles = 'inline-flex items-center justify-center font-medium rounded-xl transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-poppy-500 dark:focus:ring-offset-gray-900 disabled:opacity-50 disabled:cursor-not-allowed transform active:scale-95';

  const combinedClassName = [
    baseStyles,
    variantStyles[variant],
    sizeStyles[size],
    disabled && 'cursor-not-allowed opacity-50',
    loading && 'cursor-wait',
    className
  ].filter(Boolean).join(' ');

  return (
    <button
      ref={ref}
      className={combinedClassName}
      disabled={disabled || loading}
      onClick={handleClick}
      onContextMenu={handleLongPress}
      {...props}
    >
      {loading && (
        <svg
          className="animate-spin -ml-1 mr-3 h-5 w-5 text-current"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          />
        </svg>
      )}
      {children}
    </button>
  );
});

Button.displayName = 'Button';

export default Button;