# Metodologia, definicje i ograniczenia

## Analiza i zakres projektu

Analizę wykonano w **Google BigQuery Sandbox** na pełnym datasetcie REES46 Cosmetics: pięć miesięcy, **20,692,840 eventów**, **1,639,358 unique users** i **110,518 buyers**. Udział kupujących wyniósł około **6.7%**, a **78.9% buyers miało jedną sesję zakupową**.

Customer 360, kontrola jakości, scoring i finalna segmentacja są wynikami wykonanej analizy. Journey lifecycle i testy A/B to **recommended strategy / experiment design** — rekomendacje wynikające z danych, bez deklaracji przeprowadzonych kampanii ani efektów eksperymentalnych.

## Dane wejściowe i SQL

Repozytorium używa **Google Standard SQL / BigQuery SQL**. Nazwa `YOUR_PROJECT_ID` jest miejscem na identyfikator własnego projektu; `raw.events_month_01`–`raw.events_month_05` to nazwy do przyporządkowania pięciu tabelom miesięcznym. Datasety `raw` i `analytics` powinny mieć tę samą lokalizację.

`01_events_all.sql` łączy pięć tabel przez `UNION ALL` i zachowuje dokładnie dziewięć kolumn:

```text
event_time, event_type, product_id, category_id, category_code,
brand, price, user_id, user_session
```

Typy wejściowe: `event_time TIMESTAMP`; identyfikatory produktu, kategorii i użytkownika `INT64`; pola opisowe i `user_session STRING`; `price NUMERIC` lub `FLOAT64`. Agregacje wartości używają `NUMERIC`, bez zmiany ceny w raw data. Brakujące category_code lub brand nie usuwa eventów ani użytkowników z analizy.

Pliki uruchamia się w kolejności 01–06. Repozytorium używa odtwarzalnych widoków BigQuery dla wygody reprodukcji, natomiast właściwa analiza została wykonana na zapisanych tabelach BigQuery. Skrypty tworzą lub zastępują widoki w `analytics`; nie modyfikują tabel raw. Plik 03 audytuje jakość i zgodność podstawowych metryk, a plik 05 zestawia obliczone statystyki segmentów z finalnymi wynikami analizy.

## Customer 360

Jeden rekord na niepusty `user_id`, również dla niekupujących. Buyer to użytkownik z co najmniej jedną zarejestrowaną sesją zakupową, czyli `purchase_sessions > 0`. Ten sam warunek definiuje bazę RFM oraz mianownik udziału klientów z jedną sesją zakupową. `purchased_items` pozostaje liczbą eventów/pozycji zakupowych i nie służy do definiowania buyer. Identyfikator użytkownika nie gwarantuje tożsamości pojedynczej osoby.

| Pole | Definicja |
|---|---|
| `first_purchase` | Najwcześniejszy event_time dla purchase |
| `last_purchase` | Najpóźniejszy event_time dla purchase |
| `views` | Liczba eventów view |
| `carts` | Liczba eventów cart |
| `removes_from_cart` | Liczba eventów remove_from_cart |
| `purchased_items` | Liczba eventów purchase; licznik zdarzeń, nie zweryfikowana liczba zamówień |
| `purchase_sessions` | Liczba różnych user_session z eventem purchase dla danego user_id |
| `total_sessions` | Liczba różnych user_session ze wszystkich eventów użytkownika |
| `revenue` | Suma price tylko dla `event_type = 'purchase' AND price > 0` |
| `avg_purchased_item_price` | Średnia price tylko dla `event_type = 'purchase' AND price > 0` |

**Purchase sessions = proxy for orders**, ponieważ dataset nie posiada klasycznego `order_id`. Przy redukcji zdarzeń do sesji kluczem jest para `(user_id, user_session)`. Kilka purchase events w tej samej sesji nie oznacza kilku zamówień.

Filtr dodatniej ceny działa wewnątrz agregacji wartości, a nie w globalnym WHERE. Ujemne purchase events nadal wpływają na purchased_items, daty zakupów i purchase_sessions. `avg_purchased_item_price` nie jest liczone jako revenue / purchased_items, bo mianownik takiego ilorazu obejmowałby także eventy niedodatnie. Dla braku dodatnich purchase revenue wynosi 0, a średnia ceny NULL.

`COUNT(DISTINCT ...)` pomija NULL sesji. Użytkownik z eventami purchase, ale bez zarejestrowanej sesji zakupowej (`purchase_sessions = 0`), pozostaje w Customer 360, lecz nie należy do buyers ani bazy RFM. Takie przypadki oraz braki identyfikatorów i dat są audytowane; nie przypisujemy sztucznych sesji. Znak ceny nie wyklucza buyer z RFM. Brak czasu zakupu uniemożliwia obliczenie Recency i wymaga wyjaśnienia w audycie.

## Recency i okno obserwacji

Recency ma stały punkt odniesienia:

```sql
DATE_DIFF(DATE '2020-02-29', DATE(last_purchase), DAY)
```

Jest to liczba dni kalendarzowych, przy konwersji TIMESTAMP do DATE w UTC. Kod case study nie korzysta z bieżącej daty ani maksimum dat eventów do ustalania snapshotu.

Pierwszy obserwowany zakup nie musi być pierwszym zakupem klienta w historii sklepu. Brak powrotu do końca pięciomiesięcznego okna nie dowodzi trwałego churnu. Młodsze kohorty mają mniej czasu na powrót. „Lost” i „At Risk” są etykietami operacyjnymi.

## Repeat purchase timing

Rozkład odstępów między zakupami: **p25 = 6, mediana = 18, p75 = 37, p90 = 63 dni**. Progi Recency wynikają z tego rozkładu.

SQL redukuje purchase events do jednej daty początku sesji, porządkuje sesje w ramach user_id i używa `LAG`, aby wyznaczyć poprzedni zakup. Odstęp liczy jako `DATE_DIFF` między datami sesji. Następnie oblicza percentyle funkcją `PERCENTILE_CONT(value, percentile) OVER ()`. Każdy zaobserwowany odstęp ma tę samą wagę; częściej kupujący dostarczają więcej odstępów.

Rozkład obejmuje zaobserwowane kolejne zakupy. Nie uwzględnia powrotów poza oknem ani klientów, którzy nie wrócili. Jest podstawą do projektowania czasu komunikacji, nie dowodem optymalnego terminu wysyłki.

## Data quality i cleanup

Wykryto **126 negative purchase events**, dotyczących **108 użytkowników**, o łącznej wartości **-3825.42**. Dataset nie dokumentuje tych eventów jako refundów; nie przypisujemy im takiego znaczenia.

Ujemne ceny są zachowane w raw data i events_all. Z revenue / Monetary wykluczone są wartości `price <= 0`; identyczny warunek dodatniego purchase stosuje się do średniej ceny zakupionego produktu. Liczniki i daty zakupów pozostają oparte na pełnej historii purchase. Zera oraz brakujące ceny są raportowane oddzielnie.

Segmentacja po korekcie pozostała stabilna. Finalne liczebności, udziały i średnie po cleanupie przedstawiono poniżej. Nie przypisujemy tej stabilności niepodanej liczby migracji klientów.

Bez event_id identyczne rekordy nie są wystarczającym dowodem duplikacji. `UNION ALL` zachowuje wszystkie eventy, a audyt identycznych pełnych wierszy nie usuwa ich automatycznie. Revenue nie jest potwierdzonym przychodem księgowym, zyskiem ani LTV; nie obejmuje rekonstrukcji zwrotów czy marży.

## Scoring RFM

Monetary jest równe oczyszczonemu `revenue`. R i M mają skalę 0–4, F ma skalę 1–4. Nie sumujemy ich do jednego arbitralnego wskaźnika.

| Score | R: Recency w dniach | F: purchase_sessions | M: revenue |
|---|---|---|---|
| 4 | <=6 | >=5 | >=122.23 |
| 3 | >6 i <=18 | 3–4 | >=61.44 i <122.23 |
| 2 | >18 i <=37 | 2 | >=33.18 i <61.44 |
| 1 | >37 i <=63 | 1 | >=16.22 i <33.18 |
| 0 | >63 | — | <16.22 |

Wartość równa progowi Monetary trafia do wyższego przedziału: np. **61.44 → m_score 3**, a **122.23 → m_score 4**. Równość na progu Recency pozostaje w przedziale bardziej aktualnym: np. **18 dni → r_score 3**, **63 dni → r_score 1**. Klient z revenue=0 pozostaje buyerem, jeżeli ma co najmniej jedną zarejestrowaną sesję zakupową (`purchase_sessions > 0`), i otrzymuje m_score 0.

## Finalna logika segmentów

Pierwsza spełniona reguła CASE wygrywa. Kolejność jest częścią definicji segmentacji.

| Kolejność | Segment | Warunek |
|---|---|---|
| 1 | VIP | `r_score >= 3 AND f_score >= 3 AND m_score >= 3` |
| 2 | New High Value | `r_score >= 3 AND f_score = 1 AND m_score >= 3` |
| 3 | At Risk | `r_score <= 1 AND (f_score >= 2 OR m_score >= 3)` |
| 4 | Loyal | `r_score >= 2 AND f_score >= 2 AND m_score >= 2` |
| 5 | Lost | `r_score = 0` |
| 6 | One-Time Buyer | `f_score = 1` |
| 7 | Active | `ELSE` |

At Risk nie ma górnej granicy 63 dni: klient o r_score=0 z f_score>=2 lub m_score>=3 trafia do At Risk przed sprawdzeniem Lost. New High Value obejmuje jeden zakup, Recency <=18 dni i revenue >=61.44. VIP wymaga Recency <=18 dni, co najmniej trzech sesji oraz revenue >=61.44. Pozostałe grupy są oceniane dopiero po wcześniejszych regułach.

78.9% buyers z jedną sesją zakupową nie jest tożsame z segmentem One-Time Buyer (28.87%). Osoby z F=1 mogą zostać wcześniej przypisane do New High Value, At Risk lub Lost.

## Finalne statystyki po cleanupie

| Segment | Customers | Udział buyers | Udział revenue | Avg revenue |
|---|---:|---:|---:|---:|
| At Risk | 20,879 | 18.89% | 35.46% | 107.89 |
| Lost | 44,685 | 40.43% | 17.92% | 25.47 |
| One-Time Buyer | 31,911 | 28.87% | 15.25% | 30.36 |
| Loyal | 7,017 | 6.35% | 14.41% | 130.46 |
| VIP | 3,176 | 2.87% | 13.10% | 261.92 |
| New High Value | 1,661 | 1.50% | 3.40% | 130.06 |
| Active | 1,189 | 1.08% | 0.46% | 24.38 |

Liczebności sumują się do 110,518 buyers. Udział klientów ma w mianowniku wszystkich buyers, a udział revenue — całe dodatnie revenue tej bazy. Avg revenue = revenue segmentu / liczba klientów segmentu. To średnia wartości na klienta, odrębna od avg_purchased_item_price. Udziały i średnie są zaokrąglone do dwóch miejsc.

## Od segmentów do rekomendowanych journey

`06_campaign_audiences.sql` mapuje finalne segmenty na cztery projekty journey. Revenue >0 jest tu dodatkowym kryterium rekomendowanej aktywacji, nie zmianą analitycznej bazy buyers. Okno 6–37 dni dla pilota One-Time Buyer również ogranicza wyłącznie grupę kampanii, nie definicję segmentu.

Kod pokazuje deterministyczny podział **10% control / 45% A / 45% B** z użyciem `FARM_FINGERPRINT`. Zagnieżdżone MOD zamienia wynik na przedział 0–9999 bez używania ABS na skrajnym ujemnym INT64. Proporcje są projektem eksperymentu i wymagają analizy mocy.

Historyczny snapshot nie jest listą do bieżącej wysyłki. Przyszłe wdrożenie wymaga aktualnych danych, identyfikacji CRM, zgód, historii wejść, wykluczeń i limitów kontaktu. Kohortę, datę zapisu i przydział należy utrwalić; późniejsza migracja segmentu nie usuwa klienta z analizy intention-to-treat. Szczegóły: [plan eksperymentów](../lifecycle/ab-test-plan.md).

## Dokumentacja techniczna

Składnia funkcji: [BigQuery — navigation functions, w tym PERCENTILE_CONT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/navigation_functions) oraz [BigQuery — hash functions, w tym FARM_FINGERPRINT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/hash_functions). Źródłem wyników biznesowych jest wykonana analiza REES46 Cosmetics.
