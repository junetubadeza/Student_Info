# Student Information System (SIS)
CREATED BY:
jUNE tUBADEZA
JOHN LESTER BLANZA
CZEAHAMFORD HALL
MC KENNETH TACIS
JOSEPH ALLEN
A simple but modern **Student Information System** built with Flask for a college final project. It supports CRUD operations, role-based authentication, class schedules, grade management, and data export.

## Features

- **Single login page** with role-based redirect (Admin, Professor, Student)
- **Admin**: Manage students, professors, subjects, schedules; view grades; export PDF/Excel; handle disciplinary reports
- **Professor**: View assigned students/subjects/schedule; add/edit/finalize grades; submit disciplinary reports
- **Student**: View profile, grades, schedule; change password
- **Search & pagination** on list pages
- **Responsive design** with Bootstrap 5 (blue & white theme)

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Backend | Python, Flask |
| Frontend | HTML, CSS, Bootstrap 5, Vanilla JavaScript |
| Database | SQLite, SQLAlchemy ORM |
| Auth | Flask-Login, Werkzeug password hashing |
| Export | openpyxl (Excel), reportlab (PDF) |

## Project Structure

```
StudentInformationSystem/
├── app.py                  # Application entry point
├── requirements.txt        # Python dependencies
├── README.md
├── backend/
│   ├── __init__.py
│   ├── auth.py             # Login manager & role decorators
│   ├── database.py         # SQLAlchemy instance
│   ├── models.py           # Database models
│   └── routes.py           # All application routes
├── frontend/
│   ├── templates/          # Jinja2 HTML templates
│   └── static/
│       ├── css/style.css
│       └── js/main.js
└── database/
    ├── school.db           # SQLite database (auto-created)
    └── schema.sql          # Tables + default data (auto-installed on first run)
```

## Getting Started

### 1. Prerequisites

- Python 3.8 or higher
- pip

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run the Application

```bash
pip install -r requirements.txt
python app.py --init-db
python app.py
```

This matches the expected workflow: install requirements first, then initialize the database by running `database/schema.sql`.

To reset the database, delete `database/school.db` and run the init step again:


```bash
# Windows
del database\school.db
python app.py

# Mac/Linux
rm database/school.db
python app.py
```

**Default data includes:**
- **40 subjects** — 10 per year level (1st–4th Year)
- **80 schedules** — same 10 subjects for sections A & B, with A on morning slots and B on afternoon slots
- **64 students** — 8 students per section (1A, 1B, 2A, 2B, 3A, 3B, 4A, 4B)
- **12 professors**, sample grades, and an admin account

Open your browser at **http://127.0.0.1:5000**

## Default Login Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Professor | `prof.santos` | `prof123` |
| Student | `student001` | `student123` |

Additional students: `student002` through `student064` (password: `student123`)

## Database Schema

`database/schema.sql` contains all table definitions and default data. It is installed automatically on first run.
The app uses SQLAlchemy models in `backend/models.py` (same structure).

| Table | Description |
|-------|-------------|
| `users` | Login accounts (username, password_hash, email, role) |
| `students` | Student profiles |
| `professors` | Professor profiles |
| `admins` | Admin profiles |
| `subjects` | Academic subjects |
| `schedules` | Class schedules |
| `grades` | Student grades per subject |
| `disciplinary_reports` | Reports from professors to admin |

## Academic Structure

- **Year Levels**: 1st Year, 2nd Year, 3rd Year, 4th Year
- **Sections**: 1A, 1B, 2A, 2B, 3A, 3B, 4A, 4B
- **10 subjects per year level** (40 total) — sections A and B share the same subjects but have different schedules (morning vs afternoon)
- **Weekly timetable view** — schedules display as a Mon–Fri grid showing subject, professor, time, and room

## Role Permissions Summary

### Admin
- Full CRUD on students, professors, subjects, schedules
- View all grades (read-only, cannot edit professor-submitted grades)
- Export grades to PDF and Excel
- Suspend/remove students (requires reason)
- Review disciplinary reports

### Professor
- View assigned students, subjects, and teaching schedule
- Add and edit grades (before finalization)
- Finalize grades (becomes read-only after)
- Submit disciplinary reports (cannot remove students)

### Student
- View own profile, grades, and class schedule
- Change password
- Cannot edit grades

## License

This project is created for educational purposes as a college final project.
