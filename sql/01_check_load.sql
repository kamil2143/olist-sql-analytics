-- Porownuje liczbe wierszy w bazie z liczba oczekiwana dla standardowej wersji Olist.
WITH oczekiwane (tabela, liczba) AS (
    VALUES
        ('orders',          99441),
        ('customers',       99441),
        ('order_items',    112650),
        ('order_payments', 103886),
        ('order_reviews',   100000),
        ('products',        32951),
        ('sellers',          3095),
        ('geolocation',   1000163),
        ('translation',        71)
),
rzeczywiste (tabela, liczba) AS (
    SELECT 'orders',         COUNT(*) FROM orders
    UNION ALL SELECT 'customers',      COUNT(*) FROM customers
    UNION ALL SELECT 'order_items',    COUNT(*) FROM order_items
    UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
    UNION ALL SELECT 'order_reviews',  COUNT(*) FROM order_reviews
    UNION ALL SELECT 'products',       COUNT(*) FROM products
    UNION ALL SELECT 'sellers',        COUNT(*) FROM sellers
    UNION ALL SELECT 'geolocation',    COUNT(*) FROM geolocation
    UNION ALL SELECT 'translation',    COUNT(*) FROM product_category_name_translation
)
SELECT o.tabela,
       o.liczba AS oczekiwane,
       r.liczba AS w_bazie,
       CASE WHEN o.liczba = r.liczba THEN 'OK' ELSE 'ROZJAZD' END AS status
FROM oczekiwane o
JOIN rzeczywiste r USING (tabela)
ORDER BY o.tabela;