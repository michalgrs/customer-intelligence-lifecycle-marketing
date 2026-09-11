# New High Value — premium onboarding

**Status: rekomendacja i projekt eksperymentu; brak wyników kampanii.**

## Dlaczego ten journey

New High Value obejmuje 1,661 klientów, 1.50% kupujących i 3.40% revenue, ze średnim revenue 130.06. Wartość pierwszego obserwowanego zakupu uzasadnia test osobnego onboardingu, ale nie dowodzi przyszłej lojalności.

## Business objective

Pomóc klientowi o wysokiej wartości początkowej szybko przejść do drugiego zakupu i zbudować podstawy dłuższej relacji.

## Trigger i kwalifikacja

Proponowany trigger: pierwsze wejście do New High Value po pierwszej obserwowanej sesji zakupowej. Finalna reguła analizy to `r_score >= 3 AND f_score = 1 AND m_score >= 3`: jedna sesja, Recency <=18 dni i revenue >=61.44, z granicą Monetary włącznie. Rekomendowany start następuje możliwie szybko po potwierdzeniu transakcji w CRM; event w zbiorze nie potwierdza realizacji zamówienia. W pilotażu istniejącej bazy kwalifikować można cały segment do 18 dni Recency, oznaczając taką kohortę oddzielnie.

Wymagana zgoda email, kontaktowalność i brak innego aktywnego eksperymentu. „New” oznacza nowego w oknie danych; przed produkcyjną aktywacją zweryfikować starszą historię CRM. Po zapisie journey jest utrzymywany według warunku jednej sesji zakupowej do końca zaplanowanej sekwencji. Sama migracja segmentu po przekroczeniu 18 dni Recency nie przerywa onboardingu.

## Flow i kanał

Podstawowy kanał: email. D0 to zapis do testu.

| Moment | Działanie | Cel |
|---|---|---|
| D0 | Powitanie i wskazanie wartości dostępnego wsparcia | Zbudować zaufanie do marki |
| D+7 | Rekomendacja uzupełniająca poprzedni zakup | Ułatwić szybki drugi zakup |
| D+14 | Ostatnie przypomnienie z jasnym kolejnym krokiem | Pomóc podjąć decyzję bez presji |
| Do D+18 | Pomiar drugiej sesji zakupowej | Sprawdzić powrót w horyzoncie inspirowanym medianą |

Wsparcie doradcy lub konsultacja mogą być elementem oferty wyłącznie wtedy, gdy sklep faktycznie je zapewnia. Nie obiecywać statusu VIP, prezentów ani usług, których wdrożenia nie potwierdzono.

## Message strategy

Premium oznacza trafność, wygodę i jakość opieki, a nie automatyczny rabat. Komunikacja powinna podziękować za wybór i pokazać konkretny następny krok. Rekomendacje wymagają katalogu i informacji o dostępności; bez nich użyć treści o ogólnej wartości obsługi.

Przykładowy kierunek: „Dziękujemy za wybór — poznaj propozycję, która uzupełni Twoją pielęgnację”. Nie eksponować wewnętrznej oceny wartości klienta.

## KPI

- **Primary:** odsetek zapisanych klientów z drugą odrębną sesją zakupową z dodatnim purchase do D+18.
- **Secondary:** dodatnie revenue na zapisanego klienta i czas do drugiego zakupu.
- **Guardrails:** wypisy, skargi, odbicia oraz obciążenie obsługi, jeżeli jej wsparcie jest częścią komunikacji.

Nie używać średniej wartości zamówienia jako jedynej miary sukcesu; wyklucza ona osoby, które nie kupiły. Nie nazywać krótkoterminowego wyniku LTV.

## Exit condition

Zatrzymać wysyłki po drugiej sesji zakupowej, cofnięciu zgody, utracie kontaktowalności lub końcu sekwencji. Sama migracja do One-Time Buyer po przekroczeniu 18 dni Recency nie uruchamia konkurencyjnego journey. Zapisanych klientów obserwować do D+18 niezależnie od dalszego segmentu.

## A/B test z grupą kontrolną

**Hipoteza:** rama przekazu akcentująca opiekę i wygodę zwiększy drugi zakup względem standardowej ramy produktowej.

| Grupa | Doświadczenie |
|---|---|
| Control | Brak dodatkowego onboardingu marketingowego |
| A | Standardowy onboarding z naciskiem na produkt |
| B | Te same produkty i warunki przedstawione przez opiekę, wygodę i dopasowanie |

Warianty utrzymują ten sam harmonogram, CTA i ofertę; test dotyczy ramy komunikacji, nie nowej usługi dostępnej tylko dla B. Podział 10% / 45% / 45% jest propozycją. Historyczna liczebność 1,661 nie jest liczbą kontaktowalnych odbiorców ani gwarancją mocy testu. Jeśli próba jest za mała, wydłużyć rekrutację lub przed startem uprościć test do jednego wariantu i kontroli. [Wspólny plan](ab-test-plan.md).
