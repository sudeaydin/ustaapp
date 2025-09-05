#!/usr/bin/env python3
"""
BigQuery to SQLite Sync
Ana veri BigQuery'de, SQLite sadece local cache
"""

import os
import sys
import sqlite3
from datetime import datetime
from google.cloud import bigquery
import logging

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models.user import User
from app.models.customer import Customer
from app.models.craftsman import Craftsman
from app.models.category import Category
from app.models.job import Job
from app.models.payment import Payment
from app.models.review import Review

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class BigQueryToSQLiteSync:
    """BigQuery'den SQLite'a veri senkronizasyonu"""
    
    def __init__(self, project_id="ustaapp-analytics"):
        self.project_id = project_id
        self.dataset_id = "ustam_analytics"
        self.client = None
        
    def initialize_bigquery(self):
        """BigQuery client başlat"""
        try:
            self.client = bigquery.Client(project=self.project_id)
            logger.info(f"✅ BigQuery connected: {self.project_id}")
            return True
        except Exception as e:
            logger.error(f"❌ BigQuery connection failed: {e}")
            return False
    
    def check_bigquery_data(self):
        """BigQuery'de veri var mı kontrol et"""
        try:
            # Users tablosunu kontrol et
            query = f"""
            SELECT COUNT(*) as count 
            FROM `{self.project_id}.{self.dataset_id}.users`
            """
            
            result = list(self.client.query(query))
            user_count = result[0].count if result else 0
            
            logger.info(f"📊 BigQuery'de {user_count} kullanıcı var")
            return user_count > 0
            
        except Exception as e:
            logger.warning(f"⚠️ BigQuery data check failed: {e}")
            return False
    
    def sync_users_from_bigquery(self):
        """BigQuery'den kullanıcıları çek"""
        try:
            query = f"""
            SELECT user_id, email, first_name, last_name, phone, user_type, 
                   is_active, is_verified, created_at, updated_at
            FROM `{self.project_id}.{self.dataset_id}.users`
            ORDER BY created_at DESC
            """
            
            results = list(self.client.query(query))
            
            for row in results:
                # SQLite'da var mı kontrol et
                existing_user = User.query.filter_by(id=row.user_id).first()
                
                if not existing_user:
                    # Yeni kullanıcı oluştur
                    user = User(
                        id=row.user_id,
                        email=row.email,
                        first_name=row.first_name,
                        last_name=row.last_name,
                        phone=row.phone,
                        user_type=row.user_type,
                        is_active=row.is_active,
                        is_verified=row.is_verified,
                        password_hash='temp_hash',  # BigQuery'de password hash yok
                        created_at=row.created_at,
                        updated_at=row.updated_at
                    )
                    db.session.add(user)
            
            db.session.commit()
            logger.info(f"✅ {len(results)} kullanıcı BigQuery'den senkronize edildi")
            return True
            
        except Exception as e:
            logger.error(f"❌ Users sync failed: {e}")
            return False
    
    def sync_all_from_bigquery(self):
        """Tüm tabloları BigQuery'den senkronize et"""
        logger.info("🔄 BigQuery'den SQLite'a senkronizasyon başlıyor...")
        
        sync_operations = [
            ("users", self.sync_users_from_bigquery),
            # Diğer tablolar da eklenebilir
        ]
        
        success_count = 0
        for table_name, sync_func in sync_operations:
            logger.info(f"📊 Syncing {table_name}...")
            if sync_func():
                success_count += 1
        
        logger.info(f"✅ Sync completed: {success_count}/{len(sync_operations)} tables")
        return success_count == len(sync_operations)

def smart_database_setup():
    """Akıllı database kurulumu - BigQuery'de veri varsa oradan çek"""
    
    # Flask app context
    app = create_app()
    with app.app_context():
        # Database tablolarını oluştur
        db.create_all()
        
        # BigQuery sync dene
        syncer = BigQueryToSQLiteSync()
        
        if syncer.initialize_bigquery() and syncer.check_bigquery_data():
            logger.info("🎯 BigQuery'de veri bulundu! Oradan senkronize ediliyor...")
            
            if syncer.sync_all_from_bigquery():
                logger.info("✅ BigQuery'den veri senkronizasyonu başarılı!")
                return True
            else:
                logger.warning("⚠️ BigQuery sync failed, creating sample data...")
        else:
            logger.info("📋 BigQuery'de veri yok, sample data oluşturuluyor...")
        
        # BigQuery'den sync başarısız olursa sample data oluştur
        from create_db_with_data import create_sample_data
        create_sample_data()
        logger.info("✅ Sample data oluşturuldu!")
        return True

if __name__ == '__main__':
    smart_database_setup()