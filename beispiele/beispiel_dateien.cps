# ============================================================
# beispiel_dateien.cps - Dateien schreiben, lesen, ersetzen
# Erzeugt seine Ergebnisdateien im Skriptordner:
#   beispiel_dateien_brief.txt, beispiel_dateien_werte.txt,
#   beispiel_dateien_ersetzt.txt
#
# Start:  cps.exe beispiele\beispiel_dateien.cps
# ============================================================

%kunde = Anna Muster
%betrag = 149,90

# --- Datei schreiben: !> pfad, Block endet an der Leerzeile ---
# ":" allein am Zeilenanfang fuegt eine Leerzeile in die Datei ein
!> beispiel_dateien_brief.txt
Rechnung fuer (%kunde)
:
Betrag: EUR (%betrag)
Vielen Dank fuer Ihren Einkauf!

> [green]beispiel_dateien_brief.txt geschrieben[#0]

# --- Include-Datei schreiben und wieder laden ---
# Format "name: wert" - beim include entstehen daraus Variablen
!> beispiel_dateien_werte.txt
kunde2: Bernd Beispiel
limit: 500

include beispiel_dateien_werte.txt
> Aus Include geladen: (%kunde2), Limit (%limit)

# --- Datei komplett in eine Variable lesen ---
readfile %brief beispiel_dateien_brief.txt
> Der Brief hat (%brief len) Zeichen

# --- Text-Ersetzung: Quelle lesen, ersetzen, Ziel schreiben ---
!> beispiel_dateien_ersetzt.txt <r< beispiel_dateien_brief.txt   Anna Bernd

> Ersetzung geschrieben (Anna -> Bernd)

# --- Muster-Extraktion aus Datei (^ = Platzhalter) ---
!< beispiel_dateien_brief.txt %summe='Betrag: EUR ^'
> Extrahierter Betrag: (%summe)

> [green]Fertig - beispiel_dateien.cps durchlaufen.[#0]
exit 0
