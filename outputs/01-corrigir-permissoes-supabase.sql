-- PARTE 1 - Permissoes e RLS do Espetinho do Gordinho
-- Rode primeiro no SQL Editor do Supabase.

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
