# ============================================================
# beispiel_kette.cps - Verkettete Web-Abfragen
#
# Das Grundmuster jeder API-Anbindung: eine Abfrage starten,
# die Rueckmeldung einbinden und damit die naechste Abfrage
# fuettern - hier komplett ohne Zugangsdaten, sofort lauffaehig:
#
#   1. Ortsname -> Geocoding-API   (Koordinaten, Land, Einwohner)
#   2. Koordinaten -> Wetter-API   (aktuelle Werte fuer genau
#                                   diesen Punkt)
#   3. Antwort aufbereiten         (Wettercode -> Klartext)
#
# APIs: open-meteo.com (frei, kein API-Key noetig)
#
# Start:   cps.exe beispiele\beispiel_kette.cps
#          cps.exe beispiele\beispiel_kette.cps Budapest
# ============================================================

# --- Ort aus Parameter 1, sonst Standardwert ---
%ort = Wien
if %1 %ort = (%1)

> [cyan]--- Abfrage 1: Wo liegt "(%ort)"? ---[#0]

# Der url-Prozessor kodiert den Ort direkt in der URL
# (Leerzeichen, Umlaute usw. werden URL-sicher)
!> https://geocoding-api.open-meteo.com/v1/search?name=(%ort url)&count=1&language=de -t 15 -ehj :api_err

# Rueckmeldung einbinden: Koordinaten und Infos in Variablen
!< %fundort=results[0].name %land=results[0].country
!< %lat=results[0].latitude %lon=results[0].longitude
!< %einwohner=results[0].population

ifnot %lat :ort_unbekannt

> Gefunden: (%fundort), (%land)
> Koordinaten: (%lat) / (%lon), Einwohner: (%einwohner)

# ============================================================
# Abfrage 2 wird mit dem ERGEBNIS von Abfrage 1 gefuettert:
# (%lat) und (%lon) stehen direkt in der naechsten URL
# ============================================================
> [cyan]--- Abfrage 2: Wetter an diesen Koordinaten ---[#0]

!> https://api.open-meteo.com/v1/forecast?latitude=(%lat)&longitude=(%lon)&current_weather=true -t 15 -ehj :api_err

!< %temp=current_weather.temperature %wind=current_weather.windspeed
!< %code=current_weather.weathercode

# --- Rueckmeldung aufbereiten: WMO-Wettercode -> Klartext ---
%wetter = Wettercode (%code)
if %code = 0 %wetter = klar
if %code = 1 %wetter = heiter
if %code = 2 %wetter = wolkig
if %code = 3 %wetter = bedeckt
if %code = 45 %wetter = Nebel
if %code = 61 %wetter = Regen
if %code = 71 %wetter = Schneefall
if %code = 95 %wetter = Gewitter

> [/darkblue white] Wetter in (%fundort): (%temp) Grad, Wind (%wind) km/h, (%wetter) [#0]
> [green]Fertig - zwei verkettete Abfragen, Ergebnis aufbereitet.[#0]
exit 0

# ============================================================
# Fehlerpfade
# ============================================================
:ort_unbekannt
> [red]Ort "(%ort)" nicht gefunden - anderen Namen versuchen.[#0]
exit 1

:api_err
> [/darkred white] HTTP-Fehler [#0]
> URL:  (%http_method%) (%http_url%)
> Code: (%http_code%)  CURL: (%curlrc%)  Zeit: (%http_time%)
ifnot %http_error% +1
> Fehler: (%http_error%)
exit 9
