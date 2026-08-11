-- Listar categorías (raíz) y subcategorías desde public.categories.
-- Ejecutar en: Supabase Dashboard → SQL Editor (o psql).

-- ─── Árbol: categoría → subcategoría ───────────────────────────────
select
  p.sort_order as cat_order,
  p.slug as category_slug,
  coalesce(p.name_i18n->>'es', p.slug) as category_name,
  p.is_active as category_active,
  c.sort_order as sub_order,
  c.slug as subcategory_slug,
  coalesce(c.name_i18n->>'es', c.slug) as subcategory_name,
  c.is_active as subcategory_active,
  c.age_restricted,
  c.keywords,
  p.id as category_id,
  c.id as subcategory_id
from public.categories p
left join public.categories c
  on c.parent_id = p.id
where p.parent_id is null
order by p.sort_order, p.slug, c.sort_order nulls last, c.slug;

-- ─── Resumen por categoría raíz ────────────────────────────────────
select
  coalesce(p.name_i18n->>'es', p.slug) as category_name,
  p.slug,
  p.is_active,
  count(c.id) as subcategory_count
from public.categories p
left join public.categories c
  on c.parent_id = p.id
where p.parent_id is null
group by p.id, p.name_i18n, p.slug, p.is_active, p.sort_order
order by p.sort_order, p.slug;

-- ─── Solo raíces (sin hijos) ───────────────────────────────────────
-- select
--   sort_order,
--   slug,
--   name_i18n->>'es' as name_es,
--   is_active,
--   keywords
-- from public.categories
-- where parent_id is null
-- order by sort_order, slug;

-- ─── Solo subcategorías de una raíz (cambia el slug) ───────────────
-- select
--   c.sort_order,
--   c.slug,
--   c.name_i18n->>'es' as name_es,
--   c.is_active,
--   c.age_restricted,
--   c.keywords
-- from public.categories c
-- join public.categories p on p.id = c.parent_id
-- where p.slug = 'gastronomia'
-- order by c.sort_order, c.slug;
