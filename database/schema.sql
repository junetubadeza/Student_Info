PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS professors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    employee_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    department VARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    student_number VARCHAR(20) UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    middle_name VARCHAR(80),
    last_name VARCHAR(80) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    course VARCHAR(100) NOT NULL,
    year_level VARCHAR(20) NOT NULL,
    section VARCHAR(10) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    status_reason TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS subjects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject_code VARCHAR(20) NOT NULL UNIQUE,
    subject_name VARCHAR(120) NOT NULL,
    units INTEGER NOT NULL DEFAULT 3
);

CREATE TABLE IF NOT EXISTS schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    year_level VARCHAR(20) NOT NULL,
    section VARCHAR(10) NOT NULL,
    room VARCHAR(50) NOT NULL,
    day VARCHAR(20) NOT NULL,
    start_time VARCHAR(10) NOT NULL,
    end_time VARCHAR(10) NOT NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (professor_id) REFERENCES professors(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS grades (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    subject_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    prelim FLOAT,
    midterm FLOAT,
    finals FLOAT,
    final_grade FLOAT,
    remarks VARCHAR(20),
    finalized BOOLEAN DEFAULT 0,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (professor_id) REFERENCES professors(id) ON DELETE CASCADE,
    UNIQUE (student_id, subject_id)
);

CREATE TABLE IF NOT EXISTS disciplinary_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    reason VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (professor_id) REFERENCES professors(id) ON DELETE CASCADE
);

INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (1, 'admin', 'scrypt:32768:8:1$vbxJXonNkVMu4fR7$4dd4e8080185ca894f696892cae945fd57767a1b0dcd9a66635072512e2f682d92616d6db579942e5c9e84234362b7965249bfff98d172896e0d935995934237', 'admin@school.edu', 'admin');
INSERT OR IGNORE INTO admins (id, user_id) VALUES (1, 1);
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (2, 'prof.santos', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'santos@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (1, 2, 'EMP001', 'Maria', 'Santos', 'Computer Science');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (3, 'prof.reyes', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'reyes@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (2, 3, 'EMP002', 'Juan', 'Reyes', 'Computer Science');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (4, 'prof.cruz', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'cruz@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (3, 4, 'EMP003', 'Ana', 'Cruz', 'Information Technology');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (5, 'prof.garcia', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'garcia@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (4, 5, 'EMP004', 'Pedro', 'Garcia', 'Computer Science');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (6, 'prof.lim', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'lim@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (5, 6, 'EMP005', 'Grace', 'Lim', 'Information Technology');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (7, 'prof.tan', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'tan@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (6, 7, 'EMP006', 'Robert', 'Tan', 'Computer Science');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (8, 'prof.ong', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'ong@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (7, 8, 'EMP007', 'Linda', 'Ong', 'Mathematics');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (9, 'prof.rivera', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'rivera@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (8, 9, 'EMP008', 'Carlos', 'Rivera', 'Computer Science');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (10, 'prof.mendoza', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'mendoza@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (9, 10, 'EMP009', 'Elena', 'Mendoza', 'Information Technology');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (11, 'prof.torres', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'torres@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (10, 11, 'EMP010', 'Miguel', 'Torres', 'Computer Science');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (12, 'prof.ramos', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'ramos@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (11, 12, 'EMP011', 'Sofia', 'Ramos', 'Information Technology');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (13, 'prof.bautista', 'scrypt:32768:8:1$FQRs5Y9m6mo4xK8e$af044aa61522d6e1c6c15e6a9c7b25e9dd4aa6431e49a88a4fac06f6533303f93bc75565b240992445173f0b4a56f9f957bca89fe1f8a32928c21d09c8e96426', 'bautista@school.edu', 'professor');
INSERT OR IGNORE INTO professors (id, user_id, employee_number, first_name, last_name, department) VALUES (12, 13, 'EMP012', 'Antonio', 'Bautista', 'Computer Science');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (14, 'student001', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student001@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (1, 14, '2024-0001', 'John', 'A', 'Doe', 'Male', 'BSIT', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (15, 'student002', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student002@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (2, 15, '2024-0002', 'Jane', 'B', 'Smith', 'Female', 'BSCS', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (16, 'student003', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student003@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (3, 16, '2024-0003', 'Mark', 'C', 'Johnson', 'Male', 'BSIT', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (17, 'student004', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student004@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (4, 17, '2024-0004', 'Lisa', 'D', 'Brown', 'Female', 'BSCS', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (18, 'student005', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student005@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (5, 18, '2024-0005', 'David', 'E', 'Wilson', 'Male', 'BSIT', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (19, 'student006', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student006@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (6, 19, '2024-0006', 'Emily', 'F', 'Davis', 'Female', 'BSCS', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (20, 'student007', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student007@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (7, 20, '2024-0007', 'Chris', 'G', 'Miller', 'Male', 'BSIT', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (21, 'student008', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student008@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (8, 21, '2024-0008', 'Sarah', 'H', 'Taylor', 'Female', 'BSCS', '1st Year', '1A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (22, 'student009', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student009@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (9, 22, '2024-0009', 'James', NULL, 'Anderson', 'Male', 'BSIT', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (23, 'student010', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student010@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (10, 23, '2024-0010', 'Amy', NULL, 'Thomas', 'Female', 'BSCS', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (24, 'student011', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student011@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (11, 24, '2024-0011', 'Michael', NULL, 'Jackson', 'Male', 'BSIT', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (25, 'student012', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student012@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (12, 25, '2024-0012', 'Jessica', 'A', 'White', 'Female', 'BSCS', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (26, 'student013', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student013@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (13, 26, '2024-0013', 'Daniel', 'B', 'Harris', 'Male', 'BSIT', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (27, 'student014', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student014@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (14, 27, '2024-0014', 'Ashley', 'C', 'Martin', 'Female', 'BSCS', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (28, 'student015', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student015@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (15, 28, '2024-0015', 'Matthew', 'D', 'Thompson', 'Male', 'BSIT', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (29, 'student016', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student016@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (16, 29, '2024-0016', 'Nicole', 'E', 'Garcia', 'Female', 'BSCS', '1st Year', '1B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (30, 'student017', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student017@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (17, 30, '2024-0017', 'Andrew', 'F', 'Martinez', 'Male', 'BSIT', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (31, 'student018', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student018@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (18, 31, '2024-0018', 'Stephanie', 'G', 'Robinson', 'Female', 'BSCS', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (32, 'student019', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student019@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (19, 32, '2024-0019', 'Joshua', 'H', 'Clark', 'Male', 'BSIT', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (33, 'student020', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student020@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (20, 33, '2024-0020', 'Melissa', NULL, 'Rodriguez', 'Female', 'BSCS', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (34, 'student021', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student021@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (21, 34, '2024-0021', 'Ryan', NULL, 'Lewis', 'Male', 'BSIT', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (35, 'student022', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student022@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (22, 35, '2024-0022', 'Michelle', NULL, 'Lee', 'Female', 'BSCS', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (36, 'student023', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student023@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (23, 36, '2024-0023', 'Kevin', 'A', 'Walker', 'Male', 'BSIT', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (37, 'student024', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student024@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (24, 37, '2024-0024', 'Amanda', 'B', 'Hall', 'Female', 'BSCS', '2nd Year', '2A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (38, 'student025', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student025@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (25, 38, '2024-0025', 'Brian', 'C', 'Allen', 'Male', 'BSIT', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (39, 'student026', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student026@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (26, 39, '2024-0026', 'Rachel', 'D', 'Young', 'Female', 'BSCS', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (40, 'student027', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student027@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (27, 40, '2024-0027', 'Jason', 'E', 'King', 'Male', 'BSIT', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (41, 'student028', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student028@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (28, 41, '2024-0028', 'Lauren', 'F', 'Wright', 'Female', 'BSCS', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (42, 'student029', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student029@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (29, 42, '2024-0029', 'Justin', 'G', 'Scott', 'Male', 'BSIT', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (43, 'student030', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student030@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (30, 43, '2024-0030', 'Kimberly', 'H', 'Torres', 'Female', 'BSCS', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (44, 'student031', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student031@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (31, 44, '2024-0031', 'Brandon', NULL, 'Nguyen', 'Male', 'BSIT', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (45, 'student032', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student032@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (32, 45, '2024-0032', 'Rebecca', NULL, 'Hill', 'Female', 'BSCS', '2nd Year', '2B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (46, 'student033', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student033@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (33, 46, '2024-0033', 'Tyler', NULL, 'Flores', 'Male', 'BSIT', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (47, 'student034', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student034@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (34, 47, '2024-0034', 'Samantha', 'A', 'Green', 'Female', 'BSCS', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (48, 'student035', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student035@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (35, 48, '2024-0035', 'Eric', 'B', 'Adams', 'Male', 'BSIT', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (49, 'student036', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student036@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (36, 49, '2024-0036', 'Katherine', 'C', 'Nelson', 'Female', 'BSCS', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (50, 'student037', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student037@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (37, 50, '2024-0037', 'Jacob', 'D', 'Baker', 'Male', 'BSIT', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (51, 'student038', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student038@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (38, 51, '2024-0038', 'Christine', 'E', 'Rivera', 'Female', 'BSCS', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (52, 'student039', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student039@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (39, 52, '2024-0039', 'Nathan', 'F', 'Campbell', 'Male', 'BSIT', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (53, 'student040', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student040@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (40, 53, '2024-0040', 'Angela', 'G', 'Mitchell', 'Female', 'BSCS', '3rd Year', '3A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (54, 'student041', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student041@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (41, 54, '2024-0041', 'Aaron', 'H', 'Carter', 'Male', 'BSIT', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (55, 'student042', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student042@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (42, 55, '2024-0042', 'Brittany', NULL, 'Roberts', 'Female', 'BSCS', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (56, 'student043', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student043@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (43, 56, '2024-0043', 'Adam', NULL, 'Gomez', 'Male', 'BSIT', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (57, 'student044', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student044@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (44, 57, '2024-0044', 'Megan', NULL, 'Phillips', 'Female', 'BSCS', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (58, 'student045', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student045@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (45, 58, '2024-0045', 'Patrick', 'A', 'Evans', 'Male', 'BSIT', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (59, 'student046', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student046@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (46, 59, '2024-0046', 'Hannah', 'B', 'Turner', 'Female', 'BSCS', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (60, 'student047', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student047@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (47, 60, '2024-0047', 'Sean', 'C', 'Diaz', 'Male', 'BSIT', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (61, 'student048', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student048@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (48, 61, '2024-0048', 'Olivia', 'D', 'Parker', 'Female', 'BSCS', '3rd Year', '3B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (62, 'student049', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student049@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (49, 62, '2024-0049', 'Timothy', 'E', 'Cruz', 'Male', 'BSIT', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (63, 'student050', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student050@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (50, 63, '2024-0050', 'Elizabeth', 'F', 'Edwards', 'Female', 'BSCS', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (64, 'student051', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student051@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (51, 64, '2024-0051', 'Kenneth', 'G', 'Collins', 'Male', 'BSIT', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (65, 'student052', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student052@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (52, 65, '2024-0052', 'Victoria', 'H', 'Reyes', 'Female', 'BSCS', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (66, 'student053', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student053@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (53, 66, '2024-0053', 'Steven', NULL, 'Stewart', 'Male', 'BSIT', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (67, 'student054', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student054@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (54, 67, '2024-0054', 'Grace', NULL, 'Morris', 'Female', 'BSCS', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (68, 'student055', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student055@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (55, 68, '2024-0055', 'Paul', NULL, 'Morales', 'Male', 'BSIT', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (69, 'student056', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student056@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (56, 69, '2024-0056', 'Chloe', 'A', 'Murphy', 'Female', 'BSCS', '4th Year', '4A', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (70, 'student057', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student057@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (57, 70, '2024-0057', 'Gregory', 'B', 'Cook', 'Male', 'BSIT', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (71, 'student058', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student058@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (58, 71, '2024-0058', 'Natalie', 'C', 'Rogers', 'Female', 'BSCS', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (72, 'student059', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student059@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (59, 72, '2024-0059', 'Frank', 'D', 'Gutierrez', 'Male', 'BSIT', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (73, 'student060', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student060@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (60, 73, '2024-0060', 'Sophia', 'E', 'Ortiz', 'Female', 'BSCS', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (74, 'student061', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student061@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (61, 74, '2024-0061', 'Raymond', 'F', 'Morgan', 'Male', 'BSIT', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (75, 'student062', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student062@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (62, 75, '2024-0062', 'Isabella', 'G', 'Cooper', 'Female', 'BSCS', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (76, 'student063', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student063@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (63, 76, '2024-0063', 'Dennis', 'H', 'Peterson', 'Male', 'BSIT', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO users (id, username, password_hash, email, role) VALUES (77, 'student064', 'scrypt:32768:8:1$hk1AS5Q1PAs8MoHV$7319828614ba240e412d9619d8107bde2961123186d9a24dc6a22ba3aefc4e9a42c0c54ddbb6c852feab842f1f6c8593812636eca5705d399c4c9c15fb9a2b60', 'student064@school.edu', 'student');
INSERT OR IGNORE INTO students (id, user_id, student_number, first_name, middle_name, last_name, gender, course, year_level, section, status) VALUES (64, 77, '2024-0064', 'Emma', NULL, 'Bailey', 'Female', 'BSCS', '4th Year', '4B', 'active');
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (1, 'Y1-CS01', 'Programming 1', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (2, 'Y1-CS02', 'Introduction to Computing', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (3, 'Y1-MT01', 'Discrete Mathematics', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (4, 'Y1-GE01', 'Mathematics in the Modern World', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (5, 'Y1-GE02', 'Understanding the Self', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (6, 'Y1-GE03', 'Readings in Philippine History', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (7, 'Y1-EN01', 'English Communication', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (8, 'Y1-PE01', 'Physical Education 1', 2);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (9, 'Y1-NS01', 'National Service Training Program', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (10, 'Y1-CS03', 'Digital Logic Design', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (11, 'Y2-CS01', 'Programming 2', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (12, 'Y2-CS02', 'Database Systems', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (13, 'Y2-CS03', 'Data Structures', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (14, 'Y2-CS04', 'Object-Oriented Programming', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (15, 'Y2-CS05', 'Web Development Fundamentals', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (16, 'Y2-CS06', 'Computer Organization', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (17, 'Y2-CS07', 'Database Schema Design', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (18, 'Y2-MT01', 'Statistics and Probability', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (19, 'Y2-EN01', 'Technical Writing', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (20, 'Y2-PE01', 'Physical Education 2', 2);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (21, 'Y3-CS01', 'Advanced Web Development', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (22, 'Y3-CS02', 'Networking', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (23, 'Y3-CS03', 'Software Engineering', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (24, 'Y3-CS04', 'Operating Systems', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (25, 'Y3-CS05', 'Information Assurance', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (26, 'Y3-CS06', 'Mobile Application Development', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (27, 'Y3-CS07', 'Data Analytics', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (28, 'Y3-CS08', 'Systems Analysis and Design', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (29, 'Y3-PE01', 'Physical Education 3', 2);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (30, 'Y3-CS09', 'IT Project Management', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (31, 'Y4-CS01', 'Capstone Project 1', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (32, 'Y4-CS02', 'Capstone Project 2', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (33, 'Y4-CS03', 'Cloud Computing', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (34, 'Y4-CS04', 'Artificial Intelligence', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (35, 'Y4-CS05', 'Machine Learning', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (36, 'Y4-CS06', 'Ethics in IT', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (37, 'Y4-CS07', 'E-Commerce Systems', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (38, 'Y4-CS08', 'IT Entrepreneurship', 3);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (39, 'Y4-CS09', 'Internship / Practicum', 6);
INSERT OR IGNORE INTO subjects (id, subject_code, subject_name, units) VALUES (40, 'Y4-CS10', 'Thesis Writing', 3);
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (1, 1, 1, '1st Year', '1A', 'Room 101', 'Monday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (2, 2, 2, '1st Year', '1A', 'Room 102', 'Monday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (3, 3, 3, '1st Year', '1A', 'Room 103', 'Tuesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (4, 4, 4, '1st Year', '1A', 'Lab 201', 'Tuesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (5, 5, 5, '1st Year', '1A', 'Lab 202', 'Wednesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (6, 6, 6, '1st Year', '1A', 'Room 301', 'Wednesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (7, 7, 7, '1st Year', '1A', 'Lab 302', 'Thursday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (8, 8, 8, '1st Year', '1A', 'Room 401', 'Thursday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (9, 9, 9, '1st Year', '1A', 'Room 101', 'Friday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (10, 10, 10, '1st Year', '1A', 'Room 102', 'Friday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (11, 1, 11, '1st Year', '1B', 'Room 103', 'Monday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (12, 2, 12, '1st Year', '1B', 'Lab 201', 'Monday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (13, 3, 1, '1st Year', '1B', 'Lab 202', 'Tuesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (14, 4, 2, '1st Year', '1B', 'Room 301', 'Tuesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (15, 5, 3, '1st Year', '1B', 'Lab 302', 'Wednesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (16, 6, 4, '1st Year', '1B', 'Room 401', 'Wednesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (17, 7, 5, '1st Year', '1B', 'Room 101', 'Thursday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (18, 8, 6, '1st Year', '1B', 'Room 102', 'Thursday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (19, 9, 7, '1st Year', '1B', 'Room 103', 'Friday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (20, 10, 8, '1st Year', '1B', 'Lab 201', 'Friday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (21, 11, 9, '2nd Year', '2A', 'Lab 202', 'Monday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (22, 12, 10, '2nd Year', '2A', 'Room 301', 'Monday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (23, 13, 11, '2nd Year', '2A', 'Lab 302', 'Tuesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (24, 14, 12, '2nd Year', '2A', 'Room 401', 'Tuesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (25, 15, 1, '2nd Year', '2A', 'Room 101', 'Wednesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (26, 16, 2, '2nd Year', '2A', 'Room 102', 'Wednesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (27, 17, 3, '2nd Year', '2A', 'Room 103', 'Thursday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (28, 18, 4, '2nd Year', '2A', 'Lab 201', 'Thursday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (29, 19, 5, '2nd Year', '2A', 'Lab 202', 'Friday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (30, 20, 6, '2nd Year', '2A', 'Room 301', 'Friday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (31, 11, 7, '2nd Year', '2B', 'Lab 302', 'Monday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (32, 12, 8, '2nd Year', '2B', 'Room 401', 'Monday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (33, 13, 9, '2nd Year', '2B', 'Room 101', 'Tuesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (34, 14, 10, '2nd Year', '2B', 'Room 102', 'Tuesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (35, 15, 11, '2nd Year', '2B', 'Room 103', 'Wednesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (36, 16, 12, '2nd Year', '2B', 'Lab 201', 'Wednesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (37, 17, 1, '2nd Year', '2B', 'Lab 202', 'Thursday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (38, 18, 2, '2nd Year', '2B', 'Room 301', 'Thursday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (39, 19, 3, '2nd Year', '2B', 'Lab 302', 'Friday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (40, 20, 4, '2nd Year', '2B', 'Room 401', 'Friday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (41, 21, 5, '3rd Year', '3A', 'Room 101', 'Monday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (42, 22, 6, '3rd Year', '3A', 'Room 102', 'Monday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (43, 23, 7, '3rd Year', '3A', 'Room 103', 'Tuesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (44, 24, 8, '3rd Year', '3A', 'Lab 201', 'Tuesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (45, 25, 9, '3rd Year', '3A', 'Lab 202', 'Wednesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (46, 26, 10, '3rd Year', '3A', 'Room 301', 'Wednesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (47, 27, 11, '3rd Year', '3A', 'Lab 302', 'Thursday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (48, 28, 12, '3rd Year', '3A', 'Room 401', 'Thursday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (49, 29, 1, '3rd Year', '3A', 'Room 101', 'Friday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (50, 30, 2, '3rd Year', '3A', 'Room 102', 'Friday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (51, 21, 3, '3rd Year', '3B', 'Room 103', 'Monday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (52, 22, 4, '3rd Year', '3B', 'Lab 201', 'Monday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (53, 23, 5, '3rd Year', '3B', 'Lab 202', 'Tuesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (54, 24, 6, '3rd Year', '3B', 'Room 301', 'Tuesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (55, 25, 7, '3rd Year', '3B', 'Lab 302', 'Wednesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (56, 26, 8, '3rd Year', '3B', 'Room 401', 'Wednesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (57, 27, 9, '3rd Year', '3B', 'Room 101', 'Thursday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (58, 28, 10, '3rd Year', '3B', 'Room 102', 'Thursday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (59, 29, 11, '3rd Year', '3B', 'Room 103', 'Friday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (60, 30, 12, '3rd Year', '3B', 'Lab 201', 'Friday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (61, 31, 1, '4th Year', '4A', 'Lab 202', 'Monday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (62, 32, 2, '4th Year', '4A', 'Room 301', 'Monday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (63, 33, 3, '4th Year', '4A', 'Lab 302', 'Tuesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (64, 34, 4, '4th Year', '4A', 'Room 401', 'Tuesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (65, 35, 5, '4th Year', '4A', 'Room 101', 'Wednesday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (66, 36, 6, '4th Year', '4A', 'Room 102', 'Wednesday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (67, 37, 7, '4th Year', '4A', 'Room 103', 'Thursday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (68, 38, 8, '4th Year', '4A', 'Lab 201', 'Thursday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (69, 39, 9, '4th Year', '4A', 'Lab 202', 'Friday', '08:00', '10:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (70, 40, 10, '4th Year', '4A', 'Room 301', 'Friday', '10:00', '12:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (71, 31, 11, '4th Year', '4B', 'Lab 302', 'Monday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (72, 32, 12, '4th Year', '4B', 'Room 401', 'Monday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (73, 33, 1, '4th Year', '4B', 'Room 101', 'Tuesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (74, 34, 2, '4th Year', '4B', 'Room 102', 'Tuesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (75, 35, 3, '4th Year', '4B', 'Room 103', 'Wednesday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (76, 36, 4, '4th Year', '4B', 'Lab 201', 'Wednesday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (77, 37, 5, '4th Year', '4B', 'Lab 202', 'Thursday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (78, 38, 6, '4th Year', '4B', 'Room 301', 'Thursday', '15:00', '17:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (79, 39, 7, '4th Year', '4B', 'Lab 302', 'Friday', '13:00', '15:00');
INSERT OR IGNORE INTO schedules (id, subject_id, professor_id, year_level, section, room, day, start_time, end_time) VALUES (80, 40, 8, '4th Year', '4B', 'Room 401', 'Friday', '15:00', '17:00');
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (1, 1, 1, 2, 90, 73, 70, 77.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (2, 1, 2, 3, 78, 77, 77, 77.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (3, 1, 3, 4, 93, 73, 91, 85.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (4, 1, 4, 5, 87, 72, 88, 82.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (5, 1, 5, 6, 71, 70, 72, 71.0, 'Failed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (6, 2, 1, 2, 77, 86, 89, 84.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (7, 2, 2, 3, 87, 76, 92, 85.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (8, 2, 3, 4, 92, 87, 83, 87.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (9, 2, 4, 5, 84, 88, 78, 83.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (10, 2, 5, 6, 94, 95, 75, 88.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (11, 3, 1, 2, 83, 80, 78, 80.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (12, 3, 2, 3, 76, 94, 80, 83.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (13, 3, 3, 4, 72, 82, 73, 75.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (14, 3, 4, 5, 81, 89, 78, 82.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (15, 3, 5, 6, 93, 84, 87, 88.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (16, 4, 1, 2, 82, 72, 87, 80.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (17, 4, 2, 3, 90, 89, 81, 86.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (18, 4, 3, 4, 76, 92, 72, 80.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (19, 4, 4, 5, 91, 77, 94, 87.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (20, 4, 5, 6, 72, 77, 73, 74.0, 'Failed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (21, 5, 1, 2, 78, 84, 90, 84.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (22, 5, 2, 3, 75, 81, 81, 79.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (23, 5, 3, 4, 91, 78, 92, 87.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (24, 5, 4, 5, 90, 72, 89, 83.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (25, 5, 5, 6, 75, 87, 93, 85.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (26, 6, 1, 2, 75, 84, 82, 80.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (27, 6, 2, 3, 90, 92, 87, 89.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (28, 6, 3, 4, 91, 80, 94, 88.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (29, 6, 4, 5, 77, 71, 95, 81.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (30, 6, 5, 6, 82, 78, 72, 77.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (31, 7, 1, 2, 88, 92, 80, 86.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (32, 7, 2, 3, 90, 85, 82, 85.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (33, 7, 3, 4, 84, 74, 78, 78.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (34, 7, 4, 5, 77, 93, 87, 85.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (35, 7, 5, 6, 78, 93, 88, 86.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (36, 8, 1, 2, 88, 82, 81, 83.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (37, 8, 2, 3, 74, 86, 85, 81.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (38, 8, 3, 4, 94, 71, 73, 79.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (39, 8, 4, 5, 90, 75, 95, 86.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (40, 8, 5, 6, 83, 89, 72, 81.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (41, 9, 1, 2, 82, 89, 84, 85.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (42, 9, 2, 3, 78, 87, 70, 78.33, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (43, 9, 3, 4, 93, 73, 91, 85.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (44, 9, 4, 5, 94, 78, 94, 88.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (45, 9, 5, 6, 80, 73, 79, 77.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (46, 10, 1, 2, 75, 84, 70, 76.33, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (47, 10, 2, 3, 93, 78, 86, 85.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (48, 10, 3, 4, 86, 73, 90, 83.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (49, 10, 4, 5, 90, 86, 89, 88.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (50, 10, 5, 6, 74, 81, 94, 83.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (51, 11, 1, 2, 87, 94, 86, 89.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (52, 11, 2, 3, 89, 80, 85, 84.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (53, 11, 3, 4, 73, 81, 95, 83.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (54, 11, 4, 5, 77, 71, 77, 75.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (55, 11, 5, 6, 72, 72, 93, 79.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (56, 12, 1, 2, 72, 94, 87, 84.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (57, 12, 2, 3, 74, 91, 85, 83.33, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (58, 12, 3, 4, 75, 78, 86, 79.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (59, 12, 4, 5, 83, 76, 87, 82.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (60, 12, 5, 6, 92, 76, 92, 86.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (61, 13, 1, 2, 82, 91, 90, 87.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (62, 13, 2, 3, 84, 86, 84, 84.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (63, 13, 3, 4, 77, 77, 72, 75.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (64, 13, 4, 5, 70, 88, 87, 81.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (65, 13, 5, 6, 88, 77, 70, 78.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (66, 14, 1, 2, 92, 90, 71, 84.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (67, 14, 2, 3, 72, 71, 80, 74.33, 'Failed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (68, 14, 3, 4, 86, 77, 78, 80.33, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (69, 14, 4, 5, 85, 76, 87, 82.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (70, 14, 5, 6, 93, 88, 88, 89.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (71, 15, 1, 2, 77, 95, 85, 85.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (72, 15, 2, 3, 76, 73, 73, 74.0, 'Failed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (73, 15, 3, 4, 83, 81, 83, 82.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (74, 15, 4, 5, 84, 93, 71, 82.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (75, 15, 5, 6, 90, 90, 73, 84.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (76, 16, 1, 2, 82, 93, 80, 85.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (77, 16, 2, 3, 77, 76, 76, 76.33, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (78, 16, 3, 4, 84, 74, 83, 80.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (79, 16, 4, 5, 78, 84, 77, 79.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (80, 16, 5, 6, 84, 95, 87, 88.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (81, 17, 11, 12, 71, 90, 87, 82.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (82, 17, 12, 1, 72, 94, 77, 81.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (83, 17, 13, 2, 83, 85, 85, 84.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (84, 17, 14, 3, 82, 71, 75, 76.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (85, 17, 15, 4, 70, 82, 78, 76.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (86, 18, 11, 12, 79, 83, 92, 84.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (87, 18, 12, 1, 95, 87, 91, 91.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (88, 18, 13, 2, 85, 74, 76, 78.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (89, 18, 14, 3, 76, 71, 88, 78.33, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (90, 18, 15, 4, 87, 71, 93, 83.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (91, 19, 11, 12, 71, 71, 88, 76.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (92, 19, 12, 1, 86, 86, 75, 82.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (93, 19, 13, 2, 86, 72, 75, 77.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (94, 19, 14, 3, 89, 72, 91, 84.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (95, 19, 15, 4, 82, 73, 88, 81.0, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (96, 20, 11, 12, 88, 89, 71, 82.67, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (97, 20, 12, 1, 72, 83, 91, 82.0, 'Passed', 0);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (98, 20, 13, 2, 88, 86, 80, 84.67, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (99, 20, 14, 3, 76, 91, 92, 86.33, 'Passed', 1);
INSERT OR IGNORE INTO grades (id, student_id, subject_id, professor_id, prelim, midterm, finals, final_grade, remarks, finalized) VALUES (100, 20, 15, 4, 77, 78, 82, 79.0, 'Passed', 1);
