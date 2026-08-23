# CPS — Windows-Skript-Interpreter

CPS führt `.cps`-Skripte aus: eine kompakte Skriptsprache für HTTP/REST-Aufrufe, JSON/XML-Extraktion, Datei- und Mailoperationen (IMAP/SMTP) — gedacht für die Anbindung von DataFlex-Altanwendungen an moderne Web-APIs.

## Download

Die aktuelle Version steht unter **[Releases](../../releases)** als ZIP-Paket bereit. Inhalt:

| Datei | Zweck |
|---|---|
| `cps.exe` | Interpreter (Produktivversion) |
| `cpss.exe` | Wie `cps.exe`, mit eigenem Konsolenfenster |
| `libcurl.dll` | HTTP/IMAP/SMTP-Bibliothek (muss neben der EXE liegen) |
| `CPS_Anleitung.md` | Benutzerhandbuch |

**Installation:** ZIP in einen beliebigen Ordner entpacken — keine weitere Installation nötig.

```
cps mein_skript.cps
```

## Dokumentation

Das vollständige Benutzerhandbuch liegt hier im Repo: **[CPS_Anleitung.md](CPS_Anleitung.md)**

Was sich von Version zu Version geändert hat, steht im **[CHANGELOG.md](CHANGELOG.md)**.

## Systemvoraussetzungen

- Windows 10/11, 64-Bit
- Keine Installation, keine Admin-Rechte nötig

## Rechtliches

© Frigyes Nagy. Alle Rechte vorbehalten.
Die Programme und Unterlagen werden Kunden zur Nutzung bereitgestellt; Veränderung und Weiterverbreitung sind nicht gestattet.
