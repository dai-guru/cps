# ============================================================
# beispiel_uid.cps - UID-Nummern-Pruefung ueber FinanzOnline
#
# Die Haupt-Demo: eine komplette Web-Anwendung in einem Skript.
#   1. Login am FinanzOnline-Webservice (SOAP) -> Session-ID
#   2. UID-Abfrage Stufe 2 (liefert Name + Adresse des Inhabers)
#   3. Logout
# Alles laeuft im Speicher ueber die eingebaute libcurl -
# kein curl.exe-Aufruf, keine Temp-Dateien.
#
# Start:   cps.exe beispiele\beispiel_uid.cps ATU12345678
#
# Zugang:  FinanzOnline-Webservice-Benutzer noetig (Teilnehmer-ID,
#          Benutzer-ID, PIN, eigene UID). Einmalig hinterlegen:
#          beispiel_uid_zugang.muster nach beispiel_uid_zugang.cps
#          kopieren und ausfuellen (bleibt lokal, gehoert NICHT
#          in ein Repo).
#
# Exit-Codes (fuer aufrufende Programme, z.B. per (%curlrc%)
# nach runw oder %ERRORLEVEL% in Batch):
#   0 = UID gueltig      1 = UID ungueltig    7 = nicht pruefbar
#   9 = Login-Fehler     2 = Aufruf/Konfiguration unvollstaendig
# ============================================================

# --- Zu pruefende UID kommt als Parameter 1 ---
ifnot %1 :aufruf_fehlt
%pruefuid = (%1)

# --- Zugangsdaten laden und pruefen ---
include beispiel_uid_zugang.cps
ifnot %fon_tid :konfig_fehlt
ifnot %fon_benid :konfig_fehlt
ifnot %fon_pin :konfig_fehlt
ifnot %fon_uid :konfig_fehlt

> [cyan]--- UID-Pruefung: (%pruefuid) ---[#0]
> Anmeldung bei FinanzOnline ...

# ============================================================
# Schritt 1: Login -> Session-ID
# -ehx springt bei CURL-Fehler, HTTP != 2xx oder Nicht-XML
# ============================================================
!> https://finanzonline.bmf.gv.at/fonws/ws/session -t 15 -ehx :http_fehler
-H "Content-Type: text/xml;charset=UTF-8"
-H "SOAPAction: login"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ses="https://finanzonline.bmf.gv.at/fon/ws/session">
  <soapenv:Header/>
  <soapenv:Body>
     <ses:loginRequest>
        <ses:tid>(%fon_tid)</ses:tid>
        <ses:benid>(%fon_benid)</ses:benid>
        <ses:pin>(%fon_pin)</ses:pin>
        <ses:herstellerid>(%fon_uid)</ses:herstellerid>
     </ses:loginRequest>
  </soapenv:Body>
</soapenv:Envelope>

# Antwort: <id> = Session, <rc> = Returncode, <msg> = Meldung
!< xml %session=id %rc1=rc %msg1=msg

if %rc1 = 0 next else :login_fehler undef :login_fehler

# ============================================================
# Schritt 2: UID-Abfrage Stufe 2
# uid_tn = eigene UID, uid = zu pruefende UID
# Stufe 2 liefert bei Gueltigkeit Name und Adresse zurueck.
# ============================================================
> Session offen, frage UID ab ...

!> https://finanzonline.bmf.gv.at/fon/ws/uidAbfrage -t 20 -ehx :http_fehler
-H "Content-Type: text/xml;charset=UTF-8"
-H "SOAPAction: upload"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:uid="https://finanzonline.bmf.gv.at/fon/ws/uidAbfrage">
  <soapenv:Header/>
  <soapenv:Body>
     <uid:uidAbfrageServiceRequest>
        <uid:tid>(%fon_tid)</uid:tid>
        <uid:benid>(%fon_benid)</uid:benid>
        <uid:id>(%session)</uid:id>
        <uid:uid_tn>(%fon_uid)</uid:uid_tn>
        <uid:uid>(%pruefuid)</uid:uid>
        <uid:stufe>2</uid:stufe>
     </uid:uidAbfrageServiceRequest>
  </soapenv:Body>
</soapenv:Envelope>

!< xml %rc2=rc %msg2=msg %nameon=name %adrz1 %adrz2 %adrz3

if %rc2 = 0 next else :nicht_gueltig undef :nicht_pruefbar

# --- rc = 0: UID ist gueltig, Adresse anzeigen ---
# toutf8 dekodiert HTML-Entities aus der SOAP-Antwort
>
> [/darkgreen white] UID (%pruefuid) ist gueltig [#0]
> Inhaber:  (%nameon toutf8)
> Adresse:  (%adrz1 toutf8)
>           (%adrz2 toutf8) (%adrz3 toutf8)
%ergebnis = 0
goto :logout

# --- rc = 1 oder 4: UID ungueltig bzw. formal falsch ---
:nicht_gueltig
if %rc2 = 1 :ungueltig
if %rc2 = 4 :ungueltig

# --- alle anderen rc: derzeit nicht pruefbar ---
:nicht_pruefbar
>
> [/darkyellow black] UID (%pruefuid) derzeit nicht pruefbar [#0]
> Code (%rc2): (%msg2 toutf8)
%ergebnis = 7
goto :logout

:ungueltig
>
> [/darkred white] UID (%pruefuid) ist NICHT gueltig [#0]
> Code (%rc2): (%msg2 toutf8)
%ergebnis = 1

# ============================================================
# Schritt 3: Logout (Session immer schliessen)
# ============================================================
:logout
!> https://finanzonline.bmf.gv.at/fonws/ws/session -t 10
-H "Content-Type: text/xml;charset=UTF-8"
-H "SOAPAction: logout"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ses="https://finanzonline.bmf.gv.at/fon/ws/session">
  <soapenv:Header/>
  <soapenv:Body>
     <ses:logoutRequest>
        <ses:tid>(%fon_tid)</ses:tid>
        <ses:benid>(%fon_benid)</ses:benid>
        <ses:id>(%session)</ses:id>
     </ses:logoutRequest>
  </soapenv:Body>
</soapenv:Envelope>

> Abgemeldet.
exit (%ergebnis)

# ============================================================
# Fehlerpfade
# ============================================================
:aufruf_fehlt
> [red]Aufruf: cps beispiel_uid.cps ATU12345678[#0]
exit 2

:konfig_fehlt
> [red]Zugangsdaten fehlen.[#0]
> beispiel_uid_zugang.muster nach beispiel_uid_zugang.cps kopieren
> und die FinanzOnline-Webservice-Daten eintragen.
exit 2

:login_fehler
> [/darkred white] Login fehlgeschlagen [#0]
> Code (%rc1): (%msg1 toutf8)
exit 9

:http_fehler
> [/darkred white] HTTP-Fehler [#0]
> URL:  (%http_method%) (%http_url%)
> Code: (%http_code%)  CURL: (%curlrc%)  Zeit: (%http_time%)
ifnot %http_error% +1
> Fehler: (%http_error%)
exit 9
