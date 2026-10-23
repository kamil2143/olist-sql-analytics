-- ===========================================================================
-- 1. Sprawdzenie procentu spóźnionych dostaw zamówień z podziałem miesięcznym
-- ===========================================================================

SELECT
	TO_CHAR(data_zakupu,'YYYY-MM') AS miesiac,
	COUNT(order_id) AS liczba_zamowien,
	COUNT(*) FILTER (WHERE czy_spoznione) AS liczba_spoznionych,
	ROUND(COUNT(order_id) FILTER(WHERE czy_spoznione) * 100.00 / COUNT(czy_spoznione),2) AS procent_spoznionych
FROM analytics.orders_enriched
WHERE order_status = 'delivered'
GROUP BY TO_CHAR(data_zakupu,'YYYY-MM')
ORDER BY miesiac;

-- =========================================================================
-- 2. Średni czas dostawy według stanów
-- =========================================================================

SELECT
	c.customer_state AS stan,COUNT(*) AS liczba_zamowien,
	ROUND(AVG(oe.czas_dostawy),2) AS sredni_czas_dostawy
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE oe.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY sredni_czas_dostawy DESC;

-- =========================================================================
-- 3. Stany z największym odsetkiem opóźnień
-- =========================================================================

SELECT 
	c.customer_state AS stan,
	COUNT(*) AS ilosc_zamowien,
	COUNT(*) FILTER (WHERE dni_spoznienia > 0) AS liczba_spoznionych,
	ROUND((COUNT(*) FILTER (WHERE dni_spoznienia > 0) * 100.00 / COUNT(*)),2) AS odsetek_spoznionych
FROM analytics.orders_enriched AS oe
LEFT JOIN customers AS c
ON oe.customer_id = c.customer_id
WHERE czy_spoznione IS NOT NULL
	AND order_status = 'delivered'
GROUP BY customer_state
ORDER BY odsetek_spoznionych DESC;

-- =========================================================================
-- 4. Średnia ocena klienta dla dostaw na czas i opóźnionych
-- =========================================================================

SELECT
	CASE
		WHEN czy_spoznione THEN 'spoznione'
		ELSE 'na czas'
	END AS status_dostawy,
	ROUND(AVG(wystawiona_ocena),2) AS srednia_ocen,
	ROUND((COUNT(*) FILTER (WHERE wystawiona_ocena <= 2)*100.00/COUNT(*)),2) AS odsetek_zlych_ocen,
	COUNT(*) AS liczba_zamowien
FROM analytics.orders_enriched
WHERE order_status = 'delivered'
	AND wystawiona_ocena IS NOT NULL
	AND czy_spoznione IS NOT NULL
GROUP BY status_dostawy;
	
-- =========================================================================
-- 5. Analiza kiedy długość spóźnienia zaczyna wpływać na ocenę
-- =========================================================================

SELECT
	CASE
		WHEN dni_spoznienia <= 0 THEN 'Brak opoznien'
		WHEN dni_spoznienia <= 3 THEN '1-3 dni opoznienia'
		WHEN dni_spoznienia <= 7 THEN '4-7 dni opoznienia'
		ELSE '>7 dni opoznienia'
	END AS przedzial_spoznienia,
	COUNT(*) AS liczba_zamowien,
	ROUND(AVG(wystawiona_ocena),2) AS srednia_ocen,
	ROUND((COUNT(*) FILTER (WHERE wystawiona_ocena <= 2)*100.00/COUNT(*)),2) AS odsetek_zlych_ocen
FROM analytics.orders_enriched
WHERE dni_spoznienia IS NOT NULL
	AND wystawiona_ocena IS NOT NULL
	AND order_status = 'delivered'
GROUP BY przedzial_spoznienia
ORDER BY MIN(dni_spoznienia);

-- =========================================================================
-- 6. Analiza opóźnień w podziale na etapy realizacji dostawy
-- =========================================================================

-- 6.1 Sprawdzenie liczby zamówień, w których daty są niespójne (694 przypadków)
WITH czasy_realizacji AS(
SELECT
	order_id,
	(data_potwierdzenia_zakupu - data_zakupu::DATE) AS czas_realizacji_zakup_sklep,
	(data_otrzymania_przez_kuriera - data_potwierdzenia_zakupu) AS czas_realizacji_sklep_kurier,
	(data_dostarczenia - data_otrzymania_przez_kuriera) AS czas_realizacji_kurier_klient,
	czas_dostawy,
	czy_spoznione
FROM analytics.orders_enriched
WHERE order_status = 'delivered' AND
	czy_spoznione IS NOT NULL AND
	data_otrzymania_przez_kuriera IS NOT NULL AND
	data_potwierdzenia_zakupu IS NOT NULL
)SELECT
	COUNT(*) AS wszystkie,
	COUNT(*) FILTER(
		WHERE czas_realizacji_zakup_sklep < 0
			OR czas_realizacji_sklep_kurier < 0
			OR czas_realizacji_kurier_klient < 0
			) AS z_ujemnym_etapem
FROM czasy_realizacji;

-- 6.2 Średni czas etapu realizacji dostawy przesyłki
WITH czasy_realizacji AS(
SELECT
	order_id,
	(data_potwierdzenia_zakupu - data_zakupu::DATE) AS czas_realizacji_zakup_sklep,
	(data_otrzymania_przez_kuriera - data_potwierdzenia_zakupu) AS czas_realizacji_sklep_kurier,
	(data_dostarczenia - data_otrzymania_przez_kuriera) AS czas_realizacji_kurier_klient,
	czas_dostawy,
	czy_spoznione
FROM analytics.orders_enriched
WHERE order_status = 'delivered' AND
	czy_spoznione IS NOT NULL AND
	data_otrzymania_przez_kuriera IS NOT NULL AND
	data_potwierdzenia_zakupu IS NOT NULL
)SELECT
	CASE
		WHEN czy_spoznione = TRUE THEN 'Spoznione'
		ELSE 'Niespoznione'
	END AS status_dostawy,
	ROUND(AVG(czas_realizacji_zakup_sklep),2) AS sredni_czas_zakup_sklep,
	ROUND(AVG(czas_realizacji_sklep_kurier),2) AS sredni_czas__sklep_kurier,
	ROUND(AVG(czas_realizacji_kurier_klient),2) AS sredni_czas_kurier_klient,
	COUNT(*) AS ilosc_zamowien
FROM czasy_realizacji
WHERE czas_realizacji_zakup_sklep >= 0
	AND czas_realizacji_sklep_kurier >= 0
	AND czas_realizacji_kurier_klient >= 0
GROUP BY czy_spoznione
ORDER BY status_dostawy;