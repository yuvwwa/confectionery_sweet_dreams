create index idx_products_category on products(category_id);
create index idx_products_active on products(is_active);
create index idx_orders_date on orders(order_date);
create index idx_orders_customer on orders(customer_id);
create index idx_orders_status on orders(status_id);
create index idx_customers_phone on customers(phone);
create index idx_ingredients_stock on ingredients(current_stock);
