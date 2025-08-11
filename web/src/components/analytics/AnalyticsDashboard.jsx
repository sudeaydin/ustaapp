import React, { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../utils/api';
import LoadingSpinner from '../ui/LoadingSpinner';
import ErrorMessage from '../ui/ErrorMessage';
import { formatDate, formatCurrency, formatPercentage } from '../../utils/formatters';
import CostCalculator from './CostCalculator';
import PerformanceChart from './PerformanceChart';
import TrendChart from './TrendChart';

const AnalyticsDashboard = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('overview');
  const [dashboardData, setDashboardData] = useState(null);
  const [realtimeMetrics, setRealtimeMetrics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedPeriod, setSelectedPeriod] = useState(30);
  const [constants, setConstants] = useState(null);

  useEffect(() => {
    loadConstants();
    loadDashboardData();
    loadRealtimeMetrics();
    
    // Set up real-time updates
    const interval = setInterval(loadRealtimeMetrics, 30000); // Update every 30 seconds
    return () => clearInterval(interval);
  }, [selectedPeriod]);

  const loadConstants = async () => {
    try {
      const response = await api.getAnalyticsDashboardConstants();
      setConstants(response.data);
    } catch (err) {
      console.error('Failed to load constants:', err);
    }
  };

  const loadDashboardData = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await api.getAnalyticsDashboard({ days: selectedPeriod });
      setDashboardData(response.data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const loadRealtimeMetrics = async () => {
    try {
      const response = await api.getRealtimeMetrics();
      setRealtimeMetrics(response.data);
    } catch (err) {
      console.error('Failed to load real-time metrics:', err);
    }
  };

  const getTabs = () => {
    const baseTabs = [
      { id: 'overview', label: 'Genel Bakış', icon: '📊' },
      { id: 'trends', label: 'Trendler', icon: '📈' },
      { id: 'cost-calculator', label: 'Maliyet Hesaplayıcı', icon: '💰' }
    ];

    if (user?.user_type === 'admin') {
      baseTabs.push(
        { id: 'business', label: 'İş Metrikleri', icon: '🏢' },
        { id: 'platform', label: 'Platform Analizi', icon: '🌐' }
      );
    }

    return baseTabs;
  };

  const renderOverviewTab = () => {
    if (!dashboardData) return null;

    const { overview, trends, top_categories, recent_activity, spending_trends, preferred_categories } = dashboardData;

    return (
      <div className="space-y-6">
        {/* Real-time Metrics */}
        {realtimeMetrics && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {Object.entries(realtimeMetrics.metrics).map(([key, value]) => (
              <div key={key} className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <div className="text-2xl font-bold text-blue-600">{value}</div>
                <div className="text-blue-800 text-sm capitalize">
                  {key.replace('_', ' ')}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Overview Metrics */}
        {overview && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            {user?.user_type === 'craftsman' ? (
              <>
                <MetricCard
                  title="Toplam Teklifler"
                  value={overview.total_quotes}
                  icon="📝"
                  color="blue"
                />
                <MetricCard
                  title="Kabul Oranı"
                  value={formatPercentage(overview.acceptance_rate)}
                  icon="✅"
                  color="green"
                />
                <MetricCard
                  title="Toplam Gelir"
                  value={formatCurrency(overview.total_revenue)}
                  icon="💰"
                  color="yellow"
                />
                <MetricCard
                  title="Ortalama Puan"
                  value={overview.avg_rating.toFixed(1)}
                  icon="⭐"
                  color="purple"
                />
              </>
            ) : (
              <>
                <MetricCard
                  title="Toplam Talepler"
                  value={overview.total_requests}
                  icon="📋"
                  color="blue"
                />
                <MetricCard
                  title="Tamamlanan İşler"
                  value={overview.completed_jobs}
                  icon="✅"
                  color="green"
                />
                <MetricCard
                  title="Toplam Harcama"
                  value={formatCurrency(overview.total_spent)}
                  icon="💰"
                  color="yellow"
                />
                <MetricCard
                  title="Ortalama İş Değeri"
                  value={formatCurrency(overview.avg_job_value)}
                  icon="📊"
                  color="purple"
                />
              </>
            )}
          </div>
        )}

        {/* Performance Chart */}
        {trends && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Performans Trendi</h3>
            <PerformanceChart data={trends} userType={user?.user_type} />
          </div>
        )}

        {/* Top Categories / Preferred Categories */}
        {(top_categories || preferred_categories) && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">
              {user?.user_type === 'craftsman' ? 'En İyi Kategoriler' : 'Tercih Edilen Kategoriler'}
            </h3>
            <div className="space-y-3">
              {(top_categories || preferred_categories)?.slice(0, 5).map((category, index) => (
                <div key={category.category} className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                  <div className="flex items-center">
                    <span className="text-lg mr-3">#{index + 1}</span>
                    <div>
                      <h4 className="font-medium">{category.category}</h4>
                      <p className="text-gray-600 text-sm">
                        {user?.user_type === 'craftsman' 
                          ? `${category.total_quotes} teklif, %${category.acceptance_rate.toFixed(1)} kabul`
                          : `${category.total_requests} talep, ${formatCurrency(category.total_spent)} harcama`
                        }
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-green-600">
                      {formatCurrency(user?.user_type === 'craftsman' ? category.revenue : category.total_spent)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Recent Activity */}
        {recent_activity && recent_activity.length > 0 && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Son Aktiviteler</h3>
            <div className="space-y-3">
              {recent_activity.slice(0, 10).map((activity) => (
                <div key={`${activity.type}-${activity.id}`} className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                  <div className="flex items-center">
                    <span className="text-lg mr-3">
                      {activity.type === 'quote' && '📝'}
                      {activity.type === 'job' && '🔧'}
                      {activity.type === 'message' && '💬'}
                    </span>
                    <div>
                      <h4 className="font-medium">{activity.title}</h4>
                      <p className="text-gray-600 text-sm">{activity.description}</p>
                      <p className="text-gray-500 text-xs">{activity.customer_name}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(activity.status)}`}>
                      {getStatusText(activity.status)}
                    </div>
                    <div className="text-gray-500 text-xs mt-1">
                      {formatDate(activity.date)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    );
  };

  const renderTrendsTab = () => {
    if (!dashboardData) return null;

    return (
      <div className="space-y-6">
        {/* Spending Trends for Customers */}
        {user?.user_type === 'customer' && dashboardData.spending_trends && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Harcama Trendi</h3>
            <TrendChart 
              data={dashboardData.spending_trends} 
              type="spending"
              chartColors={constants?.chart_colors}
            />
          </div>
        )}

        {/* Performance Trends for Craftsmen */}
        {user?.user_type === 'craftsman' && dashboardData.trends && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Performans Trendi</h3>
            <TrendChart 
              data={dashboardData.trends} 
              type="performance"
              chartColors={constants?.chart_colors}
            />
          </div>
        )}

        {/* Platform Trends for Admin */}
        {user?.user_type === 'admin' && dashboardData.platform_trends && (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow-lg p-6">
              <h3 className="text-lg font-semibold mb-4">Platform Büyümesi</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <MetricCard
                  title="Yeni Müşteriler"
                  value={dashboardData.platform_trends.new_customers}
                  icon="👥"
                  color="blue"
                />
                <MetricCard
                  title="Yeni Ustalar"
                  value={dashboardData.platform_trends.new_craftsmen}
                  icon="🔧"
                  color="green"
                />
                <MetricCard
                  title="Platform Geliri"
                  value={formatCurrency(dashboardData.platform_trends.platform_revenue)}
                  icon="💰"
                  color="yellow"
                />
              </div>
            </div>

            {/* Category Trends */}
            {dashboardData.category_trends && (
              <div className="bg-white rounded-lg shadow-lg p-6">
                <h3 className="text-lg font-semibold mb-4">Kategori Trendleri</h3>
                <div className="space-y-3">
                  {dashboardData.category_trends.slice(0, 8).map((trend) => (
                    <div key={trend.category} className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                      <div>
                        <h4 className="font-medium">{trend.category}</h4>
                        <p className="text-gray-600 text-sm">
                          {trend.quote_count} teklif, %{trend.acceptance_rate.toFixed(1)} kabul
                        </p>
                      </div>
                      <div className="text-right">
                        <div className="font-bold text-green-600">
                          {formatCurrency(trend.revenue)}
                        </div>
                        <div className="text-gray-500 text-xs">
                          Ort: {formatCurrency(trend.avg_price)}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    );
  };

  const renderCostCalculatorTab = () => {
    return (
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h3 className="text-lg font-semibold mb-4">Maliyet Hesaplayıcı</h3>
        <CostCalculator constants={constants} />
      </div>
    );
  };

  const renderBusinessTab = () => {
    if (user?.user_type !== 'admin' || !dashboardData) return null;

    return (
      <div className="space-y-6">
        {/* Conversion Funnel */}
        {dashboardData.conversion_funnel && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Dönüşüm Hunisi</h3>
            <div className="space-y-4">
              {Object.entries(dashboardData.conversion_funnel.stages).map(([stage, value]) => (
                <div key={stage} className="flex items-center justify-between">
                  <span className="capitalize">{stage.replace('_', ' ')}</span>
                  <span className="font-bold">{value}</span>
                </div>
              ))}
            </div>
            <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
              {Object.entries(dashboardData.conversion_funnel.conversion_rates).map(([rate, value]) => (
                <div key={rate} className="text-center p-3 border border-gray-200 rounded-lg">
                  <div className="text-xl font-bold text-blue-600">{formatPercentage(value)}</div>
                  <div className="text-gray-600 text-sm capitalize">{rate.replace('_', ' ')}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Revenue Analytics */}
        {dashboardData.revenue_analytics && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Gelir Analizi</h3>
            <div className="mb-6">
              <div className="text-3xl font-bold text-green-600">
                {formatCurrency(dashboardData.revenue_analytics.total_revenue)}
              </div>
              <div className="text-gray-600">Toplam Gelir ({selectedPeriod} gün)</div>
            </div>
            
            {/* Category Breakdown */}
            <div className="space-y-3">
              <h4 className="font-medium">Kategori Dağılımı</h4>
              {dashboardData.revenue_analytics.category_breakdown.slice(0, 5).map((category) => (
                <div key={category.category} className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                  <div>
                    <h5 className="font-medium">{category.category}</h5>
                    <p className="text-gray-600 text-sm">{category.job_count} iş</p>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-green-600">
                      {formatCurrency(category.revenue)}
                    </div>
                    <div className="text-gray-500 text-xs">
                      %{category.percentage.toFixed(1)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    );
  };

  const renderPlatformTab = () => {
    if (user?.user_type !== 'admin' || !dashboardData) return null;

    return (
      <div className="space-y-6">
        {/* Platform Overview */}
        {dashboardData.platform_trends && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <MetricCard
              title="Toplam Kullanıcı"
              value={dashboardData.platform_trends.new_customers + dashboardData.platform_trends.new_craftsmen}
              icon="👥"
              color="blue"
            />
            <MetricCard
              title="Toplam Teklifler"
              value={dashboardData.platform_trends.total_quotes}
              icon="📝"
              color="green"
            />
            <MetricCard
              title="Platform Geliri"
              value={formatCurrency(dashboardData.platform_trends.platform_revenue)}
              icon="💰"
              color="yellow"
            />
          </div>
        )}

        {/* Geographic Trends */}
        {dashboardData.geographic_trends && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Coğrafi Dağılım</h3>
            <div className="space-y-3">
              {dashboardData.geographic_trends.slice(0, 10).map((city) => (
                <div key={city.city} className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                  <div>
                    <h4 className="font-medium">{city.city}</h4>
                    <p className="text-gray-600 text-sm">{city.quote_count} teklif</p>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-green-600">
                      {formatCurrency(city.revenue)}
                    </div>
                    <div className="text-gray-500 text-xs">
                      Ort: {formatCurrency(city.avg_price)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    );
  };

  const getStatusColor = (status) => {
    const statusColors = {
      'pending': 'bg-yellow-100 text-yellow-800',
      'accepted': 'bg-green-100 text-green-800',
      'rejected': 'bg-red-100 text-red-800',
      'completed': 'bg-blue-100 text-blue-800',
      'in_progress': 'bg-purple-100 text-purple-800',
      'new': 'bg-blue-100 text-blue-800',
      'sent': 'bg-gray-100 text-gray-800'
    };
    return statusColors[status] || 'bg-gray-100 text-gray-800';
  };

  const getStatusText = (status) => {
    const statusTexts = {
      'pending': 'Bekliyor',
      'accepted': 'Kabul Edildi',
      'rejected': 'Reddedildi',
      'completed': 'Tamamlandı',
      'in_progress': 'Devam Ediyor',
      'new': 'Yeni',
      'sent': 'Gönderildi'
    };
    return statusTexts[status] || status;
  };

  const tabs = getTabs();

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold mb-2">Analitik Dashboard</h1>
              <p className="text-blue-100">Performansınızı analiz edin ve iyileştirin</p>
            </div>
            <div className="flex items-center space-x-4">
              <select
                value={selectedPeriod}
                onChange={(e) => setSelectedPeriod(parseInt(e.target.value))}
                className="bg-white text-gray-800 px-3 py-2 rounded-lg text-sm"
              >
                {constants?.default_periods?.map((period) => (
                  <option key={period} value={period}>
                    Son {period} gün
                  </option>
                ))}
              </select>
              <button
                onClick={loadDashboardData}
                className="bg-white bg-opacity-20 hover:bg-opacity-30 text-white px-4 py-2 rounded-lg transition-colors"
              >
                🔄 Yenile
              </button>
            </div>
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="p-4">
            <ErrorMessage message={error} onClose={() => setError(null)} />
          </div>
        )}

        {/* Tabs */}
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`py-4 px-2 border-b-2 font-medium text-sm transition-colors ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <span className="mr-2">{tab.icon}</span>
                {tab.label}
              </button>
            ))}
          </nav>
        </div>

        {/* Content */}
        <div className="p-6">
          {activeTab === 'overview' && renderOverviewTab()}
          {activeTab === 'trends' && renderTrendsTab()}
          {activeTab === 'cost-calculator' && renderCostCalculatorTab()}
          {activeTab === 'business' && renderBusinessTab()}
          {activeTab === 'platform' && renderPlatformTab()}
        </div>
      </div>
    </div>
  );
};

// Metric Card Component
const MetricCard = ({ title, value, icon, color }) => {
  const colorClasses = {
    blue: 'bg-blue-50 border-blue-200 text-blue-600',
    green: 'bg-green-50 border-green-200 text-green-600',
    yellow: 'bg-yellow-50 border-yellow-200 text-yellow-600',
    purple: 'bg-purple-50 border-purple-200 text-purple-600',
    red: 'bg-red-50 border-red-200 text-red-600'
  };

  return (
    <div className={`border rounded-lg p-4 ${colorClasses[color]}`}>
      <div className="flex items-center justify-between">
        <div>
          <div className="text-2xl font-bold">{value}</div>
          <div className="text-sm opacity-80">{title}</div>
        </div>
        <span className="text-2xl">{icon}</span>
      </div>
    </div>
  );
};

export default AnalyticsDashboard;