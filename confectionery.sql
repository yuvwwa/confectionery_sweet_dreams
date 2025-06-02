drop view if exists view_products_full;
drop view if exists view_active_orders;
drop view if exists view_order_details;
drop view if exists view_inventory_status;

drop trigger if exists tr_update_stock_on_supply;
drop trigger if exists tr_update_order_total;
drop trigger if exists tr_update_customer_stats;

drop procedure if exists sp_create_order;
drop procedure if exists sp_add_order_item;

drop table if exists supply_items;
drop table if exists supplies;
drop table if exists order_items;
drop table if exists orders;
drop table if exists recipes;
drop table if exists products;
drop table if exists ingredients;
drop table if exists customers;
drop table if exists employees;
drop table if exists suppliers;
drop table if exists categories;
drop table if exists positions;
drop table if exists order_statuses;
drop table if exists units;

-- таблица единиц измерения
create table units (
    unit_id int primary key auto_increment,
    name varchar(50) not null unique,
    abbreviation varchar(10) not null unique
);

insert into units (name, abbreviation) values
('килограмм', 'кг'),
('грамм', 'г'),
('литр', 'л'),
('миллилитр', 'мл'),
('штука', 'шт'),
('упаковка', 'уп'),
('чайная ложка', 'ч.л.'),
('столовая ложка', 'ст.л.');

-- таблица категорий продукции
create table categories (
    category_id int primary key auto_increment,
    name varchar(100) not null unique,
    description text,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp
);

insert into categories (name, description) values
('торты', 'торты на заказ и в наличии'),
('пирожные', 'индивидуальные пирожные'),
('хлебобулочные изделия', 'хлеб, булочки, багеты'),
('печенье', 'различные виды печенья'),
('кексы и маффины', 'кексы, маффины, капкейки'),
('сезонные изделия', 'праздничная выпечка'),
('безглютеновые изделия', 'продукция для людей с непереносимостью глютена'),
('веганские изделия', 'продукция без продуктов животного происхождения');

-- таблица должностей
create table positions (
    position_id int primary key auto_increment,
    title varchar(100) not null unique,
    salary_min decimal(10,2),
    salary_max decimal(10,2)
);

insert into positions (title, salary_min, salary_max) values
('кондитер', 40000, 80000),
('продавец-консультант', 30000, 50000),
('управляющий', 60000, 100000),
('помощник кондитера', 25000, 40000),
('администратор', 35000, 55000);

-- таблица статусов заказов
create table order_statuses (
    status_id int primary key auto_increment,
    name varchar(50) not null unique,
    description text
);

insert into order_statuses (name, description) values
('принят', 'заказ принят, ожидает обработки'),
('в работе', 'заказ находится в производстве'),
('готов', 'заказ готов к выдаче'),
('выдан', 'заказ выдан клиенту'),
('отменен', 'заказ отменен');

-- таблица ингредиентов и сырья
create table ingredients (
    ingredient_id int primary key auto_increment,
    name varchar(150) not null,
    unit_id int not null,
    cost_per_unit decimal(10,2) not null default 0,
    min_stock_level int default 0,
    current_stock int default 0,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp,
    foreign key (unit_id) references units(unit_id)
);

insert into ingredients (name, unit_id, cost_per_unit, min_stock_level, current_stock) values
('мука пшеничная высший сорт', 1, 45.00, 50, 120),
('сахар-песок', 1, 55.00, 30, 80),
('яйца куриные с1', 5, 8.50, 100, 200),
('масло сливочное 82.5%', 1, 320.00, 10, 25),
('молоко 3.2%', 3, 65.00, 20, 40),
('сметана 20%', 1, 180.00, 5, 12),
('творог 9%', 1, 220.00, 8, 15),
('какао-порошок', 2, 3.50, 2000, 5000),
('ванилин', 2, 0.80, 100, 250),
('разрыхлитель теста', 2, 1.20, 500, 1200),
('шоколад темный 70%', 1, 890.00, 3, 8),
('орехи грецкие', 1, 1200.00, 2, 5),
('изюм', 1, 450.00, 3, 7),
('сливки 33%', 3, 280.00, 10, 20),
('желатин пищевой', 2, 2.50, 200, 500);

-- таблица продукции
create table products (
    product_id int primary key auto_increment,
    name varchar(200) not null,
    category_id int not null,
    description text,
    price decimal(10,2) not null,
    cost decimal(10,2) default 0,
    weight_grams int,
    shelf_life_hours int,
    is_custom boolean default false,
    is_active boolean default true,
    recipe_yield int default 1,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp,
    foreign key (category_id) references categories(category_id)
);

insert into products (name, category_id, description, price, cost, weight_grams, shelf_life_hours, is_custom) values
('торт "наполеон"', 1, 'классический торт с заварным кремом', 1200.00, 580.00, 1000, 72, false),
('торт "медовик"', 1, 'медовые коржи с сметанным кремом', 1100.00, 520.00, 1200, 96, false),
('торт на заказ (за 1 кг)', 1, 'торт по индивидуальному заказу', 1800.00, 850.00, 1000, 48, true),
('эклер классический', 2, 'заварное пирожное с кремом', 85.00, 40.00, 80, 24, false),
('профитроль', 2, 'маленькие заварные пирожные', 45.00, 20.00, 35, 24, false),
('хлеб белый', 3, 'пшеничный хлеб', 65.00, 25.00, 500, 48, false),
('багет французский', 3, 'хрустящий французский багет', 120.00, 55.00, 300, 24, false),
('печенье "овсяное"', 4, 'домашнее овсяное печенье', 320.00, 150.00, 500, 168, false),
('кекс "столичный"', 5, 'кекс с изюмом и орехами', 280.00, 130.00, 400, 120, false),
('капкейк ванильный', 5, 'небольшой кекс с кремом', 95.00, 45.00, 100, 48, false);

-- таблица рецептов (связь продукции с ингредиентами)
create table recipes (
    recipe_id int primary key auto_increment,
    product_id int not null,
    ingredient_id int not null,
    quantity decimal(8,3) not null,
    foreign key (product_id) references products(product_id) on delete cascade,
    foreign key (ingredient_id) references ingredients(ingredient_id),
    unique key unique_product_ingredient (product_id, ingredient_id)
);

-- рецепт для торта "наполеон"
insert into recipes (product_id, ingredient_id, quantity) values
(1, 1, 0.5),    -- мука 500г
(1, 3, 3),      -- яйца 3шт
(1, 4, 0.2),    -- масло 200г
(1, 5, 0.3),    -- молоко 300мл
(1, 2, 0.15);   -- сахар 150г

-- рецепт для эклера
insert into recipes (product_id, ingredient_id, quantity) values
(4, 1, 0.1),    -- мука 100г
(4, 3, 2),      -- яйца 2шт
(4, 4, 0.08),   -- масло 80г
(4, 5, 0.25),   -- молоко 250мл
(4, 14, 0.2);   -- сливки 200мл

-- таблица сотрудников
create table employees (
    employee_id int primary key auto_increment,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    middle_name varchar(100),
    position_id int not null,
    salary decimal(10,2),
    phone varchar(20),
    email varchar(150),
    hire_date date not null,
    is_active boolean default true,
    created_at timestamp default current_timestamp,
    foreign key (position_id) references positions(position_id)
);

insert into employees (first_name, last_name, middle_name, position_id, salary, phone, email, hire_date) values
('анна', 'петрова', 'сергеевна', 3, 75000, '+7(495)123-45-67', 'a.petrova@sweetdreams.ru', '2020-03-15'),
('мария', 'иванова', 'александровна', 1, 55000, '+7(495)234-56-78', 'm.ivanova@sweetdreams.ru', '2021-06-20'),
('елена', 'смирнова', 'владимировна', 2, 40000, '+7(495)345-67-89', 'e.smirnova@sweetdreams.ru', '2022-01-10'),
('дмитрий', 'козлов', 'игоревич', 1, 60000, '+7(495)456-78-90', 'd.kozlov@sweetdreams.ru', '2020-11-05'),
('ольга', 'морозова', 'петровна', 4, 32000, '+7(495)567-89-01', 'o.morozova@sweetdreams.ru', '2023-04-12');

-- таблица клиентов
create table customers (
    customer_id int primary key auto_increment,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    middle_name varchar(100),
    phone varchar(20) unique,
    email varchar(150) unique,
    birth_date date,
    discount_percent decimal(5,2) default 0,
    total_orders int default 0,
    total_spent decimal(12,2) default 0,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp
);

insert into customers (first_name, last_name, middle_name, phone, email, birth_date, discount_percent) values
('светлана', 'королева', 'андреевна', '+7(916)123-45-67', 's.koroleva@email.ru', '1985-07-12', 5.0),
('игорь', 'волков', 'сергеевич', '+7(925)234-56-78', 'i.volkov@email.ru', '1979-03-22', 0.0),
('наталья', 'лебедева', 'викторовна', '+7(903)345-67-89', 'n.lebedeva@email.ru', '1992-11-08', 3.0),
('алексей', 'орлов', 'михайлович', '+7(926)456-78-90', 'a.orlov@email.ru', '1988-05-15', 0.0),
('татьяна', 'соколова', 'ивановна', '+7(915)567-89-01', 't.sokolova@email.ru', '1976-09-30', 10.0);

-- таблица поставщиков
create table suppliers (
    supplier_id int primary key auto_increment,
    company_name varchar(200) not null,
    contact_person varchar(150),
    phone varchar(20),
    email varchar(150),
    address text,
    inn varchar(20),
    is_active boolean default true,
    created_at timestamp default current_timestamp
);

insert into suppliers (company_name, contact_person, phone, email, address, inn) values
('ооо "молочныйдом"', 'васильев а.п.', '+7(495)111-22-33', 'orders@moldom.ru', 'г. москва, ул. молочная, 15', '7701234567'),
('ип фермер', 'петров и.и.', '+7(498)222-33-44', 'fermer@eggs.ru', 'московская обл., г. сергиев посад', '503123456789'),
('хлебозавод №3', 'сидорова е.в.', '+7(495)333-44-55', 'supply@bread3.ru', 'г. москва, ул. хлебная, 42', '7702345678');

-- таблица заказов
create table orders (
    order_id int primary key auto_increment,
    customer_id int,
    employee_id int not null,
    status_id int not null default 1,
    order_date timestamp default current_timestamp,
    required_date datetime,
    completion_date datetime,
    total_amount decimal(12,2) not null default 0,
    discount_amount decimal(10,2) default 0,
    final_amount decimal(12,2) not null default 0,
    payment_method enum('cash', 'card', 'transfer') default 'cash',
    is_paid boolean default false,
    notes text,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp,
    foreign key (customer_id) references customers(customer_id),
    foreign key (employee_id) references employees(employee_id),
    foreign key (status_id) references order_statuses(status_id)
);

-- тестовые заказы будут создаваться через процедуры в конце

-- таблица позиций заказа
create table order_items (
    item_id int primary key auto_increment,
    order_id int not null,
    product_id int not null,
    quantity int not null,
    unit_price decimal(10,2) not null,
    total_price decimal(12,2) not null,
    custom_notes text,
    foreign key (order_id) references orders(order_id) on delete cascade,
    foreign key (product_id) references products(product_id)
);

-- таблица поставок
create table supplies (
    supply_id int primary key auto_increment,
    supplier_id int not null,
    employee_id int not null,
    supply_date timestamp default current_timestamp,
    total_amount decimal(12,2) not null default 0,
    is_received boolean default false,
    notes text,
    foreign key (supplier_id) references suppliers(supplier_id),
    foreign key (employee_id) references employees(employee_id)
);

-- таблица позиций поставки
create table supply_items (
    supply_item_id int primary key auto_increment,
    supply_id int not null,
    ingredient_id int not null,
    quantity decimal(8,3) not null,
    unit_price decimal(10,2) not null,
    total_price decimal(12,2) not null,
    foreign key (supply_id) references supplies(supply_id) on delete cascade,
    foreign key (ingredient_id) references ingredients(ingredient_id)
);

-- создание индексов

create index idx_products_category on products(category_id);
create index idx_products_active on products(is_active);
create index idx_orders_date on orders(order_date);
create index idx_orders_customer on orders(customer_id);
create index idx_orders_status on orders(status_id);
create index idx_customers_phone on customers(phone);
create index idx_ingredients_stock on ingredients(current_stock);

-- создание представлений

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

select * from view_products_full;

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

select * from view_active_orders;

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

select * from view_order_details;

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
from ingredients as i
join units as u on i.unit_id = u.unit_id
order by i.current_stock / nullif(i.min_stock_level, 0);

select * from view_inventory_status;

-- создание триггеров

-- триггер для автоматического обновления остатков при поставке
delimiter //
create trigger tr_update_stock_on_supply 
after update on supplies
for each row
begin
    if new.is_received = true and old.is_received = false then
        update ingredients as i
        join supply_items as si on i.ingredient_id = si.ingredient_id
        set i.current_stock = i.current_stock + si.quantity
        where si.supply_id = new.supply_id;
    end if;
end//

-- триггер для обновления итоговой суммы заказа
create trigger tr_update_order_total
after insert on order_items
for each row
begin
    update orders 
    set total_amount = (
        select sum(total_price) 
        from order_items 
        where order_id = new.order_id
    )
    where order_id = new.order_id;
    
    update orders 
    set final_amount = total_amount - discount_amount
    where order_id = new.order_id;
end//

-- триггер для обновления статистики клиента
create trigger tr_update_customer_stats
after update on orders
for each row
begin
    if new.status_id = 4 and old.status_id != 4 then -- заказ выдан
        update customers 
        set total_orders = total_orders + 1,
            total_spent = total_spent + new.final_amount
        where customer_id = new.customer_id;
    end if;
end//

delimiter ;

-- создание хранимых процедур

-- процедура создания нового заказа
delimiter //
create procedure sp_create_order(
    in p_customer_id int,
    in p_employee_id int,
    in p_required_date datetime,
    in p_notes text,
    out p_order_id int
)
begin
    declare discount decimal(5,2) default 0;
    
    -- получаем скидку клиента
    if p_customer_id is not null then
        select discount_percent into discount 
        from customers 
        where customer_id = p_customer_id;
    end if;
    
    -- создаем заказ
    insert into orders (customer_id, employee_id, required_date, notes, discount_amount)
    values (p_customer_id, p_employee_id, p_required_date, p_notes, 0);
    
    set p_order_id = last_insert_id();
end//

-- процедура добавления позиции в заказ
create procedure sp_add_order_item(
    in p_order_id int,
    in p_product_id int,
    in p_quantity int,
    in p_custom_notes text
)
begin
    declare v_price decimal(10,2);
    declare v_total decimal(12,2);
    
    -- получаем цену продукта
    select price into v_price 
    from products 
    where product_id = p_product_id;
    
    set v_total = v_price * p_quantity;
    
    -- добавляем позицию
    insert into order_items (order_id, product_id, quantity, unit_price, total_price, custom_notes)
    values (p_order_id, p_product_id, p_quantity, v_price, v_total, p_custom_notes);
end//

delimiter ;

-- создание тестового заказа
call sp_create_order(1, 1, '2024-12-25 15:00:00', 'Торт на день рождения', @new_order_id);
call sp_add_order_item(@new_order_id, 1, 1, 'надпись: "С днем рождения!"');
call sp_add_order_item(@new_order_id, 4, 6, null);

-- обновляем скидку и финальную сумму
update orders 
set discount_amount = total_amount * 0.05,
    final_amount = total_amount - (total_amount * 0.05)
where order_id = @new_order_id;
