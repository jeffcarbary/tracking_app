from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from .extensions import db
import logging
import time
from prometheus_client import Counter

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint"]
)

migrate = Migrate()

def create_app():
    app = Flask(__name__)
    @app.before_request
    def before_request():
        request.start_time = time.time()
    
    @app.after_request
    def after_request(response):
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path
        ).inc()
        return response
    app.config.from_object("app.config.Config")
    app.secret_key = "a-very-secret-key" 

    app.config['DEBUG'] = True
    app.config['TEMPLATES_AUTO_RELOAD'] = True
    app.logger.setLevel(logging.DEBUG)
    logging.getLogger('werkzeug').setLevel(logging.DEBUG)

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    

    # Import models so Alembic sees them
    from .budget import models as budget_models
    from .nutrition import models as nutrition_models

    # Register blueprints
    from .budget import budget_bp
    app.register_blueprint(budget_bp)

    from .nutrition.routes import nutrition_bp
    app.register_blueprint(nutrition_bp)

    from .metrics.routes import metrics_bp
    app.register_blueprint(metrics_bp)

    return app

