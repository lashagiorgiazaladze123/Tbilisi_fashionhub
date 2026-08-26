-- ============================================================
-- TBILISI FASHION HUB — Supabase schema
-- Run this once in Supabase: Dashboard -> SQL Editor -> New query -> paste -> Run
-- ============================================================

-- 1. Products table
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  cat text not null,                 -- denim | outerwear | tops | belts | shoes  (add more freely)
  icon text default 'photo',         -- fallback icon key used when no photo uploaded yet
  badge text,                        -- 'new' | '1of1' | null
  name_ka text not null,
  name_en text not null,
  size text,
  price numeric not null default 0,
  chest text default '—',
  length text default '—',
  waist text default '—',
  cond_ka text,
  cond_en text,
  image_url text,                    -- public URL in the product-photos bucket
  sold boolean not null default false,
  sort_order int not null default 0, -- lower = shows first
  created_at timestamptz not null default now()
);

-- 2. Row Level Security: anyone can read, only signed-in admins can write
alter table products enable row level security;

create policy "Public can read products"
  on products for select
  using (true);

create policy "Authenticated users can insert products"
  on products for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update products"
  on products for update
  to authenticated
  using (true);

create policy "Authenticated users can delete products"
  on products for delete
  to authenticated
  using (true);

-- 3. Storage bucket for product photos
insert into storage.buckets (id, name, public)
values ('product-photos', 'product-photos', true)
on conflict (id) do nothing;

create policy "Public can view product photos"
  on storage.objects for select
  using (bucket_id = 'product-photos');

create policy "Authenticated users can upload product photos"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'product-photos');

create policy "Authenticated users can update product photos"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'product-photos');

create policy "Authenticated users can delete product photos"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'product-photos');

-- 4. (Optional) seed a couple of starter categories/filters are handled in the front end,
--    no table needed for those since the filter list is short and rarely changes.
