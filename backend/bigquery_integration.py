#!/usr/bin/env python3
"""
BigQuery Integration for Ustam App
Data export, analytics, and business intelligence integration
"""

import os
import sys
import json
import pandas as pd
from datetime import datetime, timedelta
from decimal import Decimal
import logging

# Add the backend directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.job import Job
from app.models.quote import Quote
from app.models.review import Review
from app.models.payment import Payment
from app.models.notification import Notification
from app.models.message import Message

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class UstamBigQueryExporter:
    """BigQuery data exporter and analytics integration"""
    
    def __init__(self):
        self.app = create_app()
        self.export_dir = os.path.join(os.path.dirname(__file__), 'bigquery_exports')
        os.makedirs(self.export_dir, exist_ok=True)
        
        # BigQuery table schemas
        self.schemas = {
            'users': self._get_users_schema(),
            'customers': self._get_customers_schema(),
            'craftsmen': self._get_craftsmen_schema(),
            'categories': self._get_categories_schema(),
            'jobs': self._get_jobs_schema(),
            'quotes': self._get_quotes_schema(),
            'reviews': self._get_reviews_schema(),
            'payments': self._get_payments_schema(),
            'messages': self._get_messages_schema(),
            'notifications': self._get_notifications_schema()
        }
    
    def _get_users_schema(self):
        """BigQuery schema for users table"""
        return [
            {"name": "user_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "email", "type": "STRING", "mode": "REQUIRED"},
            {"name": "phone", "type": "STRING", "mode": "NULLABLE"},
            {"name": "user_type", "type": "STRING", "mode": "REQUIRED"},
            {"name": "first_name", "type": "STRING", "mode": "NULLABLE"},
            {"name": "last_name", "type": "STRING", "mode": "NULLABLE"},
            {"name": "date_of_birth", "type": "DATE", "mode": "NULLABLE"},
            {"name": "gender", "type": "STRING", "mode": "NULLABLE"},
            {"name": "city", "type": "STRING", "mode": "NULLABLE"},
            {"name": "district", "type": "STRING", "mode": "NULLABLE"},
            {"name": "latitude", "type": "FLOAT", "mode": "NULLABLE"},
            {"name": "longitude", "type": "FLOAT", "mode": "NULLABLE"},
            {"name": "is_active", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "is_verified", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "phone_verified", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "email_verified", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "is_premium", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "updated_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "last_login", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_customers_schema(self):
        """BigQuery schema for customers table"""
        return [
            {"name": "customer_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "user_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "company_name", "type": "STRING", "mode": "NULLABLE"},
            {"name": "tax_number", "type": "STRING", "mode": "NULLABLE"},
            {"name": "preferred_contact_method", "type": "STRING", "mode": "NULLABLE"},
            {"name": "total_jobs", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "total_spent", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "average_rating", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "updated_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_craftsmen_schema(self):
        """BigQuery schema for craftsmen table"""
        return [
            {"name": "craftsman_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "user_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "business_name", "type": "STRING", "mode": "NULLABLE"},
            {"name": "business_type", "type": "STRING", "mode": "NULLABLE"},
            {"name": "description", "type": "STRING", "mode": "NULLABLE"},
            {"name": "hourly_rate", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "min_job_price", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "service_radius", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "average_rating", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "total_reviews", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "total_jobs", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "completion_rate", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "is_available", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "is_verified", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "is_featured", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "verification_level", "type": "STRING", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "updated_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_categories_schema(self):
        """BigQuery schema for categories table"""
        return [
            {"name": "category_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "name", "type": "STRING", "mode": "REQUIRED"},
            {"name": "name_en", "type": "STRING", "mode": "NULLABLE"},
            {"name": "slug", "type": "STRING", "mode": "NULLABLE"},
            {"name": "description", "type": "STRING", "mode": "NULLABLE"},
            {"name": "icon", "type": "STRING", "mode": "NULLABLE"},
            {"name": "color", "type": "STRING", "mode": "NULLABLE"},
            {"name": "is_active", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "is_featured", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "sort_order", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "total_jobs", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "total_craftsmen", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_jobs_schema(self):
        """BigQuery schema for jobs table"""
        return [
            {"name": "job_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "title", "type": "STRING", "mode": "REQUIRED"},
            {"name": "description", "type": "STRING", "mode": "NULLABLE"},
            {"name": "category_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "customer_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "assigned_craftsman_id", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "location", "type": "STRING", "mode": "NULLABLE"},
            {"name": "city", "type": "STRING", "mode": "NULLABLE"},
            {"name": "district", "type": "STRING", "mode": "NULLABLE"},
            {"name": "latitude", "type": "FLOAT", "mode": "NULLABLE"},
            {"name": "longitude", "type": "FLOAT", "mode": "NULLABLE"},
            {"name": "budget_min", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "budget_max", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "final_price", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "urgency", "type": "STRING", "mode": "NULLABLE"},
            {"name": "status", "type": "STRING", "mode": "NULLABLE"},
            {"name": "preferred_date", "type": "DATE", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "updated_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "completed_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "view_count", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "quote_count", "type": "INTEGER", "mode": "NULLABLE"}
        ]
    
    def _get_quotes_schema(self):
        """BigQuery schema for quotes table"""
        return [
            {"name": "quote_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "job_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "craftsman_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "price", "type": "NUMERIC", "mode": "REQUIRED"},
            {"name": "description", "type": "STRING", "mode": "NULLABLE"},
            {"name": "estimated_duration", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "materials_included", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "warranty_period", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "status", "type": "STRING", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "updated_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "accepted_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_reviews_schema(self):
        """BigQuery schema for reviews table"""
        return [
            {"name": "review_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "job_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "customer_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "craftsman_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "rating", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "title", "type": "STRING", "mode": "NULLABLE"},
            {"name": "comment", "type": "STRING", "mode": "NULLABLE"},
            {"name": "quality_rating", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "punctuality_rating", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "communication_rating", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "value_rating", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "is_verified", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "is_featured", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_payments_schema(self):
        """BigQuery schema for payments table"""
        return [
            {"name": "payment_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "transaction_id", "type": "STRING", "mode": "REQUIRED"},
            {"name": "job_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "customer_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "craftsman_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "amount", "type": "NUMERIC", "mode": "REQUIRED"},
            {"name": "platform_fee", "type": "NUMERIC", "mode": "NULLABLE"},
            {"name": "craftsman_amount", "type": "NUMERIC", "mode": "REQUIRED"},
            {"name": "payment_method", "type": "STRING", "mode": "NULLABLE"},
            {"name": "payment_provider", "type": "STRING", "mode": "NULLABLE"},
            {"name": "currency", "type": "STRING", "mode": "NULLABLE"},
            {"name": "status", "type": "STRING", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "completed_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_messages_schema(self):
        """BigQuery schema for messages table"""
        return [
            {"name": "message_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "sender_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "recipient_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "message_type", "type": "STRING", "mode": "NULLABLE"},
            {"name": "job_id", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "quote_id", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "is_read", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "read_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def _get_notifications_schema(self):
        """BigQuery schema for notifications table"""
        return [
            {"name": "notification_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "user_id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "title", "type": "STRING", "mode": "REQUIRED"},
            {"name": "type", "type": "STRING", "mode": "NULLABLE"},
            {"name": "related_id", "type": "INTEGER", "mode": "NULLABLE"},
            {"name": "related_type", "type": "STRING", "mode": "NULLABLE"},
            {"name": "is_read", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "is_sent", "type": "BOOLEAN", "mode": "NULLABLE"},
            {"name": "created_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
            {"name": "read_at", "type": "TIMESTAMP", "mode": "NULLABLE"}
        ]
    
    def export_users_data(self):
        """Export users data for BigQuery"""
        with self.app.app_context():
            users = User.query.all()
            
            data = []
            for user in users:
                data.append({
                    'user_id': user.id,
                    'email': user.email,
                    'phone': user.phone,
                    'user_type': user.user_type,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                    'date_of_birth': user.date_of_birth.isoformat() if user.date_of_birth else None,
                    'gender': user.gender,
                    'city': user.city,
                    'district': user.district,
                    'latitude': float(user.latitude) if user.latitude else None,
                    'longitude': float(user.longitude) if user.longitude else None,
                    'is_active': user.is_active,
                    'is_verified': user.is_verified,
                    'phone_verified': user.phone_verified,
                    'email_verified': user.email_verified,
                    'is_premium': user.is_premium,
                    'created_at': user.created_at.isoformat() if user.created_at else None,
                    'updated_at': user.updated_at.isoformat() if user.updated_at else None,
                    'last_login': user.last_login.isoformat() if user.last_login else None
                })
            
            # Save to JSON for BigQuery import
            filename = f"users_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            filepath = os.path.join(self.export_dir, filename)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                for record in data:
                    f.write(json.dumps(record, ensure_ascii=False) + '\n')
            
            logger.info(f"Users data exported: {len(data)} records -> {filepath}")
            return filepath, len(data)
    
    def export_jobs_data(self):
        """Export jobs data for BigQuery"""
        with self.app.app_context():
            jobs = Job.query.all()
            
            data = []
            for job in jobs:
                data.append({
                    'job_id': job.id,
                    'title': job.title,
                    'description': job.description,
                    'category_id': job.category_id,
                    'customer_id': job.customer_id,
                    'assigned_craftsman_id': job.assigned_craftsman_id,
                    'location': job.location,
                    'city': job.city,
                    'district': job.district,
                    'latitude': float(job.latitude) if job.latitude else None,
                    'longitude': float(job.longitude) if job.longitude else None,
                    'budget_min': float(job.budget_min) if job.budget_min else None,
                    'budget_max': float(job.budget_max) if job.budget_max else None,
                    'final_price': float(job.final_price) if job.final_price else None,
                    'urgency': job.urgency,
                    'status': job.status,
                    'preferred_date': job.preferred_date.isoformat() if job.preferred_date else None,
                    'created_at': job.created_at.isoformat() if job.created_at else None,
                    'updated_at': job.updated_at.isoformat() if job.updated_at else None,
                    'completed_at': job.completed_at.isoformat() if job.completed_at else None,
                    'view_count': job.view_count or 0,
                    'quote_count': job.quote_count or 0
                })
            
            filename = f"jobs_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            filepath = os.path.join(self.export_dir, filename)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                for record in data:
                    f.write(json.dumps(record, ensure_ascii=False) + '\n')
            
            logger.info(f"Jobs data exported: {len(data)} records -> {filepath}")
            return filepath, len(data)
    
    def export_categories_data(self):
        """Export categories data for BigQuery"""
        with self.app.app_context():
            categories = Category.query.all()
            
            data = []
            for category in categories:
                data.append({
                    'category_id': category.id,
                    'name': category.name,
                    'name_en': category.name_en,
                    'slug': category.slug,
                    'description': category.description,
                    'icon': category.icon,
                    'color': category.color,
                    'image_url': category.image_url,
                    'meta_title': category.meta_title,
                    'meta_description': category.meta_description,
                    'is_active': category.is_active,
                    'is_featured': category.is_featured,
                    'sort_order': category.sort_order,
                    'total_jobs': category.total_jobs,
                    'total_craftsmen': category.total_craftsmen,
                    'created_at': category.created_at.isoformat() if category.created_at else None
                })
            
            filename = f"categories_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            filepath = os.path.join(self.export_dir, filename)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                for record in data:
                    f.write(json.dumps(record, ensure_ascii=False) + '\n')
            
            logger.info(f"Categories data exported: {len(data)} records -> {filepath}")
            return filepath, len(data)

    def export_customers_data(self):
        """Export customers data for BigQuery"""
        with self.app.app_context():
            customers = Customer.query.all()
            
            data = []
            for customer in customers:
                data.append({
                    'customer_id': customer.id,
                    'user_id': customer.user_id,
                    'company_name': customer.company_name,
                    'tax_number': customer.tax_number,
                    'billing_address': customer.billing_address,
                    'preferred_contact_method': customer.preferred_contact_method,
                    'notification_preferences': customer.notification_preferences,
                    'total_jobs': customer.total_jobs,
                    'total_spent': float(customer.total_spent) if customer.total_spent else 0.0,
                    'average_rating': float(customer.average_rating) if customer.average_rating else 0.0,
                    'created_at': customer.created_at.isoformat() if customer.created_at else None,
                    'updated_at': customer.updated_at.isoformat() if customer.updated_at else None
                })
            
            filename = f"customers_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            filepath = os.path.join(self.export_dir, filename)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                for record in data:
                    f.write(json.dumps(record, ensure_ascii=False) + '\n')
            
            logger.info(f"Customers data exported: {len(data)} records -> {filepath}")
            return filepath, len(data)

    def export_craftsmen_data(self):
        """Export craftsmen data for BigQuery"""
        with self.app.app_context():
            craftsmen = Craftsman.query.all()
            
            data = []
            for craftsman in craftsmen:
                data.append({
                    'craftsman_id': craftsman.id,
                    'user_id': craftsman.user_id,
                    'business_name': craftsman.business_name,
                    'business_type': craftsman.business_type,
                    'description': craftsman.description,
                    'hourly_rate': float(craftsman.hourly_rate) if craftsman.hourly_rate else None,
                    'min_job_price': float(craftsman.min_job_price) if craftsman.min_job_price else None,
                    'service_radius': craftsman.service_radius,
                    'average_rating': float(craftsman.average_rating) if craftsman.average_rating else 0.0,
                    'total_reviews': craftsman.total_reviews,
                    'total_jobs': craftsman.total_jobs,
                    'completion_rate': float(craftsman.completion_rate) if craftsman.completion_rate else 0.0,
                    'is_available': craftsman.is_available,
                    'is_verified': craftsman.is_verified,
                    'is_featured': craftsman.is_featured,
                    'verification_level': craftsman.verification_level,
                    'created_at': craftsman.created_at.isoformat() if craftsman.created_at else None,
                    'updated_at': craftsman.updated_at.isoformat() if craftsman.updated_at else None
                })
            
            filename = f"craftsmen_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            filepath = os.path.join(self.export_dir, filename)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                for record in data:
                    f.write(json.dumps(record, ensure_ascii=False) + '\n')
            
            logger.info(f"Craftsmen data exported: {len(data)} records -> {filepath}")
            return filepath, len(data)

    def export_all_data(self):
        """Export all data for BigQuery"""
        exports = {}
        
        # Export users
        try:
            filepath, count = self.export_users_data()
            exports['users'] = {'file': filepath, 'count': count}
        except Exception as e:
            logger.error(f"Failed to export users: {str(e)}")
        
        # Export categories
        try:
            filepath, count = self.export_categories_data()
            exports['categories'] = {'file': filepath, 'count': count}
        except Exception as e:
            logger.error(f"Failed to export categories: {str(e)}")
        
        # Export customers
        try:
            filepath, count = self.export_customers_data()
            exports['customers'] = {'file': filepath, 'count': count}
        except Exception as e:
            logger.error(f"Failed to export customers: {str(e)}")
        
        # Export craftsmen
        try:
            filepath, count = self.export_craftsmen_data()
            exports['craftsmen'] = {'file': filepath, 'count': count}
        except Exception as e:
            logger.error(f"Failed to export craftsmen: {str(e)}")
        
        # Export jobs
        try:
            filepath, count = self.export_jobs_data()
            exports['jobs'] = {'file': filepath, 'count': count}
        except Exception as e:
            logger.error(f"Failed to export jobs: {str(e)}")
        
        return exports
    
    def generate_bigquery_schemas(self):
        """Generate BigQuery table creation scripts"""
        schemas_dir = os.path.join(self.export_dir, 'schemas')
        os.makedirs(schemas_dir, exist_ok=True)
        
        for table_name, schema in self.schemas.items():
            # Generate BigQuery DDL
            ddl = f"CREATE TABLE IF NOT EXISTS `ustam_analytics.{table_name}` (\n"
            
            fields = []
            for field in schema:
                field_def = f"  {field['name']} {field['type']}"
                if field['mode'] == 'REQUIRED':
                    field_def += " NOT NULL"
                fields.append(field_def)
            
            ddl += ",\n".join(fields)
            ddl += "\n);"
            
            # Save DDL to file
            ddl_file = os.path.join(schemas_dir, f"{table_name}_schema.sql")
            with open(ddl_file, 'w') as f:
                f.write(ddl)
            
            # Save JSON schema for BigQuery API
            json_file = os.path.join(schemas_dir, f"{table_name}_schema.json")
            with open(json_file, 'w') as f:
                json.dump(schema, f, indent=2)
        
        logger.info(f"BigQuery schemas generated in: {schemas_dir}")
        return schemas_dir
    
    def create_analytics_views(self):
        """Create BigQuery views for analytics"""
        views_dir = os.path.join(self.export_dir, 'views')
        os.makedirs(views_dir, exist_ok=True)
        
        # User activity view
        user_activity_view = """
        CREATE OR REPLACE VIEW `ustam_analytics.user_activity` AS
        SELECT 
            u.user_id,
            u.user_type,
            u.city,
            u.created_at as registration_date,
            u.last_login,
            CASE 
                WHEN u.last_login >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) THEN 'Active'
                WHEN u.last_login >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY) THEN 'Inactive'
                ELSE 'Dormant'
            END as activity_status,
            CASE 
                WHEN u.user_type = 'customer' THEN c.total_jobs
                WHEN u.user_type = 'craftsman' THEN cr.total_jobs
                ELSE 0
            END as total_jobs,
            CASE 
                WHEN u.user_type = 'customer' THEN c.total_spent
                WHEN u.user_type = 'craftsman' THEN cr.average_rating
                ELSE 0
            END as performance_metric
        FROM `ustam_analytics.users` u
        LEFT JOIN `ustam_analytics.customers` c ON u.user_id = c.user_id
        LEFT JOIN `ustam_analytics.craftsmen` cr ON u.user_id = cr.user_id
        WHERE u.is_active = true;
        """
        
        # Job analytics view
        job_analytics_view = """
        CREATE OR REPLACE VIEW `ustam_analytics.job_analytics` AS
        SELECT 
            j.job_id,
            j.category_id,
            cat.name as category_name,
            j.city,
            j.status,
            j.budget_min,
            j.budget_max,
            j.final_price,
            j.urgency,
            j.created_at,
            j.completed_at,
            DATETIME_DIFF(j.completed_at, j.created_at, HOUR) as completion_hours,
            j.quote_count,
            CASE 
                WHEN j.status = 'completed' THEN 'Success'
                WHEN j.status = 'cancelled' THEN 'Cancelled'
                WHEN j.status IN ('open', 'assigned', 'in_progress') THEN 'In Progress'
                ELSE 'Other'
            END as job_outcome
        FROM `ustam_analytics.jobs` j
        LEFT JOIN `ustam_analytics.categories` cat ON j.category_id = cat.category_id;
        """
        
        # Revenue analytics view
        revenue_analytics_view = """
        CREATE OR REPLACE VIEW `ustam_analytics.revenue_analytics` AS
        SELECT 
            DATE(p.created_at) as payment_date,
            EXTRACT(YEAR FROM p.created_at) as year,
            EXTRACT(MONTH FROM p.created_at) as month,
            COUNT(*) as transaction_count,
            SUM(p.amount) as total_revenue,
            SUM(p.platform_fee) as platform_revenue,
            SUM(p.craftsman_amount) as craftsman_revenue,
            AVG(p.amount) as avg_transaction_amount,
            p.payment_method,
            p.status
        FROM `ustam_analytics.payments` p
        WHERE p.status = 'completed'
        GROUP BY 
            DATE(p.created_at),
            EXTRACT(YEAR FROM p.created_at),
            EXTRACT(MONTH FROM p.created_at),
            p.payment_method,
            p.status;
        """
        
        views = {
            'user_activity': user_activity_view,
            'job_analytics': job_analytics_view,
            'revenue_analytics': revenue_analytics_view
        }
        
        for view_name, view_sql in views.items():
            view_file = os.path.join(views_dir, f"{view_name}_view.sql")
            with open(view_file, 'w') as f:
                f.write(view_sql)
        
        logger.info(f"Analytics views created in: {views_dir}")
        return views_dir

def main():
    """Main function for BigQuery export"""
    print("🔨 USTAM - BIGQUERY DATA EXPORT")
    print("="*50)
    
    exporter = UstamBigQueryExporter()
    
    # Generate schemas
    print("📋 Generating BigQuery schemas...")
    schemas_dir = exporter.generate_bigquery_schemas()
    
    # Create analytics views
    print("📊 Creating analytics views...")
    views_dir = exporter.create_analytics_views()
    
    # Export data
    print("📤 Exporting data...")
    exports = exporter.export_all_data()
    
    print("\n✅ BigQuery Export Complete!")
    print("="*50)
    print(f"📁 Export Directory: {exporter.export_dir}")
    print(f"📋 Schemas: {schemas_dir}")
    print(f"📊 Views: {views_dir}")
    
    print("\n📊 Exported Data:")
    for table, info in exports.items():
        print(f"   • {table}: {info['count']} records")
    
    print("\n🔧 Next Steps:")
    print("1. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install")
    print("2. Create BigQuery dataset: bq mk ustam_analytics")
    print("3. Create tables using schema files")
    print("4. Load data using: bq load --source_format=NEWLINE_DELIMITED_JSON")
    print("5. Create views using view SQL files")
    
    print("\n📖 BigQuery Commands:")
    print("# Create dataset")
    print("bq mk --dataset --location=US ustam_analytics")
    print()
    print("# Load users data")
    print(f"bq load --source_format=NEWLINE_DELIMITED_JSON ustam_analytics.users {exporter.export_dir}/users_*.json")
    print()
    print("# Load jobs data")
    print(f"bq load --source_format=NEWLINE_DELIMITED_JSON ustam_analytics.jobs {exporter.export_dir}/jobs_*.json")

if __name__ == '__main__':
    main()