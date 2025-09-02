// Production-safe logger utility
class Logger {
  static isDevelopment = import.meta.env.DEV || process.env.NODE_ENV === 'development';

  static log(...args) {
    if (this.isDevelopment) {
      console.log(...args);
    }
  }

  static warn(...args) {
    if (this.isDevelopment) {
      console.warn(...args);
    }
  }

  static error(...args) {
    // Always log errors, even in production
    console.error(...args);
  }

  static debug(...args) {
    if (this.isDevelopment) {
      console.debug(...args);
    }
  }

  static info(...args) {
    if (this.isDevelopment) {
      console.info(...args);
    }
  }
}

export default Logger;