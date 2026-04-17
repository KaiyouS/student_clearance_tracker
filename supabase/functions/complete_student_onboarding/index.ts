import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const allowNonAdduEmails =
  (Deno.env.get('ALLOW_NON_ADDU_EMAILS') ?? '').toLowerCase() === 'true'

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return new Response('Method not allowed', {
      status: 405, headers: corsHeaders,
    })
  }

  try {
    // ── 1. Verify caller is authenticated ─────────────────
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header.' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const callerClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: userError } =
      await callerClient.auth.getUser()
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized.' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const email = user.email?.toLowerCase() ?? ''
    if (!allowNonAdduEmails && !email.endsWith('@addu.edu.ph')) {
      return new Response(
        JSON.stringify({ error: 'Only addu.edu.ph student accounts are allowed.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // ── 2. Prevent re-onboarding ──────────────────────────
    const { data: existing } = await adminClient
      .from('user_profiles')
      .select('id')
      .eq('id', user.id)
      .maybeSingle()

    if (existing) {
      return new Response(
        JSON.stringify({ error: 'Account already set up.' }),
        { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const {
      student_no,
      first_name,
      middle_name,
      last_name,
      program_id,
      year_level,
      password,
    } = await req.json()

    if (!student_no || !first_name || !last_name) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ── 3. Check student_no is not already taken ──────────
    const { data: existingStudent } = await adminClient
      .from('students')
      .select('id')
      .eq('student_no', student_no)
      .maybeSingle()

    if (existingStudent) {
      return new Response(
        JSON.stringify({ error: 'Student number is already registered.' }),
        { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ── 4. Optionally set password on the auth user ───────
    if (typeof password === 'string' && password.trim().length > 0) {
      const { error: passwordError } =
        await adminClient.auth.admin.updateUserById(user.id, {
          password,
          email_confirm: true,
        })

      if (passwordError) throw passwordError
    }

    // ── 5. Insert user_profiles ───────────────────────────
    const { error: profileError } = await adminClient
      .from('user_profiles')
      .insert({
        id:                    user.id,
        first_name,
        middle_name:           middle_name || null,
        last_name,
        account_status:        'active',     // self-registered = active immediately
        needs_password_change: false,        // they just set their password
      })

    if (profileError) throw profileError

    // ── 6. Insert students ────────────────────────────────
    const { error: studentError } = await adminClient
      .from('students')
      .insert({
        id:         user.id,
        student_no,
        program_id: program_id || null,
        year_level: year_level || null,
      })

    if (studentError) throw studentError

    // ── 7. Insert user_roles ──────────────────────────────
    const { error: roleError } = await adminClient
      .from('user_roles')
      .insert({ user_id: user.id, role: 'student' })

    if (roleError) throw roleError

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message ?? 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})