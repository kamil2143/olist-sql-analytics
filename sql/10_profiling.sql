-- =========================================================================
-- 1.Sprawdzenie, czy klucze tabel orders oraz order_reviews są unikalne --
-- =========================================================================

-- 1.1 Tabela orders: Weryfikacja, czy order_id jest unikalnym kluczem głównym(Tak, wynik: roznica = 0)
SELECT COUNT(*) AS liczba_wierszy, COUNT(DISTINCT order_id) AS liczba_unikalnych_idzamowien, COUNT(*) - COUNT(DISTINCT order_id) AS roznica
FROM orders;

-- 1.2 Tabela review_id: Czy review_id jest unikalnym kluczem głównym(Nie, wynik: roznica = 827 duplikatów)
SELECT COUNT(*) AS liczba_wierszy, COUNT(DISTINCT review_id) AS liczba_unikalnych_reviewid, COUNT(*) - COUNT(DISTINCT review_id) AS roznica
FROM order_reviews;

-- 1.3 Tabela review_id: Sprawdzenie ilości zamówień z więcej niż jedną recenzją (Wynik: 555))
WITH CTE1 AS(
SELECT order_id, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) AS rn
FROM order_reviews
)
SELECT COUNT(*) AS zamowienia_zduplikowane
FROM CTE1
WHERE rn=2;

-- =========================================================================
-- 2. Statusy zamówień i ich udział w całości --
-- =========================================================================

SELECT order_status, COUNT(*) AS ilosc_zamowien, ROUND((COUNT(*)*100.0/SUM(COUNT(*)) OVER()),2) AS wskaznik_procentowy
FROM orders
GROUP BY order_status
ORDER BY ilosc_zamowien DESC;

-- =========================================================================
-- 3. Zakres dat i liczba zamówień na miesiąc --
-- =========================================================================

-- 3.1 Sprawdzenie skrajnych miesięcy, czy dane pokrywają każdy dzień, czy tylko część(Pierwszy zaczyna się od 4 dnia, ostatni kończy na 17 dniu)
SELECT
	MIN(order_purchase_timestamp::TIMESTAMP) AS data_pierwszej_transakcji,
	MAX(order_purchase_timestamp::TIMESTAMP) AS data_ostatniej_transakcji
FROM orders;

-- 3.2 Liczba zamówień w poszczególnych miesiącach
SELECT DATE_TRUNC('month', order_purchase_timestamp::TIMESTAMP) AS miesiac, COUNT(*) AS liczba_zamowien
FROM orders
GROUP BY miesiac
ORDER BY miesiac;

-- =========================================================================
-- 4. Braki w kolumnach --
-- =========================================================================

-- 4.1 Liczba unikalnych zamówień z brakiem w dowolnej spośród 5 kolumn dat (Wynik: 23)
SELECT COUNT(*)
FROM orders
WHERE order_status = 'delivered' AND 
(
	(order_purchase_timestamp IS NULL
	OR LENGTH(TRIM(order_purchase_timestamp))<10) OR
	(order_approved_at IS NULL
	OR LENGTH(TRIM(order_approved_at))<10) OR
	(order_delivered_carrier_date IS NULL
	OR LENGTH(TRIM(order_delivered_carrier_date))<10) OR
	(order_delivered_customer_date  IS NULL
	OR LENGTH(TRIM(order_delivered_customer_date))<10) OR
	(order_estimated_delivery_date IS NULL
	OR LENGTH(TRIM(order_estimated_delivery_date))<10)
);

-- 4.2 Rozbicie informacji o liczbie braków na kolumny
SELECT
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL OR LENGTH(TRIM(order_purchase_timestamp)) < 10)           AS purchase_blad,
    COUNT(*) FILTER (WHERE order_approved_at IS NULL OR LENGTH(TRIM(order_approved_at)) < 10)                         AS approved_blad,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL OR LENGTH(TRIM(order_delivered_carrier_date)) < 10)   AS carrier_blad,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL OR LENGTH(TRIM(order_delivered_customer_date)) < 10) AS customer_blad,
    COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL OR LENGTH(TRIM(order_estimated_delivery_date)) < 10) AS estimated_blad,
    COUNT(*) AS total_delivered
FROM orders
WHERE order_status = 'delivered';


-- =========================================================================
-- 5. Zamówienia z więcej niż jedną recenzją (Istnieją duplikaty i edycje) --
-- =========================================================================
SELECT *
FROM order_reviews
WHERE order_id IN(
SELECT order_id
FROM order_reviews
GROUP BY order_id
HAVING COUNT(review_id) > 1
)
ORDER BY order_id;

-- =========================================================================
-- 6. Liczba produktów nie mających przypisanej kategorii (Wynik: 610) --
-- =========================================================================
SELECT COUNT(*) AS ilosc
FROM products
WHERE product_category_name IS NULL OR LENGTH(TRIM(product_category_name))=0;

SELECT COUNT(order_id)
FROM orders;