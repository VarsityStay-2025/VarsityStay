-- VarsityStay Phase 1 schema
-- Run this in Supabase SQL Editor, or via `supabase db push`

-- 1. Profiles table (extends auth.users with role + details)
create type user_role as enum ('student', 'landlord');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role user_role not null,
  full_name text not null,
  phone text,
  -- student-specific
  student_number text,
  university text,
  -- landlord-specific
  company_name text,
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "Users can view their own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on profiles for update
  using (auth.uid() = id);

create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

-- Public can view minimal landlord info attached to listings (name only, via join in app layer)
create policy "Anyone can view landlord names for active listings"
  on profiles for select
  using (role = 'landlord');


-- 2. Properties table
create table properties (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid not null references profiles(id) on delete cascade,
  name text not null,
  city text not null,
  university text not null,
  distance_minutes int not null,          -- walking distance to campus, in MINUTES not km
  monthly_rent numeric(10,2) not null,
  room_type text not null,                -- 'single' | 'shared' | 'studio' etc.
  nsfas_accredited boolean not null default false,
  amenities text[] not null default '{}', -- e.g. {'Wi-Fi','24/7 Security','Parking'}
  description text,
  image_url text,
  verified boolean not null default false,
  available boolean not null default true,
  rating numeric(2,1),
  created_at timestamptz not null default now()
);

alter table properties enable row level security;

create policy "Anyone can view available properties"
  on properties for select
  using (true);

create policy "Landlords can insert their own properties"
  on properties for insert
  with check (auth.uid() = landlord_id);

create policy "Landlords can update their own properties"
  on properties for update
  using (auth.uid() = landlord_id);

create policy "Landlords can delete their own properties"
  on properties for delete
  using (auth.uid() = landlord_id);

create index properties_university_idx on properties (university);
create index properties_city_idx on properties (city);


-- 3. Reservations table
create type reservation_status as enum ('pending_payment', 'confirmed', 'cancelled');

create table reservations (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  student_id uuid not null references profiles(id) on delete cascade,
  status reservation_status not null default 'pending_payment',
  funding_source text, -- e.g. 'NSFAS', 'Self-funded', 'Bursary'
  reservation_fee numeric(10,2) not null,
  payment_reference text,
  created_at timestamptz not null default now()
);

alter table reservations enable row level security;

create policy "Students can view their own reservations"
  on reservations for select
  using (auth.uid() = student_id);

create policy "Landlords can view reservations on their properties"
  on reservations for select
  using (
    exists (
      select 1 from properties
      where properties.id = reservations.property_id
      and properties.landlord_id = auth.uid()
    )
  );

create policy "Students can create their own reservations"
  on reservations for insert
  with check (auth.uid() = student_id);

create policy "Students can update their own reservations"
  on reservations for update
  using (auth.uid() = student_id);
