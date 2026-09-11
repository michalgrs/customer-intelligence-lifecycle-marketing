# One-Time Buyer — second-purchase journey

**Status: rekomendacja i projekt eksperymentu; brak wyników kampanii.**

## Dlaczego ten journey

78.9% kupujących miało tylko jedną sesję zakupową w oknie analizy. Segment One-Time Buyer liczy 31,911 klientów, 28.87% bazy i 15.25% revenue, ze średnim revenue 30.36. Nie są to identyczne grupy: przypisanie do segmentu uwzględnia inne wymiary i kolejność reguł.

## Business objective

Zwiększyć prawdopodobieństwo drugiej sesji zakupowej przez wsparcie klienta po pierwszym obserwowanym zakupie i przedstawienie trafnej kolejnej propozycji.

## Trigger i kwalifikacja

Propozycja: w 6. dniu po pierwszej obserwowanej sesji zakupowej, gdy nadal F=1 i klient należy do One-Time Buyer. Sześć dni odpowiada p25 zaobserwowanych odstępów, ale nie jest potwierdzonym optymalnym terminem wysyłki. W pilotażu istniejącej bazy można przyjąć Recency 6–37 dni, z osobnym oznaczeniem takiej kohorty. To okno rekomendowanej aktywacji, nie granica segmentacji: One-Time Buyer oznacza `f_score = 1` po wcześniejszych regułach CASE i może obejmować klientów z Recency 38–63 dni, jeśli nie trafili do At Risk.

New High Value ma pierwszeństwo przy kwalifikacji do swojego onboarding journey. Wymagane są dodatnie Monetary, zgoda email, kontaktowalność i brak aktywnego eksperymentu. Jeśli onboarding premium już wystartował, późniejsza zmiana segmentu nie może uruchomić tego journey w trakcie jego okna pomiaru.

## Flow i kanał

Email jest proponowanym kanałem pilotażu. D0 to moment zapisu do testu, nie data zakupu.

| Moment | Działanie | Cel |
|---|---|---|
| D0 | Email wspierający korzystanie z zakupionego produktu, bez niepotwierdzonych obietnic | Zwiększyć użyteczność doświadczenia po zakupie |
| D+7 | Email z jedną propozycją kolejnego zakupu | Ograniczyć trudność wyboru |
| D+14 | Krótkie przypomnienie, jeśli brak kolejnej sesji zakupowej | Ułatwić powrót |
| Do D+37 | Pomiar drugiego zakupu | Objąć dłuższy horyzont obserwacji |

Wysyłki wymagają aktualnej kwalifikacji. Przekroczenie 37 dni Recency kończy komunikację tego journey; pomiar nadal trwa do D+37 od zapisu. Materiały o dostawie lub faktycznym otrzymaniu produktu wymagają danych realizacyjnych — event purchase nie potwierdza doręczenia.

## Message strategy

Najpierw pomóc klientowi skorzystać z pierwszego zakupu, następnie zaproponować logiczne uzupełnienie. Treści produktowe muszą pochodzić z zatwierdzonego katalogu. Nie komunikować klientowi, że „kupił tylko raz”. Nie zakładać, że jest nowy w całej historii sklepu.

Przykładowy kierunek: „Poznaj wskazówki do swojej pielęgnacji i zobacz, co może ją uzupełnić”. Unikać szerokiego katalogu przypadkowych produktów w jednym emailu.

## KPI

- **Primary:** odsetek zapisanych klientów z drugą odrębną sesją zakupową z dodatnim purchase w ciągu 37 dni od D0.
- **Secondary:** dodatnie revenue na zapisanego klienta oraz czas do drugiej sesji zakupowej.
- **Guardrails:** wypisy, skargi, odbicia i koszt kontaktu; zwroty tylko po dostarczeniu zweryfikowanych danych o zwrotach.

Nowe eventy w tej samej parze `(user_id, user_session)` nie są drugim zakupem. Mianownik obejmuje wszystkich zapisanych, także tych, którzy nie otworzyli wiadomości.

## Exit condition

Druga sesja zakupowa, cofnięcie zgody, utrata kontaktowalności, opuszczenie kwalifikującego segmentu albo koniec sekwencji zatrzymują wysyłki. Nieskuteczny kontakt nie powoduje natychmiastowego dopisania do win-back. Przydział i pomiar pozostają utrwalone do końca 37-dniowego okna.

## A/B test z grupą kontrolną

**Hipoteza:** edukacyjne przedstawienie tej samej propozycji zwiększy drugi zakup względem przekazu bezpośrednio sprzedażowego.

| Grupa | Doświadczenie |
|---|---|
| Control | Brak dodatkowej komunikacji second-purchase |
| A | Propozycja kolejnego zakupu przedstawiona wprost |
| B | Ta sama propozycja przedstawiona przez wskazówki użycia i korzyści z uzupełnienia pielęgnacji |

Ta sama oferta, produkty, terminy, CTA i warunki cenowe w A/B; zmieniamy ramę przekazu w wiadomościach z rekomendacją. Pierwszy email wspierający jest taki sam w obu ramionach. Proponowany podział: 10% control, 45% A, 45% B, do potwierdzenia analizą mocy. Porównania z kontrolą mierzą wpływ całego journey, a B–A wpływ ramy przekazu. [Wspólny plan](ab-test-plan.md).
