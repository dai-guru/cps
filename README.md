# CPS — Curl Program Script

CPS steuert curl per Skript: Was sonst einzelne `curl.exe`-Aufrufe mit langen Parameterketten wären, wird ein lesbares `.cps`-Skript — Requests, Antwort-Auswertung, Fehlerbehandlung und Weiterverarbeitung in einem. Die libcurl ist dabei **direkt eingebunden** (`libcurl.dll`): alle Abfragen laufen im Speicher, ohne Prozessstart und ohne Temp-Dateien — schneller und sicherer als curl-Kommandozeilen.

Die Skriptsprache bereitet die Ergebnisse gleich für die Weiterverarbeitung auf: JSON/XML-Extraktion in Variablen, formatierte Konsolenausgabe, Dateien und Exit-Codes für aufrufende Windows-Programme. Typischer Einsatz: bewährte Anwendungen (z.B. DataFlex) an Web-APIs anbinden — Token holen, abfragen, abmelden, alles in einem Skript. Dazu kommen Mailversand und -abruf (SMTP/IMAP, ebenfalls über libcurl) und Dateioperationen.

## Download

Die aktuelle Version steht unter **[Releases](../../releases)** als ZIP-Paket bereit. Inhalt:

| Datei | Zweck |
|---|---|
| `cps.exe` | Interpreter (Produktivversion) |
| `cpss.exe` | Wie `cps.exe`, mit eigenem Konsolenfenster |
| `libcurl.dll` | HTTP/IMAP/SMTP-Bibliothek (muss neben der EXE liegen) |
| `CPS_Anleitung.md` | Benutzerhandbuch |
| `cpsupdate.cps` | Selbst-Update-Skript (siehe unten) |

**Installation:** ZIP in einen beliebigen Ordner entpacken — keine weitere Installation nötig.

```
cps mein_skript.cps
```

## Automatisches Update

Das mitgelieferte Skript `cpsupdate.cps` prüft die hier veröffentlichte neueste Version und aktualisiert `cps.exe`, `cpss.exe` und `libcurl.dll` selbstständig (die neue Version gilt ab dem nächsten Start):

```
cps\cpss.exe cps\cpsupdate.cps
```

Der Aufruf eignet sich direkt als Menüpunkt „CPS aktualisieren" in der Anwendung (Annahme: CPS liegt im Unterordner `cps` des Anwendungsverzeichnisses — Pfade sonst anpassen). Mit dem Zusatzparameter `force` wird die aktuelle Version auch dann neu geladen, wenn sie bereits installiert ist (Reparatur).

## Beispiele

Im Ordner **[beispiele/](beispiele/)** liegen lauffähige `.cps`-Beispielskripte mit beigelegten Ergebnissen. Die **Haupt-Demo `beispiel_uid.cps`** ist eine echte Webservice-Anwendung in einem Skript: UID-Nummern-Prüfung über FinanzOnline — Login (Session-ID), SOAP-Abfrage mit Adress-Rückgabe, Logout, Exit-Codes für das aufrufende Programm. Dazu kommen Sprach-Rundgang, Dateioperationen, JSON/XML-Extraktion, Prozessoren und ein einfacher HTTP/JSON-Request. Die Kommentare im Skript erklären jede Zeile.

## Dokumentation

Das vollständige Benutzerhandbuch liegt hier im Repo: **[CPS_Anleitung.md](CPS_Anleitung.md)**

Was sich von Version zu Version geändert hat, steht im **[CHANGELOG.md](CHANGELOG.md)**.

## Systemvoraussetzungen

- Windows 10/11, 64-Bit
- Keine Installation, keine Admin-Rechte nötig

## Rechtliches

© Frigyes Nagy. Alle Rechte vorbehalten.
Die Programme und Unterlagen werden Kunden zur Nutzung bereitgestellt; Veränderung und Weiterverbreitung sind nicht gestattet.
