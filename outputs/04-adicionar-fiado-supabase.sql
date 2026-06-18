-- Adiciona a modalidade FIADO ao Espetinho do Gordinho.
-- Rode este arquivo no SQL Editor do Supabase antes de usar Fiado no site.
-- ISOLADO: mexe somente em espetinho_gordinho.espetinho_orders.
-- Nao mexe em public, Pizzaria Paulista ou qualquer outro schema/tabela.

do $$
begin
  if not exists (
    select 1
    from pg_namespace
    where nspname = 'espetinho_gordinho'
  ) then
    raise exception 'Schema espetinho_gordinho nao encontrado. Pare aqui para nao misturar com outro projeto.';
  end if;

  if not exists (
    select 1
    from information_schema.tables
    where table_schema = 'espetinho_gordinho'
      and table_name = 'espetinho_orders'
  ) then
    raise exception 'Tabela espetinho_gordinho.espetinho_orders nao encontrada. Pare aqui para nao misturar com outro projeto.';
  end if;
end $$;

do $$
declare
  constraint_name text;
begin
  select con.conname
  into constraint_name
  from pg_constraint con
  join pg_class rel on rel.oid = con.conrelid
  join pg_namespace nsp on nsp.oid = rel.relnamespace
  where nsp.nspname = 'espetinho_gordinho'
    and rel.relname = 'espetinho_orders'
    and con.contype = 'c'
    and pg_get_constraintdef(con.oid) like '%payment_method%'
  limit 1;

  if constraint_name is not null then
    execute format('alter table espetinho_gordinho.espetinho_orders drop constraint %I', constraint_name);
  end if;
end $$;

alter table espetinho_gordinho.espetinho_orders
add constraint espetinho_orders_payment_method_check
check (payment_method in ('pix','dinheiro','cartao_credito','cartao','pendente','fiado'));
