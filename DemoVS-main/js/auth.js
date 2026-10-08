// Shared auth helpers, used across every page
// UPDATED for migration 0002: the database now creates the profile row
// (via a trigger), so signUp() only sends the details as metadata.

async function getCurrentUser() {
  const { data: { user } } = await supabaseClient.auth.getUser();
  return user;
}

async function getCurrentProfile() {
  const user = await getCurrentUser();
  if (!user) return null;
  const { data } = await supabaseClient.from('profiles').select('*').eq('id', user.id).single();
  return data;
}

async function requireAuth(redirectTo = 'login.html') {
  const user = await getCurrentUser();
  if (!user) {
    window.location.href = redirectTo;
    return null;
  }
  return user;
}

async function logOut() {
  await supabaseClient.auth.signOut();
  window.location.href = 'index.html';
}

// Returns { user, session }.
// If "Confirm email" is ON in Supabase, session is null until the person
// clicks the link in their email, so the page should tell them to check email.
async function signUp({ email, password, fullName, role, phone, studentNumber, university, companyName }) {
  const { data, error } = await supabaseClient.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
        role: role,
        phone: phone || '',
        student_number: role === 'student' ? (studentNumber || '') : '',
        university: role === 'student' ? (university || '') : '',
        company_name: role === 'landlord' ? (companyName || '') : ''
      }
    }
  });
  if (error) throw error;

  return { user: data.user, session: data.session };
}

async function logIn({ email, password }) {
  const { data, error } = await supabaseClient.auth.signInWithPassword({ email, password });
  if (error) throw error;

  const { data: profile } = await supabaseClient.from('profiles').select('role').eq('id', data.user.id).single();
  return profile;
}
