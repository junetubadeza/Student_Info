import os
import sqlite3

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


def init_database():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    db_path = os.path.join(base_dir, "database", "school.db")
    schema_path = os.path.join(base_dir, "database", "schema.sql")

    os.makedirs(os.path.dirname(db_path), exist_ok=True)

    run_schema = not os.path.exists(db_path)
    if not run_schema:
        conn = sqlite3.connect(db_path)
        try:
            count = conn.execute("SELECT COUNT(*) FROM users").fetchone()[0]
            run_schema = count == 0
        except sqlite3.OperationalError:
            run_schema = True
        finally:
            conn.close()

    if not run_schema:
        return

    with open(schema_path, "r", encoding="utf-8") as f:
        sql = f.read()

    conn = sqlite3.connect(db_path)
    conn.executescript(sql)
    conn.commit()
    conn.close()
