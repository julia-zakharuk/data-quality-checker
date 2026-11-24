-- Data quality checks for the Olist dataset.
-- Format: a header line "-- check: <name> | <type> | <description>" followed by
-- a SELECT that returns the rows FAILING the check. No rows means the check passes.

-- ORPHANED REFERENCES -------------------------------------------------------

-- check: orders_orphan_customer | orphan | Orders whose customer_id is not in customers
SELECT o.order_id, o.customer_id
FROM orders o
    LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE
    o.customer_id IS NOT NULL
    AND c.customer_id IS NULL;

-- check: order_items_orphan_order | orphan | Order items whose order_id is not in orders
SELECT i.order_id, i.order_item_id
FROM order_items i
    LEFT JOIN orders o ON o.order_id = i.order_id
WHERE
    i.order_id IS NOT NULL
    AND o.order_id IS NULL;

-- check: order_items_orphan_product | orphan | Order items whose product_id is not in products
SELECT i.order_id, i.order_item_id, i.product_id
FROM order_items i
    LEFT JOIN products p ON p.product_id = i.product_id
WHERE
    i.product_id IS NOT NULL
    AND p.product_id IS NULL;

-- check: order_items_orphan_seller | orphan | Order items whose seller_id is not in sellers
SELECT i.order_id, i.order_item_id, i.seller_id
FROM order_items i
    LEFT JOIN sellers s ON s.seller_id = i.seller_id
WHERE
    i.seller_id IS NOT NULL
    AND s.seller_id IS NULL;

-- check: order_payments_orphan_order | orphan | Payments whose order_id is not in orders
SELECT p.order_id, p.payment_sequential
FROM order_payments p
    LEFT JOIN orders o ON o.order_id = p.order_id
WHERE
    p.order_id IS NOT NULL
    AND o.order_id IS NULL;

-- check: order_reviews_orphan_order | orphan | Reviews whose order_id is not in orders
SELECT r.review_id, r.order_id
FROM order_reviews r
    LEFT JOIN orders o ON o.order_id = r.order_id
WHERE
    r.order_id IS NOT NULL
    AND o.order_id IS NULL;

-- check: products_orphan_category | orphan | Product categories missing from the translation table (distinct values)
SELECT DISTINCT
    p.product_category_name
FROM
    products p
    LEFT JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE
    p.product_category_name IS NOT NULL
    AND t.product_category_name IS NULL;

-- MISSING VALUES ------------------------------------------------------------

-- check: orders_delivered_without_delivery_date | missing | Delivered orders without a customer delivery date
SELECT
    order_id,
    order_status,
    order_delivered_customer_date
FROM orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NULL;

-- check: orders_delivered_without_approval | missing | Delivered orders without an approval timestamp
SELECT
    order_id,
    order_status,
    order_approved_at
FROM orders
WHERE
    order_status = 'delivered'
    AND order_approved_at IS NULL;

-- check: products_missing_category | missing | Products without a category name
SELECT
    product_id,
    product_category_name
FROM products
WHERE
    product_category_name IS NULL;

-- DUPLICATES ----------------------------------------------------------------

-- check: customers_duplicate_customer_id | duplicate | customer_id values that appear more than once
SELECT customer_id, count(*) AS occurrences
FROM customers
GROUP BY
    customer_id
HAVING
    count(*) > 1;

-- check: orders_duplicate_order_id | duplicate | order_id values that appear more than once
SELECT order_id, count(*) AS occurrences
FROM orders
GROUP BY
    order_id
HAVING
    count(*) > 1;

-- check: order_items_duplicate_key | duplicate | Repeated (order_id, order_item_id) pairs
SELECT
    order_id,
    order_item_id,
    count(*) AS occurrences
FROM order_items
GROUP BY
    order_id,
    order_item_id
HAVING
    count(*) > 1;

-- check: order_reviews_duplicate_review_id | duplicate | review_id values that appear more than once
SELECT review_id, count(*) AS occurrences
FROM order_reviews
GROUP BY
    review_id
HAVING
    count(*) > 1;

-- check: geolocation_duplicate_rows | duplicate | Fully identical rows in geolocation
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    count(*) AS occurrences
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING
    count(*) > 1;

-- OUTLIERS AND IMPLAUSIBLE VALUES -------------------------------------------

-- check: orders_slow_delivery | outlier | Orders delivered more than 60 days after purchase
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    round(
        extract(
            epoch
            FROM
                order_delivered_customer_date - order_purchase_timestamp
        ) / 86400
    ) AS days
FROM orders
WHERE
    order_delivered_customer_date - order_purchase_timestamp > interval '60 days';

-- check: order_payments_nonpositive_value | outlier | Payments with a value of zero or less
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_value
FROM order_payments
WHERE
    payment_value <= 0;

-- check: order_items_nonpositive_price | outlier | Order items with price <= 0 or negative freight
SELECT
    order_id,
    order_item_id,
    price,
    freight_value
FROM order_items
WHERE
    price <= 0
    OR freight_value < 0;

-- check: products_nonpositive_dimensions | outlier | Products with zero or negative weight or dimensions
SELECT
    product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products
WHERE
    product_weight_g <= 0
    OR product_length_cm <= 0
    OR product_height_cm <= 0
    OR product_width_cm <= 0;

-- check: order_reviews_score_out_of_range | outlier | Review scores outside the 1-5 range
SELECT
    review_id,
    order_id,
    review_score
FROM order_reviews
WHERE
    review_score NOT BETWEEN 1 AND 5;

-- check: geolocation_outside_brazil | outlier | Coordinates outside the bounding box of Brazil
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM geolocation
WHERE
    geolocation_lat NOT BETWEEN -34 AND 6
    OR geolocation_lng NOT BETWEEN -74 AND -34;

-- INVALID FORMATS -----------------------------------------------------------

-- check: customers_invalid_state | format | customer_state is not a two-letter uppercase code
SELECT customer_id, customer_state
FROM customers
WHERE
    customer_state !~ '^[A-Z]{2}$';

-- check: customers_invalid_zip | format | customer_zip_code_prefix is not exactly 5 digits
SELECT
    customer_id,
    customer_zip_code_prefix
FROM customers
WHERE
    customer_zip_code_prefix !~ '^[0-9]{5}$';

-- check: sellers_invalid_city | format | seller_city has characters other than letters, spaces, dots, hyphens, apostrophes
SELECT seller_id, seller_city
FROM sellers
WHERE
    seller_city !~ '^[[:alpha:] ''.-]+$';

-- CONSISTENCY ---------------------------------------------------------------

-- check: orders_inconsistent_dates | consistency | Carrier or delivery date earlier than the preceding step
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE
    order_delivered_carrier_date < order_purchase_timestamp
    OR order_delivered_customer_date < order_delivered_carrier_date;