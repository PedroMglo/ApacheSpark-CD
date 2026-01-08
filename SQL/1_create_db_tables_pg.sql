-- Limpa tabelas antigas se existirem (ordem inversa para evitar erros de dependência)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS departments;

--
-- Table structure for table departments
--
CREATE TABLE departments (
  department_id   INTEGER PRIMARY KEY,
  department_name VARCHAR(45) NOT NULL
);

--
-- Table structure for table categories
--
CREATE TABLE categories (
  category_id             INTEGER PRIMARY KEY,
  category_department_id  INTEGER NOT NULL,
  category_name           VARCHAR(45) NOT NULL
);

--
-- Table structure for table products
--
CREATE TABLE products (
  product_id           INTEGER PRIMARY KEY,
  product_category_id  INTEGER NOT NULL,
  product_name         VARCHAR(45) NOT NULL,
  product_description  VARCHAR(255) NOT NULL,
  product_price        NUMERIC(10,2) NOT NULL,
  product_image        VARCHAR(255) NOT NULL
);

--
-- Table structure for table customers
--
CREATE TABLE customers (
  customer_id       INTEGER PRIMARY KEY,
  customer_fname    VARCHAR(45) NOT NULL,
  customer_lname    VARCHAR(45) NOT NULL,
  customer_email    VARCHAR(45) NOT NULL,
  customer_password VARCHAR(45) NOT NULL,
  customer_street   VARCHAR(255) NOT NULL,
  customer_city     VARCHAR(45) NOT NULL,
  customer_state    VARCHAR(45) NOT NULL,
  customer_zipcode  VARCHAR(45) NOT NULL
);

--
-- Table structure for table orders
--
CREATE TABLE orders (
  order_id          INTEGER PRIMARY KEY,
  order_date        TIMESTAMP NOT NULL,
  order_customer_id INTEGER NOT NULL,
  order_status      VARCHAR(45) NOT NULL
);

--
-- Table structure for table order_items
--
CREATE TABLE order_items (
  order_item_id           INTEGER PRIMARY KEY,
  order_item_order_id     INTEGER NOT NULL,
  order_item_product_id   INTEGER NOT NULL,
  order_item_quantity     INTEGER NOT NULL,
  order_item_subtotal     NUMERIC(10,2) NOT NULL,
  order_item_product_price NUMERIC(10,2) NOT NULL
);

-- Dados de exemplo
INSERT INTO departments VALUES (2, 'Fitness');

INSERT INTO categories VALUES (1, 2, 'Football');

INSERT INTO products VALUES
  (1, 1, 'Bola de Futebol', 'Bola oficial', 29.99, 'http://image.com');

INSERT INTO customers VALUES
  (1, 'Richard', 'Hernandez', 'test@test.com', 'xxxxx',
   '123 Rua', 'Texas', 'TX', '78521');

INSERT INTO orders VALUES
  (1, '2013-07-25 00:00:00', 1, 'CLOSED'),
  (2, '2013-07-26 00:00:00', 1, 'PENDING_PAYMENT'),
  (3, '2013-07-27 00:00:00', 1, 'COMPLETE');

INSERT INTO order_items VALUES
  (1, 1, 1, 1, 29.99, 29.99);