import { useState, useEffect, useCallback } from 'react';

// Custom hook for API calls
export const useApi = (apiFunction, dependencies = []) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const execute = useCallback(async (...params) => {
    try {
      setLoading(true);
      setError(null);
      const result = await apiFunction(...params);
      setData(result);
      return result;
    } catch (err) {
      setError(err.message || 'Bir hata oluştu');
      throw err;
    } finally {
      setLoading(false);
    }
  }, dependencies);

  useEffect(() => {
    if (dependencies.length === 0) {
      execute();
    }
  }, dependencies);

  const refetch = useCallback(() => {
    return execute();
  }, [execute]);

  return {
    data,
    loading,
    error,
    execute,
    refetch
  };
};

// Hook for manual API calls
export const useApiCall = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const execute = useCallback(async (apiFunction, ...params) => {
    try {
      setLoading(true);
      setError(null);
      const result = await apiFunction(...params);
      return result;
    } catch (err) {
      setError(err.message || 'Bir hata oluştu');
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    loading,
    error,
    execute,
    clearError
  };
};

// Hook for paginated API calls
export const usePaginatedApi = (apiFunction, initialParams = {}) => {
  const [data, setData] = useState([]);
  const [pagination, setPagination] = useState({
    page: 1,
    pages: 1,
    total: 0,
    per_page: 10
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [hasMore, setHasMore] = useState(true);

  const loadPage = useCallback(async (page = 1, append = false) => {
    try {
      setLoading(true);
      setError(null);
      
      const params = {
        ...initialParams,
        page,
        per_page: pagination.per_page
      };
      
      const result = await apiFunction(params);
      
      if (append && page > 1) {
        setData(prev => [...prev, ...result.data]);
      } else {
        setData(result.data || []);
      }
      
      setPagination(result.pagination || pagination);
      setHasMore(page < (result.pagination?.pages || 1));
      
      return result;
    } catch (err) {
      setError(err.message || 'Bir hata oluştu');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [apiFunction, initialParams, pagination.per_page]);

  const loadMore = useCallback(() => {
    if (hasMore && !loading) {
      return loadPage(pagination.page + 1, true);
    }
  }, [hasMore, loading, pagination.page, loadPage]);

  const refresh = useCallback(() => {
    return loadPage(1, false);
  }, [loadPage]);

  useEffect(() => {
    loadPage(1);
  }, []);

  return {
    data,
    pagination,
    loading,
    error,
    hasMore,
    loadMore,
    refresh,
    loadPage
  };
};

export default useApi;
