-- Espetinho do Gordinho - schema Supabase
-- Seguro para projeto compartilhado: cria apenas tabelas com prefixo espetinho_.
-- Nao apaga nem altera tabelas de outros projetos.

create extension if not exists pgcrypto;

create table if not exists public.espetinho_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.espetinho_products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.espetinho_categories(id) on delete set null,
  name text not null,
  description text,
  price numeric(10,2) not null default 0,
  size text,
  sold_out boolean not null default false,
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.espetinho_orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null default upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6)),
  channel text not null check (channel in ('publico','balcao','mesa')),
  table_number integer check (table_number between 1 and 10),
  customer_name text,
  customer_phone text,
  customer_address text,
  fulfillment text check (fulfillment in ('entrega','retirada','balcao','mesa')),
  delivery_area text,
  delivery_fee numeric(10,2) not null default 0,
  payment_method text not null check (payment_method in ('pix','dinheiro','cartao_credito','cartao','pendente')),
  change_for numeric(10,2),
  subtotal numeric(10,2) not null default 0,
  total numeric(10,2) not null default 0,
  status text not null default 'novo' check (status in ('novo','aberto','impresso','fechado','cancelado')),
  printed_at timestamptz,
  closed_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.espetinho_order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.espetinho_orders(id) on delete cascade,
  product_id uuid references public.espetinho_products(id) on delete set null,
  product_name text not null,
  unit_price numeric(10,2) not null,
  quantity integer not null check (quantity > 0),
  notes text,
  removed boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.espetinho_categories enable row level security;
alter table public.espetinho_products enable row level security;
alter table public.espetinho_orders enable row level security;
alter table public.espetinho_order_items enable row level security;

drop policy if exists "espetinho public read categories" on public.espetinho_categories;
create policy "espetinho public read categories"
on public.espetinho_categories for select
to anon, authenticated
using (active = true);

drop policy if exists "espetinho public read products" on public.espetinho_products;
create policy "espetinho public read products"
on public.espetinho_products for select
to anon, authenticated
using (active = true);

drop policy if exists "espetinho public create orders" on public.espetinho_orders;
create policy "espetinho public create orders"
on public.espetinho_orders for insert
to anon, authenticated
with check (true);

drop policy if exists "espetinho public create order items" on public.espetinho_order_items;
create policy "espetinho public create order items"
on public.espetinho_order_items for insert
to anon, authenticated
with check (true);

-- Para area da empresa funcionar sem login Supabase, o anon pode ler/atualizar apenas tabelas do app.
-- Use a senha da pagina proprietario/empresa como barreira de interface.
drop policy if exists "espetinho staff read orders" on public.espetinho_orders;
create policy "espetinho staff read orders"
on public.espetinho_orders for select
to anon, authenticated
using (true);

drop policy if exists "espetinho staff update orders" on public.espetinho_orders;
create policy "espetinho staff update orders"
on public.espetinho_orders for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "espetinho staff read items" on public.espetinho_order_items;
create policy "espetinho staff read items"
on public.espetinho_order_items for select
to anon, authenticated
using (true);

drop policy if exists "espetinho staff update items" on public.espetinho_order_items;
create policy "espetinho staff update items"
on public.espetinho_order_items for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "espetinho staff manage categories" on public.espetinho_categories;
create policy "espetinho staff manage categories"
on public.espetinho_categories for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists "espetinho staff manage products" on public.espetinho_products;
create policy "espetinho staff manage products"
on public.espetinho_products for all
to anon, authenticated
using (true)
with check (true);

insert into public.espetinho_categories (name, sort_order) values
('Comida', 10),
('Bebidas', 20),
('Cerveja', 30),
('Bebidas quentes', 40)
on conflict do nothing;

with cats as (
  select id, name from public.espetinho_categories
)
insert into public.espetinho_products (category_id, name, description, price, size, sort_order)
select cats.id, data.name, data.description, data.price, data.size, data.sort_order
from cats
join (
  values
  ('Comida','Baião cremoso','Vai com farofa e vinagrete',7.00,'P',10),
  ('Comida','Baião cremoso','Vai com farofa e vinagrete',12.00,'G',11),
  ('Comida','Batatinha frita',null,8.00,'P',12),
  ('Comida','Batatinha frita',null,14.00,'G',13),
  ('Comida','Macaxeira',null,12.00,null,14),
  ('Comida','Espetinho de porco',null,6.00,null,15),
  ('Comida','Espetinho de gado',null,6.00,null,16),
  ('Comida','Espetinho de coxa',null,6.00,null,17),
  ('Comida','Espetinho de asinha',null,6.00,null,18),
  ('Comida','Espetinho de coração de frango',null,6.00,null,19),
  ('Comida','Lasanha de carne moída',null,13.00,null,20),
  ('Comida','Fricassê',null,13.00,null,21),
  ('Comida','Torta de frango',null,13.00,null,22),
  ('Comida','Macarronada',null,13.00,null,23),
  ('Comida','Escondidinho de carne moída',null,13.00,null,24),
  ('Bebidas','Coca-Cola','1L',10.00,'1L',30),
  ('Bebidas','Coca-Cola Zero','1L',10.00,'1L',31),
  ('Bebidas','São Geraldo','1L',10.00,'1L',32),
  ('Bebidas','Coca-Cola lata',null,5.00,null,33),
  ('Bebidas','Coca-Cola Zero lata',null,5.00,null,34),
  ('Bebidas','Fanta Uva',null,5.00,null,35),
  ('Bebidas','Fanta Laranja',null,5.00,null,36),
  ('Bebidas','Guaraná lata',null,5.00,null,37),
  ('Bebidas','Sprite',null,5.00,null,38),
  ('Bebidas','Água sem gás',null,3.00,null,39),
  ('Bebidas','Água com gás',null,4.00,null,40),
  ('Cerveja','Skol','300ml',5.00,'300ml',50),
  ('Cerveja','Brahma Chopp','300ml',5.00,'300ml',51),
  ('Cerveja','Michelob Ultra','330ml',10.00,'330ml',52),
  ('Cerveja','Budweiser','600ml',12.00,'600ml',53),
  ('Cerveja','Spaten','600ml',12.00,'600ml',54),
  ('Bebidas quentes','Cana 51',null,30.00,null,60),
  ('Bebidas quentes','Terça de 51',null,5.00,null,61),
  ('Bebidas quentes','Dreher',null,40.00,null,62),
  ('Bebidas quentes','Terça',null,7.00,null,63),
  ('Bebidas quentes','Red Label',null,125.00,null,64),
  ('Bebidas quentes','Black & White',null,100.00,null,65)
) as data(category, name, description, price, size, sort_order)
on data.category = cats.name
where not exists (
  select 1 from public.espetinho_products p
  where p.name = data.name and coalesce(p.size,'') = coalesce(data.size,'')
);

update public.espetinho_products set name = case name
  when 'Baiao cremoso' then 'Baião cremoso'
  when 'Espetinho de coracao de frango' then 'Espetinho de coração de frango'
  when 'Lasanha de carne moida' then 'Lasanha de carne moída'
  when 'Fricasse' then 'Fricassê'
  when 'Escondidinho de carne moida' then 'Escondidinho de carne moída'
  when 'Coca cola' then 'Coca-Cola'
  when 'Coca cola zero' then 'Coca-Cola Zero'
  when 'Sao Geraldo' then 'São Geraldo'
  when 'Coca lata' then 'Coca-Cola lata'
  when 'Coca lata zero' then 'Coca-Cola Zero lata'
  when 'Fanta uva' then 'Fanta Uva'
  when 'Fanta laranja' then 'Fanta Laranja'
  when 'Guarana lata' then 'Guaraná lata'
  when 'Agua sem gas' then 'Água sem gás'
  when 'Agua com gas' then 'Água com gás'
  when 'Brahma chopp' then 'Brahma Chopp'
  when 'Michelob ultra' then 'Michelob Ultra'
  when 'Terca de 51' then 'Terça de 51'
  when 'Dreia' then 'Dreher'
  when 'Terca' then 'Terça'
  when 'Red label' then 'Red Label'
  when 'Black white' then 'Black & White'
  else name
end
where name in (
  'Baiao cremoso','Espetinho de coracao de frango','Lasanha de carne moida','Fricasse',
  'Escondidinho de carne moida','Coca cola','Coca cola zero','Sao Geraldo','Coca lata',
  'Coca lata zero','Fanta uva','Fanta laranja','Guarana lata','Agua sem gas','Agua com gas',
  'Brahma chopp','Michelob ultra','Terca de 51','Dreia','Terca','Red label','Black white'
);

with duplicates as (
  select id,
    row_number() over (
      partition by category_id, lower(unaccent_safe_name), coalesce(size, ''), price
      order by created_at, id
    ) as rn
  from (
    select id, category_id, size, price, created_at,
      lower(translate(name, 'áàâãéêíóôõúçÁÀÂÃÉÊÍÓÔÕÚÇ', 'aaaaeeioooucAAAAEEIOOOUC')) as unaccent_safe_name
    from public.espetinho_products
    where active = true
  ) p
)
update public.espetinho_products p
set active = false
from duplicates d
where p.id = d.id and d.rn > 1;
