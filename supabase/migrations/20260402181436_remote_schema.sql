


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."can_office_sign"("p_student_id" "uuid", "p_office_id" integer, "p_academic_period_id" integer) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Check if any prerequisite office is NOT yet signed
  RETURN NOT EXISTS (
    SELECT 1
    FROM office_prerequisites op
    LEFT JOIN clearance_steps cs
      ON  cs.office_id          = op.requires_office_id
      AND cs.student_id         = p_student_id
      AND cs.academic_period_id = p_academic_period_id
      AND cs.status             = 'signed'
    WHERE op.office_id = p_office_id
      AND cs.id IS NULL           -- prerequisite exists but is NOT signed
  );
END;
$$;


ALTER FUNCTION "public"."can_office_sign"("p_student_id" "uuid", "p_office_id" integer, "p_academic_period_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_dashboard_stats"() RETURNS json
    LANGUAGE "plpgsql"
    AS $$
declare
  current_period_id int;
  result json;
begin
  -- Get current academic period
  select id into current_period_id
  from academic_periods
  where is_current = true
  limit 1;

  -- Build result
  select json_build_object(
    'total_students', (select count(*) from students),
    'total_offices', (select count(*) from offices),
    'total_staff', (select count(*) from office_staff),

    'pending_steps', (
      select count(*) 
      from clearance_steps 
      where status = 'pending'
      and academic_period_id = current_period_id
    ),

    'flagged_steps', (
      select count(*) 
      from clearance_steps 
      where status = 'flagged'
      and academic_period_id = current_period_id
    ),

    'completed_students', (
      select count(*) 
      from student_clearance_status
      where clearance_status = 'complete'
      and academic_period_id = current_period_id
    ),

    'current_period_label', (
      select label 
      from academic_periods 
      where id = current_period_id
    )
  )
  into result;

  return result;
end;
$$;


ALTER FUNCTION "public"."get_dashboard_stats"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_role"("r" "text") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = r
  );
$$;


ALTER FUNCTION "public"."has_role"("r" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_staff_of_office"("p_office_id" integer) RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM staff_offices so
    JOIN office_staff os ON os.id = so.staff_id
    WHERE so.staff_id = auth.uid()
      AND so.office_id = p_office_id
  );
$$;


ALTER FUNCTION "public"."is_staff_of_office"("p_office_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_clearance_step_change"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Only log if status actually changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO clearance_step_logs (
      clearance_step_id,
      changed_by,
      old_status,
      new_status,
      remarks,
      changed_at
    ) VALUES (
      NEW.id,
      NEW.updated_by,
      OLD.status,
      NEW.status,
      NEW.remarks,
      now()
    );
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."log_clearance_step_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rls_auto_enable"() RETURNS "event_trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."rls_auto_enable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_current_period"("period_id" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE academic_periods SET is_current = FALSE WHERE is_current = TRUE;
  UPDATE academic_periods SET is_current = TRUE  WHERE id = period_id;
END;
$$;


ALTER FUNCTION "public"."set_current_period"("period_id" integer) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."academic_periods" (
    "id" integer NOT NULL,
    "label" "text" NOT NULL,
    "start_date" "date",
    "end_date" "date",
    "is_current" boolean DEFAULT false
);


ALTER TABLE "public"."academic_periods" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."academic_periods_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."academic_periods_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."academic_periods_id_seq" OWNED BY "public"."academic_periods"."id";



CREATE TABLE IF NOT EXISTS "public"."clearance_step_logs" (
    "id" integer NOT NULL,
    "clearance_step_id" integer,
    "changed_by" "uuid",
    "old_status" "text",
    "new_status" "text",
    "remarks" "text",
    "changed_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."clearance_step_logs" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."clearance_step_logs_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."clearance_step_logs_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."clearance_step_logs_id_seq" OWNED BY "public"."clearance_step_logs"."id";



CREATE TABLE IF NOT EXISTS "public"."clearance_steps" (
    "id" integer NOT NULL,
    "student_id" "uuid",
    "office_id" integer,
    "academic_period_id" integer,
    "status" "text" DEFAULT 'pending'::"text",
    "remarks" "text",
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "updated_by" "uuid",
    CONSTRAINT "clearance_steps_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'signed'::"text", 'flagged'::"text"])))
);


ALTER TABLE "public"."clearance_steps" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."clearance_steps_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."clearance_steps_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."clearance_steps_id_seq" OWNED BY "public"."clearance_steps"."id";



CREATE TABLE IF NOT EXISTS "public"."office_prerequisites" (
    "office_id" integer NOT NULL,
    "requires_office_id" integer NOT NULL
);


ALTER TABLE "public"."office_prerequisites" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."office_staff" (
    "id" "uuid" NOT NULL,
    "employee_no" "text" NOT NULL
);


ALTER TABLE "public"."office_staff" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."offices" (
    "id" integer NOT NULL,
    "name" "text" NOT NULL,
    "description" "text"
);


ALTER TABLE "public"."offices" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."offices_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."offices_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."offices_id_seq" OWNED BY "public"."offices"."id";



CREATE TABLE IF NOT EXISTS "public"."staff_offices" (
    "staff_id" "uuid" NOT NULL,
    "office_id" integer NOT NULL
);


ALTER TABLE "public"."staff_offices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."students" (
    "id" "uuid" NOT NULL,
    "student_no" "text" NOT NULL,
    "course" "text",
    "year_level" integer
);


ALTER TABLE "public"."students" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
    "id" "uuid" NOT NULL,
    "first_name" "text" NOT NULL,
    "middle_name" "text",
    "last_name" "text" NOT NULL,
    "full_name" "text" GENERATED ALWAYS AS (((("first_name" || ' '::"text") || COALESCE(("middle_name" || ' '::"text"), ''::"text")) || "last_name")) STORED,
    "account_status" "text" DEFAULT 'pending'::"text",
    "needs_password_change" boolean DEFAULT true,
    "created_at" timestamp without time zone DEFAULT "now"(),
    CONSTRAINT "user_profiles_account_status_check" CHECK (("account_status" = ANY (ARRAY['pending'::"text", 'active'::"text", 'inactive'::"text", 'locked'::"text"])))
);


ALTER TABLE "public"."user_profiles" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."student_clearance_status" AS
 SELECT "s"."id" AS "student_id",
    "up"."full_name",
    "cs"."academic_period_id",
    "ap"."label" AS "period_label",
    "count"(*) AS "total_steps",
    "count"(*) FILTER (WHERE ("cs"."status" = 'signed'::"text")) AS "signed_steps",
    "count"(*) FILTER (WHERE ("cs"."status" = 'flagged'::"text")) AS "flagged_steps",
    "count"(*) FILTER (WHERE ("cs"."status" = 'pending'::"text")) AS "pending_steps",
        CASE
            WHEN ("count"(*) FILTER (WHERE ("cs"."status" <> 'signed'::"text")) = 0) THEN 'complete'::"text"
            ELSE 'incomplete'::"text"
        END AS "clearance_status"
   FROM ((("public"."students" "s"
     JOIN "public"."user_profiles" "up" ON (("up"."id" = "s"."id")))
     JOIN "public"."clearance_steps" "cs" ON (("cs"."student_id" = "s"."id")))
     JOIN "public"."academic_periods" "ap" ON (("ap"."id" = "cs"."academic_period_id")))
  GROUP BY "s"."id", "up"."full_name", "cs"."academic_period_id", "ap"."label";


ALTER VIEW "public"."student_clearance_status" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "user_id" "uuid" NOT NULL,
    "role" "text" NOT NULL,
    CONSTRAINT "user_roles_role_check" CHECK (("role" = ANY (ARRAY['student'::"text", 'office_staff'::"text", 'super_admin'::"text"])))
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."academic_periods" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."academic_periods_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."clearance_step_logs" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."clearance_step_logs_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."clearance_steps" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."clearance_steps_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."offices" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."offices_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."academic_periods"
    ADD CONSTRAINT "academic_periods_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clearance_step_logs"
    ADD CONSTRAINT "clearance_step_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clearance_steps"
    ADD CONSTRAINT "clearance_steps_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clearance_steps"
    ADD CONSTRAINT "clearance_steps_student_id_office_id_academic_period_id_key" UNIQUE ("student_id", "office_id", "academic_period_id");



ALTER TABLE ONLY "public"."office_prerequisites"
    ADD CONSTRAINT "office_prerequisites_pkey" PRIMARY KEY ("office_id", "requires_office_id");



ALTER TABLE ONLY "public"."office_staff"
    ADD CONSTRAINT "office_staff_employee_no_key" UNIQUE ("employee_no");



ALTER TABLE ONLY "public"."office_staff"
    ADD CONSTRAINT "office_staff_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."offices"
    ADD CONSTRAINT "offices_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."staff_offices"
    ADD CONSTRAINT "staff_offices_pkey" PRIMARY KEY ("staff_id", "office_id");



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_student_no_key" UNIQUE ("student_no");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("user_id", "role");



CREATE UNIQUE INDEX "only_one_current_period" ON "public"."academic_periods" USING "btree" ("is_current") WHERE ("is_current" = true);



CREATE OR REPLACE TRIGGER "trg_log_clearance_step" AFTER UPDATE ON "public"."clearance_steps" FOR EACH ROW EXECUTE FUNCTION "public"."log_clearance_step_change"();



ALTER TABLE ONLY "public"."clearance_step_logs"
    ADD CONSTRAINT "clearance_step_logs_clearance_step_id_fkey" FOREIGN KEY ("clearance_step_id") REFERENCES "public"."clearance_steps"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."clearance_steps"
    ADD CONSTRAINT "clearance_steps_academic_period_id_fkey" FOREIGN KEY ("academic_period_id") REFERENCES "public"."academic_periods"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."clearance_steps"
    ADD CONSTRAINT "clearance_steps_office_id_fkey" FOREIGN KEY ("office_id") REFERENCES "public"."offices"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."clearance_steps"
    ADD CONSTRAINT "clearance_steps_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."office_staff"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."office_prerequisites"
    ADD CONSTRAINT "office_prerequisites_office_id_fkey" FOREIGN KEY ("office_id") REFERENCES "public"."offices"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."office_prerequisites"
    ADD CONSTRAINT "office_prerequisites_requires_office_id_fkey" FOREIGN KEY ("requires_office_id") REFERENCES "public"."offices"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."office_staff"
    ADD CONSTRAINT "office_staff_id_fkey" FOREIGN KEY ("id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."staff_offices"
    ADD CONSTRAINT "staff_offices_office_id_fkey" FOREIGN KEY ("office_id") REFERENCES "public"."offices"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."staff_offices"
    ADD CONSTRAINT "staff_offices_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "public"."office_staff"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_id_fkey" FOREIGN KEY ("id") REFERENCES "public"."user_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE "public"."academic_periods" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "admin manages academic_periods" ON "public"."academic_periods" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages clearance_steps" ON "public"."clearance_steps" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages logs" ON "public"."clearance_step_logs" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages office_prerequisites" ON "public"."office_prerequisites" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages office_staff" ON "public"."office_staff" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages offices" ON "public"."offices" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages staff_offices" ON "public"."staff_offices" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages students" ON "public"."students" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "admin manages user_profiles" ON "public"."user_profiles" USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'super_admin'::"text")))));



CREATE POLICY "admin manages user_roles" ON "public"."user_roles" USING ("public"."has_role"('super_admin'::"text"));



CREATE POLICY "anyone can view academic_periods" ON "public"."academic_periods" FOR SELECT USING (true);



CREATE POLICY "anyone can view office_prerequisites" ON "public"."office_prerequisites" FOR SELECT USING (true);



CREATE POLICY "anyone can view offices" ON "public"."offices" FOR SELECT USING (true);



ALTER TABLE "public"."clearance_step_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."clearance_steps" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."office_prerequisites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."office_staff" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."offices" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "staff reads all profiles" ON "public"."user_profiles" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_roles"
  WHERE (("user_roles"."user_id" = "auth"."uid"()) AND ("user_roles"."role" = 'office_staff'::"text")))));



CREATE POLICY "staff reads all students" ON "public"."students" FOR SELECT USING ("public"."has_role"('office_staff'::"text"));



CREATE POLICY "staff reads clearance_steps for their offices" ON "public"."clearance_steps" FOR SELECT USING (("public"."has_role"('office_staff'::"text") AND "public"."is_staff_of_office"("office_id")));



CREATE POLICY "staff reads logs for their offices" ON "public"."clearance_step_logs" FOR SELECT USING (("public"."has_role"('office_staff'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."clearance_steps" "cs"
  WHERE (("cs"."id" = "clearance_step_logs"."clearance_step_id") AND "public"."is_staff_of_office"("cs"."office_id"))))));



CREATE POLICY "staff reads own office assignments" ON "public"."staff_offices" FOR SELECT USING (("auth"."uid"() = "staff_id"));



CREATE POLICY "staff reads own profile" ON "public"."office_staff" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "staff updates clearance_steps for their offices" ON "public"."clearance_steps" FOR UPDATE USING (("public"."has_role"('office_staff'::"text") AND "public"."is_staff_of_office"("office_id"))) WITH CHECK (("status" = ANY (ARRAY['signed'::"text", 'flagged'::"text"])));



ALTER TABLE "public"."staff_offices" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "student reads own clearance_steps" ON "public"."clearance_steps" FOR SELECT USING (("public"."has_role"('student'::"text") AND ("auth"."uid"() = "student_id")));



CREATE POLICY "student reads own logs" ON "public"."clearance_step_logs" FOR SELECT USING (("public"."has_role"('student'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."clearance_steps" "cs"
  WHERE (("cs"."id" = "clearance_step_logs"."clearance_step_id") AND ("cs"."student_id" = "auth"."uid"()))))));



CREATE POLICY "student reads own profile" ON "public"."students" FOR SELECT USING (("auth"."uid"() = "id"));



ALTER TABLE "public"."students" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user reads own profile" ON "public"."user_profiles" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "user reads own roles" ON "public"."user_roles" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "user updates own profile" ON "public"."user_profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



ALTER TABLE "public"."user_profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."can_office_sign"("p_student_id" "uuid", "p_office_id" integer, "p_academic_period_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."can_office_sign"("p_student_id" "uuid", "p_office_id" integer, "p_academic_period_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_office_sign"("p_student_id" "uuid", "p_office_id" integer, "p_academic_period_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_dashboard_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_dashboard_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_dashboard_stats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_role"("r" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."has_role"("r" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_role"("r" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_staff_of_office"("p_office_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."is_staff_of_office"("p_office_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_staff_of_office"("p_office_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."log_clearance_step_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_clearance_step_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_clearance_step_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "anon";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_current_period"("period_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."set_current_period"("period_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_current_period"("period_id" integer) TO "service_role";


















GRANT ALL ON TABLE "public"."academic_periods" TO "anon";
GRANT ALL ON TABLE "public"."academic_periods" TO "authenticated";
GRANT ALL ON TABLE "public"."academic_periods" TO "service_role";



GRANT ALL ON SEQUENCE "public"."academic_periods_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."academic_periods_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."academic_periods_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."clearance_step_logs" TO "anon";
GRANT ALL ON TABLE "public"."clearance_step_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."clearance_step_logs" TO "service_role";



GRANT ALL ON SEQUENCE "public"."clearance_step_logs_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."clearance_step_logs_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."clearance_step_logs_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."clearance_steps" TO "anon";
GRANT ALL ON TABLE "public"."clearance_steps" TO "authenticated";
GRANT ALL ON TABLE "public"."clearance_steps" TO "service_role";



GRANT ALL ON SEQUENCE "public"."clearance_steps_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."clearance_steps_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."clearance_steps_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."office_prerequisites" TO "anon";
GRANT ALL ON TABLE "public"."office_prerequisites" TO "authenticated";
GRANT ALL ON TABLE "public"."office_prerequisites" TO "service_role";



GRANT ALL ON TABLE "public"."office_staff" TO "anon";
GRANT ALL ON TABLE "public"."office_staff" TO "authenticated";
GRANT ALL ON TABLE "public"."office_staff" TO "service_role";



GRANT ALL ON TABLE "public"."offices" TO "anon";
GRANT ALL ON TABLE "public"."offices" TO "authenticated";
GRANT ALL ON TABLE "public"."offices" TO "service_role";



GRANT ALL ON SEQUENCE "public"."offices_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."offices_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."offices_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."staff_offices" TO "anon";
GRANT ALL ON TABLE "public"."staff_offices" TO "authenticated";
GRANT ALL ON TABLE "public"."staff_offices" TO "service_role";



GRANT ALL ON TABLE "public"."students" TO "anon";
GRANT ALL ON TABLE "public"."students" TO "authenticated";
GRANT ALL ON TABLE "public"."students" TO "service_role";



GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."student_clearance_status" TO "anon";
GRANT ALL ON TABLE "public"."student_clearance_status" TO "authenticated";
GRANT ALL ON TABLE "public"."student_clearance_status" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";



































drop extension if exists "pg_net";


