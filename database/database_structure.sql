-- Student Result Analyzer — database_structure.sql (structure only, no data)

CREATE DATABASE IF NOT EXISTS result_analyzer;
USE result_analyzer;

-- ===================== Core tables =====================

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('student', 'teacher', 'admin') NOT NULL DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    roll_no VARCHAR(20) NOT NULL UNIQUE,
    class VARCHAR(20) NOT NULL,
    section VARCHAR(10),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    class VARCHAR(20) NOT NULL,
    max_marks INT NOT NULL DEFAULT 100
);

CREATE TABLE results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    exam_term VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    CHECK (marks_obtained >= 0)
);

CREATE INDEX idx_results_student ON results(student_id);
CREATE INDEX idx_results_subject ON results(subject_id);
CREATE INDEX idx_students_class ON students(class);

-- ===================== Gamification tables =====================

CREATE TABLE student_progress (
    student_id INT PRIMARY KEY,
    total_xp INT NOT NULL DEFAULT 0,
    current_streak INT NOT NULL DEFAULT 0,
    longest_streak INT NOT NULL DEFAULT 0,
    last_active_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT,
    study_plan_id INT DEFAULT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    task_date DATE NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    xp_value INT NOT NULL DEFAULT 10,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL
);

CREATE TABLE rewards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    xp_required INT DEFAULT NULL,
    streak_required INT DEFAULT NULL
);

CREATE TABLE student_rewards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    reward_id INT NOT NULL,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE
);

CREATE TABLE study_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    recurrence_type ENUM('once', 'weekly') NOT NULL DEFAULT 'once',
    recurrence_day ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') DEFAULT NULL,
    plan_date DATE DEFAULT NULL,
    xp_value INT NOT NULL DEFAULT 10,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

ALTER TABLE tasks
ADD FOREIGN KEY (study_plan_id) REFERENCES study_plans(id) ON DELETE SET NULL;