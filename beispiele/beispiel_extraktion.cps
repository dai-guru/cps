# ============================================================
# beispiel_extraktion.cps - JSON-, XML- und Muster-Extraktion
# Die Beispieldaten stehen direkt im Skript - kein Netz noetig.
# (Nach einem HTTP-Request setzt CPS %json bzw. %xml automatisch,
#  die extract-Befehle funktionieren dann genauso.)
#
# Start:  cps.exe beispiele\beispiel_extraktion.cps
# ============================================================

# --- JSON: %json setzen, dann extract json ---
%json = {"kunde": {"name": "Anna Muster", "plz": "12345"}, "posten": [{"artikel": "Schrauben", "menge": 500}, {"artikel": "Duebel", "menge": 200}], "offen": true}

extract json %name=kunde.name %plz=kunde.plz
extract json %art1=posten[0].artikel %menge1=posten[0].menge
extract json %offen

> [cyan]--- JSON ---[#0]
> Kunde: (%name), PLZ (%plz)
> Posten 1: (%menge1) x (%art1)
> Offen (boolean als 1/0): (%offen)

# --- XML: %xml setzen, dann extract xml ---
# tag@attr liest Attribute, tag den Element-Text
%xml = <bestellung nr="4711"><kunde typ="firma">Muster GmbH</kunde><summe waehrung="EUR">1234,56</summe></bestellung>

extract xml %nr=bestellung@nr %firma=kunde %typ=kunde@typ %summe=summe

> [cyan]--- XML ---[#0]
> Bestellung (%nr) von (%firma) (Typ: (%typ)): EUR (%summe)

# --- Legacy-Muster mit ^ fuer unstrukturierte Texte ---
# Das Zeichen NACH dem ^ ist der Delimiter (hier: Leerzeichen
# bzw. schliessende Klammer)
%text = Lieferung LID=98765 Par=(express) am 30.08.2026

extract %text %lid='LID=^ ' %par='Par=(^)'

> [cyan]--- Muster ---[#0]
> LID: (%lid), Versandart: (%par)

> [green]Fertig - beispiel_extraktion.cps durchlaufen.[#0]
exit 0
