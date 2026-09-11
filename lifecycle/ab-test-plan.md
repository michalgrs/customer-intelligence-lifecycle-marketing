# Plan eksperymentów lifecycle

**Dokument projektowy. Żaden opisany test nie ma w tym repozytorium wyników, potwierdzonego upliftu ani deklaracji realizacji.**

## Pytanie pomiarowe

Czy dodatkowa komunikacja lifecycle powoduje więcej zakupów niż obsługa bez tego journey? Porównanie A z B odpowiada na pytanie o wariant komunikacji, a porównania z kontrolą — o jej przyrostowy wpływ. Sam wzrost zakupów po wysyłce nie dowodzi działania kampanii.

## Zapis i przydział

Jednostką przydziału jest klient CRM powiązany z `user_id`. Jeżeli kilka identyfikatorów należy do jednej osoby, należy je połączyć przed randomizacją, aby nie otrzymywała różnych wariantów. Przed przydziałem sprawdzić zgodę, kontaktowalność, kwalifikację i brak aktywnego konkurencyjnego testu.

Proponowany podział: **10% control / 45% A / 45% B**, wymagający analizy mocy. Historyczne liczebności segmentów nie są wielkością dostępnej próby. Nie zakładamy z góry, że podział wystarczy do wiarygodnego porównania, szczególnie dla New High Value.

BigQuery SQL przedstawia stabilny podział przez `FARM_FINGERPRINT` po użytkowniku, journey i wersji testu. Grupy wynikają z finalnej segmentacji analizy z datą odniesienia 2020-02-29; przed rzeczywistym wdrożeniem wymagają aktualnego snapshotu. To kandydatura przydziału, nie rejestr uruchomionego eksperymentu. Po kwalifikacji CRM należy zamrozić grupy i sprawdzić równowagę. Dla VIP/Loyal randomizację prowadzić w warstwach segmentu; dla kohort istniejących i nowych raportować wyniki osobno lub uwzględnić typ wejścia w planie analizy.

Minimalny rejestr eksperymentu: identyfikator klienta, journey, wersja reguł, grupa, segment na wejściu, data zapisu, koniec okna, status kwalifikacji, ekspozycje, wyjście z komunikacji i zdarzenia wynikowe. Nie dołączać danych kontaktowych do publicznego repozytorium.

## Co oznacza grupa kontrolna

Control nie otrzymuje dodatkowych wiadomości badanego journey. Obsługa transakcyjna i standardowa komunikacja, jeżeli jest prowadzona, pozostają na tych samych zasadach we wszystkich grupach. Konkurencyjne automatyzacje sprzedażowe należy blokować jednakowo dla A, B i control. Rejestrować nieuniknione inne kontakty.

Brak wysyłki kontrolnej nie zwalnia z zapisania daty wejścia i pełnego okna obserwacji. Nie dobierać kontroli po wynikach i nie zastępować jej osobami bez zgody lub nieaktywnymi kontaktami.

## Kolizje journey i limity kontaktów

- Jeden klient może uczestniczyć w jednym z tych eksperymentów naraz; aktywny zapis ma pierwszeństwo przed zmianą segmentu.
- Przy pierwszym zapisie zastosować rozłączne segmenty. New High Value ma pierwszeństwo wobec ogólnego journey drugiego zakupu.
- Po zakupie zatrzymać bieżące wiadomości, ale zachować pierwotny przydział do pomiaru. Nie dopisywać do następnego testu przed końcem tego okna.
- Proponowany limit pilotażu: co najmniej siedem dni między dodatkowymi emailami lifecycle do klienta. Jeśli inna komunikacja wymusza przesunięcie, stosować tę samą regułę w A/B i zapisać faktyczny czas kontaktu.
- Przed startem ustalić regułę ponownego wejścia i przerwę po eksperymencie. W pilotażu wyłączyć ponowny zapis do tej samej wersji testu.

Limity i harmonogramy są parametrami projektowymi. Należy je uzgodnić przed startem i zachować bez zmian w trakcie testu.

## KPI i horyzonty

| Journey | Primary KPI | Horyzont od zapisu |
|---|---|---|
| At Risk | Udział klientów z nową sesją zakupową | 28 dni |
| One-Time Buyer | Udział klientów z drugą sesją zakupową | 37 dni |
| New High Value | Udział klientów z drugą sesją zakupową | 18 dni |
| VIP/Loyal | Udział klientów z nową sesją zakupową | 37 dni |

Zakup wynikowy wymaga odrębnej sesji i co najmniej jednego dodatniego purchase po zapisie. Dla drugiego zakupu musi być to inna sesja niż pierwsza. Tę operacyjną definicję należy zatwierdzić przed testem; wymaga dodatniego purchase, podczas gdy historyczny buyer to użytkownik z co najmniej jedną zarejestrowaną sesją zakupową (`purchase_sessions > 0`), niezależnie od znaku ceny.

Wyniki mierzyć dla wszystkich zapisanych klientów w pierwotnych grupach (**intention-to-treat**), a nie tylko odbiorców, otwierających lub klikających. Wszystkie zakupy w oknie uwzględniać niezależnie od kliknięcia w email.

```text
purchase rate = klienci z zakupem wynikowym / wszyscy zapisani klienci
efekt w punktach procentowych = 100 × (purchase rate wariantu − purchase rate kontroli)
względny uplift = purchase rate wariantu / purchase rate kontroli − 1
revenue per enrolled customer = suma dodatniego revenue w oknie / wszyscy zapisani
przyrost revenue na klienta = revenue per customer wariantu − revenue per customer kontroli
```

Uplift względny jest nieokreślony, jeżeli wynik kontroli wynosi zero. Nie należy go wtedy raportować jako nieskończony sukces. Revenue nie jest marżą; zwrotu z inwestycji nie policzymy bez kosztów komunikacji, rabatów, produktów i zwrotów.

## Wielkość próby i czas trwania

Przed startem określić bazowy purchase rate w porównywalnej kohorcie, minimalny ekonomicznie istotny efekt, poziom istotności, moc, proporcje grup i planowane porównania. Propozycja: dwustronne testy z rodzinnym poziomem błędu 5% i mocą 80%; te parametry nie są wynikiem obliczenia próby.

Nie podajemy liczebności wymaganej próby, bo brakuje bazowych wskaźników w proponowanych oknach i minimalnego efektu. Zaplanować korektę Holma dla dwóch głównych porównań A–control i B–control w każdym journey. B–A traktować jako eksploracyjne albo przed startem uwzględnić je w rodzinie potwierdzających porównań i obliczeniu próby.

Rekrutację zakończyć po osiągnięciu ustalonej liczby klientów lub ustalonej maksymalnej dacie. Analizę końcową wykonać dopiero po upływie pełnego okna dla ostatniej osoby i uzgodnionego czasu na dotarcie danych. Nie kończyć testu dlatego, że chwilowy wynik wygląda korzystnie. Zbyt mała próba oznacza niepewność, a nie dowód braku efektu.

## Kontrola jakości i analiza

Przed startem sprawdzić rozłączność grup, przydział tylko raz, blokady wysyłek, działanie kontroli i pomiar zakupów bez kliknięcia. W trakcie sprawdzać zgodność proporcji przydziału (sample ratio mismatch), kompletność zdarzeń i przypadkową ekspozycję kontroli.

Raportować wielkość próby, zdarzenia wynikowe, purchase rate, różnice bezwzględne, przedziały ufności i koszty, jeśli są dostępne. Dla revenue uwzględnić asymetrię rozkładu, np. bootstrap po klientach, zachowując jednostkę randomizacji. Nie usuwać klientów o wysokiej wartości wyłącznie dlatego, że zmieniają wynik.

Guardrails obejmują wypisy, skargi spamowe, odbicia i koszty. Ich progi przerwania trzeba ustalić z właścicielem kanału na podstawie realnych danych przed startem. Krytyczny błąd zgód, przydziału lub wysyłek uzasadnia wstrzymanie operacyjne niezależnie od KPI.

## Decyzja po teście

Skalować wariant, jeśli efekt względem kontroli jest wystarczająco precyzyjny, biznesowo istotny i nie pogarsza uzgodnionych guardrails. Jeżeli A/B różnią się, ale żaden nie wykazuje korzyści względem kontroli, nie traktować lepszego wariantu jako dowodu wartości journey. Przy niejednoznacznym wyniku opisać ograniczenia i zaprojektować kolejny test.

Szablon przyszłego raportu: cel → definicja kohorty → termin i grupa → jakość wykonania → KPI i przedziały ufności → koszty i guardrails → decyzja. Pola wynikowe pozostają puste do zakończenia rzeczywistego eksperymentu.
