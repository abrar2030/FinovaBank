import os
import sys

# DON'T CHANGE THIS !!!
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from flask import Flask, send_from_directory
from flask_cors import CORS
from src.models.user import db
from src.routes.audit import audit_bp
from src.routes.compliance import compliance_bp
from src.routes.reporting import reporting_bp
from src.routes.security import security_bp

app = Flask(__name__, static_folder=os.path.join(os.path.dirname(__file__), "static"))
app.config["SECRET_KEY"] = "FinovaBank-Compliance-Service-Secret-Key-2024!@#$%^&*()"

# Enable CORS for all routes
CORS(app, origins="*", allow_headers=["Content-Type", "Authorization"])

# Register compliance service blueprints
app.register_blueprint(audit_bp, url_prefix="/api/compliance/audit")
app.register_blueprint(compliance_bp, url_prefix="/api/compliance/monitoring")
app.register_blueprint(security_bp, url_prefix="/api/compliance/security")
app.register_blueprint(reporting_bp, url_prefix="/api/compliance/reporting")

# Database configuration
app.config["SQLALCHEMY_DATABASE_URI"] = (
    f"sqlite:///{os.path.join(os.path.dirname(__file__), 'database', 'app.db')}"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db.init_app(app)
with app.app_context():
    db.create_all()


@app.route("/health")
def health_check():
    return {"status": "healthy", "service": "FinovaBank Compliance Service"}, 200


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def serve(path):
    static_folder_path = app.static_folder
    if static_folder_path is None:
        return "Static folder not configured", 404

    if path != "" and os.path.exists(os.path.join(static_folder_path, path)):
        return send_from_directory(static_folder_path, path)
    else:
        index_path = os.path.join(static_folder_path, "index.html")
        if os.path.exists(index_path):
            return send_from_directory(static_folder_path, "index.html")
        else:
            return "Compliance Service is running", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8013, debug=True)
