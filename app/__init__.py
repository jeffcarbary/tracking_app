from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from .extensions import db

def create_app():
    app = Flask(__name__)
    app.config.from_object("app.config.Config")
    
    app.config['TEMPLATES_AUTO_RELOAD'] = True
    app.config['DEBUG'] = True  # optional but helps
    
    # Initialize extensions
    db.init_app(app)
    Migrate(app, db)
    
    # Import and register blueprints
    from .budget import budget_bp
    app.register_blueprint(budget_bp)
    
    return app

