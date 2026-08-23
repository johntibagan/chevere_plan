-- Esquema inicial Chevere Plan (estado actual consolidado).
-- Idempotente para reset --full. No incluye datos de DIVIPOLA ni catálogo masivo.

-- Chevere Plan baseline dump (app objects only)
create extension if not exists postgis;
create extension if not exists pg_trgm;
create extension if not exists pgcrypto;

do $$ begin create type public.app_role as enum ('user', 'admin', 'root'); exception when duplicate_object then null; end $$;
do $$ begin create type public.photo_source as enum ('google_places', 'user'); exception when duplicate_object then null; end $$;
do $$ begin create type public.plan_status as enum ('draft', 'active', 'done'); exception when duplicate_object then null; end $$;
do $$ begin create type public.site_status as enum ('draft', 'pending_location', 'complete'); exception when duplicate_object then null; end $$;
do $$ begin create type public.transport_group as enum ('particular', 'publico', 'otro'); exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id uuid not null,
  display_name text,
  avatar_url text,
  role app_role default 'user'::app_role not null,
  birth_date date,
  preferred_locale text default 'es'::text not null,
  preferred_currency character(3) default 'COP'::bpchar not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  proximity_radius_m integer default 200 not null,
  remind_public_sites boolean default false not null,
  transport_max_km jsonb default '{}'::jsonb not null,
  constraint profiles_proximity_radius_m_check CHECK (((proximity_radius_m >= 100) AND (proximity_radius_m <= 2000))),
  constraint profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE,
  constraint profiles_pkey PRIMARY KEY (id)
);

create table if not exists public.categories (
  id uuid default gen_random_uuid() not null,
  parent_id uuid,
  slug text not null,
  name_i18n jsonb default '{}'::jsonb not null,
  is_active boolean default true not null,
  age_restricted boolean default false not null,
  sort_order integer default 0 not null,
  icon_key text,
  color_hex text,
  keywords text[] default '{}'::text[] not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  constraint categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE RESTRICT,
  constraint categories_pkey PRIMARY KEY (id),
  constraint categories_parent_id_slug_key UNIQUE (parent_id, slug)
);

create table if not exists public.transport_types (
  id uuid default gen_random_uuid() not null,
  transport_group transport_group not null,
  slug text not null,
  name_i18n jsonb default '{}'::jsonb not null,
  default_max_km numeric(8,2),
  is_active boolean default true not null,
  sort_order integer default 0 not null,
  icon_key text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  constraint transport_types_pkey PRIMARY KEY (id),
  constraint transport_types_slug_key UNIQUE (slug)
);

create table if not exists public.countries (
  code character(2) not null,
  name text not null,
  is_active boolean default true not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  constraint countries_pkey PRIMARY KEY (code)
);

create table if not exists public.departments (
  id uuid default gen_random_uuid() not null,
  country_code character(2) not null,
  code text not null,
  name text not null,
  name_norm text not null,
  is_active boolean default true not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  constraint departments_country_code_fkey FOREIGN KEY (country_code) REFERENCES countries(code) ON DELETE RESTRICT,
  constraint departments_pkey PRIMARY KEY (id),
  constraint departments_country_code_code_key UNIQUE (country_code, code)
);

create table if not exists public.cities (
  id uuid default gen_random_uuid() not null,
  department_id uuid not null,
  code text not null,
  name text not null,
  name_norm text not null,
  kind text,
  is_active boolean default true not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  constraint cities_department_id_fkey FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
  constraint cities_pkey PRIMARY KEY (id),
  constraint cities_department_id_code_key UNIQUE (department_id, code)
);

create table if not exists public.sites (
  id uuid default gen_random_uuid() not null,
  name text not null,
  status site_status default 'draft'::site_status not null,
  is_public boolean default false not null,
  is_physical_place boolean default true not null,
  location geography(Point,4326),
  address_line text,
  city text,
  department text,
  country_code character(2) default 'CO'::bpchar not null,
  estimated_price_amount numeric(12,2),
  currency_code character(3) default 'COP'::bpchar not null,
  created_by uuid,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  department_id uuid,
  city_id uuid,
  external_id text,
  google_place_id text,
  constraint sites_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL,
  constraint sites_created_by_fkey FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL,
  constraint sites_department_id_fkey FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
  constraint sites_pkey PRIMARY KEY (id),
  constraint sites_external_id_key UNIQUE (external_id)
);

create table if not exists public.site_categories (
  site_id uuid not null,
  category_id uuid not null,
  added_by uuid,
  created_at timestamp with time zone default now() not null,
  constraint site_categories_added_by_fkey FOREIGN KEY (added_by) REFERENCES profiles(id) ON DELETE SET NULL,
  constraint site_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  constraint site_categories_site_id_fkey FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
  constraint site_categories_pkey PRIMARY KEY (site_id, category_id)
);

create table if not exists public.site_contributors (
  site_id uuid not null,
  user_id uuid not null,
  created_at timestamp with time zone default now() not null,
  constraint site_contributors_site_id_fkey FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
  constraint site_contributors_user_id_fkey FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint site_contributors_pkey PRIMARY KEY (site_id, user_id)
);

create table if not exists public.site_photos (
  id uuid default gen_random_uuid() not null,
  site_id uuid not null,
  storage_path text not null,
  source photo_source default 'user'::photo_source not null,
  uploaded_by uuid,
  sort_order integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  constraint site_photos_site_id_fkey FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
  constraint site_photos_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES profiles(id) ON DELETE SET NULL,
  constraint site_photos_pkey PRIMARY KEY (id)
);

create table if not exists public.site_social_links (
  id uuid default gen_random_uuid() not null,
  site_id uuid not null,
  url text not null,
  network text,
  title text,
  description text,
  image_url text,
  sort_order integer default 0 not null,
  added_by uuid,
  created_at timestamp with time zone default now() not null,
  constraint site_social_links_added_by_fkey FOREIGN KEY (added_by) REFERENCES profiles(id) ON DELETE SET NULL,
  constraint site_social_links_site_id_fkey FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
  constraint site_social_links_pkey PRIMARY KEY (id),
  constraint site_social_links_site_id_url_key UNIQUE (site_id, url)
);

create table if not exists public.user_saves (
  id uuid default gen_random_uuid() not null,
  user_id uuid not null,
  site_id uuid not null,
  status site_status default 'draft'::site_status not null,
  is_public boolean default false not null,
  source_url text,
  source_network text,
  notes text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  draft_remind_at timestamp with time zone,
  last_draft_reminder_at timestamp with time zone,
  is_possible_duplicate boolean default false not null,
  possible_duplicate_of_site_id uuid,
  constraint user_saves_possible_duplicate_of_site_id_fkey FOREIGN KEY (possible_duplicate_of_site_id) REFERENCES sites(id) ON DELETE SET NULL,
  constraint user_saves_site_id_fkey FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
  constraint user_saves_user_id_fkey FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint user_saves_pkey PRIMARY KEY (id),
  constraint user_saves_user_id_site_id_key UNIQUE (user_id, site_id)
);

create table if not exists public.site_reviews (
  id uuid default gen_random_uuid() not null,
  site_id uuid not null,
  user_id uuid not null,
  body text default ''::text not null,
  rating smallint not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  is_public boolean default false not null,
  constraint site_reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5))),
  constraint site_reviews_site_id_fkey FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
  constraint site_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint site_reviews_pkey PRIMARY KEY (id)
);

create table if not exists public.site_review_photos (
  id uuid default gen_random_uuid() not null,
  review_id uuid not null,
  storage_path text not null,
  sort_order integer default 0 not null,
  uploaded_by uuid,
  created_at timestamp with time zone default now() not null,
  constraint site_review_photos_review_id_fkey FOREIGN KEY (review_id) REFERENCES site_reviews(id) ON DELETE CASCADE,
  constraint site_review_photos_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES profiles(id) ON DELETE SET NULL,
  constraint site_review_photos_pkey PRIMARY KEY (id)
);

create table if not exists public.plans (
  id uuid default gen_random_uuid() not null,
  user_id uuid not null,
  title text not null,
  location_query text not null,
  start_lat double precision,
  start_lng double precision,
  include_public boolean default false not null,
  max_budget_amount numeric(12,2),
  currency_code character(3) default 'COP'::bpchar not null,
  status plan_status default 'active'::plan_status not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  constraint plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint plans_pkey PRIMARY KEY (id)
);

create table if not exists public.plan_stops (
  id uuid default gen_random_uuid() not null,
  plan_id uuid not null,
  site_id uuid not null,
  sort_order integer default 0 not null,
  visited_at timestamp with time zone,
  estimated_price_amount numeric(12,2),
  lat double precision,
  lng double precision,
  created_at timestamp with time zone default now() not null,
  constraint plan_stops_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE,
  constraint plan_stops_site_id_fkey FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,
  constraint plan_stops_pkey PRIMARY KEY (id),
  constraint plan_stops_plan_id_site_id_key UNIQUE (plan_id, site_id)
);

create table if not exists public.content_reports (
  id uuid default gen_random_uuid() not null,
  reporter_id uuid not null,
  target_type text not null,
  target_id uuid not null,
  reason text,
  status text default 'open'::text not null,
  created_at timestamp with time zone default now() not null,
  constraint content_reports_status_check CHECK ((status = ANY (ARRAY['open'::text, 'reviewed'::text, 'dismissed'::text, 'actioned'::text]))),
  constraint content_reports_target_type_check CHECK ((target_type = ANY (ARRAY['photo'::text, 'site'::text, 'profile'::text, 'event'::text]))),
  constraint content_reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint content_reports_pkey PRIMARY KEY (id),
  constraint content_reports_reporter_id_target_type_target_id_key UNIQUE (reporter_id, target_type, target_id)
);

-- indexes (sin duplicar PK/UNIQUE de la tabla)
create index if not exists categories_keywords_gin ON public.categories USING gin (keywords);
create unique index if not exists categories_root_slug_uidx ON public.categories USING btree (slug) WHERE (parent_id IS NULL);
create index if not exists cities_department_name_idx ON public.cities USING btree (department_id, name);
create index if not exists content_reports_status_idx ON public.content_reports USING btree (status, created_at DESC);
create index if not exists content_reports_target_idx ON public.content_reports USING btree (target_type, target_id);
create index if not exists departments_country_name_idx ON public.departments USING btree (country_code, name);
create index if not exists plan_stops_plan_id_idx ON public.plan_stops USING btree (plan_id, sort_order);
create index if not exists plans_user_id_idx ON public.plans USING btree (user_id);
create index if not exists site_review_photos_review_id_idx ON public.site_review_photos USING btree (review_id, sort_order);
create index if not exists site_reviews_site_created_idx ON public.site_reviews USING btree (site_id, created_at DESC);
create index if not exists site_reviews_site_id_idx ON public.site_reviews USING btree (site_id, updated_at DESC);
create index if not exists site_reviews_site_rating_idx ON public.site_reviews USING btree (site_id, rating, created_at DESC);
create index if not exists site_social_links_site_id_idx ON public.site_social_links USING btree (site_id);
create index if not exists sites_city_id_idx ON public.sites USING btree (city_id);
create index if not exists sites_city_idx ON public.sites USING btree (city);
create index if not exists sites_department_id_idx ON public.sites USING btree (department_id);
create index if not exists sites_google_place_id_idx ON public.sites USING btree (google_place_id) WHERE (google_place_id IS NOT NULL);
create index if not exists sites_location_gix ON public.sites USING gist (location);

-- functions
CREATE OR REPLACE FUNCTION public.attach_save_to_existing_site(p_existing_site_id uuid, p_source_url text DEFAULT NULL::text, p_source_network text DEFAULT NULL::text, p_notes text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_public boolean;
  v_save_id uuid;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select s.is_public into v_public
  from public.sites s
  where s.id = p_existing_site_id;

  if v_public is distinct from true then
    raise exception 'existing site must be public';
  end if;

  insert into public.site_contributors (site_id, user_id)
  values (p_existing_site_id, uid)
  on conflict do nothing;

  insert into public.user_saves (
    user_id,
    site_id,
    status,
    is_public,
    source_url,
    source_network,
    notes,
    draft_remind_at,
    is_possible_duplicate,
    possible_duplicate_of_site_id
  )
  values (
    uid,
    p_existing_site_id,
    'complete',
    true,
    nullif(trim(p_source_url), ''),
    nullif(trim(p_source_network), ''),
    nullif(trim(p_notes), ''),
    null,
    true,
    p_existing_site_id
  )
  on conflict (user_id, site_id) do update
  set
    status = 'complete',
    is_public = true,
    source_url = coalesce(excluded.source_url, public.user_saves.source_url),
    source_network = coalesce(excluded.source_network, public.user_saves.source_network),
    notes = coalesce(excluded.notes, public.user_saves.notes),
    draft_remind_at = null,
    is_possible_duplicate = true,
    possible_duplicate_of_site_id = p_existing_site_id,
    updated_at = now()
  returning id into v_save_id;

  return v_save_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.clear_site_location(p_site_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  update public.sites
  set location = null, updated_at = now()
  where id = p_site_id
    and (created_by = auth.uid() or public.is_staff());

  update public.plan_stops
  set lat = null, lng = null
  where site_id = p_site_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.enforce_site_review_photo_limit()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  n int;
begin
  select count(*) into n from public.site_review_photos where review_id = new.review_id;
  if n >= 3 then
    raise exception 'max 3 photos per review';
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.find_possible_duplicate_sites(p_name text, p_lat double precision DEFAULT NULL::double precision, p_lng double precision DEFAULT NULL::double precision, p_city text DEFAULT NULL::text, p_radius_m double precision DEFAULT 100, p_exclude_site_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(site_id uuid, site_name text, city text, distance_m double precision, name_score real, contributor_count bigint)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  with candidates as (
    select
      s.id,
      s.name,
      s.city,
      case
        when p_lat is not null and p_lng is not null and s.location is not null then
          st_distance(
            s.location,
            st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
          )
        else null
      end as dist_m,
      greatest(
        similarity(lower(s.name), lower(p_name)),
        word_similarity(lower(p_name), lower(s.name))
      ) as score
    from public.sites s
    where s.is_public = true
      and s.is_physical_place = true
      and s.status = 'complete'
      and (p_exclude_site_id is null or s.id <> p_exclude_site_id)
      and (
        (
          p_lat is not null and p_lng is not null and s.location is not null
          and (
            (
              st_dwithin(
                s.location,
                st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
                p_radius_m
              )
              and similarity(lower(s.name), lower(p_name)) >= 0.35
            )
            or (
              -- Parques / nombres largos: radio mayor si el nombre es claramente similar
              st_dwithin(
                s.location,
                st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
                greatest(p_radius_m, 800)
              )
              and (
                similarity(lower(s.name), lower(p_name)) >= 0.45
                or word_similarity(lower(p_name), lower(s.name)) >= 0.5
              )
            )
          )
        )
        or (
          (p_lat is null or p_lng is null or s.location is null)
          and p_city is not null and length(trim(p_city)) > 0
          and s.city ilike trim(p_city)
          and (
            similarity(lower(s.name), lower(p_name)) >= 0.45
            or word_similarity(lower(p_name), lower(s.name)) >= 0.5
          )
        )
      )
  )
  select
    c.id,
    c.name,
    c.city,
    c.dist_m,
    c.score,
    (
      select count(*) from public.site_contributors sc where sc.site_id = c.id
    ) + 1
  from candidates c
  order by c.score desc nulls last, c.dist_m asc nulls last
  limit 10;
$function$;

CREATE OR REPLACE FUNCTION public.get_site_coords(p_site_id uuid)
 RETURNS TABLE(lat double precision, lng double precision)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    st_y(location::geometry) as lat,
    st_x(location::geometry) as lng
  from public.sites
  where id = p_site_id
    and location is not null
    and (
      created_by = auth.uid()
      or is_public = true
      or public.is_staff()
      or exists (
        select 1 from public.user_saves us
        where us.site_id = p_site_id and us.user_id = auth.uid()
      )
    );
$function$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', new.email),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.is_staff()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('admin', 'root')
  );
$function$;

CREATE OR REPLACE FUNCTION public.link_save_to_existing_site(p_save_id uuid, p_existing_site_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_old_site uuid;
  v_existing_public boolean;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select us.site_id into v_old_site
  from public.user_saves us
  where us.id = p_save_id and us.user_id = uid;

  if v_old_site is null then
    raise exception 'save not found';
  end if;

  select s.is_public into v_existing_public
  from public.sites s
  where s.id = p_existing_site_id;

  if v_existing_public is distinct from true then
    raise exception 'existing site must be public';
  end if;

  if v_old_site = p_existing_site_id then
    update public.user_saves
    set
      is_public = true,
      status = 'complete',
      is_possible_duplicate = true,
      possible_duplicate_of_site_id = p_existing_site_id,
      updated_at = now()
    where id = p_save_id and user_id = uid;
    return p_existing_site_id;
  end if;

  insert into public.site_contributors (site_id, user_id)
  values (p_existing_site_id, uid)
  on conflict do nothing;

  update public.plan_stops ps
  set site_id = p_existing_site_id
  from public.plans p
  where ps.plan_id = p.id
    and p.user_id = uid
    and ps.site_id = v_old_site
    and not exists (
      select 1 from public.plan_stops x
      where x.plan_id = ps.plan_id and x.site_id = p_existing_site_id
    );

  delete from public.plan_stops ps
  using public.plans p
  where ps.plan_id = p.id
    and p.user_id = uid
    and ps.site_id = v_old_site;

  update public.user_saves
  set
    site_id = p_existing_site_id,
    is_public = true,
    status = 'complete',
    is_possible_duplicate = true,
    possible_duplicate_of_site_id = p_existing_site_id,
    updated_at = now()
  where id = p_save_id and user_id = uid;

  if exists (
    select 1 from public.sites s
    where s.id = v_old_site and s.created_by = uid
  )
  and not exists (select 1 from public.user_saves where site_id = v_old_site)
  and not exists (select 1 from public.site_contributors where site_id = v_old_site)
  and not exists (select 1 from public.plan_stops where site_id = v_old_site)
  then
    delete from public.sites where id = v_old_site and created_by = uid;
  end if;

  return p_existing_site_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.list_my_route_history()
 RETURNS TABLE(stop_id uuid, plan_id uuid, plan_title text, site_id uuid, site_name text, city text, visited_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    ps.id as stop_id,
    p.id as plan_id,
    p.title as plan_title,
    s.id as site_id,
    s.name as site_name,
    s.city,
    ps.visited_at
  from public.plan_stops ps
  join public.plans p on p.id = ps.plan_id
  join public.sites s on s.id = ps.site_id
  where p.user_id = auth.uid()
    and ps.visited_at is not null
  order by ps.visited_at desc
  limit 200;
$function$;

CREATE OR REPLACE FUNCTION public.list_open_content_reports()
 RETURNS TABLE(report_id uuid, target_type text, target_id uuid, reason text, status text, created_at timestamp with time zone, reporter_id uuid, reporter_name text, photo_path text, site_name text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    r.id as report_id,
    r.target_type,
    r.target_id,
    r.reason,
    r.status,
    r.created_at,
    r.reporter_id,
    coalesce(pr.display_name, 'Usuario') as reporter_name,
    ph.storage_path as photo_path,
    s.name as site_name
  from public.content_reports r
  join public.profiles pr on pr.id = r.reporter_id
  left join public.site_photos ph
    on r.target_type = 'photo' and ph.id = r.target_id
  left join public.sites s on s.id = ph.site_id
  where public.is_staff()
    and r.status = 'open'
  order by r.created_at desc
  limit 200;
$function$;

CREATE OR REPLACE FUNCTION public.list_plan_candidates(p_location_query text, p_include_public boolean DEFAULT false, p_max_budget numeric DEFAULT NULL::numeric)
 RETURNS TABLE(site_id uuid, name text, city text, department text, lat double precision, lng double precision, estimated_price_amount numeric, currency_code character)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with q as (
    select trim(both from coalesce(p_location_query, '')) as loc
  ),
  own as (
    select
      s.id as site_id,
      s.name,
      s.city,
      s.department,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      s.estimated_price_amount,
      s.currency_code
    from public.user_saves us
    join public.sites s on s.id = us.site_id
    cross join q
    where us.user_id = auth.uid()
      and us.status = 'complete'
      and s.location is not null
      and q.loc <> ''
      and (
        s.city ilike '%' || q.loc || '%'
        or s.department ilike '%' || q.loc || '%'
      )
      and (
        p_max_budget is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount <= p_max_budget
      )
  ),
  pub as (
    select
      s.id as site_id,
      s.name,
      s.city,
      s.department,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      s.estimated_price_amount,
      s.currency_code
    from public.sites s
    cross join q
    where p_include_public = true
      and s.is_public = true
      and s.location is not null
      and q.loc <> ''
      and (
        s.city ilike '%' || q.loc || '%'
        or s.department ilike '%' || q.loc || '%'
      )
      and (
        p_max_budget is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount <= p_max_budget
      )
      and s.id not in (select own.site_id from own)
  )
  select * from own
  union all
  select * from pub;
$function$;

CREATE OR REPLACE FUNCTION public.list_proximity_sites(p_include_public boolean DEFAULT false)
 RETURNS TABLE(site_id uuid, name text, lat double precision, lng double precision, is_own boolean)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with own_sites as (
    select
      s.id as site_id,
      s.name,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      true as is_own
    from public.user_saves us
    join public.sites s on s.id = us.site_id
    where us.user_id = auth.uid()
      and us.status = 'complete'
      and s.location is not null
  ),
  public_sites as (
    select
      s.id as site_id,
      s.name,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      false as is_own
    from public.sites s
    where p_include_public = true
      and s.is_public = true
      and s.location is not null
      and s.id not in (select own_sites.site_id from own_sites)
  )
  select * from own_sites
  union all
  select * from public_sites;
$function$;

CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if new.role is distinct from old.role then
    -- Dashboard SQL Editor / service role: auth.uid() es null → permitir bootstrap
    if auth.uid() is null then
      return new;
    end if;
    if not public.is_staff() then
      raise exception 'Solo admin/root pueden cambiar roles';
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.search_sites(p_query text DEFAULT NULL::text, p_category_id uuid DEFAULT NULL::uuid, p_location_query text DEFAULT NULL::text, p_lat double precision DEFAULT NULL::double precision, p_lng double precision DEFAULT NULL::double precision, p_radius_km double precision DEFAULT NULL::double precision, p_transport_group text DEFAULT NULL::text, p_budget_min numeric DEFAULT NULL::numeric, p_budget_max numeric DEFAULT NULL::numeric, p_include_public boolean DEFAULT false)
 RETURNS TABLE(site_id uuid, name text, city text, department text, lat double precision, lng double precision, estimated_price_amount numeric, currency_code text, is_own boolean, is_public boolean, is_catalog boolean, is_linked boolean, updated_at timestamp with time zone, distance_km double precision)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_is_minor boolean := false;
  v_max_km numeric;
  v_group public.transport_group;
begin
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.birth_date is not null
      and p.birth_date > (current_date - interval '18 years')
  ) into v_is_minor;

  if p_transport_group is not null and trim(p_transport_group) <> '' then
    begin
      v_group := trim(p_transport_group)::public.transport_group;
    exception when others then
      v_group := null;
    end;

    if v_group is not null then
      select
        case when bool_or(t.default_max_km is null) then null
             else max(t.default_max_km)
        end
      into v_max_km
      from public.transport_types t
      where t.is_active
        and t.transport_group = v_group;
    end if;
  end if;

  return query
  with base as (
    select
      s.id as sid,
      s.name as sname,
      s.city as scity,
      s.department as sdepartment,
      st_y(s.location::geometry) as slat,
      st_x(s.location::geometry) as slng,
      s.estimated_price_amount as sprice,
      s.currency_code::text as scurrency,
      s.is_public as spublic,
      (s.external_id is not null and length(trim(s.external_id)) > 0) as scatalog,
      exists (
        select 1 from public.user_saves us
        where us.site_id = s.id
          and us.user_id = auth.uid()
          and us.status = 'complete'
      ) as sown,
      exists (
        select 1 from public.user_saves us
        where us.site_id = s.id
          and us.user_id = auth.uid()
          and us.is_possible_duplicate = true
      ) as slinked,
      s.updated_at as supdated,
      case
        when p_lat is not null and p_lng is not null and s.location is not null then
          st_distance(
            s.location,
            st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
          ) / 1000.0
        else null::double precision
      end as sdistance_km
    from public.sites s
    where s.location is not null
      and s.status = 'complete'
      and (
        exists (
          select 1 from public.user_saves us
          where us.site_id = s.id
            and us.user_id = auth.uid()
            and us.status = 'complete'
        )
        or (p_include_public and s.is_public)
      )
      and (
        p_query is null or trim(p_query) = ''
        or s.name ilike '%' || trim(p_query) || '%'
        or coalesce(s.city, '') ilike '%' || trim(p_query) || '%'
        or coalesce(s.department, '') ilike '%' || trim(p_query) || '%'
      )
      and (
        p_location_query is null or trim(p_location_query) = ''
        or coalesce(s.city, '') ilike '%' || trim(p_location_query) || '%'
        or coalesce(s.department, '') ilike '%' || trim(p_location_query) || '%'
      )
      and (
        p_budget_min is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount >= p_budget_min
      )
      and (
        p_budget_max is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount <= p_budget_max
      )
      and (
        p_category_id is null
        or exists (
          select 1
          from public.site_categories sc
          join public.categories c on c.id = sc.category_id
          where sc.site_id = s.id
            and (
              c.id = p_category_id
              or c.parent_id = p_category_id
            )
        )
      )
      and (
        not v_is_minor
        or not exists (
          select 1
          from public.site_categories sc
          join public.categories c on c.id = sc.category_id
          where sc.site_id = s.id and c.age_restricted = true
        )
      )
      and (
        p_lat is null or p_lng is null or p_radius_km is null
        or st_dwithin(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          p_radius_km * 1000.0
        )
      )
      and (
        v_group is null
        or p_lat is null
        or p_lng is null
        or v_max_km is null
        or st_dwithin(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          v_max_km * 1000.0
        )
      )
  )
  select
    b.sid,
    b.sname,
    b.scity,
    b.sdepartment,
    b.slat,
    b.slng,
    b.sprice,
    b.scurrency,
    b.sown,
    b.spublic,
    b.scatalog,
    b.slinked,
    b.supdated,
    b.sdistance_km
  from base b
  order by
    case when b.sdistance_km is null then 1 else 0 end,
    b.sdistance_km nulls last,
    b.sname
  limit 100;
end;
$function$;

CREATE OR REPLACE FUNCTION public.set_site_location(p_site_id uuid, p_lng double precision, p_lat double precision)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if auth.uid() is null then
    raise exception 'No autenticado';
  end if;
  update public.sites
  set location = st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
      updated_at = now()
  where id = p_site_id
    and (created_by = auth.uid() or public.is_staff());
end;
$function$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.site_privacy_blockers(p_site_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_other_saves bigint := 0;
  v_other_contrib bigint := 0;
  v_other_plans bigint := 0;
  v_catalog boolean := false;
  v_allowed boolean := false;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select
    public.is_staff()
    or s.created_by = uid
    or exists (
      select 1 from public.user_saves us
      where us.site_id = s.id and us.user_id = uid
    )
  into v_allowed
  from public.sites s
  where s.id = p_site_id;

  if not coalesce(v_allowed, false) then
    raise exception 'forbidden';
  end if;

  select (s.external_id is not null and length(trim(s.external_id)) > 0)
  into v_catalog
  from public.sites s
  where s.id = p_site_id;

  select count(*) into v_other_saves
  from public.user_saves us
  where us.site_id = p_site_id and us.user_id <> uid;

  select count(*) into v_other_contrib
  from public.site_contributors sc
  where sc.site_id = p_site_id and sc.user_id <> uid;

  select count(*) into v_other_plans
  from public.plan_stops ps
  join public.plans p on p.id = ps.plan_id
  where ps.site_id = p_site_id and p.user_id <> uid;

  return json_build_object(
    'is_catalog', coalesce(v_catalog, false),
    'other_saves', v_other_saves,
    'other_contributors', v_other_contrib,
    'other_plan_stops', v_other_plans,
    'blocked',
      coalesce(v_catalog, false)
      or v_other_saves > 0
      or v_other_contrib > 0
      or v_other_plans > 0
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.site_rating_summary(p_site_id uuid)
 RETURNS json
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select json_build_object(
    'avg_rating', coalesce(round(avg(rating)::numeric, 1), 0),
    'review_count', count(*)
  )
  from public.site_reviews
  where site_id = p_site_id
    and is_public = true;
$function$;

-- triggers
drop trigger if exists categories_set_updated_at on public.categories;
create trigger categories_set_updated_at before update on public.categories
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists cities_set_updated_at on public.cities;
create trigger cities_set_updated_at before update on public.cities
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists countries_set_updated_at on public.countries;
create trigger countries_set_updated_at before update on public.countries
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists departments_set_updated_at on public.departments;
create trigger departments_set_updated_at before update on public.departments
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists plans_set_updated_at on public.plans;
create trigger plans_set_updated_at before update on public.plans
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists profiles_prevent_role_escalation on public.profiles;
create trigger profiles_prevent_role_escalation before update on public.profiles
for each row EXECUTE FUNCTION prevent_role_escalation();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists site_review_photos_limit on public.site_review_photos;
create trigger site_review_photos_limit before insert on public.site_review_photos
for each row EXECUTE FUNCTION enforce_site_review_photo_limit();

drop trigger if exists site_reviews_set_updated_at on public.site_reviews;
create trigger site_reviews_set_updated_at before update on public.site_reviews
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists sites_set_updated_at on public.sites;
create trigger sites_set_updated_at before update on public.sites
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists transport_types_set_updated_at on public.transport_types;
create trigger transport_types_set_updated_at before update on public.transport_types
for each row EXECUTE FUNCTION set_updated_at();

drop trigger if exists user_saves_set_updated_at on public.user_saves;
create trigger user_saves_set_updated_at before update on public.user_saves
for each row EXECUTE FUNCTION set_updated_at();

-- rls
alter table public.categories enable row level security;
alter table public.cities enable row level security;
alter table public.content_reports enable row level security;
alter table public.countries enable row level security;
alter table public.departments enable row level security;
alter table public.plan_stops enable row level security;
alter table public.plans enable row level security;
alter table public.profiles enable row level security;
alter table public.site_categories enable row level security;
alter table public.site_contributors enable row level security;
alter table public.site_photos enable row level security;
alter table public.site_review_photos enable row level security;
alter table public.site_reviews enable row level security;
alter table public.site_social_links enable row level security;
alter table public.sites enable row level security;
alter table public.transport_types enable row level security;
alter table public.user_saves enable row level security;

-- policies
drop policy if exists categories_select_active_or_staff on public.categories;
create policy categories_select_active_or_staff on public.categories
  for select
  to authenticated using (((is_active = true) OR is_staff()));

drop policy if exists categories_staff_write on public.categories;
create policy categories_staff_write on public.categories
  for all
  to authenticated using (is_staff()) with check (is_staff());

drop policy if exists cities_select_active_or_staff on public.cities;
create policy cities_select_active_or_staff on public.cities
  for select
  to authenticated using (((is_active = true) OR is_staff()));

drop policy if exists cities_staff_write on public.cities;
create policy cities_staff_write on public.cities
  for all
  to authenticated using (is_staff()) with check (is_staff());

drop policy if exists content_reports_insert_own on public.content_reports;
create policy content_reports_insert_own on public.content_reports
  for insert
  to public with check ((reporter_id = auth.uid()));

drop policy if exists content_reports_select_own_or_staff on public.content_reports;
create policy content_reports_select_own_or_staff on public.content_reports
  for select
  to public using (((reporter_id = auth.uid()) OR is_staff()));

drop policy if exists content_reports_staff_update on public.content_reports;
create policy content_reports_staff_update on public.content_reports
  for update
  to public using (is_staff()) with check (is_staff());

drop policy if exists countries_select_active_or_staff on public.countries;
create policy countries_select_active_or_staff on public.countries
  for select
  to authenticated using (((is_active = true) OR is_staff()));

drop policy if exists countries_staff_write on public.countries;
create policy countries_staff_write on public.countries
  for all
  to authenticated using (is_staff()) with check (is_staff());

drop policy if exists departments_select_active_or_staff on public.departments;
create policy departments_select_active_or_staff on public.departments
  for select
  to authenticated using (((is_active = true) OR is_staff()));

drop policy if exists departments_staff_write on public.departments;
create policy departments_staff_write on public.departments
  for all
  to authenticated using (is_staff()) with check (is_staff());

drop policy if exists plan_stops_owner_all on public.plan_stops;
create policy plan_stops_owner_all on public.plan_stops
  for all
  to public using ((EXISTS ( SELECT 1
   FROM plans p
  WHERE ((p.id = plan_stops.plan_id) AND ((p.user_id = auth.uid()) OR is_staff()))))) with check ((EXISTS ( SELECT 1
   FROM plans p
  WHERE ((p.id = plan_stops.plan_id) AND ((p.user_id = auth.uid()) OR is_staff())))));

drop policy if exists plans_owner_all on public.plans;
create policy plans_owner_all on public.plans
  for all
  to public using (((user_id = auth.uid()) OR is_staff())) with check (((user_id = auth.uid()) OR is_staff()));

drop policy if exists profiles_select_own_or_staff on public.profiles;
create policy profiles_select_own_or_staff on public.profiles
  for select
  to authenticated using (((id = auth.uid()) OR is_staff()));

drop policy if exists profiles_select_public_contributors on public.profiles;
create policy profiles_select_public_contributors on public.profiles
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM (site_contributors sc
     JOIN sites s ON ((s.id = sc.site_id)))
  WHERE ((sc.user_id = profiles.id) AND (s.is_public = true)))));

drop policy if exists profiles_select_public_reviewers on public.profiles;
create policy profiles_select_public_reviewers on public.profiles
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM (site_reviews r
     JOIN sites s ON ((s.id = r.site_id)))
  WHERE ((r.user_id = profiles.id) AND (r.is_public = true) AND (s.is_public = true)))));

drop policy if exists profiles_select_public_site_creators on public.profiles;
create policy profiles_select_public_site_creators on public.profiles
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.created_by = profiles.id) AND (s.is_public = true)))));

drop policy if exists profiles_staff_update on public.profiles;
create policy profiles_staff_update on public.profiles
  for update
  to authenticated using (is_staff()) with check (is_staff());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update
  to authenticated using ((id = auth.uid())) with check ((id = auth.uid()));

drop policy if exists site_categories_select on public.site_categories;
create policy site_categories_select on public.site_categories
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_categories.site_id) AND (s.is_public OR (s.created_by = auth.uid()) OR is_staff())))));

drop policy if exists site_categories_write_own_or_staff on public.site_categories;
create policy site_categories_write_own_or_staff on public.site_categories
  for all
  to authenticated using ((is_staff() OR (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_categories.site_id) AND (s.created_by = auth.uid())))))) with check ((is_staff() OR (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_categories.site_id) AND (s.created_by = auth.uid()))))));

drop policy if exists site_contributors_delete on public.site_contributors;
create policy site_contributors_delete on public.site_contributors
  for delete
  to authenticated using (((user_id = auth.uid()) OR is_staff()));

drop policy if exists site_contributors_insert on public.site_contributors;
create policy site_contributors_insert on public.site_contributors
  for insert
  to authenticated with check (((user_id = auth.uid()) OR is_staff()));

drop policy if exists site_contributors_select on public.site_contributors;
create policy site_contributors_select on public.site_contributors
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_contributors.site_id) AND (s.is_public OR (s.created_by = auth.uid()) OR is_staff())))));

drop policy if exists site_photos_select on public.site_photos;
create policy site_photos_select on public.site_photos
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_photos.site_id) AND (s.is_public OR (s.created_by = auth.uid()) OR is_staff())))));

drop policy if exists site_photos_write on public.site_photos;
create policy site_photos_write on public.site_photos
  for all
  to authenticated using ((is_staff() OR (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_photos.site_id) AND (s.created_by = auth.uid())))))) with check ((is_staff() OR (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_photos.site_id) AND (s.created_by = auth.uid()))))));

drop policy if exists site_review_photos_select on public.site_review_photos;
create policy site_review_photos_select on public.site_review_photos
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM site_reviews r
  WHERE ((r.id = site_review_photos.review_id) AND ((r.user_id = auth.uid()) OR ((r.is_public = true) AND (EXISTS ( SELECT 1
           FROM sites s
          WHERE ((s.id = r.site_id) AND (s.is_public OR (s.created_by = auth.uid()) OR is_staff()))))))))));

drop policy if exists site_review_photos_write on public.site_review_photos;
create policy site_review_photos_write on public.site_review_photos
  for all
  to authenticated using ((EXISTS ( SELECT 1
   FROM site_reviews r
  WHERE ((r.id = site_review_photos.review_id) AND ((r.user_id = auth.uid()) OR (is_staff() AND (r.is_public = true))))))) with check ((EXISTS ( SELECT 1
   FROM site_reviews r
  WHERE ((r.id = site_review_photos.review_id) AND ((r.user_id = auth.uid()) OR (is_staff() AND (r.is_public = true)))))));

drop policy if exists site_reviews_delete on public.site_reviews;
create policy site_reviews_delete on public.site_reviews
  for delete
  to authenticated using (((user_id = auth.uid()) OR (is_staff() AND (is_public = true))));

drop policy if exists site_reviews_insert on public.site_reviews;
create policy site_reviews_insert on public.site_reviews
  for insert
  to authenticated with check (((user_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_reviews.site_id) AND (s.is_public OR (s.created_by = auth.uid()) OR is_staff()))))));

drop policy if exists site_reviews_select on public.site_reviews;
create policy site_reviews_select on public.site_reviews
  for select
  to authenticated using (((user_id = auth.uid()) OR ((is_public = true) AND (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_reviews.site_id) AND (s.is_public OR (s.created_by = auth.uid()) OR is_staff())))))));

drop policy if exists site_reviews_update on public.site_reviews;
create policy site_reviews_update on public.site_reviews
  for update
  to authenticated using (((user_id = auth.uid()) OR (is_staff() AND (is_public = true)))) with check (((user_id = auth.uid()) OR (is_staff() AND (is_public = true))));

drop policy if exists site_social_links_select on public.site_social_links;
create policy site_social_links_select on public.site_social_links
  for select
  to authenticated using ((EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_social_links.site_id) AND (s.is_public OR (s.created_by = auth.uid()) OR is_staff())))));

drop policy if exists site_social_links_write on public.site_social_links;
create policy site_social_links_write on public.site_social_links
  for all
  to authenticated using ((is_staff() OR (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_social_links.site_id) AND (s.created_by = auth.uid())))))) with check ((is_staff() OR (EXISTS ( SELECT 1
   FROM sites s
  WHERE ((s.id = site_social_links.site_id) AND (s.created_by = auth.uid()))))));

drop policy if exists sites_delete_own_unused on public.sites;
create policy sites_delete_own_unused on public.sites
  for delete
  to authenticated using (((created_by = auth.uid()) OR is_staff()));

drop policy if exists sites_insert_own on public.sites;
create policy sites_insert_own on public.sites
  for insert
  to authenticated with check ((created_by = auth.uid()));

drop policy if exists sites_select_public_or_owner_or_staff on public.sites;
create policy sites_select_public_or_owner_or_staff on public.sites
  for select
  to authenticated using (((is_public = true) OR (created_by = auth.uid()) OR is_staff()));

drop policy if exists sites_update_own_or_staff on public.sites;
create policy sites_update_own_or_staff on public.sites
  for update
  to authenticated using (((created_by = auth.uid()) OR is_staff())) with check (((created_by = auth.uid()) OR is_staff()));

drop policy if exists transport_select_active_or_staff on public.transport_types;
create policy transport_select_active_or_staff on public.transport_types
  for select
  to authenticated using (((is_active = true) OR is_staff()));

drop policy if exists transport_staff_write on public.transport_types;
create policy transport_staff_write on public.transport_types
  for all
  to authenticated using (is_staff()) with check (is_staff());

drop policy if exists user_saves_own on public.user_saves;
create policy user_saves_own on public.user_saves
  for all
  to authenticated using (((user_id = auth.uid()) OR is_staff())) with check (((user_id = auth.uid()) OR is_staff()));

-- grants
grant execute on function public.attach_save_to_existing_site(p_existing_site_id uuid, p_source_url text, p_source_network text, p_notes text) to anon, authenticated, service_role;
grant execute on function public.clear_site_location(p_site_id uuid) to anon, authenticated, service_role;
grant execute on function public.enforce_site_review_photo_limit() to anon, authenticated, service_role;
grant execute on function public.find_possible_duplicate_sites(p_name text, p_lat double precision, p_lng double precision, p_city text, p_radius_m double precision, p_exclude_site_id uuid) to anon, authenticated, service_role;
grant execute on function public.get_site_coords(p_site_id uuid) to anon, authenticated, service_role;
grant execute on function public.handle_new_user() to anon, authenticated, service_role;
grant execute on function public.is_staff() to anon, authenticated, service_role;
grant execute on function public.link_save_to_existing_site(p_save_id uuid, p_existing_site_id uuid) to anon, authenticated, service_role;
grant execute on function public.list_my_route_history() to anon, authenticated, service_role;
grant execute on function public.list_open_content_reports() to anon, authenticated, service_role;
grant execute on function public.list_plan_candidates(p_location_query text, p_include_public boolean, p_max_budget numeric) to anon, authenticated, service_role;
grant execute on function public.list_proximity_sites(p_include_public boolean) to anon, authenticated, service_role;
grant execute on function public.prevent_role_escalation() to anon, authenticated, service_role;
grant execute on function public.search_sites(p_query text, p_category_id uuid, p_location_query text, p_lat double precision, p_lng double precision, p_radius_km double precision, p_transport_group text, p_budget_min numeric, p_budget_max numeric, p_include_public boolean) to anon, authenticated, service_role;
grant execute on function public.set_site_location(p_site_id uuid, p_lng double precision, p_lat double precision) to anon, authenticated, service_role;
grant execute on function public.set_updated_at() to anon, authenticated, service_role;
grant execute on function public.site_privacy_blockers(p_site_id uuid) to anon, authenticated, service_role;
grant execute on function public.site_rating_summary(p_site_id uuid) to anon, authenticated, service_role;

grant usage on schema public to anon, authenticated, service_role;
grant all on all tables in schema public to postgres, service_role;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant select on all tables in schema public to anon;
grant usage, select on all sequences in schema public to anon, authenticated, service_role;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
