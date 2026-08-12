-- Generado por 05_sync_divipola.py desde datos.gov.co/resource/gdxc-w37w
-- Idempotente: upsert por código DIVIPOLA. Desactiva filas CO ausentes en esta corrida.

insert into public.countries (code, name) values ('CO', 'Colombia')
on conflict (code) do update set name = excluded.name, is_active = true;

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '05', 'Antioquia', 'antioquia', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '08', 'Atlántico', 'atlantico', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '11', 'Bogotá, D.C.', 'bogota, d.c.', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '13', 'Bolívar', 'bolivar', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '15', 'Boyacá', 'boyaca', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '17', 'Caldas', 'caldas', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '18', 'Caquetá', 'caqueta', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '19', 'Cauca', 'cauca', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '20', 'Cesar', 'cesar', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '23', 'Córdoba', 'cordoba', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '25', 'Cundinamarca', 'cundinamarca', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '27', 'Chocó', 'choco', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '41', 'Huila', 'huila', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '44', 'La Guajira', 'la guajira', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '47', 'Magdalena', 'magdalena', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '50', 'Meta', 'meta', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '52', 'Nariño', 'narino', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '54', 'Norte de Santander', 'norte de santander', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '63', 'Quindío', 'quindio', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '66', 'Risaralda', 'risaralda', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '68', 'Santander', 'santander', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '70', 'Sucre', 'sucre', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '73', 'Tolima', 'tolima', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '76', 'Valle del Cauca', 'valle del cauca', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '81', 'Arauca', 'arauca', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '85', 'Casanare', 'casanare', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '86', 'Putumayo', 'putumayo', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '88', 'Archipiélago de San Andrés, Providencia y Santa Catalina', 'archipielago de san andres, providencia y santa catalina', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '91', 'Amazonas', 'amazonas', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '94', 'Guainía', 'guainia', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '95', 'Guaviare', 'guaviare', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '97', 'Vaupés', 'vaupes', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

insert into public.departments (country_code, code, name, name_norm, is_active)
values ('CO', '99', 'Vichada', 'vichada', true)
on conflict (country_code, code) do update set name = excluded.name, name_norm = excluded.name_norm, is_active = true, updated_at = now();

update public.departments set is_active = false, updated_at = now() where country_code = 'CO' and code not in ('05', '08', '11', '13', '15', '17', '18', '19', '20', '23', '25', '27', '41', '44', '47', '50', '52', '54', '63', '66', '68', '70', '73', '76', '81', '85', '86', '88', '91', '94', '95', '97', '99');

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05001', 'Medellín', 'medellin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05002', 'Abejorral', 'abejorral', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05004', 'Abriaquí', 'abriaqui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05021', 'Alejandría', 'alejandria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05030', 'Amagá', 'amaga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05031', 'Amalfi', 'amalfi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05034', 'Andes', 'andes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05036', 'Angelópolis', 'angelopolis', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05038', 'Angostura', 'angostura', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05040', 'Anorí', 'anori', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05042', 'Santa Fé de Antioquia', 'santa fe de antioquia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05044', 'Anzá', 'anza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05045', 'Apartadó', 'apartado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05051', 'Arboletes', 'arboletes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05055', 'Argelia', 'argelia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05059', 'Armenia', 'armenia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05079', 'Barbosa', 'barbosa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05086', 'Belmira', 'belmira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05088', 'Bello', 'bello', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05091', 'Betania', 'betania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05093', 'Betulia', 'betulia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05101', 'Ciudad Bolívar', 'ciudad bolivar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05107', 'Briceño', 'briceno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05113', 'Buriticá', 'buritica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05120', 'Cáceres', 'caceres', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05125', 'Caicedo', 'caicedo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05129', 'Caldas', 'caldas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05134', 'Campamento', 'campamento', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05138', 'Cañasgordas', 'canasgordas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05142', 'Caracolí', 'caracoli', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05145', 'Caramanta', 'caramanta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05147', 'Carepa', 'carepa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05148', 'El Carmen de Viboral', 'el carmen de viboral', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05150', 'Carolina', 'carolina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05154', 'Caucasia', 'caucasia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05172', 'Chigorodó', 'chigorodo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05190', 'Cisneros', 'cisneros', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05197', 'Cocorná', 'cocorna', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05206', 'Concepción', 'concepcion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05209', 'Concordia', 'concordia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05212', 'Copacabana', 'copacabana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05234', 'Dabeiba', 'dabeiba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05237', 'Donmatías', 'donmatias', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05240', 'Ebéjico', 'ebejico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05250', 'El Bagre', 'el bagre', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05264', 'Entrerríos', 'entrerrios', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05266', 'Envigado', 'envigado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05282', 'Fredonia', 'fredonia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05284', 'Frontino', 'frontino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05306', 'Giraldo', 'giraldo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05308', 'Girardota', 'girardota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05310', 'Gómez Plata', 'gomez plata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05313', 'Granada', 'granada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05315', 'Guadalupe', 'guadalupe', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05318', 'Guarne', 'guarne', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05321', 'Guatapé', 'guatape', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05347', 'Heliconia', 'heliconia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05353', 'Hispania', 'hispania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05360', 'Itagüí', 'itagui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05361', 'Ituango', 'ituango', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05364', 'Jardín', 'jardin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05368', 'Jericó', 'jerico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05376', 'La Ceja', 'la ceja', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05380', 'La Estrella', 'la estrella', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05390', 'La Pintada', 'la pintada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05400', 'La Unión', 'la union', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05411', 'Liborina', 'liborina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05425', 'Maceo', 'maceo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05440', 'Marinilla', 'marinilla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05467', 'Montebello', 'montebello', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05475', 'Murindó', 'murindo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05480', 'Mutatá', 'mutata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05483', 'Nariño', 'narino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05490', 'Necoclí', 'necocli', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05495', 'Nechí', 'nechi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05501', 'Olaya', 'olaya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05541', 'Peñol', 'penol', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05543', 'Peque', 'peque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05576', 'Pueblorrico', 'pueblorrico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05579', 'Puerto Berrío', 'puerto berrio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05585', 'Puerto Nare', 'puerto nare', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05591', 'Puerto Triunfo', 'puerto triunfo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05604', 'Remedios', 'remedios', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05607', 'Retiro', 'retiro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05615', 'Rionegro', 'rionegro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05628', 'Sabanalarga', 'sabanalarga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05631', 'Sabaneta', 'sabaneta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05642', 'Salgar', 'salgar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05647', 'San Andrés de Cuerquía', 'san andres de cuerquia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05649', 'San Carlos', 'san carlos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05652', 'San Francisco', 'san francisco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05656', 'San Jerónimo', 'san jeronimo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05658', 'San José de la Montaña', 'san jose de la montana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05659', 'San Juan de Urabá', 'san juan de uraba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05660', 'San Luis', 'san luis', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05664', 'San Pedro de los Milagros', 'san pedro de los milagros', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05665', 'San Pedro de Urabá', 'san pedro de uraba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05667', 'San Rafael', 'san rafael', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05670', 'San Roque', 'san roque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05674', 'San Vicente Ferrer', 'san vicente ferrer', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05679', 'Santa Bárbara', 'santa barbara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05686', 'Santa Rosa de Osos', 'santa rosa de osos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05690', 'Santo Domingo', 'santo domingo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05697', 'El Santuario', 'el santuario', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05736', 'Segovia', 'segovia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05756', 'Sonsón', 'sonson', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05761', 'Sopetrán', 'sopetran', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05789', 'Támesis', 'tamesis', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05790', 'Tarazá', 'taraza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05792', 'Tarso', 'tarso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05809', 'Titiribí', 'titiribi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05819', 'Toledo', 'toledo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05837', 'Turbo', 'turbo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05842', 'Uramita', 'uramita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05847', 'Urrao', 'urrao', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05854', 'Valdivia', 'valdivia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05856', 'Valparaíso', 'valparaiso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05858', 'Vegachí', 'vegachi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05861', 'Venecia', 'venecia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05873', 'Vigía del Fuerte', 'vigia del fuerte', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05885', 'Yalí', 'yali', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05887', 'Yarumal', 'yarumal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05890', 'Yolombó', 'yolombo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05893', 'Yondó', 'yondo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '05895', 'Zaragoza', 'zaragoza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '05'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08001', 'Barranquilla', 'barranquilla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08078', 'Baranoa', 'baranoa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08137', 'Campo de la Cruz', 'campo de la cruz', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08141', 'Candelaria', 'candelaria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08296', 'Galapa', 'galapa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08372', 'Juan de Acosta', 'juan de acosta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08421', 'Luruaco', 'luruaco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08433', 'Malambo', 'malambo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08436', 'Manatí', 'manati', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08520', 'Palmar de Varela', 'palmar de varela', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08549', 'Piojó', 'piojo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08558', 'Polonuevo', 'polonuevo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08560', 'Ponedera', 'ponedera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08573', 'Puerto Colombia', 'puerto colombia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08606', 'Repelón', 'repelon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08634', 'Sabanagrande', 'sabanagrande', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08638', 'Sabanalarga', 'sabanalarga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08675', 'Santa Lucía', 'santa lucia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08685', 'Santo Tomás', 'santo tomas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08758', 'Soledad', 'soledad', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08770', 'Suan', 'suan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08832', 'Tubará', 'tubara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '08849', 'Usiacurí', 'usiacuri', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '08'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '11001', 'Bogotá, D.C.', 'bogota, d.c.', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '11'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13001', 'Cartagena de Indias', 'cartagena de indias', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13006', 'Achí', 'achi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13030', 'Altos del Rosario', 'altos del rosario', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13042', 'Arenal', 'arenal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13052', 'Arjona', 'arjona', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13062', 'Arroyohondo', 'arroyohondo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13074', 'Barranco de Loba', 'barranco de loba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13140', 'Calamar', 'calamar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13160', 'Cantagallo', 'cantagallo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13188', 'Cicuco', 'cicuco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13212', 'Córdoba', 'cordoba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13222', 'Clemencia', 'clemencia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13244', 'El Carmen de Bolívar', 'el carmen de bolivar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13248', 'El Guamo', 'el guamo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13268', 'El Peñón', 'el penon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13300', 'Hatillo de Loba', 'hatillo de loba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13430', 'Magangué', 'magangue', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13433', 'Mahates', 'mahates', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13440', 'Margarita', 'margarita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13442', 'María la Baja', 'maria la baja', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13458', 'Montecristo', 'montecristo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13468', 'Santa Cruz de Mompox', 'santa cruz de mompox', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13473', 'Morales', 'morales', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13490', 'Norosí', 'norosi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13549', 'Pinillos', 'pinillos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13580', 'Regidor', 'regidor', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13600', 'Río Viejo', 'rio viejo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13620', 'San Cristóbal', 'san cristobal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13647', 'San Estanislao', 'san estanislao', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13650', 'San Fernando', 'san fernando', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13654', 'San Jacinto', 'san jacinto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13655', 'San Jacinto del Cauca', 'san jacinto del cauca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13657', 'San Juan Nepomuceno', 'san juan nepomuceno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13667', 'San Martín de Loba', 'san martin de loba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13670', 'San Pablo', 'san pablo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13673', 'Santa Catalina', 'santa catalina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13683', 'Santa Rosa', 'santa rosa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13688', 'Santa Rosa del Sur', 'santa rosa del sur', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13744', 'Simití', 'simiti', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13760', 'Soplaviento', 'soplaviento', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13780', 'Talaigua Nuevo', 'talaigua nuevo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13810', 'Tiquisio', 'tiquisio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13836', 'Turbaco', 'turbaco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13838', 'Turbaná', 'turbana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13873', 'Villanueva', 'villanueva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '13894', 'Zambrano', 'zambrano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '13'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15001', 'Tunja', 'tunja', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15022', 'Almeida', 'almeida', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15047', 'Aquitania', 'aquitania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15051', 'Arcabuco', 'arcabuco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15087', 'Belén', 'belen', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15090', 'Berbeo', 'berbeo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15092', 'Betéitiva', 'beteitiva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15097', 'Boavita', 'boavita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15104', 'Boyacá', 'boyaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15106', 'Briceño', 'briceno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15109', 'Buenavista', 'buenavista', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15114', 'Busbanzá', 'busbanza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15131', 'Caldas', 'caldas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15135', 'Campohermoso', 'campohermoso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15162', 'Cerinza', 'cerinza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15172', 'Chinavita', 'chinavita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15176', 'Chiquinquirá', 'chiquinquira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15180', 'Chiscas', 'chiscas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15183', 'Chita', 'chita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15185', 'Chitaraque', 'chitaraque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15187', 'Chivatá', 'chivata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15189', 'Ciénega', 'cienega', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15204', 'Cómbita', 'combita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15212', 'Coper', 'coper', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15215', 'Corrales', 'corrales', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15218', 'Covarachía', 'covarachia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15223', 'Cubará', 'cubara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15224', 'Cucaita', 'cucaita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15226', 'Cuítiva', 'cuitiva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15232', 'Chíquiza', 'chiquiza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15236', 'Chivor', 'chivor', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15238', 'Duitama', 'duitama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15244', 'El Cocuy', 'el cocuy', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15248', 'El Espino', 'el espino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15272', 'Firavitoba', 'firavitoba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15276', 'Floresta', 'floresta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15293', 'Gachantivá', 'gachantiva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15296', 'Gámeza', 'gameza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15299', 'Garagoa', 'garagoa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15317', 'Guacamayas', 'guacamayas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15322', 'Guateque', 'guateque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15325', 'Guayatá', 'guayata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15332', 'Güicán de la Sierra', 'guican de la sierra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15362', 'Iza', 'iza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15367', 'Jenesano', 'jenesano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15368', 'Jericó', 'jerico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15377', 'Labranzagrande', 'labranzagrande', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15380', 'La Capilla', 'la capilla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15401', 'La Victoria', 'la victoria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15403', 'La Uvita', 'la uvita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15407', 'Villa de Leyva', 'villa de leyva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15425', 'Macanal', 'macanal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15442', 'Maripí', 'maripi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15455', 'Miraflores', 'miraflores', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15464', 'Mongua', 'mongua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15466', 'Monguí', 'mongui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15469', 'Moniquirá', 'moniquira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15476', 'Motavita', 'motavita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15480', 'Muzo', 'muzo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15491', 'Nobsa', 'nobsa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15494', 'Nuevo Colón', 'nuevo colon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15500', 'Oicatá', 'oicata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15507', 'Otanche', 'otanche', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15511', 'Pachavita', 'pachavita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15514', 'Páez', 'paez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15516', 'Paipa', 'paipa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15518', 'Pajarito', 'pajarito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15522', 'Panqueba', 'panqueba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15531', 'Pauna', 'pauna', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15533', 'Paya', 'paya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15537', 'Paz de Río', 'paz de rio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15542', 'Pesca', 'pesca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15550', 'Pisba', 'pisba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15572', 'Puerto Boyacá', 'puerto boyaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15580', 'Quípama', 'quipama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15599', 'Ramiriquí', 'ramiriqui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15600', 'Ráquira', 'raquira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15621', 'Rondón', 'rondon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15632', 'Saboyá', 'saboya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15638', 'Sáchica', 'sachica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15646', 'Samacá', 'samaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15660', 'San Eduardo', 'san eduardo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15664', 'San José de Pare', 'san jose de pare', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15667', 'San Luis de Gaceno', 'san luis de gaceno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15673', 'San Mateo', 'san mateo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15676', 'San Miguel de Sema', 'san miguel de sema', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15681', 'San Pablo de Borbur', 'san pablo de borbur', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15686', 'Santana', 'santana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15690', 'Santa María', 'santa maria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15693', 'Santa Rosa de Viterbo', 'santa rosa de viterbo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15696', 'Santa Sofía', 'santa sofia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15720', 'Sativanorte', 'sativanorte', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15723', 'Sativasur', 'sativasur', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15740', 'Siachoque', 'siachoque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15753', 'Soatá', 'soata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15755', 'Socotá', 'socota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15757', 'Socha', 'socha', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15759', 'Sogamoso', 'sogamoso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15761', 'Somondoco', 'somondoco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15762', 'Sora', 'sora', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15763', 'Sotaquirá', 'sotaquira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15764', 'Soracá', 'soraca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15774', 'Susacón', 'susacon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15776', 'Sutamarchán', 'sutamarchan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15778', 'Sutatenza', 'sutatenza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15790', 'Tasco', 'tasco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15798', 'Tenza', 'tenza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15804', 'Tibaná', 'tibana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15806', 'Tibasosa', 'tibasosa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15808', 'Tinjacá', 'tinjaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15810', 'Tipacoque', 'tipacoque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15814', 'Toca', 'toca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15816', 'Togüí', 'togui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15820', 'Tópaga', 'topaga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15822', 'Tota', 'tota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15832', 'Tununguá', 'tunungua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15835', 'Turmequé', 'turmeque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15837', 'Tuta', 'tuta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15839', 'Tutazá', 'tutaza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15842', 'Úmbita', 'umbita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15861', 'Ventaquemada', 'ventaquemada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15879', 'Viracachá', 'viracacha', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '15897', 'Zetaquira', 'zetaquira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '15'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17001', 'Manizales', 'manizales', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17013', 'Aguadas', 'aguadas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17042', 'Anserma', 'anserma', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17050', 'Aranzazu', 'aranzazu', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17088', 'Belalcázar', 'belalcazar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17174', 'Chinchiná', 'chinchina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17272', 'Filadelfia', 'filadelfia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17380', 'La Dorada', 'la dorada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17388', 'La Merced', 'la merced', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17433', 'Manzanares', 'manzanares', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17442', 'Marmato', 'marmato', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17444', 'Marquetalia', 'marquetalia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17446', 'Marulanda', 'marulanda', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17486', 'Neira', 'neira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17495', 'Norcasia', 'norcasia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17513', 'Pácora', 'pacora', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17524', 'Palestina', 'palestina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17541', 'Pensilvania', 'pensilvania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17614', 'Riosucio', 'riosucio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17616', 'Risaralda', 'risaralda', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17653', 'Salamina', 'salamina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17662', 'Samaná', 'samana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17665', 'San José', 'san jose', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17777', 'Supía', 'supia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17867', 'Victoria', 'victoria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17873', 'Villamaría', 'villamaria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '17877', 'Viterbo', 'viterbo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '17'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18001', 'Florencia', 'florencia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18029', 'Albania', 'albania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18094', 'Belén de los Andaquíes', 'belen de los andaquies', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18150', 'Cartagena del Chairá', 'cartagena del chaira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18205', 'Curillo', 'curillo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18247', 'El Doncello', 'el doncello', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18256', 'El Paujíl', 'el paujil', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18410', 'La Montañita', 'la montanita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18460', 'Milán', 'milan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18479', 'Morelia', 'morelia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18592', 'Puerto Rico', 'puerto rico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18610', 'San José del Fragua', 'san jose del fragua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18753', 'San Vicente del Caguán', 'san vicente del caguan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18756', 'Solano', 'solano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18785', 'Solita', 'solita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '18860', 'Valparaíso', 'valparaiso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '18'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19001', 'Popayán', 'popayan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19022', 'Almaguer', 'almaguer', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19050', 'Argelia', 'argelia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19075', 'Balboa', 'balboa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19100', 'Bolívar', 'bolivar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19110', 'Buenos Aires', 'buenos aires', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19130', 'Cajibío', 'cajibio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19137', 'Caldono', 'caldono', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19142', 'Caloto', 'caloto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19212', 'Corinto', 'corinto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19256', 'El Tambo', 'el tambo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19290', 'Florencia', 'florencia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19300', 'Guachené', 'guachene', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19318', 'Guapi', 'guapi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19355', 'Inzá', 'inza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19364', 'Jambaló', 'jambalo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19392', 'La Sierra', 'la sierra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19397', 'La Vega', 'la vega', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19418', 'López de Micay', 'lopez de micay', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19450', 'Mercaderes', 'mercaderes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19455', 'Miranda', 'miranda', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19473', 'Morales', 'morales', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19513', 'Padilla', 'padilla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19517', 'Páez', 'paez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19532', 'Patía', 'patia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19533', 'Piamonte', 'piamonte', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19548', 'Piendamó - Tunía', 'piendamo - tunia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19573', 'Puerto Tejada', 'puerto tejada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19585', 'Puracé', 'purace', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19622', 'Rosas', 'rosas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19693', 'San Sebastián', 'san sebastian', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19698', 'Santander de Quilichao', 'santander de quilichao', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19701', 'Santa Rosa', 'santa rosa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19743', 'Silvia', 'silvia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19760', 'Sotará - Paispamba', 'sotara - paispamba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19780', 'Suárez', 'suarez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19785', 'Sucre', 'sucre', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19807', 'Timbío', 'timbio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19809', 'Timbiquí', 'timbiqui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19821', 'Toribío', 'toribio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19824', 'Totoró', 'totoro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '19845', 'Villa Rica', 'villa rica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '19'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20001', 'Valledupar', 'valledupar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20011', 'Aguachica', 'aguachica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20013', 'Agustín Codazzi', 'agustin codazzi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20032', 'Astrea', 'astrea', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20045', 'Becerril', 'becerril', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20060', 'Bosconia', 'bosconia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20175', 'Chimichagua', 'chimichagua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20178', 'Chiriguaná', 'chiriguana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20228', 'Curumaní', 'curumani', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20238', 'El Copey', 'el copey', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20250', 'El Paso', 'el paso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20295', 'Gamarra', 'gamarra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20310', 'González', 'gonzalez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20383', 'La Gloria', 'la gloria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20400', 'La Jagua de Ibirico', 'la jagua de ibirico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20443', 'Manaure Balcón del Cesar', 'manaure balcon del cesar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20517', 'Pailitas', 'pailitas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20550', 'Pelaya', 'pelaya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20570', 'Pueblo Bello', 'pueblo bello', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20614', 'Río de Oro', 'rio de oro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20621', 'La Paz', 'la paz', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20710', 'San Alberto', 'san alberto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20750', 'San Diego', 'san diego', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20770', 'San Martín', 'san martin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '20787', 'Tamalameque', 'tamalameque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '20'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23001', 'Montería', 'monteria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23068', 'Ayapel', 'ayapel', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23079', 'Buenavista', 'buenavista', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23090', 'Canalete', 'canalete', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23162', 'Cereté', 'cerete', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23168', 'Chimá', 'chima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23182', 'Chinú', 'chinu', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23189', 'Ciénaga de Oro', 'cienaga de oro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23300', 'Cotorra', 'cotorra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23350', 'La Apartada', 'la apartada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23417', 'Lorica', 'lorica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23419', 'Los Córdobas', 'los cordobas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23464', 'Momil', 'momil', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23466', 'Montelíbano', 'montelibano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23500', 'Moñitos', 'monitos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23555', 'Planeta Rica', 'planeta rica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23570', 'Pueblo Nuevo', 'pueblo nuevo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23574', 'Puerto Escondido', 'puerto escondido', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23580', 'Puerto Libertador', 'puerto libertador', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23586', 'Purísima de la Concepción', 'purisima de la concepcion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23660', 'Sahagún', 'sahagun', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23670', 'San Andrés de Sotavento', 'san andres de sotavento', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23672', 'San Antero', 'san antero', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23675', 'San Bernardo del Viento', 'san bernardo del viento', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23678', 'San Carlos', 'san carlos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23682', 'San José de Uré', 'san jose de ure', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23686', 'San Pelayo', 'san pelayo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23807', 'Tierralta', 'tierralta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23815', 'Tuchín', 'tuchin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '23855', 'Valencia', 'valencia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '23'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25001', 'Agua de Dios', 'agua de dios', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25019', 'Albán', 'alban', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25035', 'Anapoima', 'anapoima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25040', 'Anolaima', 'anolaima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25053', 'Arbeláez', 'arbelaez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25086', 'Beltrán', 'beltran', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25095', 'Bituima', 'bituima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25099', 'Bojacá', 'bojaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25120', 'Cabrera', 'cabrera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25123', 'Cachipay', 'cachipay', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25126', 'Cajicá', 'cajica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25148', 'Caparrapí', 'caparrapi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25151', 'Cáqueza', 'caqueza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25154', 'Carmen de Carupa', 'carmen de carupa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25168', 'Chaguaní', 'chaguani', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25175', 'Chía', 'chia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25178', 'Chipaque', 'chipaque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25181', 'Choachí', 'choachi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25183', 'Chocontá', 'choconta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25200', 'Cogua', 'cogua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25214', 'Cota', 'cota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25224', 'Cucunubá', 'cucunuba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25245', 'El Colegio', 'el colegio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25258', 'El Peñón', 'el penon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25260', 'El Rosal', 'el rosal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25269', 'Facatativá', 'facatativa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25279', 'Fómeque', 'fomeque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25281', 'Fosca', 'fosca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25286', 'Funza', 'funza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25288', 'Fúquene', 'fuquene', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25290', 'Fusagasugá', 'fusagasuga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25293', 'Gachalá', 'gachala', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25295', 'Gachancipá', 'gachancipa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25297', 'Gachetá', 'gacheta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25299', 'Gama', 'gama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25307', 'Girardot', 'girardot', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25312', 'Granada', 'granada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25317', 'Guachetá', 'guacheta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25320', 'Guaduas', 'guaduas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25322', 'Guasca', 'guasca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25324', 'Guataquí', 'guataqui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25326', 'Guatavita', 'guatavita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25328', 'Guayabal de Síquima', 'guayabal de siquima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25335', 'Guayabetal', 'guayabetal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25339', 'Gutiérrez', 'gutierrez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25368', 'Jerusalén', 'jerusalen', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25372', 'Junín', 'junin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25377', 'La Calera', 'la calera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25386', 'La Mesa', 'la mesa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25394', 'La Palma', 'la palma', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25398', 'La Peña', 'la pena', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25402', 'La Vega', 'la vega', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25407', 'Lenguazaque', 'lenguazaque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25426', 'Machetá', 'macheta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25430', 'Madrid', 'madrid', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25436', 'Manta', 'manta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25438', 'Medina', 'medina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25473', 'Mosquera', 'mosquera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25483', 'Nariño', 'narino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25486', 'Nemocón', 'nemocon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25488', 'Nilo', 'nilo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25489', 'Nimaima', 'nimaima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25491', 'Nocaima', 'nocaima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25506', 'Venecia', 'venecia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25513', 'Pacho', 'pacho', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25518', 'Paime', 'paime', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25524', 'Pandi', 'pandi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25530', 'Paratebueno', 'paratebueno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25535', 'Pasca', 'pasca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25572', 'Puerto Salgar', 'puerto salgar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25580', 'Pulí', 'puli', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25592', 'Quebradanegra', 'quebradanegra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25594', 'Quetame', 'quetame', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25596', 'Quipile', 'quipile', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25599', 'Apulo', 'apulo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25612', 'Ricaurte', 'ricaurte', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25645', 'San Antonio del Tequendama', 'san antonio del tequendama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25649', 'San Bernardo', 'san bernardo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25653', 'San Cayetano', 'san cayetano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25658', 'San Francisco', 'san francisco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25662', 'San Juan de Rioseco', 'san juan de rioseco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25718', 'Sasaima', 'sasaima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25736', 'Sesquilé', 'sesquile', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25740', 'Sibaté', 'sibate', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25743', 'Silvania', 'silvania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25745', 'Simijaca', 'simijaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25754', 'Soacha', 'soacha', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25758', 'Sopó', 'sopo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25769', 'Subachoque', 'subachoque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25772', 'Suesca', 'suesca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25777', 'Supatá', 'supata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25779', 'Susa', 'susa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25781', 'Sutatausa', 'sutatausa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25785', 'Tabio', 'tabio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25793', 'Tausa', 'tausa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25797', 'Tena', 'tena', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25799', 'Tenjo', 'tenjo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25805', 'Tibacuy', 'tibacuy', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25807', 'Tibirita', 'tibirita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25815', 'Tocaima', 'tocaima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25817', 'Tocancipá', 'tocancipa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25823', 'Topaipí', 'topaipi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25839', 'Ubalá', 'ubala', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25841', 'Ubaque', 'ubaque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25843', 'Villa de San Diego de Ubaté', 'villa de san diego de ubate', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25845', 'Une', 'une', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25851', 'Útica', 'utica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25862', 'Vergara', 'vergara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25867', 'Vianí', 'viani', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25871', 'Villagómez', 'villagomez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25873', 'Villapinzón', 'villapinzon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25875', 'Villeta', 'villeta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25878', 'Viotá', 'viota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25885', 'Yacopí', 'yacopi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25898', 'Zipacón', 'zipacon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '25899', 'Zipaquirá', 'zipaquira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '25'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27001', 'Quibdó', 'quibdo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27006', 'Acandí', 'acandi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27025', 'Alto Baudó', 'alto baudo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27050', 'Atrato', 'atrato', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27073', 'Bagadó', 'bagado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27075', 'Bahía Solano', 'bahia solano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27077', 'Bajo Baudó', 'bajo baudo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27099', 'Bojayá', 'bojaya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27135', 'El Cantón del San Pablo', 'el canton del san pablo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27150', 'Carmen del Darién', 'carmen del darien', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27160', 'Cértegui', 'certegui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27205', 'Condoto', 'condoto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27245', 'El Carmen de Atrato', 'el carmen de atrato', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27250', 'El Litoral del San Juan', 'el litoral del san juan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27361', 'Istmina', 'istmina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27372', 'Juradó', 'jurado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27413', 'Lloró', 'lloro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27425', 'Medio Atrato', 'medio atrato', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27430', 'Medio Baudó', 'medio baudo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27450', 'Medio San Juan', 'medio san juan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27491', 'Nóvita', 'novita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27493', 'Nuevo Belén de Bajirá', 'nuevo belen de bajira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27495', 'Nuquí', 'nuqui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27580', 'Río Iró', 'rio iro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27600', 'Río Quito', 'rio quito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27615', 'Riosucio', 'riosucio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27660', 'San José del Palmar', 'san jose del palmar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27745', 'Sipí', 'sipi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27787', 'Tadó', 'tado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27800', 'Unguía', 'unguia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '27810', 'Unión Panamericana', 'union panamericana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '27'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41001', 'Neiva', 'neiva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41006', 'Acevedo', 'acevedo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41013', 'Agrado', 'agrado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41016', 'Aipe', 'aipe', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41020', 'Algeciras', 'algeciras', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41026', 'Altamira', 'altamira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41078', 'Baraya', 'baraya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41132', 'Campoalegre', 'campoalegre', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41206', 'Colombia', 'colombia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41244', 'Elías', 'elias', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41298', 'Garzón', 'garzon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41306', 'Gigante', 'gigante', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41319', 'Guadalupe', 'guadalupe', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41349', 'Hobo', 'hobo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41357', 'Íquira', 'iquira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41359', 'Isnos', 'isnos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41378', 'La Argentina', 'la argentina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41396', 'La Plata', 'la plata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41483', 'Nátaga', 'nataga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41503', 'Oporapa', 'oporapa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41518', 'Paicol', 'paicol', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41524', 'Palermo', 'palermo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41530', 'Palestina', 'palestina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41548', 'Pital', 'pital', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41551', 'Pitalito', 'pitalito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41615', 'Rivera', 'rivera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41660', 'Saladoblanco', 'saladoblanco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41668', 'San Agustín', 'san agustin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41676', 'Santa María', 'santa maria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41770', 'Suaza', 'suaza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41791', 'Tarqui', 'tarqui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41797', 'Tesalia', 'tesalia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41799', 'Tello', 'tello', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41801', 'Teruel', 'teruel', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41807', 'Timaná', 'timana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41872', 'Villavieja', 'villavieja', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '41885', 'Yaguará', 'yaguara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '41'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44001', 'Riohacha', 'riohacha', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44035', 'Albania', 'albania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44078', 'Barrancas', 'barrancas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44090', 'Dibulla', 'dibulla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44098', 'Distracción', 'distraccion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44110', 'El Molino', 'el molino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44279', 'Fonseca', 'fonseca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44378', 'Hatonuevo', 'hatonuevo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44420', 'La Jagua del Pilar', 'la jagua del pilar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44430', 'Maicao', 'maicao', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44560', 'Manaure', 'manaure', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44650', 'San Juan del Cesar', 'san juan del cesar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44847', 'Uribia', 'uribia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44855', 'Urumita', 'urumita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '44874', 'Villanueva', 'villanueva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '44'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47001', 'Santa Marta', 'santa marta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47030', 'Algarrobo', 'algarrobo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47053', 'Aracataca', 'aracataca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47058', 'Ariguaní', 'ariguani', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47161', 'Cerro de San Antonio', 'cerro de san antonio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47170', 'Chivolo', 'chivolo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47189', 'Ciénaga', 'cienaga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47205', 'Concordia', 'concordia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47245', 'El Banco', 'el banco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47258', 'El Piñón', 'el pinon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47268', 'El Retén', 'el reten', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47288', 'Fundación', 'fundacion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47318', 'Guamal', 'guamal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47460', 'Nueva Granada', 'nueva granada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47541', 'Pedraza', 'pedraza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47545', 'Pijiño del Carmen', 'pijino del carmen', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47551', 'Pivijay', 'pivijay', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47555', 'Plato', 'plato', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47570', 'Puebloviejo', 'puebloviejo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47605', 'Remolino', 'remolino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47660', 'Sabanas de San Ángel', 'sabanas de san angel', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47675', 'Salamina', 'salamina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47692', 'San Sebastián de Buenavista', 'san sebastian de buenavista', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47703', 'San Zenón', 'san zenon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47707', 'Santa Ana', 'santa ana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47720', 'Santa Bárbara de Pinto', 'santa barbara de pinto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47745', 'Sitionuevo', 'sitionuevo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47798', 'Tenerife', 'tenerife', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47960', 'Zapayán', 'zapayan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '47980', 'Zona Bananera', 'zona bananera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '47'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50001', 'Villavicencio', 'villavicencio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50006', 'Acacías', 'acacias', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50110', 'Barranca de Upía', 'barranca de upia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50124', 'Cabuyaro', 'cabuyaro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50150', 'Castilla la Nueva', 'castilla la nueva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50223', 'Cubarral', 'cubarral', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50226', 'Cumaral', 'cumaral', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50245', 'El Calvario', 'el calvario', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50251', 'El Castillo', 'el castillo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50270', 'El Dorado', 'el dorado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50287', 'Fuente de Oro', 'fuente de oro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50313', 'Granada', 'granada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50318', 'Guamal', 'guamal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50325', 'Mapiripán', 'mapiripan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50330', 'Mesetas', 'mesetas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50350', 'La Macarena', 'la macarena', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50370', 'Uribe', 'uribe', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50400', 'Lejanías', 'lejanias', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50450', 'Puerto Concordia', 'puerto concordia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50568', 'Puerto Gaitán', 'puerto gaitan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50573', 'Puerto López', 'puerto lopez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50577', 'Puerto Lleras', 'puerto lleras', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50590', 'Puerto Rico', 'puerto rico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50606', 'Restrepo', 'restrepo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50680', 'San Carlos de Guaroa', 'san carlos de guaroa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50683', 'San Juan de Arama', 'san juan de arama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50686', 'San Juanito', 'san juanito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50689', 'San Martín', 'san martin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '50711', 'Vistahermosa', 'vistahermosa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '50'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52001', 'Pasto', 'pasto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52019', 'Albán', 'alban', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52022', 'Aldana', 'aldana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52036', 'Ancuya', 'ancuya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52051', 'Arboleda', 'arboleda', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52079', 'Barbacoas', 'barbacoas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52083', 'Belén', 'belen', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52110', 'Buesaco', 'buesaco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52203', 'Colón', 'colon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52207', 'Consacá', 'consaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52210', 'Contadero', 'contadero', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52215', 'Córdoba', 'cordoba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52224', 'Cuaspud Carlosama', 'cuaspud carlosama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52227', 'Cumbal', 'cumbal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52233', 'Cumbitara', 'cumbitara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52240', 'Chachagüí', 'chachagui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52250', 'El Charco', 'el charco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52254', 'El Peñol', 'el penol', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52256', 'El Rosario', 'el rosario', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52258', 'El Tablón de Gómez', 'el tablon de gomez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52260', 'El Tambo', 'el tambo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52287', 'Funes', 'funes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52317', 'Guachucal', 'guachucal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52320', 'Guaitarilla', 'guaitarilla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52323', 'Gualmatán', 'gualmatan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52352', 'Iles', 'iles', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52354', 'Imués', 'imues', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52356', 'Ipiales', 'ipiales', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52378', 'La Cruz', 'la cruz', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52381', 'La Florida', 'la florida', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52385', 'La Llanada', 'la llanada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52390', 'La Tola', 'la tola', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52399', 'La Unión', 'la union', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52405', 'Leiva', 'leiva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52411', 'Linares', 'linares', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52418', 'Los Andes', 'los andes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52427', 'Magüí', 'magui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52435', 'Mallama', 'mallama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52473', 'Mosquera', 'mosquera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52480', 'Nariño', 'narino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52490', 'Olaya Herrera', 'olaya herrera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52506', 'Ospina', 'ospina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52520', 'Francisco Pizarro', 'francisco pizarro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52540', 'Policarpa', 'policarpa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52560', 'Potosí', 'potosi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52565', 'Providencia', 'providencia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52573', 'Puerres', 'puerres', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52585', 'Pupiales', 'pupiales', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52612', 'Ricaurte', 'ricaurte', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52621', 'Roberto Payán', 'roberto payan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52678', 'Samaniego', 'samaniego', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52683', 'Sandoná', 'sandona', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52685', 'San Bernardo', 'san bernardo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52687', 'San Lorenzo', 'san lorenzo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52693', 'San Pablo', 'san pablo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52694', 'San Pedro de Cartago', 'san pedro de cartago', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52696', 'Santa Bárbara', 'santa barbara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52699', 'Santacruz', 'santacruz', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52720', 'Sapuyes', 'sapuyes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52786', 'Taminango', 'taminango', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52788', 'Tangua', 'tangua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52835', 'San Andrés de Tumaco', 'san andres de tumaco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52838', 'Túquerres', 'tuquerres', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '52885', 'Yacuanquer', 'yacuanquer', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '52'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54001', 'San José de Cúcuta', 'san jose de cucuta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54003', 'Ábrego', 'abrego', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54051', 'Arboledas', 'arboledas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54099', 'Bochalema', 'bochalema', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54109', 'Bucarasica', 'bucarasica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54125', 'Cácota', 'cacota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54128', 'Cáchira', 'cachira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54172', 'Chinácota', 'chinacota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54174', 'Chitagá', 'chitaga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54206', 'Convención', 'convencion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54223', 'Cucutilla', 'cucutilla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54239', 'Durania', 'durania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54245', 'El Carmen', 'el carmen', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54250', 'El Tarra', 'el tarra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54261', 'El Zulia', 'el zulia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54313', 'Gramalote', 'gramalote', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54344', 'Hacarí', 'hacari', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54347', 'Herrán', 'herran', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54377', 'Labateca', 'labateca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54385', 'La Esperanza', 'la esperanza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54398', 'La Playa', 'la playa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54405', 'Los Patios', 'los patios', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54418', 'Lourdes', 'lourdes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54480', 'Mutiscua', 'mutiscua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54498', 'Ocaña', 'ocana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54518', 'Pamplona', 'pamplona', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54520', 'Pamplonita', 'pamplonita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54553', 'Puerto Santander', 'puerto santander', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54599', 'Ragonvalia', 'ragonvalia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54660', 'Salazar', 'salazar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54670', 'San Calixto', 'san calixto', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54673', 'San Cayetano', 'san cayetano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54680', 'Santiago', 'santiago', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54720', 'Sardinata', 'sardinata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54743', 'Silos', 'silos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54800', 'Teorama', 'teorama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54810', 'Tibú', 'tibu', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54820', 'Toledo', 'toledo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54871', 'Villa Caro', 'villa caro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '54874', 'Villa del Rosario', 'villa del rosario', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '54'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63001', 'Armenia', 'armenia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63111', 'Buenavista', 'buenavista', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63130', 'Calarcá', 'calarca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63190', 'Circasia', 'circasia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63212', 'Córdoba', 'cordoba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63272', 'Filandia', 'filandia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63302', 'Génova', 'genova', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63401', 'La Tebaida', 'la tebaida', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63470', 'Montenegro', 'montenegro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63548', 'Pijao', 'pijao', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63594', 'Quimbaya', 'quimbaya', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '63690', 'Salento', 'salento', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '63'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66001', 'Pereira', 'pereira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66045', 'Apía', 'apia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66075', 'Balboa', 'balboa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66088', 'Belén de Umbría', 'belen de umbria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66170', 'Dosquebradas', 'dosquebradas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66318', 'Guática', 'guatica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66383', 'La Celia', 'la celia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66400', 'La Virginia', 'la virginia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66440', 'Marsella', 'marsella', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66456', 'Mistrató', 'mistrato', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66572', 'Pueblo Rico', 'pueblo rico', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66594', 'Quinchía', 'quinchia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66682', 'Santa Rosa de Cabal', 'santa rosa de cabal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '66687', 'Santuario', 'santuario', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '66'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68001', 'Bucaramanga', 'bucaramanga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68013', 'Aguada', 'aguada', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68020', 'Albania', 'albania', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68051', 'Aratoca', 'aratoca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68077', 'Barbosa', 'barbosa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68079', 'Barichara', 'barichara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68081', 'Barrancabermeja', 'barrancabermeja', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68092', 'Betulia', 'betulia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68101', 'Bolívar', 'bolivar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68121', 'Cabrera', 'cabrera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68132', 'California', 'california', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68147', 'Capitanejo', 'capitanejo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68152', 'Carcasí', 'carcasi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68160', 'Cepitá', 'cepita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68162', 'Cerrito', 'cerrito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68167', 'Charalá', 'charala', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68169', 'Charta', 'charta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68176', 'Chima', 'chima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68179', 'Chipatá', 'chipata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68190', 'Cimitarra', 'cimitarra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68207', 'Concepción', 'concepcion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68209', 'Confines', 'confines', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68211', 'Contratación', 'contratacion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68217', 'Coromoro', 'coromoro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68229', 'Curití', 'curiti', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68235', 'El Carmen de Chucurí', 'el carmen de chucuri', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68245', 'El Guacamayo', 'el guacamayo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68250', 'El Peñón', 'el penon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68255', 'El Playón', 'el playon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68264', 'Encino', 'encino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68266', 'Enciso', 'enciso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68271', 'Florián', 'florian', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68276', 'Floridablanca', 'floridablanca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68296', 'Galán', 'galan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68298', 'Gámbita', 'gambita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68307', 'Girón', 'giron', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68318', 'Guaca', 'guaca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68320', 'Guadalupe', 'guadalupe', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68322', 'Guapotá', 'guapota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68324', 'Guavatá', 'guavata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68327', 'Güepsa', 'guepsa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68344', 'Hato', 'hato', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68368', 'Jesús María', 'jesus maria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68370', 'Jordán', 'jordan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68377', 'La Belleza', 'la belleza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68385', 'Landázuri', 'landazuri', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68397', 'La Paz', 'la paz', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68406', 'Lebrija', 'lebrija', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68418', 'Los Santos', 'los santos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68425', 'Macaravita', 'macaravita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68432', 'Málaga', 'malaga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68444', 'Matanza', 'matanza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68464', 'Mogotes', 'mogotes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68468', 'Molagavita', 'molagavita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68498', 'Ocamonte', 'ocamonte', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68500', 'Oiba', 'oiba', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68502', 'Onzaga', 'onzaga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68522', 'Palmar', 'palmar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68524', 'Palmas del Socorro', 'palmas del socorro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68533', 'Páramo', 'paramo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68547', 'Piedecuesta', 'piedecuesta', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68549', 'Pinchote', 'pinchote', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68572', 'Puente Nacional', 'puente nacional', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68573', 'Puerto Parra', 'puerto parra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68575', 'Puerto Wilches', 'puerto wilches', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68615', 'Rionegro', 'rionegro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68655', 'Sabana de Torres', 'sabana de torres', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68669', 'San Andrés', 'san andres', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68673', 'San Benito', 'san benito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68679', 'San Gil', 'san gil', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68682', 'San Joaquín', 'san joaquin', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68684', 'San José de Miranda', 'san jose de miranda', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68686', 'San Miguel', 'san miguel', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68689', 'San Vicente de Chucurí', 'san vicente de chucuri', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68705', 'Santa Bárbara', 'santa barbara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68720', 'Santa Helena del Opón', 'santa helena del opon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68745', 'Simacota', 'simacota', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68755', 'Socorro', 'socorro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68770', 'Suaita', 'suaita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68773', 'Sucre', 'sucre', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68780', 'Suratá', 'surata', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68820', 'Tona', 'tona', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68855', 'Valle de San José', 'valle de san jose', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68861', 'Vélez', 'velez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68867', 'Vetas', 'vetas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68872', 'Villanueva', 'villanueva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '68895', 'Zapatoca', 'zapatoca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '68'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70001', 'Sincelejo', 'sincelejo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70110', 'Buenavista', 'buenavista', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70124', 'Caimito', 'caimito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70204', 'Colosó', 'coloso', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70215', 'Corozal', 'corozal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70221', 'Coveñas', 'covenas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70230', 'Chalán', 'chalan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70233', 'El Roble', 'el roble', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70235', 'Galeras', 'galeras', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70265', 'Guaranda', 'guaranda', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70400', 'La Unión', 'la union', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70418', 'Los Palmitos', 'los palmitos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70429', 'Majagual', 'majagual', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70473', 'Morroa', 'morroa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70508', 'Ovejas', 'ovejas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70523', 'Palmito', 'palmito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70670', 'Sampués', 'sampues', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70678', 'San Benito Abad', 'san benito abad', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70702', 'San Juan de Betulia', 'san juan de betulia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70708', 'San Marcos', 'san marcos', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70713', 'San Onofre', 'san onofre', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70717', 'San Pedro', 'san pedro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70742', 'San Luis de Sincé', 'san luis de since', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70771', 'Sucre', 'sucre', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70820', 'Santiago de Tolú', 'santiago de tolu', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '70823', 'San José de Toluviejo', 'san jose de toluviejo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '70'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73001', 'Ibagué', 'ibague', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73024', 'Alpujarra', 'alpujarra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73026', 'Alvarado', 'alvarado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73030', 'Ambalema', 'ambalema', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73043', 'Anzoátegui', 'anzoategui', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73055', 'Armero', 'armero', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73067', 'Ataco', 'ataco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73124', 'Cajamarca', 'cajamarca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73148', 'Carmen de Apicalá', 'carmen de apicala', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73152', 'Casabianca', 'casabianca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73168', 'Chaparral', 'chaparral', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73200', 'Coello', 'coello', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73217', 'Coyaima', 'coyaima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73226', 'Cunday', 'cunday', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73236', 'Dolores', 'dolores', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73268', 'Espinal', 'espinal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73270', 'Falan', 'falan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73275', 'Flandes', 'flandes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73283', 'Fresno', 'fresno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73319', 'Guamo', 'guamo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73347', 'Herveo', 'herveo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73349', 'Honda', 'honda', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73352', 'Icononzo', 'icononzo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73408', 'Lérida', 'lerida', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73411', 'Líbano', 'libano', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73443', 'San Sebastián de Mariquita', 'san sebastian de mariquita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73449', 'Melgar', 'melgar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73461', 'Murillo', 'murillo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73483', 'Natagaima', 'natagaima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73504', 'Ortega', 'ortega', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73520', 'Palocabildo', 'palocabildo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73547', 'Piedras', 'piedras', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73555', 'Planadas', 'planadas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73563', 'Prado', 'prado', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73585', 'Purificación', 'purificacion', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73616', 'Rioblanco', 'rioblanco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73622', 'Roncesvalles', 'roncesvalles', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73624', 'Rovira', 'rovira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73671', 'Saldaña', 'saldana', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73675', 'San Antonio', 'san antonio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73678', 'San Luis', 'san luis', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73686', 'Santa Isabel', 'santa isabel', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73770', 'Suárez', 'suarez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73854', 'Valle de San Juan', 'valle de san juan', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73861', 'Venadillo', 'venadillo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73870', 'Villahermosa', 'villahermosa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '73873', 'Villarrica', 'villarrica', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '73'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76001', 'Santiago de Cali', 'santiago de cali', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76020', 'Alcalá', 'alcala', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76036', 'Andalucía', 'andalucia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76041', 'Ansermanuevo', 'ansermanuevo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76054', 'Argelia', 'argelia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76100', 'Bolívar', 'bolivar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76109', 'Buenaventura', 'buenaventura', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76111', 'Guadalajara de Buga', 'guadalajara de buga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76113', 'Bugalagrande', 'bugalagrande', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76122', 'Caicedonia', 'caicedonia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76126', 'Calima', 'calima', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76130', 'Candelaria', 'candelaria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76147', 'Cartago', 'cartago', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76233', 'Dagua', 'dagua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76243', 'El Águila', 'el aguila', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76246', 'El Cairo', 'el cairo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76248', 'El Cerrito', 'el cerrito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76250', 'El Dovio', 'el dovio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76275', 'Florida', 'florida', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76306', 'Ginebra', 'ginebra', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76318', 'Guacarí', 'guacari', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76364', 'Jamundí', 'jamundi', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76377', 'La Cumbre', 'la cumbre', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76400', 'La Unión', 'la union', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76403', 'La Victoria', 'la victoria', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76497', 'Obando', 'obando', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76520', 'Palmira', 'palmira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76563', 'Pradera', 'pradera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76606', 'Restrepo', 'restrepo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76616', 'Riofrío', 'riofrio', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76622', 'Roldanillo', 'roldanillo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76670', 'San Pedro', 'san pedro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76736', 'Sevilla', 'sevilla', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76823', 'Toro', 'toro', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76828', 'Trujillo', 'trujillo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76834', 'Tuluá', 'tulua', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76845', 'Ulloa', 'ulloa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76863', 'Versalles', 'versalles', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76869', 'Vijes', 'vijes', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76890', 'Yotoco', 'yotoco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76892', 'Yumbo', 'yumbo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '76895', 'Zarzal', 'zarzal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '76'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '81001', 'Arauca', 'arauca', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '81'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '81065', 'Arauquita', 'arauquita', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '81'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '81220', 'Cravo Norte', 'cravo norte', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '81'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '81300', 'Fortul', 'fortul', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '81'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '81591', 'Puerto Rondón', 'puerto rondon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '81'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '81736', 'Saravena', 'saravena', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '81'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '81794', 'Tame', 'tame', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '81'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85001', 'Yopal', 'yopal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85010', 'Aguazul', 'aguazul', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85015', 'Chámeza', 'chameza', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85125', 'Hato Corozal', 'hato corozal', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85136', 'La Salina', 'la salina', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85139', 'Maní', 'mani', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85162', 'Monterrey', 'monterrey', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85225', 'Nunchía', 'nunchia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85230', 'Orocué', 'orocue', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85250', 'Paz de Ariporo', 'paz de ariporo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85263', 'Pore', 'pore', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85279', 'Recetor', 'recetor', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85300', 'Sabanalarga', 'sabanalarga', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85315', 'Sácama', 'sacama', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85325', 'San Luis de Palenque', 'san luis de palenque', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85400', 'Támara', 'tamara', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85410', 'Tauramena', 'tauramena', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85430', 'Trinidad', 'trinidad', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '85440', 'Villanueva', 'villanueva', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '85'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86001', 'Mocoa', 'mocoa', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86219', 'Colón', 'colon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86320', 'Orito', 'orito', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86568', 'Puerto Asís', 'puerto asis', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86569', 'Puerto Caicedo', 'puerto caicedo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86571', 'Puerto Guzmán', 'puerto guzman', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86573', 'Puerto Leguízamo', 'puerto leguizamo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86749', 'Sibundoy', 'sibundoy', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86755', 'San Francisco', 'san francisco', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86757', 'San Miguel', 'san miguel', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86760', 'Santiago', 'santiago', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86865', 'Valle del Guamuez', 'valle del guamuez', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '86885', 'Villagarzón', 'villagarzon', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '86'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '88001', 'San Andrés', 'san andres', 'Isla', true
from public.departments d
where d.country_code = 'CO' and d.code = '88'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '88564', 'Providencia', 'providencia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '88'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91001', 'Leticia', 'leticia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91263', 'El Encanto', 'el encanto', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91405', 'La Chorrera', 'la chorrera', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91407', 'La Pedrera', 'la pedrera', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91430', 'La Victoria', 'la victoria', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91460', 'Mirití - Paraná', 'miriti - parana', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91530', 'Puerto Alegría', 'puerto alegria', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91536', 'Puerto Arica', 'puerto arica', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91540', 'Puerto Nariño', 'puerto narino', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91669', 'Puerto Santander', 'puerto santander', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '91798', 'Tarapacá', 'tarapaca', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '91'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94001', 'Inírida', 'inirida', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94343', 'Barrancominas', 'barrancominas', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94883', 'San Felipe', 'san felipe', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94884', 'Puerto Colombia', 'puerto colombia', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94885', 'La Guadalupe', 'la guadalupe', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94886', 'Cacahual', 'cacahual', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94887', 'Pana Pana', 'pana pana', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '94888', 'Morichal', 'morichal', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '94'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '95001', 'San José del Guaviare', 'san jose del guaviare', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '95'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '95015', 'Calamar', 'calamar', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '95'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '95025', 'El Retorno', 'el retorno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '95'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '95200', 'Miraflores', 'miraflores', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '95'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '97001', 'Mitú', 'mitu', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '97'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '97161', 'Carurú', 'caruru', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '97'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '97511', 'Pacoa', 'pacoa', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '97'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '97666', 'Taraira', 'taraira', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '97'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '97777', 'Papunahua', 'papunahua', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '97'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '97889', 'Yavaraté', 'yavarate', 'Área no municipalizada', true
from public.departments d
where d.country_code = 'CO' and d.code = '97'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '99001', 'Puerto Carreño', 'puerto carreno', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '99'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '99524', 'La Primavera', 'la primavera', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '99'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '99624', 'Santa Rosalía', 'santa rosalia', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '99'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

insert into public.cities (department_id, code, name, name_norm, kind, is_active)
select d.id, '99773', 'Cumaribo', 'cumaribo', 'Municipio', true
from public.departments d
where d.country_code = 'CO' and d.code = '99'
on conflict (department_id, code) do update set
  name = excluded.name, name_norm = excluded.name_norm, kind = excluded.kind, is_active = true, updated_at = now();

-- Desactivar municipios CO que ya no vienen en DIVIPOLA
update public.cities c set is_active = false, updated_at = now()
from public.departments d
where c.department_id = d.id and d.country_code = 'CO'
  and not exists (
    select 1 from (values
      ('05', '05001'),
      ('05', '05002'),
      ('05', '05004'),
      ('05', '05021'),
      ('05', '05030'),
      ('05', '05031'),
      ('05', '05034'),
      ('05', '05036'),
      ('05', '05038'),
      ('05', '05040'),
      ('05', '05042'),
      ('05', '05044'),
      ('05', '05045'),
      ('05', '05051'),
      ('05', '05055'),
      ('05', '05059'),
      ('05', '05079'),
      ('05', '05086'),
      ('05', '05088'),
      ('05', '05091'),
      ('05', '05093'),
      ('05', '05101'),
      ('05', '05107'),
      ('05', '05113'),
      ('05', '05120'),
      ('05', '05125'),
      ('05', '05129'),
      ('05', '05134'),
      ('05', '05138'),
      ('05', '05142'),
      ('05', '05145'),
      ('05', '05147'),
      ('05', '05148'),
      ('05', '05150'),
      ('05', '05154'),
      ('05', '05172'),
      ('05', '05190'),
      ('05', '05197'),
      ('05', '05206'),
      ('05', '05209'),
      ('05', '05212'),
      ('05', '05234'),
      ('05', '05237'),
      ('05', '05240'),
      ('05', '05250'),
      ('05', '05264'),
      ('05', '05266'),
      ('05', '05282'),
      ('05', '05284'),
      ('05', '05306'),
      ('05', '05308'),
      ('05', '05310'),
      ('05', '05313'),
      ('05', '05315'),
      ('05', '05318'),
      ('05', '05321'),
      ('05', '05347'),
      ('05', '05353'),
      ('05', '05360'),
      ('05', '05361'),
      ('05', '05364'),
      ('05', '05368'),
      ('05', '05376'),
      ('05', '05380'),
      ('05', '05390'),
      ('05', '05400'),
      ('05', '05411'),
      ('05', '05425'),
      ('05', '05440'),
      ('05', '05467'),
      ('05', '05475'),
      ('05', '05480'),
      ('05', '05483'),
      ('05', '05490'),
      ('05', '05495'),
      ('05', '05501'),
      ('05', '05541'),
      ('05', '05543'),
      ('05', '05576'),
      ('05', '05579'),
      ('05', '05585'),
      ('05', '05591'),
      ('05', '05604'),
      ('05', '05607'),
      ('05', '05615'),
      ('05', '05628'),
      ('05', '05631'),
      ('05', '05642'),
      ('05', '05647'),
      ('05', '05649'),
      ('05', '05652'),
      ('05', '05656'),
      ('05', '05658'),
      ('05', '05659'),
      ('05', '05660'),
      ('05', '05664'),
      ('05', '05665'),
      ('05', '05667'),
      ('05', '05670'),
      ('05', '05674'),
      ('05', '05679'),
      ('05', '05686'),
      ('05', '05690'),
      ('05', '05697'),
      ('05', '05736'),
      ('05', '05756'),
      ('05', '05761'),
      ('05', '05789'),
      ('05', '05790'),
      ('05', '05792'),
      ('05', '05809'),
      ('05', '05819'),
      ('05', '05837'),
      ('05', '05842'),
      ('05', '05847'),
      ('05', '05854'),
      ('05', '05856'),
      ('05', '05858'),
      ('05', '05861'),
      ('05', '05873'),
      ('05', '05885'),
      ('05', '05887'),
      ('05', '05890'),
      ('05', '05893'),
      ('05', '05895'),
      ('08', '08001'),
      ('08', '08078'),
      ('08', '08137'),
      ('08', '08141'),
      ('08', '08296'),
      ('08', '08372'),
      ('08', '08421'),
      ('08', '08433'),
      ('08', '08436'),
      ('08', '08520'),
      ('08', '08549'),
      ('08', '08558'),
      ('08', '08560'),
      ('08', '08573'),
      ('08', '08606'),
      ('08', '08634'),
      ('08', '08638'),
      ('08', '08675'),
      ('08', '08685'),
      ('08', '08758'),
      ('08', '08770'),
      ('08', '08832'),
      ('08', '08849'),
      ('11', '11001'),
      ('13', '13001'),
      ('13', '13006'),
      ('13', '13030'),
      ('13', '13042'),
      ('13', '13052'),
      ('13', '13062'),
      ('13', '13074'),
      ('13', '13140'),
      ('13', '13160'),
      ('13', '13188'),
      ('13', '13212'),
      ('13', '13222'),
      ('13', '13244'),
      ('13', '13248'),
      ('13', '13268'),
      ('13', '13300'),
      ('13', '13430'),
      ('13', '13433'),
      ('13', '13440'),
      ('13', '13442'),
      ('13', '13458'),
      ('13', '13468'),
      ('13', '13473'),
      ('13', '13490'),
      ('13', '13549'),
      ('13', '13580'),
      ('13', '13600'),
      ('13', '13620'),
      ('13', '13647'),
      ('13', '13650'),
      ('13', '13654'),
      ('13', '13655'),
      ('13', '13657'),
      ('13', '13667'),
      ('13', '13670'),
      ('13', '13673'),
      ('13', '13683'),
      ('13', '13688'),
      ('13', '13744'),
      ('13', '13760'),
      ('13', '13780'),
      ('13', '13810'),
      ('13', '13836'),
      ('13', '13838'),
      ('13', '13873'),
      ('13', '13894'),
      ('15', '15001'),
      ('15', '15022'),
      ('15', '15047'),
      ('15', '15051'),
      ('15', '15087'),
      ('15', '15090'),
      ('15', '15092'),
      ('15', '15097'),
      ('15', '15104'),
      ('15', '15106'),
      ('15', '15109'),
      ('15', '15114'),
      ('15', '15131'),
      ('15', '15135'),
      ('15', '15162'),
      ('15', '15172'),
      ('15', '15176'),
      ('15', '15180'),
      ('15', '15183'),
      ('15', '15185'),
      ('15', '15187'),
      ('15', '15189'),
      ('15', '15204'),
      ('15', '15212'),
      ('15', '15215'),
      ('15', '15218'),
      ('15', '15223'),
      ('15', '15224'),
      ('15', '15226'),
      ('15', '15232'),
      ('15', '15236'),
      ('15', '15238'),
      ('15', '15244'),
      ('15', '15248'),
      ('15', '15272'),
      ('15', '15276'),
      ('15', '15293'),
      ('15', '15296'),
      ('15', '15299'),
      ('15', '15317'),
      ('15', '15322'),
      ('15', '15325'),
      ('15', '15332'),
      ('15', '15362'),
      ('15', '15367'),
      ('15', '15368'),
      ('15', '15377'),
      ('15', '15380'),
      ('15', '15401'),
      ('15', '15403'),
      ('15', '15407'),
      ('15', '15425'),
      ('15', '15442'),
      ('15', '15455'),
      ('15', '15464'),
      ('15', '15466'),
      ('15', '15469'),
      ('15', '15476'),
      ('15', '15480'),
      ('15', '15491'),
      ('15', '15494'),
      ('15', '15500'),
      ('15', '15507'),
      ('15', '15511'),
      ('15', '15514'),
      ('15', '15516'),
      ('15', '15518'),
      ('15', '15522'),
      ('15', '15531'),
      ('15', '15533'),
      ('15', '15537'),
      ('15', '15542'),
      ('15', '15550'),
      ('15', '15572'),
      ('15', '15580'),
      ('15', '15599'),
      ('15', '15600'),
      ('15', '15621'),
      ('15', '15632'),
      ('15', '15638'),
      ('15', '15646'),
      ('15', '15660'),
      ('15', '15664'),
      ('15', '15667'),
      ('15', '15673'),
      ('15', '15676'),
      ('15', '15681'),
      ('15', '15686'),
      ('15', '15690'),
      ('15', '15693'),
      ('15', '15696'),
      ('15', '15720'),
      ('15', '15723'),
      ('15', '15740'),
      ('15', '15753'),
      ('15', '15755'),
      ('15', '15757'),
      ('15', '15759'),
      ('15', '15761'),
      ('15', '15762'),
      ('15', '15763'),
      ('15', '15764'),
      ('15', '15774'),
      ('15', '15776'),
      ('15', '15778'),
      ('15', '15790'),
      ('15', '15798'),
      ('15', '15804'),
      ('15', '15806'),
      ('15', '15808'),
      ('15', '15810'),
      ('15', '15814'),
      ('15', '15816'),
      ('15', '15820'),
      ('15', '15822'),
      ('15', '15832'),
      ('15', '15835'),
      ('15', '15837'),
      ('15', '15839'),
      ('15', '15842'),
      ('15', '15861'),
      ('15', '15879'),
      ('15', '15897'),
      ('17', '17001'),
      ('17', '17013'),
      ('17', '17042'),
      ('17', '17050'),
      ('17', '17088'),
      ('17', '17174'),
      ('17', '17272'),
      ('17', '17380'),
      ('17', '17388'),
      ('17', '17433'),
      ('17', '17442'),
      ('17', '17444'),
      ('17', '17446'),
      ('17', '17486'),
      ('17', '17495'),
      ('17', '17513'),
      ('17', '17524'),
      ('17', '17541'),
      ('17', '17614'),
      ('17', '17616'),
      ('17', '17653'),
      ('17', '17662'),
      ('17', '17665'),
      ('17', '17777'),
      ('17', '17867'),
      ('17', '17873'),
      ('17', '17877'),
      ('18', '18001'),
      ('18', '18029'),
      ('18', '18094'),
      ('18', '18150'),
      ('18', '18205'),
      ('18', '18247'),
      ('18', '18256'),
      ('18', '18410'),
      ('18', '18460'),
      ('18', '18479'),
      ('18', '18592'),
      ('18', '18610'),
      ('18', '18753'),
      ('18', '18756'),
      ('18', '18785'),
      ('18', '18860'),
      ('19', '19001'),
      ('19', '19022'),
      ('19', '19050'),
      ('19', '19075'),
      ('19', '19100'),
      ('19', '19110'),
      ('19', '19130'),
      ('19', '19137'),
      ('19', '19142'),
      ('19', '19212'),
      ('19', '19256'),
      ('19', '19290'),
      ('19', '19300'),
      ('19', '19318'),
      ('19', '19355'),
      ('19', '19364'),
      ('19', '19392'),
      ('19', '19397'),
      ('19', '19418'),
      ('19', '19450'),
      ('19', '19455'),
      ('19', '19473'),
      ('19', '19513'),
      ('19', '19517'),
      ('19', '19532'),
      ('19', '19533'),
      ('19', '19548'),
      ('19', '19573'),
      ('19', '19585'),
      ('19', '19622'),
      ('19', '19693'),
      ('19', '19698'),
      ('19', '19701'),
      ('19', '19743'),
      ('19', '19760'),
      ('19', '19780'),
      ('19', '19785'),
      ('19', '19807'),
      ('19', '19809'),
      ('19', '19821'),
      ('19', '19824'),
      ('19', '19845'),
      ('20', '20001'),
      ('20', '20011'),
      ('20', '20013'),
      ('20', '20032'),
      ('20', '20045'),
      ('20', '20060'),
      ('20', '20175'),
      ('20', '20178'),
      ('20', '20228'),
      ('20', '20238'),
      ('20', '20250'),
      ('20', '20295'),
      ('20', '20310'),
      ('20', '20383'),
      ('20', '20400'),
      ('20', '20443'),
      ('20', '20517'),
      ('20', '20550'),
      ('20', '20570'),
      ('20', '20614'),
      ('20', '20621'),
      ('20', '20710'),
      ('20', '20750'),
      ('20', '20770'),
      ('20', '20787'),
      ('23', '23001'),
      ('23', '23068'),
      ('23', '23079'),
      ('23', '23090'),
      ('23', '23162'),
      ('23', '23168'),
      ('23', '23182'),
      ('23', '23189'),
      ('23', '23300'),
      ('23', '23350'),
      ('23', '23417'),
      ('23', '23419'),
      ('23', '23464'),
      ('23', '23466'),
      ('23', '23500'),
      ('23', '23555'),
      ('23', '23570'),
      ('23', '23574'),
      ('23', '23580'),
      ('23', '23586'),
      ('23', '23660'),
      ('23', '23670'),
      ('23', '23672'),
      ('23', '23675'),
      ('23', '23678'),
      ('23', '23682'),
      ('23', '23686'),
      ('23', '23807'),
      ('23', '23815'),
      ('23', '23855'),
      ('25', '25001'),
      ('25', '25019'),
      ('25', '25035'),
      ('25', '25040'),
      ('25', '25053'),
      ('25', '25086'),
      ('25', '25095'),
      ('25', '25099'),
      ('25', '25120'),
      ('25', '25123'),
      ('25', '25126'),
      ('25', '25148'),
      ('25', '25151'),
      ('25', '25154'),
      ('25', '25168'),
      ('25', '25175'),
      ('25', '25178'),
      ('25', '25181'),
      ('25', '25183'),
      ('25', '25200'),
      ('25', '25214'),
      ('25', '25224'),
      ('25', '25245'),
      ('25', '25258'),
      ('25', '25260'),
      ('25', '25269'),
      ('25', '25279'),
      ('25', '25281'),
      ('25', '25286'),
      ('25', '25288'),
      ('25', '25290'),
      ('25', '25293'),
      ('25', '25295'),
      ('25', '25297'),
      ('25', '25299'),
      ('25', '25307'),
      ('25', '25312'),
      ('25', '25317'),
      ('25', '25320'),
      ('25', '25322'),
      ('25', '25324'),
      ('25', '25326'),
      ('25', '25328'),
      ('25', '25335'),
      ('25', '25339'),
      ('25', '25368'),
      ('25', '25372'),
      ('25', '25377'),
      ('25', '25386'),
      ('25', '25394'),
      ('25', '25398'),
      ('25', '25402'),
      ('25', '25407'),
      ('25', '25426'),
      ('25', '25430'),
      ('25', '25436'),
      ('25', '25438'),
      ('25', '25473'),
      ('25', '25483'),
      ('25', '25486'),
      ('25', '25488'),
      ('25', '25489'),
      ('25', '25491'),
      ('25', '25506'),
      ('25', '25513'),
      ('25', '25518'),
      ('25', '25524'),
      ('25', '25530'),
      ('25', '25535'),
      ('25', '25572'),
      ('25', '25580'),
      ('25', '25592'),
      ('25', '25594'),
      ('25', '25596'),
      ('25', '25599'),
      ('25', '25612'),
      ('25', '25645'),
      ('25', '25649'),
      ('25', '25653'),
      ('25', '25658'),
      ('25', '25662'),
      ('25', '25718'),
      ('25', '25736'),
      ('25', '25740'),
      ('25', '25743'),
      ('25', '25745'),
      ('25', '25754'),
      ('25', '25758'),
      ('25', '25769'),
      ('25', '25772'),
      ('25', '25777'),
      ('25', '25779'),
      ('25', '25781'),
      ('25', '25785'),
      ('25', '25793'),
      ('25', '25797'),
      ('25', '25799'),
      ('25', '25805'),
      ('25', '25807'),
      ('25', '25815'),
      ('25', '25817'),
      ('25', '25823'),
      ('25', '25839'),
      ('25', '25841'),
      ('25', '25843'),
      ('25', '25845'),
      ('25', '25851'),
      ('25', '25862'),
      ('25', '25867'),
      ('25', '25871'),
      ('25', '25873'),
      ('25', '25875'),
      ('25', '25878'),
      ('25', '25885'),
      ('25', '25898'),
      ('25', '25899'),
      ('27', '27001'),
      ('27', '27006'),
      ('27', '27025'),
      ('27', '27050'),
      ('27', '27073'),
      ('27', '27075'),
      ('27', '27077'),
      ('27', '27099'),
      ('27', '27135'),
      ('27', '27150'),
      ('27', '27160'),
      ('27', '27205'),
      ('27', '27245'),
      ('27', '27250'),
      ('27', '27361'),
      ('27', '27372'),
      ('27', '27413'),
      ('27', '27425'),
      ('27', '27430'),
      ('27', '27450'),
      ('27', '27491'),
      ('27', '27493'),
      ('27', '27495'),
      ('27', '27580'),
      ('27', '27600'),
      ('27', '27615'),
      ('27', '27660'),
      ('27', '27745'),
      ('27', '27787'),
      ('27', '27800'),
      ('27', '27810'),
      ('41', '41001'),
      ('41', '41006'),
      ('41', '41013'),
      ('41', '41016'),
      ('41', '41020'),
      ('41', '41026'),
      ('41', '41078'),
      ('41', '41132'),
      ('41', '41206'),
      ('41', '41244'),
      ('41', '41298'),
      ('41', '41306'),
      ('41', '41319'),
      ('41', '41349'),
      ('41', '41357'),
      ('41', '41359'),
      ('41', '41378'),
      ('41', '41396'),
      ('41', '41483'),
      ('41', '41503'),
      ('41', '41518'),
      ('41', '41524'),
      ('41', '41530'),
      ('41', '41548'),
      ('41', '41551'),
      ('41', '41615'),
      ('41', '41660'),
      ('41', '41668'),
      ('41', '41676'),
      ('41', '41770'),
      ('41', '41791'),
      ('41', '41797'),
      ('41', '41799'),
      ('41', '41801'),
      ('41', '41807'),
      ('41', '41872'),
      ('41', '41885'),
      ('44', '44001'),
      ('44', '44035'),
      ('44', '44078'),
      ('44', '44090'),
      ('44', '44098'),
      ('44', '44110'),
      ('44', '44279'),
      ('44', '44378'),
      ('44', '44420'),
      ('44', '44430'),
      ('44', '44560'),
      ('44', '44650'),
      ('44', '44847'),
      ('44', '44855'),
      ('44', '44874'),
      ('47', '47001'),
      ('47', '47030'),
      ('47', '47053'),
      ('47', '47058'),
      ('47', '47161'),
      ('47', '47170'),
      ('47', '47189'),
      ('47', '47205'),
      ('47', '47245'),
      ('47', '47258'),
      ('47', '47268'),
      ('47', '47288'),
      ('47', '47318'),
      ('47', '47460'),
      ('47', '47541'),
      ('47', '47545'),
      ('47', '47551'),
      ('47', '47555'),
      ('47', '47570'),
      ('47', '47605'),
      ('47', '47660'),
      ('47', '47675'),
      ('47', '47692'),
      ('47', '47703'),
      ('47', '47707'),
      ('47', '47720'),
      ('47', '47745'),
      ('47', '47798'),
      ('47', '47960'),
      ('47', '47980'),
      ('50', '50001'),
      ('50', '50006'),
      ('50', '50110'),
      ('50', '50124'),
      ('50', '50150'),
      ('50', '50223'),
      ('50', '50226'),
      ('50', '50245'),
      ('50', '50251'),
      ('50', '50270'),
      ('50', '50287'),
      ('50', '50313'),
      ('50', '50318'),
      ('50', '50325'),
      ('50', '50330'),
      ('50', '50350'),
      ('50', '50370'),
      ('50', '50400'),
      ('50', '50450'),
      ('50', '50568'),
      ('50', '50573'),
      ('50', '50577'),
      ('50', '50590'),
      ('50', '50606'),
      ('50', '50680'),
      ('50', '50683'),
      ('50', '50686'),
      ('50', '50689'),
      ('50', '50711'),
      ('52', '52001'),
      ('52', '52019'),
      ('52', '52022'),
      ('52', '52036'),
      ('52', '52051'),
      ('52', '52079'),
      ('52', '52083'),
      ('52', '52110'),
      ('52', '52203'),
      ('52', '52207'),
      ('52', '52210'),
      ('52', '52215'),
      ('52', '52224'),
      ('52', '52227'),
      ('52', '52233'),
      ('52', '52240'),
      ('52', '52250'),
      ('52', '52254'),
      ('52', '52256'),
      ('52', '52258'),
      ('52', '52260'),
      ('52', '52287'),
      ('52', '52317'),
      ('52', '52320'),
      ('52', '52323'),
      ('52', '52352'),
      ('52', '52354'),
      ('52', '52356'),
      ('52', '52378'),
      ('52', '52381'),
      ('52', '52385'),
      ('52', '52390'),
      ('52', '52399'),
      ('52', '52405'),
      ('52', '52411'),
      ('52', '52418'),
      ('52', '52427'),
      ('52', '52435'),
      ('52', '52473'),
      ('52', '52480'),
      ('52', '52490'),
      ('52', '52506'),
      ('52', '52520'),
      ('52', '52540'),
      ('52', '52560'),
      ('52', '52565'),
      ('52', '52573'),
      ('52', '52585'),
      ('52', '52612'),
      ('52', '52621'),
      ('52', '52678'),
      ('52', '52683'),
      ('52', '52685'),
      ('52', '52687'),
      ('52', '52693'),
      ('52', '52694'),
      ('52', '52696'),
      ('52', '52699'),
      ('52', '52720'),
      ('52', '52786'),
      ('52', '52788'),
      ('52', '52835'),
      ('52', '52838'),
      ('52', '52885'),
      ('54', '54001'),
      ('54', '54003'),
      ('54', '54051'),
      ('54', '54099'),
      ('54', '54109'),
      ('54', '54125'),
      ('54', '54128'),
      ('54', '54172'),
      ('54', '54174'),
      ('54', '54206'),
      ('54', '54223'),
      ('54', '54239'),
      ('54', '54245'),
      ('54', '54250'),
      ('54', '54261'),
      ('54', '54313'),
      ('54', '54344'),
      ('54', '54347'),
      ('54', '54377'),
      ('54', '54385'),
      ('54', '54398'),
      ('54', '54405'),
      ('54', '54418'),
      ('54', '54480'),
      ('54', '54498'),
      ('54', '54518'),
      ('54', '54520'),
      ('54', '54553'),
      ('54', '54599'),
      ('54', '54660'),
      ('54', '54670'),
      ('54', '54673'),
      ('54', '54680'),
      ('54', '54720'),
      ('54', '54743'),
      ('54', '54800'),
      ('54', '54810'),
      ('54', '54820'),
      ('54', '54871'),
      ('54', '54874'),
      ('63', '63001'),
      ('63', '63111'),
      ('63', '63130'),
      ('63', '63190'),
      ('63', '63212'),
      ('63', '63272'),
      ('63', '63302'),
      ('63', '63401'),
      ('63', '63470'),
      ('63', '63548'),
      ('63', '63594'),
      ('63', '63690'),
      ('66', '66001'),
      ('66', '66045'),
      ('66', '66075'),
      ('66', '66088'),
      ('66', '66170'),
      ('66', '66318'),
      ('66', '66383'),
      ('66', '66400'),
      ('66', '66440'),
      ('66', '66456'),
      ('66', '66572'),
      ('66', '66594'),
      ('66', '66682'),
      ('66', '66687'),
      ('68', '68001'),
      ('68', '68013'),
      ('68', '68020'),
      ('68', '68051'),
      ('68', '68077'),
      ('68', '68079'),
      ('68', '68081'),
      ('68', '68092'),
      ('68', '68101'),
      ('68', '68121'),
      ('68', '68132'),
      ('68', '68147'),
      ('68', '68152'),
      ('68', '68160'),
      ('68', '68162'),
      ('68', '68167'),
      ('68', '68169'),
      ('68', '68176'),
      ('68', '68179'),
      ('68', '68190'),
      ('68', '68207'),
      ('68', '68209'),
      ('68', '68211'),
      ('68', '68217'),
      ('68', '68229'),
      ('68', '68235'),
      ('68', '68245'),
      ('68', '68250'),
      ('68', '68255'),
      ('68', '68264'),
      ('68', '68266'),
      ('68', '68271'),
      ('68', '68276'),
      ('68', '68296'),
      ('68', '68298'),
      ('68', '68307'),
      ('68', '68318'),
      ('68', '68320'),
      ('68', '68322'),
      ('68', '68324'),
      ('68', '68327'),
      ('68', '68344'),
      ('68', '68368'),
      ('68', '68370'),
      ('68', '68377'),
      ('68', '68385'),
      ('68', '68397'),
      ('68', '68406'),
      ('68', '68418'),
      ('68', '68425'),
      ('68', '68432'),
      ('68', '68444'),
      ('68', '68464'),
      ('68', '68468'),
      ('68', '68498'),
      ('68', '68500'),
      ('68', '68502'),
      ('68', '68522'),
      ('68', '68524'),
      ('68', '68533'),
      ('68', '68547'),
      ('68', '68549'),
      ('68', '68572'),
      ('68', '68573'),
      ('68', '68575'),
      ('68', '68615'),
      ('68', '68655'),
      ('68', '68669'),
      ('68', '68673'),
      ('68', '68679'),
      ('68', '68682'),
      ('68', '68684'),
      ('68', '68686'),
      ('68', '68689'),
      ('68', '68705'),
      ('68', '68720'),
      ('68', '68745'),
      ('68', '68755'),
      ('68', '68770'),
      ('68', '68773'),
      ('68', '68780'),
      ('68', '68820'),
      ('68', '68855'),
      ('68', '68861'),
      ('68', '68867'),
      ('68', '68872'),
      ('68', '68895'),
      ('70', '70001'),
      ('70', '70110'),
      ('70', '70124'),
      ('70', '70204'),
      ('70', '70215'),
      ('70', '70221'),
      ('70', '70230'),
      ('70', '70233'),
      ('70', '70235'),
      ('70', '70265'),
      ('70', '70400'),
      ('70', '70418'),
      ('70', '70429'),
      ('70', '70473'),
      ('70', '70508'),
      ('70', '70523'),
      ('70', '70670'),
      ('70', '70678'),
      ('70', '70702'),
      ('70', '70708'),
      ('70', '70713'),
      ('70', '70717'),
      ('70', '70742'),
      ('70', '70771'),
      ('70', '70820'),
      ('70', '70823'),
      ('73', '73001'),
      ('73', '73024'),
      ('73', '73026'),
      ('73', '73030'),
      ('73', '73043'),
      ('73', '73055'),
      ('73', '73067'),
      ('73', '73124'),
      ('73', '73148'),
      ('73', '73152'),
      ('73', '73168'),
      ('73', '73200'),
      ('73', '73217'),
      ('73', '73226'),
      ('73', '73236'),
      ('73', '73268'),
      ('73', '73270'),
      ('73', '73275'),
      ('73', '73283'),
      ('73', '73319'),
      ('73', '73347'),
      ('73', '73349'),
      ('73', '73352'),
      ('73', '73408'),
      ('73', '73411'),
      ('73', '73443'),
      ('73', '73449'),
      ('73', '73461'),
      ('73', '73483'),
      ('73', '73504'),
      ('73', '73520'),
      ('73', '73547'),
      ('73', '73555'),
      ('73', '73563'),
      ('73', '73585'),
      ('73', '73616'),
      ('73', '73622'),
      ('73', '73624'),
      ('73', '73671'),
      ('73', '73675'),
      ('73', '73678'),
      ('73', '73686'),
      ('73', '73770'),
      ('73', '73854'),
      ('73', '73861'),
      ('73', '73870'),
      ('73', '73873'),
      ('76', '76001'),
      ('76', '76020'),
      ('76', '76036'),
      ('76', '76041'),
      ('76', '76054'),
      ('76', '76100'),
      ('76', '76109'),
      ('76', '76111'),
      ('76', '76113'),
      ('76', '76122'),
      ('76', '76126'),
      ('76', '76130'),
      ('76', '76147'),
      ('76', '76233'),
      ('76', '76243'),
      ('76', '76246'),
      ('76', '76248'),
      ('76', '76250'),
      ('76', '76275'),
      ('76', '76306'),
      ('76', '76318'),
      ('76', '76364'),
      ('76', '76377'),
      ('76', '76400'),
      ('76', '76403'),
      ('76', '76497'),
      ('76', '76520'),
      ('76', '76563'),
      ('76', '76606'),
      ('76', '76616'),
      ('76', '76622'),
      ('76', '76670'),
      ('76', '76736'),
      ('76', '76823'),
      ('76', '76828'),
      ('76', '76834'),
      ('76', '76845'),
      ('76', '76863'),
      ('76', '76869'),
      ('76', '76890'),
      ('76', '76892'),
      ('76', '76895'),
      ('81', '81001'),
      ('81', '81065'),
      ('81', '81220'),
      ('81', '81300'),
      ('81', '81591'),
      ('81', '81736'),
      ('81', '81794'),
      ('85', '85001'),
      ('85', '85010'),
      ('85', '85015'),
      ('85', '85125'),
      ('85', '85136'),
      ('85', '85139'),
      ('85', '85162'),
      ('85', '85225'),
      ('85', '85230'),
      ('85', '85250'),
      ('85', '85263'),
      ('85', '85279'),
      ('85', '85300'),
      ('85', '85315'),
      ('85', '85325'),
      ('85', '85400'),
      ('85', '85410'),
      ('85', '85430'),
      ('85', '85440'),
      ('86', '86001'),
      ('86', '86219'),
      ('86', '86320'),
      ('86', '86568'),
      ('86', '86569'),
      ('86', '86571'),
      ('86', '86573'),
      ('86', '86749'),
      ('86', '86755'),
      ('86', '86757'),
      ('86', '86760'),
      ('86', '86865'),
      ('86', '86885'),
      ('88', '88001'),
      ('88', '88564'),
      ('91', '91001'),
      ('91', '91263'),
      ('91', '91405'),
      ('91', '91407'),
      ('91', '91430'),
      ('91', '91460'),
      ('91', '91530'),
      ('91', '91536'),
      ('91', '91540'),
      ('91', '91669'),
      ('91', '91798'),
      ('94', '94001'),
      ('94', '94343'),
      ('94', '94883'),
      ('94', '94884'),
      ('94', '94885'),
      ('94', '94886'),
      ('94', '94887'),
      ('94', '94888'),
      ('95', '95001'),
      ('95', '95015'),
      ('95', '95025'),
      ('95', '95200'),
      ('97', '97001'),
      ('97', '97161'),
      ('97', '97511'),
      ('97', '97666'),
      ('97', '97777'),
      ('97', '97889'),
      ('99', '99001'),
      ('99', '99524'),
      ('99', '99624'),
      ('99', '99773')
    ) as keep(d_code, c_code)
    where keep.d_code = d.code and keep.c_code = c.code
  );
