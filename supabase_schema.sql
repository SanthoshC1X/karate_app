-- ============================================================
-- KARATE APP — SUPABASE SQL SCHEMA
-- Paste this in: Supabase Dashboard → SQL Editor → Run
-- ============================================================
-- Architecture : Flutter → Express Backend → Supabase PostgreSQL
-- Auth         : Custom JWT handled by Express (NOT Supabase Auth)
-- ============================================================


-- ============================================================
-- CLEAN SLATE  (drops everything so re-runs are safe)
-- ============================================================
drop table if exists public.class_schedules        cascade;
drop table if exists public.belt_promotion_history  cascade;
drop table if exists public.payments               cascade;
drop table if exists public.student_rank_values    cascade;
drop table if exists public.class_rank_fields      cascade;
drop table if exists public.messages               cascade;
drop table if exists public.conversations          cascade;
drop table if exists public.attendance             cascade;
drop table if exists public.student_classes        cascade;
drop table if exists public.master_classes         cascade;
drop table if exists public.student_masters        cascade;
drop table if exists public.admin_locations        cascade;
drop table if exists public.posts                  cascade;
drop table if exists public.auth_accounts          cascade;
drop table if exists public.users                  cascade;
drop table if exists public.classes                cascade;
drop table if exists public.locations              cascade;

drop type if exists payment_status_enum     cascade;
drop type if exists attendance_status_enum  cascade;
drop type if exists post_type_enum          cascade;
drop type if exists role_enum               cascade;

drop function if exists update_updated_at_column()       cascade;
drop function if exists sync_conversation_last_message() cascade;


-- ============================================================
-- EXTENSIONS
-- ============================================================
create extension if not exists "pgcrypto";  -- gen_random_uuid()
create extension if not exists "citext";    -- case-insensitive email


-- ============================================================
-- ENUMS
-- ============================================================
do $$ begin
  if not exists (select 1 from pg_type where typname = 'role_enum') then
    create type role_enum as enum ('super_admin', 'admin', 'student');
  end if;
end $$;
-- super_admin = school owner | admin = master/instructor | student = trainee

do $$ begin
  if not exists (select 1 from pg_type where typname = 'post_type_enum') then
    create type post_type_enum as enum ('upcoming', 'recent');
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_type where typname = 'attendance_status_enum') then
    create type attendance_status_enum as enum ('present', 'absent');
  end if;
end $$;

do $$ begin
  if not exists (select 1 from pg_type where typname = 'payment_status_enum') then
    create type payment_status_enum as enum ('pending', 'paid', 'partial', 'overdue');
  end if;
end $$;


-- ============================================================
-- TRIGGER FUNCTION  (auto-refreshes updated_at on every change)
-- ============================================================
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;


-- ============================================================
-- TABLE: locations
-- ============================================================
create table public.locations (
  id         uuid        primary key default gen_random_uuid(),
  name       text        not null,
  address    text,
  notes      text,
  created_at timestamptz not null default now()
);


-- ============================================================
-- TABLE: classes  (Kata, Kumite, Basics, etc.)
-- ============================================================
create table public.classes (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  description text,
  created_at  timestamptz not null default now()
);


-- ============================================================
-- TABLE: users  (all roles live here)
-- ============================================================
create table public.users (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  age         integer,
  belt_level  text        not null default 'White',
  phone       text,
  bio         text,
  role        role_enum   not null default 'student',
  location_id uuid,
  is_active   boolean     not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint users_location_fkey
    foreign key (location_id)
    references public.locations(id)
    on delete set null    -- deleting a location clears it from users, doesn't block
);

create or replace trigger users_updated_at
  before update on public.users
  for each row execute function update_updated_at_column();


-- ============================================================
-- TABLE: auth_accounts  (credentials — separated from profile)
-- ============================================================
create table public.auth_accounts (
  id            uuid        primary key default gen_random_uuid(),
  user_id       uuid        not null,
  email         citext      not null,   -- citext = case-insensitive login
  password_hash text        not null,   -- bcrypt hash, never plain text
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint auth_accounts_user_id_key  unique (user_id),
  constraint auth_accounts_email_key    unique (email),
  constraint auth_accounts_user_fkey
    foreign key (user_id)
    references public.users(id)
    on delete cascade     -- deleting a user removes their login
);

create or replace trigger auth_accounts_updated_at
  before update on public.auth_accounts
  for each row execute function update_updated_at_column();


-- ============================================================
-- TABLE: posts  (announcements from a master to their students)
-- created_by links each post to the master who wrote it
-- students query: WHERE created_by IN (my masters)
-- ============================================================
create table public.posts (
  id          uuid           primary key default gen_random_uuid(),
  title       text           not null,
  description text,
  date        date,
  image_url   text,
  type        post_type_enum not null default 'upcoming',
  created_by  uuid           not null,  -- master/admin who wrote this post
  created_at  timestamptz    not null default now(),
  constraint posts_created_by_fkey
    foreign key (created_by)
    references public.users(id)
    on delete cascade     -- master deleted → their posts deleted
);


-- ============================================================
-- TABLE: admin_locations  (which master manages which location)
-- ============================================================
create table public.admin_locations (
  id          uuid        primary key default gen_random_uuid(),
  admin_id    uuid        not null,
  location_id uuid        not null,
  created_at  timestamptz not null default now(),
  constraint admin_locations_unique unique (admin_id, location_id),
  constraint admin_locations_admin_fkey
    foreign key (admin_id)
    references public.users(id)
    on delete cascade,
  constraint admin_locations_location_fkey
    foreign key (location_id)
    references public.locations(id)
    on delete cascade
);


-- ============================================================
-- TABLE: student_masters  (student trains under which master/s)
-- This drives: post visibility, attendance access, chat access
-- ============================================================
create table public.student_masters (
  id         uuid        primary key default gen_random_uuid(),
  student_id uuid        not null,
  master_id  uuid        not null,
  created_at timestamptz not null default now(),
  constraint student_masters_unique unique (student_id, master_id),
  constraint student_masters_student_fkey
    foreign key (student_id)
    references public.users(id)
    on delete cascade,
  constraint student_masters_master_fkey
    foreign key (master_id)
    references public.users(id)
    on delete cascade
);


-- ============================================================
-- TABLE: master_classes  (which class types a master teaches)
-- ============================================================
create table public.master_classes (
  id         uuid        primary key default gen_random_uuid(),
  master_id  uuid        not null,
  class_id   uuid        not null,
  created_at timestamptz not null default now(),
  constraint master_classes_unique unique (master_id, class_id),
  constraint master_classes_master_fkey
    foreign key (master_id)
    references public.users(id)
    on delete cascade,
  constraint master_classes_class_fkey
    foreign key (class_id)
    references public.classes(id)
    on delete cascade
);


-- ============================================================
-- TABLE: student_classes  (which class types a student is in)
-- ============================================================
create table public.student_classes (
  id         uuid        primary key default gen_random_uuid(),
  student_id uuid        not null,
  class_id   uuid        not null,
  created_at timestamptz not null default now(),
  constraint student_classes_unique unique (student_id, class_id),
  constraint student_classes_student_fkey
    foreign key (student_id)
    references public.users(id)
    on delete cascade,
  constraint student_classes_class_fkey
    foreign key (class_id)
    references public.classes(id)
    on delete cascade
);


-- ============================================================
-- TABLE: attendance  (one record per student per day)
-- ============================================================
create table public.attendance (
  id          uuid                   primary key default gen_random_uuid(),
  student_id  uuid                   not null,
  location_id uuid,                  -- nullable so old records survive a location delete
  date        date                   not null,
  status      attendance_status_enum not null default 'present',
  created_at  timestamptz            not null default now(),
  constraint attendance_student_date_key unique (student_id, date),
  constraint attendance_student_fkey
    foreign key (student_id)
    references public.users(id)
    on delete cascade,
  constraint attendance_location_fkey
    foreign key (location_id)
    references public.locations(id)
    on delete set null    -- location deleted → record kept, location_id becomes null
);


-- ============================================================
-- TABLE: conversations  (one chat thread per student↔master pair)
-- ============================================================
create table public.conversations (
  id              uuid        primary key default gen_random_uuid(),
  student_id      uuid        not null,
  master_id       uuid        not null,
  last_message_at timestamptz,        -- updated by trigger; sorts inbox by latest
  created_at      timestamptz not null default now(),
  constraint conversations_pair_key unique (student_id, master_id),
  constraint conversations_student_fkey
    foreign key (student_id)
    references public.users(id)
    on delete cascade,
  constraint conversations_master_fkey
    foreign key (master_id)
    references public.users(id)
    on delete cascade
);


-- ============================================================
-- TABLE: messages  (individual messages inside a conversation)
-- ============================================================
create table public.messages (
  id              uuid        primary key default gen_random_uuid(),
  conversation_id uuid        not null,
  sender_id       uuid        not null,
  content         text        not null check (length(trim(content)) > 0),
  is_read         boolean     not null default false,
  created_at      timestamptz not null default now(),
  constraint messages_conversation_fkey
    foreign key (conversation_id)
    references public.conversations(id)
    on delete cascade,
  constraint messages_sender_fkey
    foreign key (sender_id)
    references public.users(id)
    on delete cascade
);

-- Auto-update conversations.last_message_at on every new message
create or replace function sync_conversation_last_message()
returns trigger as $$
begin
  update public.conversations
  set last_message_at = new.created_at
  where id = new.conversation_id;
  return new;
end;
$$ language plpgsql;

create or replace trigger messages_sync_conversation
  after insert on public.messages
  for each row execute function sync_conversation_last_message();


-- ============================================================
-- TABLE: class_rank_fields  (master-defined custom fields per class)
-- Masters can define text or select fields for each class they teach,
-- so students can fill in their level/details at registration time.
-- ============================================================
create table public.class_rank_fields (
  id          uuid        primary key default gen_random_uuid(),
  class_id    uuid        not null,
  master_id   uuid        not null,
  field_label text        not null,
  field_type  text        not null default 'text',  -- 'text' | 'select'
  options     text[]      not null default '{}',     -- used when field_type = 'select'
  order_index integer     not null default 0,
  created_at  timestamptz not null default now(),
  constraint crf_class_fkey
    foreign key (class_id)
    references public.classes(id)
    on delete cascade,
  constraint crf_master_fkey
    foreign key (master_id)
    references public.users(id)
    on delete cascade
);


-- ============================================================
-- TABLE: student_rank_values  (students' answers to rank fields)
-- One row per (student, field) pair — unique constraint prevents dupes.
-- ============================================================
create table public.student_rank_values (
  id         uuid        primary key default gen_random_uuid(),
  student_id uuid        not null,
  field_id   uuid        not null,
  value      text        not null,
  created_at timestamptz not null default now(),
  constraint srv_student_field_key unique (student_id, field_id),
  constraint srv_student_fkey
    foreign key (student_id)
    references public.users(id)
    on delete cascade,
  constraint srv_field_fkey
    foreign key (field_id)
    references public.class_rank_fields(id)
    on delete cascade
);


-- ============================================================
-- FUTURE TABLES  (schema ready, no UI/API yet — do not delete)
-- ============================================================

-- payments — monthly fee tracking
create table public.payments (
  id             uuid                primary key default gen_random_uuid(),
  student_id     uuid                not null,
  amount         numeric(10, 2)      not null,
  currency       text                not null default 'INR',
  paid_for_month date                not null,   -- use first day of month
  status         payment_status_enum not null default 'pending',
  notes          text,
  created_at     timestamptz         not null default now(),
  constraint payments_student_fkey
    foreign key (student_id)
    references public.users(id)
    on delete cascade
);

-- belt_promotion_history — immutable audit log of belt changes
create table public.belt_promotion_history (
  id          uuid        primary key default gen_random_uuid(),
  student_id  uuid        not null,
  old_belt    text        not null,
  new_belt    text        not null,
  promoted_by uuid,                  -- set null if promoting master is deleted
  notes       text,
  promoted_at timestamptz not null default now(),
  constraint belt_history_different check (old_belt <> new_belt),
  constraint belt_history_student_fkey
    foreign key (student_id)
    references public.users(id)
    on delete cascade,
  constraint belt_history_promoter_fkey
    foreign key (promoted_by)
    references public.users(id)
    on delete set null
);

-- class_schedules — weekly recurring timetable per class + location
create table public.class_schedules (
  id          uuid        primary key default gen_random_uuid(),
  class_id    uuid        not null,
  location_id uuid        not null,
  day_of_week smallint    not null check (day_of_week between 0 and 6),  -- 0=Sun…6=Sat
  start_time  time        not null,
  end_time    time        not null    check (end_time > start_time),
  created_at  timestamptz not null default now(),
  constraint class_schedules_class_fkey
    foreign key (class_id)
    references public.classes(id)
    on delete cascade,
  constraint class_schedules_location_fkey
    foreign key (location_id)
    references public.locations(id)
    on delete cascade
);


-- ============================================================
-- INDEXES
-- ============================================================

-- users
create index idx_users_location    on public.users(location_id);
create index idx_users_role        on public.users(role);
create index idx_users_active_role on public.users(is_active, role);

-- admin_locations
create index idx_admin_loc_admin    on public.admin_locations(admin_id);
create index idx_admin_loc_location on public.admin_locations(location_id);

-- student_masters  (heavily queried — drives access control)
create index idx_sm_master  on public.student_masters(master_id);
create index idx_sm_student on public.student_masters(student_id);

-- master_classes / student_classes
create index idx_mc_master   on public.master_classes(master_id);
create index idx_mc_class    on public.master_classes(class_id);
create index idx_sc_student  on public.student_classes(student_id);
create index idx_sc_class    on public.student_classes(class_id);

-- attendance
create index idx_att_student_date  on public.attendance(student_id, date desc);
create index idx_att_location_date on public.attendance(location_id, date desc);

-- posts  (student feed: "posts by my masters, newest first")
create index idx_posts_author      on public.posts(created_by, created_at desc);
create index idx_posts_type        on public.posts(type, created_at desc);

-- conversations
create index idx_conv_student on public.conversations(student_id, last_message_at desc nulls last);
create index idx_conv_master  on public.conversations(master_id,  last_message_at desc nulls last);

-- messages
create index idx_msg_conv   on public.messages(conversation_id, created_at asc);
create index idx_msg_unread on public.messages(conversation_id, is_read) where is_read = false;

-- class_rank_fields / student_rank_values
create index idx_crf_class_master on public.class_rank_fields(class_id, master_id);
create index idx_srv_student      on public.student_rank_values(student_id);

-- payments (future)
create index idx_pay_student on public.payments(student_id, paid_for_month desc);
create index idx_pay_status  on public.payments(status) where status <> 'paid';

-- belt history (future)
create index idx_belt_student on public.belt_promotion_history(student_id, promoted_at desc);

-- class schedules (future)
create index idx_cs_location_day on public.class_schedules(location_id, day_of_week);


-- ============================================================
-- SEED DATA — initial locations
-- ============================================================
insert into public.locations (id, name) values
  ('11111111-1111-1111-1111-111111111111', 'Bolloine'),
  ('22222222-2222-2222-2222-222222222222', 'DLF'),
  ('33333333-3333-3333-3333-333333333333', 'Gemgrove'),
  ('44444444-4444-4444-4444-444444444444', 'RC Blossom'),
  ('55555555-5555-5555-5555-555555555555', 'Jonesh Casio'),
  ('66666666-6666-6666-6666-666666666666', 'TVH'),
  ('77777777-7777-7777-7777-777777777777', 'TCH')
on conflict (id) do update set name = excluded.name;


-- ============================================================
-- NEXT STEP — seed your super admin
-- ============================================================
-- After running this schema, start the backend and run:
--   npm run seed:super-admin
--
-- Or manually:
--   insert into public.users  (name, role)          values ('Your Name', 'super_admin') returning id;
--   insert into public.auth_accounts (user_id, email, password_hash) values ('<id above>', 'you@email.com', '<bcrypt hash>');
-- ============================================================
