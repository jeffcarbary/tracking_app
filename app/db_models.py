from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import CheckConstraint
from datetime import date
from app.extensions import db 



class Category(db.Model):
    __tablename__ = "categories"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    color = db.Column(db.String(7), nullable=False)

    __table_args__ = (
        CheckConstraint("length(name) > 0", name="check_category_name_not_empty"),
    )

class Transaction(db.Model):
    __tablename__ = "transactions"
    id = db.Column(db.Integer, primary_key=True)
    description = db.Column(db.String(200), nullable=False)
    amount = db.Column(db.Numeric(10,2), nullable=False)
    date = db.Column(db.Date, default=date.today)
    category_id = db.Column(db.Integer, db.ForeignKey("categories.id"))
    category = db.relationship("Category")

    def to_dict(self):
        return {
            "id": self.id,
            "description": self.description,
            "amount": float(self.amount),  # convert Decimal -> float
            "category": self.category,
            "category_id": self.category_id,
            "date": self.date.strftime("%Y-%m-%d")  # convert date -> string
        }
