USE olist;

-- =====================================================
-- A1. Total revenue, total order, dan rata-rata nilai transaksi (AOV)
-- =====================================================
SELECT COUNT(DISTINCT o.order_id)                                  AS total_order,
       ROUND(SUM(oi.price), 2)                                     AS total_revenue,
       ROUND(SUM(oi.freight_value), 2)                             AS total_ongkir,
       ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2)        AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- =====================================================
-- A2. Jumlah order, revenue, dan AOV per bulan
-- =====================================================
SELECT o.order_month,
       COUNT(DISTINCT o.order_id)                                  AS jumlah_order,
       ROUND(SUM(oi.price), 2)                                     AS revenue,
       ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2)        AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_month
ORDER BY o.order_month;


-- =====================================================
-- A3. Tren penjualan: pertumbuhan revenue bulan ke bulan (MoM)
-- =====================================================
WITH monthly AS (
    SELECT o.order_month,
           SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_month
)
SELECT order_month,
       ROUND(revenue, 2)                                           AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY order_month), 2)          AS revenue_bulan_lalu,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY order_month))
                 / LAG(revenue) OVER (ORDER BY order_month), 2)    AS pertumbuhan_pct
FROM monthly
ORDER BY order_month;


-- =====================================================
-- A3b. Ringkasan tahunan (pelengkap tren)
-- =====================================================
SELECT o.order_year,
       COUNT(DISTINCT o.order_id)        AS jumlah_order,
       ROUND(SUM(oi.price), 2)           AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_year
ORDER BY o.order_year;



-- =====================================================
-- A4. Bulan dengan revenue tertinggi (top 5)
-- =====================================================
SELECT o.order_month,
       ROUND(SUM(oi.price), 2)           AS revenue,
       COUNT(DISTINCT o.order_id)        AS jumlah_order
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_month
ORDER BY revenue DESC
LIMIT 5;
