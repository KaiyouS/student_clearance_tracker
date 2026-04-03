-- ============================================================
-- MIGRATION: Add schools and programs tables
-- ============================================================

-- 1. Schools
CREATE TABLE schools (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT
);

-- 2. Programs
CREATE TABLE programs (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  school_id INT REFERENCES schools(id) ON DELETE RESTRICT
);

-- 3. Update students — replace course text with program_id FK
ALTER TABLE students
  DROP COLUMN IF EXISTS course CASCADE,
  ADD COLUMN program_id INT REFERENCES programs(id) ON DELETE SET NULL;

-- ============================================================
-- SEED: Schools
-- ============================================================
INSERT INTO schools (id, name, description) VALUES
(1, 'School of Engineering', 'Offers programs in civil, electrical, mechanical, and other engineering disciplines.'),
(2, 'School of Arts and Sciences', 'Offers programs in natural sciences, social sciences, humanities, and communication.'),
(3, 'School of Business Administration', 'Offers programs in accountancy, business administration, and economics.'),
(4, 'School of Nursing', 'Offers the Bachelor of Science in Nursing program with clinical training.'),
(5, 'School of Education', 'Offers teacher education programs for secondary and elementary levels.'),
(6, 'School of Law', 'Offers the Juris Doctor program.'),
(7, 'School of Medicine', 'Offers the Doctor of Medicine program.'),
(8, 'Senior High School', 'Offers academic, technical-vocational, and arts and design tracks.');

SELECT setval('schools_id_seq', 8);

-- ============================================================
-- SEED: ADDU Programs
-- ============================================================
INSERT INTO programs (id, name, school_id) VALUES
-- School of Engineering (1)
(1,  'BS Civil Engineering',              1),
(2,  'BS Electrical Engineering',         1),
(3,  'BS Mechanical Engineering',         1),
(4,  'BS Computer Engineering',           1),
(5,  'BS Electronics Engineering',        1),
(6,  'BS Chemical Engineering',           1),
-- School of Arts and Sciences (2)
(7,  'BS Computer Science',               2),
(8,  'BS Information Technology',         2),
(9,  'BS Biology',                        2),
(10, 'BS Psychology',                     2),
(11, 'AB Communication',                  2),
(12, 'AB Political Science',              2),
(13, 'AB Philosophy',                     2),
(14, 'BS Mathematics',                    2),
-- School of Business Administration (3)
(15, 'BS Accountancy',                    3),
(16, 'BS Business Administration',        3),
(17, 'BS Economics',                      3),
(18, 'BS Management Accounting',          3),
-- School of Nursing (4)
(19, 'BS Nursing',                        4),
-- School of Education (5)
(20, 'Bachelor of Secondary Education',   5),
(21, 'Bachelor of Elementary Education',  5),
(22, 'Bachelor of Physical Education',    5);

SELECT setval('programs_id_seq', 22);

-- ============================================================
-- Update existing seeded students to use program_id
-- (maps from old course string → new program_id)
-- ============================================================
UPDATE students SET program_id = 7  WHERE student_no IN ('2021-00001','2021-00009','2021-00017'); -- BS Computer Science
UPDATE students SET program_id = 19 WHERE student_no IN ('2021-00002','2021-00010','2021-00018'); -- BS Nursing
UPDATE students SET program_id = 15 WHERE student_no IN ('2021-00003','2021-00011','2021-00020'); -- BS Accountancy
UPDATE students SET program_id = 11 WHERE student_no IN ('2021-00004','2021-00019');              -- AB Communication
UPDATE students SET program_id = 1  WHERE student_no IN ('2021-00005','2021-00013');              -- BS Civil Engineering
UPDATE students SET program_id = 8  WHERE student_no IN ('2021-00006','2021-00014');              -- BS Information Technology
UPDATE students SET program_id = 16 WHERE student_no IN ('2021-00007','2021-00015');              -- BS Business Administration
UPDATE students SET program_id = 10 WHERE student_no = '2021-00008';                             -- BS Psychology
UPDATE students SET program_id = 12 WHERE student_no = '2021-00012';                             -- AB Political Science
UPDATE students SET program_id = 9  WHERE student_no = '2021-00016';                             -- BS Biology

-- ============================================================
-- RLS
-- ============================================================
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;

-- super_admin: full CRUD
CREATE POLICY "admin manages schools"
  ON schools FOR ALL
  USING (EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'super_admin'
  ));

CREATE POLICY "admin manages programs"
  ON programs FOR ALL
  USING (EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'super_admin'
  ));

-- everyone else: read only
CREATE POLICY "anyone can view schools"
  ON schools FOR SELECT USING (TRUE);

CREATE POLICY "anyone can view programs"
  ON programs FOR SELECT USING (TRUE);