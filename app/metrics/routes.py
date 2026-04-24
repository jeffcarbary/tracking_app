from prometheus_client import generate_latest
from flask import Response, Blueprint


metrics_bp = Blueprint(
    "metrics",
    __name__,
    url_prefix="/metrics",
    static_folder="static",
    template_folder="templates"
)


@metrics_bp.route("/")
def metrics():
    return Response(generate_latest(), mimetype="text/plain")
