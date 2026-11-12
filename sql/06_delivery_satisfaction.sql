USE olist;

-- =====================================================
-- E1. Rata-rata waktu pengiriman (hari)
-- Sekaligus: dari pembelian sampai tiba, dan selisih dengan estimasi
-- =====================================================
SELECT COUNT(*)                                                    AS jumlah_order,
       ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                          order_purchase_timestamp)), 1)           AS rata_hari_kirim,
       MIN(DATEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp))                     AS tercepat,
       MAX(DATEDIFF(order_delivered_customer_date,
                    order_purchase_timestamp))                     AS terlama,
       ROUND(AVG(DATEDIFF(order_estimated_delivery_date,
                          order_purchase_timestamp)), 1)           AS rata_hari_estimasi
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
  
  
  -- =====================================================
-- E2. Jumlah dan persentase pesanan terlambat
-- =====================================================
SELECT SUM(is_late = 1)                                  AS terlambat,
       SUM(is_late = 0)                                  AS tepat_waktu,
       COUNT(*)                                          AS total,
       ROUND(100 * SUM(is_late = 1) / COUNT(*), 2)       AS pct_terlambat
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
  
  
  
  
  
  
-- =====================================================
-- E3. Hubungan keterlambatan dengan rating
-- =====================================================
SELECT CASE WHEN o.is_late = 1 THEN 'Terlambat' ELSE 'Tepat waktu' END AS status_kirim,
       COUNT(*)                                       AS jumlah_order,
       ROUND(AVG(r.review_score), 2)                  AS rata_rating,
       ROUND(100 * SUM(r.review_score <= 2) / COUNT(*), 2) AS pct_rating_rendah,
       ROUND(100 * SUM(r.review_score = 5) / COUNT(*), 2)  AS pct_rating_5
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY status_kirim;


-- =====================================================
-- E3b. Rating berdasarkan lama kertelambatan
-- =====================================================
SELECT CASE 
WHEN o.is_late = 0 THEN '1. Tepat waktu'
         WHEN DATEDIFF(o.order_delivered_customer_date,
                       o.order_estimated_delivery_date) <= 3  THEN '2. Telat 1-3 hari'
         WHEN DATEDIFF(o.order_delivered_customer_date,
                       o.order_estimated_delivery_date) <= 7  THEN '3. Telat 4-7 hari'
         ELSE '4. Telat > 7 hari'
       END                              AS kategori,
       COUNT(*)                         AS jumlah_order,
       ROUND(AVG(r.review_score), 2)    AS rata_rating
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY kategori
ORDER BY kategori;

-- =====================================================
-- E4. Rata-rata rating dan distribusi skor
-- =====================================================
SELECT ROUND(AVG(r.review_score), 2) AS rata_rating,
       COUNT(*)                      AS jumlah_review
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE o.order_status = 'delivered';