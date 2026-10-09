-- =====================================================
-- 0002_security_and_payments.sql
-- Run ONCE in the Supabase SQL Editor, AFTER 0001_init.sql.
-- Fixes security holes in 0001 and prepares for payments.
--
-- IMPORTANT: Dev B must change signUp() in auth.js at the same time
-- (see the new version in the chat). Otherwise signup breaks.
-- =====================================================

-- ---------- 1. RESERVATIONS: nobody pays or edits from the browser ----------
-- 0001 let students UPDATE their own reservation (they could set status = 'confirmed')
-- and INSERT one with any fee they like. Only Edge Functions (service_role) do that now.
drop policy "Students can create their own reservations" on reservations;
drop policy "Students can update their own reservations" on reservations;

alter table reservations add column if not exists move_in_date date;
alter table reservations add column if not exists months int not null default 12
  check (months between 1 and 24);
alter table reservations add constraint reservations_payment_reference_key
  unique (payment_reference);

create index if not exists reservations_student_idx on reservations (student_id);
create index if not exists reservations_property_idx on reservations (property_id);
create index if not exists properties_landlord_idx on properties (landlord_id);

-- ---------- 2. PROFILES: stop leaking landlord phone numbers ----------
-- 0001 let ANYONE (even logged-out visitors) read every landlord profile, including phone.
drop policy "Anyone can view landlord names for active listings" on profiles;

-- Safe public view: name and company only.
create view landlord_public as
  select id, full_name, company_name
  from profiles
  where role = 'landlord';
grant select on landlord_public to anon, authenticated;

-- ---------- 3. PROFILES: create the profile with a trigger ----------
-- The old signup inserted the profile from the browser. That fails whenever
-- "Confirm email" is on (there is no session yet), so the database does it instead.
drop policy "Users can insert their own profile" on profiles;

create or replace function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into profiles (id, role, full_name, phone, student_number, university, company_name)
  values (
    new.id,
    case when new.raw_user_meta_data->>'role' = 'landlord'
         then 'landlord'::user_role else 'student'::user_role end,
    coalesce(nullif(trim(new.raw_user_meta_data->>'full_name'), ''), 'New user'),
    nullif(trim(new.raw_user_meta_data->>'phone'), ''),
    nullif(trim(new.raw_user_meta_data->>'student_number'), ''),
    nullif(trim(new.raw_user_meta_data->>'university'), ''),
    nullif(trim(new.raw_user_meta_data->>'company_name'), '')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ---------- 4. PROPERTIES: verification and who can list ----------
-- Only verified listings are public. Landlords also see their own unverified ones.
drop policy "Anyone can view available properties" on properties;
create policy "Browse verified listings, landlords see their own"
  on properties for select
  using (verified = true or auth.uid() = landlord_id);

-- Only landlord accounts can create listings.
drop policy "Landlords can insert their own properties" on properties;
create policy "Landlords can insert their own properties"
  on properties for insert
  with check (
    auth.uid() = landlord_id
    and exists (select 1 from profiles where id = auth.uid() and role = 'landlord')
  );

-- Landlords can never mark their own listing verified.
-- Changes from the SQL Editor / Table Editor (you) are not affected.
create or replace function protect_verified()
returns trigger
language plpgsql
as $$
begin
  if auth.role() in ('anon', 'authenticated') then
    if tg_op = 'INSERT' then
      new.verified := false;
    elsif new.verified is distinct from old.verified then
      new.verified := old.verified;
    end if;
  end if;
  return new;
end;
$$;

create trigger protect_verified_insert
  before insert on properties
  for each row execute function protect_verified();

create trigger protect_verified_update
  before update on properties
  for each row execute function protect_verified();

-- ---------- 5. LANDLORD DASHBOARD VIEW (Week 3) ----------
create view landlord_listing_stats
with (security_invoker = true) as
select
  p.id,
  p.landlord_id,
  p.name,
  p.monthly_rent,
  p.available,
  p.verified,
  count(r.id) filter (where r.status = 'confirmed') as confirmed_bookings,
  count(r.id) filter (where r.status = 'pending_payment') as pending_bookings
from properties p
left join reservations r on r.property_id = p.id
group by p.id;
