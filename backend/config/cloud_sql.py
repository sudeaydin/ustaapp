"""Utilities for configuring Google Cloud SQL connections."""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import List, Optional

import sqlalchemy
from google.cloud.sql.connector import Connector


class CloudSQLConfigError(RuntimeError):
    """Raised when Cloud SQL configuration is missing required values."""


@dataclass(frozen=True)
class CloudSQLSettings:
    """Typed representation of Cloud SQL related environment variables."""

    db_user: Optional[str]
    db_password: Optional[str]
    db_name: Optional[str]
    db_host: Optional[str]
    db_port: str
    connection_name: Optional[str]
    db_socket_dir: str
    instance_unix_socket: Optional[str]

    def missing_fields(self, require_connection_name: bool = False) -> List[str]:
        """Return a list of missing environment keys required for Cloud SQL."""

        missing: List[str] = []

        required_values = {
            "DB_USER": self.db_user,
            "DB_PASSWORD": self.db_password,
            "DB_NAME": self.db_name,
        }

        for key, value in required_values.items():
            if not value:
                missing.append(key)

        if self.db_host:
            return missing

        if require_connection_name:
            if not self.connection_name:
                missing.append("CLOUD_SQL_CONNECTION_NAME")
        elif not (self.connection_name or self.instance_unix_socket):
            missing.append("CLOUD_SQL_CONNECTION_NAME or INSTANCE_UNIX_SOCKET")

        return missing

    def resolve_unix_socket(self) -> str:
        """Resolve the Unix socket path for the Cloud SQL instance."""

        if self.instance_unix_socket:
            return self.instance_unix_socket

        if not self.connection_name:
            raise CloudSQLConfigError(
                "Cloud SQL connection name is required to build the Unix socket path."
            )

        socket_dir = self.db_socket_dir or "/cloudsql"
        return os.path.join(socket_dir, self.connection_name)


def load_cloud_sql_config(validate: bool = False, *, require_connection_name: bool = False) -> CloudSQLSettings:
    """Load Cloud SQL configuration from the environment."""

    settings = CloudSQLSettings(
        db_user=os.environ.get("DB_USER"),
        db_password=os.environ.get("DB_PASSWORD"),
        db_name=os.environ.get("DB_NAME"),
        db_host=os.environ.get("DB_HOST"),
        db_port=os.environ.get("DB_PORT", "5432"),
        connection_name=os.environ.get("CLOUD_SQL_CONNECTION_NAME"),
        db_socket_dir=os.environ.get("DB_SOCKET_DIR", "/cloudsql"),
        instance_unix_socket=os.environ.get("INSTANCE_UNIX_SOCKET"),
    )

    if validate:
        missing = settings.missing_fields(require_connection_name=require_connection_name)
        if missing:
            raise CloudSQLConfigError(
                "Cloud SQL configuration is incomplete. Set the following environment "
                f"variables: {', '.join(missing)}."
            )

    return settings


def validate_cloud_sql_config(*, require_connection_name: bool = False) -> CloudSQLSettings:
    """Validate that mandatory Cloud SQL configuration values exist."""

    return load_cloud_sql_config(validate=True, require_connection_name=require_connection_name)


def init_cloud_sql_engine() -> sqlalchemy.engine.Engine:
    """Initialize a SQLAlchemy engine that connects to Cloud SQL via the Connector."""

    settings = validate_cloud_sql_config(require_connection_name=True)

    connector = Connector()

    def getconn():
        return connector.connect(
            settings.connection_name,
            "pg8000",
            user=settings.db_user,
            password=settings.db_password,
            db=settings.db_name,
        )

    engine = sqlalchemy.create_engine(
        "postgresql+pg8000://",
        creator=getconn,
        pool_size=5,
        max_overflow=2,
        pool_timeout=30,
        pool_recycle=1800,
    )

    return engine


def get_cloud_sql_url(settings: Optional[CloudSQLSettings] = None) -> str:
    """Construct a SQLAlchemy connection URL for the configured Cloud SQL instance."""

    resolved_settings = settings or validate_cloud_sql_config()

    if resolved_settings.db_host:
        return (
            "postgresql+psycopg2://"
            f"{resolved_settings.db_user}:{resolved_settings.db_password}"
            f"@{resolved_settings.db_host}:{resolved_settings.db_port}/{resolved_settings.db_name}"
        )

    unix_socket = resolved_settings.resolve_unix_socket()
    return (
        "postgresql+psycopg2://"
        f"{resolved_settings.db_user}:{resolved_settings.db_password}"
        f"@/{resolved_settings.db_name}?host={unix_socket}"
    )

