-- Floor Plan Evaluator — database schema
-- Run this once in your Supabase project's SQL Editor (Dashboard → SQL Editor → New query).

create extension if not exists pgcrypto;

-- One row per partner, keyed to their Supabase Auth account.
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  color text not null default '#3366FF',
  created_at timestamptz not null default now()
);

create table public.floor_plans (
  id uuid primary key default gen_random_uuid(),
  url text not null,
  title text not null,
  source_label text,
  notes text,
  sqft integer,
  bedrooms smallint,
  bathrooms numeric(3,1),
  garage_spaces smallint,
  image_url text,
  created_by uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.floor_plan_ratings (
  id uuid primary key default gen_random_uuid(),
  floor_plan_id uuid not null references public.floor_plans(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  stars smallint not null check (stars between 1 and 5),
  updated_at timestamptz not null default now(),
  unique (floor_plan_id, user_id)
);

create table public.floor_plan_notes (
  id uuid primary key default gen_random_uuid(),
  floor_plan_id uuid not null references public.floor_plans(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null check (kind in ('like', 'dislike')),
  body text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.floor_plans enable row level security;
alter table public.floor_plan_ratings enable row level security;
alter table public.floor_plan_notes enable row level security;

-- profiles: both of you can see each other; you can only create/edit your own row.
create policy "profiles_select" on public.profiles for select to authenticated using (true);
create policy "profiles_insert_own" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "profiles_update_own" on public.profiles for update to authenticated using (id = auth.uid());

-- floor_plans: shared list — either of you can read, add, edit, or remove any entry.
create policy "floor_plans_select" on public.floor_plans for select to authenticated using (true);
create policy "floor_plans_insert" on public.floor_plans for insert to authenticated with check (created_by = auth.uid());
create policy "floor_plans_update" on public.floor_plans for update to authenticated using (true);
create policy "floor_plans_delete" on public.floor_plans for delete to authenticated using (true);

-- ratings: both of you can see all ratings; you can only write your own.
create policy "ratings_select" on public.floor_plan_ratings for select to authenticated using (true);
create policy "ratings_insert_own" on public.floor_plan_ratings for insert to authenticated with check (user_id = auth.uid());
create policy "ratings_update_own" on public.floor_plan_ratings for update to authenticated using (user_id = auth.uid());
create policy "ratings_delete_own" on public.floor_plan_ratings for delete to authenticated using (user_id = auth.uid());

-- notes (likes/dislikes): both of you can see all notes; you can only add/remove your own.
create policy "notes_select" on public.floor_plan_notes for select to authenticated using (true);
create policy "notes_insert_own" on public.floor_plan_notes for insert to authenticated with check (user_id = auth.uid());
create policy "notes_delete_own" on public.floor_plan_notes for delete to authenticated using (user_id = auth.uid());

-- Turn on realtime so you each see the other's ratings/notes show up live.
alter publication supabase_realtime add table
  public.profiles,
  public.floor_plans,
  public.floor_plan_ratings,
  public.floor_plan_notes;
