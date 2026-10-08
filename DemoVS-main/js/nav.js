// Renders the shared nav into <div id="nav-placeholder"></div> on every page,
// and adjusts links based on whether someone's logged in.

async function renderNav() {
  const el = document.getElementById('nav-placeholder');
  if (!el) return;

  const user = await getCurrentUser();
  let profile = null;
  if (user) profile = await getCurrentProfile();

  const dashboardLink = profile
    ? (profile.role === 'landlord' ? 'dashboard-landlord.html' : 'dashboard-student.html')
    : 'login.html';

  el.innerHTML = `
    <nav class="nav">
      <a href="index.html" class="logo">
        <span class="logo-mark">VS</span>
        <span class="logo-text">Varsity<em>Stay</em></span>
      </a>
      <div class="nav-links">
        <a href="properties.html">Find a Stay</a>
        <a href="list-your-property.html">List Your Property</a>
      </div>
      <div class="nav-actions">
        ${user ? `
          <a href="${dashboardLink}" class="btn btn-outline">My Account</a>
        ` : `
          <a href="login.html" class="btn btn-outline">Log In</a>
          <a href="signup.html" class="btn btn-primary">Sign Up</a>
        `}
      </div>
    </nav>
  `;
}

document.addEventListener('DOMContentLoaded', renderNav);
