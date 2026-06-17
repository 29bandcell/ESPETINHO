-- Correção para Espetinho do Gordinho no schema isolado.
-- Rode no SQL Editor do Supabase se o cardápio/pedidos não gravarem.
-- Não apaga nem altera nada da Pizzaria Paulista.

grant usage on schema espetinho_gordinho to anon, authenticated;
grant select, insert, update, delete on all tables in schema espetinho_gordinho to anon, authenticated;

alter table espetinho_gordinho.espetinho_categories enable row level security;
alter table espetinho_gordinho.espetinho_products enable row level security;
alter table espetinho_gordinho.espetinho_orders enable row level security;
alter table espetinho_gordinho.espetinho_order_items enable row level security;

drop policy if exists "espetinho read categories" on espetinho_gordinho.espetinho_categories;
create policy "espetinho read categories"
on espetinho_gordinho.espetinho_categories for select
to anon, authenticated
using (active = true);

drop policy if exists "espetinho manage categories" on espetinho_gordinho.espetinho_categories;
create policy "espetinho manage categories"
on espetinho_gordinho.espetinho_categories for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists "espetinho read products" on espetinho_gordinho.espetinho_products;
create policy "espetinho read products"
on espetinho_gordinho.espetinho_products for select
to anon, authenticated
using (active = true);

drop policy if exists "espetinho manage products" on espetinho_gordinho.espetinho_products;
create policy "espetinho manage products"
on espetinho_gordinho.espetinho_products for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists "espetinho create orders" on espetinho_gordinho.espetinho_orders;
create policy "espetinho create orders"
on espetinho_gordinho.espetinho_orders for insert
to anon, authenticated
with check (true);

drop policy if exists "espetinho read orders" on espetinho_gordinho.espetinho_orders;
create policy "espetinho read orders"
on espetinho_gordinho.espetinho_orders for select
to anon, authenticated
using (true);

drop policy if exists "espetinho update orders" on espetinho_gordinho.espetinho_orders;
create policy "espetinho update orders"
on espetinho_gordinho.espetinho_orders for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "espetinho create order items" on espetinho_gordinho.espetinho_order_items;
create policy "espetinho create order items"
on espetinho_gordinho.espetinho_order_items for insert
to anon, authenticated
with check (true);

drop policy if exists "espetinho read order items" on espetinho_gordinho.espetinho_order_items;
create policy "espetinho read order items"
on espetinho_gordinho.espetinho_order_items for select
to anon, authenticated
using (true);

drop policy if exists "espetinho update order items" on espetinho_gordinho.espetinho_order_items;
create policy "espetinho update order items"
on espetinho_gordinho.espetinho_order_items for update
to anon, authenticated
using (true)
with check (true);

insert into espetinho_gordinho.espetinho_categories (name, sort_order) values
('Comida', 10),
('Bebidas', 20),
('Cerveja', 30),
('Bebidas quentes', 40)
on conflict do nothing;

with cats as (
  select id, name from espetinho_gordinho.espetinho_categories
)
insert into espetinho_gordinho.espetinho_products (category_id, name, description, price, size, sort_order)
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
  select 1
  from espetinho_gordinho.espetinho_products p
  where p.category_id = cats.id
    and lower(p.name) = lower(data.name)
    and coalesce(p.size, '') = coalesce(data.size, '')
    and p.price = data.price
);
