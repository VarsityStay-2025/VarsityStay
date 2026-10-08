// Shared auth helpers, used across every page

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

async function signUp({ email, password, fullName, role, phone, studentNumber, university, companyName }) {
  const { data, error } = await supabaseClient.auth.signUp({ email, password });
  if (error) throw error;

  const { error: profileError } = await supabaseClient.from('profiles').insert({
    id: data.user.id,
    role,
    full_name: fullName,
    phone: phone || null,
    student_number: role === 'student' ? (studentNumber || null) : null,
    university: role === 'student' ? (university || null) : null,
    company_name: role === 'landlord' ? (companyName || null) : null,
  });
  if (profileError) throw profileError;

  return data.user;
}

async function logIn({ email, password }) {
  const { data, error } = await supabaseClient.auth.signInWithPassword({ email, password });
  if (error) throw error;

  const { data: profile } = await supabaseClient.from('profiles').select('role').eq('id', data.user.id).single();
  return profile;
}
