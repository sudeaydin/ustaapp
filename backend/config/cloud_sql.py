"""
Google Cloud SQL Configuration
"""

import os
import sqlalchemy
from google.cloud.sql.connector import Connector

def init_cloud_sql_engine():
    """Initialize Cloud SQL engine with connection pooling"""
    
    # Cloud SQL connection details
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT', 'ustaapp-analytics')
    region = os.environ.get('CLOUD_SQL_REGION', 'us-central1')
    instance_name = os.environ.get('CLOUD_SQL_INSTANCE', 'ustam-db')
    database_name = os.environ.get('CLOUD_SQL_DATABASE', 'ustam')
    
    # Database credentials
    db_user = os.environ.get('CLOUD_SQL_USERNAME', 'ustam_user')
    db_password = os.environ.get('CLOUD_SQL_PASSWORD')
    
    # Connection string format
    instance_connection_name = f"{project_id}:{region}:{instance_name}"
    
    # Initialize Cloud SQL Connector
    connector = Connector()
    
    def getconn():
        conn = connector.connect(
            instance_connection_name,
            "pg8000",
            user=db_user,
            password=db_password,
            db=database_name,
        )
        return conn
    
    # Create SQLAlchemy engine
    engine = sqlalchemy.create_engine(
        "postgresql+pg8000://",
        creator=getconn,
        pool_size=5,
        max_overflow=2,
        pool_timeout=30,
        pool_recycle=1800,
    )
    
    return engine

def get_cloud_sql_url():
    """Get Cloud SQL connection URL"""
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT', 'ustaapp-analytics')
    region = os.environ.get('CLOUD_SQL_REGION', 'us-central1')
    instance_name = os.environ.get('CLOUD_SQL_INSTANCE', 'ustam-db')
    database_name = os.environ.get('CLOUD_SQL_DATABASE', 'ustam')
    
    db_user = os.environ.get('CLOUD_SQL_USERNAME', 'ustam_user')
    db_password = os.environ.get('CLOUD_SQL_PASSWORD')
    
    # For App Engine, use unix socket connection
    if os.environ.get('GAE_ENV', '').startswith('standard'):
        connection_string = (
            f"postgresql+psycopg2://{db_user}:{db_password}@"
            f"/{database_name}?host=/cloudsql/{project_id}:{region}:{instance_name}"
        )
    else:
        # For local development or other environments
        connection_string = (
            f"postgresql+psycopg2://{db_user}:{db_password}@"
            f"127.0.0.1:5432/{database_name}"
        )
    
    return connection_string