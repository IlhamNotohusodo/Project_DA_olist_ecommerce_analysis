USE olist;

-- =====================================================
-- D1. Metode pembayaran paling banyak digunakan
-- =====================================================
SELECT p.payment_type                                  AS metode,
       COUNT(*)                                        AS jumlah_transaksi,
       COUNT(DISTINCT p.order_id)                      AS jumlah_order,
       ROUND(100 * COUNT(DISTINCT p.order_id)
             / (SELECT COUNT(DISTINCT order_id) FROM orders
                WHERE order_status = 'delivered'), 2)  AS pct_dari_order
FROM order_payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY jumlah_order DESC;


-- =====================================================
-- D2. Total nilai pembayaran per metode + kontribusi
-- =====================================================

SELECT p.payment_type                                          AS metode,
       ROUND(SUM(p.payment_value), 2)                          AS total_nilai,
       ROUND(100 * SUM(p.payment_value)
             / SUM(SUM(p.payment_value)) OVER (), 2)           AS kontribusi_pct,
       ROUND(AVG(p.payment_value), 2)                          AS rata_rata_per_transaksi
FROM order_payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_nilai DESC;


-- =====================================================
-- D3. Distribusi jumlah cicilan
-- =====================================================
SELECT p.payment_installments                          AS cicilan,
       COUNT(*)                                        AS jumlah_transaksi,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct,
       ROUND(AVG(p.payment_value), 2)                  AS rata_rata_nilai
FROM order_payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_installments
ORDER BY p.payment_installments;

-- =====================================================
-- D3b. Cicilan hanya untuk kartu kredit (metode lain umumnya 1x)
-- =====================================================
SELECT p.payment_installments                          AS cicilan,
       COUNT(*)                                        AS jumlah_transaksi,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM order_payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_type = 'credit_card'
GROUP BY p.payment_installments
ORDER BY p.payment_installments;

-- =====================================================
-- D4. Metode pembayaran vs transaksi bernilai tinggi
-- Ambang: persentil 90 dari total pembayaran per order
-- (dihitung per order agar tidak dobel; order multi-metode
--  dikelompokkan ke metode dengan nilai terbesar)
-- =====================================================
WITH total_order AS (
    SELECT p.order_id, SUM(p.payment_value) AS total
    FROM order_payments p
    JOIN orders o ON p.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.order_id
),
metode_utama AS (
    SELECT order_id, payment_type
    FROM (SELECT p.order_id, p.payment_type,
                 ROW_NUMBER() OVER (PARTITION BY p.order_id
                                    ORDER BY p.payment_value DESC) AS rn
          FROM order_payments p) x
    WHERE rn = 1
),
ranked AS (
    SELECT t.order_id, t.total, m.payment_type,
           PERCENT_RANK() OVER (ORDER BY t.total) AS pr
    FROM total_order t
    JOIN metode_utama m ON t.order_id = m.order_id
)
SELECT payment_type                                              AS metode,
       COUNT(*)                                                  AS jumlah_order,
       SUM(pr >= 0.9)                                            AS order_bernilai_tinggi,
       ROUND(100 * SUM(pr >= 0.9) / COUNT(*), 2)                 AS pct_tinggi_dalam_metode,
       ROUND(100 * SUM(pr >= 0.9) / SUM(SUM(pr >= 0.9)) OVER (), 2) AS pct_dari_semua_order_tinggi
FROM ranked
GROUP BY payment_type
ORDER BY order_bernilai_tinggi DESC;
