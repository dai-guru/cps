# ============================================================
# beispiel_http.cps - HTTP-Request mit JSON-Extraktion
# Fragt die GitHub-API nach der neuesten CPS-Version.
# Braucht Internet; Fehler landen im Handler :api_err.
#
# Start:  cps.exe beispiele\beispiel_http.cps
# ============================================================

# HTTP-Block: beginnt mit !> URL, endet an der Leerzeile.
#   -t 15    Timeout 15 Sekunden
#   -ehj     Fehler-Sprung bei CURL-Fehler, HTTP != 2xx oder Nicht-JSON
!> https://api.github.com/repos/dai-guru/cps/releases/latest -t 15 -ehj :api_err
-H "User-Agent: cps-beispiel"

# Nach dem Request ist %json automatisch gesetzt.
# !< extrahiert daraus (Typ kommt aus (%http_type%)).
!< %version=tag_name %asset1=assets[0].name

> [cyan]--- Ergebnis ---[#0]
> HTTP-Status: (%http_code%), Typ: (%http_type%), Dauer: (%http_time%)
> Neueste CPS-Version:  [yellow](%version)[#0]
> Erstes Release-Asset: (%asset1)
> [green]Fertig - beispiel_http.cps durchlaufen.[#0]
exit 0

# --- Fehler-Handler (siehe -ehj oben) ---
:api_err
> [/darkred white] HTTP-Fehler [#0]
> [red]URL:  (%http_method%) (%http_url%)[#0]
> [red]Code: (%http_code%)  CURL: (%curlrc%)[#0]
ifnot %http_error% +1
> [red]Fehler: (%http_error%)[#0]
exit 1
