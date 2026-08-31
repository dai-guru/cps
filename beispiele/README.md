# Beispiele

Lauffähige `.cps`-Beispielskripte. Zu jedem Skript liegt die fertige
Konsolenausgabe daneben (Spalte „Ergebnis") — zum Ansehen im Browser, ohne
CPS zu starten. Zum Selbst-Ausführen das Skript an `cps.exe` übergeben
(EXE und `libcurl.dll` aus dem [Release-ZIP](../../../releases)):

```
cps.exe beispiele\beispiel_sprache.cps
```

Die Kommentare in den Skripten erklären jede Zeile — die Beispiele sind
zugleich die Kurzdoku. Die vollständige Referenz steht in der
[CPS_Anleitung.md](../CPS_Anleitung.md).

## Haupt-Demo: UID-Prüfung über FinanzOnline

**`beispiel_uid.cps`** ([Ausgabe](beispiel_uid.out.txt)) zeigt, wofür CPS
gebaut ist — eine komplette Webservice-Anwendung in einem Skript:
**Login** am FinanzOnline-SOAP-Service (Session-ID holen), **UID-Abfrage
Stufe 2** (liefert bei gültiger UID Name und Adresse des Inhabers zurück),
**Logout** — mit Fehlerbehandlung für jeden Schritt und Exit-Codes
(0 = gültig, 1 = ungültig, 7 = nicht prüfbar, 9 = Login-Fehler), die ein
aufrufendes Programm direkt auswerten kann. Alle drei Requests laufen im
Speicher über die eingebaute libcurl — kein `curl.exe`-Aufruf, keine
Temp-Dateien.

Zum Ausführen wird ein eigener FinanzOnline-Webservice-Benutzer benötigt:
[`beispiel_uid_zugang.muster`](beispiel_uid_zugang.muster) nach
`beispiel_uid_zugang.cps` kopieren und ausfüllen (bleibt lokal, ist per
`.gitignore` vom Repo ausgeschlossen). Die beigelegte Ausgabe stammt aus
einem echten Lauf; UID, Name und Adresse des gültigen Treffers wurden
durch Musterdaten ersetzt, der zweite Lauf (ungültige UID) ist unverändert.

## Weitere Beispiele

| Datei | Ergebnis | Zeigt |
|---|---|---|
| `beispiel_kette.cps` | [Ausgabe](beispiel_kette.out.txt) | **Verkettete Abfragen ohne Zugangsdaten** — das Grundmuster jeder API-Anbindung, sofort lauffähig: Ortsname → Geocoding-API → Koordinaten aus der Antwort direkt in die Wetter-API → Wettercode in Klartext übersetzen. `cps beispiel_kette.cps Budapest` fragt einen anderen Ort ab. Wetterwerte ändern sich naturgemäß je Lauf. |
| `beispiel_sprache.cps` | [Ausgabe](beispiel_sprache.out.txt) | Rundgang durch die Sprache: Variablen (drei Schreibweisen), Quotes, Prozessoren in der Referenz, `if`/`ifnot` mit `else`, Teilstring-Prüfung `in`, `goto`, Subroutinen mit `gosub`/`return`. Läuft offline. |
| `beispiel_dateien.cps` | [Ausgabe](beispiel_dateien.out.txt) · [Brief](beispiel_dateien_brief.txt) · [Include](beispiel_dateien_werte.txt) · [Ersetzt](beispiel_dateien_ersetzt.txt) | Dateien schreiben (`!>`-Block), Include-Dateien erzeugen und laden, Datei in Variable lesen (`readfile`), Text-Ersetzung (`<r<`), Muster-Extraktion aus Datei (`!<` mit `^`). Die drei Textdateien sind die vom Skript erzeugten Ergebnisse. |
| `beispiel_extraktion.cps` | [Ausgabe](beispiel_extraktion.out.txt) | JSON-Extraktion (Pfade wie `kunde.name`, `posten[0].artikel`, boolean), XML-Extraktion (Element-Text, Attribute per `tag@attr`) und Legacy-Muster mit `^`-Platzhalter. Beispieldaten stehen im Skript — läuft offline. |
| `beispiel_prozessoren.cps` | [Ausgabe](beispiel_prozessoren.out.txt) | String-Prozessoren (`lower`, `left`, `right`, `len`, `pad`), Encoding (`url`, `b64`, `b64u`, `hex`), Zahlenformate (`cent2eur`, `dec`), SHA-256 und Prozessor-Verkettung. Läuft offline. |
| `beispiel_http.cps` | [Ausgabe](beispiel_http.out.txt) | HTTP-Request (`!>`-Block mit Header und Timeout), automatische JSON-Erkennung, Extraktion mit `!<`, HTTP-Systemvariablen und Fehler-Handler (`-ehj`). Fragt die GitHub-API nach der neuesten CPS-Version — braucht Internet. |

Alle Ausgabedateien wurden mit der Release-Version von `cps.exe` erzeugt
(Aufruf mit `-b` für Batch-Modus, keines der Beispiele erwartet Eingaben).

**Hinweis zu `beispiel_http.cps`:** Die Zeile mit der Dauer (`225ms`) und
die gemeldete Versionsnummer ändern sich naturgemäß von Lauf zu Lauf bzw.
mit jedem neuen Release — die beigelegte Ausgabe zeigt den Stand bei
v07.07.26.

**Hinweis zur Zeichenkodierung:** Die Skripte sind bewusst in reinem ASCII
gehalten (`ue` statt `ü`), damit die Ausgabe in jeder Windows-Konsole
unabhängig von der Codepage gleich aussieht. CPS selbst verarbeitet auch
UTF-8-Skripte und reicht die Bytes unverändert durch.

Alle Daten in den Beispielen (Namen, Adressen, Beträge, Bestellnummern)
sind frei erfundene Musterdaten.
