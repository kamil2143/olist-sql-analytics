# Analiza e-commerce Olist: Sprzedaż, dostawy i klienci (SQL)
Analiza ok. 100 tys. zamówień brazylijskiego marketplace'u Olist (2016-2018), wykonana w PostgreSQL.

## Trzy pytania biznesowe:
1. **Sprzedaż:** jak zmieniała się sprzedaż z podziałem na miesiące, które kategorie i regiony generują największy przychód oraz kiedy klienci najczęściej kupują (podział na dni tygodnia i godziny dnia).
2. **Dostawy:** ile zamówień przychodzi opóźnionych, na którym etapie powstają opóźnienia i jak wpływają na oceny.
3. **Klienci:** czy klienci wracają i zamawiają ponownie oraz czy spóźnienie wpływa na to.

## Najważniejsze ustalenia
### Sprzedaż
1. Sprzedaż silnie rosła, z wyraźnym szczytem w okresie świątecznym i na przełomie roku 2017 oraz 2018. Całkowity przychód wzrósł ze 130 446 R$ (sty 2017) do nawet 1 161 986 R$ (lis 2017). Prawdopodobnie było to związane z Black Friday. W 2018 roku wzrost ten jednak wyhamował: miesięcznie składano 6,1-7,1 tys. zamówień (ok. 1,0-1,15 mln R$ przychodu) bez wyraźnego trendu.
2. Zakupy rozkładają się równo między godz. 10 a 23, natomiast między 2 a 6 rano jest bardzo mało zamówień. W godzinach 10-23 składane jest 81,5% zamówień. Nie ma wyraźnego szczytu, więc nie da się wyznaczyć "złotej godziny". Klienci kupują wyraźnie rzadziej w weekendy. Średnio jeden dzień roboczy generuje ok. 15,4% wszystkich zamówień, natomiast jeden dzień weekendu ok. 11,5%.
3. Przychód jest silnie skoncentrowany: 18 spośród 72 kategorii daje ok. 80% całkowitego przychodu, natomiast 5 stanów z 27 ok. 73%. Największe kategorie to health_beauty (9,2% całkowitego przychodu), watches_gifts (8,3%) i bed_bath_table (7,9%). Największe stany to SP,RJ,MG.

### Dostawy i oceny
4. Spóźnione dostawy obniżają oceny. W przypadku zamówień dostarczonych na czas średnia ocena wynosi 4,28, a w przypadku spóźnionych ok. 2,26 (Odsetek ocen 1-2 gwiazdki to 62,9% wobec 9,5% w przypadku zamówień na czas). Już 1-3 dni opóźnienia obniża średnią ocenę z 4,28 do 3,28 i zwiększa udział złych ocen z 9,5% do 32,4%. Największy skok jest między 1-3 a 4-7 dniami (32,4% do 68,1% złych ocen), natomiast po 7 dniach prawie 80% ocen jest negatywnych.
5. Opóźnienia powstają głównie w trakcie transportu do klienta, a nie u sprzedawcy. Spóźnione zamówienia idą od zakupu do dostawy średnio ok. 33,9 dnia wobec 11,0 dnia dla dostaw na czas (różnica 22,9 dnia). Aż 87% tej różnicy to etap od odbioru paczki przez kuriera do dostarczenia jej klientowi, 13% to etap sprzedawca -> kurier. Największy odsetek spóźnień mają stany: AL (21,4%), MA (17,4%), SE (15,2%), PI (13,9%). Spóźnienia też są skupione w czasie: najwięcej - listopad 2017 (12,4%) oraz luty 2018 (14,1%) i marzec 2018 (19,0%).

### Klienci
6. Bardzo niewielu klientów wraca, a po spóźnionej dostawie jeszcze mniej. Tylko 3,0% klientów złożyło więcej niż jedno zamówienie. Średni czas między zamówieniami wynosi 79,1 dnia, zaś mediana to 29 dni. Klienci, których pierwsze zamówienie przyszło spóźnione, wracają rzadziej: 2,5% wobec 3,0%. Powtórzyłem porównanie dla klientów z pierwszym zamówieniem przed 2018 rokiem, aby każdy miał podobnie dużo czasu na powrót. Wyniki to 4,3% powracających w przypadku dostawy na czas i 2,8% dla spóźnionej dostawy (n = 2389/40004).

## Wnioski i rekomendacje

### Wnioski
- **Największy potencjał poprawy leży w transporcie do klienta.** To tam powstaje ok. 87% dodatkowego czasu spóźnionych zamówień, a opóźnienia po stronie sprzedawców są wyraźnie mniejsze.
- **Spóźnienie silnie obniżą oceny już od 1-3 dni**, a najmocniej po 4-7 dniach. Wiąże się też z rzadszymi powrotami klientów, choć powroty są rzadkie w obu grupach.
- **Dni tygodnia różnią się wyraźniej niż godziny.** Zamówienia rozkładają się płasko w godz. 10-22, a w weekend jest ich wyraźnie mniej.

### Rekomendacje
1. **Sprawdzić terminy szacowane dla stanów z największymi odsetkami spóźnień (AL, MA, SE, PI).** Te regiony mają 14-21% spóźnień. Czas dostawy sam w sobie nie tłumaczy różnicy: AM ma średnio 26,4 dnia dostawy i tylko 2,8% spóźnień, a AL 24,5 dnia i 21,4% spóźnień. Możliwe, że terminy są tam zbyt optymistyczne lub nierealne do spełnienia.
2. **Reagować na ryzyko opóźnienia, zanim minie kilka dni.** Odsetek ocen 1-2 gwiazdki rośnie z 9,5% (dostawa na czas) do 32,4% przy opóźnieniu 1-3 dni oraz do 68,1% przy 4-7 dniach. Warto więc informować klienta o opóźnieniu wcześnie, zanim wystawi ocenę.
3. **Traktować pierwszą dostawę jako moment ważny dla powrotu klienta.** Klienci, których pierwsze zamówienie przyszło spóźnione wracają rzadziej: 2,72% wobec 4,25% (dane dot. pierwszych zamówień przed 2018 rokiem, n = 2 390 / 40 003)
4. **Przetestować wydatki reklamowe w weekendy.** Zamówienia klientów rozkładają się płasko w godz. 10-22, natomiast dni różnią się wyraźnie (w weekend średnio o ok. 25% mniej zamówień niż na tygodniu). Warto sprawdzić, czy zwiększenie wydatków na reklamy w dni o najmniejszym ruchu (weekend) podniesie sprzedaż, czy lepiej skoncentrować budżet w dniach o największym popycie. Dane pokazują moment zakupu, a nie skuteczność reklam.
5. **Zbierać dane o przewoźniku.** Dane nie zawierają informacji z podziałem na przewoźników. Nie da się ocenić, czy opóźnienia wynikają z odległości, czy ze złej pracy kurierów. Bez tych danych wniosek o transporcie pozostaje ogólny.

## Dane i kontrola jakości
Źródło: [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

Przed analizą sprawdziłem klucze, duplikaty, braki i spójności dat.

**Znalezione problemy i decyzje:**
| Problem | Skala | Decyzja | Gdzie |
|---|---|---|---|
| Zduplikowane `review_id` i zamówienia z kilkoma recenzjami | 827 powtórzonych `review_id`, 555 zamówień z 2+ recenzjami | Dla każdego zamówienia zostawiam najnowszą recenzję, żeby jedno zamówienie było liczone tylko raz | `10_profiling.sql` 1-2., 5.; `20_views.sql` |
| Produkty bez kategorii | 610 | W analizie kategorii trafiają do `unknown` (razem z kategoriami bez tłumaczenia) | `10_profiling.sql` 6; `30_sales.sql` 2. |
| Dostarczone zamówienia z brakiem którejś z dat | 23 | Pomijane w metrykach czasu dostawy | `10_profiling.sql` 4. |
| Niespójne daty etapów (np. dostawa przed odbiorem przez kuriera) | 694 | Wyłączone ze średnich czasów etapów, bo nie wiadomo, która data jest błędna | `40_delivery.sql` 6. |
| Pierwszy i ostatni miesiąc danych pokryte tylko częściowo, mało zamówień w 2016 | kilka zamówień na miesiąc | Trend sprzedaży ograniczony do 2017-01 … 2018-08 | `10_profiling.sql` 3.; `30_sales.sql` 1. |

**Kontrola jakości danych:**
- Widok `analytics.orders_enriched` ma 99 441 wierszy, czyli tyle ile unikanlych `order_id`.
- Rozkłady sprzedaży w podziale na godziny, dni tygodnia i stany sumują się do tej samej liczby zamówień.

**Ograniczenia**
- Brak danych o przewoźniku, więc o etapie transportu informacje są dość ogólne.
- Skrajne miesiące mają mało zamówień, więc zostały pominięte w zestawieniach miesięcznych.
- Powroty klientów są obliczone dla pierwszych zamówień przed 2018 rokiem, żeby każdy miał podobnie dużo czasu na powrót.

## Struktura repozytorium

```text
├── sql/
│   ├── 00_setup.sql              Schemat tabel i załadowanie plików CSV
│   ├── 01_check_load.sql         Kontrola liczby wierszy względem wartości oczekiwanych
│   ├── 10_profiling.sql          Klucze, duplikaty, statusy, zakres dat, braki
│   ├── 20_views.sql              Widok analytics.orders_enriched
│   ├── 30_sales.sql              Trend sprzedaży, kategorie, stany, godziny i dni tygodnia
│   ├── 40_delivery.sql           Spóźnienia, etapy dostawy, wpływ na oceny
│   └── 50_customers.sql          Powroty klientów, wpływ spóźnienia na powroty
├── docs/
│   ├── metrics.md                Definicje metryk
│   └── data-quality.md           Problemy z danymi i decyzje
├── data/                         Pliki CSV z Kaggle
├── .gitignore
└── README.md
```
## Uruchomienie
Docker - w trakcie realizacji
