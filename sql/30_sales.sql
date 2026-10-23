-- =========================================================================
-- 30_sales.sql: sprzedaz w czasie, kategorie i stany
-- Pytanie: jak zmienia sie sprzedaz i skad pochodzi przychod?
-- Zapytania korzystaja glownie z analytics.orders_enriched
-- Brane pod uwage sa zamowienia ze statusem `delivered` lub `shipped`
-- =========================================================================


-- =========================================================================
-- 1. Miesięczny trend sprzedaży i dynamika
-- =========================================================================

WITH miesieczna_sprzedaz AS(
SELECT
	DATE_TRUNC('month', data_zakupu)::DATE AS miesiac,
	COUNT(order_id) AS liczba_zamowien,
	SUM(cena_przedmiotow) AS przychod_produkty,
	SUM(calkowity_przychod) AS calkowity_przychod,
	ROUND(AVG(cena_przedmiotow),2) AS srednia_koszyka,
	LAG(SUM(calkowity_przychod)) OVER(ORDER BY DATE_TRUNC('month', data_zakupu)::DATE) AS poprzedni_miesiac
FROM analytics.orders_enriched
WHERE (order_status = 'delivered' OR order_status = 'shipped') AND data_zakupu::DATE BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY miesiac
)
SELECT *, ROUND((calkowity_przychod-poprzedni_miesiac)/(poprzedni_miesiac)*100.00,2) AS zmiana_miesieczna_proc
FROM miesieczna_sprzedaz
ORDER BY miesiac;

-- =========================================================================
-- 2. Top kategorie wg przychodu, udział w całości i ranking
-- =========================================================================

WITH przychody_kategorii AS(
SELECT 
	SUM(oi.price+oi.freight_value) AS przychod,
	COALESCE(NULLIF(TRIM(pt.product_category_name_english),''),'unknown') AS nazwa_kategorii
FROM order_items AS oi
LEFT JOIN orders AS o
ON oi.order_id = o.order_id
LEFT JOIN products AS p
ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation AS pt
ON p.product_category_name = pt.product_category_name
WHERE order_status IN ('delivered','shipped')
GROUP BY nazwa_kategorii
)
SELECT 
	przychod,
	nazwa_kategorii,
	ROUND((przychod * 100.00) / SUM(przychod) OVER(),2) AS procent_calosci,
	DENSE_RANK() OVER(ORDER BY przychod DESC) AS ranking
FROM przychody_kategorii
ORDER BY ranking;

-- =========================================================================
-- 3. Sprzedaż i średnia wartość koszyków według stanów
-- =========================================================================

SELECT
	c.customer_state AS stan,
	SUM(oe.calkowity_przychod) AS przychod,
	COUNT(oe.order_id) AS liczba_zamowien,
	ROUND(AVG(oe.cena_przedmiotow),2) AS srednia_koszyka
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE oe.order_status IN ('delivered','shipped')
GROUP BY c.customer_state
ORDER BY przychod DESC;

-- =========================================================================
-- 4. Rozkład sprzedaży w ujęciu godzinowym i dniowym
-- =========================================================================

-- 4.1 Rozklad w ujeciu godzinowym
SELECT
	EXTRACT('hour' FROM data_zakupu) AS godzina_zakupu,
	COUNT(order_id) AS liczba_zamowien,
	SUM(calkowity_przychod) AS przychod,
	ROUND(AVG(calkowity_przychod),2) AS srednia_koszyka,
	ROUND(COUNT(order_id) * 100.00 / SUM(COUNT(order_id)) OVER(),2) AS procent_wszystkich_zamowien
FROM analytics.orders_enriched
WHERE order_status IN ('delivered','shipped')
GROUP BY godzina_zakupu
ORDER BY godzina_zakupu;

-- 4.2 Rozklad w ujeciu dniowym
SELECT
	EXTRACT(isodow FROM data_zakupu) AS dzien_zakupu,
	COUNT(order_id) AS liczba_zamowien,
	SUM(calkowity_przychod) AS przychod,
	ROUND(AVG(calkowity_przychod),2) AS srednia_koszyka,
	ROUND(COUNT(order_id) * 100.00 / SUM(COUNT(order_id)) OVER(),2) AS procent_wszystkich_zamowien
FROM analytics.orders_enriched
WHERE order_status IN ('delivered','shipped')
GROUP BY dzien_zakupu
ORDER BY dzien_zakupu;
