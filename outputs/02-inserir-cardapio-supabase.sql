-- PARTE 2 - Cardapio do Espetinho do Gordinho
-- Rode depois da PARTE 1.

insert into espetinho_gordinho.espetinho_categories (name, sort_order) values
('Comida', 10),
('Bebidas', 20),
('Cerveja', 30),
('Bebidas quentes', 40)
on conflict do nothing;

with cats as (
  select id, name from espetinho_gordinho.espetinho_categories
),
items(category, name, description, price, size, sort_order) as (
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
)
insert into espetinho_gordinho.espetinho_products
(category_id, name, description, price, size, sort_order)
select cats.id, items.name, items.description, items.price, items.size, items.sort_order
from items
join cats on cats.name = items.category
where not exists (
  select 1
  from espetinho_gordinho.espetinho_products p
  where p.category_id = cats.id
    and lower(p.name) = lower(items.name)
    and coalesce(p.size, '') = coalesce(items.size, '')
    and p.price = items.price
);
