# CPS Script Interpreter

**Version:** v28.Feb.26  Windows (Win32)

CPS ist ein Windows-Skript-Interpreter für `.cps`-Dateien mit eigener Skriptsprache, speziell entwickelt für die Automatisierung von HTTP-Requests, Dateioperationen und die Kommunikation mit Externe-Anwendungen zB. Dataflex.

---

## Inhaltsverzeichnis

1. [Installation & Aufruf](#installation--aufruf)
2. [Grundlagen der Skriptsprache](#grundlagen-der-skriptsprache)
3. [Variablen](#variablen)
4. [Prozessoren](#prozessoren)
5. [Bedingte Ausführung (IF/IFNOT)](#bedingte-ausführung-ifnot)
6. [Sprungbefehle & Subroutinen](#sprungbefehle--subroutinen)
7. [Konsolenausgabe](#konsolenausgabe)
8. [Dateischreiben (!>)](#dateischreiben-)
9. [HTTP-Requests](#http-requests)
10. [JSON/XML-Parsing](#jsonxml-parsing)
11. [Text-Ersetzung](#text-ersetzung)
12. [Datei-Include](#datei-include)
13. [Prozessausführung](#prozessausführung)
14. [Pause & Benutzereingabe](#pause--benutzereingabe)
15. [MessageBox](#messagebox)
16. [E-Mail-Versand](#e-mail-versand)
17. [Clipboard](#clipboard)
18. [Logging](#logging)
19. [Post-Mortem-Dump](#post-mortem-dump)
20. [Include-Bibliothek (cpsincl.cps)](#include-bibliothek-cpsincl)
21. [FIFO-Kommunikation (DataFlex)](#fifo-kommunikation-dataflex)
22. [Debug-Modus](#debug-modus)
23. [Referenz: Alle Befehle](#referenz-alle-befehle)

---

## Installation & Aufruf

### Voraussetzungen

- `cps.exe` — Der Interpreter
- `libcurl.dll` — Im gleichen Verzeichnis wie cps.exe

### EXE-Varianten

| EXE | Script-Endung | Beschreibung |
|-----|--------------|--------------|
| `cps.exe` | `.cps` | Produktiv |
| `cpss.exe` | `.cps` | Produktiv, eigenes Konsolenfenster |
| `cpx.exe` | `.cpx` | Testversion/Parallel-Version aber mit .cpx Skripten  |

### Kommandozeile

```
cps.exe [Optionen] <skript[.cps]> [Parameter...]
```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-i` | Interne Infos (zeigt interne Operationen) |
| `-v:N` | Variante laden: `skript_N.cps` statt `skript.cps` |
| `-s`, `-silent` | Silent-Modus (keine Ausgaben) |
| `-b`, `-bat`, `-batch` | Batch-Modus (keine interaktiven Abfragen) |
| `-p`, `-pause` | Pause am Skriptende |
| `-l`, `-log` | Logging aktivieren |
| `-d`, `-debug` | Debug-Modus (Einzelschritt) |
| `-h`, `-help`, `-?` | Anleitung öffnen |
| `-w:handle` | Window-Handle für DataFlex-Kommunikation |

**`-v:N` Variante:** `cps -b -v:2 ku2abas` lädt `ku2abas_2.cps`. Die FIFO-Basis (`ku2abas`) bleibt unverändert.


### Beispiele

```bash
cps.exe api_call.cps
cps.exe -i upload.cps datei.txt
cps.exe -b -l sync.cps *9AW
cps.exe -b -v:2 ku2abas
```

---

## Grundlagen der Skriptsprache

### Zeilenstruktur

- Leerzeilen werden ignoriert
- `//` ist Kommentar wenn am Zeilenanfang (nach optionalem Whitespace) **oder** wenn ein Leerzeichen/Tab unmittelbar davor steht — Rest der Zeile wird ignoriert. Innerhalb von Quotes (`"..."` / `'...'`) nie Kommentar.
- Befehle beginnen mit Spezial-Präfix: `%`, `>`, `!>`, `!<`, `:`, `<`, `<<`

```
// ganzer Kommentar
   // auch Kommentar (Leerzeichen davor)
%url https://api.example.com       // kein Kommentar (kein Leerzeichen vor //)
%x http://test                     // kein Kommentar (kein Leerzeichen vor //)
%x http: //test                    // "http:" bleibt, Rest Kommentar
%x test // Kommentar ab hier       // Leerzeichen vor // → Kommentar
```

### Markdown-Modus

Wenn **Zeile 1** mit `#` oder `<!` (HTML-Kommentar) beginnt und mindestens ein Code-Fence (` ``` ` oder `~~~`) vorhanden ist, werden nur Inhalte innerhalb der Fences ausgeführt.

| Zeile 1 | Fence? | Verhalten |
|---------|:------:|-----------|
| Beginnt mit `#` | ja | Markdown-Modus, Fences steuern Skript-Blöcke |
| Beginnt mit `#` | nein | Normaler Skript-Modus (`#` = Kommentar) |
| Beginnt mit `<!` | ja | Markdown-Modus, `<!...->` als HTML-Kommentar übersprungen |
| Beginnt mit `<!` | nein | HTML-Kommentar übersprungen, normaler Skript-Modus |
| Sonstiges | — | Normaler Skript-Modus |

HTML-Kommentare werden durch `<!` geöffnet und durch `->` geschlossen — auch mehrzeilig. Die Bindestriche sind optional: `<! text ->` und `<!-- text -->` funktionieren beide (da `->` ein Teilstring von `-->` ist). Innerhalb von HTML-Kommentaren wird nichts ausgeführt.

### Zeichenkodierung

Skriptdateien sollten UTF-8 sein. Die Konsole verwendet UTF-8 für korrekte Umlaute.

---

## Variablen

### Zuweisung

Alle Formen sind gleichwertig:

```
%name Hans Müller
%name = Hans Müller
%name: Hans Müller
name: Hans Müller
```

**Quotes als Begrenzer** (werden gestrippt):

| Zuweisung | Gespeicherter Wert |
|-----------|-------------------|
| `%x hello` | `hello` |
| `%x "hello"` | `hello` |
| `%x "hello  "` | `hello  ` (Trailing Spaces erhalten) |
| `%x ""hello""` | `"hello"` (Doppelt → ein `"`) |
| `%x '"text"'` | `"text"` (Äußere `'`, innere `"` bleiben) |
| `%x (%y)` | Wert von y (kein Strip) |

**Erlaubte Zeichen:** `A-Z a-z 0-9 _ $ & # ä ö ü Ä Ö Ü ß` — case-insensitive. Nicht erlaubt: `-`, `.`, Leerzeichen.


### Variablenreferenz

| Syntax | Beschreibung |
|--------|--------------|
| `(%var)` | Normale Variable oder System-Variable |
| `(%var%)` | System-Variable (Zeitstempel, Umgebung, HTTP-State) |
| `(%var prozessor)` | Mit Prozessor transformieren |


### Kommandozeilen-Parameter

| Variable | Beschreibung |
|----------|--------------|
| `(%0)` | Skriptdatei-Name (wie auf Kommandozeile angegeben, inkl. Pfad falls angegeben) |
| `(%1)` | Erster Parameter |
| `(%2)` … `(%9)` | Weitere Parameter |

### System-Variablen

Erreichbar als `(%var)` oder `(%var%)`:

| Variable | Kurzform | Beschreibung |
|----------|----------|--------------|
| `(%curlrc%)` | — | CURL Return Code (0 = OK) |
| `(%winerror%)` | — | Letzter Windows-Fehlercode |
| `(%line%)` | Aktuelle Skript-Zeilennummer |
| `(%script%)` | — | Skriptdatei-Pfad |
| `(%pid%)` | — | Prozess-ID |
| `(%ver%)` | — | CPS-Version (`v23.Feb.26`) |
| `(%.%)` | — | Aktuelles Arbeitsverzeichnis |
| `(%..%)` | — | Übergeordnetes Verzeichnis |
| `(%home%)` | — | HOME-Verzeichnis (Fallback: TEMP) |
| `(%lastkey%)` | — | Letzte Taste bei pause |
| `(%mbox_result%)` | — | Ergebnis der letzten MessageBox |
| `(%incl_error%)` | — | `1` wenn include fehlgeschlagen |
| `(%incl_file%)` | — | Dateiname des fehlgeschlagenen Includes |
| `(%lasterror%)` | — | Letzter Fehlertyp |
| `(%lasterrormsg%)` | — | Letzte Fehlermeldung |
| `(%lasterrorline%)` | — | Zeile des letzten Fehlers |
| `(%lastifline%)` | — | Zeile des letzten IF-Sprungs |

Nur als `(%var%)` (Zeitstempel/Umgebung):

| Variable | Beschreibung |
|----------|--------------|
| `(%ts%)` / `(%timestamp%)` | Zeitstempel: `YYYY-MM-DD HH:MM:SS` |
| `(%date%)` | Datum: `YYYY-MM-DD` |
| `(%time%)` | Uhrzeit: `HH:MM:SS` |
| `(%now%)` | Zeit + ms: `HHMM_SS.mmm` |
| `(%PATH%)`, `(%TEMP%)`, … | Windows-Umgebungsvariablen |

### HTTP System-Variablen

| Variable | Beschreibung |
|----------|--------------|
| `(%http_response%)` | Response Body |
| `(%http_code%)` | HTTP Status Code |
| `(%http_type%)` | `JSON` / `XML` / `SOAP` / `HTML` / `TEXT` |
| `(%http_size%)` | Response Body Größe in Bytes |
| `(%http_url%)` | Verwendete URL |
| `(%http_method%)` | Verwendete HTTP-Methode |
| `(%http_time%)` | Request-Dauer (z.B. `245ms`) |
| `(%http_error%)` | Fehlermeldung bei CURL-Fehler |
| `(%http_content_type%)` | Content-Type der Response |
| `(%http_body%)` | Gesendeter Request-Body |
| `(%http_log%)` | Internes HTTP-Log |
| `(%json_error%)` | Fehler bei JSON-Extraktion |
| `(%xml_error%)` | Fehler bei XML-Extraktion |

### HTTP Auto-Response-Variablen

| `(%http_type%)` | Gesetzte Variable(n) | Gecleart |
|-----------------|----------------------|----------|
| `JSON` | `%json` | `%xml`, `%soap`, `%html` |
| `XML` | `%xml` | `%json`, `%soap`, `%html` |
| `SOAP` | `%soap` + `%xml` | `%json`, `%html` |
| `HTML` | `%html` | `%json`, `%xml`, `%soap` |
| `TEXT` | (keine) | alle |

---

## Prozessoren

Prozessoren transformieren Variablenwerte bei der Expansion.

### Syntax

```
(%variable prozessor)
(%variable prozessor:parameter)
```

Mehrere Prozessoren kombinierbar:

```
(%text trim lower left:20)
(%param trim urlencode)
```

### String-Manipulation

| Prozessor | Beschreibung |
|-----------|--------------|
| `upper` | Großbuchstaben (UTF-8, inkl. Umlaute) |
| `lower` | Kleinbuchstaben (UTF-8, inkl. Umlaute) |
| `trim` | Whitespace entfernen |
| `left:N` | Erste N Zeichen |
| `right:N` | Letzte N Zeichen |
| `len` / `length` | Zeichenanzahl |
| `pad:N` | Auf N Zeichen auffüllen (mit Leerzeichen) |

### Encoding

| Prozessor | Beschreibung |
|-----------|--------------|
| `url` / `urlencode` | URL-Encoding |
| `urldec` / `urldecode` | URL-Decoding |
| `b64` / `base64` | Base64 encode |
| `d64` | Base64 decode |
| `e64` | Base64 encode + Obfuskation (optional mit `%passpar`) |
| `b64u` | Base64URL encode (RFC 4648 §5: `+`→`-`, `/`→`_`, ohne `=`-Padding) |
| `b64udec` | Base64URL decode |
| `b642hex` | Base64 → Hex |
| `hex` | Bytes/Text → Hex (lowercase) |
| `hexdec` | Hex → Bytes/Text |
| `hex2b64` / `hex2b64u` | Hex → Base64 / Base64URL |
| `json` / `jsonesc` | JSON-String escapen |
| `toutf8` | HTML-Entities → UTF-8 (`&amp;`→`&`, `&auml;`→`ä`, `&#123;`→Zeichen) |
| `tooem` | HTML-Entities → OEM |
| `esc` / `nl` | Newlines/Tabs escapen (`\n`, `\t`) |

### Crypto

Krypto-Primitives via Windows BCrypt (`bcrypt.dll` per DelayLoad — wird erst beim ersten Crypto-Aufruf geladen).

| Prozessor | Beschreibung |
|-----------|--------------|
| `sha256` | SHA-256-Digest, **default Hex** (64 Zeichen) |
| `sha256:b64` | SHA-256-Digest als Base64 |
| `sha256:b64u` | SHA-256-Digest als Base64URL |
| `sha256:bytes` | SHA-256-Digest als Raw-Bytes (32 Byte) |
| `aes_ecb_hex:keyhex` | AES-256-ECB Encrypt eines 16-Byte-Blocks. Input/Output Hex; Key 64 Hex (= 32 Byte) |
| `hexxor:hexB` | XOR zweier gleichlanger Hex-Strings → Hex |
| `i64behex` | Integer (long long, dezimal) → 16-Hex Big-Endian (8 Byte) |
| `cent2eur` | Cent-Integer → `"X,YY"` (deutsches Komma, immer 2 Nachkommastellen, neg. mit `-`) |

**Beispiele:**

```
%h    = (%text sha256)              // 64-Hex Digest
%t8   = (%h left:16)                // erste 8 Bytes (16 Hex)
%b64  = (%t8 hex2b64)               // Base64
%xor  = (%a hexxor:(%b))            // XOR zweier Hex-Strings
%blk  = (%data aes_ecb_hex:(%key))  // AES-256-ECB Block-Encrypt
%be   = (%kstand i64behex)          // 0000000000000aad
%eur  = (%cents cent2eur)           // 1234 → "12,34"
```

**Komplett-Beispiel — RKSV-Umsatzzähler verschlüsseln:**

```
%seed     = (%kassen_id)(%beleg_nr)
%hash16h  = (%seed sha256 left:32)
%key_hex  = (%aes_key_b64 b642hex)
%enc8h    = (%hash16h aes_ecb_hex:(%key_hex) left:16)
%xor8h    = (%enc8h hexxor:(%kstand i64behex))
%uz_b64   = (%xor8h hex2b64)
```

### Pfad-Prozessoren

Funktionieren auf jeder Variable die einen Dateipfad enthält:

| Prozessor | Ergebnis für `work\test_7.cps` | Beschreibung |
|-----------|-------------------------------|--------------|
| `name` | `test_7` | Dateiname ohne Pfad und ohne Endung |
| `fix` | `test` | Wie `name`, aber auch Variante `_N` abgeschnitten |
| `base` | `test_7.cps` | Dateiname mit Endung, ohne Pfad |
| `root` | `C:\myc\work` | Voller absoluter Verzeichnispfad |
| `ext` | `.cps` | Nur die Endung (inkl. Punkt) |

```
> (%script name)    // test_7
> (%script fix)     // test
> (%script base)    // test_7.cps
> (%script root)    // C:\myc\work
> (%script ext)     // .cps
> (%0 fix)          // test  (auch auf %0 anwendbar)
```

### Spezial

| Prozessor | Beschreibung |
|-----------|--------------|
| `fifo` | FIFO-Pfad generieren (aus `%1`) |
| `lookup:datei` | Wert in Lookup-Tabelle suchen |

**e64/d64 Verschlüsselung:**

```
cps -e64 passwort [passpar]    // gibt verschlüsselten Wert aus
%secret (%cred_enc d64)         // dekodieren (passpar muss gesetzt sein)
```

---

## Bedingte Ausführung (IF/IFNOT)

### Syntax

```
if <bedingung> [then] <aktion> [else <else_aktion>] [undef <undef_aktion>]
ifnot <bedingung> [then] <aktion> [else <else_aktion>] [undef <undef_aktion>]
```

Variablen in Bedingungen mit `%` oder `(%...)`. `if`/`ifnot` sind case-insensitive.

### Bedingungen

| Bedingung | Beschreibung |
|-----------|--------------|
| `%var` | True wenn Variable existiert UND nicht leer UND nicht `0` |
| `%var = wert` / `==` | Gleichheit (case-insensitive) |
| `%var > wert` | Größer als |
| `%var < wert` | Kleiner als |
| `%var ~= wert` | Wort-Match (gleiche Wörter, beliebige Reihenfolge) |
| `"text" in %var` | Enthält (case-insensitive) |

### Aktionen

| Aktion | Beschreibung |
|--------|--------------|
| `:label` | Sprung zu Label |
| `goto :label` | Explizites goto |
| `%var wert` / `%var = wert` | Variablenzuweisung |
| `+N` | Relativer Sprung N Zeilen vorwärts (1–32) |
| `next` / `:` | Keine Aktion (noop) |

### Verhalten bei undefined

| Syntax | Variable nicht definiert |
|--------|--------------------------|
| `if %var :ok` | Springt NICHT (undefined = false) |
| `ifnot %var :err` | Springt (undefined = true) |
| `if %var :ok undef :missing` | Springt zu `:missing` |

### Beispiele

```
if %token :has_token

if (%http_code%) = 200 :success else :error

if (%result) :ok else :fail undef :missing

if (%rc) = 0 %status ok else %status fail

if "Connect" in (%erg) :ok

ifnot %token :token_err
```

---

## Sprungbefehle & Subroutinen

### Labels

```
:start
:error_handler
:ende
```

Labels dürfen nicht mit einer Ziffer beginnen. `goto`/`gosub` suchen zuerst vorwärts, dann vom Dateianfang.

### goto

```
goto :label
```


### gosub / return

Nur **eine** Verschachtelungsebene.

```
gosub :subroutine
// ...
:subroutine
// ...
return
```

| Befehl | Rückkehr zu |
|--------|-------------|
| `return` | Nach gosub-Zeile |
| `return 0` | Gosub-Zeile (nochmal ausführen) |
| `return -1` | Zeile vor gosub (Loop mit Variablen-Setting) |
| `return :label` | Zu Label springen statt zurückkehren |

```
%retry 1
gosub :process
goto :ende

:process
> Durchlauf (%retry)
if %fertig return
%retry = (%retry) + 1   // nicht direkt möglich, nutze externes Tool oder Flag
return -1

:ende
```

### exit

```
exit                        // Skript beenden, Exit-Code 0
exit 1                      // Skript beenden, Exit-Code 1
exit ku2abas %1 %2          // Aktuelles Skript beenden, ku2abas.cps mit %1 %2 starten
exit work\other             // Pfad möglich, Endung wird aus aktuellem Skript übernommen
exit other.cps arg1         // Explizite Endung möglich
```

Wenn der erste Parameter **kein** Exit-Code (Zahl) ist, wird er als neuer Skriptname interpretiert — das aktuelle Skript wird beendet und das neue gestartet (Chain). Die Script-Endung (`.cps`, `.cpx`, …) wird automatisch vom laufenden Skript übernommen, wenn keine Endung angegeben.

**Wichtig:** Bei Chain-Exit bleiben alle UserVariablen (MyVars) erhalten und stehen im neuen Skript zur Verfügung. So können Variablen in einem Vorskript vorbereitet und an das Folge-Skript übergeben werden.

---

## Konsolenausgabe

### Syntax

```
> Text ausgeben (mit Newline)
>> Text ohne Newline
```

### Variablen-Expansion

```
> Hallo (%name), Status: (%http_code%)
```

### Farbcodes

Farben werden in eckigen Klammern angegeben und bleiben aktiv bis `[#0]`:

```
> [cyan]Status: [green]OK[#0]
> [bold /darkblue white]Titel[#0]
> [red]Fehler[#0]
```

**Vordergrundfarben:**

| Code | Farbe | Code | Farbe |
|------|-------|------|-------|
| `[black]` | Schwarz | `[darkgray]` | Dunkelgrau |
| `[darkblue]` | Dunkelblau | `[blue]` | Blau |
| `[darkgreen]` | Dunkelgrün | `[green]` | Grün |
| `[darkcyan]` | Dunkelcyan | `[cyan]` | Cyan |
| `[darkred]` | Dunkelrot | `[red]` | Rot |
| `[darkmagenta]` | Dunkelmagenta | `[magenta]` | Magenta |
| `[darkyellow]` | Dunkelgelb | `[yellow]` | Gelb |
| `[gray]` | Grau | `[white]` | Weiß |

**Hintergrundfarbe:** `[/farbe]` — z.B. `[/darkred]`, `[/darkblue white]`

**Sonstige Tags:**

| Code | Funktion |
|------|----------|
| `[bold]` | Fett |
| `[#0]` | Reset — alle Attribute zurücksetzen |
| `[#1]`–`[#255]` | SCREENMODE: `BG*16 + FG` (ConsoleColor-Index 0–15) |
| `[#RRGGBB]` | RGB Vordergrundfarbe (24-Bit True Color) |
| `[/#RRGGBB]` | RGB Hintergrundfarbe |
| `[cls]` | Bildschirm löschen |
| `[pN]` | Cursor auf Spalte N setzen (kann rückwärts) |
| `[fN]` | Mit Leerzeichen bis Spalte N auffüllen (nur vorwärts) |
| `[k]` | Zeile ab Cursor löschen |

Kombinierbar: `[bold #FFD700 /#1A1A2E]`

**Escape `´` (ANSI 0xB4):**

| Sequenz | Bedeutung |
|---------|-----------|
| `´e` | ESC-Zeichen |
| `´[` | Literal `[` (kein Tag) |
| `´]` | Literal `]` |
| `´´` | Literal `´` |
| `´n` / `´r` / `´t` | Newline / CR / Tab |
| `´a` | Bell |

`[[` ist ebenfalls ein Literal `[`. Am Skript-Ende wird automatisch `[#0]` gesetzt.

---

## Dateischreiben (!>)

### Syntax

```
!> zieldatei
Zeile 1
Zeile 2
(%variable)

```

Ein leerer Block (Leerzeile) beendet den Schreibblock.

### Modi

| Befehl | Modus |
|--------|-------|
| `!>` | Überschreiben (truncate) |
| `!>>` | Anhängen (append) |

### Ziele

| Ziel | Beschreibung |
|------|--------------|
| `datei.txt` | In Datei schreiben |
| `%variablenname` | In Variable schreiben |
| `CLIP` | In Zwischenablage kopieren |
| `MBOX ...` | MessageBox anzeigen |
| `MAIL ...` | E-Mail senden |

### Datei löschen

```
!> dateiname del
!> dateiname delete
```

### Block-Steuerzeichen

| Zeichen | Bedeutung |
|---------|-----------|
| Leerzeile | Block-Ende |
| `:` (allein) | Leerzeile einfügen |
| `::` | Literal `:` ausgeben |
| `? bedingung` | Bedingte Zeile |
| `?? text` | Literal `?` in bedingter Zeile |
| `:label` | Label-Definition (wird übersprungen) |
| `:=label` | Sprung zu Label im Block |
| `goto label` | Sprung (ohne `:`) |

### Optionen (nach Zieldatei)

| Option | Beschreibung |
|--------|--------------|
| `trim` | Whitespace trimmen |
| `nolf` | Kein Zeilenumbruch (Zeilen mit Space verbinden) |
| `LN` | Linker Einzug N Zeichen |
| `RN` | Rechter Rand (Zeilenumbruch bei Spalte N) |
| `PADN` | Zeilen auf N Zeichen auffüllen |

### Beispiel

```
!> output.txt
Header
:
? (%debug) Debug-Info: (%info)
Zeile mit (%variablen)
:ende

```

---

## HTTP-Requests

### HTTP Block Mode

```
!> https://api.example.com/endpoint -t 30 -eh :http_error
-H "Authorization: Bearer (%token)"
-H "Content-Type: application/json"
{
  "name": "(%name)"
}

> Response: (%http_code%)
```

Block wird durch **Leerzeile** beendet. Auto-POST wenn Body vorhanden.

### URL-Erkennung

| Anfang | Block-Typ |
|--------|-----------|
| `http://` / `https://` | HTTP-Request |
| Dateipfad | Datei schreiben |

### Body-Erkennung

| Zeichen | Bedeutung |
|---------|-----------|
| `{` | JSON Body beginnt |
| `<` | XML/SOAP Body beginnt |
| `@` | Expliziter Body-Start |
| `:` (allein im Body) | Leerzeile einfügen |
| `::` | Literal `:` |

### Config-Optionen

| Option | Kurzform | Beschreibung |
|--------|----------|--------------|
| `--request METHOD` | `-X METHOD` | HTTP-Methode (GET/POST/PUT/DELETE) |
| `--header "H: V"` | `-H "H: V"` | HTTP-Header |
| `--data "..."` | `-d "..."` | Body-Daten (auch `-d @datei`) |
| `--data-urlencode "k=v"` | | URL-encoded Body |
| `--output datei` | `-o datei` | Response in Datei speichern |
| `--timeout N` | `-t N` | Timeout in Sekunden (Standard: 30) |
| `--insecure` | `-k` | SSL-Verifikation deaktivieren |
| `--verbose` | `-v` | Verbose-Ausgabe |
| `--location` | `-L` | Redirects folgen |
| `-r %var` | | Response in Variable speichern |

### Fehlerbehandlung

| Option | Verhalten |
|--------|-----------|
| `--onerror :label` / `-e :label` | Bei CURL-Fehler → Label |
| `-eh :label` | Bei CURL-Fehler oder HTTP non-2xx → Label |
| `-ehj :label` | Zusätzlich wenn kein JSON in Response |
| `-ehx :label` | Zusätzlich wenn kein XML/SOAP in Response |

Fehlende Labels erben das letzte angegebene Label:

```
!> https://api.example.com/data -t 10 -ehj :curl_err :http_err :json_err
```

### Beispiele

**GET Request:**
```
!> https://api.example.com/users/(%id) -t 15

> Status: (%http_code%)
```

**POST mit JSON:**
```
!> https://api.example.com/data -t 30 -eh :http_fehler
-H "Content-Type: application/json"
-H "Authorization: Bearer (%token)"
{
  "name": "(%name)",
  "value": (%value)
}

if (%http_code%) = 200 :success
```

**POST mit Form-Daten:**
```
!> https://api.example.com/token -t 15
--data-urlencode "grant_type=client_credentials"
--data-urlencode "client_id=(%client_id)"
--data-urlencode "client_secret=(%client_secret)"

```

**Beispiel Fehler-Handler:**
```
:http_fehler
> [/darkred white] HTTP-Fehler in Zeile (%line%) [#0]
> [red] URL: (%http_method%) (%http_url%)
> [red] Code: (%http_code%)  CURL: (%curlrc%)  Zeit: (%http_time%)
ifnot %http_error% +1
> [red] Fehler: (%http_error%)
> [gray] Body: (%http_response% left:500)
goto :ende
```

---

## JSON/XML-Parsing

### extract json

```
extract json %var=pfad                    // implizit aus %json
extract json %access_token %expires_in   // Shorthand: Varname = JSON-Key
extract json < %myvar %token=access_token // explizite Quelle: Variable
extract json < response.json %status=status // explizite Quelle: Datei
!<json %token=access_token %name=user.name  // Kurzform
```

**Pfad-Syntax:** `key`, `key.subkey`, `key[0]`, `key["name"]`, `a.b[0].c`

**Rückgabe:** string→direkt, number→als String, boolean→`1`/`0`, null→leer, object/array→leer

**Fehler:** `(%json_error%)` → `"Empty JSON"` / `"Invalid JSON"` / `"Path not found: ..."`

### extract xml

```
extract xml %rc=rc %name=name            // implizit aus %xml
extract xml %rc %name %adrz1            // Shorthand
extract xml < response.xml %rc          // explizite Quelle: Datei
!<xml %rc %name %adrz1                  // Kurzform
%xml = (%xml toutf8)                    // HTML-Entities dekodieren (typisch bei SOAP)
```

**Tag-Syntax:**

| Syntax | Extrahiert |
|--------|------------|
| `%var=tag` | Element-Text (`<tag>wert</tag>` → `wert`) |
| `%var=tag@attr` | Attribut-Wert (`<tag attr="wert">` → `wert`) |
| `%var=tag[a=v]` | Text mit Filter (`<tag a="v">wert</tag>` → `wert`) |
| `%var=tag[a=v]@b` | Attribut mit Filter |

**SOAP:** Namespace-Präfixe ignoriert, sucht automatisch in `<Body>`.

**Fehler:** `(%xml_error%)` → `"EMPTY_XML"` / `"PARSE_ERROR"` / `"NOT_FOUND"`

### Text-Extraktion Legacy (extract / !<)

Für unstrukturierte Texte per Muster-Suche. `^` = Platzhalter für Wert.

```
extract %http_response% %token='"access_token":"^"'
extract %http_response% %id='"id":^' %name='"name":"^"'
extract response.json %status='"status":"^"'
```

| Muster | Findet |
|--------|--------|
| `"key":"^"` | String-Wert |
| `"key":^` | Numerischer Wert |
| `"key":^,` | Wert bis Komma |

---

## Text-Ersetzung

### Syntax

```
!> zieldatei <r< quelle   suche ersetz
!> zieldatei <replace< quelle   suche ersetz
```

**Quellen:** `%http_response%`, `(%varname)` (expandiert als Dateiname), Dateiname

**Escape-Sequenzen:** `\r\n`, `\n`, `\r`, `\t`

### Beispiel

```
// JSON formatieren
!> formatted.json <r< %http_response%   },{ },{\r\n{

// Dateiinhalt ersetzen
!> output.txt <r< input.txt   alt neu
```

---

## Datei-Include

### Syntax

```
include dateiname [codepage]
incl dateiname [codepage]
```

### Codepages

| Parameter | Codepage | Verwendung |
|-----------|----------|------------|
| (Standard) | UTF-8 | Moderne Dateien |
| `CPOEM` | System-OEM | Lokal erstellte OEM-Dateien |
| `CPANSI` | System-ANSI | Lokal erstellte ANSI-Dateien |
| `CP850` | 850 | DOS Westeuropa (AT, DE) |
| `CP852` | 852 | DOS Mitteleuropa (PL, CZ) |
| `CP1252` | 1252 | Windows Westeuropa (AT, DE) |
| `CP1250` | 1250 | Windows Mitteleuropa (PL, CZ) |
| `CP###` | ### | Jede gültige Windows-Codepage |

**Hinweis:** `CPOEM`/`CPANSI` verwenden die Codepage des **lokalen Systems**. Für systemübergreifende Dateien explizite Codepage verwenden.

### Format der Include-Datei

```
// Kommentar
varname1 = wert1
varname2 : wert2
varname3   wert3

:eof  // Ende-Marker (optional)
```

### Fehlerbehandlung

```
include config.ini
if (%incl_error) = 1 :config_fehlt
> Geladen: (%incl_file)
```

### Beispiele

```
include config.ini
include (%1 fifo) CPOEM
include daten.go CP850
```

### Lookup-Dateien

Include-Dateien können Bedingungen und Labels enthalten:

```
// lookup.txt
? (%type) = A :typ_a
? (%type) = B :typ_b
default_code = 999
:eof

:typ_a
code = 100
:eof

:typ_b
code = 200
:eof
```

---

## Prozessausführung

### shell — Mit Windows-Shell öffnen

```
shell datei.pdf
shell https://example.com
shell notepad.exe datei.txt
```

### run — Prozess starten (nicht warten)

```
run notepad.exe
run cmd.exe /c script.bat
```

### runw — Prozess starten und warten

```
runw tool.exe parameter
if (%curlrc%) = 0 :erfolg
```

Exit-Code in `(%curlrc%)`.

### curl — curl.exe ausführen

```
curl https://example.com -o output.html
```

---

## Pause & Benutzereingabe

### Syntax

```
pause                     // ~20s Timeout, Punkt-Bounce-Animation
pause Weiter?             // Mit Prompt
pause 5                   // Max. 5s (ohne Animation)
pause 10 Weiter?          // 10s mit Prompt
pause 0                   // Ewig warten
```

Kurzform: `<` statt `pause`

### Ergebnis in `(%lastkey%)`

| Wert | Bedeutung |
|------|-----------|
| `ENTER` | Enter-Taste |
| `SPACE` | Leertaste |
| `ESC` | Escape-Taste |
| `TIMEOUT` | Timeout erreicht |
| `BATCH` | Batch-Modus aktiv |
| `a`, `b`, … | Gedrücktes Zeichen |
| `EXT:60` | Sondertaste (F2), `EXT:61` (F3), … |

### Verhalten während Punkt-Animation

| Taste | Verhalten |
|-------|-----------|
| **ESC** | Abbrechen, `(%lastkey%)` = `ESC` |
| **SPACE** (1×) | Countdown stoppt, wartet auf nächste Taste |
| **SPACE** (2×) | Countdown neu starten (20s reset) |
| **ENTER** | Beenden, `(%lastkey%)` = `ENTER` |
| **F3** | Aktuelle Log-Datei öffnen |
| **#** | HTTP-Log anzeigen |

### Beispiele

```
pause Weiter mit Enter...
if (%lastkey%) = ESC :abbruch

pause 0 Warte auf Eingabe:
if (%lastkey%) = j :ja
if (%lastkey%) = n :nein
```

---

## MessageBox

### Inline-Syntax

```
<< Text für MessageBox
<< $5 Text mit 5s Timeout
```

### Block-Syntax

```
!> MBOX [Titel] [Icon] [Buttons]
Nachrichtentext
über mehrere
Zeilen

```

### Icons

| Option | Icon |
|--------|------|
| `info` | Information |
| `warn` / `warning` | Warnung |
| `error` | Fehler |
| `question` | Frage |

### Buttons

| Option | Buttons |
|--------|---------|
| `ok` | OK |
| `okcancel` | OK / Abbrechen |
| `yesno` | Ja / Nein |
| `yesnocancel` | Ja / Nein / Abbrechen |

### Ergebnis in `(%mbox_result%)`

| Wert | Button |
|------|--------|
| `ok` | OK |
| `cancel` | Abbrechen |
| `yes` | Ja |
| `no` | Nein |
| `TIMEOUT` | Timeout |

### Beispiel

```
!> MBOX Warnung warn yesno
Möchten Sie wirklich fortfahren?

if (%mbox_result) = no :abbruch
```

---

## E-Mail-Versand

### Syntax

```
!> MAIL smtp://server[:port] [-F from] [-T to] [-U user:pass] [-A attachment]
From: Absender <absender@example.com>
To: Empfänger <empfaenger@example.com>
Subject: Betreff

Nachrichtentext
hier.

```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-F email` | Absender (oder aus `From:` Header) |
| `-T email` | Empfänger (oder aus `To:` Header) |
| `-U user:pass` | Authentifizierung |
| `-t N` | Timeout in Sekunden |
| `-A datei` | Attachment |
| `--ssl` | SSL/TLS verwenden |

---

## Clipboard

```
!> CLIP
Text für die
Zwischenablage

!>> CLIP
Weiterer Text anhängen

```

---

## Logging

### Aktivieren

```
setlog                    // Level 1, logs\script_timestamp.f2u
setlog 1                  // Level 1
setlog 2                  // Level 2 (verbose)
setlog on                 // Level 1
setlog 1 logfile.f2u      // Spezifische Datei
setlog (%1 fifo)          // FIFO-Pfad (.ok → .f2u, _OK. → _LOG.)
```

### Deaktivieren

```
setlog 0
setlog off
```

### Log-Level

| Level | Inhalt |
|-------|--------|
| 0 | Aus |
| 1 | Befehle, Variablen, IF-Ergebnisse |
| 2 | + HTTP-Details |

HTTP-Logging: Level 1/2 → Response max. 640 Byte + `...`; `-l` (cmdline) → vollständig.

### Append-Log (thread-sicher)

```
alog logfile.txt Nachricht mit (%variablen)
```

---

## Post-Mortem-Dump

Schreibt eine Diagnosedatei ohne das Skript zu beenden.

```
pmdump
pmdump Verbindung fehlgeschlagen
pmdump (%http_error%)
```

Ziel: `ERRLOG\scriptname_YYYY-MM-DD_HHMMSS.f2u`

Enthält: Timestamp, Skript-Info, Parameter `%1`–`%9`, System-Variablen, alle User-Variablen, HTTP-Response (gekürzt bei >2000 Zeichen), HTTP-Log vollständig.

---

## Include-Bibliothek (cpsincl.cps) {#include-bibliothek-cpsincl}

`cpsincl.cps` im **selben Verzeichnis wie das Skript** wird automatisch geladen. Jede EXE-Variante sucht ihre eigene Endung: `cpsincl.cps`, `cpsincl.cpx`, `cpsincl.cpy`.

**Mechanismus:** Bei `goto`/`gosub` zu einem Label das im Hauptskript nicht gefunden wird → Suche in `cpsincl.cps`. Hauptskript wird immer zuerst durchsucht.

```
goto :http_error         // Springt zu :http_error in cpsincl.cps
gosub :token_err         // return bringt zurück ins Hauptskript
```

**Ausführung:** Vollständiger Script-Loop — alle Befehle verfügbar. `(%lastcmdline%)` gibt die Zeile des aufrufenden Befehls im Hauptskript zurück.

| Befehl in cpsincl.cps | Verhalten |
|----------------------|-----------|
| `return` | Rückkehr zum Hauptskript (wenn kein aktiver gosub) |
| `exit [code]` | Programm beenden |
| `:eof` | Explizites Dateiende |
| EOF | Wie `return` |

**Beispiel cpsincl.cps:**

```
:http_error
> [/darkred white] HTTP-Fehler in Zeile (%lastcmdline%) [#0]
> [red] URL:  (%http_method%) (%http_url%)
> [red] Code: (%http_code%)  CURL: (%curlrc%)  Zeit: (%http_time%)
ifnot %http_error% +1
> [red] Fehler: (%http_error%)
> [gray] Body: (%http_response% left:500)
goto :ende_mit_err

:token_err
> [/white red] Fehler beim Token-Abruf!
> CURL RC: (%curlrc%) HTTP: (%http_code%)
goto :ende_mit_err

:ende_mit_err
pmdump
pause
exit 1

:eof
```

**Verwendung:**

```
!> https://api.example.com/data -t 10 -ehj :http_error
!< %id=id %name=name
> OK: (%http_code%)
```

---

## FIFO-Kommunikation (DataFlex)

### Konzept

DataFlex schreibt `.go`-Datei → CPS liest und verarbeitet → schreibt `.ok` → DataFlex liest Ergebnis.

### fifo-Prozessor

`(%1 fifo)` generiert Pfade aus Parameter `%1`:

| `%1` | Input-Pfad | Output-Pfad |
|------|------------|-------------|
| (leer) | `.\go\scriptname` | `.\ok\scriptname` (kein Extension) |
| `*` | `%HOME%\scriptname.go` | `%HOME%\scriptname.ok` |
| `*9AW` | `%HOME%\scriptname_GO.9AW` | `%HOME%\scriptname_OK.9AW` |
| `xml` | `.\go\scriptname.xml` | `.\ok\scriptname.xml` |

**Versions-Suffix:** `uidck_3.cps` → FIFO-Basis `uidck` (wenn nach letztem `_` nur Ziffern stehen).

| Skriptname | FIFO-Basisname |
|------------|----------------|
| `uidck_3.cps` | `uidck` |
| `ku2_abas_2.cps` | `ku2_abas` |
| `test_SQL.cps` | `test_SQL` |

**Window-Handle:** `-w:handle` → `g_caller_window`

### Beispiel

```
include (%1 fifo)

// Verarbeitung...
!> https://api.example.com/data -t 10 -ehj :http_error
!< %status=status %result=result

// Ergebnis schreiben
!> (%1 fifo)
status = (%status)
result = (%result)

```

---

## Debug-Modus

### Aktivierung

- Kommandozeile: `-d` oder `-debug`
- Scroll-Lock-Taste während der Ausführung

Im Debug-Modus ist F2 sofort freigeschaltet (ohne `##`-Menü).

### Debug während Pause (`#`-Taste)

| Taste | Funktion |
|-------|----------|
| `?` | Alle Variablen anzeigen |
| `v` | Verbose umschalten |
| `l` | Logging umschalten |
| `#` | HTTP-Log anzeigen (wenn vorhanden) |
| Enter/Space | Weiter |
| `q` / ESC | Skript abbrechen |

---

## Referenz: Alle Befehle

### Variablen & Ausgabe

| Befehl | Beschreibung |
|--------|--------------|
| `%var wert` / `%var = wert` | Variable setzen |
| `> text` | Konsolenausgabe (mit Newline) |
| `>> text` | Ausgabe ohne Newline |

### Kontrollfluss

| Befehl | Beschreibung |
|--------|--------------|
| `if`/`ifnot` | Bedingte Ausführung |
| `goto :label` | Sprung zu Label |
| `:label` | Label-Definition |
| `gosub :label` | Subroutine aufrufen |
| `return [0\|-1\|:label]` | Subroutine beenden |
| `exit [code]` | Skript beenden |
| `exit skript [p1...]` | Chain: neues Skript starten (UserVars bleiben) |

### Dateien & HTTP

| Befehl | Beschreibung |
|--------|--------------|
| `!> ziel` | Block schreiben (Datei/Variable/HTTP) |
| `!>> ziel` | Block anhängen |
| `!> ziel <r< quelle s e` | Text ersetzen |
| `extract json ...` / `!<json ...` | JSON extrahieren |
| `extract xml ...` / `!<xml ...` | XML extrahieren |
| `extract quelle %var=muster` | Legacy Text-Extraktion |
| `include datei [cp]` | Datei inkludieren |

### Prozesse

| Befehl | Beschreibung |
|--------|--------------|
| `shell ziel` | Mit Shell öffnen |
| `run cmd` | Prozess starten (nicht warten) |
| `runw cmd` | Prozess starten und warten |
| `curl args` | curl.exe ausführen |

### Interaktion

| Befehl | Beschreibung |
|--------|--------------|
| `pause [N] [text]` | Pause mit Eingabe |
| `<< text` | MessageBox (inline) |
| `!> MBOX ...` | MessageBox (Block) |
| `!> MAIL ...` | E-Mail senden |
| `!> CLIP` | In Clipboard schreiben |
| `!>> CLIP` | An Clipboard anhängen |

### System

| Befehl | Beschreibung |
|--------|--------------|
| `setlog [level] [file]` | Logging steuern |
| `alog datei text` | Zeile an Log-Datei anhängen |
| `pmdump [text]` | Post-Mortem-Dump schreiben |

---

## Tipps & Best Practices

### Fehlerbehandlung mit cpsincl.cps

```
!> https://api.example.com/data -t 30 -ehj :http_error
!< %id=id %name=name
> (%id): (%name)
```

### Credentials verschlüsseln

```
// Einmalig: cps -e64 passwort [key]  → gibt verschlüsselten Wert aus
%cred_enc dGVzdA==...
%passpar geheim
%cred (%cred_enc d64)
```

### SOAP/XML verarbeiten

```
!> https://ws.example.com/service -t 30 -ehx :http_error
-H "Content-Type: text/xml; charset=utf-8"
-H "SOAPAction: GetData"
<soapenv:Envelope ...>
  <soapenv:Body><GetData><id>(%id)</id></GetData></soapenv:Body>
</soapenv:Envelope>

%xml = (%xml toutf8)
extract xml %rc=rc %name=name
```

### FIFO mit Varianten

```
// DataFlex ruft auf: cps -b -v:2 ku2abas *9AW
// → lädt ku2abas_2.cps, FIFO-Basis bleibt ku2abas

include (%1 fifo) CPOEM
// Verarbeitung...
!> (%1 fifo)
RC = 0
ERG = (%ergebnis)

```

### Logging für Debugging

```
setlog 2

!> https://api.example.com/data -t 10
// F3 während pause öffnet Log-Datei
pause Fehler?
```

---

*CPS Script Interpreter — Dokumentation v28.Feb.26*
