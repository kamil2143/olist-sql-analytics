-- =======================================================================
-- 1.Sprawdzenie, czy klucze tabel orders oraz order_reviews są unikalne --
-- =======================================================================

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

-- =======================================================================
-- 2. Statusy zamówień i ich udział w całości --
-- =======================================================================

SELECT order_status, COUNT(*) AS ilosc_zamowien, ROUND((COUNT(*)*100.0/SUM(COUNT(*)) OVER()),2) AS wskaznik_procentowy
FROM orders
GROUP BY order_status
ORDER BY ilosc_zamowien DESC;

-- =======================================================================
-- 3. Zakres dat i liczba zamówień na miesiąc
-- =======================================================================

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