#!/usr/local/bin/python3
from flask import Flask, jsonify, request, abort, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from datetime import datetime, date, timedelta
import random
import colorsys
import calendar
from app.config import Config
from sqlalchemy import func, and_
import traceback
from app.extensions import db

app = Flask(__name__)
#import config
app.config.from_object(Config)
app.config['TEMPLATES_AUTO_RELOAD'] = True


#Bind db to app
db.init_app(app)  

#import DB models
from app.db_models import Transaction, Category

#Initialize Flask-Migrate
migrate = Migrate(app, db)


#POST A NEW CATEGORY
@app.route("/categories", methods=["POST"])
def create_category():
    data = request.get_json()
    if not data or "name" not in data or "color" not in data:
        return abort(400, description="Missing name or color")
    
    # Check if already exists
    existing = Category.query.filter(func.lower(Category.name) == data["name"].lower()).first()
    if existing:
        return jsonify({"message": "Category already exists"}), 200
    
    category = Category(name=data["name"], color=data["color"])
    db.session.add(category)
    db.session.commit()
    
    return jsonify({
        "id": category.id,
        "name": category.name,
        "color": category.color
    }), 201

#add transaction page
@app.route("/", methods=["GET"])
def index():
    return render_template("add_transaction.html")

#Report page
@app.route("/report")
def report_page():
    return render_template("report.html")

#Route for Report (current week/month)
#@app.route("/api/report")
#def report_data():
#    today = date.today()
#
#    # 🗓 Week starts on Friday
#    days_since_friday = (today.weekday() - 4) % 7
#    start_of_week = today - timedelta(days=days_since_friday)
#
#    # 🗓 Month starts on the 1st
#    start_of_month = today.replace(day=1)
#
#    weekly_total = (
#        Transaction.query.filter(Transaction.date >= start_of_week)
#        .with_entities(db.func.sum(Transaction.amount))
#        .scalar() or 0
#    )
#
#    monthly_total = (
#        Transaction.query.filter(Transaction.date >= start_of_month)
#        .with_entities(db.func.sum(Transaction.amount))
#        .scalar() or 0
#    )
#
#    return jsonify({
#        "week_start": str(start_of_week),
#        "month_start": str(start_of_month),
#        "weekly_total": round(weekly_total, 2),
#        "monthly_total": round(monthly_total, 2)
#    })

#Monthly Report
@app.route("/reports/monthly", methods=["GET"])
def monthly_report():
    today = date.today()
    month_start = today.replace(day=1)
    next_month = (month_start.replace(day=28) + timedelta(days=4)).replace(day=1)
    month_end = next_month - timedelta(days=1)

    # Daily totals for the current month
    results = (
        db.session.query(
            func.date(Transaction.date).label("day"),
            func.sum(Transaction.amount).label("total")
        )
        .filter(Transaction.date >= month_start, Transaction.date <= month_end)
        .group_by("day")
        .order_by("day")
        .all()
    )

    daily_totals = {str(r.day): float(r.total) for r in results}
    monthly_total = sum(daily_totals.values())

    return jsonify({
        "month": today.strftime("%B %Y"),
        "monthly_total": round(monthly_total, 2),
        "daily_totals": daily_totals
    })

# --- Weekly Report (Friday to Thursday) ---
@app.route("/reports/weekly", methods=["GET"])
def weekly_report():
    today = date.today()

    # Find most recent Friday as start of week
    offset = (today.weekday() - 4) % 7  # weekday(): Mon=0 .. Sun=6, so 4 = Friday
    week_start = today - timedelta(days=offset)
    week_end = week_start + timedelta(days=6)

    results = (
        db.session.query(
            func.date(Transaction.date).label("day"),
            func.sum(Transaction.amount).label("total")
        )
        .filter(Transaction.date >= week_start, Transaction.date <= week_end)
        .group_by("day")
        .order_by("day")
        .all()
    )

    daily_totals = {str(r.day): float(r.total) for r in results}
    weekly_total = sum(daily_totals.values())

    return jsonify({
        "week_range": f"{week_start} to {week_end}",
        "weekly_total": round(weekly_total, 2),
        "daily_totals": daily_totals
    })
# GET all transactions
@app.route("/transactions", methods=["GET"])
def get_transactions():
    try:
        # Optional query parameters
        start_date_str = request.args.get("start_date")
        end_date_str = request.args.get("end_date")
        category_name = request.args.get("category")  
        description_substr = request.args.get("description")  

        # Parse dates if provided
        start_date = None
        end_date = None
        try:
            if start_date_str:
                start_date = datetime.strptime(start_date_str, "%Y-%m-%d").date()
            if end_date_str:
                end_date = datetime.strptime(end_date_str, "%Y-%m-%d").date()
        except ValueError as e:
            return jsonify({"error": f"Invalid date format: {e}"}), 400

        # Build query for transactions
        query = Transaction.query
        if start_date:
            query = query.filter(Transaction.date >= start_date)
        if end_date:
            query = query.filter(Transaction.date <= end_date)
        if category_name:
        # Join with Category table and filter by name
            query = query.join(Category).filter(Category.name.ilike(f"%{category_name}%"))
        if description_substr:
            query = query.filter(Transaction.description.ilike(f"%{description_substr}%"))


        transactions = query.all()
        #transactions_list = [t.to_dict() for t in transactions]
        transactions_list = []

        for t in transactions:
            transactions_list.append({
                "id": t.id,
                "description": t.description,
                "amount": float(t.amount),
                "date": t.date.isoformat(),
                "category": {
                    "id": t.category.id,
                    "name": t.category.name,
                    "color": t.category.color
        }
    })

        # Calculate total amount in DB
        total_query = db.session.query(func.sum(Transaction.amount))
        if start_date:
            total_query = total_query.filter(Transaction.date >= start_date)
        if end_date:
            total_query = total_query.filter(Transaction.date <= end_date)

        total_amount = total_query.scalar() or 0  # default to 0 if no transactions

        return jsonify({
            "transactions": transactions_list,
            "total_amount": float(total_amount)
        })

    except Exception as e:
        app.logger.error(f"Error in /transactions: {e}")
        return jsonify({"error": "Internal server error"}), 500

@app.route("/categories/<string:name>", methods=["GET"])
def get_category(name):
    category = Category.query.filter(func.lower(Category.name) == name.lower()).first()
    if not category:
        return abort(404, description="Category not found")
    
    return jsonify({
        "id": category.id,
        "name": category.name,
        "color": category.color
    })

#HELPER FUNCTION 
def generate_unique_color(existing_colors, index):
    """
    Generates soft pastel colors, starting at a random hue so the first color
    isn't always red.
    """
    golden_ratio = 0.61803398875
    start_hue = random.random()  # random starting hue between 0 and 1
    hue = (start_hue + index * golden_ratio) % 1.0

    saturation = random.uniform(0.5, 0.8)
    lightness = random.uniform(0.6, 0.85)

    r, g, b = colorsys.hls_to_rgb(hue, lightness, saturation)
    color = f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"

    #Ensure uniqueness
    while color in existing_colors:
        hue = (hue + 0.05) % 1.0
        r, g, b = colorsys.hls_to_rgb(hue, lightness, saturation)
        color = f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"

    existing_colors.add(color)
    return color

# POST a new transaction
@app.route("/transactions", methods=["POST"])
def add_transaction():
    try:
        data = request.get_json()
        description = data.get("description")
        amount = data.get("amount")
        date_value = data.get("date")  # optional, e.g., "2025-10-25"
        category_name = data.get("category")  # can be None
        # ------------------------
        # Validate inputs
        # ------------------------
        if not description or amount is None:
            return jsonify({"error": "Description and amount are required"}), 400

        description = description.title()
        # ------------------------
        # Default date handling
        # ------------------------
        date_str = str(date_value) if date_value is not None else ""
        today = date.today()
        if not date_str:
            # No date provided → use today
            date_obj = today
        else:
            # Check if it's just a number (day of month)
            if date_str.isdigit():
                day = int(date_str)
            
                # get last day of current month
                last_day_of_month = calendar.monthrange(today.year, today.month)[1]
            
                # clamp day to valid range
                day = min(max(1, day), last_day_of_month)
            
                date_obj = date(today.year, today.month, day)
            else:
                date_obj = datetime.strptime(date_str, "%Y-%m-%d").date()
        # ------------------------
        # Lookup previous category if none provided
        # ------------------------
        category_obj = None
        if category_name:
            category_name = category_name.capitalize()
            category_obj = Category.query.filter_by(name=category_name).first()
            if not category_obj:
                # Category doesn't exist → create it
                color = generate_unique_color(
                {c.color for c in Category.query.all()},  # used colors
                0  # index can be 0 or some other logic
                )
                category_obj = Category(name=category_name, color=color)
                db.session.add(category_obj)
                db.session.commit()
        else:
            # Find last transaction with same description
            prev_txn = (
                Transaction.query
                .filter(Transaction.description == description)
                .order_by(Transaction.date.desc())
                .first()
            )
            if prev_txn:
                category_obj = prev_txn.category  # Category object from relationship
               

        # ------------------------
        # If still no category, default to "Misc"
        # ------------------------
        if not category_obj:
            category_name = "Misc"
            category_obj = Category.query.filter_by(name=category_name).first()
            if not category_obj:
                existing_colors = {c.color for c in Category.query.all()}
                new_color = generate_unique_color(existing_colors, len(existing_colors))
                category_obj = Category(name=category_name, color=new_color)
                db.session.add(category_obj)
                db.session.commit()

        # ------------------------
        # Check for exact duplicate
        # ------------------------
        existing_txn = Transaction.query.filter(
            and_(
                Transaction.description == description,
                Transaction.amount == amount,
                Transaction.date == date_obj,
                Transaction.category_id == category_obj.id
            )
        ).first()

        if existing_txn:
            print('here')
            return jsonify({"message": "Duplicate transaction exists", "id": existing_txn.id}), 201


        # ------------------------
        # Create Transaction
        # ------------------------
        transaction = Transaction(
            description=description,
            amount=amount,
            date=date_obj,
            category=category_obj
        )
        db.session.add(transaction)
        db.session.commit()

        return jsonify({
            "message": "Transaction created",
            "transaction_id": transaction.id,
            "category": category_obj.name
        })
    except Exception as e:
        print("ERROR in add_transaction:", e)
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

# PUT update a transaction
@app.route("/transactions/<int:trans_id>", methods=["PUT"])
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

# DELETE a transaction
@app.route("/transactions/<int:trans_id>", methods=["DELETE"])
def delete_transaction(trans_id):
    transaction = Transaction.query.get(trans_id)
    if not transaction:
        abort(404, description="Transaction not found")
    db.session.delete(transaction)
    db.session.commit()
    return jsonify({"result": True})

#Summary endpoint
@app.route("/summary", methods=["GET"])
def summary():
    transactions = Transaction.query.all()
    total_income = sum(float(t.amount) for t in transactions if t.amount > 0)
    total_expense = sum(float(t.amount) for t in transactions if t.amount < 0)
    return jsonify({
        "total_income": total_income,
        "total_expense": total_expense,
        "balance": total_income + total_expense
    })

if __name__ == "__main__":
    app.run(debug=True, use_reloader=False, host=Config.FLASK_HOST, port=Config.FLASK_PORT)

