-- ===========================================================================
-- 50_customers.sql: klienci i ich powroty oraz rozklad wedlug stanow
-- Pytanie: czy klienci wracaja i gdzie sa?
-- Zapytania korzystaja glownie z analytics.orders_enriched
-- Brane sa pod uwage zamowienia ze statusem 'delivered'
-- ===========================================================================


-- ===========================================================================
-- 1. Odsetek klientów, którzy kupili więcej niż raz
-- ===========================================================================

WITH cust AS(
SELECT 
	c.customer_unique_id,
	COUNT(*) AS liczba_zamowien
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE order_status = 'delivered'
GROUP BY c.customer_unique_id
)
SELECT
	COUNT(customer_unique_id) AS liczba_klientow,
	COUNT(customer_unique_id) FILTER (WHERE liczba_zamowien >= 2) AS klienci_powracajacy,
	ROUND(COUNT(customer_unique_id) FILTER (
	WHERE liczba_zamowien >= 2) * 100.00 / COUNT(customer_unique_id),2) AS odsetek_powracajacych
FROM cust;

-- ===========================================================================
-- 2. Dni między pierwszym a drugim zamówieniem
-- ===========================================================================

WITH info AS(
SELECT c.customer_unique_id, oe.data_zakupu,
LAG(oe.data_zakupu) OVER(
PARTITION BY customer_unique_id ORDER BY oe.data_zakupu) AS data_poprzedniego_zakupu
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE oe.order_status = 'delivered'
), odstepy AS(
SELECT *,
	(data_zakupu::DATE - data_poprzedniego_zakupu::DATE) AS roznica_dni
FROM info
WHERE data_poprzedniego_zakupu IS NOT NULL
)
SELECT
	COUNT(*) AS liczba_odstepow,
	ROUND(AVG(roznica_dni),1) AS srednia_dni,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY roznica_dni)::NUMERIC , 1) AS mediana_dni
FROM odstepy;

-- ===========================================================================
-- 3. Klienci według stanów
-- ===========================================================================

SELECT 
	c.customer_state AS stan,
	COUNT(DISTINCT(c.customer_unique_id)) AS liczba_klientow,
	COUNT(*) AS liczba_zamowien,
	ROUND(AVG(oe.calkowity_przychod),2) AS srednia_wartosc_zamowienia,
	ROUND(COUNT(DISTINCT(c.customer_unique_id))*100.00/SUM(COUNT(DISTINCT(c.customer_unique_id))) OVER(),2) AS procent_klientow
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE oe.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY liczba_klientow DESC;

-- ===========================================================================
-- 4. Czy spoznienia mają wpływ na odsetek klientów powracających
-- ===========================================================================

-- 4.1 Odsetek powracających klientów (Wszystkie zamówienia)
WITH klienci AS(
SELECT 
	c.customer_unique_id,
	oe.order_id,
	oe.data_zakupu,
	ROW_NUMBER() OVER(PARTITION BY customer_unique_id ORDER BY data_zakupu) AS rn,
	oe.czy_spoznione,
	COUNT(oe.order_id) OVER(PARTITION BY c.customer_unique_id) AS liczba_zamowien
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE order_status = 'delivered'
AND oe.czy_spoznione IS NOT NULL
)
SELECT
	CASE
		WHEN czy_spoznione THEN 'Spoznione'
		ELSE 'Na czas'
	END AS status_pierwszej_dostawy,
	COUNT(customer_unique_id) AS liczba_klientow,
	ROUND(COUNT(*) FILTER (WHERE liczba_zamowien >=2)*100.00 / COUNT(*),2) AS odsetek_powracajacych
FROM klienci
WHERE rn = 1
GROUP BY czy_spoznione;

-- 4.2 Odsetek powracających klientów (Zamówienia tylko sprzed 2018 roku)
WITH klienci AS(
SELECT 
	c.customer_unique_id,
	oe.order_id,
	oe.data_zakupu,
	ROW_NUMBER() OVER(PARTITION BY customer_unique_id ORDER BY data_zakupu) AS rn,
	oe.czy_spoznione,
	COUNT(oe.order_id) OVER(PARTITION BY c.customer_unique_id) AS liczba_zamowien
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE order_status = 'delivered'
AND oe.czy_spoznione IS NOT NULL
)
SELECT
	CASE
		WHEN czy_spoznione THEN 'Spoznione'
		ELSE 'Na czas'
	END AS status_pierwszej_dostawy,
	COUNT(customer_unique_id) AS liczba_klientow,
	ROUND(COUNT(*) FILTER (WHERE liczba_zamowien >=2)*100.00 / COUNT(*),2) AS odsetek_powracajacych
FROM klienci
WHERE rn = 1
	AND data_zakupu < '2018-01-01'
GROUP BY czy_spoznione;
