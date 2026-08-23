-- ============================================================
-- Cartopia — esquema de base de datos para Supabase
-- ============================================================
-- Cómo usarlo:
--   1) Abre tu proyecto en supabase.com → SQL Editor → New query
--   2) Pega TODO el bloque "PARTE 1" de abajo y presiona Run
--   3) Ve a Storage → New bucket → nómbralo exactamente
--      "listing-photos" y marca "Public bucket" al crearlo
--   4) Vuelve al SQL Editor, pega el bloque "PARTE 2" y presiona Run
-- (el orden importa: la Parte 2 necesita que el bucket ya exista)
-- ============================================================


-- ================= PARTE 1: tablas y permisos =================

create extension if not exists pgcrypto;

-- Un perfil de vendedor por cada cuenta (vinculado a auth.users)
create table if not exists public.vendors (
  id uuid primary key references auth.users(id) on delete cascade,
  store text not null,
  whatsapp text not null,
  region text not null,
  instagram text,
  created_at timestamptz not null default now()
);

alter table public.vendors enable row level security;

create policy "Cualquiera puede ver los vendedores"
  on public.vendors for select
  using (true);

create policy "Un usuario puede crear su propio perfil de vendedor"
  on public.vendors for insert
  with check (auth.uid() = id);

create policy "Un usuario puede editar su propio perfil de vendedor"
  on public.vendors for update
  using (auth.uid() = id);


-- Las cartas publicadas
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  title text not null,
  sport text not null,
  price integer not null check (price > 0),
  region text not null,
  ships boolean not null default false,
  description text,
  photo_url text not null,
  status text not null default 'disponible' check (status in ('disponible', 'vendida')),
  created_at timestamptz not null default now()
);

alter table public.listings enable row level security;

create policy "Cualquiera puede ver las cartas publicadas"
  on public.listings for select
  using (true);

create policy "Un vendedor puede publicar sus propias cartas"
  on public.listings for insert
  with check (auth.uid() = vendor_id);

create policy "Un vendedor puede editar sus propias cartas"
  on public.listings for update
  using (auth.uid() = vendor_id);

create policy "Un vendedor puede eliminar sus propias cartas"
  on public.listings for delete
  using (auth.uid() = vendor_id);

-- Habilita las actualizaciones en tiempo real (para que el marketplace
-- se actualice solo cuando alguien publica, sin recargar la página)
alter publication supabase_realtime add table public.listings;
alter publication supabase_realtime add table public.vendors;


-- ================= PARTE 2: fotos (crea el bucket primero) =================

create policy "Cualquiera puede ver las fotos de las cartas"
  on storage.objects for select
  using (bucket_id = 'listing-photos');

create policy "Un vendedor puede subir fotos a su propia carpeta"
  on storage.objects for insert
  with check (
    bucket_id = 'listing-photos'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Un vendedor puede borrar sus propias fotos"
  on storage.objects for delete
  using (
    bucket_id = 'listing-photos'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );


-- ================= PARTE 3 (opcional): monetización =================
-- Solo necesitas correr esto el día que actives MONETIZATION_ENABLED en
-- index.html (planes de vendedor y publicaciones destacadas).

alter table public.vendors
  add column if not exists plan text not null default 'free' check (plan in ('free', 'pro'));

alter table public.listings
  add column if not exists featured boolean not null default false;

alter table public.listings
  add column if not exists featured_until timestamptz;

-- Importante: las políticas de la Parte 1 dejan que cada vendedor edite
-- CUALQUIER columna de sus propias filas (no solo store/whatsapp/etc.).
-- Sin esto de abajo, alguien con conocimientos técnicos podría marcarse
-- "pro" o destacar sus propias cartas gratis llamando a Supabase
-- directamente. Estos dos triggers bloquean eso: solo alguien con la
-- clave "service_role" (o sea, tú desde el Table Editor o una función de
-- backend que valide el pago) puede cambiar "plan", "featured" o
-- "featured_until".

create or replace function public.prevent_plan_selfupgrade()
returns trigger as $$
begin
  if new.plan is distinct from old.plan and auth.role() <> 'service_role' then
    new.plan := old.plan;
  end if;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists vendors_prevent_plan_selfupgrade on public.vendors;
create trigger vendors_prevent_plan_selfupgrade
  before update on public.vendors
  for each row execute function public.prevent_plan_selfupgrade();

create or replace function public.prevent_listing_selffeature()
returns trigger as $$
begin
  if (new.featured is distinct from old.featured or new.featured_until is distinct from old.featured_until)
     and auth.role() <> 'service_role' then
    new.featured := old.featured;
    new.featured_until := old.featured_until;
  end if;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists listings_prevent_selffeature on public.listings;
create trigger listings_prevent_selffeature
  before update on public.listings
  for each row execute function public.prevent_listing_selffeature();

-- Para pasar a un vendedor a "pro" o destacar una carta una vez que
-- confirmes el pago: ve a Supabase → Table Editor → la tabla
-- correspondiente → edita la fila a mano (eso sí corre con permisos de
-- administrador y pasa el trigger), o hazlo desde una función de backend
-- que use la clave "service_role" después de confirmar el pago.
