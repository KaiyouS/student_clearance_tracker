-- ============================================================
-- MIGRATION: Add office_requirements table
-- ============================================================
CREATE TABLE office_requirements (
  id         SERIAL PRIMARY KEY,
  office_id  INT  REFERENCES offices(id)  ON DELETE CASCADE,
  program_id INT  REFERENCES programs(id) ON DELETE CASCADE,
  -- NULL program_id = applies to ALL students regardless of program
  UNIQUE (office_id, program_id)
);

ALTER TABLE office_requirements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin manages office_requirements"
  ON office_requirements FOR ALL
  USING (EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'super_admin'
  ));

CREATE POLICY "anyone can view office_requirements"
  ON office_requirements FOR SELECT
  USING (TRUE);

-- ============================================================
-- SEED: Office requirements
-- NULL program_id = applies to all students
-- ============================================================

-- Global offices — apply to every student
INSERT INTO office_requirements (office_id, program_id) VALUES
(1,  NULL),  -- Registrar's Office
(2,  NULL),  -- University Library
(3,  NULL),  -- Finance Office
(4,  NULL),  -- Office of Student Affairs
(5,  NULL),  -- Campus Ministry
(6,  NULL),  -- Health Services Unit
(7,  NULL),  -- Security Office
(8,  NULL),  -- IT Services Office
(9,  NULL),  -- Guidance and Counseling Center
(10, NULL),  -- University Dormitory Office
(11, NULL),  -- Athletics and Sports Office
(13, NULL),  -- Research and Publication Center
(14, NULL),  -- Alumni Affairs Office
(15, NULL),  -- Admissions Office
(20, NULL);  -- Property and Procurement Office

-- Science Lab (12) → Engineering + Science programs only
INSERT INTO office_requirements (office_id, program_id) VALUES
(12, 1),   -- BS Civil Engineering
(12, 2),   -- BS Electrical Engineering
(12, 3),   -- BS Mechanical Engineering
(12, 4),   -- BS Computer Engineering
(12, 5),   -- BS Electronics Engineering
(12, 6),   -- BS Chemical Engineering
(12, 7),   -- BS Computer Science
(12, 8),   -- BS Information Technology
(12, 9),   -- BS Biology
(12, 14);  -- BS Mathematics

-- Dean's offices → per program under their college
-- College of Engineering Dean's Office (16) → programs 1-6
INSERT INTO office_requirements (office_id, program_id) VALUES
(16, 1),(16, 2),(16, 3),(16, 4),(16, 5),(16, 6);

-- College of Arts and Sciences Dean's Office (17) → programs 7-14
INSERT INTO office_requirements (office_id, program_id) VALUES
(17, 7),(17, 8),(17, 9),(17, 10),(17, 11),(17, 12),(17, 13),(17, 14);

-- College of Business Administration Dean's Office (18) → programs 15-18
INSERT INTO office_requirements (office_id, program_id) VALUES
(18, 15),(18, 16),(18, 17),(18, 18);

-- College of Nursing Dean's Office (19) → program 19 only
INSERT INTO office_requirements (office_id, program_id) VALUES
(19, 19);