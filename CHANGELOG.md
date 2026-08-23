# Changelog

Alle für Anwender relevanten Änderungen an CPS.

## v07.07.26 — Stand 2026-08-23

### Neu
- **Selbst-Update:** neues Skript `cpsupdate.cps` prüft die neueste Version auf GitHub und aktualisiert CPS automatisch — geeignet als Menüpunkt „CPS aktualisieren" in der Anwendung.
- **MD5-Unterstützung:** neue Prozessoren `md5` und `md5file` in Skripten sowie die Kommandozeilenoptionen `-md5 <text>` und `-md5file <datei>` zum direkten Berechnen von MD5-Hashes.

### Verbessert
- **Mail-Verarbeitung (Mail-AI-Gateway):** Antworten per Mail führen den Gesprächsfaden fort (Thread-Gedächtnis); robustere Fehlerbehandlung, Duplikatprüfung beim Mailabruf und Korrektur einer UID-Kollision; neue Start-/Stop-Skripte für den Dienstbetrieb.
- **Auslieferung:** `libcurl.dll` wird beim Build automatisch neben die EXE gelegt — das ZIP-Paket ist damit immer vollständig.

## v07.07.26 — Erstveröffentlichung (2026-07-07)

- Skript-Interpreter für `.cps`-Dateien: Variablen, Bedingungen (`if`/`ifnot`), Sprungmarken, Subroutinen
- HTTP/REST-Requests mit JSON-, XML- und SOAP-Extraktion
- IMAP-Mailabruf (`mailget`, inkl. MIME-Zerlegung) und SMTP-Mailversand (`!> MAIL`, inkl. Anhänge)
- Dateioperationen, Text-Extraktion und -Ersetzung
- Farbige Konsolenausgabe, Logging, Post-Mortem-Dump
- Verschlüsselte Ablage von Zugangsdaten (`-e64`), SHA-256/AES-Prozessoren
