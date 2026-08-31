# ============================================================
# beispiel_sprache.cps - Rundgang durch die CPS-Skriptsprache
# Laeuft komplett offline, ohne Nebenwirkungen.
#
# Start:  cps.exe beispiele\beispiel_sprache.cps
# ============================================================

# --- Variablen: alle Schreibweisen sind gleichwertig ---
%name Anna Muster
%ort = Musterstadt
plz: 12345

> [cyan]--- Variablen ---[#0]
> Kunde: (%name), (%plz) (%ort)

# Quotes sind Begrenzer: aussen gestrippt, Inhalt bleibt erhalten
%zitat = "  mit  Leerzeichen  "
> Zitat in Klammern: [(%zitat)]

# --- Prozessoren direkt in der Referenz ---
> Kleinbuchstaben:   (%name lower)
> Erste 4 Zeichen:   (%name left:4)
> Laenge:            (%name len)

# --- Bedingungen: if / ifnot mit else ---
> [cyan]--- Bedingungen ---[#0]
%stand = 42
if %stand > 40 :gross else :klein

:gross
> Stand (%stand) ist gross
goto :weiter

:klein
> Stand (%stand) ist klein

:weiter
# Zuweisung als Aktion (statt Sprungmarke)
if %stand = 42 %antwort = richtig else %antwort = falsch
> Antwort: (%antwort)

# "in" prueft Teilstring, case-insensitive
if "muster" in %name :enthalten
goto :subdemo

:enthalten
> Der Name enthaelt "muster"

# --- Subroutine: gosub / return (max. 1 Ebene) ---
:subdemo
> [cyan]--- Subroutine ---[#0]
%wer = Welt
gosub :gruss
%wer = CPS
gosub :gruss
goto :ende

:gruss
> Hallo, (%wer)!
return

:ende
> [green]Fertig - beispiel_sprache.cps ohne Fehler durchlaufen.[#0]
exit 0
