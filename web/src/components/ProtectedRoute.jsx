import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const ProtectedRoute = ({ children, requiredRole = null, allowGuest = false }) => {
  const { user, loading } = useAuth();
  const location = useLocation();

  // Loading state
  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Yetkilendirme kontrol ediliyor...</p>
        </div>
      </div>
    );
  }

  // Guest access allowed (public pages)
  if (allowGuest) {
    return children;
  }

  // No user - redirect to login
  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Role-based access control
  if (requiredRole && user.user_type !== requiredRole) {
    // Redirect to appropriate dashboard based on user type
    const redirectPath = user.user_type === 'customer' 
      ? '/dashboard/customer' 
      : '/dashboard/craftsman';
    
    return <Navigate to={redirectPath} replace />;
  }

  return children;
};

export const PublicRoute = ({ children }) => {
  return <ProtectedRoute allowGuest={true}>{children}</ProtectedRoute>;
};

export const CustomerRoute = ({ children }) => {
  return <ProtectedRoute requiredRole="customer">{children}</ProtectedRoute>;
};

export const CraftsmanRoute = ({ children }) => {
  return <ProtectedRoute requiredRole="craftsman">{children}</ProtectedRoute>;
};

export default ProtectedRoute;