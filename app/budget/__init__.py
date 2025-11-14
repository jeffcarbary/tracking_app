from flask import Blueprint

budget_bp = Blueprint(
    "budget",
    __name__,
    template_folder="templates"  # relative to this __init__.py
)

# Import routes so they get registered
from . import routes

