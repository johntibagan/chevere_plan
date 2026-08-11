-- Ciclo 8+: keywords GIN index (categorías en seed 000002 simplificado).
-- Idempotente: no reintroduce el árbol antiguo.

alter table public.categories
  add column if not exists keywords text[] not null default '{}'::text[];

create index if not exists categories_keywords_gin
  on public.categories using gin (keywords);
