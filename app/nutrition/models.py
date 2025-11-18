# app/nutrition/models.py

from datetime import datetime, time
from app.extensions import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    calorie_goal = db.Column(db.Float, default=2000)  # daily calorie goal
    protein_goal = db.Column(db.Float, default=2000)  # daily calorie goal
    fiber_goal = db.Column(db.Float, default=2000)  # daily calorie goal
    day_start_time = db.Column(db.Time, default=time(0, 0))  # default 00:00
    day_end_time = db.Column(db.Time, default=time(23, 59))  # default 23:59

    entries = db.relationship("LogEntry", backref="user", lazy=True)

    def __repr__(self):
        return f"<User {self.username}>"

class FoodItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    base_amount = db.Column(db.Float, nullable=False, default=100)  # grams
    calories = db.Column(db.Float, nullable=False)
    protein = db.Column(db.Float, nullable=False)
    fiber = db.Column(db.Float, nullable=False)
    fat = db.Column(db.Float, default=0)
    sodium = db.Column(db.Float, default=0)

    def __repr__(self):
        return f"<FoodItem {self.name}>"

class LogEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    food_id = db.Column(db.Integer, db.ForeignKey("food_item.id"), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    unit = db.Column(db.String(10), default="g")
    calories = db.Column(db.Float)
    protein = db.Column(db.Float)
    fiber = db.Column(db.Float)
    fat = db.Column(db.Float)
    sodium = db.Column(db.Float)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    food = db.relationship("FoodItem", backref=db.backref("entries", lazy=True))

    def __repr__(self):
        return f"<LogEntry {self.food.name} {self.amount}{self.unit} by {self.user.username}>"

