#!/usr/local/bin/python3
from flask import Flask, jsonify, request, abort, render_template_string
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


#Bind db to app
db.init_app(app)  

#import DB models
from app.db_models import Transaction, Category

#Initialize Flask-Migrate
migrate = Migrate(app, db)


DEFAULT_SATURATION = 0.4
DEFAULT_BRIGHTNESS = 1.0

#FRONT END FORM
HTML_FORM = """
<!DOCTYPE html>
<html>
  <body style="font-family: sans-serif; max-width: 400px; margin: 2em auto;">
    <h3>Add Transaction</h3>
    <form id="txnForm">
      <label>Description:</label><br>
      <input id="desc" type="text" required><br><br>

      <label>Category (optional):</label><br>
      <input id="cat" type="text"><br><br>

      <label>Amount:</label><br>
      <input id="amt" type="number" step="0.01" required><br><br>

      <button type="submit">Add Transaction</button>
    </form>

    <p id="msg" style="color: green; font-weight: bold;"></p>

    <script>
      const form = document.getElementById('txnForm');
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const data = {
          description: document.getElementById('desc').value,
          category: document.getElementById('cat').value,
          amount: parseFloat(document.getElementById('amt').value)
        };
        try {
          const res = await fetch('/transactions', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
          });
          const resultText = await res.text();
          document.getElementById('msg').innerText =
            res.ok ? '✅ Transaction added!' : `❌ Error: ${resultText}`;
          form.reset();
        } catch (err) {
          document.getElementById('msg').innerText = '⚠️ Network error';
        }
      });
    </script>
  </body>
</html>
"""
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
@app.route("/", methods=["GET"])
def index():
    return render_template_string(HTML_FORM)

# CRUD endpoints

# GET all transactions
@app.route("/transactions", methods=["GET"])
def get_transactions():
    try:
        # Optional query parameters
        start_date_str = request.args.get("start_date")
        end_date_str = request.args.get("end_date")

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

# Optional: Summary endpoint
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

