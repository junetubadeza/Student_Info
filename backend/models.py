"""
SQLAlchemy models for the Student Information System.
Defines all database tables and their relationships.
"""

from datetime import datetime
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

from backend.database import db


class User(UserMixin, db.Model):
    """User account for login (admin, professor, or student)."""

    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    role = db.Column(db.String(20), nullable=False)  # admin, professor, student
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # One-to-one relationships with role-specific profiles
    student = db.relationship("Student", backref="user", uselist=False, cascade="all, delete-orphan")
    professor = db.relationship("Professor", backref="user", uselist=False, cascade="all, delete-orphan")
    admin = db.relationship("Admin", backref="user", uselist=False, cascade="all, delete-orphan")

    def set_password(self, password):
        """Hash and store the user's password."""
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        """Verify a password against the stored hash."""
        return check_password_hash(self.password_hash, password)


class Student(db.Model):
    """Student profile linked to a User account."""

    __tablename__ = "students"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), unique=True, nullable=False)
    student_number = db.Column(db.String(20), unique=True, nullable=True)
    first_name = db.Column(db.String(80), nullable=False)
    middle_name = db.Column(db.String(80), nullable=True)
    last_name = db.Column(db.String(80), nullable=False)
    gender = db.Column(db.String(10), nullable=False)
    course = db.Column(db.String(100), nullable=False)
    year_level = db.Column(db.String(20), nullable=False)  # 1st Year, 2nd Year, etc.
    section = db.Column(db.String(10), nullable=False)       # 1A, 1B, etc.
    status = db.Column(db.String(20), default="active")    # active, suspended, removed
    status_reason = db.Column(db.Text, nullable=True)

    grades = db.relationship("Grade", backref="student", lazy="dynamic")
    disciplinary_reports = db.relationship("DisciplinaryReport", backref="student", lazy="dynamic")

    @property
    def full_name(self):
        """Return the student's full name."""
        if self.middle_name:
            return f"{self.first_name} {self.middle_name} {self.last_name}"
        return f"{self.first_name} {self.last_name}"


class Professor(db.Model):
    """Professor profile linked to a User account."""

    __tablename__ = "professors"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), unique=True, nullable=False)
    employee_number = db.Column(db.String(20), unique=True, nullable=False)
    first_name = db.Column(db.String(80), nullable=False)
    last_name = db.Column(db.String(80), nullable=False)
    department = db.Column(db.String(100), nullable=False)

    schedules = db.relationship("Schedule", backref="professor", lazy="dynamic")
    grades = db.relationship("Grade", backref="professor", lazy="dynamic")
    disciplinary_reports = db.relationship("DisciplinaryReport", backref="professor", lazy="dynamic")

    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"


class Admin(db.Model):
    """Admin profile linked to a User account."""

    __tablename__ = "admins"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), unique=True, nullable=False)


class Subject(db.Model):
    """Academic subject / course offering."""

    __tablename__ = "subjects"

    id = db.Column(db.Integer, primary_key=True)
    subject_code = db.Column(db.String(20), unique=True, nullable=False)
    subject_name = db.Column(db.String(120), nullable=False)
    units = db.Column(db.Integer, nullable=False, default=3)

    schedules = db.relationship("Schedule", backref="subject", lazy="dynamic")
    grades = db.relationship("Grade", backref="subject", lazy="dynamic")


class Schedule(db.Model):
    """Class schedule linking a subject, professor, and section."""

    __tablename__ = "schedules"

    id = db.Column(db.Integer, primary_key=True)
    subject_id = db.Column(db.Integer, db.ForeignKey("subjects.id"), nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey("professors.id"), nullable=False)
    year_level = db.Column(db.String(20), nullable=False)
    section = db.Column(db.String(10), nullable=False)
    room = db.Column(db.String(50), nullable=False)
    day = db.Column(db.String(20), nullable=False)
    start_time = db.Column(db.String(10), nullable=False)
    end_time = db.Column(db.String(10), nullable=False)


class Grade(db.Model):
    """Student grade record for a subject."""

    __tablename__ = "grades"

    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey("students.id"), nullable=False)
    subject_id = db.Column(db.Integer, db.ForeignKey("subjects.id"), nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey("professors.id"), nullable=False)
    prelim = db.Column(db.Float, nullable=True)
    midterm = db.Column(db.Float, nullable=True)
    finals = db.Column(db.Float, nullable=True)
    final_grade = db.Column(db.Float, nullable=True)
    remarks = db.Column(db.String(20), nullable=True)  # Passed, Failed, etc.
    finalized = db.Column(db.Boolean, default=False)

    __table_args__ = (
        db.UniqueConstraint("student_id", "subject_id", name="unique_student_subject"),
    )


class DisciplinaryReport(db.Model):
    """Disciplinary report submitted by a professor about a student."""

    __tablename__ = "disciplinary_reports"

    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey("students.id"), nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey("professors.id"), nullable=False)
    reason = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default="pending")  # pending, reviewed, resolved
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
