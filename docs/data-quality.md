# RAPORT JAKOŚCI DANYCH - Olist E-commerce

## Zakres i założenia
- Sprawdzono tabele: `orders`, `order_reviews`, `products`
- Pominięte (świadomie): `geolocation`, `sellers`, `customers`, `order_payments`, `order_items`, `product_category_name_translation`. Nie są potrzebne do analiz na obecnym etapie.
- Uwaga techniczna: wszystkie kolumny dat zostały zaimportowane jako varchar(50), więc braki występują pod postacią `NULL` oraz jako pusty ciąg znaków.


## Szczegóły

### 1. Tabela `Orders`:

- Kolumna `order_id` jest unikalnym kluczem głównym (99 441 wierszy)
- Dane zaczynają się od 4. dnia pierwszego miesiąca (2016 wrzesień), natomiast kończą się na 17. dniu ostatniego miesiąca (2018 październik).
- Wśród zamówień o statusie `delivered` (96 478 wierszy, ok. 97.02%) wykryto 23 zamówienia, które mają braki w przynajmniej jednej spośród 5 kolumn dat.  
- Dane obejmują okres od września 2016 do października 2018, jednak w 2016 roku występują anomalie i brak ciągłości (wrzesień - 4 zamówienia, październik - 324, listopad - 0, grudzień - 1), natomiast wrzesień i październik 2018 zawierają tylko pojedyncze zamówienia (kolejno: 16 i 4) 
- Niespójne daty etapów dostawy (np. kurier otrzymał paczkę, a sklep dopiero następnego dnia potwierdził zamówienie); 694 przypadki powyższych nieprawidłowości
- **Decyzja:** Wykluczenie niekompletnych zamówień z analiz czasu dostawy. Odrzucamy je bez wahania, bo mieszczą się w granicy błędy statystycznego (ok. 0.02%), a zostawienie ich stworzyłoby błędy przy liczeniu np. średniego czasu dostawy. Dodatkowo, w analizach zawężamy zakres danych do pełnego i stabilnego okresu 01.2017-08.2018. Wykluczone zostały również zamówienia z niespójnymi datami w przypadku obliczania średniego czasu realizacji etapu dostawy.

### 2. Tabela `order_reviews`
- Kolumna `review_id` nie jest unikalnym kluczem głównym - występuje 827 duplikatów
- Istnieje 555 zamówień, które mają więcej niż jedną recenzję (duplikaty mają różne podłoże, najwięcej z nich to edycje po czasie, jednakże, co do niektórych, na podstawie `order_reviews` nie można ustalić przyczyny)
- **Decyzja:**  Wzięte pod uwagę zostaną tylko najnowsze opinie z danego zamówienia.

### 3. Tabela `products`
- Znaleziono 610 produktów (ok. 1,85% z 32 951 wszystkich produktów) bez nadanej kategorii (Braki są w postaci `NULL` lub pusty ciąg znaków)
- **Decyzja:** Zastąpienie etykietą 'Unknown', aby nie tracić tych produktów podczas łączenia tabel w dalszych obliczeniach.

