### Instrukcja użytkowania skryptu PowerShell do aktualizacji pliku `hosts` z listą złośliwych domen CERT Polska

conatct me : github.matjan@gmail.com

Skrypt umożliwia pobranie listy złośliwych domen z **CERT Polska**, wykonanie kopii zapasowej pliku `hosts`, a następnie zaktualizowanie tego pliku na komputerze. Wszystko odbywa się automatycznie, a ewentualne błędy są logowane do osobnego pliku.

---

### Jak działa skrypt?

1. **Backup pliku `hosts`**:
   - Przed dokonaniem jakiejkolwiek zmiany w pliku `hosts`, skrypt wykonuje kopię zapasową tego pliku.
   - Kopia zapasowa jest zapisywana w folderze `C:\Windows\System32\drivers\etc\backup` jako `hosts_backup.txt`.
   - Tylko **aktualna wersja** pliku `hosts` zostaje zapisana w kopii zapasowej. Stare wpisy są usuwane, a nowe domeny dodawane.
   
2. **Pobieranie listy złośliwych domen**:
   - Skrypt pobiera aktualną listę złośliwych domen udostępnioną przez **CERT Polska** pod adresem: `https://hole.cert.pl/domains/v2/domains_hosts.txt`.
   - Zawartość listy jest zapisywana w pliku tymczasowym w folderze `%TEMP%`, który jest później wykorzystywany do zaktualizowania pliku `hosts`.

3. **Aktualizacja pliku `hosts`**:
   - Po pobraniu listy złośliwych domen skrypt aktualizuje plik `hosts` na komputerze. 
   - Wpisy z listy CERT Polska są dodawane do pliku `hosts` w odpowiednim formacie, który blokuje dostęp do tych domen.
   - Plik `hosts` zostaje zaktualizowany między znacznikami `# START CERT.PL HOSTS LIST` oraz `# END CERT.PL HOSTS LIST`.

4. **Logowanie błędów**:
   - Jeśli wystąpi jakikolwiek błąd (np. błąd pobierania pliku lub problem z dostępem do pliku `hosts`), skrypt zapisuje szczegóły błędu do pliku logu `error.log`, który znajduje się w folderze **Pobrane** (`Downloads`).

---

### Instrukcja krok po kroku

#### 1. Pobierz i zapisz skrypt
- Skopiuj kod skryptu do pliku z rozszerzeniem `.ps1` (np. `update_hosts.ps1`).

#### 2. Uruchom skrypt jako administrator
- Skrypt wymaga uprawnień administratora, ponieważ będzie modyfikował plik `hosts` w systemowym folderze `C:\Windows\System32\drivers\etc`.
- Aby uruchomić skrypt jako administrator:
  1. Kliknij prawym przyciskiem myszy na plik skryptu.
  2. Wybierz opcję **"Uruchom jako administrator"**.

#### 3. Co się wydarzy po uruchomieniu skryptu?
- Skrypt wykona następujące kroki:
  1. **Backup pliku hosts**: Sprawdzi, czy folder `backup` istnieje. Jeśli nie, utworzy go. Następnie wykona kopię zapasową pliku `hosts` w tym folderze, usuwając stare wpisy z listy CERT Polska i dodając nowe.
  2. **Pobranie listy złośliwych domen**: Skrypt pobierze najnowszą listę złośliwych domen z CERT Polska.
  3. **Aktualizacja pliku hosts**: Skrypt zaktualizuje plik `hosts`, dodając do niego nowe domeny z pobranej listy, które będą blokowane przez system.
  4. **Logowanie błędów**: W przypadku wystąpienia jakiegokolwiek błędu, szczegóły błędu zostaną zapisane do pliku `error.log` w folderze **Pobrane**.

#### 4. Co się stanie po zakończeniu działania skryptu?
- Plik `hosts` zostanie zaktualizowany, a kopia zapasowa zostanie zapisana w folderze `C:\Windows\System32\drivers\etc\backup\hosts_backup.txt`.
- Jeśli skrypt napotka jakiekolwiek błędy, zostaną one zapisane do pliku `error.log` w folderze **Pobrane**.

#### 5. Jak sprawdzić kopię zapasową?
- Kopia zapasowa pliku `hosts` będzie zapisana w folderze `C:\Windows\System32\drivers\etc\backup\hosts_backup.txt`. 
- Będzie ona zawierała tylko aktualne domeny z listy CERT Polska.

---

### Jak działa plik `hosts`?

Plik `hosts` to specjalny plik w systemie operacyjnym, który mapuje nazwy domenowe (np. `zlosliwa-domena.com`) na adresy IP (np. `127.0.0.1`). System operacyjny używa tego pliku do rozwiązywania nazw domenowych. Jeśli wpis w pliku `hosts` jest skierowany na adres IP `127.0.0.1`, to próba wejścia na tę domenę w przeglądarce zostanie zablokowana (ponieważ adres `127.0.0.1` wskazuje na lokalny komputer, co nie prowadzi do żadnej strony internetowej).

W przypadku tego skryptu, **złośliwe domeny** CERT Polska będą kierowane na adres IP serwera lokalnego, co uniemożliwi dostęp do tych stron.

---

### Jakie są wymagania?

1. **System operacyjny**: Skrypt działa na systemach Windows, ponieważ manipuluje plikiem `hosts` znajdującym się w systemowym folderze.
2. **Uprawnienia administratora**: Skrypt wymaga uprawnień administratora, ponieważ modyfikuje plik systemowy `hosts`.
3. **Połączenie internetowe**: Skrypt wymaga dostępu do internetu w celu pobrania listy złośliwych domen z CERT Polska.

---

### Podsumowanie

Ten skrypt jest narzędziem umożliwiającym automatyczne blokowanie złośliwych domen na Twoim komputerze przez aktualizację pliku `hosts`. Regularne uruchamianie tego skryptu pomoże w utrzymaniu systemu w bezpiecznym stanie, chroniąc przed dostępem do stron internetowych zawierających złośliwe treści.
