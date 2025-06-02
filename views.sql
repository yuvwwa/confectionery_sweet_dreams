drop view if exists view_products_full;
drop view if exists view_active_orders;
drop view if exists view_order_details;
drop view if exists view_inventory_status;

-- полная информация о продукции
create view view_products_full as
select 
    p.product_id,
    p.name as product_name,
    c.name as category,
    p.description,
    p.price,
    p.cost,
    p.weight_grams,
    p.shelf_life_hours,
    p.is_custom,
    p.is_active,
    p.created_at
from products as p
join categories as c on p.category_id = c.category_id;

-- актуальные заказы
create view view_active_orders as
select 
    o.order_id,
    concat(c.last_name, ' ', c.first_name) as customer_name,
    c.phone as customer_phone,
    concat(e.last_name, ' ', e.first_name) as employee_name,
    os.name as status,
    o.order_date,
    o.required_date,
    o.final_amount,
    o.is_paid
from orders as o
left join customers as c on o.customer_id = c.customer_id
join employees as e on o.employee_id = e.employee_id
join order_statuses as os on o.status_id = os.status_id
where o.status_id in (1, 2, 3);

-- состав заказов
create view view_order_details as
select 
    o.order_id,
    concat(c.last_name, ' ', c.first_name) as customer_name,
    p.name as product_name,
    oi.quantity,
    oi.unit_price,
    oi.total_price,
    oi.custom_notes
from orders as o
left join customers as c on o.customer_id = c.customer_id
join order_items as oi on o.order_id = oi.order_id
join products as p on oi.product_id = p.product_id
order by o.order_id, oi.item_id;

-- остатки на складе
create view view_inventory_status as
select 
    i.ingredient_id,
    i.name as ingredient_name,
    u.name as unit_name,
    u.abbreviation as unit_abbr,
    i.current_stock,
    i.min_stock_level,
    case 
        when i.current_stock <= i.min_stock_level then 'требует заказа'
        when i.current_stock <= i.min_stock_level * 1.5 then 'низкий остаток'
        else 'в норме'
    end as stock_status,
    i.cost_per_unit,
    i.current_stock * i.cost_per_unit as total_value
from ingredients i
join units u on i.unit_id = u.unit_id
order by i.current_stock / nullif(i.min_stock_level, 0);
