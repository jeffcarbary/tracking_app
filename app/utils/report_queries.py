from sqlalchemy import func
from app.db_models import Transaction

class ReportQueries:
    def __init__(self, db):
        self.db = db

    def get_daily_totals(self, start, end):
        results = (
            self.db.session.query(
                func.date(Transaction.date).label("day"),
                func.sum(Transaction.amount).label("total")
            )
            .filter(Transaction.date >= start, Transaction.date <= end)
            .group_by("day")
            .order_by("day")
            .all()
        )
        return {str(r.day): float(r.total) for r in results}
