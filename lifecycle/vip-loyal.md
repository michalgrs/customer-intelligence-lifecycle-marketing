# VIP / Loyal — retention i value expansion

**Status: rekomendacja i projekt eksperymentu; brak wyników kampanii.**

## Dlaczego ten journey

VIP: 3,176 klientów, 2.87% bazy, 13.10% revenue, średnio 261.92. Loyal: 7,017 klientów, 6.35% bazy, 14.41% revenue, średnio 130.46. Obie grupy zasługują na rozwój relacji, ale ich wyniki należy mierzyć także oddzielnie.

## Business objective

Utrzymać powtarzalność zakupów i sprawdzić możliwość zwiększenia wartości relacji przez trafne uzupełnienie oferty oraz rozpoznanie lojalności.

## Trigger i kwalifikacja

Proponowany trigger: pierwsze wejście do segmentu VIP lub Loyal, ewentualnie jednorazowy zapis istniejącej bazy do oznaczonej kohorty pilotażowej. Finalna reguła VIP to `r_score >= 3 AND f_score >= 3 AND m_score >= 3`; Loyal to `r_score >= 2 AND f_score >= 2 AND m_score >= 2`, po wcześniejszych regułach CASE. VIP oznacza Recency <=18 dni, co najmniej trzy sesje i revenue >=61.44. Loyal obejmuje Recency <=37 dni, co najmniej dwie sesje i revenue >=33.18, po wykluczeniu wcześniej przypisanych klientów.

Wymagane: dodatnie Monetary, zgoda email, kontaktowalność, brak innego eksperymentu i sprawdzenie niedawnej komunikacji. Stratyfikować przydział według segmentu, aby nie przypisać nieproporcjonalnie większej liczby VIP do jednego wariantu. Etykietę segmentu na wejściu utrwalić do analizy.

## Flow i kanał

Email jako podstawowy kanał. D0 oznacza zapis do testu.

| Moment | Działanie | Cel |
|---|---|---|
| D0 | Podziękowanie za powroty i rekomendacja dopasowana do historii | Wzmocnić poczucie trafnej obsługi |
| D+18 | Uzupełniająca propozycja, jeśli brak nowego zakupu | Wesprzeć kolejny zakup |
| Do D+37 | Pomiar | Ocenić retencję i wartość zakupów |

Nie wysyłać powtarzającego się „powitania VIP” przy każdej zmianie snapshotu. Program korzyści czy wcześniejszy dostęp do nowości wymagają rzeczywistej dostępności; są możliwym przyszłym rozszerzeniem, nie wdrożoną funkcją tego projektu.

## Message strategy

Dla VIP mocniej akcentować jakość i dopasowanie doświadczenia, dla Loyal — wygodę kolejnych zakupów i odkrywanie uzupełnień. Rekomendacja produktu powinna wynikać z historii i zatwierdzonego katalogu, nie z założenia, że klient potrzebuje najdroższego produktu.

Przykładowy kierunek: „Dziękujemy, że wracasz — zobacz propozycję dopasowaną do Twoich zakupów”. Bez automatycznych rabatów za samą przynależność do segmentu.

## KPI

- **Primary:** odsetek zapisanych klientów z co najmniej jedną nową sesją zakupową z dodatnim purchase do D+37.
- **Secondary:** dodatnie revenue i liczba sesji zakupowych na zapisanego klienta. Rozwój zakupów do nowych kategorii mierzyć dopiero po dołączeniu wiarygodnej mapy kategorii.
- **Guardrails:** wypisy, skargi, odbicia, koszt kontaktu i marża, jeżeli dostępne są koszty.

Raportować wyniki dla VIP i Loyal osobno oraz łącznie z ustalonymi wagami segmentów. Nie ogłaszać różnicy skuteczności między segmentami na podstawie samego tego, że jeden wynik był istotny statystycznie, a drugi nie.

## Exit condition

Nowy zakup kończy bieżącą sekwencję. Cofnięcie zgody, utrata kontaktowalności, przejście do At Risk/Lost lub koniec sekwencji także zatrzymują wysyłki. Zmiana VIP ↔ Loyal nie uruchamia drugiego zapisu. Analiza trwa do D+37, a kolejny eksperyment może rozpocząć się dopiero po zamknięciu bieżącego okna i uzgodnionej przerwie.

## A/B test z grupą kontrolną

**Hipoteza:** przekaz rozpoznający lojalność zwiększy ponowny zakup względem standardowej komunikacji produktowej.

| Grupa | Doświadczenie |
|---|---|
| Control | Brak dodatkowych wiadomości journey VIP/Loyal |
| A | Standardowy przekaz produktowy z dopasowaną rekomendacją |
| B | Ta sama rekomendacja z podziękowaniem za relację i naciskiem na wygodę stałego klienta |

Ta sama oferta, liczba wiadomości, terminy, CTA i warunki cenowe. Proponowany podział 10% control / 45% A / 45% B, z kontrolą równowagi w obu segmentach i analizą mocy przed startem. [Wspólny plan](ab-test-plan.md).
