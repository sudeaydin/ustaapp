import { useState, useEffect, useCallback } from 'react';
import { ApiError } from '../utils/api';

// Custom hook for API calls
export const useApi = (apiFunction, dependencies = [], options = {}) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const { immediate = true, onSuccess, onError } = options;

  const execute = useCallback(async (...args) => {
    try {
      setLoading(true);
      setError(null);
      
      const result = await apiFunction(...args);
      setData(result);
      
      if (onSuccess) {
        onSuccess(result);
      }
      
      return result;
    } catch (err) {
      const apiError = err instanceof ApiError ? err : new ApiError(
        err.message || 'Beklenmeyen hata',
        err.status || 500,
        err.code || 'UNKNOWN_ERROR'
      );
      
      setError(apiError);
      
      if (onError) {
        onError(apiError);
      }
      
      throw apiError;
    } finally {
      setLoading(false);
    }
  }, dependencies);

  useEffect(() => {
    if (immediate) {
      execute();
    }
  }, [execute, immediate]);

  const retry = useCallback(() => {
    execute();
  }, [execute]);

  return {
    data,
    loading,
    error,
    execute,
    retry,
    refetch: execute,
  };
};

// Hook for paginated API calls
export const usePaginatedApi = (apiFunction, dependencies = [], options = {}) => {
  const [data, setData] = useState([]);
  const [pagination, setPagination] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const { perPage = 20, immediate = true, onSuccess, onError } = options;

  const execute = useCallback(async (pageNum = page, ...args) => {
    try {
      setLoading(true);
      setError(null);
      
      const result = await apiFunction({ page: pageNum, per_page: perPage, ...args[0] });
      
      if (pageNum === 1) {
        setData(result.data?.craftsmen || result.data?.items || []);
      } else {
        setData(prev => [...prev, ...(result.data?.craftsmen || result.data?.items || [])]);
      }
      
      setPagination(result.data?.pagination);
      setPage(pageNum);
      
      if (onSuccess) {
        onSuccess(result);
      }
      
      return result;
    } catch (err) {
      const apiError = err instanceof ApiError ? err : new ApiError(
        err.message || 'Beklenmeyen hata',
        err.status || 500,
        err.code || 'UNKNOWN_ERROR'
      );
      
      setError(apiError);
      
      if (onError) {
        onError(apiError);
      }
      
      throw apiError;
    } finally {
      setLoading(false);
    }
  }, [apiFunction, page, perPage, onSuccess, onError]);

  useEffect(() => {
    if (immediate) {
      execute(1);
    }
  }, dependencies);

  const loadMore = useCallback(() => {
    if (pagination?.has_next && !loading) {
      execute(page + 1);
    }
  }, [execute, pagination, page, loading]);

  const refresh = useCallback(() => {
    setPage(1);
    execute(1);
  }, [execute]);

  return {
    data,
    pagination,
    loading,
    error,
    page,
    loadMore,
    refresh,
    hasMore: pagination?.has_next || false,
    execute,
  };
};

// Hook for form submissions
export const useApiSubmit = (apiFunction, options = {}) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const { onSuccess, onError, resetOnSubmit = true } = options;

  const submit = useCallback(async (data) => {
    try {
      if (resetOnSubmit) {
        setError(null);
        setSuccess(false);
      }
      
      setLoading(true);
      
      const result = await apiFunction(data);
      setSuccess(true);
      
      if (onSuccess) {
        onSuccess(result);
      }
      
      return result;
    } catch (err) {
      const apiError = err instanceof ApiError ? err : new ApiError(
        err.message || 'Beklenmeyen hata',
        err.status || 500,
        err.code || 'UNKNOWN_ERROR'
      );
      
      setError(apiError);
      setSuccess(false);
      
      if (onError) {
        onError(apiError);
      }
      
      throw apiError;
    } finally {
      setLoading(false);
    }
  }, [apiFunction, onSuccess, onError, resetOnSubmit]);

  const reset = useCallback(() => {
    setError(null);
    setSuccess(false);
    setLoading(false);
  }, []);

  return {
    submit,
    loading,
    error,
    success,
    reset,
  };
};

// Hook for file uploads
export const useFileUpload = (uploadFunction, options = {}) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [progress, setProgress] = useState(0);
  const [success, setSuccess] = useState(false);
  const { onSuccess, onError, onProgress } = options;

  const upload = useCallback(async (file, additionalData = {}) => {
    try {
      setLoading(true);
      setError(null);
      setSuccess(false);
      setProgress(0);

      const formData = new FormData();
      formData.append('file', file);
      
      Object.keys(additionalData).forEach(key => {
        formData.append(key, additionalData[key]);
      });

      const result = await uploadFunction(formData, {
        onProgress: (progressValue) => {
          setProgress(progressValue);
          if (onProgress) {
            onProgress(progressValue);
          }
        }
      });

      setSuccess(true);
      setProgress(100);
      
      if (onSuccess) {
        onSuccess(result);
      }
      
      return result;
    } catch (err) {
      const apiError = err instanceof ApiError ? err : new ApiError(
        err.message || 'Upload hatası',
        err.status || 500,
        err.code || 'UPLOAD_ERROR'
      );
      
      setError(apiError);
      setSuccess(false);
      
      if (onError) {
        onError(apiError);
      }
      
      throw apiError;
    } finally {
      setLoading(false);
    }
  }, [uploadFunction, onSuccess, onError, onProgress]);

  const reset = useCallback(() => {
    setError(null);
    setSuccess(false);
    setLoading(false);
    setProgress(0);
  }, []);

  return {
    upload,
    loading,
    error,
    progress,
    success,
    reset,
  };
};

export default useApi;
