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
