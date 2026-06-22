"""
Authentication helpers: login manager setup and role-based access decorators.
"""

from functools import wraps
from flask import redirect, url_for, flash, abort
from flask_login import LoginManager, current_user

from backend.models import User

# Login manager instance (initialized in app.py)
login_manager = LoginManager()
login_manager.login_view = "auth.login"
login_manager.login_message = "Please log in to access this page."
login_manager.login_message_category = "warning"


@login_manager.user_loader
def load_user(user_id):
    """Load a user by ID for Flask-Login session management."""
    return User.query.get(int(user_id))


def role_required(*roles):
    """
    Decorator that restricts a route to specific user roles.
    Usage: @role_required('admin') or @role_required('admin', 'professor')
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                return redirect(url_for("auth.login"))
            if current_user.role not in roles:
                flash("You do not have permission to access that page.", "danger")
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator


def get_dashboard_url(role):
    """Return the dashboard URL for a given user role."""
    routes = {
        "admin": "admin.dashboard",
        "professor": "professor.dashboard",
        "student": "student.dashboard",
    }
    return url_for(routes.get(role, "auth.login"))
