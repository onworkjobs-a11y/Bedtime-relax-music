-- ไพรนิทรา: tables, row-level security and storage for cloud sync.
-- Every row and file belongs to the signed-in user; nobody else can read or change it.

create table if not exists public.media (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  kind        text not null check (kind in ('song','image')),
  name        text not null check (char_length(name) between 1 and 200),
  path        text not null unique,
  duration    real,
  size_bytes  bigint,
  enabled     boolean not null default true,
  created_at  timestamptz not null default now()
);
create index if not exists media_user_idx on public.media(user_id, created_at);
alter table public.media enable row level security;

create table if not exists public.sleep_sessions (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null default auth.uid() references auth.users(id) on delete cascade,
  started_at        timestamptz not null,
  ended_at          timestamptz,
  stress_level      smallint not null check (stress_level between 1 and 10),
  listened_seconds  integer not null default 0 check (listened_seconds >= 0),
  tracks            text[] not null default '{}',
  ended_by          text check (ended_by in ('timer','pause')),
  created_at        timestamptz not null default now()
);
create index if not exists sleep_sessions_user_idx on public.sleep_sessions(user_id, started_at desc);
alter table public.sleep_sessions enable row level security;

do $$
declare t text;
begin
  foreach t in array array['media','sleep_sessions'] loop
    execute format('drop policy if exists "own rows select" on public.%I', t);
    execute format('drop policy if exists "own rows insert" on public.%I', t);
    execute format('drop policy if exists "own rows update" on public.%I', t);
    execute format('drop policy if exists "own rows delete" on public.%I', t);
    execute format('create policy "own rows select" on public.%I for select to authenticated using ((select auth.uid()) = user_id)', t);
    execute format('create policy "own rows insert" on public.%I for insert to authenticated with check ((select auth.uid()) = user_id)', t);
    execute format('create policy "own rows update" on public.%I for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)', t);
    execute format('create policy "own rows delete" on public.%I for delete to authenticated using ((select auth.uid()) = user_id)', t);
  end loop;
end $$;

-- Private bucket; files live at <user id>/<item id>.<ext>
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('media', 'media', false, 52428800, array['audio/*','image/*'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "media own files select" on storage.objects;
drop policy if exists "media own files insert" on storage.objects;
drop policy if exists "media own files update" on storage.objects;
drop policy if exists "media own files delete" on storage.objects;
create policy "media own files select" on storage.objects for select to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "media own files insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'media' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "media own files update" on storage.objects for update to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "media own files delete" on storage.objects for delete to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = (select auth.uid())::text);
