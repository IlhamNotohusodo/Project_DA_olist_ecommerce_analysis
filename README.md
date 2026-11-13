# Olist E-Commerce Analysis

End-to-end analysis of the Olist Brazilian e-commerce dataset using **Python (Pandas), MySQL, and Power BI**: sales, product, customer, payment, and delivery & satisfaction analysis.

## 1. Latar Belakang

Olist adalah marketplace Brasil yang menghubungkan penjual kecil dengan pelanggan di seluruh negeri. Proyek ini menganalisis data transaksi Olist untuk menjawab lima pertanyaan bisnis:

| Analisis | Tujuan |
|---|---|
| A. Sales Performance | Mengetahui performa penjualan |
| B. Product Performance | Mengetahui performa produk dan kategori |
| C. Customer | Memahami perilaku dan sebaran pelanggan |
| D. Payment | Mengetahui metode dan pola pembayaran |
| E. Delivery & Satisfaction | Mengevaluasi pengiriman dan kepuasan pelanggan |

## 2. Dataset

- Sumber: [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- Periode data: **[2016] s/d [2018]**
- 9 file CSV yang saling berelasi (orders, order_items, order_payments, order_reviews, customers, products, sellers, category_translation, geolocation). Tabel geolocation tidak dipakai.
- File CSV **tidak diunggah** ke repo (ukuran besar dan lisensi dataset). Unduh dari Kaggle, lalu taruh di `data/raw/`.

## 3. Tools

| Tools | Fungsi |
|---|---|
| Python Pandas | Data cleaning dan EDA |
| MySQL | Database dan SQL analysis |
| Power BI | Dashboard dan visualisasi |
| GitHub | Dokumentasi portofolio |

## 4. Definisi Metrik

- **Revenue** = `SUM(price)` dari `order_items`, hanya order berstatus `delivered` (ongkir dipisah)
- **AOV (rata-rata nilai transaksi)** = revenue / jumlah order unik
- **Pesanan terlambat** = `order_delivered_customer_date` > `order_estimated_delivery_date`
- **Pelanggan unik** = `customer_unique_id` (bukan `customer_id`, yang berbeda untuk tiap pesanan)

## 5. Struktur Repo

```
Project_DA_olist_ecommerce_analysis/
├── data/
│   ├── raw/          # CSV asli dari Kaggle (tidak di-upload)
│   └── clean/        # hasil cleaning (tidak di-upload)
├── notebooks/
│   └── 01_cleaning_eda.ipynb
├── sql/
│   ├── 01_create_tables.sql
│   ├── 01b_load_data.sql
│   ├── 02_sales_analysis.sql
│   ├── 03_product_analysis.sql
│   ├── 04_customer_analysis.sql
│   ├── 05_payment_analysis.sql
│   └── 06_delivery_satisfaction.sql
├── dashboard/        # file .pbix dan screenshot
└── README.md
```

## 6. Alur Kerja

1. **Cleaning & EDA (Python):** memuat dan memeriksa tabel, memperbaiki tipe data, menangani missing value dan duplikat, membuat kolom baru (`order_month`, `delivery_days`, `is_late`), lalu menyimpan hasil bersih.
2. **Database (MySQL):** membuat 7 tabel, mengimpor data bersih dengan `LOAD DATA LOCAL INFILE`, dan menambahkan index pada kolom join.
3. **Analisis (SQL):** satu file query untuk tiap analisis (A sampai E).
4. **Visualisasi (Power BI):** dashboard 5 halaman, satu halaman per analisis.

## 7. Data Cleaning

Keputusan utama saat cleaning (isi dengan angka dari notebook):

1. Dari **[JUMLAH]** order, **[JUMLAH]** berstatus `delivered`. Status lain (canceled, shipped, dll.) dikeluarkan dari analisis revenue.
2. **[JUMLAH]** order `delivered` tidak punya tanggal tiba, sehingga dikeluarkan dari analisis pengiriman.
3. **[JUMLAH]** order punya lebih dari satu review. Diambil review terbaru agar join tidak menggandakan baris.
4. **[JUMLAH]** produk tanpa kategori diisi `unknown`.
5. **[JUMLAH]** kategori tanpa terjemahan ditambahkan manual (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`).
6. Satu order bisa punya banyak item dan banyak baris pembayaran. Semua agregasi memakai `COUNT(DISTINCT order_id)` atau dihitung per order dulu untuk mencegah penghitungan ganda (*fan-out*).

## 8. Temuan Utama

### A. Sales Performance
- Total revenue **R$ [ANGKA]** dari **[JUMLAH]** order, dengan AOV **R$ [ANGKA]**.
- Bulan dengan revenue tertinggi: **[BULAN]** (R$ [ANGKA]).
- Tren: **[naik / turun / stabil, dan kapan]**.

### B. Product Performance
- Kategori terlaris berdasarkan unit: **[KATEGORI]** ([JUMLAH] unit).
- Kategori dengan revenue tertinggi: **[KATEGORI]** (R$ [ANGKA], [X]% dari total).
- Perbedaan keduanya disebabkan harga rata-rata per unit: R$ [ANGKA] vs R$ [ANGKA].
- **[N]** kategori teratas menyumbang 80% revenue.

### C. Customer
- Jumlah pelanggan unik: **[JUMLAH]**.
- Wilayah terbanyak: **[STATE]** ([X]% pelanggan), disusul **[STATE]** dan **[STATE]**.
- Nilai order paling banyak berada di rentang **[RENTANG]**, rata-rata R$ [ANGKA].
- Pelanggan repeat hanya **[X]%**, menandakan retensi yang rendah.

### D. Payment
- Metode paling banyak: **[METODE]** ([X]% order), menyumbang [X]% total nilai.
- Cicilan paling umum: **[N]x**. Cicilan panjang (6x atau lebih) lebih sering muncul pada transaksi bernilai besar: **[YA / TIDAK, DENGAN ANGKA]**.
- Pada transaksi bernilai tinggi (10% teratas), metode dominan adalah **[METODE]** ([X]%).

### E. Delivery & Customer Satisfaction
- Rata-rata waktu pengiriman **[X] hari** (estimasi rata-rata [X] hari).
- **[X]%** pesanan terlambat dari estimasi.
- Rating pesanan tepat waktu **[X]** vs pesanan terlambat **[X]**. Semakin lama keterlambatan, semakin rendah rating.
- Rata-rata rating keseluruhan: **[X]**.
- State dengan keterlambatan tertinggi: **[STATE]** dan **[STATE]**.

## 9. Dashboard

*(Tambahkan screenshot setelah dashboard Power BI selesai.)*

| Halaman | Isi |
|---|---|
| Sales | KPI revenue, order, AOV, tren bulanan |
| Product | Top kategori, kontribusi revenue |
| Customer | Sebaran state, repeat vs one-time |
| Payment | Metode bayar, distribusi cicilan |
| Delivery | Waktu kirim, late rate, rating vs keterlambatan |

<!-- ![Sales](dashboard/sales.png) -->

## 10. Rekomendasi Bisnis

1. **Perbaiki logistik di [STATE]** yang keterlambatannya tertinggi, karena keterlambatan berkaitan dengan rating rendah.
2. **Dorong pembelian ulang** (voucher, email pasca-pembelian), karena hanya [X]% pelanggan yang membeli lebih dari sekali.
3. **Fokus pada kategori bernilai tinggi** seperti [KATEGORI], yang memberi revenue besar dengan unit lebih sedikit.
4. **Tawarkan cicilan** pada produk bernilai besar, karena [X]% transaksi bernilai tinggi memakai cicilan.

## 11. Keterbatasan

- Data 2016 sangat sedikit dan akhir 2018 tidak lengkap, sehingga angka tren di periode itu tidak mencerminkan kondisi bisnis sebenarnya.
- `customer_unique_id` tidak sempurna mengidentifikasi pelanggan yang sama, jadi persentase repeat adalah perkiraan.
- Tidak ada data biaya, sehingga profit tidak bisa dihitung. Analisis hanya sampai revenue.
- Rating hanya berasal dari order yang direview. Hubungan keterlambatan dan rating adalah korelasi, bukan bukti sebab-akibat.
- `payment_value` sudah termasuk ongkir, jadi total pembayaran lebih besar dari revenue.

## 12. Cara Menjalankan Ulang

1. Unduh dataset dari Kaggle ke `data/raw/`.
2. Jalankan `notebooks/01_cleaning_eda.ipynb` (menghasilkan `data/clean/`).
3. Di MySQL, jalankan `sql/01_create_tables.sql`, lalu `sql/01b_load_data.sql` (aktifkan `local_infile`, sesuaikan path file).
4. Jalankan `sql/02` sampai `sql/06` untuk analisis A sampai E.
5. Buka file `.pbix` di `dashboard/` dengan Power BI Desktop.

## 13. Author

**Ilham Notohusodo**, [GitHub](https://github.com/IlhamNotohusodo)
