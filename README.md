# UpdateHosts - Automatyczna aktualizacja pliku hosts

Contact me: github.matjan@gmail.com

Ten projekt umożliwia automatyczną aktualizację pliku `hosts` na komputerach z systemem Windows za pomocą listy złośliwych domen udostępnianej przez CERT Polska.

## Funkcje

- Tworzenie kopii zapasowej pliku `hosts`.
- Pobieranie aktualnej listy złośliwych domen z CERT Polska.
- Aktualizacja pliku `hosts` o nowe wpisy.

## Struktura projektu

UpdateHosts/ ├── scripts/ │ ├── UpdateHosts.ps1 # Skrypt PowerShell │ └── UpdateHosts.bat # Plik BAT uruchamiający skrypt PowerShell jako administrator ├── README.md # Dokumentacja projektu

## Wymagania

- System operacyjny: Windows 10 lub nowszy.
- Uprawnienia administratora.

## Instrukcja użycia

1. **Pobierz repozytorium**:
Lub pobierz pliki w formacie ZIP i wypakuj je.

2. **Skopiuj pliki**:
Umieść folder `scripts` na serwerze lub lokalnie.

3. **Uruchom plik BAT**:
Kliknij dwukrotnie `UpdateHosts.bat`, aby uruchomić skrypt z uprawnieniami administratora.

## Wdrożenie w sieci

Aby wdrożyć skrypt na wielu komputerach:
1. Udostępnij folder `scripts` w sieci z prawami do odczytu.
2. Użyj **Group Policy** do skonfigurowania uruchamiania pliku `UpdateHosts.bat` przy starcie systemu:
- W **GPO**, przejdź do: `Computer Configuration > Policies > Windows Settings > Scripts (Startup/Shutdown)`.
- Dodaj ścieżkę sieciową do pliku `UpdateHosts.bat`.

## Logi błędów

Wszystkie błędy są zapisywane w pliku:
%USERPROFILE%\Downloads\error.log

## Uwagi

Jeśli plik `hosts` nie zostanie zaktualizowany, sprawdź logi błędów i upewnij się, że skrypt ma odpowiednie uprawnienia do modyfikacji pliku.

## Licencja

Projekt jest udostępniany na licencji MIT.
