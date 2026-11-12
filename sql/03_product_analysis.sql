USE olist;

-- =====================================================
-- B1. Kategori terlaris (berdasarkan jumlah unit terjual) - top 10
-- =====================================================
SELECT p.product_category_name_english AS kategori,
       COUNT(*)                        AS unit_terjual,
       COUNT(DISTINCT oi.order_id)     AS jumlah_order,
       ROUND(SUM(oi.price), 2)         AS revenue
FROM order_items oi
JOIN orders   o ON oi.order_id   = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name_english
ORDER BY unit_terjual DESC
LIMIT 10;

-- =====================================================
-- B2. Produk dengan revenue tertinggi - top 10
-- (product_id tidak punya nama, jadi sertakan kategorinya)
-- =====================================================
SELECT oi.product_id,
       p.product_category_name_english AS kategori,
       COUNT(*)                        AS unit_terjual,
       ROUND(SUM(oi.price), 2)         AS revenue
FROM order_items oi
JOIN orders   o ON oi.order_id   = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id, p.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;



-- =====================================================
-- B2. Produk dengan revenue tertinggi - top 10
-- (product_id tidak punya nama, jadi sertakan kategorinya)
-- =====================================================
SELECT oi.product_id,
       p.product_category_name_english AS kategori,
       COUNT(*)                        AS unit_terjual,
       ROUND(SUM(oi.price), 2)         AS revenue
FROM order_items oi
JOIN orders   o ON oi.order_id   = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id, p.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;



-- =====================================================
-- B4. Perbandingan jumlah order antar kategori (top 15)
-- =====================================================
SELECT p.product_category_name_english AS kategori,
       COUNT(DISTINCT oi.order_id)     AS jumlah_order,
       ROUND(100 * COUNT(DISTINCT oi.order_id)
             / (SELECT COUNT(DISTINCT order_id) FROM orders
                WHERE order_status = 'delivered'), 2) AS pct_dari_total_order
FROM order_items oi
JOIN orders   o ON oi.order_id   = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name_english
ORDER BY jumlah_order DESC
LIMIT 15;


