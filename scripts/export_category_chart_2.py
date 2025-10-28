from app.budget_app import app
from app.db_models import db, Transaction, Category
from sqlalchemy import func
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

def plot_weekly_category_totals(category_name, start_date, end_date):
    with app.app_context():
        start_date = datetime.strptime(start_date, "%Y-%m-%d").date()
        end_date = datetime.strptime(end_date, "%Y-%m-%d").date()

        category = Category.query.filter(func.lower(Category.name) == category_name.lower()).first()
        if not category:
            print(f"❌ No category named '{category_name}' found.")
            return

        txns = (
            Transaction.query
            .filter(Transaction.category_id == category.id)
            .filter(Transaction.date >= start_date)
            .filter(Transaction.date <= end_date)
            .all()
        )

        if not txns:
            print(f"⚠️ No transactions found for '{category_name}' in that range.")
            return

        # Group by week
        weekly_sums = {}
        for txn in txns:
            week_start = txn.date - timedelta(days=txn.date.weekday())
            weekly_sums[week_start] = weekly_sums.get(week_start, 0) + txn.amount

        sorted_weeks = sorted(weekly_sums.items())

        weeks = [w.strftime("%b %d") for w, _ in sorted_weeks]
        totals = [t for _, t in sorted_weeks]

        plt.figure(figsize=(8, 4))
        plt.bar(weeks, totals, color="#4C9AFF")
        plt.title(f"Weekly Totals for {category_name}")
        plt.xlabel("Week Starting")
        plt.ylabel("Amount ($)")
        plt.grid(axis="y", linestyle="--", alpha=0.6)
        plt.tight_layout()
        plt.show()

        print(f"✅ Charted {len(weeks)} weeks for {category_name} ({start_date}–{end_date})")


plot_weekly_category_totals("Grocery", "2025-07-01", "2025-10-26")

