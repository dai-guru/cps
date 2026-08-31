# ============================================================
# beispiel_prozessoren.cps - String-, Encoding- und Hash-Prozessoren
# Aufruf: (%var prozessor) oder (%var prozessor:param), verkettbar.
# Laeuft komplett offline.
#
# Start:  cps.exe beispiele\beispiel_prozessoren.cps
# ============================================================

%wort = CPS-Beispiel

> [cyan]--- Strings ---[#0]
> lower:     (%wort lower)
> left:3     (%wort left:3)
> right:8    (%wort right:8)
> len:       (%wort len)
> pad:16     [(%wort pad:16)]

> [cyan]--- Encoding ---[#0]
%frage = Preis > 100 EUR & Rabatt?
> urlencode:  (%frage url)
> base64:     (%wort b64)
> base64url:  (%wort b64u)
> hex:        (%wort hex)

> [cyan]--- Zahlen ---[#0]
%cent = 12345
> cent2eur:  (%cent cent2eur) EUR
%zahl = 3,14159
> dec (2):   (%zahl dec)
> dec:4      (%zahl dec:4)

> [cyan]--- Hash und Verkettung ---[#0]
%seed = musterdaten
> sha256:           (%seed sha256)
> sha256 + left:16: (%seed sha256 left:16)

> [green]Fertig - beispiel_prozessoren.cps durchlaufen.[#0]
exit 0
