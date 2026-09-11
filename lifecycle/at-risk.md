# At Risk — win-back / reactivation

**Status: rekomendacja i projekt eksperymentu; brak wyników kampanii.**

## Dlaczego ten journey

At Risk obejmuje 20,879 klientów, 18.89% kupujących i 35.46% historycznego revenue, ze średnim revenue 107.89. To uzasadnia priorytet testu reaktywacji. Udział w historycznym revenue nie jest prognozą przychodu do odzyskania.

## Business objective

Zwiększyć odsetek klientów wracających do zakupu po wydłużonej przerwie, przy akceptowalnym koszcie komunikacji i bez nadmiernej presji rabatowej.

## Trigger i kwalifikacja

Proponowany trigger: pierwsze wejście do segmentu At Risk, zdefiniowanego w analizie jako `r_score <= 1 AND (f_score >= 2 OR m_score >= 3)`. Oznacza to Recency >37 dni oraz co najmniej dwie sesje zakupowe lub revenue >=61.44. Reguła poprzedza Lost, więc nie ma górnej granicy 63 dni. Punkt odniesienia stanowi p75 odstępu zakupowego wynoszący 37 dni. Dla pilota na istniejącej bazie można utworzyć jednorazową kohortę klientów spełniających warunek w dniu startu; należy oznaczyć ją osobno od nowych wejść.

Wymagane: dodatnie Monetary, zgoda email, kontaktowalny profil CRM, brak aktywnego konkurencyjnego journey i sprawdzenie aktualnej historii zakupów. Dzisiejszy segment bez poprzedniego snapshotu nie dowodzi przekroczenia progu.

## Flow i kanał

Terminy są propozycją do testu. D0 oznacza zapis do eksperymentu.

| Moment | Działanie | Cel |
|---|---|---|
| D0 | Email z przypomnieniem korzyści i powodem powrotu | Odbudować zainteresowanie |
| D+7 | Email z dopasowaną rekomendacją i jednym CTA, jeśli brak zakupu | Ułatwić wybór |
| D+14 | Ostatni email z krótką propozycją powrotu, jeśli klient nadal kwalifikuje się | Domknąć sekwencję |
| Do D+28 | Pomiar wyników także po zakończeniu kontaktów | Ocenić reaktywację w jednakowym oknie |

Kanał podstawowy: email. SMS lub push wymagają osobnej zgody, analizy kosztów i osobnego testu; nie są dodawane w tym pilotażu.

## Message strategy

Przekaz opierać na wartości oferty i ułatwieniu wyboru, bez komunikowania klientowi etykiety „At Risk”. Wariant z rekomendacją produktu wymaga dostępnego katalogu i poprawnego połączenia historii zakupów; w przeciwnym razie stosować bezpieczny przekaz ogólny. Nie zakładać czasu zużycia kosmetyku ani potrzeb zdrowotnych na podstawie samych kliknięć.

Przykładowy kierunek: „Wróć do swojej pielęgnacji — sprawdź propozycje dopasowane do poprzednich zakupów”. Nie stosować fikcyjnej pilności ani automatycznego rabatu jako warunku powrotu.

## KPI

- **Primary:** odsetek zapisanych klientów z co najmniej jedną nową sesją zakupową z dodatnim purchase w ciągu 28 dni od D0.
- **Secondary:** dodatnie revenue na zapisanego klienta, liczba sesji zakupowych na klienta i czas do powrotu.
- **Guardrails:** rezygnacje, skargi spamowe, odbicia, koszt kontaktu; marża przyrostowa dopiero po dołączeniu danych kosztowych.

Wynik oceniać jako różnicę A–control i B–control, z przedziałami ufności. Open rate i CTR są wskaźnikami diagnostycznymi, nie dowodem reaktywacji.

## Exit condition

Zatrzymać wysyłki po zakupie, cofnięciu zgody, utracie kontaktowalności, opuszczeniu segmentu At Risk lub zakończeniu sekwencji. Samo przekroczenie 63 dni Recency nie kończy journey: klient spełniający kryterium Frequency lub Monetary nadal należy do At Risk. Zakup tuż przed zaplanowaną wysyłką musi ją anulować. Nie przenosić automatycznie do kolejnego eksperymentu podczas bieżącego okna pomiaru. Wszystkich zapisanych pozostawić w analizie intention-to-treat do D+28.

## A/B test z grupą kontrolną

**Hipoteza:** rekomendacja oparta na historii zakupów zwiększy reaktywację względem ogólnego przypomnienia wartości oferty.

| Grupa | Doświadczenie |
|---|---|
| Control | Brak dodatkowych wiadomości tego journey |
| A | Ogólne przypomnienie korzyści i oferty sklepu |
| B | Rekomendacja oparta na poprzednich zakupach, z tym samym harmonogramem i bez dodatkowego rabatu |

Zmieniamy strategię personalizacji, utrzymując porównywalny układ, CTA i liczbę kontaktów. Do testu A/B kwalifikować tylko klientów, dla których możliwe są oba warianty. Jeżeli katalog lub historia nie pozwalają na B, najpierw uzupełnić integrację. Proponowany podział 10% / 45% / 45% i zasady kontroli opisuje [plan eksperymentów](ab-test-plan.md); liczebność wymaga analizy mocy.
