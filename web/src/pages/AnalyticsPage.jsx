import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import AnalyticsCard from '../components/analytics/AnalyticsCard';
import ChartComponent from '../components/analytics/ChartComponent';

const AnalyticsPage = () => {
  const { user } = useAuth();
  const [timeRange, setTimeRange] = useState('30'); // 7, 30, 90, 365 days
  const [loading, setLoading] = useState(true);
  const [analyticsData, setAnalyticsData] = useState(null);

  const timeRangeOptions = [
    { value: '7', label: 'Son 7 Gün' },
    { value: '30', label: 'Son 30 Gün' },
    { value: '90', label: 'Son 3 Ay' },
    { value: '365', label: 'Son 1 Yıl' }
  ];

  // Mock analytics data
  const generateMockData = (userType, range) => {
    if (userType === 'craftsman') {
      return {
        overview: {
          totalJobs: Math.floor(Math.random() * 50) + 20,
          totalEarnings: Math.floor(Math.random() * 15000) + 5000,
          averageRating: (Math.random() * 1.5 + 3.5).toFixed(1),
          responseTime: Math.floor(Math.random() * 4) + 1
        },
        trends: {
          jobs: {
            change: `+${Math.floor(Math.random() * 20) + 5}%`,
            changeType: 'positive'
          },
          earnings: {
            change: `+${Math.floor(Math.random() * 30) + 10}%`,
            changeType: 'positive'
          },
          rating: {
            change: `+${(Math.random() * 0.5).toFixed(1)}`,
            changeType: 'positive'
          },
          responseTime: {
            change: `-${Math.floor(Math.random() * 20) + 5}%`,
            changeType: 'positive'
          }
        },
        charts: {
          jobsOverTime: [
            { label: 'Pzt', value: Math.floor(Math.random() * 10) + 2 },
            { label: 'Sal', value: Math.floor(Math.random() * 10) + 2 },
            { label: 'Çar', value: Math.floor(Math.random() * 10) + 2 },
            { label: 'Per', value: Math.floor(Math.random() * 10) + 2 },
            { label: 'Cum', value: Math.floor(Math.random() * 10) + 2 },
            { label: 'Cmt', value: Math.floor(Math.random() * 10) + 2 },
            { label: 'Paz', value: Math.floor(Math.random() * 10) + 2 }
          ],
          earningsOverTime: [
            { label: 'Ocak', value: Math.floor(Math.random() * 3000) + 1000 },
            { label: 'Şubat', value: Math.floor(Math.random() * 3000) + 1000 },
            { label: 'Mart', value: Math.floor(Math.random() * 3000) + 1000 },
            { label: 'Nisan', value: Math.floor(Math.random() * 3000) + 1000 },
            { label: 'Mayıs', value: Math.floor(Math.random() * 3000) + 1000 },
            { label: 'Haziran', value: Math.floor(Math.random() * 3000) + 1000 }
          ],
          jobCategories: [
            { label: 'Elektrik', value: Math.floor(Math.random() * 15) + 5 },
            { label: 'Tesisat', value: Math.floor(Math.random() * 15) + 5 },
            { label: 'Boyama', value: Math.floor(Math.random() * 15) + 5 },
            { label: 'Temizlik', value: Math.floor(Math.random() * 15) + 5 },
            { label: 'Diğer', value: Math.floor(Math.random() * 15) + 5 }
          ],
          customerSatisfaction: [
            { label: '5 Yıldız', value: Math.floor(Math.random() * 30) + 20 },
            { label: '4 Yıldız', value: Math.floor(Math.random() * 20) + 10 },
            { label: '3 Yıldız', value: Math.floor(Math.random() * 10) + 2 },
            { label: '2 Yıldız', value: Math.floor(Math.random() * 5) + 1 },
            { label: '1 Yıldız', value: Math.floor(Math.random() * 3) + 1 }
          ]
        },
        recentActivity: [
          { type: 'job_completed', message: 'Elektrik tesisatı işi tamamlandı', time: '2 saat önce', amount: '₺450' },
          { type: 'review_received', message: 'Yeni 5 yıldızlı değerlendirme aldınız', time: '4 saat önce' },
          { type: 'job_started', message: 'Klima montajı işine başlandı', time: '1 gün önce' },
          { type: 'proposal_sent', message: 'Yeni teklif gönderildi', time: '2 gün önce' }
        ]
      };
    } else {
      return {
        overview: {
          totalJobs: Math.floor(Math.random() * 20) + 5,
          totalSpent: Math.floor(Math.random() * 8000) + 2000,
          activeJobs: Math.floor(Math.random() * 5) + 1,
          savedMoney: Math.floor(Math.random() * 2000) + 500
        },
        trends: {
          jobs: {
            change: `+${Math.floor(Math.random() * 15) + 5}%`,
            changeType: 'positive'
          },
          spent: {
            change: `+${Math.floor(Math.random() * 25) + 10}%`,
            changeType: 'neutral'
          },
          activeJobs: {
            change: `+${Math.floor(Math.random() * 10) + 2}`,
            changeType: 'positive'
          },
          savedMoney: {
            change: `+${Math.floor(Math.random() * 30) + 15}%`,
            changeType: 'positive'
          }
        },
        charts: {
          spendingOverTime: [
            { label: 'Ocak', value: Math.floor(Math.random() * 1500) + 500 },
            { label: 'Şubat', value: Math.floor(Math.random() * 1500) + 500 },
            { label: 'Mart', value: Math.floor(Math.random() * 1500) + 500 },
            { label: 'Nisan', value: Math.floor(Math.random() * 1500) + 500 },
            { label: 'Mayıs', value: Math.floor(Math.random() * 1500) + 500 },
            { label: 'Haziran', value: Math.floor(Math.random() * 1500) + 500 }
          ],
          jobsByCategory: [
            { label: 'Elektrik', value: Math.floor(Math.random() * 8) + 2 },
            { label: 'Tesisat', value: Math.floor(Math.random() * 8) + 2 },
            { label: 'Boyama', value: Math.floor(Math.random() * 8) + 2 },
            { label: 'Temizlik', value: Math.floor(Math.random() * 8) + 2 },
            { label: 'Diğer', value: Math.floor(Math.random() * 8) + 2 }
          ],
          jobStatus: [
            { label: 'Tamamlanan', value: Math.floor(Math.random() * 15) + 10 },
            { label: 'Devam Eden', value: Math.floor(Math.random() * 5) + 2 },
            { label: 'Bekleyen', value: Math.floor(Math.random() * 3) + 1 },
            { label: 'İptal Edilen', value: Math.floor(Math.random() * 2) + 1 }
          ]
        },
        recentActivity: [
          { type: 'job_completed', message: 'Klima montajı işi tamamlandı', time: '1 saat önce', amount: '₺350' },
          { type: 'review_left', message: 'Elektrikçi için değerlendirme bıraktınız', time: '3 saat önce' },
          { type: 'proposal_received', message: '3 yeni teklif aldınız', time: '1 gün önce' },
          { type: 'job_posted', message: 'Yeni iş ilanı yayınladınız', time: '2 gün önce' }
        ]
      };
    }
  };

  useEffect(() => {
    setLoading(true);
    setTimeout(() => {
      setAnalyticsData(generateMockData(user?.user_type, timeRange));
      setLoading(false);
    }, 1000);
  }, [user, timeRange]);

  const getActivityIcon = (type) => {
    switch (type) {
      case 'job_completed': return '✅';
      case 'review_received': return '⭐';
      case 'review_left': return '⭐';
      case 'job_started': return '🚀';
      case 'proposal_sent': return '📝';
      case 'proposal_received': return '📋';
      case 'job_posted': return '📢';
      default: return '📌';
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Analitik veriler yükleniyor...</p>
        </div>
      </div>
    );
  }

  const renderCraftsmanAnalytics = () => (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <AnalyticsCard
          title="Toplam İş"
          value={analyticsData.overview.totalJobs}
          change={analyticsData.trends.jobs.change}
          changeType={analyticsData.trends.jobs.changeType}
          icon="💼"
          description="Tamamlanan iş sayısı"
          trend={75}
        />
        <AnalyticsCard
          title="Toplam Kazanç"
          value={`₺${analyticsData.overview.totalEarnings.toLocaleString()}`}
          change={analyticsData.trends.earnings.change}
          changeType={analyticsData.trends.earnings.changeType}
          icon="💰"
          description="Toplam gelir miktarı"
          trend={85}
        />
        <AnalyticsCard
          title="Ortalama Puan"
          value={analyticsData.overview.averageRating}
          change={analyticsData.trends.rating.change}
          changeType={analyticsData.trends.rating.changeType}
          icon="⭐"
          description="Müşteri memnuniyeti"
          trend={92}
        />
        <AnalyticsCard
          title="Yanıt Süresi"
          value={`${analyticsData.overview.responseTime} saat`}
          change={analyticsData.trends.responseTime.change}
          changeType={analyticsData.trends.responseTime.changeType}
          icon="⚡"
          description="Ortalama yanıt süresi"
          trend={68}
        />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <ChartComponent
          type="bar"
          data={analyticsData.charts.jobsOverTime}
          title="Haftalık İş Dağılımı"
          color="blue"
        />
        <ChartComponent
          type="line"
          data={analyticsData.charts.earningsOverTime}
          title="Aylık Kazanç Trendi"
          color="green"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <ChartComponent
          type="pie"
          data={analyticsData.charts.jobCategories}
          title="İş Kategorileri Dağılımı"
        />
        <ChartComponent
          type="bar"
          data={analyticsData.charts.customerSatisfaction}
          title="Müşteri Memnuniyeti"
          color="yellow"
        />
      </div>
    </div>
  );

  const renderCustomerAnalytics = () => (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <AnalyticsCard
          title="Toplam İş"
          value={analyticsData.overview.totalJobs}
          change={analyticsData.trends.jobs.change}
          changeType={analyticsData.trends.jobs.changeType}
          icon="📋"
          description="Verilen iş sayısı"
          trend={70}
        />
        <AnalyticsCard
          title="Toplam Harcama"
          value={`₺${analyticsData.overview.totalSpent.toLocaleString()}`}
          change={analyticsData.trends.spent.change}
          changeType={analyticsData.trends.spent.changeType}
          icon="💳"
          description="Toplam harcama miktarı"
          trend={60}
        />
        <AnalyticsCard
          title="Aktif İşler"
          value={analyticsData.overview.activeJobs}
          change={analyticsData.trends.activeJobs.change}
          changeType={analyticsData.trends.activeJobs.changeType}
          icon="🚀"
          description="Devam eden işler"
          trend={45}
        />
        <AnalyticsCard
          title="Tasarruf"
          value={`₺${analyticsData.overview.savedMoney.toLocaleString()}`}
          change={analyticsData.trends.savedMoney.change}
          changeType={analyticsData.trends.savedMoney.changeType}
          icon="🏦"
          description="Elde edilen tasarruf"
          trend={80}
        />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <ChartComponent
          type="line"
          data={analyticsData.charts.spendingOverTime}
          title="Aylık Harcama Trendi"
          color="red"
        />
        <ChartComponent
          type="pie"
          data={analyticsData.charts.jobsByCategory}
          title="İş Kategorileri"
        />
      </div>

      <div className="grid grid-cols-1 gap-6">
        <ChartComponent
          type="bar"
          data={analyticsData.charts.jobStatus}
          title="İş Durumu Dağılımı"
          color="purple"
        />
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 py-6">
        {/* Header */}
        <div className="mb-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
                📊 Analitikler
              </h1>
              <p className="mt-2 text-gray-600 dark:text-gray-400">
                {user?.user_type === 'craftsman' 
                  ? 'İş performansınızı ve kazançlarınızı takip edin'
                  : 'Harcamalarınızı ve iş geçmişinizi analiz edin'
                }
              </p>
            </div>
            
            <div className="mt-4 sm:mt-0">
              <select
                value={timeRange}
                onChange={(e) => setTimeRange(e.target.value)}
                className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                {timeRangeOptions.map(option => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        {/* Analytics Content */}
        {user?.user_type === 'craftsman' ? renderCraftsmanAnalytics() : renderCustomerAnalytics()}

        {/* Recent Activity */}
        <div className="mt-8">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              Son Aktiviteler
            </h3>
            <div className="space-y-4">
              {analyticsData.recentActivity.map((activity, index) => (
                <div key={index} className="flex items-start space-x-4 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
                  <div className="text-2xl">{getActivityIcon(activity.type)}</div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-gray-900 dark:text-white">
                      {activity.message}
                    </p>
                    <div className="flex items-center justify-between mt-1">
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        {activity.time}
                      </p>
                      {activity.amount && (
                        <span className="text-sm font-semibold text-green-600 dark:text-green-400">
                          {activity.amount}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Performance Insights */}
        <div className="mt-8">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              💡 Performans Önerileri
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {user?.user_type === 'craftsman' ? (
                <>
                  <div className="p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
                    <div className="flex items-center space-x-2 mb-2">
                      <span className="text-blue-600 dark:text-blue-400">⚡</span>
                      <h4 className="font-medium text-blue-900 dark:text-blue-100">Yanıt Hızı</h4>
                    </div>
                    <p className="text-sm text-blue-800 dark:text-blue-200">
                      Daha hızlı yanıt vererek daha fazla iş alabilirsiniz.
                    </p>
                  </div>
                  <div className="p-4 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
                    <div className="flex items-center space-x-2 mb-2">
                      <span className="text-green-600 dark:text-green-400">📸</span>
                      <h4 className="font-medium text-green-900 dark:text-green-100">Portfolyo</h4>
                    </div>
                    <p className="text-sm text-green-800 dark:text-green-200">
                      Daha fazla iş fotoğrafı ekleyerek güven oluşturun.
                    </p>
                  </div>
                  <div className="p-4 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg border border-yellow-200 dark:border-yellow-800">
                    <div className="flex items-center space-x-2 mb-2">
                      <span className="text-yellow-600 dark:text-yellow-400">⭐</span>
                      <h4 className="font-medium text-yellow-900 dark:text-yellow-100">Değerlendirmeler</h4>
                    </div>
                    <p className="text-sm text-yellow-800 dark:text-yellow-200">
                      Müşterilerinizden değerlendirme istemeyi unutmayın.
                    </p>
                  </div>
                </>
              ) : (
                <>
                  <div className="p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-800">
                    <div className="flex items-center space-x-2 mb-2">
                      <span className="text-purple-600 dark:text-purple-400">💰</span>
                      <h4 className="font-medium text-purple-900 dark:text-purple-100">Bütçe Takibi</h4>
                    </div>
                    <p className="text-sm text-purple-800 dark:text-purple-200">
                      Aylık harcama limitinizi belirleyerek tasarruf edin.
                    </p>
                  </div>
                  <div className="p-4 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg border border-indigo-200 dark:border-indigo-800">
                    <div className="flex items-center space-x-2 mb-2">
                      <span className="text-indigo-600 dark:text-indigo-400">🔍</span>
                      <h4 className="font-medium text-indigo-900 dark:text-indigo-100">Karşılaştırma</h4>
                    </div>
                    <p className="text-sm text-indigo-800 dark:text-indigo-200">
                      Birden fazla teklif alarak en uygun fiyatı bulun.
                    </p>
                  </div>
                  <div className="p-4 bg-pink-50 dark:bg-pink-900/20 rounded-lg border border-pink-200 dark:border-pink-800">
                    <div className="flex items-center space-x-2 mb-2">
                      <span className="text-pink-600 dark:text-pink-400">📋</span>
                      <h4 className="font-medium text-pink-900 dark:text-pink-100">Planlama</h4>
                    </div>
                    <p className="text-sm text-pink-800 dark:text-pink-200">
                      İşlerinizi önceden planlayarak daha iyi fiyatlar alın.
                    </p>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AnalyticsPage;