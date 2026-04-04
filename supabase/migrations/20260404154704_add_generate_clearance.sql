-- ============================================================
-- FUNCTION: generate_clearance_for_student
-- Creates clearance_steps for a student based on their program
-- and the current academic period.
-- Safe to call multiple times — skips existing steps.
-- ============================================================
CREATE OR REPLACE FUNCTION generate_clearance_for_student(
  p_student_id UUID
)
RETURNS INT  -- returns number of steps created
LANGUAGE plpgsql
AS $$
DECLARE
  v_period_id  INT;
  v_program_id INT;
  v_count      INT := 0;
  v_office_id  INT;
BEGIN
  -- Get current period
  SELECT id INTO v_period_id
  FROM academic_periods
  WHERE is_current = TRUE
  LIMIT 1;

  IF v_period_id IS NULL THEN
    RAISE EXCEPTION 'No current academic period is set.';
  END IF;

  -- Get student's program
  SELECT program_id INTO v_program_id
  FROM students
  WHERE id = p_student_id;

  -- Insert a clearance step for each applicable office
  -- Applicable = has NULL program_id (all students)
  --           OR has this student's program_id
  FOR v_office_id IN
    SELECT DISTINCT office_id
    FROM office_requirements
    WHERE program_id IS NULL
       OR program_id = v_program_id
  LOOP
    -- Skip if step already exists
    IF NOT EXISTS (
      SELECT 1 FROM clearance_steps
      WHERE student_id         = p_student_id
        AND office_id          = v_office_id
        AND academic_period_id = v_period_id
    ) THEN
      INSERT INTO clearance_steps (
        student_id, office_id, academic_period_id, status
      ) VALUES (
        p_student_id, v_office_id, v_period_id, 'pending'
      );
      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$$;

-- ============================================================
-- FUNCTION: generate_clearance_for_all_students
-- Calls generate_clearance_for_student for every student.
-- Returns total steps created across all students.
-- ============================================================
CREATE OR REPLACE FUNCTION generate_clearance_for_all_students()
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
  v_student_id UUID;
  v_total      INT := 0;
  v_created    INT;
BEGIN
  FOR v_student_id IN SELECT id FROM students LOOP
    SELECT generate_clearance_for_student(v_student_id) INTO v_created;
    v_total := v_total + v_created;
  END LOOP;
  RETURN v_total;
END;
$$;