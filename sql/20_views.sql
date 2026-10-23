-- =============================================================================
-- 20_views.sql: warstwa analityczna analytics.orders_enriched
-- Cel: czysty i praktyczny widok na poziomie zamowienia, do pracy na plikach 30_-50_
-- 1 wiersz = 1 order_id (99 441 wierszy)
-- Definicje metryk znajduja sie w docs/metrics.md
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.orders_enriched AS

WITH przychody AS(
SELECT 
	order_id,
	COUNT(*) AS liczba_przedmiotow,
	ROUND(SUM(price)::NUMERIC,2) AS cena_przedmiotow,
	ROUND(SUM(freight_value)::NUMERIC,2) AS cena_wysylki,
	ROUND(SUM(price+freight_value)::NUMERIC,2) AS calkowity_przychod
FROM order_items
GROUP BY order_id
),
wyczyszczone_recenzje AS (
SELECT 
	order_id,
	review_id,
	review_score AS wystawiona_ocena,
	review_answer_timestamp,
	ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY review_answer_timestamp DESC, review_id) AS rn
FROM order_reviews
),
wyczyszczone_daty AS(
SELECT
	order_id,
	customer_id,
	order_status,
	NULLIF(TRIM(order_purchase_timestamp),'')::TIMESTAMP AS data_zakupu,
	NULLIF(TRIM(order_delivered_customer_date),'')::DATE AS data_dostarczenia,
	NULLIF(TRIM(order_delivered_carrier_date),'')::DATE AS data_otrzymania_przez_kuriera,
	NULLIF(TRIM(order_approved_at),'')::DATE AS data_potwierdzenia_zakupu,
	NULLIF(TRIM(order_estimated_delivery_date),'')::DATE AS szacowana_data_dostarczenia
FROM orders
)
SELECT 
	d.order_id,
	d.customer_id,
	d.order_status,
	d.data_zakupu,
	(d.data_dostarczenia-d.data_zakupu::DATE) AS czas_dostawy,
	CASE
		WHEN d.data_dostarczenia IS NULL THEN NULL
		WHEN d.data_dostarczenia > d.szacowana_data_dostarczenia THEN TRUE
		ELSE FALSE
	END AS czy_spoznione,
	p.liczba_przedmiotow,
	p.cena_przedmiotow,
	p.cena_wysylki,
	p.calkowity_przychod,
	wr.wystawiona_ocena,
	(d.data_dostarczenia - d.szacowana_data_dostarczenia) AS dni_spoznienia,
	d.data_otrzymania_przez_kuriera,
	d.data_potwierdzenia_zakupu,
	d.data_dostarczenia
FROM wyczyszczone_daty d
LEFT JOIN przychody p
	ON d.order_id = p.order_id
LEFT JOIN wyczyszczone_recenzje wr
	ON wr.order_id = d.order_id AND wr.rn=1;
