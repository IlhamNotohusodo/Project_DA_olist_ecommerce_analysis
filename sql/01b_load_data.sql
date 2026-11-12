USE olist;

-- 1. customers
LOAD DATA LOCAL INFILE 'D:/Project DA/Project_DA_olist_ecommerce_analysis/data/clean/customers_clean.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

-- 2. sellers
LOAD DATA LOCAL INFILE 'D:/Project DA/Project_DA_olist_ecommerce_analysis/data/clean/sellers_clean.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(seller_id, seller_zip_code_prefix, seller_city, seller_state);

-- 3. products (angka kosong -> NULL)
LOAD DATA LOCAL INFILE 'D:/Project DA/Project_DA_olist_ecommerce_analysis/data/clean/products_clean.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(product_id, product_category_name, @nl, @dl, @pq, @w, @l, @h, @wd, product_category_name_english)
SET product_name_lenght        = NULLIF(@nl, ''),
    product_description_lenght = NULLIF(@dl, ''),
    product_photos_qty         = NULLIF(@pq, ''),
    product_weight_g           = NULLIF(@w, ''),
    product_length_cm          = NULLIF(@l, ''),
    product_height_cm          = NULLIF(@h, ''),
    product_width_cm           = NULLIF(@wd, '');

-- 4. orders (tanggal kosong -> NULL)
LOAD DATA LOCAL INFILE 'D:/Project DA/Project_DA_olist_ecommerce_analysis/data/clean/orders_clean.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, @purchase, @approved, @carrier, @cust, @est,
 order_month, order_year, @dd, @late, valid_delivery)
SET order_purchase_timestamp      = NULLIF(@purchase, ''),
    order_approved_at             = NULLIF(@approved, ''),
    order_delivered_carrier_date  = NULLIF(@carrier, ''),
    order_delivered_customer_date = NULLIF(@cust, ''),
    order_estimated_delivery_date = NULLIF(@est, ''),
    delivery_days                 = CAST(NULLIF(@dd, '') AS DECIMAL(10,0)),
    is_late                       = NULLIF(@late, '');

-- 5. order_items
LOAD DATA LOCAL INFILE 'D:/Project DA/Project_DA_olist_ecommerce_analysis/data/clean/order_items_clean.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value);

-- 6. order_payments
LOAD DATA LOCAL INFILE 'D:/Project DA/Project_DA_olist_ecommerce_analysis/data/clean/order_payments_clean.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(order_id, payment_sequential, payment_type, payment_installments, payment_value);

-- 7. order_reviews
LOAD DATA LOCAL INFILE 'D:/Project DA/Project_DA_olist_ecommerce_analysis/data/clean/order_reviews_clean.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(review_id, order_id, review_score, review_creation_date, review_answer_timestamp);