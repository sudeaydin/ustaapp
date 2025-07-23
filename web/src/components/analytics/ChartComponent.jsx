import React from 'react';

const ChartComponent = ({ 
  type = 'bar', 
  data = [], 
  title, 
  height = 'h-64',
  color = 'blue',
  showGrid = true,
  showLabels = true 
}) => {
  if (!data.length) {
    return (
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">{title}</h3>
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 00-2-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            <h3 className="mt-2 text-sm font-medium text-gray-900 dark:text-white">Veri yok</h3>
            <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
              Henüz gösterilecek veri bulunmuyor.
            </p>
          </div>
        </div>
      </div>
    );
  }

  const maxValue = Math.max(...data.map(item => item.value));
  const colorClasses = {
    blue: 'bg-blue-500 dark:bg-blue-600',
    green: 'bg-green-500 dark:bg-green-600',
    red: 'bg-red-500 dark:bg-red-600',
    yellow: 'bg-yellow-500 dark:bg-yellow-600',
    purple: 'bg-purple-500 dark:bg-purple-600',
    indigo: 'bg-indigo-500 dark:bg-indigo-600'
  };

  const renderBarChart = () => (
    <div className="flex items-end justify-between space-x-2" style={{ height: '200px' }}>
      {data.map((item, index) => {
        const height = (item.value / maxValue) * 180;
        return (
          <div key={index} className="flex flex-col items-center flex-1">
            <div className="flex flex-col items-center justify-end" style={{ height: '180px' }}>
              <div className="group relative">
                <div
                  className={`w-full rounded-t transition-all duration-300 hover:opacity-80 ${colorClasses[color]}`}
                  style={{ height: `${height}px`, minWidth: '20px' }}
                ></div>
                <div className="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <div className="bg-gray-900 dark:bg-gray-700 text-white text-xs rounded py-1 px-2 whitespace-nowrap">
                    {item.value}
                  </div>
                </div>
              </div>
            </div>
            {showLabels && (
              <div className="mt-2 text-xs text-gray-600 dark:text-gray-400 text-center">
                {item.label}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );

  const renderLineChart = () => {
    const points = data.map((item, index) => {
      const x = (index / (data.length - 1)) * 100;
      const y = 100 - (item.value / maxValue) * 80;
      return `${x},${y}`;
    }).join(' ');

    return (
      <div className="relative" style={{ height: '200px' }}>
        <svg className="w-full h-full" viewBox="0 0 100 100" preserveAspectRatio="none">
          {showGrid && (
            <g className="opacity-20">
              {[0, 25, 50, 75, 100].map(y => (
                <line key={y} x1="0" y1={y} x2="100" y2={y} stroke="currentColor" strokeWidth="0.5" className="text-gray-400" />
              ))}
            </g>
          )}
          <polyline
            fill="none"
            stroke={`rgb(${color === 'blue' ? '59 130 246' : color === 'green' ? '34 197 94' : color === 'red' ? '239 68 68' : '168 85 247'})`}
            strokeWidth="2"
            points={points}
            className="drop-shadow-sm"
          />
          {data.map((item, index) => {
            const x = (index / (data.length - 1)) * 100;
            const y = 100 - (item.value / maxValue) * 80;
            return (
              <circle
                key={index}
                cx={x}
                cy={y}
                r="2"
                fill={`rgb(${color === 'blue' ? '59 130 246' : color === 'green' ? '34 197 94' : color === 'red' ? '239 68 68' : '168 85 247'})`}
                className="hover:r-3 transition-all cursor-pointer"
              >
                <title>{`${item.label}: ${item.value}`}</title>
              </circle>
            );
          })}
        </svg>
        {showLabels && (
          <div className="flex justify-between mt-2">
            {data.map((item, index) => (
              <div key={index} className="text-xs text-gray-600 dark:text-gray-400">
                {item.label}
              </div>
            ))}
          </div>
        )}
      </div>
    );
  };

  const renderPieChart = () => {
    const total = data.reduce((sum, item) => sum + item.value, 0);
    let cumulativePercentage = 0;
    const colors = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4'];

    return (
      <div className="flex items-center justify-center" style={{ height: '200px' }}>
        <div className="relative">
          <svg width="160" height="160" viewBox="0 0 42 42" className="transform -rotate-90">
            <circle
              cx="21"
              cy="21"
              r="15.915"
              fill="transparent"
              stroke="#E5E7EB"
              strokeWidth="3"
              className="dark:stroke-gray-600"
            />
            {data.map((item, index) => {
              const percentage = (item.value / total) * 100;
              const strokeDasharray = `${percentage} ${100 - percentage}`;
              const strokeDashoffset = -cumulativePercentage;
              cumulativePercentage += percentage;

              return (
                <circle
                  key={index}
                  cx="21"
                  cy="21"
                  r="15.915"
                  fill="transparent"
                  stroke={colors[index % colors.length]}
                  strokeWidth="3"
                  strokeDasharray={strokeDasharray}
                  strokeDashoffset={strokeDashoffset}
                  className="transition-all duration-300 hover:stroke-4"
                >
                  <title>{`${item.label}: ${item.value} (${percentage.toFixed(1)}%)`}</title>
                </circle>
              );
            })}
          </svg>
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="text-center">
              <div className="text-lg font-bold text-gray-900 dark:text-white">{total}</div>
              <div className="text-xs text-gray-600 dark:text-gray-400">Toplam</div>
            </div>
          </div>
        </div>
        <div className="ml-6 space-y-2">
          {data.map((item, index) => (
            <div key={index} className="flex items-center space-x-2">
              <div
                className="w-3 h-3 rounded-full"
                style={{ backgroundColor: colors[index % colors.length] }}
              ></div>
              <span className="text-sm text-gray-700 dark:text-gray-300">
                {item.label}: {item.value}
              </span>
            </div>
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
      {title && (
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">{title}</h3>
      )}
      <div className={height}>
        {type === 'bar' && renderBarChart()}
        {type === 'line' && renderLineChart()}
        {type === 'pie' && renderPieChart()}
      </div>
    </div>
  );
};

export default ChartComponent;