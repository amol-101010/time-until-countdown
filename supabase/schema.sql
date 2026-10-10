-- Dash cloud sync schema.
-- Run this in your Supabase project's SQL editor (Project > SQL Editor > New query).
-- Safe to re-run: uses IF NOT EXISTS / DROP ... IF EXISTS before re-creating.

create table if not exists public.events (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  color_value integer not null,
  icon_code_point integer,
  is_built_in boolean not null default false,
  is_recurring boolean not null,
  granularity text not null,
  shape text not null,
  recurrence_frequency text,
  recurrence_days_of_week text,
  recurrence_cycle_start_minutes integer,
  recurrence_cycle_end_minutes integer,
  start_date timestamptz,
  end_date timestamptz,
  reminders_enabled boolean not null default false,
  reminder_time_minutes integer,
  reminder_date_time timestamptz,
  reminder_repeat_frequency text,
  tag text,
  group_name text,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Safety net for re-running this script against a table created by an
-- earlier version of this file (CREATE TABLE IF NOT EXISTS above won't add
-- columns to an already-existing table).
alter table public.events add column if not exists reminders_enabled boolean not null default false;
alter table public.events add column if not exists reminder_time_minutes integer;
alter table public.events add column if not exists reminder_date_time timestamptz;
alter table public.events add column if not exists reminder_repeat_frequency text;
alter table public.events add column if not exists tag text;
alter table public.events add column if not exists group_name text;

-- Column comments, mirroring lib/data/persistence/database.dart's Events table.
comment on column public.events.id is 'Same uuid as the local drift row id (client-generated).';
comment on column public.events.updated_at is 'Last-write-wins conflict resolution timestamp.';
comment on column public.events.deleted_at is 'Soft-delete tombstone so deletes propagate to other devices instead of just disappearing.';

-- Keep sync queries (pull-by-user, ordering by updated_at) fast.
create index if not exists events_user_id_idx on public.events (user_id);
create index if not exists events_updated_at_idx on public.events (updated_at);

alter table public.events enable row level security;

drop policy if exists "Users manage their own events" on public.events;
create policy "Users manage their own events"
  on public.events
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Realtime: lets the app's sync engine subscribe to live changes via
-- supabase.from('events').stream(...). Supabase projects created after
-- ~2023 have the `supabase_realtime` publication by default; this adds the
-- table to it (no-op if already present).
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'events'
  ) then
    alter publication supabase_realtime add table public.events;
  end if;
end $$;

-- Groups (schema v8 locally - see lib/models/event_group.dart). Keyed by
-- (user_id, name) rather than a surrogate id: group names are already the
-- join key every events.group_name uses, and there's no rename feature
-- yet that would need that key to change under an existing row.
create table if not exists public.groups (
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  icon_code_point integer,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  primary key (user_id, name)
);

comment on column public.groups.name is 'Matches events.group_name for this user - the join key.';
comment on column public.groups.updated_at is 'Last-write-wins conflict resolution timestamp.';
comment on column public.groups.deleted_at is 'Soft-delete tombstone so deletes propagate to other devices instead of just disappearing.';

create index if not exists groups_user_id_idx on public.groups (user_id);

alter table public.groups enable row level security;

drop policy if exists "Users manage their own groups" on public.groups;
create policy "Users manage their own groups"
  on public.groups
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'groups'
  ) then
    alter publication supabase_realtime add table public.groups;
  end if;
end $$;
