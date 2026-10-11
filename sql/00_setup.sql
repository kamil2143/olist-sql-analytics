\encoding UTF8

-- Reset: usuwa stare schematy z poprzednich prob oraz tabele (skrypt mozna odpalac wielokrotnie)
DROP SCHEMA IF EXISTS raw, staging, core, mart CASCADE;
DROP TABLE IF EXISTS order_items, order_payments, order_reviews, orders,
                     customers, products, sellers, geolocation,
                     product_category_name_translation CASCADE;

-- Tworzenie tabel z poprawnymi typami
CREATE TABLE customers (
    customer_id              TEXT PRIMARY KEY,
    customer_unique_id       TEXT,
    customer_zip_code_prefix TEXT,
    customer_city            TEXT,
    customer_state           TEXT
);

CREATE TABLE sellers (
    seller_id              TEXT PRIMARY KEY,
    seller_zip_code_prefix TEXT,
    seller_city            TEXT,
    seller_state           TEXT
);

CREATE TABLE products (
    product_id                 TEXT PRIMARY KEY,
    product_category_name      TEXT,
    product_name_lenght        NUMERIC,
    product_description_lenght NUMERIC,
    product_photos_qty         NUMERIC,
    product_weight_g           NUMERIC,
    product_length_cm          NUMERIC,
    product_height_cm          NUMERIC,
    product_width_cm           NUMERIC
);

CREATE TABLE orders (
    order_id                      TEXT PRIMARY KEY,
    customer_id                   TEXT,
    order_status                  TEXT,
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id            TEXT,
    order_item_id       INTEGER,
    product_id          TEXT,
    seller_id           TEXT,
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10,2),
    freight_value       NUMERIC(10,2)
);

CREATE TABLE order_payments (
    order_id             TEXT,
    payment_sequential   INTEGER,
    payment_type         TEXT,
    payment_installments INTEGER,
    payment_value        NUMERIC(10,2)
);

CREATE TABLE order_reviews (
    review_id               TEXT,
    order_id                TEXT,
    review_score            INTEGER,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat             NUMERIC,
    geolocation_lng             NUMERIC,
    geolocation_city            TEXT,
    geolocation_state           TEXT
);

CREATE TABLE product_category_name_translation (
    product_category_name         TEXT,
    product_category_name_english TEXT
);

-- Ladowanie danych z plikow CSV (kazda komenda w jednej linii)
\copy customers FROM 'data/customers.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy sellers FROM 'data/sellers.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy products FROM 'data/products.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy orders FROM 'data/orders.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy order_items FROM 'data/order_items.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy order_payments FROM 'data/order_payments.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy order_reviews FROM 'data/order_reviews.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy geolocation FROM 'data/geolocation.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy product_category_name_translation FROM 'data/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')