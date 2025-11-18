from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from .extensions import db
import logging

def create_app():
    app = Flask(__name__)
    app.config.from_object("app.config.Config")
    app.secret_key = "a-very-secret-key" 

    app.config['DEBUG'] = True
    app.config['TEMPLATES_AUTO_RELOAD'] = True
    app.logger.setLevel(logging.DEBUG)
    logging.getLogger('werkzeug').setLevel(logging.DEBUG)

    # Initialize extensions
    db.init_app(app)
    Migrate(app, db)

    # Import models so Alembic sees them
    from .budget import models as budget_models
    from .nutrition import models as nutrition_models

    # Register blueprints
    from .budget import budget_bp
    app.register_blueprint(budget_bp)

    from .nutrition.routes import nutrition_bp
    app.register_blueprint(nutrition_bp)

    return app

