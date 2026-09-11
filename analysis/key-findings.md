# Kluczowe ustalenia i decyzje biznesowe

Wyniki poniżej pochodzą z analizy wykonanej w Google BigQuery Sandbox na pełnym datasetcie REES46 Cosmetics: pięć miesięcy, 20,692,840 eventów i 1,639,358 użytkowników. Segmentacja przedstawia finalny stan po cleanupie revenue; Recency obliczono względem 2020-02-29. Działania marketingowe są rekomendacjami wynikającymi z analizy.

## 1. Drugi zakup jest istotnym obszarem pracy CRM

Zakup wykonało 110,518 użytkowników, czyli około 6.7% wszystkich użytkowników. 78.9% kupujących miało tylko jedną sesję zakupową w obserwowanym okresie.

**Interpretacja:** duża część obserwowanych relacji zakupowych nie rozwinęła się w powtarzalne zakupy w tym oknie. Nie możemy stwierdzić, że klienci nigdy nie wrócili — część mogła dokonać pierwszego zakupu tuż przed końcem danych.

**Rekomendacja:** zaprojektować second-purchase journey. Przed jego oceną wyodrębnić kohorty pierwszego obserwowanego zakupu i zapewnić każdej pełny okres obserwacji. Segment One-Time Buyer (31,911; 28.87%; średnie revenue 30.36) nie jest równoważny wszystkim osobom z jedną sesją zakupową.

## 2. At Risk łączy istotną skalę z wysoką wartością historyczną

At Risk obejmuje 20,879 klientów, 18.89% bazy kupujących i 35.46% revenue; średnie revenue wynosi 107.89.

**Interpretacja:** udział segmentu w revenue przewyższa jego udział w klientach. To uzasadnia wysoki priorytet testu reaktywacji, lecz nie określa przyszłego przychodu ani odzyskiwalnej kwoty.

**Rekomendacja:** przetestować win-back z dopasowanymi rekomendacjami oraz wariantem przypominającym o użyteczności oferty, porównując oba z brakiem dodatkowej komunikacji journey.

## 3. Czas komunikacji powinien uwzględniać zachowania zakupowe

Mediana odstępu między zakupami wynosi 18 dni; p25 to 6 dni, p75 to 37 dni, a p90 to 63 dni.

**Interpretacja:** klienci różnią się tempem powrotu. Jeden sztywny termin nie musi odpowiadać wszystkim. Odstępy dotyczą obserwowanych kolejnych zakupów, więc pomijają osoby bez powrotu i powroty poza oknem danych.

**Rekomendacja:** wykorzystać te granice jako punkt startowy segmentacji Recency i projektowania journey. Optymalny termin kontaktu powinien być przedmiotem przyszłego testu, a nie deklarowanym wynikiem obecnej analizy.

## 4. Wartość klienta uzasadnia różne doświadczenia

VIP: 3,176 klientów, 2.87% bazy, 13.10% revenue, średnio 261.92. Loyal: 7,017 klientów, 6.35% bazy, 14.41% revenue, średnio 130.46. New High Value: 1,661 klientów, 1.50% bazy, 3.40% revenue, średnio 130.06.

**Rekomendacja:** dla VIP/Loyal zaprojektować korzyści relacyjne i trafny cross-sell; dla New High Value — onboarding premium i wsparcie drugiego zakupu. Nie zakładać, że wysoka wartość pojedynczego zakupu oznacza już lojalność ani wysokie przyszłe LTV.

## 5. Lost wymaga osobnej decyzji o ekonomice kontaktu

Lost obejmuje 44,685 klientów, 40.43% bazy i 17.92% revenue, ze średnim revenue 25.47. Active obejmuje 1,189 klientów, 1.08% bazy i 0.46% revenue, ze średnim revenue 24.38.

**Rekomendacja:** nie kierować całej bazy Lost do intensywnego win-back bez oceny zgód, dostarczalności i kosztów. Ewentualny test dla Lost zaplanować osobno. Active może pozostać w standardowej komunikacji; nie jest częścią czterech priorytetowych journey w tym repozytorium.

## 6. Korekta revenue wymaga jawnego uzasadnienia

126 ujemnych purchase events dotyczyło 108 użytkowników i sumowało się do -3825.42. Brak dokumentacji nie pozwala oznaczyć ich jako refundów. Raw data zachowano, a `price <= 0` pominięto w revenue i Monetary.

**Interpretacja:** poprawiono spójność miary dodatniej wartości zakupowej. Nie zrekonstruowano przychodu netto po zwrotach. Segmentacja po korekcie pozostała stabilna; przedstawione statystyki są finalnymi wynikami po cleanupie.

## Co należy zweryfikować w kolejnym etapie

- Zastosowanie ustalonych reguł na nowych snapshotach i obserwację migracji segmentów w czasie.
- Retencję kohort przy jednakowym horyzoncie obserwacji oraz sezonowość w dłuższym okresie.
- Znaczenie cen, duplikatów i zdarzeń ujemnych oraz kompletność identyfikatorów sesji.
- Możliwość połączenia `user_id` z kontaktem CRM i rzeczywistą dostępność zgód, historii wysyłek i katalogu produktów.
- Efekt przyrostowy komunikacji w randomizowanych testach opisanych w [planie A/B](../lifecycle/ab-test-plan.md).
