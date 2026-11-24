# Data quality report

Generated: 2026-11-24 13:29 | Checks: 25 | Passed: 13 | Failed: 12

## Summary

| Status | Check | Type | Failed rows |
|---|---|---|---:|
| PASS | `orders_orphan_customer` | orphan | 0 |
| PASS | `order_items_orphan_order` | orphan | 0 |
| PASS | `order_items_orphan_product` | orphan | 0 |
| PASS | `order_items_orphan_seller` | orphan | 0 |
| PASS | `order_payments_orphan_order` | orphan | 0 |
| PASS | `order_reviews_orphan_order` | orphan | 0 |
| FAIL | `products_orphan_category` | orphan | 2 |
| FAIL | `orders_delivered_without_delivery_date` | missing | 8 |
| FAIL | `orders_delivered_without_approval` | missing | 14 |
| FAIL | `products_missing_category` | missing | 610 |
| PASS | `customers_duplicate_customer_id` | duplicate | 0 |
| PASS | `orders_duplicate_order_id` | duplicate | 0 |
| PASS | `order_items_duplicate_key` | duplicate | 0 |
| FAIL | `order_reviews_duplicate_review_id` | duplicate | 789 |
| FAIL | `geolocation_duplicate_rows` | duplicate | 128,174 |
| FAIL | `orders_slow_delivery` | outlier | 306 |
| FAIL | `order_payments_nonpositive_value` | outlier | 9 |
| PASS | `order_items_nonpositive_price` | outlier | 0 |
| FAIL | `products_nonpositive_dimensions` | outlier | 4 |
| PASS | `order_reviews_score_out_of_range` | outlier | 0 |
| FAIL | `geolocation_outside_brazil` | outlier | 42 |
| PASS | `customers_invalid_state` | format | 0 |
| PASS | `customers_invalid_zip` | format | 0 |
| FAIL | `sellers_invalid_city` | format | 24 |
| FAIL | `orders_inconsistent_dates` | consistency | 189 |

## Failed checks

### `products_orphan_category`

Product categories missing from the translation table (distinct values). Failed rows: 2. Examples:

```text
product_category_name=portateis_cozinha_e_preparadores_de_alimentos
product_category_name=pc_gamer
```

### `orders_delivered_without_delivery_date`

Delivered orders without a customer delivery date. Failed rows: 8. Examples:

```text
order_id=2d1e2d5bf4dc7227b3bfebb81328c15f, order_status=delivered, order_delivered_customer_date=None
order_id=f5dd62b788049ad9fc0526e3ad11a097, order_status=delivered, order_delivered_customer_date=None
order_id=2ebdfc4f15f23b91474edf87475f108e, order_status=delivered, order_delivered_customer_date=None
order_id=e69f75a717d64fc5ecdfae42b2e8e086, order_status=delivered, order_delivered_customer_date=None
order_id=0d3268bad9b086af767785e3f0fc0133, order_status=delivered, order_delivered_customer_date=None
```

### `orders_delivered_without_approval`

Delivered orders without an approval timestamp. Failed rows: 14. Examples:

```text
order_id=e04abd8149ef81b95221e88f6ed9ab6a, order_status=delivered, order_approved_at=None
order_id=8a9adc69528e1001fc68dd0aaebbb54a, order_status=delivered, order_approved_at=None
order_id=7013bcfc1c97fe719a7b5e05e61c12db, order_status=delivered, order_approved_at=None
order_id=5cf925b116421afa85ee25e99b4c34fb, order_status=delivered, order_approved_at=None
order_id=12a95a3c06dbaec84bcfb0e2da5d228a, order_status=delivered, order_approved_at=None
```

### `products_missing_category`

Products without a category name. Failed rows: 610. Examples:

```text
product_id=a41e356c76fab66334f36de622ecbd3a, product_category_name=None
product_id=d8dee61c2034d6d075997acef1870e9b, product_category_name=None
product_id=56139431d72cd51f19eb9f7dae4d1617, product_category_name=None
product_id=46b48281eb6d663ced748f324108c733, product_category_name=None
product_id=5fb61f482620cb672f5e586bb132eae9, product_category_name=None
```

### `order_reviews_duplicate_review_id`

review_id values that appear more than once. Failed rows: 789. Examples:

```text
review_id=00130cbe1f9d422698c812ed8ded1919, occurrences=2
review_id=0115633a9c298b6a98bcbe4eee75345f, occurrences=2
review_id=0174caf0ee5964646040cd94e15ac95e, occurrences=2
review_id=017808d29fd1f942d97e50184dfb4c13, occurrences=2
review_id=0254bd905dc677a6078990aad3331a36, occurrences=2
```

### `geolocation_duplicate_rows`

Fully identical rows in geolocation. Failed rows: 128,174. Examples:

```text
geolocation_zip_code_prefix=01001, geolocation_lat=-23.551336655288804, geolocation_lng=-46.63402699777831, geolocation_city=sao paulo, geolocation_state=SP, occurrences=3
geolocation_zip_code_prefix=01001, geolocation_lat=-23.550497706907514, geolocation_lng=-46.63433817805407, geolocation_city=sao paulo, geolocation_state=SP, occurrences=8
geolocation_zip_code_prefix=01001, geolocation_lat=-23.5498252739339, geolocation_lng=-46.63396956010149, geolocation_city=sao paulo, geolocation_state=SP, occurrences=2
geolocation_zip_code_prefix=01001, geolocation_lat=-23.54929199999999, geolocation_lng=-46.633559478233785, geolocation_city=sao paulo, geolocation_state=SP, occurrences=6
geolocation_zip_code_prefix=01002, geolocation_lat=-23.548878451007027, geolocation_lng=-46.634003628224384, geolocation_city=sao paulo, geolocation_state=SP, occurrences=2
```

### `orders_slow_delivery`

Orders delivered more than 60 days after purchase. Failed rows: 306. Examples:

```text
order_id=f31535f21d145b2345e2bf7f09d62322, order_purchase_timestamp=2018-02-01 07:47:34, order_delivered_customer_date=2018-04-23 15:49:34, days=81
order_id=cafc9b2f7d35ec42bdb74347cc6e8a70, order_purchase_timestamp=2018-01-19 00:48:30, order_delivered_customer_date=2018-04-04 17:12:36, days=76
order_id=b5195225c11fc325d686d24fe14eedbb, order_purchase_timestamp=2018-03-02 10:35:38, order_delivered_customer_date=2018-05-07 15:59:16, days=66
order_id=56af0400ccac703cca01cd9846d29c58, order_purchase_timestamp=2018-02-20 17:37:20, order_delivered_customer_date=2018-05-06 17:08:31, days=75
order_id=a4efaffc506a395c9cea7402b078c1e5, order_purchase_timestamp=2018-01-17 10:50:09, order_delivered_customer_date=2018-05-07 19:25:33, days=110
```

### `order_payments_nonpositive_value`

Payments with a value of zero or less. Failed rows: 9. Examples:

```text
order_id=8bcbe01d44d147f901cd3192671144db, payment_sequential=4, payment_type=voucher, payment_value=0.00
order_id=fa65dad1b0e818e3ccc5cb0e39231352, payment_sequential=14, payment_type=voucher, payment_value=0.00
order_id=6ccb433e00daae1283ccc956189c82ae, payment_sequential=4, payment_type=voucher, payment_value=0.00
order_id=4637ca194b6387e2d538dc89b124b0ee, payment_sequential=1, payment_type=not_defined, payment_value=0.00
order_id=00b1cb0320190ca0daa2c88b35206009, payment_sequential=1, payment_type=not_defined, payment_value=0.00
```

### `products_nonpositive_dimensions`

Products with zero or negative weight or dimensions. Failed rows: 4. Examples:

```text
product_id=81781c0fed9fe1ad6e8c81fca1e1cb08, product_weight_g=0, product_length_cm=30, product_height_cm=25, product_width_cm=30
product_id=8038040ee2a71048d4bdbbdc985b69ab, product_weight_g=0, product_length_cm=30, product_height_cm=25, product_width_cm=30
product_id=36ba42dd187055e1fbe943b2d11430ca, product_weight_g=0, product_length_cm=30, product_height_cm=25, product_width_cm=30
product_id=e673e90efa65a5409ff4196c038bb5af, product_weight_g=0, product_length_cm=30, product_height_cm=25, product_width_cm=30
```

### `geolocation_outside_brazil`

Coordinates outside the bounding box of Brazil. Failed rows: 42. Examples:

```text
geolocation_zip_code_prefix=18243, geolocation_lat=28.008978338034268, geolocation_lng=-15.536867177679131, geolocation_city=bom retiro da esperanca, geolocation_state=SP
geolocation_zip_code_prefix=28165, geolocation_lat=41.61405150610495, geolocation_lng=-8.411675312504059, geolocation_city=vila nova de campos, geolocation_state=RJ
geolocation_zip_code_prefix=28155, geolocation_lat=-34.586422110664884, geolocation_lng=-58.732100610901725, geolocation_city=santa maria, geolocation_state=RJ
geolocation_zip_code_prefix=28155, geolocation_lat=42.43928591592116, geolocation_lng=13.82021409761152, geolocation_city=santa maria, geolocation_state=RJ
geolocation_zip_code_prefix=28333, geolocation_lat=38.38167205114709, geolocation_lng=-6.328200272094753, geolocation_city=raposo, geolocation_state=RJ
```

### `sellers_invalid_city`

seller_city has characters other than letters, spaces, dots, hyphens, apostrophes. Failed rows: 24. Examples:

```text
seller_id=c3aad7dc65449ae90a5e9c3c6c1e78e0, seller_city=auriflama/sp
seller_id=71593c7413973a1e160057b80d4958f6, seller_city=sao paulo / sao paulo
seller_id=a3fa18b3f688ec0fca3eb8bfcbd2d5b3, seller_city=são paulo
seller_id=26b482dccfa29bd2e40703ba45523702, seller_city=santa barbara d´oeste
seller_id=ceb7b4fb9401cd378de7886317ad1b47, seller_city=04482255
```

### `orders_inconsistent_dates`

Carrier or delivery date earlier than the preceding step. Failed rows: 189. Examples:

```text
order_id=b9afddbdcfadc9a87b41a83271c3e888, order_purchase_timestamp=2018-08-16 13:50:48, order_delivered_carrier_date=2018-08-16 13:27:00, order_delivered_customer_date=2018-08-24 14:58:37
order_id=ad133696906f6a78826daa0911b7daec, order_purchase_timestamp=2018-06-15 15:41:22, order_delivered_carrier_date=2018-06-15 14:52:00, order_delivered_customer_date=2018-06-22 18:09:37
order_id=74e033208dc13a7b8127eb8e73d09b76, order_purchase_timestamp=2018-05-02 10:48:44, order_delivered_carrier_date=2018-05-02 09:49:00, order_delivered_customer_date=2018-05-07 23:06:36
order_id=a6b58794fd2ba533359a76c08df576e3, order_purchase_timestamp=2018-05-14 15:18:23, order_delivered_carrier_date=2018-05-14 13:46:00, order_delivered_customer_date=2018-05-19 19:33:32
order_id=5792e0b1c8c8a2bf53af468c9a422c88, order_purchase_timestamp=2018-07-26 13:25:14, order_delivered_carrier_date=2018-07-26 12:42:00, order_delivered_customer_date=2018-07-30 14:45:02
```
