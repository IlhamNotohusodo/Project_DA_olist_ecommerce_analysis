USE olist;

-- =====================================================
-- C1. Jumlah pelanggan (unik) dan jumlah order
-- =====================================================
SELECT COUNT(DISTINCT c.customer_unique_id) AS pelanggan_unik,
       COUNT(DISTINCT c.customer_id)        AS customer_id_unik,
       COUNT(DISTINCT o.order_id)           AS total_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';


-- =====================================================
-- C2. Wilayah (state) asal pelanggan - top 10
-- =====================================================
SELECT c.customer_state                      AS state,
       COUNT(DISTINCT c.customer_unique_id)  AS jumlah_pelanggan,
       ROUND(100 * COUNT(DISTINCT c.customer_unique_id)
             / (SELECT COUNT(DISTINCT c2.customer_unique_id)
                FROM orders o2
                JOIN customers c2 ON o2.customer_id = c2.customer_id
                WHERE o2.order_status = 'delivered'), 2) AS pct_pelanggan
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY jumlah_pelanggan DESC
LIMIT 10;

-- =====================================================
-- C3. Distribusi nilai pembelian per order (bucket harga)
-- Nilai order = SUM(price), dihitung per order dulu agar tidak fan-out
-- =====================================================
WITH nilai_order AS (
    SELECT o.order_id,
           SUM(oi.price) AS nilai
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT CASE
         WHEN nilai < 50   THEN '1. < 50'
         WHEN nilai < 100  THEN '2. 50 - 99'
         WHEN nilai < 200  THEN '3. 100 - 199'
         WHEN nilai < 500  THEN '4. 200 - 499'
         WHEN nilai < 1000 THEN '5. 500 - 999'
         ELSE                   '6. >= 1000'
       END                                            AS rentang_nilai,
       COUNT(*)                                       AS jumlah_order,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_order,
       ROUND(SUM(nilai), 2)                           AS total_nilai
FROM nilai_order
GROUP BY rentang_nilai
ORDER BY rentang_nilai;

-- =====================================================
-- C3b. Ringkasan statistik nilai order (rata-rata, min, max)
-- =====================================================
WITH nilai_order AS (
    SELECT o.order_id, SUM(oi.price) AS nilai
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT ROUND(AVG(nilai), 2) AS rata_rata,
       ROUND(MIN(nilai), 2) AS minimum,
       ROUND(MAX(nilai), 2) AS maksimum
FROM nilai_order;


-- =====================================================
-- C4. Proporsi pelanggan repeat vs one-time
-- =====================================================
WITH cust AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS n_order
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT COUNT(*)                                   AS total_pelanggan,
       SUM(n_order = 1)                           AS one_time,
       SUM(n_order > 1)                           AS repeat_customer,
       ROUND(100 * SUM(n_order > 1) / COUNT(*), 2) AS pct_repeat
FROM cust;
