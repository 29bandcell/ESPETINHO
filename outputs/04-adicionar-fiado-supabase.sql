-- Adiciona a modalidade FIADO ao Espetinho do Gordinho.
-- Rode este arquivo no SQL Editor do Supabase antes de usar Fiado no site.
-- Nao mexe nas tabelas da Pizzaria Paulista.

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
