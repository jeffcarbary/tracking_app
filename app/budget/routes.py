from flask import request, jsonify, render_template, abort
from sqlalchemy import func, and_, extract
from datetime import date, datetime, timedelta
import calendar
import time
import base64
import traceback
import random
import colorsys

from app.extensions import db
from app.budget.models import Transaction, Category
from .services import generate_unique_color
from app.utils.report_period import ReportPeriod
from app.utils.report_queries import ReportQueries
from app.utils.budget_utils import get_week_budget, get_month_budget
from app.utils.charts import plot_current_week_chart, plot_current_month_chart
from . import budget_bp

# -------------------------
# Page Routes
# -------------------------

@budget_bp.route("/")
def index():
    return render_template("add_transaction.html")

@budget_bp.route("/transactions")
def view_transactions():
    today = date.today()
    month = today.month
    year = today.year

    transactions = Transaction.query.filter(
        extract('month', Transaction.date) == month,
        extract('year', Transaction.date) == year
    ).order_by(Transaction.date.desc()).all()

    return render_template("transactions.html", transactions=transactions, month=month, year=year)

@budget_bp.route("/category_trends")
def category_trends_page():
    return render_template("category_trends.html")

@budget_bp.route("/report")
def report_page():
    return render_template("report.html", timestamp=int(time.time()))

# -------------------------
# Chart APIs
# -------------------------

@budget_bp.route("/api/charts/week")
def api_week_chart():
    today = date.today()
    period = ReportPeriod(today)
    week_start, week_end = period.week_range()
    queries = ReportQueries(db)
    daily_totals = queries.get_daily_totals(week_start, week_end)
    num_days = (week_end - week_start).days + 1
    week_budget = get_week_budget(num_days)
    img_base64 = plot_current_week_chart(daily_totals, week_start, num_days, today, week_budget)

    return (
        base64.b64decode(img_base64),
        200,
        {"Content-Type": "image/png",
         "Cache-Control": "no-store, no-cache, must-revalidate, max-age=0",
         "Pragma": "no-cache"}
    )

@budget_bp.route("/api/charts/month")
def api_month_chart():
    today = date.today()
    period = ReportPeriod(today)
    month_start, month_end = period.month_range()
    queries = ReportQueries(db)
    daily_totals = queries.get_daily_totals(month_start, month_end)
    days_in_month = (month_end - month_start).days + 1
    month_budget = get_month_budget(today)
    img_base64 = plot_current_month_chart(daily_totals, today, days_in_month, month_budget)

    return (
        base64.b64decode(img_base64),
        200,
        {"Content-Type": "image/png",
         "Cache-Control": "no-store, no-cache, must-revalidate, max-age=0",
         "Pragma": "no-cache"}
    )

@budget_bp.route("/api/charts/category_trend/<category>")
def api_category_trend(category):
    today = date.today()
    start_date = today - timedelta(days=90)
    queries = ReportQueries(db)
    weekly_data = queries.get_weekly_totals_for_category(category, start_date, today)

    return jsonify({
        "category": category,
        "labels": [str(week_start) for week_start in weekly_data.keys()],
        "totals": list(weekly_data.values()),
        "start_date": str(start_date),
        "end_date": str(today),
    })

# -------------------------
# Category APIs
# -------------------------

@budget_bp.route("/categories", methods=["POST"])
def create_category():
    data = request.get_json()
    if not data or "name" not in data or "color" not in data:
        return abort(400, description="Missing name or color")

    existing = Category.query.filter(func.lower(Category.name) == data["name"].lower()).first()
    if existing:
        return jsonify({"message": "Category already exists"}), 200

    category = Category(name=data["name"], color=data["color"])
    db.session.add(category)
    db.session.commit()

    return jsonify({"id": category.id, "name": category.name, "color": category.color}), 201

@budget_bp.route("/categories/<string:name>", methods=["GET"])
def get_category(name):
    category = Category.query.filter(func.lower(Category.name) == name.lower()).first()
    if not category:
        return abort(404, description="Category not found")
    return jsonify({"id": category.id, "name": category.name, "color": category.color})

# -------------------------
# Transaction APIs
# -------------------------

@budget_bp.route("/transactions", methods=["POST"])
def add_transaction():
    try:
        data = request.get_json()
        description = (data.get("description") or "").strip()
        amount = data.get("amount")
        date_value = data.get("date")
        category_name = (data.get("category") or "").strip() if data.get("category") else None

        if not description or amount is None:
            return jsonify({"error": "Description and amount are required"}), 400
        description = description.title()
        today = date.today()

        # --- Date parsing ---
        if not date_value:
            date_obj = today
        else:
            date_str = str(date_value)
            if date_str.isdigit():
                day = int(date_str)
                last_day_of_month = calendar.monthrange(today.year, today.month)[1]
                day = min(max(1, day), last_day_of_month)
                date_obj = date(today.year, today.month, day)
            else:
                date_obj = datetime.strptime(date_str, "%Y-%m-%d").date()

        # --- Category handling ---
        category_obj = None
        if category_name:
            category_name = category_name.capitalize()
            category_obj = Category.query.filter_by(name=category_name).first()
            if not category_obj:
                color = generate_unique_color({c.color for c in Category.query.all()}, 0)
                category_obj = Category(name=category_name, color=color)
                db.session.add(category_obj)
                db.session.commit()
        else:
            prev_txn = Transaction.query.filter(Transaction.description == description)\
                                        .order_by(Transaction.date.desc()).first()
            if prev_txn:
                category_obj = prev_txn.category

        if not category_obj:
            category_name = "Misc"
            category_obj = Category.query.filter_by(name=category_name).first()
            if not category_obj:
                color = generate_unique_color({c.color for c in Category.query.all()}, 0)
                category_obj = Category(name=category_name, color=color)
                db.session.add(category_obj)
                db.session.commit()

        # --- Check duplicate ---
        existing_txn = Transaction.query.filter(
            and_(Transaction.description == description,
                 Transaction.amount == amount,
                 Transaction.date == date_obj,
                 Transaction.category_id == category_obj.id)
        ).first()
        if existing_txn:
            return jsonify({"message": "Duplicate transaction exists", "id": existing_txn.id}), 201

        transaction = Transaction(description=description, amount=amount, date=date_obj, category=category_obj)
        db.session.add(transaction)
        db.session.commit()

        return jsonify({"message": "Transaction created", "transaction_id": transaction.id, "category": category_obj.name})
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@budget_bp.route("/transactions/<int:trans_id>", methods=["PUT"])
def update_transaction(trans_id):
    transaction = Transaction.query.get(trans_id)
    if not transaction:
        abort(404, description="Transaction not found")
    data = request.json
    transaction.description = data.get("description", transaction.description)
    transaction.amount = data.get("amount", transaction.amount)
    transaction.category = data.get("category", transaction.category)
    transaction.date = data.get("date", transaction.date)
    db.session.commit()
    return jsonify({
        "id": transaction.id,
        "description": transaction.description,
        "amount": float(transaction.amount),
        "category": transaction.category,
        "date": str(transaction.date)
    })

@budget_bp.route("/transactions/<int:trans_id>", methods=["DELETE"])
def delete_transaction(trans_id):
    transaction = Transaction.query.get(trans_id)
    if not transaction:
        abort(404, description="Transaction not found")
    db.session.delete(transaction)
    db.session.commit()
    return jsonify({"result": True})

@budget_bp.route("/api/transactions", methods=["GET"])
def get_transactions():
    try:
        start_date_str = request.args.get("start_date")
        end_date_str = request.args.get("end_date")
        category_name = request.args.get("category")
        description_substr = request.args.get("description")

        start_date = datetime.strptime(start_date_str, "%Y-%m-%d").date() if start_date_str else None
        end_date = datetime.strptime(end_date_str, "%Y-%m-%d").date() if end_date_str else None

        query = Transaction.query
        if start_date:
            query = query.filter(Transaction.date >= start_date)
        if end_date:
            query = query.filter(Transaction.date <= end_date)
        if category_name:
            query = query.join(Category).filter(Category.name.ilike(f"%{category_name}%"))
        if description_substr:
            query = query.filter(Transaction.description.ilike(f"%{description_substr}%"))

        transactions = query.all()
        transactions_list = [{
            "id": t.id,
            "description": t.description,
            "amount": float(t.amount),
            "date": t.date.isoformat(),
            "category": {"id": t.category.id, "name": t.category.name, "color": t.category.color}
        } for t in transactions]

        total_query = db.session.query(func.sum(Transaction.amount))
        if start_date:
            total_query = total_query.filter(Transaction.date >= start_date)
        if end_date:
            total_query = total_query.filter(Transaction.date <= end_date)
        total_amount = total_query.scalar() or 0

        return jsonify({"transactions": transactions_list, "total_amount": float(total_amount)})
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": "Internal server error"}), 500

# -------------------------
# Summary
# -------------------------

@budget_bp.route("/summary", methods=["GET"])
def summary():
    transactions = Transaction.query.all()
    total_income = sum(float(t.amount) for t in transactions if t.amount > 0)
    total_expense = sum(float(t.amount) for t in transactions if t.amount < 0)
    return jsonify({"total_income": total_income, "total_expense": total_expense, "balance": total_income + total_expense})

# -------------------------
# Reports
# -------------------------

@budget_bp.route("/reports/month")
def month_report():
    today = date.today()
    month_str = request.args.get("month")
    today_str = request.args.get("today")

    if month_str:
        try:
            year, month = map(int, month_str.split("-"))
            today = date(year, month, 1)
        except ValueError:
            return jsonify({"error": "Invalid month format. Use YYYY-MM."}), 400
    elif today_str:
        try:
            today = datetime.strptime(today_str, "%Y-%m-%d").date()
        except ValueError:
            return jsonify({"error": "Invalid date format. Use YYYY-MM-DD."}), 400

    period = ReportPeriod(today)
    month_start, month_end = period.month_range()
    queries = ReportQueries(db)
    daily_totals = queries.get_daily_totals(month_start, month_end)

    today_total = daily_totals.get(today.isoformat(), 0)
    effective_totals = dict(daily_totals)
    if today_total == 0:
        effective_totals.pop(today.isoformat(), None)

    month_total = sum(effective_totals.values())
    days_in_month = (today.replace(day=1) + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    days_in_month = days_in_month.day
    days_so_far = len([d for d in effective_totals.keys() if date.fromisoformat(d) <= today])
    days_so_far = max(days_so_far, 1)
    month_budget = get_month_budget(today)
    month_projected = (month_total / days_so_far) * days_in_month
    month_pct = round((month_projected / month_budget) * 100, 1)
    month_diff = month_projected - month_budget
    week_avg = (month_projected / days_in_month) * 7

    return jsonify({
        "month": month_start.strftime("%B %Y"),
        "start_date": str(month_start),
        "end_date": str(month_end),
        "month_total": round(month_total, 2),
        "daily_totals": daily_totals,
        "days_in_month": days_in_month,
        "month_budget": month_budget,
        "month_projected": month_projected,
        "month_pct": month_pct,
        "month_diff": month_diff,
        "week_avg": week_avg,
        "days_so_far": days_so_far
    })

@budget_bp.route("/reports/week")
def get_week_report():
    today = date.today()
    period = ReportPeriod(today)
    week_start, week_end = period.week_range()
    queries = ReportQueries(db)
    daily_totals = queries.get_daily_totals(week_start, week_end)
    num_week_days = (week_end - week_start).days + 1

    today_total = daily_totals.get(today.isoformat(), 0)
    effective_totals = dict(daily_totals)
    if today_total == 0:
        effective_totals.pop(today.isoformat(), None)

    week_total = sum(effective_totals.values())
    days_so_far = len([d for d in effective_totals.keys() if date.fromisoformat(d) <= today])
    days_so_far = max(days_so_far, 1)
    week_budget = get_week_budget(num_week_days)
    week_projected = (week_total / days_so_far) * num_week_days
    week_pct = round((week_projected / week_budget) * 100, 1)
    week_diff = week_projected - week_budget

    return jsonify({
        "week_start": str(week_start),
        "week_end": str(week_end),
        "today": str(today),
        "num_week_days": num_week_days,
        "week_total": round(week_total, 2),
        "week_budget": round(week_budget, 2),
        "week_projected": round(week_projected, 2),
        "week_pct": week_pct,
        "week_diff": round(week_diff, 2),
        "daily_totals": {str(k): float(v) for k, v in daily_totals.items()},
        "days_so_far": days_so_far
    })

