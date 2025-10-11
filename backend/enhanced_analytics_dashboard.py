#!/usr/bin/env python3
"""
Enhanced Analytics Dashboard for ustam App
Real-time business intelligence and comprehensive analytics
"""

import os
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from google.cloud import bigquery
from google.api_core import exceptions
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import streamlit as st

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class UstamAnalyticsDashboard:
    """Comprehensive analytics dashboard for ustam app"""
    
    def __init__(self, project_id: str = None):
        self.project_id = project_id or os.environ.get('BIGQUERY_PROJECT_ID', 'ustam-analytics')
        self.dataset_id = "ustam_analytics"
        self.client = None
        self._initialize_client()
    
    def _initialize_client(self):
        """Initialize BigQuery client"""
        try:
            self.client = bigquery.Client(project=self.project_id)
            logger.info(f"BigQuery client initialized for project: {self.project_id}")
        except Exception as e:
            logger.error(f"Failed to initialize BigQuery client: {e}")
            self.client = None
    
    def query_bigquery(self, query: str) -> pd.DataFrame:
        """Execute BigQuery query and return DataFrame"""
        try:
            if not self.client:
                raise Exception("BigQuery client not initialized")
            
            job = self.client.query(query)
            df = job.to_dataframe()
            return df
        except Exception as e:
            logger.error(f"BigQuery query failed: {e}")
            return pd.DataFrame()
    
    def get_realtime_dashboard_data(self) -> Dict[str, Any]:
        """Get real-time dashboard metrics"""
        query = f"""
        SELECT * FROM `{self.project_id}.{self.dataset_id}.realtime_dashboard`
        LIMIT 1
        """
        
        df = self.query_bigquery(query)
        if df.empty:
            return {}
        
        return df.iloc[0].to_dict()
    
    def get_hourly_metrics(self, hours: int = 24) -> pd.DataFrame:
        """Get hourly metrics for specified time period"""
        query = f"""
        SELECT *
        FROM `{self.project_id}.{self.dataset_id}.hourly_metrics`
        WHERE hour_tr >= DATETIME_SUB(CURRENT_DATETIME('Europe/Istanbul'), INTERVAL {hours} HOUR)
        ORDER BY hour_tr DESC
        """
        
        return self.query_bigquery(query)
    
    def get_user_funnel_analysis(self, days: int = 30) -> pd.DataFrame:
        """Get user funnel analysis"""
        query = f"""
        WITH user_journey AS (
          SELECT
            user_id,
            MIN(CASE WHEN action_type = 'register' THEN timestamp END) as registered_at,
            MIN(CASE WHEN action_type = 'login' THEN timestamp END) as first_login_at,
            MIN(CASE WHEN action_category = 'job' AND action_type != 'view' THEN timestamp END) as first_job_action_at,
            MIN(CASE WHEN action_category = 'payment' THEN timestamp END) as first_payment_at,
            COUNT(DISTINCT DATE(timestamp)) as active_days
          FROM `{self.project_id}.{self.dataset_id}.user_activity_logs`
          WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
          GROUP BY user_id
        )
        SELECT
          COUNT(*) as total_users,
          COUNT(first_login_at) as logged_in_users,
          COUNT(first_job_action_at) as job_active_users,
          COUNT(first_payment_at) as paying_users,
          AVG(active_days) as avg_active_days,
          COUNT(first_login_at) / COUNT(*) as login_conversion_rate,
          COUNT(first_job_action_at) / COUNT(*) as job_conversion_rate,
          COUNT(first_payment_at) / COUNT(*) as payment_conversion_rate
        FROM user_journey
        """
        
        return self.query_bigquery(query)
    
    def get_craftsman_performance_metrics(self, limit: int = 20) -> pd.DataFrame:
        """Get top performing craftsmen"""
        query = f"""
        SELECT * FROM `{self.project_id}.{self.dataset_id}.craftsman_performance`
        ORDER BY total_earnings DESC
        LIMIT {limit}
        """
        
        return self.query_bigquery(query)
    
    def get_revenue_trends(self, days: int = 30) -> pd.DataFrame:
        """Get revenue trends"""
        query = f"""
        SELECT
          date,
          SUM(total_amount) as daily_revenue,
          SUM(total_platform_fees) as daily_fees,
          COUNT(*) as transaction_count,
          AVG(avg_transaction_value) as avg_value
        FROM `{self.project_id}.{self.dataset_id}.revenue_dashboard`
        WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL {days} DAY)
        GROUP BY date
        ORDER BY date DESC
        """
        
        return self.query_bigquery(query)
    
    def get_search_analytics(self, days: int = 7) -> pd.DataFrame:
        """Get search analytics"""
        query = f"""
        SELECT
          DATE(timestamp) as date,
          search_type,
          COUNT(*) as total_searches,
          AVG(results_count) as avg_results,
          AVG(response_time_ms) as avg_response_time,
          SUM(CASE WHEN clicked_result_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) as ctr
        FROM `{self.project_id}.{self.dataset_id}.search_analytics`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
        GROUP BY DATE(timestamp), search_type
        ORDER BY date DESC, search_type
        """
        
        return self.query_bigquery(query)
    
    def get_error_analysis(self, days: int = 7) -> pd.DataFrame:
        """Get error analysis"""
        query = f"""
        SELECT
          DATE(timestamp) as date,
          error_type,
          error_level,
          COUNT(*) as error_count,
          COUNT(DISTINCT user_id) as affected_users,
          COUNT(DISTINCT session_id) as affected_sessions
        FROM `{self.project_id}.{self.dataset_id}.error_logs`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
        GROUP BY DATE(timestamp), error_type, error_level
        ORDER BY date DESC, error_count DESC
        """
        
        return self.query_bigquery(query)
    
    def get_platform_comparison(self, days: int = 7) -> pd.DataFrame:
        """Get platform performance comparison"""
        query = f"""
        SELECT
          platform,
          COUNT(DISTINCT user_id) as unique_users,
          COUNT(*) as total_actions,
          AVG(duration_ms) as avg_response_time,
          SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*) as success_rate
        FROM `{self.project_id}.{self.dataset_id}.user_activity_logs`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {days} DAY)
        GROUP BY platform
        ORDER BY unique_users DESC
        """
        
        return self.query_bigquery(query)
    
    def get_cohort_analysis(self, months: int = 6) -> pd.DataFrame:
        """Get user cohort retention analysis"""
        query = f"""
        WITH user_cohorts AS (
          SELECT
            user_id,
            DATE_TRUNC(DATE(MIN(timestamp)), MONTH) as cohort_month
          FROM `{self.project_id}.{self.dataset_id}.user_activity_logs`
          WHERE action_type = 'register'
          GROUP BY user_id
        ),
        cohort_activity AS (
          SELECT
            uc.cohort_month,
            DATE_TRUNC(DATE(ual.timestamp), MONTH) as activity_month,
            COUNT(DISTINCT ual.user_id) as active_users
          FROM user_cohorts uc
          JOIN `{self.project_id}.{self.dataset_id}.user_activity_logs` ual ON uc.user_id = ual.user_id
          WHERE uc.cohort_month >= DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL {months} MONTH)
          GROUP BY cohort_month, activity_month
        )
        SELECT
          cohort_month,
          activity_month,
          DATE_DIFF(activity_month, cohort_month, MONTH) as month_number,
          active_users,
          active_users / FIRST_VALUE(active_users) OVER (
            PARTITION BY cohort_month 
            ORDER BY activity_month
          ) as retention_rate
        FROM cohort_activity
        ORDER BY cohort_month, activity_month
        """
        
        return self.query_bigquery(query)
    
    def create_realtime_dashboard_chart(self, data: Dict[str, Any]) -> go.Figure:
        """Create real-time dashboard chart"""
        fig = make_subplots(
            rows=2, cols=2,
            subplot_titles=('Active Users', 'Revenue Today', 'Success Rate', 'Error Rate'),
            specs=[[{"type": "indicator"}, {"type": "indicator"}],
                   [{"type": "indicator"}, {"type": "indicator"}]]
        )
        
        # Active Users
        fig.add_trace(
            go.Indicator(
                mode="number+delta",
                value=data.get('active_users', 0),
                title={"text": "Active Users (24h)"},
                delta={'reference': data.get('active_users', 0) * 0.9}
            ),
            row=1, col=1
        )
        
        # Revenue Today
        fig.add_trace(
            go.Indicator(
                mode="number+delta",
                value=data.get('total_revenue', 0),
                title={"text": "Revenue Today (₺)"},
                number={'prefix': "₺"},
                delta={'reference': data.get('total_revenue', 0) * 0.8}
            ),
            row=1, col=2
        )
        
        # Success Rate
        fig.add_trace(
            go.Indicator(
                mode="gauge+number",
                value=data.get('success_rate', 0) * 100,
                title={'text': "Success Rate (%)"},
                gauge={'axis': {'range': [None, 100]},
                       'bar': {'color': "darkgreen"},
                       'steps': [{'range': [0, 50], 'color': "lightgray"},
                                {'range': [50, 80], 'color': "yellow"},
                                {'range': [80, 100], 'color': "lightgreen"}],
                       'threshold': {'line': {'color': "red", 'width': 4},
                                    'thickness': 0.75, 'value': 90}}
            ),
            row=2, col=1
        )
        
        # Error Rate
        error_rate = (data.get('total_errors', 0) / max(data.get('total_actions', 1), 1)) * 100
        fig.add_trace(
            go.Indicator(
                mode="gauge+number",
                value=error_rate,
                title={'text': "Error Rate (%)"},
                gauge={'axis': {'range': [None, 10]},
                       'bar': {'color': "red"},
                       'steps': [{'range': [0, 2], 'color': "lightgreen"},
                                {'range': [2, 5], 'color': "yellow"},
                                {'range': [5, 10], 'color': "lightcoral"}],
                       'threshold': {'line': {'color': "red", 'width': 4},
                                    'thickness': 0.75, 'value': 5}}
            ),
            row=2, col=2
        )
        
        fig.update_layout(height=600, title="Real-time Dashboard")
        return fig
    
    def create_hourly_trends_chart(self, df: pd.DataFrame) -> go.Figure:
        """Create hourly trends chart"""
        fig = make_subplots(
            rows=2, cols=2,
            subplot_titles=('Active Users', 'Revenue', 'Success Rate', 'Error Count'),
            shared_xaxes=True
        )
        
        # Active Users
        fig.add_trace(
            go.Scatter(x=df['hour_tr'], y=df['unique_users'], 
                      mode='lines+markers', name='Active Users'),
            row=1, col=1
        )
        
        # Revenue
        fig.add_trace(
            go.Scatter(x=df['hour_tr'], y=df['total_revenue'], 
                      mode='lines+markers', name='Revenue (₺)', line=dict(color='green')),
            row=1, col=2
        )
        
        # Success Rate
        fig.add_trace(
            go.Scatter(x=df['hour_tr'], y=df['success_rate'] * 100, 
                      mode='lines+markers', name='Success Rate (%)', line=dict(color='blue')),
            row=2, col=1
        )
        
        # Error Count
        fig.add_trace(
            go.Scatter(x=df['hour_tr'], y=df['error_count'], 
                      mode='lines+markers', name='Errors', line=dict(color='red')),
            row=2, col=2
        )
        
        fig.update_layout(height=600, title="Hourly Trends (Last 24 Hours)")
        return fig
    
    def create_revenue_chart(self, df: pd.DataFrame) -> go.Figure:
        """Create revenue trends chart"""
        fig = make_subplots(
            rows=1, cols=2,
            subplot_titles=('Daily Revenue', 'Transaction Volume'),
            specs=[[{"secondary_y": True}, {"type": "bar"}]]
        )
        
        # Revenue trend
        fig.add_trace(
            go.Scatter(x=df['date'], y=df['daily_revenue'], 
                      mode='lines+markers', name='Revenue (₺)', line=dict(color='green')),
            row=1, col=1
        )
        
        # Platform fees
        fig.add_trace(
            go.Scatter(x=df['date'], y=df['daily_fees'], 
                      mode='lines+markers', name='Platform Fees (₺)', line=dict(color='orange')),
            row=1, col=1
        )
        
        # Transaction count
        fig.add_trace(
            go.Bar(x=df['date'], y=df['transaction_count'], 
                   name='Transactions', marker_color='lightblue'),
            row=1, col=2
        )
        
        fig.update_layout(height=400, title="Revenue Analysis")
        return fig
    
    def create_platform_comparison_chart(self, df: pd.DataFrame) -> go.Figure:
        """Create platform comparison chart"""
        fig = make_subplots(
            rows=1, cols=2,
            subplot_titles=('Users by Platform', 'Performance Metrics'),
            specs=[[{"type": "pie"}, {"type": "bar"}]]
        )
        
        # Platform distribution
        fig.add_trace(
            go.Pie(labels=df['platform'], values=df['unique_users'], 
                   name="Users by Platform"),
            row=1, col=1
        )
        
        # Performance metrics
        fig.add_trace(
            go.Bar(x=df['platform'], y=df['success_rate'] * 100, 
                   name='Success Rate (%)', marker_color='green'),
            row=1, col=2
        )
        
        fig.update_layout(height=400, title="Platform Comparison")
        return fig

def create_streamlit_dashboard():
    """Create Streamlit dashboard"""
    st.set_page_config(page_title="ustam Analytics", layout="wide")
    
    st.title("🚀 ustam - Real-time Analytics Dashboard")
    st.markdown("---")
    
    # Initialize dashboard
    dashboard = UstamAnalyticsDashboard()
    
    if not dashboard.client:
        st.error("❌ BigQuery connection failed. Please check your configuration.")
        return
    
    # Sidebar controls
    st.sidebar.header("Dashboard Controls")
    refresh_interval = st.sidebar.selectbox("Refresh Interval", [30, 60, 300, 600], index=1)
    time_range = st.sidebar.selectbox("Time Range", ["1 hour", "6 hours", "24 hours", "7 days"], index=2)
    
    # Auto refresh
    if st.sidebar.button("🔄 Refresh Data"):
        st.rerun()
    
    # Real-time metrics
    st.header("📊 Real-time Metrics")
    
    try:
        realtime_data = dashboard.get_realtime_dashboard_data()
        
        if realtime_data:
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric("Active Users (24h)", 
                         realtime_data.get('active_users', 0),
                         delta=f"+{realtime_data.get('active_users', 0) - 100}")
            
            with col2:
                st.metric("Total Revenue", 
                         f"₺{realtime_data.get('total_revenue', 0):,.2f}",
                         delta=f"+₺{realtime_data.get('total_revenue', 0) * 0.1:,.2f}")
            
            with col3:
                st.metric("Success Rate", 
                         f"{realtime_data.get('success_rate', 0) * 100:.1f}%",
                         delta=f"+{realtime_data.get('success_rate', 0) * 5:.1f}%")
            
            with col4:
                st.metric("Total Errors", 
                         realtime_data.get('total_errors', 0),
                         delta=f"-{realtime_data.get('total_errors', 0) // 2}")
            
            # Real-time dashboard chart
            fig_realtime = dashboard.create_realtime_dashboard_chart(realtime_data)
            st.plotly_chart(fig_realtime, use_container_width=True)
        
        # Hourly trends
        st.header("📈 Hourly Trends")
        hours_map = {"1 hour": 1, "6 hours": 6, "24 hours": 24, "7 days": 168}
        hourly_df = dashboard.get_hourly_metrics(hours_map[time_range])
        
        if not hourly_df.empty:
            fig_hourly = dashboard.create_hourly_trends_chart(hourly_df)
            st.plotly_chart(fig_hourly, use_container_width=True)
        
        # Revenue analysis
        st.header("💰 Revenue Analysis")
        revenue_df = dashboard.get_revenue_trends(30)
        
        if not revenue_df.empty:
            fig_revenue = dashboard.create_revenue_chart(revenue_df)
            st.plotly_chart(fig_revenue, use_container_width=True)
        
        # Platform comparison
        st.header("📱 Platform Comparison")
        platform_df = dashboard.get_platform_comparison(7)
        
        if not platform_df.empty:
            fig_platform = dashboard.create_platform_comparison_chart(platform_df)
            st.plotly_chart(fig_platform, use_container_width=True)
        
        # User funnel
        st.header("🎯 User Funnel Analysis")
        funnel_df = dashboard.get_user_funnel_analysis(30)
        
        if not funnel_df.empty:
            funnel_data = funnel_df.iloc[0]
            
            col1, col2 = st.columns(2)
            
            with col1:
                st.subheader("Conversion Rates")
                st.metric("Login Conversion", f"{funnel_data['login_conversion_rate'] * 100:.1f}%")
                st.metric("Job Action Conversion", f"{funnel_data['job_conversion_rate'] * 100:.1f}%")
                st.metric("Payment Conversion", f"{funnel_data['payment_conversion_rate'] * 100:.1f}%")
            
            with col2:
                st.subheader("User Engagement")
                st.metric("Total Users", f"{funnel_data['total_users']:,}")
                st.metric("Active Users", f"{funnel_data['logged_in_users']:,}")
                st.metric("Avg Active Days", f"{funnel_data['avg_active_days']:.1f}")
        
        # Error analysis
        st.header("🚨 Error Analysis")
        error_df = dashboard.get_error_analysis(7)
        
        if not error_df.empty:
            st.dataframe(error_df, use_container_width=True)
        
        # Top craftsmen
        st.header("⭐ Top Performing Craftsmen")
        craftsmen_df = dashboard.get_craftsman_performance_metrics(10)
        
        if not craftsmen_df.empty:
            st.dataframe(craftsmen_df, use_container_width=True)
    
    except Exception as e:
        st.error(f"❌ Error loading dashboard data: {e}")
        logger.error(f"Dashboard error: {e}")

if __name__ == "__main__":
    create_streamlit_dashboard()