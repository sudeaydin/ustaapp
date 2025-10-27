"""Utility helpers for lightweight analytics features.

This module intentionally keeps the analytics surface minimal so that core
endpoints depending on these helpers can operate safely in all environments.
The helpers below focus on returning simple, database-backed summaries rather
than complex data science outputs. They are designed to be fast, safe, and to
fail gracefully when data is missing.
"""

from __future__ import annotations

import logging
import time
from datetime import datetime, timedelta
from typing import Any, Dict, Optional

from flask import current_app, g, request
from sqlalchemy import func

from app import db

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Request middleware
# ---------------------------------------------------------------------------
def init_analytics_middleware(app) -> None:
    """Attach very light-weight request timing hooks."""

    @app.before_request
    def analytics_before_request() -> None:  # pragma: no cover - flask hook
        g.analytics_start_time = time.time()
        g.request_count = getattr(g, "request_count", 0) + 1

    @app.after_request
    def analytics_after_request(response):  # pragma: no cover - flask hook
        if hasattr(g, "analytics_start_time"):
            duration = time.time() - g.analytics_start_time
            logger.info(
                "Request: %s %s - Status: %s - Duration: %.3fs",
                request.method,
                request.path,
                response.status_code,
                duration,
            )

        return response

    logger.info("Basic analytics middleware initialized")


# ---------------------------------------------------------------------------
# Analytics helpers used by API routes
# ---------------------------------------------------------------------------
class AnalyticsTracker:
    """Utility that records user interactions in application logs."""

    @staticmethod
    def track_user_action(
        user_id: Optional[int],
        action: str,
        details: Optional[Dict[str, Any]] = None,
        page: Optional[str] = None,
    ) -> None:
        payload = {
            "user_id": user_id,
            "action": action,
            "page": page,
            "details": details or {},
            "timestamp": datetime.utcnow().isoformat(),
        }

        try:
            current_app.logger.info("analytics_event", extra={"analytics": payload})
        except RuntimeError:
            # Outside of an application context we fall back to the module logger
            logger.info("analytics_event %s", payload)


class BusinessMetrics:
    """Basic business level metrics used on dashboards."""

    @staticmethod
    def _quote_revenue_sum(query) -> float:
        raw_sum = query.scalar()
        return float(raw_sum or 0.0)

    @staticmethod
    def get_craftsman_metrics(craftsman_id: int) -> Optional[Dict[str, Any]]:
        from app.models.craftsman import Craftsman
        from app.models.job import Job, JobStatus
        from app.models.message import Message
        from app.models.quote import Quote, QuoteStatus

        craftsman = Craftsman.query.filter_by(id=craftsman_id).first()
        if not craftsman:
            # Backwards compatibility for older callers that still pass user IDs.
            craftsman = Craftsman.query.filter_by(user_id=craftsman_id).first()
        if not craftsman:
            return None

        craftsman_id = craftsman.id

        total_quotes = Quote.query.filter_by(craftsman_id=craftsman_id).count()
        accepted_quotes = Quote.query.filter_by(
            craftsman_id=craftsman_id, status=QuoteStatus.ACCEPTED.value
        ).count()
        completed_jobs = Job.query.filter(
            Job.craftsman_id == craftsman_id,
            Job.status == JobStatus.COMPLETED,
        ).count()

        revenue_query = db.session.query(func.sum(Quote.quoted_price)).filter(
            Quote.craftsman_id == craftsman_id,
            Quote.status == QuoteStatus.ACCEPTED.value,
        )

        unread_messages = Message.query.filter_by(
            receiver_id=craftsman.user_id, is_read=False
        ).count()

        return {
            "total_quotes": total_quotes,
            "accepted_quotes": accepted_quotes,
            "conversion_rate": (accepted_quotes / total_quotes * 100)
            if total_quotes
            else 0,
            "completed_jobs": completed_jobs,
            "estimated_revenue": BusinessMetrics._quote_revenue_sum(revenue_query),
            "unread_messages": unread_messages,
        }

    @staticmethod
    def get_customer_metrics(customer_id: int) -> Optional[Dict[str, Any]]:
        from app.models.customer import Customer
        from app.models.job import Job, JobStatus
        from app.models.quote import Quote, QuoteStatus

        customer = Customer.query.filter_by(id=customer_id).first()
        if not customer:
            # Backwards compatibility for older callers that still pass user IDs.
            customer = Customer.query.filter_by(user_id=customer_id).first()
        if not customer:
            return None

        customer_id = customer.id

        total_requests = Quote.query.filter_by(customer_id=customer_id).count()
        accepted_quotes = Quote.query.filter_by(
            customer_id=customer_id, status=QuoteStatus.ACCEPTED.value
        ).count()
        active_jobs = Job.query.filter(
            Job.customer_id == customer_id,
            Job.status.in_([JobStatus.IN_PROGRESS, JobStatus.ACCEPTED]),
        ).count()

        return {
            "total_requests": total_requests,
            "accepted_quotes": accepted_quotes,
            "acceptance_rate": (accepted_quotes / total_requests * 100)
            if total_requests
            else 0,
            "active_jobs": active_jobs,
        }

    @staticmethod
    def get_platform_overview() -> Dict[str, Any]:
        from app.models.job import Job, JobStatus
        from app.models.message import Message
        from app.models.payment import Payment
        from app.models.quote import Quote, QuoteStatus
        from app.models.user import User

        total_users = User.query.count()
        total_quotes = Quote.query.count()
        accepted_quotes = Quote.query.filter_by(status=QuoteStatus.ACCEPTED.value).count()
        active_jobs = Job.query.filter(
            Job.status.in_([JobStatus.IN_PROGRESS, JobStatus.ACCEPTED])
        ).count()
        total_messages = Message.query.count()

        revenue_query = db.session.query(func.sum(Payment.total_amount))

        return {
            "users": total_users,
            "quotes": total_quotes,
            "accepted_quotes": accepted_quotes,
            "active_jobs": active_jobs,
            "messages": total_messages,
            "total_payments": float(revenue_query.scalar() or 0.0),
        }

    @staticmethod
    def get_trend_analysis(days: int = 30) -> Dict[str, Any]:
        from app.models.quote import Quote

        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)

        daily_trend = (
            db.session.query(func.date(Quote.created_at), func.count(Quote.id))
            .filter(Quote.created_at >= start_date)
            .group_by(func.date(Quote.created_at))
            .order_by(func.date(Quote.created_at))
            .all()
        )

        return {
            "start_date": start_date.date().isoformat(),
            "end_date": end_date.date().isoformat(),
            "daily_quotes": [
                {"date": day.strftime("%Y-%m-%d"), "count": count}
                for day, count in daily_trend
            ],
        }


class CostCalculator:
    """Very small estimation helper for job costs."""

    BASE_RATE = 750  # TRY

    @staticmethod
    def estimate_job_cost(
        category: str,
        area_type: str,
        square_meters: Optional[float],
        complexity: str = "orta",
        city: str = "İstanbul",
    ) -> Dict[str, Any]:
        sq_m = square_meters or 50
        complexity_multiplier = {
            "dusuk": 0.9,
            "orta": 1.0,
            "yuksek": 1.25,
            "acil": 1.5,
        }.get(complexity.lower(), 1.0)

        city_multiplier = 1.1 if city.lower() in {"istanbul", "ankara", "izmir"} else 1.0
        estimate = CostCalculator.BASE_RATE * (sq_m / 10) * complexity_multiplier * city_multiplier

        return {
            "category": category,
            "area_type": area_type,
            "city": city,
            "estimated_cost": round(estimate, 2),
            "inputs": {
                "square_meters": sq_m,
                "complexity_multiplier": complexity_multiplier,
                "city_multiplier": city_multiplier,
            },
        }


class PerformanceMonitor:
    """Simplified performance metrics sourced from database activity."""

    @staticmethod
    def get_performance_report(hours: int = 24) -> Dict[str, Any]:
        from app.models.job import Job
        from app.models.message import Message
        from app.models.quote import Quote

        since = datetime.utcnow() - timedelta(hours=hours)

        recent_quotes = Quote.query.filter(Quote.created_at >= since).count()
        recent_messages = Message.query.filter(Message.created_at >= since).count()
        recent_jobs = Job.query.filter(Job.created_at >= since).count()

        return {
            "window_hours": hours,
            "quotes_created": recent_quotes,
            "messages_sent": recent_messages,
            "jobs_created": recent_jobs,
        }


class UserBehaviorAnalytics:
    """Basic insight into user engagement."""

    @staticmethod
    def get_user_journey_analysis(days: int = 30) -> Dict[str, Any]:
        from app.models.quote import Quote
        from app.models.user import User

        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)

        new_users = User.query.filter(User.created_at >= start_date).count()
        quote_creators = (
            db.session.query(func.count(func.distinct(Quote.customer_id)))
            .filter(Quote.created_at >= start_date)
            .scalar()
        )

        return {
            "new_users": new_users,
            "active_customers": int(quote_creators or 0),
            "period_days": days,
        }

    @staticmethod
    def get_search_analytics() -> Dict[str, Any]:
        from app.models.craftsman import Craftsman

        available_craftsmen = Craftsman.query.filter_by(is_available=True).count()
        verified_craftsmen = Craftsman.query.filter_by(is_verified=True).count()

        return {
            "available_craftsmen": available_craftsmen,
            "verified_craftsmen": verified_craftsmen,
        }


class DashboardData:
    """Live stats for dashboards."""

    @staticmethod
    def get_live_stats() -> Dict[str, Any]:
        from app.models.job import Job, JobStatus
        from app.models.quote import Quote, QuoteStatus

        pending_quotes = Quote.query.filter_by(status=QuoteStatus.PENDING.value).count()
        in_progress_jobs = Job.query.filter_by(status=JobStatus.IN_PROGRESS).count()

        return {
            "pending_quotes": pending_quotes,
            "jobs_in_progress": in_progress_jobs,
        }


__all__ = [
    "init_analytics_middleware",
    "AnalyticsTracker",
    "BusinessMetrics",
    "CostCalculator",
    "PerformanceMonitor",
    "UserBehaviorAnalytics",
    "DashboardData",
]

