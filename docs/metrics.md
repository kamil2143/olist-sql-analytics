# Definicje metryk (`analytics.orders_enriched`)

## Widok `analytics.orders_enriched` stanowi oczyszczoną warstwę analityczną dla poszczególnych zamówień (1 wiersz = 1 order_id, łącznie 99441 wierszy).

### 1. Metryki finansowe (przychód):
- liczba_przedmiotow - liczba pozycji (`COUNT(*)`) wchodzących w skład zamówienia.
- cena_przedmiotow - suma cen produktów w zamówieniu zaokrąglona do 2 miejsc po przecinku.
- cena_wysylki - całkowity koszt dostawy przypisany do danego zamówienia (`SUM(freight_value)`) zaokrąglony do 2 miejsc po przecinku.
- calkowity_przychod - łączna kwota zamówienia, całkowity koszt poniesiony przez klienta (`SUM(price+freight_value)`)

**UWAGA:** Zamówienia nieposiadające pozycji w `order_items` (np. anulowane na wczesnym etapie) przyjmują w powyższych kolumnach wartość NULL.

### 2. Metryki logistyczne (Czas dostawy i spóźnienia)
- data_zakupu - data i godzina złożenia zamówienia oczyszczona z pustych znaków i ze zmienionym typem na `TIMESTAMP`.
- czas_dostawy - liczba pełnych dni kalendarzowych od zakupu do doręczenia paczki (`data_dostarczenia - data_zakupu`)
- czy_spoznione - boolean określający, czy zamówienie dotarło po wyznaczonym szacowanym terminie dostawy (`TRUE` - dzien dostarczenia > szacowana data dostarczenia, `FALSE` gdy dotarło na czas)
- dni_spoznienia - różnica dni między datą dostarczenia a pierwotnie szacowanym terminem (`data_dostarczenia - szacowana_data_dostarczenia`). Jeśli występuje wartość dodatnia, to oznacza opóźnienie, jeśli ujemna - brak opóźnień/dotarcie przesyłki przed czasem.
- data_dostarczenia - data doręczenia paczki klientowi(`order_delivered_customer_date`), jako `DATE`.
- data_potwierdzenia_zakupu - data zatwierdzzenia zamówienia przez sklep (`order_approved_at`), jako `DATE`.
- data_otrzymania_przez_kuriera - data przekazania paczki kurierowi (`order_delivered_carrier_date`), jako `DATE`.

**UWAGA:** Dla zamówień, które nie mają wprowadzonej daty dostarczenia, kolumny `czas_dostawy` oraz `czy_spoznione` przyjmują wartość NULL. Daty zostały porównane jako pełne dni, ponieważ szacowana data ma zawsze wpisaną godzinę `00:00:00`.

### 3. Oceny klientów (Recenzje):
- wystawiona_ocena - ocena zamówienia w skali 1-5 (kolumna `review_score` z tabeli `order_reviews`).

**UWAGA:** Część zamówień w bazie posiada więcej niż jedna recenzję. Aby uniknąć duplikatów wierszy przy łączeniu tabel, użyto funkcji `ROW_NUMBER()` i wybrano dla każdego zamówienia jedną, najnowszą opinię według `review_answer_timestamp`(w przypadku identycznego czasu o kolejności decyduje `review_id`). Zamówienia bez wystawionej recenzji mają wartość NULL.