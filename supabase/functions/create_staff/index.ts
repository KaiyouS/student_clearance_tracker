import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return new Response('Method not allowed', {
      status: 405,
      headers: corsHeaders,
    })
  }

  try {
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

    const { data: roles } = await callerClient
      .from('user_roles')
      .select('role')
      .eq('user_id', user.id)
      .eq('role', 'super_admin')
      .single()

    if (!roles) {
      return new Response(
        JSON.stringify({ error: 'Forbidden. Super admin access required.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const {
      email,
      employee_no,
      first_name,
      middle_name,
      last_name,
      office_ids,
    } = await req.json()

    if (!email || !employee_no || !first_name || !last_name) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ── Create auth user (no email sent) ──────────────────
    const { data: authData, error: authError } =
      await adminClient.auth.admin.createUser({
        email,
        password:      employee_no,
        email_confirm: true,
        user_metadata: { first_name, last_name },
      })

    if (authError) throw authError
    const userId = authData.user.id

    // ── Insert into user_profiles ─────────────────────────
    const { error: profileError } = await adminClient
      .from('user_profiles')
      .insert({
        id:                    userId,
        first_name,
        middle_name:           middle_name || null,
        last_name,
        account_status:        'pending',
        needs_password_change: true,
      })

    if (profileError) {
      await adminClient.auth.admin.deleteUser(userId)
      throw profileError
    }

    // ── Insert into office_staff ──────────────────────────
    const { error: staffError } = await adminClient
      .from('office_staff')
      .insert({ id: userId, employee_no })

    if (staffError) {
      await adminClient.auth.admin.deleteUser(userId)
      throw staffError
    }

    // ── Insert into user_roles ────────────────────────────
    const { error: roleError } = await adminClient
      .from('user_roles')
      .insert({ user_id: userId, role: 'office_staff' })

    if (roleError) {
      await adminClient.auth.admin.deleteUser(userId)
      throw roleError
    }

    // ── Assign offices ────────────────────────────────────
    if (office_ids && office_ids.length > 0) {
      const assignments = office_ids.map((officeId: number) => ({
        staff_id:  userId,
        office_id: officeId,
      }))

      const { error: officeError } = await adminClient
        .from('staff_offices')
        .insert(assignments)

      if (officeError) {
        await adminClient.auth.admin.deleteUser(userId)
        throw officeError
      }
    }

    return new Response(
      JSON.stringify({ success: true, user_id: userId }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message ?? 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})