"""
Main application entry point for the Student Information System.
"""

import os
from flask import Flask

from backend.database import db
from backend.auth import login_manager
from backend.routes import auth_bp, admin_bp, professor_bp, student_bp


def create_app(init_db=True):
    """Create and configure the Flask application."""
    app = Flask(
        __name__,
        template_folder="frontend/templates",
        static_folder="frontend/static",
    )

    # Configuration
    base_dir = os.path.abspath(os.path.dirname(__file__))
    db_path = os.path.join(base_dir, "database", "school.db")
    app.config["SECRET_KEY"] = "sis-secret-key-change-in-production"
    app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{db_path}"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # Initialize extensions
    db.init_app(app)
    login_manager.init_app(app)

    # Register blueprints
    app.register_blueprint(auth_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(professor_bp)
    app.register_blueprint(student_bp)

    # Initialize database schema and default data
    if init_db:
        with app.app_context():
            from backend.database import init_database
            init_database()

    return app



if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Student Information System (SIS)")
    parser.add_argument(
        "--init-db",
        action="store_true",
        help="Create/initialize the SQLite database by running database/schema.sql",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Run Flask in debug mode",
    )
    parser.add_argument("--port", type=int, default=5000, help="Port to run on")

    args = parser.parse_args()

    # Only run DB initialization when explicitly requested.
    app = create_app(init_db=args.init_db)
    app.run(debug=bool(args.debug), port=args.port)

