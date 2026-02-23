-- =========================================
-- KARATE CLASS APP — SUPABASE SCHEMA SQL
-- Run this in Supabase SQL Editor
-- =========================================

-- 1. LOCATIONS (create first, users references it)
create table public.locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  notes text,
  created_at timestamptz default now()
);

insert into public.locations (id, name) values
  ('11111111-1111-1111-1111-111111111111', 'Bolloine'),
  ('22222222-2222-2222-2222-222222222222', 'DLF'),
  ('33333333-3333-3333-3333-333333333333', 'Gemgrove'),
  ('44444444-4444-4444-4444-444444444444', 'RC Blossom'),
  ('55555555-5555-5555-5555-555555555555', 'Jonesh Casio'),
  ('66666666-6666-6666-6666-666666666666', 'TVH'),
  ('77777777-7777-7777-7777-777777777777', 'TCH')
on conflict (id) do update set name = excluded.name;

-- 2. USERS (extends Supabase auth)
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  age int,
  belt_level text not null default 'White',
  phone text,
  role text not null default 'student' check (role in ('admin', 'student')),
  location_id uuid references public.locations(id) on delete set null,
  created_at timestamptz default now()
);

-- 3. ATTENDANCE
create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.users(id) on delete cascade,
  location_id uuid references public.locations(id) on delete set null,
  date date not null,
  status text not null default 'present' check (status in ('present', 'absent')),
  created_at timestamptz default now(),
  unique(student_id, date)
);

-- 4. POSTS
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  date date,
  image_url text,
  type text not null default 'upcoming' check (type in ('upcoming', 'recent')),
  created_at timestamptz default now()
);

-- =========================================
-- ROW LEVEL SECURITY (RLS)
-- =========================================

alter table public.locations enable row level security;
alter table public.users enable row level security;
alter table public.attendance enable row level security;
alter table public.posts enable row level security;

-- LOCATIONS policies
create policy "All authenticated can view locations" on public.locations
  for select to authenticated using (true);
create policy "Admin can insert locations" on public.locations
  for insert to authenticated with check (
    (select role from public.users where id = auth.uid()) = 'admin'
  );
create policy "Admin can update locations" on public.locations
  for update to authenticated using (
    (select role from public.users where id = auth.uid()) = 'admin'
  );
create policy "Admin can delete locations" on public.locations
  for delete to authenticated using (
    (select role from public.users where id = auth.uid()) = 'admin'
  );

-- USERS policies
create policy "Users can view all users" on public.users
  for select to authenticated using (true);
create policy "Users can insert own profile" on public.users
  for insert to authenticated with check (id = auth.uid());
create policy "Users can update own profile" on public.users
  for update to authenticated using (id = auth.uid())
  with check (id = auth.uid() and role = (select role from public.users where id = auth.uid()));
create policy "Admin can update any user" on public.users
  for update to authenticated using (
    (select role from public.users where id = auth.uid()) = 'admin'
  );

-- ATTENDANCE policies
create policy "Students can view own attendance" on public.attendance
  for select to authenticated using (
    student_id = auth.uid() or
    (select role from public.users where id = auth.uid()) = 'admin'
  );
create policy "Admin can insert attendance" on public.attendance
  for insert to authenticated with check (
    (select role from public.users where id = auth.uid()) = 'admin'
  );
create policy "Admin can update attendance" on public.attendance
  for update to authenticated using (
    (select role from public.users where id = auth.uid()) = 'admin'
  );

-- POSTS policies
create policy "All authenticated can view posts" on public.posts
  for select to authenticated using (true);
create policy "Admin can insert posts" on public.posts
  for insert to authenticated with check (
    (select role from public.users where id = auth.uid()) = 'admin'
  );
create policy "Admin can update posts" on public.posts
  for update to authenticated using (
    (select role from public.users where id = auth.uid()) = 'admin'
  );
create policy "Admin can delete posts" on public.posts
  for delete to authenticated using (
    (select role from public.users where id = auth.uid()) = 'admin'
  );

-- =========================================
-- STORAGE BUCKET
-- Run in Supabase Dashboard > Storage
-- Create a public bucket named: karate-media
-- =========================================
-- Or run this:
-- insert into storage.buckets (id, name, public) values ('karate-media', 'karate-media', true);

-- =========================================
-- MAKE YOURSELF ADMIN
-- After registering, run this to elevate your account:
-- update public.users set role = 'admin' where id = '<YOUR_USER_ID>';
-- =========================================
