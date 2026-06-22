"""
Application routes organized by role: auth, admin, professor, and student.
"""

import io
from datetime import datetime
from functools import wraps

from flask import (
    Blueprint, render_template, redirect, url_for, flash,
    request, jsonify, send_file, abort
)
from flask_login import login_user, logout_user, login_required, current_user
from openpyxl import Workbook
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from sqlalchemy import or_

from backend.database import db
from backend.auth import role_required, get_dashboard_url
from backend.schedule_utils import build_weekly_grid
from backend.models import (
    User, Student, Professor, Admin, Subject, Schedule, Grade, DisciplinaryReport
)

# ---------------------------------------------------------------------------
# Blueprints
# ---------------------------------------------------------------------------
auth_bp = Blueprint("auth", __name__)
admin_bp = Blueprint("admin", __name__, url_prefix="/admin")
professor_bp = Blueprint("professor", __name__, url_prefix="/professor")
student_bp = Blueprint("student", __name__, url_prefix="/student")

# Shared constants
YEAR_LEVELS = ["1st Year", "2nd Year", "3rd Year", "4th Year"]
SECTIONS = {
    "1st Year": ["1A", "1B"],
    "2nd Year": ["2A", "2B"],
    "3rd Year": ["3A", "3B"],
    "4th Year": ["4A", "4B"],
}
PER_PAGE = 10


def calculate_final_grade(prelim, midterm, finals):
    """Compute final grade as average of prelim, midterm, and finals."""
    scores = [s for s in [prelim, midterm, finals] if s is not None]
    if not scores:
        return None, None
    avg = round(sum(scores) / len(scores), 2)
    remarks = "Passed" if avg >= 75 else "Failed"
    return avg, remarks


# ---------------------------------------------------------------------------
# Auth Routes
# ---------------------------------------------------------------------------
@auth_bp.route("/")
def index():
    """Redirect to login or role dashboard."""
    if current_user.is_authenticated:
        return redirect(get_dashboard_url(current_user.role))
    return redirect(url_for("auth.login"))


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    """Single login page for all user roles."""
    if current_user.is_authenticated:
        return redirect(get_dashboard_url(current_user.role))

    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")

        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            # Block login for suspended/removed students
            if user.role == "student" and user.student:
                if user.student.status in ("suspended", "removed"):
                    flash(f"Account is {user.student.status}. Contact the administrator.", "danger")
                    return render_template("login.html")

            login_user(user)
            flash(f"Welcome back, {username}!", "success")
            return redirect(get_dashboard_url(user.role))

        flash("Invalid username or password.", "danger")

    return render_template("login.html")


@auth_bp.route("/logout")
@login_required
def logout():
    """Log out the current user."""
    logout_user()
    flash("You have been logged out.", "info")
    return redirect(url_for("auth.login"))


# ---------------------------------------------------------------------------
# Admin Routes
# ---------------------------------------------------------------------------
@admin_bp.route("/dashboard")
@login_required
@role_required("admin")
def dashboard():
    """Admin dashboard with summary statistics."""
    stats = {
        "students": Student.query.filter_by(status="active").count(),
        "professors": Professor.query.count(),
        "subjects": Subject.query.count(),
        "schedules": Schedule.query.count(),
        "grades": Grade.query.count(),
        "reports": DisciplinaryReport.query.filter_by(status="pending").count(),
    }
    return render_template("admin/dashboard.html", stats=stats)


# --- Student Management ---
@admin_bp.route("/students")
@login_required
@role_required("admin")
def students_list():
    """List students with search and pagination."""
    page = request.args.get("page", 1, type=int)
    search = request.args.get("search", "").strip()
    status_filter = request.args.get("status", "all")

    query = Student.query
    if status_filter != "all":
        query = query.filter_by(status=status_filter)
    if search:
        query = query.filter(or_(
            Student.first_name.ilike(f"%{search}%"),
            Student.last_name.ilike(f"%{search}%"),
            Student.student_number.ilike(f"%{search}%"),
            Student.course.ilike(f"%{search}%"),
        ))

    pagination = query.order_by(Student.last_name).paginate(page=page, per_page=PER_PAGE, error_out=False)
    return render_template(
        "admin/students.html",
        students=pagination.items,
        pagination=pagination,
        search=search,
        status_filter=status_filter,
        year_levels=YEAR_LEVELS,
        sections=SECTIONS,
    )


@admin_bp.route("/students/add", methods=["GET", "POST"])
@login_required
@role_required("admin")
def students_add():
    """Add a new student."""
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        email = request.form.get("email", "").strip()
        password = request.form.get("password", "")

        if User.query.filter_by(username=username).first():
            flash("Username already exists.", "danger")
            return render_template("admin/student_form.html", student=None,
                                   year_levels=YEAR_LEVELS, sections=SECTIONS)

        if User.query.filter_by(email=email).first():
            flash("Email already exists.", "danger")
            return render_template("admin/student_form.html", student=None,
                                   year_levels=YEAR_LEVELS, sections=SECTIONS)

        user = User(username=username, email=email, role="student")
        user.set_password(password)
        db.session.add(user)
        db.session.flush()

        year_level = request.form.get("year_level")
        student = Student(
            user_id=user.id,
            student_number=request.form.get("student_number") or None,
            first_name=request.form.get("first_name"),
            middle_name=request.form.get("middle_name") or None,
            last_name=request.form.get("last_name"),
            gender=request.form.get("gender"),
            course=request.form.get("course"),
            year_level=year_level,
            section=request.form.get("section"),
        )
        db.session.add(student)
        db.session.commit()
        flash("Student added successfully.", "success")
        return redirect(url_for("admin.students_list"))

    return render_template("admin/student_form.html", student=None,
                           year_levels=YEAR_LEVELS, sections=SECTIONS)


@admin_bp.route("/students/<int:student_id>")
@login_required
@role_required("admin")
def students_view(student_id):
    """View student profile."""
    student = Student.query.get_or_404(student_id)
    grades = Grade.query.filter_by(student_id=student_id).all()
    return render_template("admin/student_view.html", student=student, grades=grades)


@admin_bp.route("/students/<int:student_id>/edit", methods=["GET", "POST"])
@login_required
@role_required("admin")
def students_edit(student_id):
    """Edit student information."""
    student = Student.query.get_or_404(student_id)

    if request.method == "POST":
        student.student_number = request.form.get("student_number") or None
        student.first_name = request.form.get("first_name")
        student.middle_name = request.form.get("middle_name") or None
        student.last_name = request.form.get("last_name")
        student.gender = request.form.get("gender")
        student.course = request.form.get("course")
        student.year_level = request.form.get("year_level")
        student.section = request.form.get("section")

        if student.user:
            new_email = request.form.get("email", "").strip()
            if new_email and new_email != student.user.email:
                if User.query.filter_by(email=new_email).first():
                    flash("Email already in use.", "danger")
                    return render_template("admin/student_form.html", student=student,
                                           year_levels=YEAR_LEVELS, sections=SECTIONS)
                student.user.email = new_email

        db.session.commit()
        flash("Student updated successfully.", "success")
        return redirect(url_for("admin.students_list"))

    return render_template("admin/student_form.html", student=student,
                           year_levels=YEAR_LEVELS, sections=SECTIONS)


@admin_bp.route("/students/<int:student_id>/delete", methods=["POST"])
@login_required
@role_required("admin")
def students_delete(student_id):
    """Delete a student and their user account."""
    student = Student.query.get_or_404(student_id)
    user = student.user
    db.session.delete(student)
    if user:
        db.session.delete(user)
    db.session.commit()
    flash("Student deleted successfully.", "success")
    return redirect(url_for("admin.students_list"))


@admin_bp.route("/students/<int:student_id>/status", methods=["POST"])
@login_required
@role_required("admin")
def students_status(student_id):
    """Suspend or remove a student with a required reason."""
    student = Student.query.get_or_404(student_id)
    action = request.form.get("action")
    reason = request.form.get("reason", "").strip()

    if not reason:
        flash("A reason is required to suspend or remove a student.", "danger")
        return redirect(url_for("admin.students_view", student_id=student_id))

    if action == "suspend":
        student.status = "suspended"
        student.status_reason = reason
        flash("Student has been suspended.", "warning")
    elif action == "remove":
        student.status = "removed"
        student.status_reason = reason
        flash("Student has been removed.", "danger")
    elif action == "reactivate":
        student.status = "active"
        student.status_reason = None
        flash("Student has been reactivated.", "success")

    db.session.commit()
    return redirect(url_for("admin.students_view", student_id=student_id))


# --- Professor Management ---
@admin_bp.route("/professors")
@login_required
@role_required("admin")
def professors_list():
    """List professors with search and pagination."""
    page = request.args.get("page", 1, type=int)
    search = request.args.get("search", "").strip()

    query = Professor.query
    if search:
        query = query.filter(or_(
            Professor.first_name.ilike(f"%{search}%"),
            Professor.last_name.ilike(f"%{search}%"),
            Professor.employee_number.ilike(f"%{search}%"),
            Professor.department.ilike(f"%{search}%"),
        ))

    pagination = query.order_by(Professor.last_name).paginate(page=page, per_page=PER_PAGE, error_out=False)
    return render_template("admin/professors.html", professors=pagination.items,
                           pagination=pagination, search=search)


@admin_bp.route("/professors/add", methods=["GET", "POST"])
@login_required
@role_required("admin")
def professors_add():
    """Add a new professor."""
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        email = request.form.get("email", "").strip()
        password = request.form.get("password", "")

        if User.query.filter_by(username=username).first():
            flash("Username already exists.", "danger")
            return render_template("admin/professor_form.html", professor=None)

        user = User(username=username, email=email, role="professor")
        user.set_password(password)
        db.session.add(user)
        db.session.flush()

        professor = Professor(
            user_id=user.id,
            employee_number=request.form.get("employee_number"),
            first_name=request.form.get("first_name"),
            last_name=request.form.get("last_name"),
            department=request.form.get("department"),
        )
        db.session.add(professor)
        db.session.commit()
        flash("Professor added successfully.", "success")
        return redirect(url_for("admin.professors_list"))

    return render_template("admin/professor_form.html", professor=None)


@admin_bp.route("/professors/<int:professor_id>/edit", methods=["GET", "POST"])
@login_required
@role_required("admin")
def professors_edit(professor_id):
    """Edit professor information."""
    professor = Professor.query.get_or_404(professor_id)

    if request.method == "POST":
        professor.employee_number = request.form.get("employee_number")
        professor.first_name = request.form.get("first_name")
        professor.last_name = request.form.get("last_name")
        professor.department = request.form.get("department")

        if professor.user:
            new_email = request.form.get("email", "").strip()
            if new_email:
                professor.user.email = new_email

        db.session.commit()
        flash("Professor updated successfully.", "success")
        return redirect(url_for("admin.professors_list"))

    return render_template("admin/professor_form.html", professor=professor)


@admin_bp.route("/professors/<int:professor_id>/delete", methods=["POST"])
@login_required
@role_required("admin")
def professors_delete(professor_id):
    """Delete a professor and their user account."""
    professor = Professor.query.get_or_404(professor_id)
    user = professor.user
    db.session.delete(professor)
    if user:
        db.session.delete(user)
    db.session.commit()
    flash("Professor deleted successfully.", "success")
    return redirect(url_for("admin.professors_list"))


# --- Subject Management ---
@admin_bp.route("/subjects")
@login_required
@role_required("admin")
def subjects_list():
    """List all subjects."""
    page = request.args.get("page", 1, type=int)
    search = request.args.get("search", "").strip()

    query = Subject.query
    if search:
        query = query.filter(or_(
            Subject.subject_code.ilike(f"%{search}%"),
            Subject.subject_name.ilike(f"%{search}%"),
        ))

    pagination = query.order_by(Subject.subject_code).paginate(page=page, per_page=PER_PAGE, error_out=False)
    return render_template("admin/subjects.html", subjects=pagination.items,
                           pagination=pagination, search=search)


@admin_bp.route("/subjects/add", methods=["GET", "POST"])
@login_required
@role_required("admin")
def subjects_add():
    """Add a new subject."""
    if request.method == "POST":
        subject = Subject(
            subject_code=request.form.get("subject_code"),
            subject_name=request.form.get("subject_name"),
            units=int(request.form.get("units", 3)),
        )
        db.session.add(subject)
        db.session.commit()
        flash("Subject added successfully.", "success")
        return redirect(url_for("admin.subjects_list"))

    return render_template("admin/subject_form.html", subject=None)


@admin_bp.route("/subjects/<int:subject_id>/edit", methods=["GET", "POST"])
@login_required
@role_required("admin")
def subjects_edit(subject_id):
    """Edit a subject."""
    subject = Subject.query.get_or_404(subject_id)

    if request.method == "POST":
        subject.subject_code = request.form.get("subject_code")
        subject.subject_name = request.form.get("subject_name")
        subject.units = int(request.form.get("units", 3))
        db.session.commit()
        flash("Subject updated successfully.", "success")
        return redirect(url_for("admin.subjects_list"))

    return render_template("admin/subject_form.html", subject=subject)


@admin_bp.route("/subjects/<int:subject_id>/delete", methods=["POST"])
@login_required
@role_required("admin")
def subjects_delete(subject_id):
    """Delete a subject."""
    subject = Subject.query.get_or_404(subject_id)
    db.session.delete(subject)
    db.session.commit()
    flash("Subject deleted successfully.", "success")
    return redirect(url_for("admin.subjects_list"))


# --- Schedule Management ---
@admin_bp.route("/schedules")
@login_required
@role_required("admin")
def schedules_list():
    """Weekly schedule view with year/section filter."""
    year_level = request.args.get("year_level", "1st Year")
    section = request.args.get("section", "1A")

    if year_level not in YEAR_LEVELS:
        year_level = YEAR_LEVELS[0]
    if section not in SECTIONS.get(year_level, []):
        section = SECTIONS[year_level][0]

    schedules = Schedule.query.filter_by(
        year_level=year_level, section=section
    ).order_by(Schedule.day, Schedule.start_time).all()

    weekly_grid, schedule_days, time_slots = build_weekly_grid(schedules)

    return render_template(
        "admin/schedules.html",
        schedules=schedules,
        weekly_grid=weekly_grid,
        schedule_days=schedule_days,
        time_slots=time_slots,
        year_levels=YEAR_LEVELS,
        sections=SECTIONS,
        selected_year=year_level,
        selected_section=section,
    )


@admin_bp.route("/schedules/add", methods=["GET", "POST"])
@login_required
@role_required("admin")
def schedules_add():
    """Add a new class schedule."""
    subjects = Subject.query.order_by(Subject.subject_code).all()
    professors = Professor.query.order_by(Professor.last_name).all()

    if request.method == "POST":
        schedule = Schedule(
            subject_id=int(request.form.get("subject_id")),
            professor_id=int(request.form.get("professor_id")),
            year_level=request.form.get("year_level"),
            section=request.form.get("section"),
            room=request.form.get("room"),
            day=request.form.get("day"),
            start_time=request.form.get("start_time"),
            end_time=request.form.get("end_time"),
        )
        db.session.add(schedule)
        db.session.commit()
        flash("Schedule added successfully.", "success")
        return redirect(url_for("admin.schedules_list"))

    return render_template("admin/schedule_form.html", schedule=None,
                           subjects=subjects, professors=professors,
                           year_levels=YEAR_LEVELS, sections=SECTIONS)


@admin_bp.route("/schedules/<int:schedule_id>/edit", methods=["GET", "POST"])
@login_required
@role_required("admin")
def schedules_edit(schedule_id):
    """Edit a class schedule."""
    schedule = Schedule.query.get_or_404(schedule_id)
    subjects = Subject.query.order_by(Subject.subject_code).all()
    professors = Professor.query.order_by(Professor.last_name).all()

    if request.method == "POST":
        schedule.subject_id = int(request.form.get("subject_id"))
        schedule.professor_id = int(request.form.get("professor_id"))
        schedule.year_level = request.form.get("year_level")
        schedule.section = request.form.get("section")
        schedule.room = request.form.get("room")
        schedule.day = request.form.get("day")
        schedule.start_time = request.form.get("start_time")
        schedule.end_time = request.form.get("end_time")
        db.session.commit()
        flash("Schedule updated successfully.", "success")
        return redirect(url_for("admin.schedules_list"))

    return render_template("admin/schedule_form.html", schedule=schedule,
                           subjects=subjects, professors=professors,
                           year_levels=YEAR_LEVELS, sections=SECTIONS)


@admin_bp.route("/schedules/<int:schedule_id>/delete", methods=["POST"])
@login_required
@role_required("admin")
def schedules_delete(schedule_id):
    """Delete a class schedule."""
    schedule = Schedule.query.get_or_404(schedule_id)
    db.session.delete(schedule)
    db.session.commit()
    flash("Schedule deleted successfully.", "success")
    return redirect(url_for("admin.schedules_list"))


# --- Grade Viewing & Export (read-only for admin) ---
@admin_bp.route("/grades")
@login_required
@role_required("admin")
def grades_list():
    """View all grades (read-only)."""
    page = request.args.get("page", 1, type=int)
    search = request.args.get("search", "").strip()

    query = Grade.query.join(Student).join(Subject)
    if search:
        query = query.filter(or_(
            Student.first_name.ilike(f"%{search}%"),
            Student.last_name.ilike(f"%{search}%"),
            Subject.subject_name.ilike(f"%{search}%"),
        ))

    pagination = query.paginate(page=page, per_page=PER_PAGE, error_out=False)
    return render_template("admin/grades.html", grades=pagination.items,
                           pagination=pagination, search=search)


@admin_bp.route("/grades/export/excel")
@login_required
@role_required("admin")
def grades_export_excel():
    """Export all grades to Excel."""
    grades = Grade.query.join(Student).join(Subject).all()

    wb = Workbook()
    ws = wb.active
    ws.title = "Grades"
    headers = ["Student No.", "Student Name", "Subject", "Prelim", "Midterm",
               "Finals", "Final Grade", "Remarks", "Finalized"]
    ws.append(headers)

    for g in grades:
        ws.append([
            g.student.student_number or "N/A",
            g.student.full_name,
            g.subject.subject_name,
            g.prelim, g.midterm, g.finals,
            g.final_grade, g.remarks,
            "Yes" if g.finalized else "No",
        ])

    output = io.BytesIO()
    wb.save(output)
    output.seek(0)
    return send_file(
        output,
        mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        as_attachment=True,
        download_name=f"grades_{datetime.now().strftime('%Y%m%d')}.xlsx",
    )


@admin_bp.route("/grades/export/pdf")
@login_required
@role_required("admin")
def grades_export_pdf():
    """Export all grades to PDF."""
    grades = Grade.query.join(Student).join(Subject).all()

    output = io.BytesIO()
    doc = SimpleDocTemplate(output, pagesize=landscape(letter))
    elements = []
    styles = getSampleStyleSheet()

    elements.append(Paragraph("Student Grades Report", styles["Title"]))
    elements.append(Spacer(1, 12))

    data = [["Student", "Subject", "Prelim", "Midterm", "Finals",
             "Final Grade", "Remarks", "Finalized"]]
    for g in grades:
        data.append([
            g.student.full_name,
            g.subject.subject_name,
            str(g.prelim or "-"),
            str(g.midterm or "-"),
            str(g.finals or "-"),
            str(g.final_grade or "-"),
            g.remarks or "-",
            "Yes" if g.finalized else "No",
        ])

    table = Table(data, repeatRows=1)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#0d6efd")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f8f9fa")]),
    ]))
    elements.append(table)
    doc.build(elements)

    output.seek(0)
    return send_file(
        output,
        mimetype="application/pdf",
        as_attachment=True,
        download_name=f"grades_{datetime.now().strftime('%Y%m%d')}.pdf",
    )


# --- Disciplinary Reports ---
@admin_bp.route("/reports")
@login_required
@role_required("admin")
def reports_list():
    """View disciplinary reports."""
    page = request.args.get("page", 1, type=int)
    pagination = DisciplinaryReport.query.order_by(
        DisciplinaryReport.created_at.desc()
    ).paginate(page=page, per_page=PER_PAGE, error_out=False)
    return render_template("admin/reports.html", reports=pagination.items, pagination=pagination)


@admin_bp.route("/reports/<int:report_id>/status", methods=["POST"])
@login_required
@role_required("admin")
def reports_update_status(report_id):
    """Update disciplinary report status."""
    report = DisciplinaryReport.query.get_or_404(report_id)
    report.status = request.form.get("status", "reviewed")
    db.session.commit()
    flash("Report status updated.", "success")
    return redirect(url_for("admin.reports_list"))


# ---------------------------------------------------------------------------
# Professor Routes
# ---------------------------------------------------------------------------
@professor_bp.route("/dashboard")
@login_required
@role_required("professor")
def dashboard():
    """Professor dashboard."""
    professor = current_user.professor
    schedule_count = Schedule.query.filter_by(professor_id=professor.id).count()
    grade_count = Grade.query.filter_by(professor_id=professor.id).count()
    return render_template("professor/dashboard.html",
                           professor=professor,
                           schedule_count=schedule_count,
                           grade_count=grade_count)


@professor_bp.route("/students")
@login_required
@role_required("professor")
def students_list():
    """View students assigned to the professor's subjects."""
    professor = current_user.professor
    schedules = Schedule.query.filter_by(professor_id=professor.id).all()

    # Collect unique year_level + section combos from professor's schedules
    sections = set((s.year_level, s.section) for s in schedules)
    students = []
    for year_level, section in sections:
        section_students = Student.query.filter_by(
            year_level=year_level, section=section, status="active"
        ).all()
        students.extend(section_students)

    # Remove duplicates
    seen = set()
    unique_students = []
    for s in students:
        if s.id not in seen:
            seen.add(s.id)
            unique_students.append(s)

    return render_template("professor/students.html", students=unique_students)


@professor_bp.route("/subjects")
@login_required
@role_required("professor")
def subjects_list():
    """View subjects assigned to the professor."""
    professor = current_user.professor
    schedules = Schedule.query.filter_by(professor_id=professor.id).all()
    subject_ids = set(s.subject_id for s in schedules)
    subjects = Subject.query.filter(Subject.id.in_(subject_ids)).all() if subject_ids else []
    return render_template("professor/subjects.html", subjects=subjects)


@professor_bp.route("/schedule")
@login_required
@role_required("professor")
def schedule_view():
    """View teaching schedule as a weekly timetable."""
    professor = current_user.professor
    schedules = Schedule.query.filter_by(professor_id=professor.id).order_by(
        Schedule.day, Schedule.start_time
    ).all()
    weekly_grid, schedule_days, time_slots = build_weekly_grid(schedules)
    return render_template(
        "professor/schedule.html",
        schedules=schedules,
        weekly_grid=weekly_grid,
        schedule_days=schedule_days,
        time_slots=time_slots,
    )


@professor_bp.route("/grades")
@login_required
@role_required("professor")
def grades_list():
    """List grades for the professor's subjects."""
    professor = current_user.professor
    page = request.args.get("page", 1, type=int)
    subject_id = request.args.get("subject_id", type=int)

    query = Grade.query.filter_by(professor_id=professor.id)
    if subject_id:
        query = query.filter_by(subject_id=subject_id)

    pagination = query.paginate(page=page, per_page=PER_PAGE, error_out=False)
    subjects = Subject.query.join(Schedule).filter(
        Schedule.professor_id == professor.id
    ).distinct().all()

    return render_template("professor/grades.html", grades=pagination.items,
                           pagination=pagination, subjects=subjects,
                           selected_subject=subject_id)


@professor_bp.route("/grades/add", methods=["GET", "POST"])
@login_required
@role_required("professor")
def grades_add():
    """Add a grade for a student."""
    professor = current_user.professor

    # Get subjects this professor teaches
    subject_ids = [s.subject_id for s in Schedule.query.filter_by(professor_id=professor.id).all()]
    subjects = Subject.query.filter(Subject.id.in_(subject_ids)).all() if subject_ids else []

    if request.method == "POST":
        student_id = int(request.form.get("student_id"))
        subject_id = int(request.form.get("subject_id"))

        existing = Grade.query.filter_by(student_id=student_id, subject_id=subject_id).first()
        if existing:
            flash("Grade record already exists for this student and subject.", "danger")
            return redirect(url_for("professor.grades_edit", grade_id=existing.id))

        prelim = float(request.form.get("prelim")) if request.form.get("prelim") else None
        midterm = float(request.form.get("midterm")) if request.form.get("midterm") else None
        finals = float(request.form.get("finals")) if request.form.get("finals") else None
        final_grade, remarks = calculate_final_grade(prelim, midterm, finals)

        grade = Grade(
            student_id=student_id,
            subject_id=subject_id,
            professor_id=professor.id,
            prelim=prelim,
            midterm=midterm,
            finals=finals,
            final_grade=final_grade,
            remarks=remarks,
        )
        db.session.add(grade)
        db.session.commit()
        flash("Grade added successfully.", "success")
        return redirect(url_for("professor.grades_list"))

    # Get students from professor's sections
    schedules = Schedule.query.filter_by(professor_id=professor.id).all()
    sections = set((s.year_level, s.section) for s in schedules)
    students = []
    for year_level, section in sections:
        students.extend(Student.query.filter_by(
            year_level=year_level, section=section, status="active"
        ).all())

    return render_template("professor/grade_form.html", grade=None,
                           subjects=subjects, students=students)


@professor_bp.route("/grades/<int:grade_id>/edit", methods=["GET", "POST"])
@login_required
@role_required("professor")
def grades_edit(grade_id):
    """Edit a grade (only if not finalized)."""
    grade = Grade.query.get_or_404(grade_id)
    professor = current_user.professor

    if grade.professor_id != professor.id:
        abort(403)

    if grade.finalized:
        flash("This grade has been finalized and cannot be edited.", "warning")
        return redirect(url_for("professor.grades_list"))

    if request.method == "POST":
        grade.prelim = float(request.form.get("prelim")) if request.form.get("prelim") else None
        grade.midterm = float(request.form.get("midterm")) if request.form.get("midterm") else None
        grade.finals = float(request.form.get("finals")) if request.form.get("finals") else None
        grade.final_grade, grade.remarks = calculate_final_grade(
            grade.prelim, grade.midterm, grade.finals
        )
        db.session.commit()
        flash("Grade updated successfully.", "success")
        return redirect(url_for("professor.grades_list"))

    return render_template("professor/grade_form.html", grade=grade,
                           subjects=[grade.subject], students=[grade.student])


@professor_bp.route("/grades/<int:grade_id>/finalize", methods=["POST"])
@login_required
@role_required("professor")
def grades_finalize(grade_id):
    """Finalize a grade (makes it read-only)."""
    grade = Grade.query.get_or_404(grade_id)
    professor = current_user.professor

    if grade.professor_id != professor.id:
        abort(403)

    if grade.finalized:
        flash("Grade is already finalized.", "info")
    else:
        grade.finalized = True
        db.session.commit()
        flash("Grade finalized successfully. It is now read-only.", "success")

    return redirect(url_for("professor.grades_list"))


@professor_bp.route("/disciplinary", methods=["GET", "POST"])
@login_required
@role_required("professor")
def disciplinary_report():
    """Submit a disciplinary report about a student."""
    professor = current_user.professor

    if request.method == "POST":
        report = DisciplinaryReport(
            student_id=int(request.form.get("student_id")),
            professor_id=professor.id,
            reason=request.form.get("reason"),
            description=request.form.get("description"),
        )
        db.session.add(report)
        db.session.commit()
        flash("Disciplinary report submitted to admin.", "success")
        return redirect(url_for("professor.dashboard"))

    schedules = Schedule.query.filter_by(professor_id=professor.id).all()
    sections = set((s.year_level, s.section) for s in schedules)
    students = []
    for year_level, section in sections:
        students.extend(Student.query.filter_by(
            year_level=year_level, section=section, status="active"
        ).all())

    return render_template("professor/disciplinary.html", students=students)


# ---------------------------------------------------------------------------
# Student Routes
# ---------------------------------------------------------------------------
@student_bp.route("/dashboard")
@login_required
@role_required("student")
def dashboard():
    """Student dashboard."""
    student = current_user.student
    grade_count = Grade.query.filter_by(student_id=student.id).count()
    schedule_count = Schedule.query.filter_by(
        year_level=student.year_level, section=student.section
    ).count()
    return render_template("student/dashboard.html", student=student,
                           grade_count=grade_count, schedule_count=schedule_count)


@student_bp.route("/profile")
@login_required
@role_required("student")
def profile():
    """View student profile."""
    student = current_user.student
    return render_template("student/profile.html", student=student)


@student_bp.route("/grades")
@login_required
@role_required("student")
def grades_view():
    """View student grades (read-only)."""
    student = current_user.student
    grades = Grade.query.filter_by(student_id=student.id).all()
    return render_template("student/grades.html", grades=grades)


@student_bp.route("/schedule")
@login_required
@role_required("student")
def schedule_view():
    """View class schedule as a weekly timetable."""
    student = current_user.student
    schedules = Schedule.query.filter_by(
        year_level=student.year_level, section=student.section
    ).order_by(Schedule.day, Schedule.start_time).all()
    weekly_grid, schedule_days, time_slots = build_weekly_grid(schedules)
    return render_template(
        "student/schedule.html",
        schedules=schedules,
        weekly_grid=weekly_grid,
        schedule_days=schedule_days,
        time_slots=time_slots,
        student=student,
    )


@student_bp.route("/change-password", methods=["GET", "POST"])
@login_required
@role_required("student")
def change_password():
    """Allow student to change their password."""
    if request.method == "POST":
        current_pw = request.form.get("current_password", "")
        new_pw = request.form.get("new_password", "")
        confirm_pw = request.form.get("confirm_password", "")

        if not current_user.check_password(current_pw):
            flash("Current password is incorrect.", "danger")
            return render_template("student/change_password.html")

        if new_pw != confirm_pw:
            flash("New passwords do not match.", "danger")
            return render_template("student/change_password.html")

        if len(new_pw) < 6:
            flash("Password must be at least 6 characters.", "danger")
            return render_template("student/change_password.html")

        current_user.set_password(new_pw)
        db.session.commit()
        flash("Password changed successfully.", "success")
        return redirect(url_for("student.dashboard"))

    return render_template("student/change_password.html")


# API endpoint for dynamic section loading
@admin_bp.route("/api/sections/<year_level>")
@login_required
@role_required("admin")
def api_sections(year_level):
    """Return sections for a given year level (used by JavaScript)."""
    return jsonify(SECTIONS.get(year_level, []))
