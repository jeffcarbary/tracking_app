from sqlalchemy import func, text
from app.budget.models import Transaction, Category
from datetime import timedelta


class ReportQueries:
    def __init__(self, db):
        self.db = db

    def get_daily_totals(self, start, end):
        # Fetch totals for days that have data
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

        # Convert query results to a dict
        data = {str(r.day): float(r.total) for r in results}

        # Fill in missing days with 0
        current = start
        filled = {}
        while current <= end:
            key = current.isoformat()
            filled[key] = data.get(key, 0.0)
            current += timedelta(days=1)

        return filled

    def get_weekly_totals_for_category(self, category, start_date, end_date):
        query = text("""
            SELECT
                TO_CHAR(DATE_TRUNC('week', t.date), 'IYYY-IW') AS week_label,
                SUM(t.amount) AS total
            FROM transactions t
            JOIN categories c ON t.category_id = c.id
            WHERE c.name = :category
              AND t.date BETWEEN :start_date AND :end_date
            GROUP BY week_label
            ORDER BY week_label
        """)
        results = self.db.session.execute(query, {
            "category": category,
            "start_date": start_date,
            "end_date": end_date
        }).fetchall()
        return {r[0]: r[1] for r in results}
