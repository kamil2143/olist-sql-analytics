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


