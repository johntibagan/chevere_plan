-- Permitir reportar reseñas públicas (target_type = review).

alter table public.content_reports
  drop constraint if exists content_reports_target_type_check;

alter table public.content_reports
  add constraint content_reports_target_type_check
  check (
    target_type = any (
      array[
        'photo'::text,
        'site'::text,
        'profile'::text,
        'event'::text,
        'review'::text
      ]
    )
  );

drop function if exists public.list_open_content_reports();

create or replace function public.list_open_content_reports()
returns table (
  report_id uuid,
  target_type text,
  target_id uuid,
  reason text,
  status text,
  created_at timestamp with time zone,
  reporter_id uuid,
  reporter_name text,
  photo_path text,
  site_name text,
  snippet text
)
language sql
stable
security definer
set search_path to 'public'
as $function$
  select
    r.id as report_id,
    r.target_type,
    r.target_id,
    r.reason,
    r.status,
    r.created_at,
    r.reporter_id,
    coalesce(pr.display_name, 'Usuario') as reporter_name,
    coalesce(ph.storage_path, null) as photo_path,
    coalesce(s_photo.name, s_review.name) as site_name,
    case
      when r.target_type = 'review' then left(trim(coalesce(rev.body, '')), 160)
      else null
    end as snippet
  from public.content_reports r
  join public.profiles pr on pr.id = r.reporter_id
  left join public.site_photos ph
    on r.target_type = 'photo' and ph.id = r.target_id
  left join public.sites s_photo on s_photo.id = ph.site_id
  left join public.site_reviews rev
    on r.target_type = 'review' and rev.id = r.target_id
  left join public.sites s_review on s_review.id = rev.site_id
  where public.is_staff()
    and r.status = 'open'
  order by r.created_at desc
  limit 200;
$function$;

grant execute on function public.list_open_content_reports() to anon, authenticated, service_role;
