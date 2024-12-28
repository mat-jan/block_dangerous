Oto przykładowy opis, który możesz dodać do swojego repozytorium GitHub, zawierający instrukcje dla użytkowników:

---

# Skrypt PowerShell do aktualizacji pliku `hosts` z listą CERT Polska

## Opis

Ten skrypt PowerShell umożliwia automatyczne pobranie najnowszej listy złośliwych domen z **CERT Polska**, wykonanie kopii zapasowej aktualnego pliku `hosts` i aktualizację pliku `hosts` w systemie Windows, aby blokować złośliwe domeny. Skrypt obsługuje również logowanie błędów oraz uruchamianie w trybie administratora, jeśli nie został uruchomiony z odpowiednimi uprawnieniami.

## Funkcjonalności

1. **Pobieranie listy złośliwych domen**: Skrypt pobiera listę złośliwych domen z publicznego źródła CERT Polska.
2. **Aktualizacja pliku `hosts`**: Zawartość pliku `hosts` jest aktualizowana o nowe domeny, a stare wpisy związane z CERT Polska są usuwane.
3. **Kopia zapasowa**: Przed aktualizacją pliku `hosts`, skrypt wykonuje kopię zapasową pliku w folderze `backup`.
4. **Logowanie błędów**: Jeśli wystąpią jakiekolwiek błędy podczas wykonywania skryptu, są one zapisywane w pliku logów `error.log` w folderze **Pobrane** użytkownika.
5. **Automatyczne podniesienie uprawnień**: Skrypt automatycznie uruchomi się ponownie w trybie administratora, jeśli nie zostanie uruchomiony z odpowiednimi uprawnieniami.

## Instrukcja

### Wymagania

- Windows PowerShell (zalecana wersja 5.0 lub wyższa).
- Uprawnienia administratora na komputerze.

### Jak uruchomić skrypt

1. **Pobierz skrypt**:
   - Sklonuj repozytorium na swoje urządzenie lub pobierz plik skryptu bezpośrednio.
   
   ```bash
   git clone https://github.com/TwojeRepozytorium/skrypt.git
   ```

2. **Uruchom skrypt**:
   - Kliknij prawym przyciskiem myszy na plik skryptu PowerShell i wybierz **"Uruchom jako administrator"**, jeśli PowerShell już działa z uprawnieniami administratora, skrypt wykona się automatycznie.
   
   - Jeśli skrypt nie jest uruchomiony jako administrator, automatycznie poprosi o podniesienie uprawnień (wyświetli się okno UAC).

3. **Skrypt wykonuje następujące kroki**:
   - Sprawdza, czy działa w trybie administratora.
   - Jeśli nie, automatycznie uruchamia się ponownie z uprawnieniami administratora.
   - Tworzy kopię zapasową pliku `hosts`.
   - Pobiera nową listę złośliwych domen z **CERT Polska**.
   - Usuwa stare wpisy z listy CERT Polska z pliku `hosts`.
   - Dodaje nowe wpisy z listy CERT Polska do pliku `hosts`.
   - Loguje wszelkie błędy do pliku `error.log` w folderze Pobrane.

4. **Kopia zapasowa**:
   - Kopia zapasowa pliku `hosts` jest tworzona w folderze `System32\drivers\etc\backup`, a nazwa kopii zawiera datę i godzinę.

5. **Logowanie błędów**:
   - Jeśli podczas wykonywania skryptu wystąpią błędy, szczegóły błędów zostaną zapisane w pliku `error.log`, który znajduje się w folderze **Pobrane**.

### Harmonogramowanie zadania

Aby skrypt uruchamiał się codziennie o określonej godzinie (np. o 12:00), możesz skonfigurować **Harmonogram zadań** w systemie Windows, aby automatycznie uruchamiał się codziennie.

1. Otwórz **Harmonogram zadań** i kliknij **Utwórz zadanie**.
2. W zakładce **Ogólne** wpisz nazwę zadania.
3. W zakładce **Wyzwalacze** dodaj nowy wyzwalacz ustawiając godzinę na 12:00.
4. W zakładce **Akcje** dodaj nową akcję uruchamiającą PowerShell z parametrami:
   - **Program/script**: `powershell.exe`
   - **Dodaj argumenty**: `-NoProfile -ExecutionPolicy Bypass -File "C:\ścieżka\do\skryptu.ps1"`
5. Kliknij **OK** i wprowadź swoje uprawnienia administratora, aby zapisać zadanie.

## Licencja

Skrypt jest dostępny na licencji MIT.

## Problemy

Jeśli napotkałeś jakiekolwiek problemy, proszę zgłoś je w zakładce **Issues** na GitHubie. Jeśli masz propozycje ulepszeń lub dodatkowych funkcji, również możesz je dodać, otwierając **Pull Request**.

---

### Dodatkowe wskazówki:

- Jeśli chcesz, aby skrypt działał bez przerwy, uruchamiaj go regularnie za pomocą **Harmonogramu zadań** lub innego narzędzia do planowania zadań w systemie Windows.
