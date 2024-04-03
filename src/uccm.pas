(******************************************************************************)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* This file is part of CCM                                                   *)
(*                                                                            *)
(*  See the file license.md, located under:                                   *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(******************************************************************************)
Unit uccm;

{$MODE objfpc}{$H+}

Interface

{$I ccm.inc}

Uses
  Classes, SysUtils, sqlite3conn, Laz2_DOM, sqldb, forms, Graphics, StdCtrls, Grids, ulanguage, umathsolver, IpHtml;

{$I updater_settings.inc}

Const
  UTF8BOM: String = chr($00EF) + chr($00BB) + chr($00BF);

  Invalid_Coord = -1.0; // TODO: Das Soll mal Global im Programm die Konstante für ungültige Koordinate werden ;)

  (*
   * Diverse Konstanten
   * Alle Hier gelisteten Konstanten werden nicht übersetzt, da sie in
   * Konfigurationsdateien oder html Protokollen gesendet werden.
   *)

  // Cache Typen
  Traditional_Cache = 'Traditional Cache';
  Multi_cache = 'Multi-cache';
  Unknown_Cache = 'Unknown Cache';
  Letterbox_Hybrid = 'Letterbox Hybrid';
  Wherigo_Cache = 'Wherigo Cache';
  Earthcache = 'Earthcache';
  Virtual_Cache = 'Virtual Cache';
  Giga_Event_Cache = 'Giga-Event Cache';
  Mega_Event_Cache = 'Mega-Event Cache';
  Community_Celebration_Event = 'Community Celebration Event';
  Event_Cache = 'Event Cache';
  Cache_In_Trash_Out_Event = 'Cache In Trash Out Event';
  Webcam_Cache = 'Webcam Cache';
  Project_APE_Cache = 'Project APE Cache';
  Geocache_Lab_Cache = 'Geocache|Lab Cache';
  Lab_Cache = 'Lab Cache'; // Caches die von Lab2GPX als .zip Archiv kommen ;)
  LocationLess_Cache = 'Locationless (Reverse) Cache';

  //Cache Size
  csUnknown = 'Unknown'; // -- Das wird beim Export gemappt zu csNotChosen
  csMicro = 'Micro';
  csSmall = 'Small';
  csRegular = 'Regular';
  csLarge = 'Large';
  csVirtual = 'Virtual';
  csNotChosen = 'Not chosen';
  csOther = 'Other';

  // Wegpunkt Typ
  wpt_t_Final = 'Final';

  // CheckForUpdate URL
  URL_CheckForUpdate = 'https://corpsman.de/download/ccm.version';
  URL_UploadFieldNotes = 'https://www.geocaching.com/my/uploadfieldnotes.aspx';
  URL_OpenTBListing = 'https://www.geocaching.com/track/details.aspx?tracker='; // hier muss noch der TB-Code angehängt werden.
  URL_OpenCacheListing = 'https://coord.info/'; // Dem wird noch der GC-Code nachgestellt

  CreateTableCachesCMD = // Das ist ein Formatstring, dem der Tabellenname übergeben werden muss (typisch "caches")
  'create table %s(' + LineEnding +
    // Allgemein
  'LAT REAL,' + LineEnding +
    'LON REAL,' + LineEnding +
    'COR_LAT REAL,' + LineEnding + // -- Vom benutzer eingegebene neue Koordinaten
  'COR_LON REAL,' + LineEnding + // -- Vom benutzer eingegebene neue Koordinaten
  'TIME TEXT,' + LineEnding +
    'NAME TEXT PRIMARY KEY,' + LineEnding + // GC-Code
  'DESC TEXT,' + LineEnding +
    'URL TEXT,' + LineEnding +
    'URL_NAME TEXT,' + LineEnding +
    'SYM TEXT,' + LineEnding +
    'TYPE TEXT,' + LineEnding +
    'NOTE TEXT,' + LineEnding + // -- Vom benutzer eingegebene Notes
  'Customer_Flag INTEGER,' + LineEnding + // -- Frei durch den Benutzer verwendbares flag
  'Lite Integer,' + LineEnding + // Angabe ob es sich um einen Lite Cache handelt oder nicht.
  'Fav Integer,' + LineEnding + // Anzahl der Fav Punkte die die Dose hat
  // Tag Groundspeack:cache
  'G_ID INTEGER,' + LineEnding +
    'G_AVAILABLE INTEGER,' + LineEnding +
    'G_ARCHIVED INTEGER,' + LineEnding +
    'G_NEED_ARCHIVED INTEGER,' + LineEnding + // Wird via Import Directory gesteuert um raus zu kriegen welche Caches nicht Aktualisiert wurden.
  'G_FOUND INTEGER,' + LineEnding + // 0 = not Found, 1 = Found (geht aber nur bei vergebenem Usernamen)
  'G_XMLNS TEXT,' + LineEnding +
    'G_NAME TEXT,' + LineEnding + // Name der Anzeige
  'G_PLACED_BY TEXT,' + LineEnding +
    'G_OWNER_ID INTEGER,' + LineEnding +
    'G_OWNER TEXT,' + LineEnding +
    'G_TYPE TEXT,' + LineEnding +
    'G_CONTAINER TEXT, ' + LineEnding +
    'G_DIFFICULTY REAL, ' + LineEnding +
    'G_TERRAIN REAL,' + LineEnding +
    'G_COUNTRY TEXT,' + LineEnding +
    'G_STATE TEXT,' + LineEnding +
    'G_SHORT_DESCRIPTION TEXT,' + LineEnding +
    'G_SHORT_DESCRIPTION_HTML INTEGER,' + LineEnding +
    'G_LONG_DESCRIPTION TEXT,' + LineEnding +
    'G_LONG_DESCRIPTION_HTML INTEGER,' + LineEnding +
    'G_ENCODED_HINTS TEXT' + LineEnding +
    ');';

  (*
   * Historie : 0.01 = Initialversion
   *            0.02 = Option Export .ggz mit Dateinamen der DB
   *            0.03 = Anzeigen via "Checked" dass im Edit Field Notes Dialog die Buttons gedrückt wurden
   *            0.04 = Neuer Lade Datenbank Dialog
   *            0.05 = Warnung, wenn Caches die nicht in der DB sind als geloggt markiert werden sollen
   *                   Speichern POI ebenfalls unter Datenbanknamen
   *                   Bugfix Create Dir in Add Spoiler Image to Cache
   *                   Selecting via Space im Field note Editor erlauben
   *            0.06 = User Notes als 1. Log Exportieren und nicht vor der Beschreibung.
   *            0.07 = User Notes vor Hint und nicht vor dem 1. Log
   *            0.08 = Waypoint Graphiken nach Klasse
   *            0.09 = Graphiken für Wherigo's
   *                   Workaround für Sortieren Bug
   *            0.10 = Bugfix, Version 0.09 hatte beim Importieren alle Caches auf Modifizierte Koordinaten gesetzt (irreparabel)
   *            0.11 = Speedup beim Anzeigen der Query im Stringgrid
   *                   Erstellen Export Query on Default
   *            0.12 = OpenGL gesteuerte Map Vorschau
   *                   UserPoints auf Karte
   *                   Bugfix, Suche nach Distanz hatte seit 0.11 Blödsinn ergeben
   *            0.13 = Button Einfügen Automatischer Lognummern
   *            0.14 = Anzeigen wenn ein Cache doppelt vom GPS importiert wurde
   *            0.15 = Anzeigen des Cache Typs beim Fieldnote Import
   *                   Bugfix Export As Pocket Query ohne Wegpunktliste
   *            0.16 = Bugfix, wenn beim Löschen der Temp Dateien der .ggz Datei was schief ging, konnte danach nie wieder eine .ggz Datei erstellt werden
   *            0.17 = Automatisches Umschalten der Auswahl bei der Modifizierung von Cache Koordinaten
   *            0.18 = Bugfixes im Pocket Query Export
   *                   Freischalten Proxy Support fürs Kartendaten Laden
   *            0.19 = Bilder für WebcamCache und Virtualcache eingefügt
   *            0.20 = Fix Renderfehler beim Anzeigen der 161m Radien (falsches Offset)
   *            0.21 = Fix AusgabeZeit für Pocketquery export (für GSAK)
   *            0.22 = Anzeigen der Found / Archived .. States auch auf der Preview Map
   *            0.23 = Beim Export in eine Andere DB wurde die URL gelöscht
   *                   Alphabetisches Sortieren der Datenbank namen in den Dialogen
   *            0.24 = Anzeigen der Wegpunkte eines Caches auf der Preview Map
   *                   Wegpunkteditor für einen Cache
   *                   Bugfix Caches mit DNF Log, wurden beim Importieren als zu Archivieren Markiert.
   *            0.25 = Hoffentlich endlich Bugfix Größenanpassung Mainform Stringgrid
   *            0.26 = Anzeigen der D/T-Wertung im Main Grid
   *            0.27 = Fix Parsing Error on Parsing a GSAK Exported Pocketquery
   *            0.28 = Fix Händisches Sortieren bei GetDBList
   *            0.29 = Skript Editor
   *                   DontImportFoundCaches und DeleteImportedFiles in die Skripte rein gezogen
   *                   About Text ein wenig aufgehübscht
   *            0.30 = Fix Crash, wenn Koordinaten Modifiziert werden (Folgefehler aus 0.29), Code aufgeräumt
   *            0.31 = Unterstützen Format "N4848000E00922000" bei Modify Coordinates
   *            0.32 = ccm.inc eingeführt -> FormShowModal
   *            0.33 = Anpassen Export as pocket query für GSAK
   *            0.34 = Mehr default Queries (werden nur erstellt, wenn beim Start ccm.ini nicht existiert)
   *                   Default Tool "Openstreetmap" (wird nur erstellt, wenn beim Start ccm.ini nicht existiert)
   *                   Filter Editor überarbeitet
   *                   Erster Location Editor
   *                   Options erweitert
   *                   Tool Editor
   *            0.35 = Verbesserte Detailansicht der Caches + Attribute
   *                   Bugfix Auswertung der Filter
   *            0.36 = Buttons "EditNote", "Add Spoiler" für Cache Details eingefügt
   *                   Logs anzeigen
   *            0.37 = Rausschmeisen der Option "UseDBNameOnGPSExport"
   *            0.38 = Fehlende Editoren für Files / Pfade integriert
   *                   Open Cache Detail on Doppelclick in Map preview
   *                   hint on hover bei Map preview
   *            0.39 = Anzeigen GC-Code im Hint
   *                   Open Cache in Browser in Detailview
   *            0.40 = OpenCache in Browser im Field-Note Editor auch für unbekannte Dosen
   *                   Doppelklick Feature im Field-Note Editor => View Details
   *                   "Found it" -> "Attended" bei Event Caches
   *                   Erste Unterstützung für Lab-Caches
   *            0.41 = Volle Unterstützung für Lab-Caches
   *            0.42 = Bugfix Copy/Move Cache To DB -> Danach war die Geladene DB kaputt
   *            0.43 = Overwrite Location war nicht implementiert
   *            0.44 = Editieren des Status der Dose inplace im Field Note Editor
   *            0.45 = Editieren des Status der Dose via Contextmenu, da sonst selektionen nicht mehr funktionieren
   *            0.46 = Bugfix, image "here.bmp" wurde nicht geladen
   *            0.47 = Anzeigen Schnittmenge zweier Datenbanken
   *            0.48 = Online Loggen
   *                   TB-Editor
   *            0.49 = Überprüfen der Log Zeitstempel beim Import
   *                   Editieren des Logdatums in Field-notes
   *            0.50 = Set State -> Write Note
   *                   Anchors im Field Note Dialog Korrigiert.
   *            0.51 = Umstellen aller Karte Lade URL's auf Google
   *            0.52 = Anzeigen eines Fortschritts bei Copy / Move Caches to other DB
   *            0.53 = Korrektur Rechenfehler beim Umgang mit Negativen Koordinaten
   *                   "Found it" -> "Webcam Photo taken" bei Webcam Caches
   *            0.54 = Entgültiges Umstellen auf [N/S] bzw. [E/W] support.
   *            0.55 = Anzeige Fortschritt Beim Löschen von Caches
   *            0.56 = Open Cache in Browser im Map Preview
   *            0.57 = POI-Export nun auch für Windows
   *            0.58 = Passwort in Map-Preview wurde nur bei neustart übernommen, nicht bei Änderung
   *            0.59 = Abfangen AV, wenn nicht existierende Exe ausgeführt werden soll
   *                   Anlegen des POI-Verzeichnisses, falls dieses nicht existiert.
   *            0.60 = Bessere FieldNoteExport heuristik, die erkennt und handelt, wenn der FieldNote Import auf der HP schiefgehen würde (prüfung auf gültige Einträge)
   *            0.61 = Akzeptieren von Attributen ohne namen (für opencaching.com)
   *            0.62 = Umstellen aller Zeitanzeigen auf PrettyTime
   *                   Importieren einer ungeprüften gpx File in eine neue Datenbank
   *            0.63 = Export as GSAP gpx
   *                   SQL-Admin Tool
   *                   Add location aus der Kartenansicht heraus
   *            0.64 = Anzeige der Cache Koordinaten in der Cache Detailübersicht.
   *                   Berücksichtigen ob GSAK Koordinaten Modifiziert hat oder nicht (beim Import wie Export)
   *                   CCM-Hint GSAK-Kompatibel in den gpx files speichern
   *            0.65 = neue Script Engine
   *            0.66 = Fertigstellen Script Engine (zum Teil aber noch ungetestet)
   *                   Menüstruktur im MainMenu umgestellt / aufgeräumt
   *            0.67 = Automatisches Umrechnen der Angezeigten Koordinaten beim Klick auf diese (in der Cache Preview)
   *            0.68 = Flag für mehr als 2GB Speicher auf Windows
   *                   81-iger Matrix nach Icons Sortierbar
   *            0.69 = 81-iger Matrix Icons um Cito, Virtual, Event und Webcam erweitert.
   *            0.70 = Doppelklick Feature in 81-iger Matrix
   *                   Custom Quick Filter (nach dt und nach Type)
   *            0.71 = Custom Filter nach Attributen
   *                   Button zum Custom Filter als Filter speichern
   *                   Anzeige der Attribute in der 81er Matrix
   *            0.72 = Bugfixes für Windows (anzeige der Comboboxen)
   *                   Bugfix: Die Darstellung auf der Karte ist sehr stark Rausgezoomt falsch (aber nur in y-Richtung)
   *            0.73 = Bugfix CustomQuery mit Attributen wurde filter falsch generiert.
   *                   Export caches als .csv
   *                   Bugfix Anzeige Distanz in Localer Zahlendarstellung.
   *                   Customer flag - ein Flag das der Benutzer frei setzen / löschen kann
   *                   Code completion für Filter Editor und SQL Admin Tool
   *            0.74 = Ausbauen des Rendertimers in Mappreview CPU-Zeit schonen ;)
   *            0.75 = Bugfix, beim Kopieren / verschieben in eine andere DB wurde diese nicht auf customer Flag Korrigiert.
   *            0.76 = Erkennen wenn Logeinträge > 4000 Zeichen.
   *            0.77 = NeverUseHTMLRenderer in Optionen verfügbar.
   *                   Workdir in Optionen editierbar
   *                   - löschen Option "ClearExportFolderBevoreExport"
   *            0.78 = TB-Editor fertiggestellt
   *                   Fehlende "del's" im scripteditor eingefügt.
   *            0.79 = Cache-Preview Code aufgeräumt
   *            0.80 = Hin und wieder Renderte er die Karte nicht (fehlendes invalidate)
   *            0.81 = deutlicher Speedup der Attributberechnung der 81iger Matrix
   *            0.82 = Test Connection Button in den Optionen
   *            0.83 = Wegpunktprojektion von Userpoints in Map Vorschau
   *                   Korrektur Anzeige 161m Radius war um Faktor 2 daneben.
   *            0.84 = Fix Attribute 67 und 63 war graphik vertauscht.
   *                   Sortierung der DB's bei Load / Move / Copy war CaseSensitiv
   *            0.85 = Anchorbugfix TB-Editor
   *            0.86 = Optionales Auswählen des DB-Namens bei Create DB from GPX
   *                   Delete Database
   *                   Download Pocket Queries
   *                   Loggen von Fav's
   *            0.87 = fehlendes Filter Refresh beim Import von Skripten
   *            0.88 = Anzeigen ob 32 oder 64 Bit Application
   *                   Anpassen an neue LoginURL
   *                   FollowLink umgestellt auf header Auswertung
   *            0.89 = Fix Loggen TB's
   *            0.90 = TB-Logeditor
   *            0.91 = TB-Logeditor Anzeige, wann der TB gefunden wurde (noch nicht perfekt)
   *            0.92 = Anzeigen führender 0en bei Koordinaten
   *            0.93 = Bugfix anzeige Logdateum schon gefundener TB's
   *            0.94 = OpenTB in Browser submenü
   *            0.95 = Fehlende Option "Warn if imported caches are not from today"
   *            0.96 = Fix Login wurde von Groundspeak geändert.
   *            0.97 = Erste Schritte für automatisches Prüfen auf notwendigkeit Update
   *                   Set Discoverdate for TB's
   *                   Delete selected TB's
   *
   * Ab hier wurden nicht mehr alle Versionen auf die Homepage hochgeladen nur noch die Versionen welche mit HP release geflaggt wurden.
   *
   * HP release 0.98 = Bugfix Download Engine (links wurden nicht korrekt verfolgt)
   *            0.99 = Fix Datumsformat für TB Logdatum
   *                   Ignorieren wenn die Eigene Version höher ist als die Online Verfügbare
   * HP release 1.00 = Fix Datumsanzeige Aktuelles Datum für TB Logdatum
   *            1.01 = Löschen des Edits nach der Eingabe von TB's
   *                   Return taste Berücksichtigen bei Eingabe TB's
   *            1.02 = Anzeigen fehler, bei leeren Logtexten
   * HP release 1.03 = neue popupmenüstruktur (aufräumen)
   *                   OpenCache in Browser für mehrere
   *                   Loggen von caches aus der Auswahl heraus
   *                   GSAK/CGEO .gpx Dateien können nun importiert werden ohne dass extra ein .zip erstellt werden muss
   *            1.04 = differenzieren bei TB's zwischen not existing und not activeted
   *                   Fix AV bei Suche nach DB löschen
   *            1.05 = Nachtragen Import Folder in File Folder Dialog
   *            1.06 = Umstellen MainMenu / PopupMenü
   *                   Berücksichtigen Abbruch bei Move Datasets
   * HP release 1.07 = Korrektur fehlerhaft angezeigter caption in Form7
   *                   Show Hint, Show Logs nun übers Contextmenü in Form1 erreichbar
   *                   Optional kann auf dem GPS via POI ein ! angezeigt werden, wenn die Koordinate des Caches Modifiziert wurde.
   * HP release 1.08 = Unterstützung Mehrsprachigkeit (De / En)
   *                   Optionales speichern Breite / Höhe Form1 (damit in der DE version man die Breite anpassen kann und die es auch bleibt *g* )
   *                   Umstellen auf GCToolWrapper
   *                   Workaround für: Sortieren Nach Name, Sortieren nach einer Anderen Spalte, Sortieren nach Name => Die Namen sind jedes 2. Mal nicht korrekt sortiert.
   *                   Copy Koord to Clipboard
   *                   Wegpunkt Projektion nun auch aus dem Kontextmenü
   *                   Manuelles nachladen der Listings
   *                   Fix Bug Import bereits gefundener Dosen die schon in der DB sind.
   * HP release 1.09 = Automatisches Nachladen von Field-Note Dosen, die nicht in der Datenbank sind
   *                   Automatisch Write Note bei Dosen, welche bereits in der DB als gefunden markiert wurden
   *                   Angleichen der Variablennamen an die in der Datenbank (bis auf type - type_)
   *                   ccm hat nun ein Icon
   *            1.10 = Versuch die Fortschrittsanzeige (form4) unter Linux verschiebbar zu machen..
   *                   Auflösen der $**$ Verzeichnisse bei der Statusanzeige
   *                   Downloads werden nur noch als eingeloggter User gemacht -> weniger Fehlermeldungen mehr Informationen (z.B. beim Listing nachladen)
   *                   Fix SpoilerDL Engine (wenn ein Listing mehrere Spoiler hatte wurde nur der erste geladen)
   *                   Form1 mindesbreite
   *            1.11 = Unterstützen einer Abfrage nach Mindestabstand einer Dose von Home (negative Distanz)
   *                   Sperren des Formulars, welches Form4 aufruft
   *                   Fix Bug das nicht alle Dateien im Importverzeichnis gelöscht wurden.
   *            1.12 = Besseres Fehlerhandling beim Loggen / löschen der geocache_visits.txt
   *            1.13 = Edit Usernote aus Field Note Editor heraus
   *            1.14 = Default Export Query nun + Challenges
   * HP release 1.15 = Nur eine Instanz von CCM auf einmal zulassen (verhindert Datenbank fehler)
   *                   Check ob ccm auf dem Sichtbaren Screen ist.
   *            1.16 = Log TB's auch aus dem Fieldnote Editor heraus.
   *            1.17 = Fix Gui Blockade unter Linux, wenn html errorcode 500 beim Loggen
   *            1.18 = Robuster Machen der Follow_Links Routinen
   *            1.19 = Fix Downloadbug für Dateinamen, welche auf dem Betriebsystem nicht erlaubt sind
   *                   Log Caches by GC-Code
   * HP release 1.20 = Fix Eingabe bei Cache Wegpunkten
   *                   Heuristik für Umwandlung von Koordinaten Verbessert
   *            1.21 = Heuristik für Umwandlung von Koordinaten noch mal Verbessert
   *                   Fehlende Sprachtexte eingefügt
   *            1.22 = Fix Icon anzeige für Caches war case Sensitiv C:Geo hatte andere cases
   *                   Modify Coords aus dem field note Editor heraus
   *            1.23 = Anzeige Durchschnitts D / T in 81-Matrix
   *                   Jasmer Matrix
   *                   Export CSV nun mit Hint, UserNote und Hidden Date in UTF8
   *            1.24 = Map Hints werden nun im OpenGL Fenster gerendert -> Schneller
   *            1.25 = Neue Möglichkeit das Tool Menü zu strukturieren
   *                   Erste Tastaturkommandos eingeführt
   *            1.26 = Anzeigen wenn Customer Flag gesetzt ist.
   *                   Besserer Umgang mit Dosen die aus der Datenbank gelöscht wurden.
   *                   Sinnvolleres Show on Map, wenn keine oder nur eine Dose gewählt wurde
   *                   Customer Flags nun auch aus der Map Preview Editierbar
   * HP release 1.27 = Download by GC-Code
   *                   Import und Export TB-Wulf Compatible TB-Listen
   *                   Anzeige Fortschritt beim Import von TB's
   *            1.28 = Reset der Main Stringgrid Captions wenn die Datensätze Aktualisiert werden.
   *                   default Cache Vorschau Dialog breiter gemacht
   *                   Anzeigen Attribut Hints in 81-Matrix, Custom Query Dialog
   * HP release 1.29 = Fix Bug in Follow Links (entstanden bei ccm version 1.20)
   *            1.30 = bessere Online Hilfe SQL Admin und Filter Editor
   *                   Anzeigen Fortschritt beim TB's discovern
   *                   Fix Sortierbug in Quicksort
   *            1.31 = Einführen Terrainkarte in Map Preview
   *            1.32 = Bessere Fehlerbahandlung beim Laden kaputter Listings
   *            1.33 = Optionales anfügen von ccm Hinweisen in den Logtexten
   *            1.34 = Initialversion Wizard (Select Database, Select Groundspeak Daten)
   *                   Verbessertes Verhalten Modaler Fenster unter Linux
   * HP release 1.35 = Cachebeschreibung beim Loggen wurde falsch dargestellt
   *                   OpenCache In Browser, hatte im TB Editor gefehlt
   *                   Warnen wenn versucht wird via Write Notes zu loggen
   *                   Online Logging, nur ausgewählte loggen
   *                   Fertig stellen Wizard
   *            1.36 = Export CSV Koords als DEG und DEC
   *            1.37 = Scrollwheel für Jasmer Matrix
   *                   Deutlicher Speedup Move Selection to other Database
   *                   Deutlicher Speedup Copy Selection to other Database
   *                   Fix Bug beim CSV Export von GC-Titeln mit ,
   *                   Fix Bug Copy / Move Selection to ging nicht, wenn in der Zieldatenbank der cache als gefunden markiert war.
   *            1.38 = Form4 besseres BrintToFront => Fix Bug das Info Anzeige nach hinten verschwindet.
   * HP release 1.39 = Fix Suchfeld mit Präfix Leerzeichen findet nichts
   *                   Fix anzeige Datum beim CSV-Export
   *                   Speichern aller Trackables die über den CCM discovert werden (zur späteren Auswertung)
   *                   Testweises Aktivieren das der CCM sich immer als "Deutscher" einloggt.
   *                   Update ER_Diagram Graphik und dazugehörige .xls Datei
   *                   Add found number hat bei Webcam photo nicht funktioniert..
   *            1.40 = Mark Caches as Found in wurde auch bei ungefundenen Caches durchgeführt
   *            1.41 = Unsinnigen Eintrag "save Database" gelöscht
   *                   kleinere Schönheitskorrekturen
   *            1.42 = Unterstützen Gesperrter TB'S
   *            1.43 = Support Giga-Event Cache
   *            1.44 = Export as c:geo zip
   *                   Fix Enabled Bug beim Importieren von Caches
   * HP release 1.45 = Support für händisch erstellte Lab Caches
   *            1.46 = Unterscheiden ob ein TB-Code oder ein Discover-Code eingegeben wurde
   *                   TB-Select Dialog
   *                   Trackables Database nun auch im SQL Admin Tool verfügbar.
   *                   Menüstruktur Edit angepasst
   *                   Bessere Fortschrittsanzeige unter Windows
   *            1.47 = Fix Bug, when used Comments in SQL-Admin Tool transactions, the transaction was scipped.
   *                   Wenn ein TB mittels TB-Code Gesucht wurde und der schon drin war, wurde der Falsch doppelt gespeichert
   *            1.48 = Fix OnKeyDown Bug map Preview [Windows only]
   *            1.49 = Loggen durch direktes aufrufen der geocache_visits.txt
   *                   Warnen, wenn unversuchte Caches geloggt werden.
   * HP release 1.50 = Heuristik zum Erkennen von TB-Codes bei der Eingabe verbessert.
   *                   Support für Project APE-Caches
   *            1.51 = Wenn die Anwendung wieder hergestellt wird, und Form4 Visible ist => BringToFront
   *            1.52 = Erkennen, wenn ein bereits geloggter Cache geloggt werden soll.
   *                   Umbauen der Fortschrittsanzeige beim Online Loggen (bessere Fehlertoleranz)
   *            1.53 = Löschen Toten Code zur alten Script implementierung
   *            1.54 = Anzeige Hinweis zum TB-Editor
   *            1.55 = Anpassen set log date auf stringgrid selection und nicht checked
   *            1.56 = Export csv "Parking Area"
   *                   Fix Anchor Bug im Wegpunkteditor
   *                   Zoom in Mapview mit + - pgup pgdown
   *            1.57 = Need Maintenance wieder reaktiviert im Log Editor
   *            1.58 = Umstellen Online Logging auf Geocache/API
   *            1.59 = Fix Bug, wenn Exakt bei Sekunde 0 einer Minute ein Log gemacht wurde, dann wurde die Zeit nicht Korrekt umgerechnet.
   *            1.60 = Anzeige verfügbare Favs in Online Log Dialog
   *                   Umstellen Logtype von String auf Enum
   *            1.61 = Needs Maintenance nun mit Auswalmöglichkeit
   *            1.62 = Center Map at
   *                   Unterstützen von mehr .gpx variationen (unterschiedliche GSAK exports)
   *                   Heuristik zum erkennen des File Contents beim Import
   *            1.63 = Erste implementierung des "Online Mode"
   *                   Spalte "Light" in Datenbank mit aufgenommen
   *                   Route Record Modus Aktiviert
   *            1.64 = Fix Bug in Export Funktion (unkonw Size)
   *                   Gridsize bei Online Map auf 000° 10.000 erhöht
   *                   Gridsize bei Route Record einstellbar
   * HP release 1.65 = Export / Import von Routen
   *                   Center at auch für light Caches
   *                   Rename Filter
   *            1.66 = Export Pseudolog bei Lite Caches mit dem Letzten Fund datum
   * HP release 1.67 = Filtername "-" verbieten
   *                   Umbenennen Light in Lite
   *            1.68 = Unterstützung Favoritenpunkte
   *            1.69 = Fix Bug bei Anzeige von Caches, da wurde gar nichts mehr angezeigt.
   *            1.70 = Hoffentlich deutliche Verbesserung Umgang Modaler Dialoge unter Linux
   *                   Fix Setfocus Bug in TB-Eingabe Dialog
   *            1.71 = Mit Speichern der Form Dimension bei Routen
   *                   Fix Anchors in Center at dialog
   * HP release 1.72 = Fix Export Bug von Lite Caches
   *                   Fix Dateiname in Export nach C:Geo
   *                   Favs aus GSAK Importen berücksichtigen
   *                   Favs die vorher schon da waren, werden nicht mehr durch Pocketquery importe genullt
   *                   Wird ein Lite-Cache mit Favs weggeworfen überlebt nun die Fav nummer
   *            1.73 = Erkennen der Endianes der geocache_visit.txt und geeignet laden (support c:geo)
   *                   Fix Dialog bei Anzeige von sehr vielen GC-Codes während Fieldnote Import
   *            1.74 = Unterstützen von " in geocache_visits.txt
   *                   Verbesserter Parser der geocache_visits.txt
   *            1.75 = support \n in add found number
   *                   renamed "Add Found number" to "add signature"
   *                   Sortieren nach Spalte im Fielnote Editor
   *            1.76 = Added section Tutorial to help menu
   *                   Minor bugfixes in TB-Editor
   *                   Robusteres Importieren von TB-Codes
   *                   Kontrolle bei der Eingabe von TB-Codes im Eigenen Editor
   *            1.77 = Anzeige Anzeige der Auswahl im Fieldnote Editor
   *                   Via Markieren und Kontextmenü Selectieren / Deselectieren
   *                   Fieldnotes automatisch nach Logdatum Sortieren, bevor die Signatur angefügt wird.
   *            1.78 = Beim Import von Caches wird das Customer Flag nicht mehr zurückgesetzt
   *                   Neues Tutorial How To Handle TB's
   *            1.79 = Anzeigen Total CacheCount bei Datenbankauswahl
   *                   Anzeigen Total CacheCount in Main Form
   *                   Anzeigen Total TBCount in TBDatabase Editor
   *                   Fix Konvertierung Light nach Lite scheiterte bei Datenbanken die noch keine FAV's unterstützten
   *                   Fix Write Geocache_visits.txt hatte BOM nicht gesetzt
   *            1.80 = Fix CSV-Export added invalid captions for columns
   *            1.81 = Nach Löschen einer DB Automatische Anwahl einer neuen oder erstellen
   * HP release 1.82 = Mitscrollen beim Loggen von vielen TB's
   *                   Sortieren von TB's wie beim Field Note Editor
   *            1.83 = Automatisches anpassen der Count info beim discovern von TB's
   *            1.84 = Anzeigen Warnung, wenn nicht alle Einträge in geocache_visits zurück geschrieben werden.
   *            1.85 = Fix FormShow aus Fremdforms heraus zerwürfelte die Form Reihenfolgen
   *                   Fix Memleak
   * HP release 1.86 = Die letzten n Suchanfragen merken
   *            1.87 = Clear History via Contextmenu
   *            1.88 = CenterAt lädt ggf. den Cache als LiteCache nach
   *            1.89 = Upload von Bildern in Logs
   *            1.90 = Fix Crash, beim herunterladen eines ungültigen GC-Codes
   *                   Export Orig Mystery Koordinate als Wegpunkt
   * HP release 1.91 = Fix Online Map Fenster war nicht StayOnTop
   *                   Fix On Windows some Windows left the monitor, when others Fullscreen
   *            1.92 = Anzeigen, dass Koordinaten bereits modifiziert sind.
   *            1.93 = Fix, DB-Cachecount wurde beim anlegen eines LAB-Caches nicht aktualisiert
   *                   Fix, Export csv ohne Koords gab AV
   *            1.94 = Schöneres Code bassiertes Scrollen in den Stringgrids (und setzen von Selected)
   * HP release 1.95 = Will Attend als Logtype Aktiviert
   *                   Fix AV, bei Eingabe text als Distanz
   *            1.96 = Neuer About Dialog
   *            1.97 = "fieldnotes.txt" von IOS wird nun beim laden von Geocache_visits.txt ebenfalls unterstützt
   * HP release 1.98 = Support Celebration Event Cache
   *            1.99 = Anpassen aller Pfade auf OS "erlaubte" Pfade => Damit kann der CCM theoretisch in einem ReadOnly Verzeichnis liegen (ohne Update)
   *                   Option Lösche MapTileCache
   *            2.00 = Neue PrettyTime Funktion
   *                   Kleinere Schönheitskorrekturen im About Dialog
   * HP release 2.01 = Anpassen Log auf neue Groundspeak API
   *            2.02 = Fix, das Skriptmenü wurde durch den Wizzard nicht erstellt (benötigte Neustart)
   *            2.03 = Anzeige GC-Code und Titel beim Spoiler DL
   *            2.04 = Fix, Crash wenn beim ersten Start der Wizzard abgebrochen wird und dann sofort Beendet wird.
   *            2.05 = Anzeige Anzahl Logs im Show Logs Dialog
   *            2.06 = Fix Typo gbx -> gpx
   *            2.07 = Reduce Errormessages when Listing Download fails.
   *            2.08 = Fix Hints für LiteCaches wurden nicht aus dem Puffer geschmissen, wenn Online Map geschlossen wurde
   *            2.09 = Entfernen Redundanter Code zum Parsen von JSON-Litecaches
   *            2.10 = Wegpunktprojektion aus dem Edit Coordinate Dialog heraus
   *            2.11 = Erste Eingabefelder (Angle / Dist im Wegpunktprojektion) lassen Formeln ohne Variablen zu.
   * HP release 2.12 = Im Fieldnote Editor kann man nun nachträchlich noch GC-Codes mit anfügen.
   *            2.13 = Warnen, wenn Favs ohne Webcam Photo Taken / Found it geloggt werden sollen (geht nicht)
   *                   CustomFlags auch für gerade erst geladenen Lite Caches
   *            2.14 = Fix DB-Cachecount nach Einfügen von lite Caches, stimmte nicht
   *                   Fix CSV-Export labels beim Export von Parkplatzkoordinagen (deg + dec) falsch beschriftet
   *                   Fix GC-Server Antwortet manchmal nicht mehr, Lösung durch "künstliches warten bis er wieder will"
   *                   Fix Anzeige der Gepufferten Caches während der Routen Aufnahme wurde nicht Aktualisiert
   *            2.15 = 4 Neue Cache Attribute von GC-Verfügbar.
   *                   Korrektes anzeigen Logstate in Show Logs (manchmal wurden nur zahlen angezeigt)
   *                   Copy to Clipboard für das Suchfeld (war kaputt, wegen Clear History Menü)
   *                   Favs sind nun schon im Field Note Editor über das Context Menü setzbar (Erleichterung fürs online loggen)
   *                   Historie für TB-Code Eingabefeld (mittels Hoch / Runter verfügbar)
   * HP release 2.16 = Customflags nun auch im Fieldnote Editor verfügbar
   *            2.17 = Gesetzte Favs wurden beim erneuten loggen anderer Caches fehlerhaft übernommen
   *                   Sortieren nach vergebenen Favs kaputt
   *            2.18 = Das "Merken" der gesetzen Favs hat sich beim Online loggen invertiert
   *            2.19 = Anlegen von LAB-Caches vereinfacht
   *                   Fix Welcome Message, ging in Release 1.99 Kaputt
   *                   Open Config folder aus Optionen Dialog heraus
   *                   Edit Listing / title von nicht HTML-Caches (z.B. LAB-Caches)
   * HP release 2.20 = Gefundene Dosen wurden beim Import nicht immer als gefunden erkannt obwohl im gpx die notwendigen Informationen enthalten waren
   *                   Logs wurden beim Import nicht immer Korrekt aktualisiert
   *            2.21 = Tools Untermenü war unter Linux ganz Rechts anstatt in der Mitte
   *            2.22 = Download von Listings ein bischen robuster gemacht
   * HP release 2.23 = Update Fav Aktualisiert nun auch das Hidden date.
   *            2.24 = F2 auch in Write Log Dialog
   *            2.25 = F1 für Edit User Note
   *            2.26 = Anzeige TB-Details
   *                   Redownload TB-Listing - mit Logtext
   *                   Mitspeichern des TB' Headings
   * HP release 2.27 = Support für Locationless Cache
   *            2.28 = Erste Versuche LAB's zu laden
   *            2.29 = Anpassen an neues LAB-JSON Interface
   * HP release 2.30 = Anpassen Extract Find-Count an neue HP-Variante
   *            2.31 = Globale Hotkeys der Stringliste sind nicht sauber auf die anderen Controls verteilt worden
   *            2.32 = Copy or move LABS from one DB to other lost their waypoints
   *                   LAB2GPX Exports werden nun als "Waypoints as Cache" importiert
   *            2.33 = Export Hints als GC:Note für C:Geo
   * HP release 2.34 = Reaktivieren Download Labs
   *                   Fix Labs und normale Caches konnten nicht "gleichzeitig" angezeigt werden.
   *            2.35 = Fix Memleaks
   *            2.36 = Fix Anchor Bug in Travelbug Database View
   *            2.37 = Kartensprache nun "wählbar (nicht vergessen den Cache zu leeren)
   *            2.38 = Custom filter / 81iger Ansicht kann nun auch nach Container Size suchen / filtern
   *                   Robusterer Field Note Import
   * HP release 2.39 = Nach Listing Redownload wurde das Icon des Caches nicht Aktualisiert
   *            2.40 = Fix Anchors in Export CSV Dialog
   * HP release 2.41 = Fix Crash on loading 81-Matrix
   *            2.42 = Add ability to clear problems during log entering
   *                   Updated Default Export Filter !! Attention !! you have to update the filter by hand to get the new features
   *            2.43 = Laden / Uploaden UserNote und Korrigierte Koords von und zur Webseite
   *            2.44 = Anzeigen Zwischenergebnisse im Show 81iger Matrix Dialog (Optische Verkürzung der Ladezeit)
   *                   Zuordnung Cache Size zu Icon war Falsch + Hints eingefügt
   *            2.45 = Fix Anchors in SQL-Admin Dialog
   *                   Fix Export filter
   *                   New Export Filter / Button Reset "Filter"
   * HP release 2.46 = Check inifile on load and update "invalid" / "old" filters if needed.
   *                   Abfangen AV wenn DL von Cache schief geht
   *                   Fix GPX-Downloading
   *            2.47 = Fix ToSQLString, ..
   * HP release 2.48 = Fix GPX-Downloading (viewstates nicht korrekt ausgelesen)
   * HP release 2.49 = Improve SQL-Interface to new usqlite_helper.pas
   *            2.50 = Auto Scroll down Jasmer view
   * HP release 2.51 = Fix open Cache in Browser
   *            2.52 = Fix Anzeigename Multis in Fieldnotes kaputt
   *            2.53 = Fix Zeitstempel mit +00:00 (andere Zeitzonen) wurden nicht umgewandelt -> damit in der Zukunft = Fehler
   *                   Anzeige Logdatum in Log Ansicht war kaputt
   * HP release 2.54 = Fix Anzeige bei 81iger Matrix stimmte mit filtern für Attribute und Size nicht.
   * HP release 2.55 = Fix g_Type wurde an ettlichen Stellen nicht mittels FromSQLString gelesen
   *                   Fix custom Filter mit Multi's waren kaputt
   *            2.56 = Fix invalid g_type values on DB-Load and after import
   *            2.57 = Fix loading Field notes from L4C
   *                   Improve Error messages in Log Dialog
   *                   Fix Online Log dialog did not pop over custom filter
   *                   Fix Online Log dialog did not import multiple Caches when entered as "spaced" list
   *                   Fix Cachly Multi import wrong Icon
   * HP release 2.58 = Fix TB'discovering was broken
   *            2.59 = Fix Retrieved TB's where not counted as "discovered" TB's
   * HP release 2.60 = Fix reduce "blocking" due light cache downloading (is now skipable)
   *                   Fix lite cache downloading was broken
   *            2.61 = Center at coodinate (in Map view)
   *)

  Version = updater_Version;

  (*
   * Bekannte Bugs/ Missing Feature:
   *   - Project APE Caches werden beim Exportieren nicht auf dem GPS Angezeigt
   *     \-> evtl liegt es am Type -> das Garmin kann die bestimmt net anzeigen
   *   - Beim Importieren eines bereits existierenden Skriptes den Überschreiben Dialog unterbinden wenn Quelle und Ziel identisch sind.
   *   - Beim Schmerzbefreit geht das Rendern der Karte nicht Richtig, es wird immer die Textur des 1. Tiles links oben genommen..
   *     \-> Vermutung, es liegt am Graphikkartentreiber (noch nicht bestätigt)
   *   - ParamStrUTF8(0) darf unter Unix nicht genutzt werden -> da muss wohl noch eine Lösung her ...
   *     \-> Umbauen gemäß: http://www.lazarusforum.de/viewtopic.php?f=16&t=12446
   *     \-> Problem nur, wenn CCM via Symlink genutzt wird
   *   - Beim Loggen via GC-Code, erkennen, das es ein eigener ist => Auswerten des Fehlercodes.
   *   (- ugctool sollte in einen TThread ausgelagert werden, damit das nachladen nicht Blocking ist)
   *
   *)

Type

  TFileType = (ftJPG, ftPNG, ftBMP, ftUnknown);

  { TSimpleIpHtml }

  TSimpleIpHtml = Class(TIpHtml)
  public
    Property OnGetImageX;
    Function LoadContentFromString(Const Content: String; Callback: TIpHtmlDataGetImageEvent): Boolean;
  End;

  TReportProblemLogType = (
    rptNoProblem,
    rptLogfull, // = 45
    rptDamaged, // = 45
    rptMissing, // = 45
    rptArchive, // = 7
    rptOther // = 45
    );

  TLogtype = (
    ltFoundit, //          =  2
    ltDidNotFoundit, //    =  3
    ltWriteNote, //        =  4
    //ltArchive, //        =  5
    ltNeedsArchive, //     =  7
    ltWillAttend, //       =  9
    ltAttended, //         = 10
    ltWebcamPhotoTaken, // = 11
    //ltUnarchive, //      = 12
    ltNeedsMaintenance, // = 45 // -> other
    //ltOwnerMaintenance,//= 46
    ltUnattempted //       = 4 -- Den gibt es bei GC nicht ist von Garmin -> Write Note
    );

  TTBLogType = (
    tlWriteNote, //         = 4
    tlRetrieveFromCache, // = 13
    tlDroppedOff, //        = 14
    tlTransfer, //          = 15
    tlMarkMissing, //       = 16
    tlGrabIt, //            = 19 (not from a Cache)
    tlDiscoveredIt, //      = 48
    tlMoveToCollection, //  = 69
    tlMoveToinventory, //   = 70
    tlVisited //            = 75
    );

  TViewport = Record
    Lat_min: Double;
    Lon_min: Double;
    Lat_max: Double;
    Lon_max: Double;
  End;

  // Datensatz zur Bearbeitung der geocaches_visits.txt
  TFieldNote = Record
    // Die Einträge der Fieldnote Liste wie sie vom Garmin kommen
    GC_Code: String;
    Date: String;
    Logtype: TLogtype;
    Comment: String;
    // Alles ab hier ist fürs online loggen mittels gctools
    Image: String; // Dateiname auf ein Bild welches mit hochgeladen werden soll
    TBs: TStringArray;
    Fav: Boolean; // Wenn True, dann wird die Dose als Favourit geloggt
    reportProblem: TReportProblemLogType;
  End;

  (*
   * ER-Model für : http://plantuml.com

   @startuml
    'Ausblenden des Kreises in der Caption
    hide circle
    'Ausblenden von Leeren Sections in den Entities
    hide empty members
    package "Cache databases" {
    entity caches {
    * name
    --
    lat
    lon
    cor_lat
    cor_lon
    Time
    Desc
    URL
    URL_Name
    Type
    Note
    Customer_Flag
    Lite
    Fav
    G_ID
    G_AVAILABLE
    G_ARCHIVED
    G_NEED_ARCHIVED
    G_Found
    G_XMLNS
    G_NAME
    G_PLACED_BY
    G_OWNER_ID
    G_OWNER
    G_TYPE
    G_CONTAINER
    G_DIFFICULTY
    G_TERRAIN
    G_COUNTRY
    G_STATE
    G_SHORT_DESCRIPTION
    G_SHORT_DESCRIPTION_HTML
    G_LONG_DESCRIPTION
    G_LONG_DESCRIPTION_HTML
    G_ENCODED_HINTS
    }

    entity attributes {
    + cache_name
    --
    ID
    INC
    Attribute_text
    }

    entity logs {
    + cache_name
    --
    ID
    Date
    Type
    Finder_ID
    Finder
    Text_Encoded
    Log_text
    }

    entity waypoints {
    + cache_name
    --
    Name
    Time
    Lat
    Lon
    CMT
    Desc
    URL
    URL_Name
    Sym
    Type
    }
    }

    package "Trackable Database" {
    entity trackables{
    * Discover_Code
    --
    TB_Code
    LogState
    LogDate
    Owner
    ReleasedDate
    Origin
    Current_Goal
    About_this_item
    Comment
    Heading
    }
    }

    caches --{ attributes
    caches --{ logs
    caches --{ waypoints
    @enduml
  *)

  // Attribut eines Caches (z.B. Need Climbing ...)
  TAttribute = Record
    id: integer; // Was
    inc: integer; // Verboten oder Erlaubt
    Attribute_Text: String;
  End;

  // Ein einzelner Log
  TLog = Record
    id: integer;
    date: String;
    Type_: String;
    // Todo: Eigentlich sollte FinderID ein Fremdschlüssel auf eine "User" Datenbank sein in der dann ID auf Klarnamen gemappt werden.
    Finder_ID: integer;
    Finder: String;
    Text_Encoded: Boolean;
    Log_Text: String;
  End;

  TWaypoint = Record
    GC_Code: String; // GC-Code zu dem der Wegpunkt gehört
    Name: String; // Name des Wegpunktes
    Time: String; // Zeitstempel
    lat: Double;
    Lon: Double;
    cmt: String; // Text
    desc: String; // GC-Code + zusatz info
    url: String;
    url_name: String;
    sym: String; // Symbol
    Type_: String; // Symbol
    // Für interne Verarbeitungen, hat nichts mit der SQL Datanbank zu tun
    Used: Boolean; // Für den Wegpunkt Export, damit die Daten nicht umkopiert werden müssen
  End;

  TWaypointList = Array Of TWaypoint;

  (*
   * !! ACHTUNG !!
   *
   * Wenn an diesem Record etwas geändert wird muss die Routine "LiteCacheToCache" in Unit40 auch angepasst werden.
   *)
  TCache = Record
    // Tag wpt
    Lat: Double;
    Lon: Double;
    Cor_Lat: Double; // -1 = nicht Definiert -> Was machen wir wenn es einen Cache bei -1 -1 gibt ??
    Cor_Lon: Double; // -1 = nicht Definiert
    Time: String; // Das Datum an dem die Dose gepublished wurde
    GC_Code: String; // Der GC Code
    Desc: String; // Eine Art zusammenfassung "<G_Name> by <G_Owner>, <Type_> (<G_Difficulty>/<G_Terrain>)"
    URL: String; // Direkter Link auf die Dose, quasi follow_links(https://coord.info/<gcCode>)
    URL_Name: String; // = <G_Name>
    Sym: String; // Das Symbol welches auf der onlinekarte zum Anzeigen genutzt wird
    Type_: String; // Tradi, Multi, Mystery .. !! der CCM nutzt aber G_Type !!
    Note: String; // -- Vom benutzer eingegebene Notes
    Customer_Flag: integer; // Das kann der User Setzen oder auch nicht, dieses wird nicht Exportiert oder irgendwie behandelt.
    Lite: Boolean; // Ein Lite Cache ist ein nicht Vollständig geladener Cache, es sind nur die Felder von ugctool.TLiteCache definiert.
    Fav: integer; // Anzahl an Favoritenpunkte die der Cache hat
    // Tag Groundspeack:cache
    G_ID: integer; // Geocache ID, kann auch aus GC_Code Berechnet werden
    G_Available: Boolean; // 0 = Activ, 1 = Deaktiviert
    G_Archived: Boolean;
    // G_Need_Archived: Boolean; // Wird via Import Directory gesteuert um raus zu kriegen welche Caches nicht Aktualisiert wurden.
    G_Found: integer; // 0 = not Found, 1 = Found
    G_XMLNs: String; // Todo : Eigentlich Quatsch, bzw könnte man mal Entfernen
    G_Name: String; // Der Name, wie er angezeigt wird.
    G_Placed_By: String; // ?
    G_Owner_ID: integer; // ID des Owners
    G_Owner: String; // Klarname des Owners
    G_Type: String; // Tradi, Multi, Mystery ..
    G_Container: String; // Container Größe  [Micro]
    G_Attributes: Array Of TAttribute; // Liegt in einer Separaten Tabelle
    G_Difficulty: Single; // [3]
    G_Terrain: Single; // [1.5]
    G_Country: String; // Land
    G_State: String; // Bundesland
    G_Short_Description: String; // ? Teil des Listing Textes
    G_Short_Description_HTML: Boolean;
    G_Long_Description: String; // ? Teil des Listing Textes
    G_Long_Description_HTML: Boolean;
    G_Encoded_Hints: String; // Der Hint
    Logs: Array Of TLog; // Liegt in einer Separaten Tabelle
    Waypoints: TWaypointList; // -- Ist Defaultmäßig = NIL
    //    travelbugs: Array Of TTravelbug; -- Wo kriegen wir die her ?
  End;

  TCacheArray = Array Of TCache;

  TFieldNoteList = Array Of TFieldNote;

  TRefresStatsMethod = Function(Filename: String; Count, Waypoints: integer; Restart: Boolean): Boolean Of Object;

  TPOIInfo = Record
    Sym: String;
    FileNameAdd: String;
    Bitmap: String;
  End;

Const

  (*
   * Alle Verwendeten Bilder müssen auf 256-Farben beschränkt werden !!
   *)
  POI_Types: Array[0..7] Of TPOIInfo = (// !! Achtung !!, das muss 0-basiert sein !
    (sym: 'Final Location'; FileNameAdd: '_fl'; Bitmap: 'Final Location.bmp'),
    (sym: 'Parking Area'; FileNameAdd: '_pa'; Bitmap: 'Parking Area.bmp'),
    (sym: 'Physical Stage'; FileNameAdd: '_ps'; Bitmap: 'Physical Stage.bmp'),
    (sym: 'Reference Point'; FileNameAdd: '_rp'; Bitmap: 'Reference Point.bmp'), // Achtung der Index 3 ist hardcodiert in Loadwpttag !!
    (sym: 'Trailhead'; FileNameAdd: '_th'; Bitmap: 'Trailhead.bmp'),
    (sym: 'Virtual Stage'; FileNameAdd: '_vs'; Bitmap: 'Virtual Stage.bmp'),
    // Ab hier kommen keine Echten Wegpunktbilder mehr.
    (sym: 'Mystery'; FileNameAdd: '_my'; Bitmap: 'Mystery.bmp'), // -- Das ist kein Echter POI-Type der ccm kann aber auf alle Modifizierten Koords einen zusätzlichen POI mit dieser Graphik setzen !! Muss immer vor-letzter sein !!
    (sym: 'Modified'; FileNameAdd: '_m'; Bitmap: 'Modified.bmp') // -- Das ist kein Echter POI-Type der ccm kann aber auf alle Modifizierten Koords einen zusätzlichen POI mit dieser Graphik setzen !! Muss immer letzter sein !!
    );

  Valid_POI_Types_Count = length(POI_Types) - 2;

  AttribsNames: Array[1..72] Of String = (
    'Dogs', // 1
    'Access Or parking fee', // 2
    'Climbing gear', // 3
    'Boat', // 4
    'Scuba gear', // 5
    'Recommended For kids', // 6
    'Takes less than an hour', // 7
    'Scenic view', // 8
    'Significant Hike', // 9
    'Difficult climbing', // 10
    'May require wading', // 11
    'May require swimming', // 12
    'Available at all times', // 13
    'Recommended at night', // 14
    'Available during winter', // 15
    '', // 16 -- Was war das mal ?
    'Poison plants', // 17
    'Dangerous Animals', // 18
    'Ticks', // 19
    'Abandoned mines', // 20
    'Cliff / falling rocks', // 21
    'Hunting', // 22
    'Dangerous area', // 23
    'Wheelchair accessible', // 24
    'Parking available', // 25
    'Public transportation', // 26
    'Drinking water nearby', // 27
    'Public restrooms nearby', // 28
    'Telephone nearby', // 29
    'Picnic tables nearby', // 30
    'Camping available', // 31
    'Bicycles', // 32
    'Motorcycles', // 33
    'Quads', // 34
    'Off - road vehicles', // 35
    'Snowmobiles', // 36
    'Horses', // 37
    'Campfires', // 38
    'Thorns', // 39
    'Stealth required', // 40
    'Stroller accessible', // 41
    'Needs maintenance', // 42
    'Watch For livestock', // 43
    'Flashlight required', // 44
    'Lost And Found Tour', // 45
    'Truck Driver / RV', // 46
    'Field Puzzle', // 47
    'UV Light Required', // 48
    'Snowshoes', // 49
    'Cross Country Skis', // 50
    'Special Tool Required', // 51
    'Night Cache', // 52
    'Park And Grab', // 53
    'Abandoned Structure', // 54
    'Short hike(less than 1 km)', // 55
    'Medium hike(1 km - 10 km)', // 56
    'Long Hike(+ +10 km)', // 57
    'Fuel Nearby', // 58
    'Food Nearby', // 59
    'Wireless Beacon', // 60
    'Partnership Cache', // 61
    'Seasonal Access', // 62
    'Tourist Friendly', // 63
    'Tree Climbing', // 64
    'Front Yard(Private Residence)', // 65
    'Teamwork Required', // 66
    'Geotour', // 67
    '', // 68 -- Was war das mal ?
    'Bonus cache', // 69
    'Power trail', // 70
    'Challenge cache', // 71
    'Geocaching.com solution checker' // 72
    );

  // Liste aller Positive Attribute und derer Nummern, sortiert nach Project-GC
  PosAttribs: Array[0..69] Of integer = (
    20, 54, 2, 13, 15, 32, 4, 69, 38, 31, 71, 21, 3, 18, 23, 10, 1, 27, 47, 44,
    59, 58, 72, 67, 37, 22, 43, 57, 45, 50, 49, 12, 11, 56, 33, 42, 52, 35, 53, 25,
    61, 30, 17, 70, 28, 26, 34, 14, 6, 63, 8, 5, 62, 55, 9, 36, 51, 40, 41, 7,
    66, 29, 39, 19, 64, 46, 48, 24, 60, 65
    );

  // Liste aller Negativ Attribute und derer Nummern, sortiert nach Project-GC
  NegAttribs: Array[0..40] Of Integer = (
    54, 13, 15, 32, 38, 31, 10, 1, 27, 47, 59, 58, 37, 57, 56, 33, 52, 35, 53, 25,
    30, 17, 28, 34, 14, 6, 63, 8, 62, 55, 9, 36, 40, 41, 7, 66, 29, 64, 46, 24,
    65
    );

  (*
   * Für die Dependency inversion
   *)
Var
  SQLite3Connection: TSQLite3Connection = Nil;
  SQLQuery: TSQLQuery = Nil;
  SQLTransaction: TSQLTransaction = Nil;

  TB_SQLite3Connection: TSQLite3Connection = Nil;
  TB_SQLQuery: TSQLQuery = Nil;
  TB_SQLTransaction: TSQLTransaction = Nil;

  RefresStatsMethod: TRefresStatsMethod = Nil;
  DefFormat: TFormatSettings;
  VeryFirstStartofCCM: Boolean = false; // True, wenn der ccm das erste mal gestartet wird (ccm.ini nicht vorhanden)

Procedure Initccm(Lazy: Boolean); // Initialisiert die internen Variablen und Strukturen (sowie die .ini Datei), im CCM mus lazy = false sein !!

(*
 * Öffnet die FieldNote Datei vom GPS und gibt sie als FieldNoteListe zurück
 *)
Function LoadFieldNotesFromFile(Const Filename: String): TFieldNoteList;

(*
 * Speichert eine FieldNoteListe in eine FieldNote Date (die dann bei Geocaching.com importiert werden kann)
 *)
Function SaveFieldNotesToFile(Const Filename: String; Data: TFieldNoteList): Boolean;

(*
 * Erzeugt eine komplett neue Datenbank
 *)
Function CreateNewDatabase(Const DataBasename: String): boolean;

(*
 * Erzeugt eine neue TB Datenbank
 *)
Function CreateNewTBDatabase(Const Filename: String): Boolean;

(*
 * True, wenn der Spaltenname in der Tabelle Existiert.
 *)
Function ColumnExistsInTable(ColumnName, TableName: String): Boolean;
Function ColumnExistsInTBTable(ColumnName, TableName: String): Boolean;

(*
 * Liefert eine Liste aller Spalten der Tabelle TableName
 *)
Function GetAllColumsFromTable(TableName: String): TStringlist;

(*
 * Startet eine SQLQuery im Anschluss muss diese nur noch ausgewertet werden.
 * Result = false, Fehler
 * Result = True, Auswertung via :
 *
 *  While (Not SQLQuery.EOF) Do Begin
 *    -- Auswertung des jeweiligen Datensatzes
 *    SQLQuery.Next;
 *  End;
 *  SQLQuery.Active := false; // -- Optional beenden des Kommunikationskanals
 *)
Function StartSQLQuery(Query: String): Boolean;
Function TB_StartSQLQuery(Query: String): Boolean;

(*
 * Using : - Call CommitSQLTransactionQuery as many times you want.
 *         - Write your results to the database by
 *           SQLTransaction.Commit;
 *)
Function CommitSQLTransactionQuery(aText: String): Boolean;
Function TB_CommitSQLTransactionQuery(aText: String): Boolean;

(*
 * Importiert eine GPX-Datei so denn sie noch nicht gefunden wurde.
 *)
Function ImportGPXFile(Filename: String): integer;
Function ImportZIPFile(Filename: String): integer;
Function ImportNoncheckedGPXFile(Filename: String): integer; // Wie Import Zip, nur ohne entzippen und ohne irgendwelche Datenkonsistenz prüfungen

(*
 * Lädt einen Cache aus der Datenbank wenn Result.GC_Code = '' dann Fehler
 *)
Function CacheFromDB(GC_Code: String; Skip_Attributes: Boolean = false): TCache;

(*
 * Trägt einen Cache in der Datenbank ein
 *)
Function CacheToDB(Var Cache: TCache; ForceUpdateLogsAttribs, ResetIfNotInDB: Boolean): Boolean;
Function CacheToDBUnchecked(Var Cache: TCache): Boolean;

(*
 * Gibt alle Wegpunkte, welche es zu Cachname gibt zurück
 *)
Function WaypointsFromDB(GC_Code: String): TWaypointList;
Function WaypointToDB(Const Waypoint: TWaypoint; ForceUpdateLogsAttribs: Boolean = false): Boolean;

(*
 * Löscht einen Cache und alles was dazu gehört aus der Datenbank (incl. evtl existierenden Spoilern)
 *)
Procedure DelCache(GC_Code: String);
Procedure DelWaypoint(wp: TWaypoint);

(*
 * Fügt in Doc dem ParentNode einen Tag mit Wert Value ein und gibt anschließend das neue Childnode zurück
 *)
Function AddTag(Const doc: TXMLDocument; ParentNode: TDOMNode; TagName, Value: String): TDOMNode;

(*
 * Routinen zum Umwandeln von Koordinaten in Strings und umgekehrt.
 * Die Strings sind dabei im Format [N/S] **° **.*** [E/W] **° **.***
 * Die Doubles sind im Englischen Format also -180.00 bis 180.00
 *)
Function CoordToString(Lat, Lon: Double): String;
Function StringToCoord(Coord: String; Out Lat: Double; Out lon: Double): Boolean; // Wandelt eine Komplette Koordinate in seine Teile um

(*
 * Vergleicht die beiden Koordinaten, True wenn sie Gleich sind, sonst false
 *)
Function CompareCoords(Lat1, Lon1, Lat2, Lon2: Double): Boolean;

(*
 * Projiziert Lat, lon um Dist meter in Alpha Grad => oLat oLon
 *
 * Quelle : https://www.naviboard.de/archive/index.php/t-25860.html
 *
 *)
Procedure ProjectCoord(Lat, Lon, alpha, Dist: Double; Out oLat: Double; Out oLon: Double);

(*
 * Zerlegt den Coord String und Verteilt die einzelteile in die Comboboxen und Edits
 * die Comboboxen müssen als Items [N/S] bzw. [E/W] haben
 *)
Procedure StringCoordToComboboxEdit(Coord: String; LatCom: tcombobox; LatEdit: TEdit; LonCom: tcombobox; LonEdit: TEdit);

(*
 * Parameterverwaltung
 *)
Function GetConfigFolder(): String;
Function GetValue(Section, Ident, Def: String): String;
Procedure SetValue(Section, Ident, Value: String);
Procedure DeleteValue(Section, Ident: String);
Procedure DeleteSection(Section: String);
Function SectionExists(Section: String): Boolean;

(*
 * Berechnet die Distanz zweier Koordinaten in Meter
 *)
Function distance(lat1, lon1, lat2, lon2: Double): Double;
Function distance2(lat1, lon1, lat2, lon2: Double): Double; // Berechnet die Distanz in Geokoordinaten

// Kopiert eine Datei aufs GPS und legt im Zweifelsfall die Notwendige Ordnerstruktur richtig an.
Function TransferSpoilerImage(SpoilerRootDir, CacheName, Filename: String): Boolean;

(*
 *      vmin / rmin               vmax / rmax
 *       |                                |
 *    ---------------------------------------
 *                  |
 *                 v / result
 *
 * Berechnet den Wert von result so, dass er an der entsprechEnd
 * gleichen Stelle in rmin / rmax liegt, wie  v in vmin / vmax ist.
 *)
Function convert_dimension(vmin, vmax, v: Single; rmin, rmax: integer): integer;

// Versucht ein Wenig den String nach HTML um zu wandeln
Function StringToHTMLString(Value: String): String;
Function HTMLStringToString(Value: String): String;

Function StrToTime(value: String): TDateTime; // Wandelt einen .gpx Timestring in TDatetime um (-1, wenns nicht geklappt hat)
Function GetTime(datetime: TDatetime): String; // Liefert den für die .gpx passend formatierrten Timestring zurück
Function StrToDateTimeFormat(Input, Format: String): TDateTime;

Procedure NewDocGPX(Out Doc: TXMLDocument; Out gpx: TDOMNode); // Legt eine neue Leere XML Datei an in der der CCM header steht

Procedure GetDBList(Const List: TStrings; ExcludeDB: String); // Gibt die Liste Aller Datenbanken zurück (sortiert), mit Optionalem Exlude von einer einzelnen
Function RemoveCacheCountInfo(DB_Name: String): String; // GetDBList fügt hinter jedem DB-Namen die Anzahl der Dosen an, Das macht es wieder weg.

Procedure FormShowModal(Const ModalForm, SenderForm: TForm);
Procedure BringFormBackToScreen(Const form: Tform); // Zentriert ein Formular wieder auf einem der Sichtbaren Monitore

Procedure Nop; // Nur zum Debuggen, bzw Haltepunkt setzen

Function PosRev(Const Substr, s: String): integer;

Function GetIndexOfLocation(Location: String; ShowWarningIfNotFound: Boolean): integer; // Liefert den Index in der ccm.ini, welcher dem Filter zugeordnet ist

Function LocateGPSExportIndex(Folder: String): integer; // Löst ein GPS_Export Verzeichnis in den zugehörigen index innerhalb der .ini File auf, -1, wenn nicht gefunden
Function LocateExportSpoilerIndex(Folder: String): integer;
Function LocateImportGeocacheVisitsIndex(Filename: String): integer;
Function LocatePoiExportFilderIndex(Folder: String): integer;

Procedure OpenCacheInBrowser(GC_Code: String);

// Formatiert eine time in s "hübsch"
Function PrettyTime(Time_in_ms: UInt64): String;

// Gibt zum AttributIndex das passende Bild zurück
// Es wird nicht geprüft ob es die Kombination tatsächlich gibt.
// Ist AttrActive = false, dann wird das rote durchgestrichen mit generiert.
Function GetAttribImage(Attrib: integer; AttrActive: Boolean): TBitmap;

// Filtert aus einem String alle Zeichen raus, welche nicht in Valids enthalten sind und ersetzt sie durch Replacer, ist replacer = #0 werden sie einfach nur entfernt
Function FilterStringForValidChars(Data: String; Valids: String; Replacer: Char): String;

// Ein Vom OS Bereitgestelltes Temp Verzeichnis
Function GetWorkDir(Out Directory: String): Boolean; // '' wenn keines gefunden / erstellt werden konnte
Function GetMapCacheDir(): String; // Ein System Verzeichnis in dem alle CCM Instancen die Geladenen Tiles Speichern Können
Function GetDataBaseDir(): String; // Verzeichnis in welchem die Datenbanken liegen
Function GetDownloadsDir(): String; // Verzeichnis in dem Informationen zu Listings, welche nachgeladen wurden abgelegt werden
Function GetSpoilersDir(): String; // Verzeichnis in dem die herunter geladenen Spoiler gespeichert werden.
Function GetImagesDir(): String; // Ein Reines "Lesen" Verzeichnis hier liegen alle Dynamisch nachgeladenen Bilder ab

// Für die Skripte werden die Verzeichnisse aufgelöst
Function ResolveDirectory(Dir, varpromptDirectory: String): String;

// Kann aus einem GC-Code eine GC.ReferenceID berechnen
Function GCCodeToGCiD(GC_Code: String): UInt64;

// Übersetzt einen Englischen String nach Logtype (z.B. beim FieldNode Import, das ist immer Englisch)
Function EnglishStringToLogType(Value: String): TLogtype; // !! Achtung, das ist keine Vollständige Liste
Function LogTypeToEnglishString(value: TLogtype): String; // !! Achtung, das ist keine Vollständige Liste
Function LogtypeToString(value: TLogtype): String;

Function LogtypeIndexToLogtype(Value: integer): TLogtype;
Function LogtypeToLogtypeIndex(value: TLogtype): integer;

Function ProblemTypeToProblemTypeIndex(Value: TReportProblemLogType): integer;
Function ProblemtypeIndexToProblemtype(Value: integer): TReportProblemLogType;
Function ProblemToString(Value: TReportProblemLogType): String;

(*
 * Fügt den Identifier zur Auswahl
 * "Gefunden"= F
 * "Archiviert" = A
 * "Koordinaten Modifiziert" = C
 * "Customer Flag" = U
 * Hinten an den Cachetyp an.
 *)
Function AddCacheTypeSpezifier(OldType: String; Spezifier: Char): String;
(*
 * Entfernt den Identifier aus OldType, siehe umkehrfunktion zu AddCacheTypeSpezifier
 *)
Function RemoveCacheTypeSpezifier(OldType: String; Spezifier: Char): String;

(*
 * Zerlegt einen CacheType String in seine 3 Bestandteile
 *)
Procedure SplitCacheType(CacheType: String; Out ClearCacheType: String; Out TypeSpezifier: String; Out DT: String);
Function MergeCacheType(ClearCacheType, TypeSpezifier, DT: String): String; // Umkehrfunktion zu SplitCacheType

Function PointInRect(P: TPoint; R: Trect): boolean;

(*
 * Wandelt den Dateinamen einer Datenbank in einen String um der als ini.Ident genutzt werden kann
 *)
Function DataBaseNameToIniString(Filename: String): String;

(*
 * Wählt die Zeile Row an, aber nicht mittels TopRow, sondern einer Art
 * BottomRow
 * Verwendet: DefaultRowHeight => Keine unterschiedlichen Zeilenhöhen unterstützt
 *)
Procedure SelectAndScrollToRow(Const Grid: TStringGrid; Row: integer);

(*
 * Löscht aus dem Filename alles mögliche Raus, was as Dateinamen eine Zugriffsverletzung geben würde.
 *)
Function FilterForValidFilenameChars(Const Filename: String): String;

Function GetFileTypeByFirstBytes(Const Filename: String): TFileType;

(*
 * Wandelt die Texte Um in Integer Zahlen !! Achtung !! Die Zahlen sind von 0-An Aufsteigend sortiert nach Form13.ImageList1, das hat nichts mit der Groundspeak Sortierung zu tun !!
 *)
Function CacheSizeToIndex(CacheSize: String): integer;
Function IndexToCacheSize(Index: integer): String;

(*
 * Gibt den Default filter für Filtername, '' wenn es keinen gibt.
 *)
Function GetDefaultFilterFor(FilterName: String): String;

Implementation

Uses usqlite_helper, FileUtil, lazutf8, LazFileUtils, dialogs, IniFiles, laz2_XMLRead,
  zipper, math, controls, LCLIntf, umapviewer, db;

Var
  ini: TIniFile = Nil;

Procedure Nop;
Begin

End;

Function FilterForValidFilenameChars(Const Filename: String): String;
Begin
  result := Filename;
  // Entnommen aus: https://en.wikipedia.org/wiki/Filename
  result := StringReplace(result, '/', '', [rfReplaceAll]);
  result := StringReplace(result, '\', '', [rfReplaceAll]);
  result := StringReplace(result, '?', '', [rfReplaceAll]);
  result := StringReplace(result, '%', '', [rfReplaceAll]);
  result := StringReplace(result, '*', '', [rfReplaceAll]);
  result := StringReplace(result, ':', '', [rfReplaceAll]);
  result := StringReplace(result, '|', '', [rfReplaceAll]);
  result := StringReplace(result, '"', '', [rfReplaceAll]);
  result := StringReplace(result, '<', '', [rfReplaceAll]);
  result := StringReplace(result, '>', '', [rfReplaceAll]);
  //result := StringReplace(result, '.', '', [rfReplaceAll]);
  result := StringReplace(result, ' ', '', [rfReplaceAll]);
End;

Function GetFileTypeByFirstBytes(Const Filename: String): TFileType;
Var
  f: TFileStream;
  b1, b2, b3: byte;
Begin
  // Entnommen aus: https://en.wikipedia.org/wiki/List_of_file_signatures
  result := ftUnknown;
  f := TFileStream.Create(Filename, fmOpenRead);
  b1 := 0;
  b2 := 0;
  b3 := 0;
  f.Read(b1, 1);
  f.Read(b2, 1);
  f.Read(b3, 1);
  If (b1 = $FF) And (b2 = $D8) And (b3 = $FF) Then result := ftJPG;
  If (b1 = $89) And (b2 = $50) And (b3 = $4E) Then result := ftPNG;
  If (b1 = $42) And (b2 = $4D) Then result := ftBMP;
  f.free;
End;

(*
 * Wandelt die Texte Um in Integer Zahlen !! Achtung !! Die Zahlen sind von 0-An Aufsteigend sortiert nach Form13.ImageList1, das hat nichts mit der Groundspeak Sortierung zu tun !!
 *)

Function CacheSizeToIndex(CacheSize: String): integer;
Begin
  result := -1; // Default
  Case CacheSize Of
    '': result := 0; // Fehler, dass darf nicht vor kommen
    csMicro: result := 1;
    csSmall: result := 2;
    csRegular: result := 3;
    csLarge: result := 4;
    csVirtual: result := 5;
    csUnknown, csNotChosen: result := 6;
    csOther: result := 7;
  End;
  If result = -1 Then Begin
    showmessage(format(RF_Could_not_resolve_container_size, [CacheSize]));
    result := 0;
  End;
End;

(*
 * Wandelt die Texte Um in Integer Zahlen !! Achtung !! Die Zahlen sind von 0-An Aufsteigend sortiert nach Form13.ImageList1, das hat nichts mit der Groundspeak Sortierung zu tun !!
 *)

Function IndexToCacheSize(Index: integer): String;
Begin
  result := ''; // Default
  Case Index Of
    1: result := csMicro;
    2: result := csSmall;
    3: result := csRegular;
    4: result := csLarge;
    5: result := csVirtual;
    0, 6: result := csNotChosen;
    7: result := csOther;
  End;
  If result = '' Then Begin
    showmessage(format(RF_Could_not_resolve_container_size, [inttostr(Index)]));
    result := csNotChosen;
  End;
End;

Procedure SelectAndScrollToRow(Const Grid: TStringGrid; Row: integer);
Var
  r: TgridRect;
  RowsPerScreen: integer;
  ne: TNotifyEvent;
Begin
  If (row < 0) Or (row >= Grid.RowCount) Then exit;
  // Das setzen der Toprow löst einen OnClick aus, das soll hier aber explizit nicht geschehen, wir scrollen ja nur ...
  ne := Grid.OnClick;
  Grid.OnClick := Nil;
  // Die Selection
  r := Grid.Selection;
  r.Top := Row;
  r.Bottom := Row;
  Grid.Selection := r;
  Grid.row := row;
  // Scrollen
  If row < Grid.TopRow Then Begin // Das Grid muss hoch gescrollt werden
    Grid.TopRow := row;
  End
  Else Begin
    // TODO: Wenn man Dynamische RowHeights hat, muss RowsPerScreen Dynamisch berechnet werden
    RowsPerScreen := (Grid.Height Div Grid.DefaultRowHeight) - grid.FixedRows;
    If Row >= Grid.TopRow + RowsPerScreen Then Begin // Das Grid mus nach Unten Gescrollt werden
      grid.TopRow := max(0, row - RowsPerScreen + 1);
    End;
  End;
  Grid.OnClick := ne;
End;

Function MergeCacheType(ClearCacheType, TypeSpezifier, DT: String): String;
Begin
  If dt <> '' Then Begin // Wieder zusammenbasteln
    result := ClearCacheType + TypeSpezifier + '|' + dt;
  End
  Else Begin
    result := ClearCacheType + TypeSpezifier;
  End;
End;

(*
 * Bläßt einen TypeIdentifierstring in einen mit Leerzeichen gefüllten String auf
 * so dass an jeder Stelle immer nur ein A,C,F,U steht z.b. "F" -> "  F"
 *)

Function ExpandTypeSpezifier(TypeSpezifier: String): String;
Var
  i: Integer;
Begin
  result := '    '; // 4 Leerzeichen
  For i := 1 To length(TypeSpezifier) Do Begin
    Case TypeSpezifier[i] Of
      'A': result[1] := 'A';
      'C': result[2] := 'C';
      'F': result[3] := 'F';
      'U': result[4] := 'U';
    End;
  End;
End;

Function AddCacheTypeSpezifier(OldType: String; Spezifier: Char): String;
Var
  CT, TI, DT: String;
Begin
  SplitCacheType(OldType, ct, ti, dt); // Zerlegen in die 3 Teile
  ti := ExpandTypeSpezifier(ti); // Aufziehen auf 4 Zeichen Breit
  Case Spezifier Of // Das eigentliche "einfügen"
    'A': ti[1] := 'A';
    'C': ti[2] := 'C';
    'F': ti[3] := 'F';
    'U': ti[4] := 'U';
  End;
  ti := StringReplace(ti, ' ', '', [rfReplaceAll]); // Entfernen der "leerstellen"
  result := MergeCacheType(ct, ti, dt); // die 3 Teile wieder zusammen basteln
End;

Function RemoveCacheTypeSpezifier(OldType: String; Spezifier: Char): String;
Var
  CT, TI, DT: String;
Begin
  SplitCacheType(OldType, ct, ti, dt); // Zerlegen in die 3 Teile
  ti := ExpandTypeSpezifier(ti); // Aufziehen auf 4 Zeichen Breit
  Case Spezifier Of // Das eigentliche "Löschen
    'A': ti[1] := ' ';
    'C': ti[2] := ' ';
    'F': ti[3] := ' ';
    'U': ti[4] := ' ';
  End;
  ti := StringReplace(ti, ' ', '', [rfReplaceAll]); // Entfernen der "leerstellen"
  result := MergeCacheType(ct, ti, dt); // die 3 Teile wieder zusammen basteln
End;

Procedure SplitCacheType(CacheType: String; Out ClearCacheType: String; Out
  TypeSpezifier: String; Out DT: String);
Var
  Sel, Pre: String;
  p, t, i: Integer;
Begin
  // Abspalten der DT - Wertung
  p := PosRev('|', CacheType);
  If p <> 0 Then Begin
    // Sonder Hack, weil Lab Caches den | im Typ nahmen haben, ..
    If pos(lowercase(Geocache_Lab_Cache), lowercase(CacheType)) = 1 Then Begin
      p := -1;
      t := length(Geocache_Lab_Cache) + 1;
      For i := t To length(CacheType) Do Begin //
        If CacheType[i] = '|' Then Begin
          p := i;
          break;
        End;
      End;
    End;
    If p = -1 Then Begin
      Pre := CacheType;
      DT := '';
    End
    Else Begin
      Pre := copy(CacheType, 1, p - 1);
      DT := copy(CacheType, p + 1, length(CacheType));
    End;
  End
  Else Begin
    Pre := CacheType;
    DT := '';
  End;
  // Abspalten der Type Identifier
  sel := '';
  For i := Length(Pre) Downto 1 Do Begin
    If pre[i] In ['A', 'C', 'F', 'U'] Then Begin
      sel := sel + Pre[i];
      Pre := copy(Pre, 1, length(pre) - 1);
    End
    Else Begin
      break;
    End;
  End;
  ClearCacheType := pre;
  TypeSpezifier := sel;
End;

Function LogtypeIndexToLogtype(Value: integer): TLogtype;
Begin
  Case value Of
    0: result := ltAttended;
    1: result := ltWillAttend;
    2: result := ltFoundit;
    3: result := ltWebcamPhotoTaken;
    4: result := ltDidNotFoundit;
    5: result := ltWriteNote;
    6: result := ltNeedsMaintenance;
    7: result := ltUnattempted;
  Else Begin
      Raise Exception.Create('LogtypeIndexToLogtype, missing type.');
    End;
  End;
End;

Function LogtypeToLogtypeIndex(value: TLogtype): integer;
Begin
  Case value Of
    ltAttended: result := 0;
    ltWillAttend: result := 1;
    ltFoundit: result := 2;
    ltWebcamPhotoTaken: result := 3;
    ltDidNotFoundit: result := 4;
    ltWriteNote: result := 5;
    ltNeedsMaintenance: result := 6;
    ltUnattempted: result := 7;
  Else Begin
      Raise Exception.Create('LogtypeToLogtypeIndex, missing type.');
    End;
  End;
End;

Function ProblemTypeToProblemTypeIndex(Value: TReportProblemLogType): integer;
Begin
  result := 0;
  Case Value Of
    rptNoProblem: result := 0;
    rptLogfull: result := 1;
    rptDamaged: result := 2;
    rptMissing: result := 3;
    rptArchive: result := 4;
    rptOther: result := 5;
  End;
End;

Function ProblemtypeIndexToProblemtype(Value: integer): TReportProblemLogType;
Begin
  result := rptNoProblem;
  Case Value Of
    0: result := rptNoProblem;
    1: result := rptLogfull;
    2: result := rptDamaged;
    3: result := rptMissing;
    4: result := rptArchive;
    5: result := rptOther;
  End;
End;

Function EnglishStringToLogType(Value: String): TLogtype;
Begin
  result := ltWriteNote; // Wenn wir nicht wissen was es sein soll, dann ist es immer ein Write Note
  value := trim(lowercase(value));
  Case value Of
    '': result := ltFoundit; // Das kann bei einem Webcam Cache vorkommen der mittels L4C geloggt wurde
    'attended': result := ltAttended;
    'found it': result := ltFoundit;
    'needs maintenance': result := ltNeedsMaintenance;
    'write note': result := ltWriteNote;
    'webcam photo taken': result := ltWebcamPhotoTaken;
    'unattempted': result := ltUnattempted;
    'didn''t find it': result := ltDidNotFoundit;
  Else Begin
      Raise Exception.Create('EnglishStringToLogType, missing type: ' + Value);
    End;
  End;
End;

Function LogTypeToEnglishString(value: TLogtype): String;
Begin
  result := 'Write note';
  Case value Of
    ltAttended: result := 'Attended';
    ltFoundit: result := 'Found it';
    ltNeedsMaintenance: result := 'Needs Maintenance';
    ltWebcamPhotoTaken: result := 'Webcam photo taken';
    ltUnattempted: result := 'Unattempted';
    ltDidNotFoundit: result := 'Didn''t find it';
  Else Begin
      Raise Exception.Create('LogTypeToEnglishString, missing type (the logtype is not compatible with garmin logtypes).');
    End;
  End;
End;

Function ProblemToString(Value: TReportProblemLogType): String;
Begin
  result := '';
  Case value Of
    rptNoProblem: result := ''; // Kein Problem, keine Anzeige
    rptLogfull: result := R_Logbook_Full;
    rptDamaged: result := R_Container_Damaged;
    rptMissing: result := R_Container_Missing;
    rptArchive: result := R_Needs_Archive;
    rptOther: result := R_Needs_Maintenance;
  End;
End;

Function LogtypeToString(value: TLogtype): String;
Begin
  result := R_Write_note;
  Case value Of
    ltAttended: result := R_Attended;
    ltWillAttend: result := R_Will_attend;
    ltFoundit: result := R_Found_it;
    ltWebcamPhotoTaken: result := R_Webcam_photo_taken;
    ltDidNotFoundit: result := R_Did_not_find_it;
    ltWriteNote: result := R_Write_Note;
    ltNeedsMaintenance: result := R_Needs_Maintenance;
    ltUnattempted: result := R_Unattempted;
  Else Begin
      Raise Exception.Create('LogtypeToString, missing type.');
    End;
  End;
End;

Function PointInRect(P: TPoint; R: Trect): boolean;
Begin
  result :=
    (p.x >= min(r.Left, r.Right)) And
    (p.x <= max(r.Left, r.Right)) And
    (p.y >= min(r.Top, r.Bottom)) And
    (p.y <= max(r.Top, r.Bottom))
    ;
End;

Function DataBaseNameToIniString(Filename: String): String;
Begin
  result := ExtractFileName(Filename);
  result := ExtractFileNameWithoutExt(Result);
  result := StringReplace(result, ' ', '_', [rfReplaceAll]);
End;

Procedure BringFormBackToScreen(Const form: Tform);
Var
  d, md, m, i: integer;
  tl, tr, bl, br: Boolean;
Begin
  tl := false;
  tr := false;
  bl := false;
  br := false;
  md := high(integer);
  m := 0; // Default der 1. Monitor
  For i := 0 To Screen.MonitorCount - 1 Do Begin
    If PointInRect(point(form.Left, form.Top), screen.Monitors[i].BoundsRect) Then Begin
      tl := true;
    End;
    If PointInRect(point(form.Left + form.Width, form.Top), screen.Monitors[i].BoundsRect) Then Begin
      tr := true;
    End;
    If PointInRect(point(form.Left, form.Top + form.Height), screen.Monitors[i].BoundsRect) Then Begin
      bl := true;
    End;
    If PointInRect(point(form.Left + form.Width, form.Top + form.Height), screen.Monitors[i].BoundsRect) Then Begin
      br := true;
    End;
    // Wir Ermitteln die Geringste Distanz zu einem der Monitore
    d := sqr(form.Left + form.Width Div 2 - (screen.Monitors[i].Left + screen.Monitors[i].Width Div 2)) +
      sqr(form.Top + form.Height Div 2 - (screen.Monitors[i].Top + screen.Monitors[i].Height Div 2));
    If d < md Then Begin
      md := d;
      m := i;
    End;
  End;
  // Wenn auch nur eine Ecke nicht mehr auf Wenigstens einem Monitor ist
  // Rücken wir das Formular wieder rein
  If (Not tl) Or (Not tr) Or (Not bl) Or (Not br) Then Begin
    // Wir Zentrieren Das Formular auf dem Monitor md
    form.left := Screen.Monitors[m].Left + (Screen.Monitors[m].Width - form.Width) Div 2;
    form.Top := Screen.Monitors[m].Top + (Screen.Monitors[m].Height - form.Height) Div 2;
  End;
End;

Function GetWorkDir(Out Directory: String): Boolean;
Begin
  result := false;
  Try
    Directory := IncludeTrailingPathDelimiter(GetTempDir(false)) + 'CCM_Temp';
    If Not DirectoryExistsUTF8(Directory) Then Begin
      If Not ForceDirectoriesUTF8(Directory) Then Begin
        showmessage(format(RF_Error_could_not_create, [Directory]));
        exit;
      End;
    End;
    Directory := IncludeTrailingPathDelimiter(Directory);
    // Todo: Prüfen ob man hier tatsächlich Schreibrechte hat, Wenn nicht Knallts aber sowieso ;)
    result := true;
  Except
  End;
End;

Function GetMapCacheDir(): String;
Begin
  result := IncludeTrailingPathDelimiter(GetAppConfigDir(false)) + 'maptilecache' + PathDelim;
  If Not DirectoryExistsUTF8(result) Then Begin
    If Not ForceDirectoriesUTF8(result) Then Begin
      showmessage(format(RF_Error_could_not_create, [result]));
      exit;
    End;
  End;
End;

Function GetDataBaseDir(): String;
Begin
  // Default
  result := IncludeTrailingPathDelimiter(GetAppConfigDir(false)) + 'databases';
  // Evtl durch User Überschrieben
  result := GetValue('General', 'Databases', result);
  // Sicherstellen das der Pathdelim als letztes kommt
  result := IncludeTrailingPathDelimiter(result);
  If Not DirectoryExistsUTF8(result) Then Begin
    If Not ForceDirectoriesUTF8(result) Then Begin
      showmessage(format(RF_Error_could_not_create, [result]));
      exit;
    End;
  End;
End;

Function GetDownloadsDir(): String;
Begin
  // Default
  result := IncludeTrailingPathDelimiter(GetAppConfigDir(false)) + 'downloads';
  // Sicherstellen das der Pathdelim als letztes kommt
  result := IncludeTrailingPathDelimiter(result);
  If Not DirectoryExistsUTF8(result) Then Begin
    If Not ForceDirectoriesUTF8(result) Then Begin
      showmessage(format(RF_Error_could_not_create, [result]));
      exit;
    End;
  End;
End;

Function GetSpoilersDir(): String;
Begin
  // Default
  result := IncludeTrailingPathDelimiter(GetAppConfigDir(false)) + 'spoilers';
  // Sicherstellen das der Pathdelim als letztes kommt
  result := IncludeTrailingPathDelimiter(result);
  If Not DirectoryExistsUTF8(result) Then Begin
    If Not ForceDirectoriesUTF8(result) Then Begin
      showmessage(format(RF_Error_could_not_create, [result]));
      exit;
    End;
  End;
End;

Function GetImagesDir(): String;
Begin
  result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0))) + 'images' + PathDelim;
End;

Function ResolveDirectory(Dir, varpromptDirectory: String): String;
Begin
  result := dir;
  If LowerCase(trim(dir)) = '$workdir$' Then GetWorkDir(result);
  If lowercase(trim(dir)) = '$importdir$' Then result := GetValue('General', 'LastImportDir', '');
  If lowercase(trim(dir)) = '$promptdir$' Then result := varpromptDirectory;
End;

Function GetAttribImage(Attrib: integer; AttrActive: Boolean): TBitmap;
Var
  Filenamebase: String;
  b: Tbitmap;
Begin
  Filenamebase := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0))) + 'images' + PathDelim + 'attr_';
  result := TBitmap.Create;
  result.TransparentColor := clFuchsia;
  result.Transparent := true;
  If FileExistsUTF8(Filenamebase + inttostr(attrib) + '.bmp') Then Begin
    result.LoadFromFile(Filenamebase + inttostr(attrib) + '.bmp');
  End
  Else Begin
    // Das Angefragte Attribut haben wir nicht, also zeigen wir es als Nummer an.
    result.Width := 30;
    result.Height := 30;
    result.Canvas.Rectangle(0, 0, 30, 30);
    result.Canvas.TextOut(0, 0, inttostr(Attrib));
    exit; // Raus, damit die "Nicht" Textur auf keinen Fall überlagert, so kann man die Zahl besser lesen..
  End;
  If Not AttrActive Then Begin
    b := TBitmap.Create;
    b.LoadFromFile(Filenamebase + 'not.bmp');
    b.TransparentColor := clFuchsia;
    b.Transparent := true;
    result.Canvas.Draw(0, 0, b);
    b.free;
  End;
End;

Function PosRev(Const Substr, s: String): integer;
Var
  intSubStrLen: Integer;
  i: Integer;
Begin
  result := 0;
  intSubStrLen := Length(SubStr);
  If (intSubStrLen < 1) Then Exit;
  For i := Length(s) + 1 Downto 1 Do Begin
    If (I - intSubStrLen < 1) Then Exit;
    If (Copy(s, I - intSubStrLen, intSubStrLen) = SubStr) Then Begin
      Result := I - intSubStrLen;
      Exit;
    End;
  End;
End;

Function LocatePoiExportFilderIndex(Folder: String): integer;
Var
  i, c: integer;
Begin
  result := -1;
  c := strtoint(getvalue('GPSPOI', 'Count', '0'));
  For i := 0 To c - 1 Do Begin
    If getvalue('GPSPOI', 'Folder' + inttostr(i), '') = Folder Then Begin
      result := i;
      breaK;
    End;
  End;
End;

Procedure OpenCacheInBrowser(GC_Code: String);
Begin
  // Cache URL is broken so use the default method that works always !
  OpenURL(URL_OpenCacheListing + GC_Code);
End;

(*
 * Formatiert TimeInmS als möglich hübsche Zeiteinheit
 *
 * 0ms bis x Tage [ Jahre werden nicht unterstützt da sonst schaltjahre und ettliches mehr berücksichtigt werden müssen
 * 0 => 0ms
 * 500 => 500ms
 * 1000 => 1s
 * 1500 => 1,5s
 * 65000 => 1:05min
 * 80000 => 1:20min
 * 3541000 => 59:01min
 * 3600000 => 1h
 * 3660000 => 1:01h
 * 86400000 => 1d
 * 129600000 => 1d 12h
 * 30762000000 => 356d 1h
 *)

Function PrettyTime(Time_in_ms: UInt64): String;
Var
  hs, digits, sts, sep, s: String;
  st, i: integer;
  b: Boolean;
Begin
  s := 'ms';
  hs := '';
  sep := DefaultFormatSettings.DecimalSeparator;
  st := 0;
  b := false;
  digits := '3';
  // [0 .. 60[ s
  If Time_in_ms >= 1000 Then Begin
    st := Time_in_ms Mod 1000;
    Time_in_ms := Time_in_ms Div 1000;
    s := 's';
    b := true;
  End;
  // [1 .. 60[ min
  If (Time_in_ms >= 60) And b Then Begin
    st := Time_in_ms Mod 60;
    Time_in_ms := Time_in_ms Div 60;
    s := 'min';
    sep := DefaultFormatSettings.TimeSeparator;
    digits := '2';
  End
  Else
    b := false;
  // [1 .. 24[ h
  If (Time_in_ms >= 60) And b Then Begin
    st := Time_in_ms Mod 60;
    Time_in_ms := Time_in_ms Div 60;
    s := 'h';
  End
  Else
    b := false;
  // [1 ..  d
  If (Time_in_ms >= 24) And b Then Begin
    st := Time_in_ms Mod 24;
    Time_in_ms := Time_in_ms Div 24;
    hs := 'd';
    If st <> 0 Then s := 'h';
    sep := ' ';
    digits := '1';
  End
  Else
    b := false;
  // Ausgabe mit oder ohne Nachkomma
  If st <> 0 Then Begin
    sts := format('%0.' + digits + 'd', [st]);
    If (s = 's') Then Begin // Bei Sekunden die endenden 0-en löschen
      For i := length(sts) Downto 1 Do Begin
        If sts[i] = '0' Then Begin
          delete(sts, i, 1);
        End
        Else Begin
          break;
        End;
      End;
    End;
    result := inttostr(Time_in_ms) + hs + sep + sts + s;
  End
  Else Begin
    result := inttostr(Time_in_ms) + s;
  End;
End;

Function LocateImportGeocacheVisitsIndex(Filename: String): integer;
Var
  i, c: integer;
Begin
  result := -1;
  c := strtoint(getvalue('GPSImport', 'Count', '0'));
  For i := 0 To c - 1 Do Begin
    If getvalue('GPSImport', 'Filename' + inttostr(i), '') = Filename Then Begin
      result := i;
      breaK;
    End;
  End;
End;

Function LocateExportSpoilerIndex(Folder: String): integer;
Var
  i, c: integer;
Begin
  result := -1;
  c := strtoint(getvalue('GPSSpoilerExport', 'Count', '0'));
  For i := 0 To c - 1 Do Begin
    If getvalue('GPSSpoilerExport', 'Folder' + inttostr(i), '') = Folder Then Begin
      result := i;
      breaK;
    End;
  End;
End;

Function GetIndexOfLocation(Location: String; ShowWarningIfNotFound: Boolean
  ): integer;
Var
  i: Integer;
Begin
  result := -1;
  For i := 0 To strtointdef(getValue('Locations', 'Count', '0'), 0) - 1 Do Begin
    If GetValue('Locations', 'Name' + inttostr(i), '') = Location Then Begin
      result := i;
      exit;
    End;
  End;
  If ShowWarningIfNotFound Then Begin
    showmessage(format(RF_Could_not_locate_location_Did_you_really_added_it_first, [Location]));
  End;
End;

Function LocateGPSExportIndex(Folder: String): integer;
Var
  i, c: integer;
Begin
  result := -1;
  c := strtoint(getvalue('GPSExport', 'Count', '0'));
  For i := 0 To c - 1 Do Begin
    If getvalue('GPSExport', 'Folder' + inttostr(i), '') = Folder Then Begin
      result := i;
      breaK;
    End;
  End;
End;

Procedure FormShowModal(Const ModalForm, SenderForm: TForm);
Begin
  (*
   * Auf manchen Plattformen / Fenstermanagern funktionieren Modale Fenster nicht wie gewünscht.
   * Diese Routine bildet ein ModalForm.Showmodal nach, ohne jedoch ein Modales Fenster an zu zeigen
   *)
  ModalForm.ModalResult := mrnone;
{$IFDEF NoShowModal}
  // Modales Fenster öffnen und warten bis es geschlossen wird
  ModalForm.show;
  // Sendendes Formular Sperren
  If assigned(SenderForm) Then Begin
    SenderForm.Enabled := false;
    SenderForm.SetFocusedControl(ModalForm);
  End;
  While (ModalForm.ModalResult = mrNone) And (ModalForm.Visible) Do Begin
    Application.ProcessMessages;
    sleep(1);
  End;
  // Sendendes Formular wieder Freigeben
  If assigned(SenderForm) Then Begin
    SenderForm.Enabled := true;
  End;
  // Wurde ein Modalresult setzendes Element gedrückt, schliesen wir das Formular Händisch
  If ModalForm.Visible Then Begin
    ModalForm.Hide;
  End;
  If assigned(Senderform) Then Begin
    SenderForm.BringToFront;
    SenderForm.SetFocus;
    SenderForm.SetFocusedControl(SenderForm);
  End;
  // Application.BringToFront; -- Das bringt jedesmal die Form1 nach vorn, wenn Senderform aber <> form1 ist, dann ist das schlecht.
{$ELSE}
  ModalForm.showmodal;
{$IFEND}
End;

Procedure GetDBList(Const List: TStrings; ExcludeDB: String);

  Procedure QuickList(li, re: integer);
  Var
    l, r: Integer;
    t, p: String;
  Begin
    If Li < Re Then Begin
      p := List[Trunc((li + re) / 2)]; // Auslesen des Pivo Elementes
      l := Li;
      r := re;
      While l < r Do Begin
        While CompareStr(lowercase(List[l]), lowercase(p)) < 0 Do
          inc(l);
        While CompareStr(lowercase(List[r]), lowercase(p)) > 0 Do
          dec(r);
        If L <= R Then Begin
          t := List[l];
          List[l] := List[r];
          List[r] := t;
          inc(l);
          dec(r);
        End;
      End;
      QuickList(li, r);
      QuickList(l, re);
    End;
  End;

Var
  sl: tstringlist;
  i: integer;
  s, p: String;
Begin
  list.Clear;
  p := GetDataBaseDir();
  If Not DirectoryExistsutf8(p) Then Begin
    If Not CreateDirUTF8(p) Then Begin
      exit;
    End;
  End;
  sl := FindAllFiles(p, '*.db', false);
  For i := 0 To sl.count - 1 Do Begin
    If (ExcludeDB = '') Or (ExcludeDB <> ExtractFileNameOnly(sl[i])) Then Begin
      s := ExtractFileNameOnly(sl[i]) + ' (' + getValue('DB_Statistics', DataBaseNameToIniString(sl[i]), '?') + ')';
      list.Add(s);
    End;
  End;
  QuickList(0, list.count - 1);
  sl.free;
End;

Function RemoveCacheCountInfo(DB_Name: String): String;
Begin
  If pos('(', DB_Name) <> 0 Then Begin
    // <DB_name> (*) -> <DB_name>
    result := trim(copy(DB_Name, 1, PosRev('(', DB_Name) - 1)); // Abschneiden der gesamt Cachezahl
  End
  Else Begin
    result := DB_Name;
  End;
End;

Function convert_dimension(vmin, vmax, v: Single; rmin, rmax: integer): integer;
Begin
  If (vmax - vmin = 0) Then Begin // Div by 0 abfangen
    result := rmin;
    exit;
  End
  Else Begin
    result := round((((v - vmin) * (rmax - rmin)) / (vmax - vmin)) + rmin);
  End;
End;

Function HTMLStringToString(Value: String): String;
Begin
  result := StringReplace(value, '<br>', LineEnding, [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(result, '&auml;', 'ä', [rfReplaceAll]);
  result := StringReplace(result, '&ouml;', 'ö', [rfReplaceAll]);
  result := StringReplace(result, '&uuml;', 'ü', [rfReplaceAll]);
  result := StringReplace(result, '&Auml;', 'Ä', [rfReplaceAll]);
  result := StringReplace(result, '&Ouml;', 'Ö', [rfReplaceAll]);
  result := StringReplace(result, '&Uuml;', 'Ü', [rfReplaceAll]);
  result := StringReplace(result, '&nbsp;', ' ', [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(result, '&amp;', '&', [rfReplaceAll]);
End;

Function StringToHTMLString(Value: String): String;
Begin
  result := StringReplace(value, LineEnding, '<br>', [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(result, 'ä', '&auml;', [rfReplaceAll]);
  result := StringReplace(result, 'ö', '&ouml;', [rfReplaceAll]);
  result := StringReplace(result, 'ü', '&uuml;', [rfReplaceAll]);
  result := StringReplace(result, 'Ä', '&Auml;', [rfReplaceAll]);
  result := StringReplace(result, 'Ö', '&Ouml;', [rfReplaceAll]);
  result := StringReplace(result, 'Ü', '&Uuml;', [rfReplaceAll]);
  result := StringReplace(result, ' ', '&nbsp;', [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(result, '&', '&amp;', [rfReplaceAll]);
End;

// TODO: Prüfen inwiefern das identisch zu: ScanDateTime aus dateutil.pas ist

Function StrToDateTimeFormat(Input, Format: String): TDateTime;
Var
  y, m, d, h, n, s, z: String;
  ip, fp: integer;
  Block: Boolean;
Begin
  Result := -1; // beruhigt den Compiler, ..
  Try
    (*
     * Die Idee ist den Input String gemäß dem Format String zu Parsen und alle
     * Formatstring Tokens in den einzelnen Container zu sammeln.
     * Dann wird Konvertiert und mittels anschließender Rückkonvertierung
     * geprüft ob alles geklappt hat *g*.
     *)
    // Der Formatstring muss mindestens so lang sein wie der Eingabestring.
    If length(Format) < length(Input) Then Begin
      Result := -1;
      exit;
    End;
    y := '';
    m := '';
    d := '';
    h := '';
    n := '';
    s := '';
    z := '';
    Block := FALSE;
    Format := lowercase(Format);
    ip := 1;
    fp := 1;
    While fp <= length(Format) Do Begin
      If Block Then Begin
        If Format[fp] = '''' Then Begin
          Block := FALSE;
          inc(fp);
        End
        Else Begin
          inc(fp);
          inc(ip);
        End;
      End
      Else Begin
        Case Format[fp] Of
          '''': Begin
              Block := true;
              dec(ip);
            End;
          'y': y := y + Input[ip];
          'm': m := m + Input[ip];
          'd': d := d + Input[ip];
          'h': h := h + Input[ip];
          'n': n := n + Input[ip];
          's': s := s + Input[ip];
          'z': z := z + Input[ip];
        End;
        inc(fp);
        inc(ip);
      End;
    End;
    // Sind die yy Daten nur als zweistellige Zahl vorhanden, dann auf 2000+ verschieben
    If strtointdef(y, 0) < 2000 Then Begin
      y := IntToStr(strtointdef(y, 0) + 2000);
    End;
    Try
      If (y = '2000') And (m = '') And (d = '') Then Begin
        Result := EncodeTime(strtointdef(h, 0), strtointdef(n, 0), strtointdef(s, 0), strtointdef(z, 0));
      End
      Else Begin
        Result := EncodeDate(strtointdef(y, 0), strtointdef(m, 0), strtointdef(d, 0)) + EncodeTime(strtointdef(h, 0), strtointdef(n, 0), strtointdef(s, 0), strtointdef(z, 0));
      End;
    Except
      Result := -1;
      exit;
    End;
    // Wenn alles geklappt hat, muss sich die Inverse wieder bilden lassen ;)
    // z := FormatDateTime(Format, Result); -- Zum Debuggen
    If lowercase(FormatDateTime(Format, Result)) <> lowercase(Input) Then Begin
      Result := -1;
    End;
  Except
    result := -1;
  End;
End;

Function StrToTime(value: String): TDateTime;
Var
  s: String;
Begin
  (*
   * Step 1: Value so umwandeln, dass es dem unten liegenden Format string angepasst ist.
   *)
  If length(value) = 0 Then Begin
    result := -1;
    exit;
  End;
  // Bei Manchen Datensätzen stehen die ms noch mit dran
  If pos('.', value) <> 0 Then Begin
    value := copy(value, 1, pos('.', value) - 1);
  End;
  // Bei Manchen Datensätzen ist noch eine Zeitverschiebung mit angegeben -> die werfen wir mal dezent weg ..
  If pos('+', value) <> 0 Then Begin
    value := copy(value, 1, pos('+', value) - 1);
  End;
  // Bei Manchen Datensätzen, fehlt hinten das ss (z.B. wenn man exakt zur Vollen Minute geloggt hat)
  s := copy(value, pos(':', value) + 1, length(value));
  If pos(':', s) = 0 Then Begin // das : muss 2 mal vorkommen => der SS Teil ist 00
    If pos('Z', value) = 0 Then Begin
      value := value + ':00';
    End
    Else Begin
      insert(':00', value, length(value)); //Anfügen der Sekunden
    End;
  End;
  // Manche Datensätze haben hinten das Z nicht, also reparieren wir mal *g*.
  If (lowercase(value[length(value)]) <> 'z') Then value := value + 'Z';
  (*
   * Step 2: die eigentliche convertierung
   *)
  result := StrToDateTimeFormat(value, 'YYYY-MM-DD''T''HH:NN:SS''Z''');
End;

Function GetTime(datetime: TDatetime): String;
Begin
  result := FormatDateTime('YYYY-MM-DD', datetime) + 'T' + FormatDateTime('HH:NN:SS', datetime) + 'Z';
End;

Procedure NewDocGPX(Out Doc: TXMLDocument; Out gpx: TDOMNode);
Begin
  Doc := TXMLDocument.Create;
  gpx := Doc.CreateElement('gpx');
  TDOMElement(gpx).SetAttribute('creator', 'CCM');
  TDOMElement(gpx).SetAttribute('version', version);
  TDOMElement(gpx).SetAttribute('xmlns', 'http://www.topografix.com/GPX/1/0');
  AddTag(Doc, gpx, 'name', 'Cache Listing from CCM');
  AddTag(Doc, gpx, 'desc', 'Cache Listing from CCM');
  AddTag(Doc, gpx, 'author', 'Corpsman Cache Manager');
  AddTag(Doc, gpx, 'email', 'support@corpsman.de');
  AddTag(Doc, gpx, 'url', 'http://www.corpsman.de');
  AddTag(Doc, gpx, 'urlname', 'CCM Link');
  AddTag(Doc, gpx, 'time', GetTime(now));
End;

// Quelle : http://www.gocacher.de/garmin-gps-unterstutzten-nun-spoiler-fotos/

Function TransferSpoilerImage(SpoilerRootDir, CacheName, Filename: String
  ): Boolean;
Var
  Folder, Destname: String;
Begin
  result := false;
  // Done: Laut Weblink mus man da noch den Unterordner \Spoilers mit anlegen, sollte das hier auch gemacht werden ?
  Folder := IncludeTrailingPathDelimiter(SpoilerRootDir) + 'GeocachePhotos' + PathDelim + CacheName[Length(CacheName)] + PathDelim + CacheName[Length(CacheName) - 1] + PathDelim + CacheName + PathDelim;
  If Not ForceDirectoriesUTF8(Folder) Then exit;
  DestName := ExtractFileName(Filename);
  // Die Länge der Dateinamen beschränken auf 11 Zeichen
  If length(DestName) > 15 Then Begin
    destname := copy(Destname, 1, 11) + ExtractFileExt(Destname);
  End;
  If FileExistsUTF8(Folder + DestName) Then Begin
    // Datei gibt es schon, nichts mehr Kopieren
    result := True;
  End
  Else Begin
    result := CopyFile(Filename, Folder + DestName);
  End;
End;

Function ColumnExistsInTable(ColumnName, TableName: String): Boolean;
Begin
  result := usqlite_helper.ColumnExistsInTable(SQLQuery, ColumnName, TableName);
End;

Function ColumnExistsInTBTable(ColumnName, TableName: String): Boolean;
Begin
  result := usqlite_helper.ColumnExistsInTable(TB_SQLQuery, ColumnName, TableName);
End;

Function GetAllColumsFromTable(TableName: String): TStringlist;
Begin
  result := usqlite_helper.GetAllColumsFromTable(SQLQuery, TableName);
End;

Function TB_StartSQLQuery(Query: String): Boolean;
Var
  u: String;
Begin
  Query := RemoveCommentFromSQLQuery(Query);
  u := GetValue('General', 'Username', '');
  Query := StringReplace(query, '%username%', u, [rfIgnoreCase, rfReplaceAll]);
  result := usqlite_helper.StartSQLQuery(tb_SQLQuery, Query);
End;

Function StartSQLQuery(Query: String): Boolean;
Var
  u: String;
Begin
  Query := RemoveCommentFromSQLQuery(Query);
  u := GetValue('General', 'Username', '');
  Query := StringReplace(query, '%username%', u, [rfIgnoreCase, rfReplaceAll]);
  result := usqlite_helper.StartSQLQuery(SQLQuery, Query);
End;

(*
 * Using : Call CommitSQLTransactionQuery as many times you want.
 *         Write your results to the database by
 *         SQLTransaction.Commit;
 *)

Function TB_CommitSQLTransactionQuery(aText: String): Boolean;
Var
  u: String;
Begin
  result := false;
  u := GetValue('General', 'Username', '');
  aText := StringReplace(aText, '%username%', u, [rfIgnoreCase, rfReplaceAll]);
  result := usqlite_helper.CommitSQLTransactionQuery(tb_SQLQuery, aText, Nil);
  If Not result Then Begin
    tb_SQLTransaction.Rollback;
  End;
End;

Function CommitSQLTransactionQuery(aText: String): Boolean;
Var
  u: String;
Begin
  u := GetValue('General', 'Username', '');
  aText := StringReplace(aText, '%username%', u, [rfIgnoreCase, rfReplaceAll]);
  result := usqlite_helper.CommitSQLTransactionQuery(SQLQuery, aText, Nil);
  If Not result Then Begin
    SQLTransaction.Rollback;
  End;
End;

Function CacheFromDB(GC_Code: String; Skip_Attributes: Boolean): TCache;
Var
  c: integer;
Begin
  result.GC_Code := '';
  result.Waypoints := Nil;
  If trim(GC_Code) = '' Then exit;
  StartSQLQuery(
    'Select ' + // Exakt die gleiche Reihenfolge wie in der Tabellendeklaration ;)
    'c.lat' +
    ', c.lon' +
    ', c.cor_lat' +
    ', c.cor_lon' +
    ', c.time' +
    //  ', c.name' + -- Nach dem wird ja Selektiert
    ', c.desc' +
    ', c.url' +
    ', c.url_name' +
    ', c.sym' +
    ', c.type' +
    ', c.note' + // -- Die Persöhnlichen Notizen
    ', c.lite' +
    ', c.Fav' +
    ', c.g_id' +
    ', c.G_AVAILABLE' +
    ', c.G_ARCHIVED' +
    //    ', c.G_NEED_ARCHIVED' +
    ', c.G_Found' +
    ', c.G_XMLNS' +
    ', c.G_NAME' +
    ', c.G_PLACED_BY' +
    ', c.G_OWNER_ID' +
    ', c.G_OWNER' +
    ', c.G_TYPE' +
    ', c.G_CONTAINER' +
    ', c.G_DIFFICULTY' +
    ', c.G_TERRAIN' +
    ', c.G_COUNTRY' +
    ', c.G_STATE' +
    ', c.G_SHORT_DESCRIPTION' +
    ', c.G_SHORT_DESCRIPTION_HTML' +
    ', c.G_LONG_DESCRIPTION ' +
    ', c.G_LONG_DESCRIPTION_HTML' +
    ', c.G_ENCODED_HINTS' +
    ' from caches c where c.name = "' + GC_Code + '"');
  If SQLQuery.EOF Then exit;
  // Die Cache Grunddaten
  result.Lat := SQLQuery.Fields[0].AsFloat;
  result.Lon := SQLQuery.Fields[1].AsFloat;
  result.Cor_Lat := SQLQuery.Fields[2].AsFloat;
  result.Cor_Lon := SQLQuery.Fields[3].AsFloat;
  result.Time := FromSQLString(SQLQuery.Fields[4].AsString);
  result.GC_Code := GC_Code;
  result.Desc := FromSQLString(SQLQuery.Fields[5].AsString);
  result.url := FromSQLString(SQLQuery.Fields[6].AsString);
  result.URL_Name := FromSQLString(SQLQuery.Fields[7].AsString);
  result.Sym := FromSQLString(SQLQuery.Fields[8].AsString);
  result.Type_ := FromSQLString(SQLQuery.Fields[9].AsString);
  result.Note := FromSQLString(SQLQuery.Fields[10].AsString);
  result.Lite := SQLQuery.Fields[11].AsBoolean;
  result.Fav := SQLQuery.Fields[12].AsInteger;
  result.G_ID := SQLQuery.Fields[13].AsInteger;
  result.G_Available := SQLQuery.Fields[14].AsBoolean;
  result.G_Archived := SQLQuery.Fields[15].AsBoolean;
  result.Customer_Flag := 0;
  result.G_Found := SQLQuery.Fields[16].AsInteger;
  result.G_XMLNs := FromSQLString(SQLQuery.Fields[17].AsString);
  result.G_Name := FromSQLString(SQLQuery.Fields[18].AsString);
  result.G_Placed_By := FromSQLString(SQLQuery.Fields[19].AsString);
  result.G_Owner_ID := SQLQuery.Fields[20].AsInteger;
  result.G_Owner := FromSQLString(SQLQuery.Fields[21].AsString);
  result.G_Type := FromSQLString(SQLQuery.Fields[22].AsString);
  result.G_Container := FromSQLString(SQLQuery.Fields[23].AsString);
  result.G_Difficulty := SQLQuery.Fields[24].AsFloat;
  result.G_Terrain := SQLQuery.Fields[25].AsFloat;
  result.G_Country := FromSQLString(SQLQuery.Fields[26].AsString);
  result.G_State := FromSQLString(SQLQuery.Fields[27].AsString);
  result.G_Short_Description := FromSQLString(SQLQuery.Fields[28].AsString);
  result.G_Short_Description_HTML := SQLQuery.Fields[29].AsBoolean;
  result.G_Long_Description := FromSQLString(SQLQuery.Fields[30].AsString);
  result.G_Long_Description_HTML := SQLQuery.Fields[31].AsBoolean;
  result.G_Encoded_Hints := FromSQLString(SQLQuery.Fields[32].AsString);
  // Logs
  StartSQLQuery(
    'Select ' +
    // 'CacheName' + -- Nach dem wird ja Selektiert
    'id' +
    ', date' +
    ', type' +
    ', finder_id' +
    ', finder' +
    ', text_encoded' +
    ', log_text' +
    ' from logs where cache_name = "' + GC_Code + '" order by date desc');
  c := 0;
  setlength(Result.Logs, 100);
  While Not SQLQuery.EOF Do Begin
    result.Logs[c].id := SQLQuery.Fields[0].AsInteger;
    result.Logs[c].date := FromSQLString(SQLQuery.Fields[1].AsString);
    result.Logs[c].Type_ := FromSQLString(SQLQuery.Fields[2].AsString);
    result.Logs[c].Finder_ID := SQLQuery.Fields[3].AsInteger;
    result.Logs[c].Finder := FromSQLString(SQLQuery.Fields[4].AsString);
    result.Logs[c].Text_Encoded := SQLQuery.Fields[5].AsBoolean;
    result.Logs[c].Log_Text := FromSQLString(SQLQuery.Fields[6].AsString);
    inc(c);
    If c > high(result.logs) Then Begin
      setlength(Result.Logs, high(Result.Logs) + 101);
    End;
    SQLQuery.Next;
  End;
  setlength(Result.Logs, c);
  // Attribute
  If Not Skip_Attributes Then Begin
    StartSQLQuery(
      'Select ' +
      // 'Cache_Name' + -- Nach dem wird ja Selektiert
      'id' +
      ', inc' +
      ', attribute_text' +
      ' from attributes where cache_name = "' + GC_Code + '"');
    c := 0;
    setlength(Result.G_Attributes, 100);
    While Not SQLQuery.EOF Do Begin
      result.G_Attributes[c].id := SQLQuery.Fields[0].AsInteger;
      result.G_Attributes[c].inc := SQLQuery.Fields[1].AsInteger;
      result.G_Attributes[c].Attribute_Text := FromSQLString(SQLQuery.Fields[2].AsString);
      inc(c);
      If c > high(result.G_Attributes) Then Begin
        setlength(Result.G_Attributes, high(Result.G_Attributes) + 101);
      End;
      SQLQuery.Next;
    End;
    setlength(Result.G_Attributes, c);
  End
  Else Begin
    Result.G_Attributes := Nil;
  End;
End;

Function WaypointsFromDB(GC_Code: String): TWaypointList;
Var
  c: integer;
Begin
  c := 0;
  result := Nil;
  setlength(result, 100);
  StartSQLQuery(
    'Select ' +
    // 'CacheName' + -- Nach dem wird ja Selektiert
    'name' +
    ', time' +
    ', lat' +
    ', lon' +
    ', cmt' +
    ', desc' +
    ', url' +
    ', url_name' +
    ', sym' +
    ', type' +
    ' from waypoints where Cache_name = "' + GC_Code + '"');
  While Not SQLQuery.EOF Do Begin
    result[c].GC_Code := GC_Code;
    result[c].Name := FromSQLString(SQLQuery.Fields[0].AsString);
    result[c].Time := FromSQLString(SQLQuery.Fields[1].AsString);
    result[c].lat := SQLQuery.Fields[2].AsFloat;
    result[c].Lon := SQLQuery.Fields[3].AsFloat;
    result[c].cmt := FromSQLString(SQLQuery.Fields[4].AsString);
    result[c].desc := FromSQLString(SQLQuery.Fields[5].AsString);
    result[c].url := FromSQLString(SQLQuery.Fields[6].AsString);
    result[c].url_name := FromSQLString(SQLQuery.Fields[7].AsString);
    result[c].sym := FromSQLString(SQLQuery.Fields[8].AsString);
    result[c].Type_ := FromSQLString(SQLQuery.Fields[9].AsString);
    inc(c);
    If c > high(result) Then Begin
      setlength(Result, high(Result) + 101);
    End;
    SQLQuery.Next;
  End;
  setlength(Result, c);
End;

Procedure DelCache(GC_Code: String);
Var
  Folder: String;
Begin
  // Löschen Aus DB
  CommitSQLTransactionQuery('Delete from caches where name="' + GC_Code + '"');
  CommitSQLTransactionQuery('Delete from waypoints where CACHE_NAME="' + GC_Code + '"');
  CommitSQLTransactionQuery('Delete from logs where CACHE_NAME="' + GC_Code + '"');
  CommitSQLTransactionQuery('Delete from attributes where CACHE_NAME="' + GC_Code + '"');
  SQLTransaction.Commit;
  // Löschen aus Spoiler Verzeichniss
  folder := GetSpoilersDir() + GC_Code + PathDelim;
  If DirectoryExistsUTF8(Folder) Then Begin
    DeleteDirectory(folder, false);
  End;
End;

Procedure DelWaypoint(wp: TWaypoint);
Begin
  CommitSQLTransactionQuery('Delete from waypoints where CACHE_NAME="' + wp.GC_Code + '" and name="' + wp.Name + '"');
  SQLTransaction.Commit;
End;

Function AddTag(Const doc: TXMLDocument; ParentNode: TDOMNode; TagName,
  Value: String): TDOMNode;
Var
  n, c: TDOMNode;
Begin
  n := doc.CreateElement(tagname);
  c := doc.CreateTextNode(Value);
  n.AppendChild(c);
  ParentNode.AppendChild(n);
  result := n;
End;

Function GetTag(ParentNode: TDOMNode; TagName: String): String;
Var
  tmp: TDOMNode;
Begin
  result := '';
  tmp := ParentNode.FindNode(TagName);
  If assigned(tmp) And assigned(tmp.FirstChild) Then Begin
    result := tmp.FirstChild.NodeValue;
  End;
End;

Function GetTagAttrib(ParentNode: TDOMNode; TagName, AttribName: String): String;
Var
  n, tmp: TDOMNode;
Begin
  result := '';
  tmp := ParentNode.FindNode(TagName);
  If assigned(tmp) Then Begin
    n := tmp.Attributes.GetNamedItem(AttribName);
    If assigned(n) Then Begin
      result := n.NodeValue;
    End
    Else Begin
      result := '';
    End;
  End;
End;

Function LoadWPTTag(Node: TDOMNode; Out Waypoint: TWaypoint): Boolean;
Begin
  result := false;
  Waypoint.Lat := strtofloat(Node.Attributes.GetNamedItem('lat').NodeValue, DefFormat);
  Waypoint.Lon := strtofloat(Node.Attributes.GetNamedItem('lon').NodeValue, DefFormat);
  Waypoint.Time := GetTag(Node, 'time');
  Waypoint.Name := GetTag(Node, 'name');
  If length(Waypoint.Name) < 3 Then exit;
  Waypoint.GC_Code := 'GC' + copy(Waypoint.Name, 3, length(Waypoint.Name));
  Waypoint.cmt := GetTag(Node, 'cmt');
  Waypoint.Desc := GetTag(Node, 'desc');
  Waypoint.URL := GetTag(Node, 'url');
  Waypoint.URL_Name := GetTag(Node, 'urlname');
  Waypoint.Sym := GetTag(Node, 'sym');
  If Waypoint.sym = 'Original Coordinates' Then Begin
    Waypoint.Sym := POI_Types[3].Sym; // Als Referenzpunkt
    If trim(Waypoint.cmt) = '' Then Begin
      Waypoint.cmt := 'Original Coordinates';
    End
    Else Begin
      Waypoint.cmt := 'Original Coordinates' + LineEnding + Waypoint.cmt;
    End;
  End;
  Waypoint.type_ := GetTag(Node, 'type');
  result := true;
End;

Function LoadWPTTag(Node: TDOMNode; Out Cache: TCache): Boolean;

  Function LoadLogTag(Node: TDOMNode): TLog;
  Begin
    result.id := strtointdef(node.Attributes.GetNamedItem('id').NodeValue, 0); // Wenn die Log ID-Nicht stimmt ist uns das Egal
    result.date := GetTag(node, 'groundspeak:date');
    result.Type_ := GetTag(node, 'groundspeak:type');
    result.Finder := GetTag(node, 'groundspeak:finder');
    result.Finder_ID := strtointdef(GetTagAttrib(node, 'groundspeak:finder', 'id'), 0);
    result.Text_Encoded := lowercase(GetTagAttrib(node, 'groundspeak:text', 'encoded')) = 'true';
    result.Log_Text := GetTag(node, 'groundspeak:text');
  End;

Var
  n, gsc, gsa, logs: TDOMNode;
  off, i: Integer;
  fav, gsaknote, latbef, lonbef: String;
  olat, olon: Double;
  log: TLog;
Begin
  result := false;
  cache.Lat := strtofloat(Node.Attributes.GetNamedItem('lat').NodeValue, DefFormat);
  cache.Lon := strtofloat(Node.Attributes.GetNamedItem('lon').NodeValue, DefFormat);
  cache.Cor_Lat := -1; // Initialisieren mit nicht Modifizierten Koordinaten
  cache.Cor_Lon := -1; // Initialisieren mit nicht Modifizierten Koordinaten
  cache.note := ''; // Initialisieren mit keine Note
  cache.Lite := false;
  cache.Fav := 0;
  cache.Waypoints := Nil;
  gsc := Node.FindNode('gsak:wptExtension');
  If Not assigned(gsc) Then Begin // Manchmal sind die GSAK Informationen in einem untertag namens "Extensions"
    gsc := node.FindNode('extensions');
    If assigned(gsc) Then Begin
      gsc := gsc.FindNode('gsak:wptExtension');
    End;
  End;
  // Ein Cache von GSAK, der Informationen über modifikationen hat ->  Dann übernehmen wir diese auch.
  If assigned(gsc) Then Begin
    latbef := GetTag(gsc, 'gsak:LatBeforeCorrect');
    If latbef <> '' Then Begin
      lonbef := GetTag(gsc, 'gsak:LonBeforeCorrect');
      If lonbef <> '' Then Begin
        // Da GSAK, genau wie CCM die Modifizierten Koords als "echte" ausgibt, wir das intern aber
        // genau andersrum speichern muss das entsprechend gedreht abgelegt werden.
        olat := strtofloatdef(latbef, -1, DefFormat);
        olon := strtofloatdef(lonbef, -1, DefFormat);
        If (olat <> -1) And (olon <> -1) Then Begin // Manchmal speichert GSAK aber auch Müll, dann lassen wir's wie's ist ;)
          cache.Cor_Lat := cache.Lat;
          cache.Cor_Lon := cache.Lon;
          cache.Lat := olat;
          cache.Lon := olon;
        End;
      End;
    End;
    // Wenn die GSAK Erweiterung einen Kommentar rein gemacht hat, dann lesen wir den mal als Note mit..
    gsaknote := getTag(gsc, 'gsak:GcNote');
    If gsaknote <> '' Then Begin
      cache.Note := cache.Note + gsaknote;
    End;
    fav := getTag(gsc, 'gsak:FavPoints');
    If fav <> '' Then Begin
      cache.Fav := strtointdef(fav, 0);
    End;
  End;
  cache.Time := GetTag(Node, 'time');
  cache.GC_Code := GetTag(Node, 'name');
  cache.Desc := GetTag(Node, 'desc');
  cache.URL := GetTag(Node, 'url');
  cache.URL_Name := GetTag(Node, 'urlname');
  cache.Sym := GetTag(Node, 'sym');
  cache.type_ := GetTag(Node, 'type');
  gsc := Node.FindNode('groundspeak:cache');
  If Not assigned(gsc) Then Begin // Manchmal sind die GSAK Informationen in einem untertag namens "Extensions"
    gsc := node.FindNode('extensions');
    If assigned(gsc) Then Begin
      gsc := gsc.FindNode('groundspeak:cache');
    End;
  End;
  If Not assigned(gsc) Then Begin
    exit;
  End;
  cache.G_ID := strtointdef(gsc.Attributes.GetNamedItem('id').NodeValue, -1);
  If cache.G_ID = -1 Then Begin // das Importieren hat nicht geklappt
    cache.G_ID := 0;
    gsaknote := lowercase(gsc.Attributes.GetNamedItem('id').NodeValue);
    If pos('gc', gsaknote) = 1 Then Begin // Es handelt sich offensichtlich um einen GC-Code also berechnen wir die ID einfach geschwind.
      cache.G_ID := GCCodeToGCiD(gsaknote);
    End;
  End;
  cache.G_Available := lowercase(gsc.Attributes.GetNamedItem('available').NodeValue) = 'true';
  cache.G_Archived := lowercase(gsc.Attributes.GetNamedItem('archived').NodeValue) = 'true';
  //cache.G_Need_Archived := false;
  cache.G_Found := 0; // Initialisieren mit nicht gefunden
  n := gsc.Attributes.GetNamedItem('xmlns:groundspeak');
  If assigned(n) Then Begin
    cache.G_XMLNs := n.NodeValue;
  End
  Else Begin
    cache.G_XMLNs := ''; // Gibt wohl keine XML Def..
  End;
  cache.g_Name := GetTag(gsc, 'groundspeak:name');
  cache.G_Placed_By := GetTag(gsc, 'placed_by');
  cache.G_Type := GetTag(gsc, 'groundspeak:type');
  (*
   * Manche Caches werden "Komisch" getypt, das wird gleich im Keim erledigt.
   *)
  If lowercase(trim(cache.G_Type)) = 'unknown (mystery) cache' Then Begin
    cache.G_Type := Unknown_Cache;
  End;
  If lowercase(trim(cache.G_Type)) = 'wherigo caches' Then Begin
    cache.G_Type := Wherigo_Cache;
  End;
  cache.G_Owner_ID := strtointdef(GetTagAttrib(gsc, 'groundspeak:owner', 'id'), 0);
  cache.G_Owner := GetTag(gsc, 'groundspeak:owner');
  cache.G_Container := GetTag(gsc, 'groundspeak:container');
  gsa := gsc.FindNode('groundspeak:attributes');
  If assigned(gsa) Then Begin
    setlength(Cache.G_Attributes, gsa.ChildNodes.count);
    For i := 0 To gsa.ChildNodes.count - 1 Do Begin
      Cache.G_Attributes[i].id := strtoint(gsa.ChildNodes[i].Attributes.GetNamedItem('id').NodeValue);
      Cache.G_Attributes[i].inc := strtoint(gsa.ChildNodes[i].Attributes.GetNamedItem('inc').NodeValue);
      If assigned(gsa.ChildNodes[i].FirstChild) Then Begin // Opencaching.de hat nicht immer alle Attribute gelabeled
        Cache.G_Attributes[i].Attribute_Text := gsa.ChildNodes[i].FirstChild.NodeValue;
      End
      Else Begin
        Cache.G_Attributes[i].Attribute_Text := '';
      End;
    End;
  End
  Else Begin
    setlength(Cache.G_Attributes, 0);
  End;
  cache.G_Difficulty := strtofloat(GetTag(gsc, 'groundspeak:difficulty'), DefFormat);
  cache.G_Terrain := strtofloat(GetTag(gsc, 'groundspeak:terrain'), DefFormat);
  cache.G_Country := GetTag(gsc, 'groundspeak:country');
  cache.G_State := GetTag(gsc, 'groundspeak:state');
  cache.G_Short_Description := GetTag(gsc, 'groundspeak:short_description');
  cache.G_Short_Description_HTML := lowercase(GetTagAttrib(gsc, 'groundspeak:short_description', 'html')) = 'true';
  cache.G_Long_Description := GetTag(gsc, 'groundspeak:long_description');
  cache.G_Long_Description_HTML := lowercase(GetTagAttrib(gsc, 'groundspeak:long_description', 'html')) = 'true';
  cache.G_Encoded_Hints := GetTag(gsc, 'groundspeak:encoded_hints');
  logs := gsc.FindNode('groundspeak:logs');
  If assigned(logs) Then Begin
    off := 0;
    setlength(cache.logs, logs.ChildNodes.Count);
    For i := 0 To logs.ChildNodes.Count - 1 Do Begin
      log := LoadLogTag(logs.ChildNodes[i]);
      // Ist der Log eine GSAK Field Note, dann übernehmen wir das in unser Note System
      If (log.Finder_ID = 0) And (log.Finder = 'GSAK') Then Begin
        If cache.note <> '' Then Begin
          cache.Note := cache.Note + LineEnding + trim(log.Log_Text);
        End
        Else Begin
          cache.Note := trim(log.Log_Text);
        End;
        inc(off);
      End
      Else Begin
        Cache.logs[i - off] := log;
      End;
    End;
    If off <> 0 Then Begin
      setlength(cache.logs, logs.ChildNodes.Count - off);
    End;
  End
  Else Begin
    setlength(cache.logs, 0);
  End;
  // Todo : Laden der Travelbugs..
  result := true;
End;

Function WaypointToDB(Const Waypoint: TWaypoint; ForceUpdateLogsAttribs: Boolean
  ): Boolean;
Begin
  result := false;
  StartSQLQuery('Select count(*) from caches where name = "' + Waypoint.GC_Code + '";');
  If SQLQuery.Fields[0].AsInteger = 0 Then exit; // Wieso nen Wegpunkt einfügen, wenns keinen Cache dazu gibt ?
  StartSQLQuery('Select count(*) from waypoints where name = "' + ToSQLString(Waypoint.Name) + '" and CACHE_NAME = "' + Waypoint.GC_Code + '";');
  If SQLQuery.Fields[0].AsInteger = 0 Then Begin
    // Den Wegpunkt gibt es noch nicht
    // Den Log gibt es noch nicht
    CommitSQLTransactionQuery('Insert into waypoints (Name, Cache_name, time, Lat, lon, cmt, desc, url, url_name, sym, type) values (' +
      '"' + ToSQLString(Waypoint.Name) + '" ' +
      ', "' + Waypoint.GC_Code + '" ' +
      ', "' + ToSQLString(Waypoint.Time) + '" ' +
      ', ' + floattostr(Waypoint.lat, DefFormat) + ' ' +
      ', ' + floattostr(Waypoint.Lon, DefFormat) + ' ' +
      ', "' + ToSQLString(Waypoint.cmt) + '" ' +
      ', "' + ToSQLString(Waypoint.desc) + '" ' +
      ', "' + ToSQLString(Waypoint.url) + '" ' +
      ', "' + ToSQLString(Waypoint.url_name) + '" ' +
      ', "' + ToSQLString(Waypoint.sym) + '" ' +
      ', "' + ToSQLString(Waypoint.Type_) + '" ' +
      ');');
  End
  Else Begin
    // Der Wegpunkt existiert schon
    If ForceUpdateLogsAttribs Then Begin
      CommitSQLTransactionQuery('Update waypoints ' +
        'set time="' + ToSQLString(Waypoint.Time) + '" ' +
        ', lat=' + floattostr(Waypoint.lat, DefFormat) + ' ' +
        ', lon=' + floattostr(Waypoint.Lon, DefFormat) + ' ' +
        ', cmt="' + ToSQLString(Waypoint.cmt) + '" ' +
        ', desc="' + ToSQLString(Waypoint.desc) + '" ' +
        ', url="' + ToSQLString(Waypoint.url) + '" ' +
        ', url_name="' + ToSQLString(Waypoint.url_name) + '" ' +
        ', sym="' + ToSQLString(Waypoint.sym) + '" ' +
        ', type="' + ToSQLString(Waypoint.Type_) + '" ' +
        'where name = "' + ToSQLString(Waypoint.Name) + '" and CACHE_NAME = "' + Waypoint.GC_Code + '";');
    End;
  End;
  result := true;
End;

Function CacheToDB(Var Cache: TCache; ForceUpdateLogsAttribs,
  ResetIfNotInDB: Boolean): Boolean;

  Procedure QuickLogs(li, re: integer);
  Var
    l, r, p: Integer;
    t: TLog;
  Begin
    If Li < Re Then Begin
      p := Cache.Logs[Trunc((li + re) / 2)].id; // Auslesen des Pivo Elementes
      l := Li;
      r := re;
      While l < r Do Begin
        While Cache.Logs[l].id < p Do
          inc(l);
        While Cache.Logs[r].id > p Do
          dec(r);
        If L <= R Then Begin
          t := Cache.Logs[l];
          Cache.Logs[l] := Cache.Logs[r];
          Cache.Logs[r] := t;
          inc(l);
          dec(r);
        End;
      End;
      QuickLogs(li, r);
      QuickLogs(l, re);
    End;
  End;

  Procedure QuickAttributes(li, re: integer);
  Var
    l, r, p: Integer;
    t: TAttribute;
  Begin
    If Li < Re Then Begin
      p := Cache.G_Attributes[Trunc((li + re) / 2)].id; // Auslesen des Pivo Elementes
      l := Li;
      r := re;
      While l < r Do Begin
        While Cache.G_Attributes[l].id < p Do
          inc(l);
        While Cache.G_Attributes[r].id > p Do
          dec(r);
        If L <= R Then Begin
          t := Cache.G_Attributes[l];
          Cache.G_Attributes[l] := Cache.G_Attributes[r];
          Cache.G_Attributes[r] := t;
          inc(l);
          dec(r);
        End;
      End;
      QuickAttributes(li, r);
      QuickAttributes(l, re);
    End;
  End;

Var
  FoundVal, c, i, j: Integer;
  ids: Array Of Record
    id: integer;
    log: String;
  End;
  s: String;
  b: Boolean;
  lat, lon: double;
Begin
  result := false;
  FoundVal := 0;
  (*
   * Wenn wir nen Lab-Cache Importieren wirds kompliziert, denn diese haben in der Regel keine Gültigen Cache namen
   *)
  If ((lowercase(cache.G_Type) = lowercase(Geocache_Lab_Cache))
    Or (lowercase(cache.G_Type) = lowercase(Lab_Cache)) {And (length(Cache.GC_Code) > 9) -- Lab-Caches müssen immer geeignet Signiert werden !}
    ) Then Begin
    cache.G_Type := Geocache_Lab_Cache; // Sicherstellen, dass der Cachetyp nachher auch stimmt.
    b := true;
    // erst mal Schaun ob wir den Cache evtl. schon in der Datenbank haben, da aber der Primärschlüssel hinüber ist, müssen wir das anders versuchen
    // Wir suchen also nach g_Name und der Distanz zur Location
    StartSQLQuery('select c.name, c.lat, c.lon, cor_lat, cor_lon from caches c where c.G_NAME="' + ToSQLString(cache.G_Name) + '"'
      + ' And ((c.lat - ' + floattostr(Cache.Lat, DefFormat) + ')*(c.lat - ' + floattostr(Cache.Lat, DefFormat) + ')) + ((c.lon - ' + floattostr(Cache.Lon, DefFormat) + ')*(c.lon - ' + floattostr(Cache.Lon, DefFormat) + ')) <= 0.001'
      );
    If Not SQLQuery.EOF Then Begin
      For i := 0 To SQLQuery.RecordCount - 1 Do Begin
        lat := SQLQuery.Fields[3].AsFloat;
        lon := SQLQuery.Fields[4].AsFloat;
        If (lat = -1) Or (lon = -1) Then Begin
          lat := SQLQuery.Fields[1].AsFloat;
          lon := SQLQuery.Fields[2].AsFloat;
        End;
        If distance2(cache.Lat, cache.Lon, lat, lon) <= 5 Then Begin
          cache.GC_Code := SQLQuery.Fields[0].AsString;
          b := false;
        End;
      End;
    End;
    // Suchen eines neuen Namens für den Cache
    While b Do Begin
      cache.GC_Code := 'LAB_' + inttostr(RandomRange(10000, 99999)); // Todo: bei 90000 Labcaches in der DB Knallts hier.
      StartSQLQuery('select count(*) from caches where name="' + cache.GC_Code + '"');
      b := SQLQuery.Fields[0].AsInteger <> 0;
    End;
  End;
  // Nur Caches Hinzufügen, in deren Logs wir nicht drin stehen
  s := GetValue('General', 'UserName', '');
  If (s <> '') Then Begin
    If GetValue('General', 'DontImportFoundCaches', '1') = '1' Then Begin
      StartSQLQuery('select count(*) from logs where cache_name="' + cache.GC_Code + '" and finder="' + s + '" and type = "Found it"');
      If SQLQuery.Fields[0].AsInteger <> 0 Then Begin
        exit; // Den Cache haben wir bereits gefunden, und er ist eh schon in der Datenbank => nicht mehr importieren
      End;
      StartSQLQuery('select g_found from caches where name="' + cache.GC_Code + '"');
      If SQLQuery.Fields[0].AsInteger = 1 Then Begin
        exit; // Den Cache haben wir bereits gefunden, und er ist eh schon in der Datenbank => nicht mehr importieren
      End;
    End
    Else Begin
      // Den Cache haben wir schon gefunden, sollen ihn aber trotzdem importieren, also markieren wir ihn nun als gefunden.
      StartSQLQuery('select count(*) from logs where cache_name="' + cache.GC_Code + '" and finder="' + s + '" and type = "Found it"');
      If SQLQuery.Fields[0].AsInteger <> 0 Then Begin
        FoundVal := 1;
      End;
      If FoundVal = 0 Then Begin
        // Evtl ist in den Logs der Fund, die müssen auch durchsucht werden
        For i := 0 To high(Cache.Logs) Do Begin
          If (lowercase(Cache.Logs[i].Finder) = lowercase(s)) And (Cache.Logs[i].Type_ = 'Found it') Then Begin
            FoundVal := 1;
            break;
          End;
        End;
      End;
    End;
  End;

  // 1. Eintragen in die SQL-Tabelle
  StartSQLQuery('select count(*), cor_lat, cor_lon, note, G_Found, fav from caches where name="' + cache.GC_Code + '";');
  If SQLQuery.Fields[0].AsInteger = 0 Then Begin
    // 1.1 Den Cache gibt es noch nicht also nen Dummy Anlegen
    CommitSQLTransactionQuery('Insert into caches (name, cor_lat, cor_lon, Customer_Flag) values ("' + Cache.GC_Code + '", "", "", 0);');
    If ResetIfNotInDB Then Begin
      // cache.Cor_Lat := -1; -- Wenn der Cache Korrigierte Koords hat nehmen wir die mit ..
      // cache.Cor_Lon := -1; -- Wenn der Cache Korrigierte Koords hat nehmen wir die mit ..
      // cache.Note := ''; // -- Die Notizen sind z.B. beim Import aus GSAK durchaus interessant ..
      cache.G_found := FoundVal;
    End;
  End
  Else Begin
    // Den Cache gibt es schon, also werden seine Korrigierten Koordinaten übernommen
    // Wenn der Cache überhaupt Korrigierte Koordinaten hat, andernfalls
    // Werden die Koordinaten übernommen, mit welchen der Cache Rein Kam
    If SQLQuery.Fields[1].AsFloat <> -1 Then Begin
      cache.Cor_Lat := SQLQuery.Fields[1].AsFloat;
      cache.Cor_Lon := SQLQuery.Fields[2].AsFloat;
    End;
    If trim(cache.note) = '' Then Begin // Wenn der Cache schon eine Note hat, dann wird diese beibehalten, sonst kommt die note aus der DB zum Zug
      cache.Note := FromSQLString(SQLQuery.Fields[3].AsString);
    End;
    cache.G_found := FoundVal;
    // Der Cache hat keine Favs definiert, aber evtl die Datenbank, das sollte dann nicht überschrieben werden
    If cache.Fav <= 0 Then Begin
      cache.fav := SQLQuery.Fields[5].AsInteger;
    End;
    // Wenn wir einen Lite Cache auf einen Nicht Lite Cache Schreiben wollen,
    // würde der ja alles Kaputt machen => der wird nicht angefügt
    If Cache.Lite Then Begin
      // Sollte der Lite Cache aber Korrigierte Koords haben, und wir noch keine, dann übernehmen wir diese
      If (SQLQuery.Fields[1].AsFloat = -1) And (cache.Cor_Lat <> -1) And (cache.Cor_Lon <> -1) Then Begin
        CommitSQLTransactionQuery('Update caches ' +
          'set cor_lat=' + FloatToStr(cache.Cor_Lat, DefFormat) + ' ' +
          ', cor_lon=' + FloatToStr(cache.Cor_Lon, DefFormat) + ' ' +
          ', fav=' + inttostr(cache.Fav) + ' ' +
          'where name = "' + Cache.GC_Code + '";');
        result := true;
      End
      Else Begin
        // Die Dose hat vielleicht keine Korrigierten Koords, aber die Favs sind <> 0 also werden sie übernommen
        If (cache.fav > 0) And (cache.fav <> SQLQuery.Fields[5].AsInteger) Then Begin
          CommitSQLTransactionQuery('Update caches ' +
            'set fav=' + inttostr(cache.Fav) + ' ' +
            'where name = "' + Cache.GC_Code + '";');
          result := true;
        End;
      End;
      // Wir können bei Lite Caches immer Raus, da diese keine Attribute haben (Logs haben sie zwar aber die Ignorieren wir)
      exit;
    End;
  End;
  // 1.2 Den Cache gibt es schon, also alles Updaten
  CommitSQLTransactionQuery('Update caches ' +
    'set lat=' + FloatToStr(cache.Lat, DefFormat) + ' ' +
    ', lon=' + FloatToStr(cache.Lon, DefFormat) + ' ' +
    ', cor_lat=' + FloatToStr(cache.Cor_Lat, DefFormat) + ' ' +
    ', cor_lon=' + FloatToStr(cache.Cor_Lon, DefFormat) + ' ' +
    ', time="' + ToSQLString(cache.Time) + '" ' +
    ', desc="' + ToSQLString(cache.Desc) + '" ' +
    ', URL="' + ToSQLString(cache.URL) + '" ' +
    ', URL_Name="' + ToSQLString(cache.URL_Name) + '" ' +
    ', Sym="' + ToSQLString(cache.Sym) + '" ' +
    ', Type="' + ToSQLString(cache.Type_) + '" ' +
    ', Note="' + ToSQLString(cache.Note) + '" ' +
    //', Customer_Flag=0 ' + // Sollte der Cache Schon existieren und das Customer Flag besitzen, wird dieses bei behalten
    ', Lite=' + inttostr(ord(cache.Lite)) + ' ' +
    ', Fav=' + inttostr(cache.Fav) + ' ' +
    ', G_ID=' + inttostr(cache.G_ID) + ' ' +
    ', G_AVAILABLE=' + inttostr(ord(cache.G_Available)) + ' ' +
    ', G_ARCHIVED=' + inttostr(ord(cache.G_Archived)) + ' ' +
    ', G_NEED_ARCHIVED=0 ' + // markieren als Aktualisiert / bzw vorhanden.
    ', G_Found=' + inttostr(ord(cache.G_Found)) + ' ' +
    ', G_XMLNS="' + ToSQLString(cache.G_XMLNs) + '" ' +
    ', G_NAME="' + ToSQLString(cache.G_Name) + '" ' +
    ', G_PLACED_BY="' + ToSQLString(cache.G_Placed_By) + '" ' +
    ', G_OWNER_ID=' + inttostr(cache.G_Owner_ID) + ' ' +
    ', G_OWNER="' + ToSQLString(cache.G_Owner) + '" ' +
    ', G_TYPE="' + ToSQLString(cache.G_Type) + '" ' +
    ', G_CONTAINER="' + ToSQLString(cache.G_Container) + '" ' +
    ', G_DIFFICULTY=' + floattostr(cache.G_Difficulty, DefFormat) + ' ' +
    ', G_TERRAIN=' + floattostr(cache.G_Terrain, DefFormat) + ' ' +
    ', G_COUNTRY="' + ToSQLString(cache.G_Country) + '" ' +
    ', G_STATE="' + ToSQLString(cache.G_State) + '" ' +
    ', G_SHORT_DESCRIPTION="' + ToSQLString(cache.G_Short_Description) + '" ' +
    ', G_SHORT_DESCRIPTION_HTML=' + inttostr(ord(cache.G_Short_Description_HTML)) + ' ' +
    ', G_LONG_DESCRIPTION="' + ToSQLString(cache.G_Long_Description) + '" ' +
    ', G_LONG_DESCRIPTION_HTML=' + inttostr(ord(cache.G_Long_Description_HTML)) + ' ' +
    ', G_ENCODED_HINTS="' + ToSQLString(cache.G_Encoded_Hints) + '" ' +
    'where name = "' + Cache.GC_Code + '";');

  // TODO: Der Zeitfresser scheinen die Inserts der logs und Attribute zu sein, gibt es hier noch "Optimierungspotential" ?
  // 2. Eintragen der Logs
  // 2.1 Erst mal ne Liste Aller Logs für den Cache hohlen
  If assigned(cache.Logs) Then Begin // Hat der Cache keine Logs, dann machen wir nichts
    StartSQLQuery('Select id, log_text from logs where cache_name  = "' + cache.GC_Code + '" order by id asc;');
    c := 0;
    ids := Nil;
    setlength(ids, 1024);
    While Not SQLQuery.EOF Do Begin
      ids[c].id := SQLQuery.Fields[0].AsInteger;
      ids[c].log := FromSQLString(SQLQuery.Fields[1].AsString);
      inc(c);
      If c > high(ids) Then Begin
        setlength(ids, high(ids) + 1025);
      End;
      SQLQuery.Next;
    End;
    setlength(ids, c);
    QuickLogs(0, high(cache.Logs));
    c := 0;
    // Nun vergleichen wir via Platou Suche welche Logs wir schon haben und welche nicht, nur neue werden hinzugefügt, existierende werden "gemerkt"
    For i := 0 To high(Cache.Logs) Do Begin
      While (c < high(ids)) And (Cache.Logs[i].id < ids[c].id) Do
        inc(c);
      c := min(high(ids), c);
      If assigned(ids) And (ids[c].id = Cache.Logs[i].id) Then Begin
        // Den Log gibt es schon, dann Braucht er nicht eingefügt werden
        ids[c].id := 0;
        If ForceUpdateLogsAttribs Or (Cache.Logs[i].Log_Text <> ids[c].log) Then Begin
          CommitSQLTransactionQuery('Update logs ' +
            'set date="' + ToSQLString(cache.Logs[i].date) + '" ' +
            ', type="' + ToSQLString(cache.Logs[i].Type_) + '" ' +
            ', Finder_id=' + inttostr(cache.Logs[i].Finder_ID) + ' ' +
            ', Finder="' + ToSQLString(cache.Logs[i].Finder) + '" ' +
            ', Text_Encoded=' + inttostr(ord(cache.Logs[i].Text_Encoded)) + ' ' +
            ', Log_text="' + ToSQLString(cache.Logs[i].Log_Text) + '" ' +
            'where Cache_Name = "' + Cache.GC_Code + '" and id = ' + inttostr(cache.logs[i].id) + ';');
        End;
        inc(c);
      End
      Else Begin
        // Den Log gibt es noch nicht
        CommitSQLTransactionQuery('Insert into logs (Cache_Name, ID, Date, Type, Finder_id, Finder, Text_Encoded, Log_text) values (' +
          '"' + Cache.GC_Code + '" ' +
          ', ' + inttostr(cache.Logs[i].id) + ' ' +
          ', "' + ToSQLString(cache.Logs[i].date) + '" ' +
          ', "' + ToSQLString(cache.Logs[i].Type_) + '" ' +
          ', ' + inttostr(cache.Logs[i].Finder_ID) + ' ' +
          ', "' + ToSQLString(cache.Logs[i].Finder) + '" ' +
          ', ' + inttostr(ord(cache.Logs[i].Text_Encoded)) + ' ' +
          ', "' + ToSQLString(cache.Logs[i].Log_Text) + '" ' +
          ');');
      End;
    End;
    // Löschen evtl veralteter Log Einträge
    For j := 0 To high(ids) Do Begin
      If ids[j].id <> 0 Then Begin
        CommitSQLTransactionQuery('delete from logs ' +
          'where cache_name = "' + Cache.GC_Code + '" and id = ' + inttostr(ids[j].id) + ';');
      End;
    End;
  End;

  // 3. Eintragen der Attribute
  // 3.1 Erst mal ne Liste Aller Attribute für den Cache hohlen
  If assigned(cache.G_Attributes) Then Begin // Hat der Cache keine Attribute, dann machen wir nichts
    StartSQLQuery('Select id from attributes where cache_name  = "' + cache.GC_Code + '" order by id asc;');
    c := 0;
    setlength(ids, 1024);
    While Not SQLQuery.EOF Do Begin
      ids[c].id := SQLQuery.Fields[0].AsInteger;
      ids[c].log := '';
      inc(c);
      If c > high(ids) Then Begin
        setlength(ids, high(ids) + 1025);
      End;
      SQLQuery.Next;
    End;
    setlength(ids, c);
    QuickAttributes(0, high(cache.G_Attributes));
    c := 0;
    // Nun vergleichen wir via Platou Suche welche Attribute wir schon haben und welche nicht, nur neue werden hinzugefügt, existierende werden "gemerkt"
    For i := 0 To high(Cache.G_Attributes) Do Begin
      While (c < high(ids)) And (Cache.G_Attributes[i].id < ids[c].id) Do
        inc(c);
      c := min(high(ids), c);
      If assigned(ids) And (ids[c].id = Cache.G_Attributes[i].id) Then Begin
        // Den Log gibt es schon, dann Braucht er nicht eingefügt werden
        ids[c].id := 0;
        If ForceUpdateLogsAttribs Then Begin
          CommitSQLTransactionQuery('Update attributes ' +
            'set inc=' + inttostr(cache.G_Attributes[i].inc) + ' ' +
            ', ATTRIBUTE_TEXT="' + ToSQLString(cache.G_Attributes[i].Attribute_Text) + '" ' +
            'where Cache_Name = "' + Cache.GC_Code + '" and id = ' + inttostr(cache.G_Attributes[i].id) + ';');
        End;
        inc(c);
      End
      Else Begin
        // Das Attribut gibt es noch nicht
        CommitSQLTransactionQuery('Insert into attributes (Cache_Name, ID, inc, ATTRIBUTE_TEXT) values (' +
          '"' + Cache.GC_Code + '" ' +
          ', ' + inttostr(cache.G_Attributes[i].id) + ' ' +
          ', ' + inttostr(cache.G_Attributes[i].inc) + ' ' +
          ', "' + ToSQLString(cache.G_Attributes[i].Attribute_Text) + '" ' +
          ');');
      End;
    End;
    // Löschen evtl. veralteter Attribut Einträge
    For j := 0 To high(ids) Do Begin
      If ids[j].id <> 0 Then Begin
        CommitSQLTransactionQuery('delete from attributes ' +
          'where cache_name = "' + Cache.GC_Code + '" and id = ' + inttostr(ids[j].id) + ';');
      End;
    End;
    setlength(ids, 0);
  End;
  // Todo : 4. Eintragen der Trackables
  // 5. Hinzufügen der Wegpunkte
  If assigned(Cache.Waypoints) Then Begin
    For j := 0 To high(Cache.Waypoints) Do Begin
      If (cache.G_Type = Geocache_Lab_Cache) Then Begin
        Cache.Waypoints[j].GC_Code := cache.GC_Code;
      End;
      WaypointToDB(Cache.Waypoints[j], ForceUpdateLogsAttribs);
    End;
  End;
  result := true;
End;

Function CacheToDBUnchecked(Var Cache: TCache): Boolean;
Var
  i: Integer;
Begin
  result := false;
  // Der Eigentliche Cache
  // Todo: Hier scheint das Customer Flag zu fehlen, ist eh 0 in dem Fall, aber sollte schon rein, ..
  CommitSQLTransactionQuery('Insert into caches (' +
    'name, lat, lon, cor_lat, cor_lon, time, desc, URL, URL_Name, Sym, Type, Note, Lite, Fav, ' +
    'G_ID, G_AVAILABLE, G_ARCHIVED, G_NEED_ARCHIVED, G_Found, G_XMLNS, G_NAME, G_PLACED_BY, ' +
    'G_OWNER_ID, G_OWNER, G_TYPE, G_CONTAINER, G_DIFFICULTY, G_TERRAIN, G_COUNTRY, G_STATE, ' +
    'G_SHORT_DESCRIPTION, G_SHORT_DESCRIPTION_HTML, G_LONG_DESCRIPTION, G_LONG_DESCRIPTION_HTML, ' +
    'G_ENCODED_HINTS' +
    ') values (' +
    '"' + Cache.GC_Code + '",' +
    '"' + FloatToStr(cache.Lat, DefFormat) + '", ' +
    '"' + FloatToStr(cache.Lon, DefFormat) + '", ' +
    '"' + FloatToStr(cache.Cor_Lat, DefFormat) + '", ' +
    '"' + FloatToStr(cache.Cor_Lon, DefFormat) + '", ' +
    '"' + ToSQLString(cache.Time) + '", ' +
    '"' + ToSQLString(cache.Desc) + '", ' +
    '"' + ToSQLString(cache.URL) + '", ' +
    '"' + ToSQLString(cache.URL_Name) + '", ' +
    '"' + ToSQLString(cache.Sym) + '", ' +
    '"' + ToSQLString(cache.Type_) + '", ' +
    '"' + ToSQLString(cache.Note) + '", ' +
    '"' + inttostr(ord(cache.Lite)) + '", ' +
    '"' + inttostr(cache.Fav) + '", ' +
    '"' + inttostr(cache.G_ID) + '", ' +
    '"' + inttostr(ord(cache.G_Available)) + '", ' +
    '"' + inttostr(ord(cache.G_Archived)) + '", ' +
    '"0", ' + // markieren als Aktualisiert / bzw vorhanden.
    '"' + inttostr(ord(cache.G_Found)) + '", ' +
    '"' + ToSQLString(cache.G_XMLNs) + '", ' +
    '"' + ToSQLString(cache.G_Name) + '", ' +
    '"' + ToSQLString(cache.G_Placed_By) + '", ' +
    '"' + inttostr(cache.G_Owner_ID) + '", ' +
    '"' + ToSQLString(cache.G_Owner) + '", ' +
    '"' + ToSQLString(cache.G_Type) + '", ' +
    '"' + ToSQLString(cache.G_Container) + '", ' +
    '"' + floattostr(cache.G_Difficulty, DefFormat) + '", ' +
    '"' + floattostr(cache.G_Terrain, DefFormat) + '", ' +
    '"' + ToSQLString(cache.G_Country) + '", ' +
    '"' + ToSQLString(cache.G_State) + '", ' +
    '"' + ToSQLString(cache.G_Short_Description) + '", ' +
    '"' + inttostr(ord(cache.G_Short_Description_HTML)) + '", ' +
    '"' + ToSQLString(cache.G_Long_Description) + '", ' +
    '"' + inttostr(ord(cache.G_Long_Description_HTML)) + '", ' +
    '"' + ToSQLString(cache.G_Encoded_Hints) + '" ' +
    ');');
  // Die Logs des Cache
  For i := 0 To high(Cache.Logs) Do Begin
    CommitSQLTransactionQuery('Insert into logs (Cache_Name, ID, Date, Type, Finder_id, Finder, Text_Encoded, Log_text) values (' +
      '"' + Cache.GC_Code + '" ' +
      ', ' + inttostr(cache.Logs[i].id) + ' ' +
      ', "' + ToSQLString(cache.Logs[i].date) + '" ' +
      ', "' + ToSQLString(cache.Logs[i].Type_) + '" ' +
      ', ' + inttostr(cache.Logs[i].Finder_ID) + ' ' +
      ', "' + ToSQLString(cache.Logs[i].Finder) + '" ' +
      ', ' + inttostr(ord(cache.Logs[i].Text_Encoded)) + ' ' +
      ', "' + ToSQLString(cache.Logs[i].Log_Text) + '" ' +
      ');');
  End;
  For i := 0 To high(Cache.G_Attributes) Do Begin
    CommitSQLTransactionQuery('Insert into attributes (Cache_Name, ID, inc, ATTRIBUTE_TEXT) values (' +
      '"' + Cache.GC_Code + '" ' +
      ', ' + inttostr(cache.G_Attributes[i].id) + ' ' +
      ', ' + inttostr(cache.G_Attributes[i].inc) + ' ' +
      ', "' + ToSQLString(cache.G_Attributes[i].Attribute_Text) + '" ' +
      ');');
  End;
  // Todo : 4. Eintragen der Trackables
  // 5. Hinzufügen der Wegpunkte
  If assigned(Cache.Waypoints) Then Begin
    For i := 0 To high(Cache.Waypoints) Do Begin
      WaypointToDB(Cache.Waypoints[i]);
    End;
  End;
  result := true;
End;

Function ImportGPXFile(Filename: String): integer;
Var
  Doc: TXMLDocument;
  wpt, gpx: TDOMNode;
  Cache: TCache;
  Waypoint: TWaypoint;
  wpts: integer;
Begin
  result := 0;
  wpts := 0;
  If assigned(RefresStatsMethod) Then
    RefresStatsMethod(filename, result, wpts, true);
  // 1. Laden des Caches
  doc := TXMLDocument.Create;
  Try
    ReadXMLFile(doc, Filename);
  Except
    result := 0;
    doc.free;
    exit;
  End;
  gpx := doc.FindNode('gpx');
  If Not assigned(gpx) Then Begin
    doc.free;
    exit;
  End;
  wpt := gpx.FindNode('wpt');
  If Not assigned(wpt) Then Begin
    doc.free;
    exit;
  End;
  If Not LoadWPTTag(wpt, cache) Then Begin
    doc.free;
    exit;
  End;
  // 2. Eintragen des Caches in die Datenbank
  If Not CacheToDB(cache, false, true) Then Begin
    doc.free;
    exit;
  End;
  If GetValue('General', 'DeleteImportedFiles', '0') = '1' Then Begin
    DeleteFileUTF8(Filename);
  End;
  SQLTransaction.Commit;
  result := 1;
  // 3. Eintragen aller Wegpunkte des Caches
  wpt := wpt.NextSibling;
  While assigned(wpt) Do Begin
    If LoadWPTTag(wpt, Waypoint) Then Begin
      If WaypointToDB(Waypoint, true) Then Begin
        inc(wpts);
        If wpts Mod 5 = 0 Then Begin
          If assigned(RefresStatsMethod) Then
            If RefresStatsMethod(filename, result, wpts, false) Then Begin
              result := 0;
              doc.free;
              exit;
            End;
        End;
      End
      Else Begin
        // Wenn der Wegpunkt nicht geadded werden kann ist es evtl ein Cache
        If pos('GC', uppercase(Waypoint.Name)) = 1 Then Begin
          If LoadWPTTag(wpt, cache) Then Begin
            inc(result);
            CacheToDB(cache, false, true);
            If result Mod 5 = 0 Then Begin
              If assigned(RefresStatsMethod) Then
                If RefresStatsMethod(filename, result, wpts, false) Then Begin
                  result := 0;
                  doc.free;
                  exit;
                End;
            End;
          End;
        End;
      End;
    End;
    wpt := wpt.NextSibling;
  End;
  SQLTransaction.Commit;
  doc.free;
End;

Function ImportZIPFile(Filename: String): integer;
Var
  z: TUnZipper;
  folder: String;
  sl: TStringList;
  i: Integer;
  doc: TXMLDocument;
  wpt, gpx: TDOMNode;
  cache: Tcache;
  Waypoint: TWaypoint;
  wpts: integer;
Begin
  result := 0;
  wpts := 0;
  // 1. Zip File Extrahieren
  Folder := IncludeTrailingPathDelimiter(ExtractFilePath(Filename)) + ExtractFileNameOnly(Filename);
  z := TUnZipper.Create;
  z.FileName := Filename;
  z.OutputPath := folder;
  z.Examine;
  z.UnZipAllFiles;
  z.free;
  sl := findallFiles(Folder);
  // 2.1 Alle Caches
  For i := 0 To sl.Count - 1 Do Begin
    If pos('wpts', sl[i]) = 0 Then Begin
      If assigned(RefresStatsMethod) Then Begin
        RefresStatsMethod(sl[i], result, wpts, true);
      End;
      doc := TXMLDocument.Create;
      ReadXMLFile(doc, sl[i]);
      // Eine Liste von Caches
      gpx := doc.FindNode('gpx');
      If assigned(gpx) Then Begin
        wpt := gpx.FindNode('wpt');
      End
      Else Begin
        wpt := Nil;
      End;
      While assigned(wpt) Do Begin
        If LoadWPTTag(wpt, cache) Then Begin
          If CacheToDB(cache, false, true) Then Begin
            inc(result);
            If result Mod 5 = 0 Then Begin
              If assigned(RefresStatsMethod) Then
                If RefresStatsMethod(sl[i], result, wpts, false) Then Begin
                  result := 0;
                  doc.free;
                  exit;
                End;
            End;
          End;
        End
        Else Begin
          // Wenn es kein Cache ist, kann es auch ein Wegpunkt eines anderen Caches sein
          If LoadWPTTag(wpt, Waypoint) Then Begin
            WaypointToDB(Waypoint, true);
          End;
        End;
        wpt := wpt.NextSibling;
      End;
      DeleteFileUTF8(sl[i]);
      doc.free;
    End;
  End;
  SQLTransaction.Commit;

  // 2.2 Alle Wegpunkte
  For i := 0 To sl.Count - 1 Do Begin
    If pos('wpts', sl[i]) <> 0 Then Begin
      If assigned(RefresStatsMethod) Then Begin
        If RefresStatsMethod(sl[i], result, wpts, false) Then Begin
          result := 0;
          exit;
        End;
      End;
      doc := TXMLDocument.Create;
      ReadXMLFile(doc, sl[i]);
      // Eine Liste von Caches
      gpx := doc.FindNode('gpx');
      If assigned(gpx) Then Begin
        wpt := gpx.FindNode('wpt');
      End
      Else Begin
        wpt := Nil;
      End;
      While assigned(wpt) Do Begin
        If LoadWPTTag(wpt, Waypoint) Then Begin
          If WaypointToDB(Waypoint, true) Then Begin
            inc(wpts);
            If wpts Mod 5 = 0 Then Begin
              If assigned(RefresStatsMethod) Then Begin
                If RefresStatsMethod(sl[i], result, wpts, false) Then Begin
                  result := 0;
                  exit;
                End;
              End;
            End;
          End;
        End;
        wpt := wpt.NextSibling;
      End;
      DeleteFileUTF8(sl[i]);
      doc.free;
    End;
  End;
  SQLTransaction.Commit;

  // 3. Verzeichnis und Datei löschen
  DeleteDirectory(folder, false);
  sl.free;
End;

Function ImportNoncheckedGPXFile(Filename: String): integer; // Wie Import Zip, nur ohne entzippen und ohne irgendwelche Datenkonsistenz prüfungen
Var
  doc: TXMLDocument;
  gpx, wpt: TDOMNode;
  cache: TCache;
Begin
  result := 0;
  If pos('wpts', Filename) = 0 Then Begin
    If assigned(RefresStatsMethod) Then Begin
      RefresStatsMethod(Filename, result, 0, true);
    End;
    doc := TXMLDocument.Create;
    ReadXMLFile(doc, Filename);
    // Eine Liste von Caches
    gpx := doc.FindNode('gpx');
    If assigned(gpx) Then Begin
      wpt := gpx.FindNode('wpt');
    End
    Else Begin
      wpt := Nil;
    End;
    While assigned(wpt) Do Begin
      If LoadWPTTag(wpt, cache) Then Begin
        If CacheToDBUnchecked(cache) Then Begin
          inc(result);
          If result Mod 5 = 0 Then Begin
            If assigned(RefresStatsMethod) Then
              If RefresStatsMethod(Filename, result, 0, false) Then Begin
                result := 0;
                doc.free;
                exit;
              End;
          End;
        End;
      End;
      wpt := wpt.NextSibling;
    End;
    SQLTransaction.Commit;
    doc.free;
  End;
End;

Function PrettyKoordToString(Coord: Double; Prefix: String): String;
Var
  p, a, b, c: String;
Begin
  DecodeKoordinate(coord, a, b, c);
  p := Prefix[1];
  If strtoint(a) < 0 Then
    p := Prefix[2];
  result := p + format(' %d° %0.2d.%0.3d', [abs(strtoint(a)), abs(strtoint(b)), abs(strtoint(c))], DefFormat);
End;

Function FilterStringForValidChars(Data: String; Valids: String; Replacer: Char
  ): String; // Filtert aus einem String alle Zeichen raus, welche nicht in Valids enthalten sind.
Var
  i: Integer;
Begin
  result := '';
  For i := 1 To utf8length(data) Do Begin
    If UTF8Pos(UTF8Copy(data, i, 1), valids) <> 0 Then Begin
      result := result + UTF8Copy(data, i, 1);
    End
    Else Begin
      If Replacer <> #0 Then Begin
        result := result + Replacer;
      End;
    End;
  End;
End;

Function CoordToString(Lat, Lon: Double): String;
Begin
  result := PrettyKoordToString(lat, 'NS') + ' ' + PrettyKoordToString(lon, 'EW');
End;

Function SplitStringCoordToLatLon(Coord: String; Out lat: String; Out lon: String): boolean;
Begin
  result := false;
  Coord := Uppercase(Coord);
  If pos('E', Coord) = 0 Then Begin
    If pos('W', coord) = 0 Then exit;
    lat := copy(coord, 1, pos('W', Coord) - 1);
    lon := copy(coord, pos('W', Coord), length(Coord));
  End
  Else Begin
    lat := copy(coord, 1, pos('E', Coord) - 1);
    lon := copy(coord, pos('E', Coord), length(Coord));
  End;
  lat := trim(lat);
  lon := trim(lon);
  result := true;
End;

(*
 * Folgende Eingaben werden erkannt
 *
 * N 48 44 505   -- Trennung via Leerzeichen
 * E 9 12 123    -- Trennung via Leerzeichen
 * N4812123      -- Gar keine Trennung
 * E00912123     -- Gar keine Trennung
 * N 48 12.456   -- Fehlendes °
 * E9 12.345     -- Fehlendes °
 * N48°12 345    -- Fehlendes .
 * N 9°12 345    -- Fehlendes .
 * N 48° 13.123  -- Hübsch Formatiert Alles vorhanden
 * E 9° 3.123    -- Hübsch Formatiert Alles vorhanden
 *
 * Ausgabe ist immer:
 * N48°13.123        -- Trennung via Sonderzeichen ohne Leerzeichen
 *)

Function FixCoordString(Coord: String): String;
Var
  s, i: Integer;
Begin
  result := trim(coord);
  (*
   * Es kann unbeabsichtigt vorkommen, dass zwischen N/E/S/W und der ersten Zahl ein leerzeichzen steht, das schneiden wir hier schon ab sonst functioniert die Erkennung auf "Keine Leerzeichen" evtl nicht.
   *)
  While (length(result) > 1) And (result[2] = ' ') Do Begin
    delete(result, 2, 1);
  End;
  If length(result) = 0 Then Begin
    result := '';
    exit;
  End;
  // Die Fälle Keine Leerzeichen, oder sonstige Formatierungszeichen
  If (pos(' ', result) = 0) And (pos('°', result) = 0) And (pos('.', result) = 0) Then Begin
    If (result[1] In ['E', 'W']) Then Begin
      If length(result) = length('E00913123') Then Begin
        result :=
          copy(result, 1, 4) + '°' +
          copy(result, 5, 2) + '.' +
          copy(result, 7, 3);
      End;
    End
    Else Begin
      If length(result) = length('N4813123') Then Begin
        result :=
          copy(result, 1, 3) + '°' +
          copy(result, 4, 2) + '.' +
          copy(result, 6, 3);
      End;
    End;
  End;
  // Der Fall Leerzeichen anstatt Steuerzeichen
  If pos('°', result) = 0 Then Begin // Fehlendes ° zeichen
    // Wenn wir kein ° haben, dann wird das wohl nach der 1. Zahl kommen
    s := 0;
    For i := 1 To length(result) Do Begin
      Case s Of
        0:
          If (result[i] In ['0'..'9']) Then s := 1; // Finden der 1. Zahl
        1:
          If Not (result[i] In ['0'..'9']) Then Begin
            result := copy(result, 1, i - 1) + '°' + copy(result, i, length(result));
            break;
          End;
      End;
    End;
  End;
  If pos('.', result) = 0 Then Begin // Fehlender .
    // Wenn wir kein . haben, dann wird das wohl nach der 2. Zahl kommen
    s := 0;
    For i := 1 To length(result) Do Begin
      Case s Of
        0:
          If (result[i] In ['0'..'9']) Then s := 1; // Finden der 1. Zahl
        1:
          If Not (result[i] In ['0'..'9']) Then s := 2; // Ende 1. Zahl
        2:
          If (result[i] In ['0'..'9']) Then s := 3; // Finden der 2. Zahl
        3:
          If Not (result[i] In ['0'..'9']) Then Begin // Ende 2. Zahl
            result := copy(result, 1, i - 1) + '.' + copy(result, i, length(result));
            break;
          End;
      End;
    End;
  End;
  // Am Schluss alle Leerzeichen Raus
  result := StringReplace(result, ' ', '', [rfReplaceAll]);
End;

Function StringToCoord(Coord: String; Out Lat: Double; Out lon: Double
  ): Boolean;
Var
  a, b, c, s, slat, slon: String;
  scale: integer;
Begin
  result := false;
  Try
    Coord := Uppercase(Coord);
    coord := StringReplace(coord, #9, ' ', [rfReplaceAll]);
    // So Umbauen, das nur noch die gelisteten Sonderzeichen möglich sind, alles andere wird ' '
    Coord := FilterStringForValidChars(coord, ' NESW0123456789.°', ' ');
    // Splitt der Koordinate in N und E Anteil
    SplitStringCoordToLatLon(Coord, slat, slon); // Der Rückgabe wert muss nicht ausgewertet werden weil das unten noch genauer gemacht wird.
    If (pos('N', slat) = 0) And (pos('S', slat) = 0) Then exit;
    If (pos('E', slon) = 0) And (pos('W', slon) = 0) Then exit;
    // Normieren der Koordinatenstrings
    slat := FixCoordString(slat);
    slon := FixCoordString(slon);
    // Latitude encodieren
    s := slat;
    If s[1] = 'N' Then
      scale := 1
    Else
      scale := -1;
    delete(s, 1, 1);
    a := trim(copy(s, 1, pos('°', s) - 1));
    delete(s, 1, pos('°', s) + 1);
    b := trim(copy(s, 1, pos('.', s) - 1));
    c := trim(copy(s, pos('.', s) + 1, length(s)));
    EncodeKoordinate(lat, inttostr(strtoint(a) * scale), inttostr(strtoint(b) * scale), inttostr(strtoint(c) * scale));
    // Longitude encodieren
    s := slon;
    If s[1] = 'E' Then
      scale := 1
    Else
      scale := -1;
    delete(s, 1, 1);
    a := trim(copy(s, 1, pos('°', s) - 1));
    delete(s, 1, pos('°', s) + 1);
    b := trim(copy(s, 1, pos('.', s) - 1));
    c := trim(copy(s, pos('.', s) + 1, length(s)));
    EncodeKoordinate(lon, inttostr(strtoint(a) * scale), inttostr(strtoint(b) * scale), inttostr(strtoint(c) * scale));
    If (lat <> -1) And (lon <> -1) Then Begin
      result := true;
    End;
  Except
    // Nichts Result ist ja schon false
  End;
End;

Function CompareCoords(Lat1, Lon1, Lat2, Lon2: Double): Boolean;
Var
  c1, c2: String;
Begin
  c1 := CoordToString(lat1, lon1);
  c2 := CoordToString(lat2, lon2);
  result := c1 = c2;
End;

Procedure ProjectCoord(Lat, Lon, alpha, Dist: Double; Out oLat: Double; Out
  oLon: Double);
Const
  EARTH_RADIUS = 6378137;
Var
  cosarg, gamma, a, c: Double;
Begin
  alpha := DegToRad(alpha);
  Lat := DegToRad(Lat);
  Lon := DegToRad(Lon);
  // 0) Entfernung Dist umrechnen in die Dreiecksseite c (Winkel!!).
  c := Dist / EARTH_RADIUS; // (dimensionslose Größe, Winkel im Bogenmaß)
  // 1) Seite a im Kugeldreieck ermitteln
  a := ArcCos(sin(Lat) * cos(c) + cos(Lat) * sin(c) * cos(alpha)); //(dimensionslose Größe, Winkel im Bogenmaß)
  // Daraus geografische Breite des projizierten Punktes
  oLat := pi / 2 - a; // (dimensionslose Größe, Winkel im Bogenmaß)
  // 2) Winkel Gamma ermitteln:
  cosarg := max(-1.0, min(1.0, (cos(c) - cos(a) * sin(Lat)) / sin(a) / cos(Lat))); // Auf Manchen Systemen kommt ein Wert außerhalb [-1.0 .. 1.0] raus, das ist nicht erlaubt.
  gamma := ArcCos(cosarg);
  If alpha < pi Then Begin
    //L2 = L1 + Gamma für Alfa < Pi (dimensionslose Größe, Winkel im Bogenmaß)
    oLon := Lon + gamma;
  End
  Else Begin
    //L2 = L1 – Gamma für Alfa > Pi (dimensionslose Größe, Winkel im Bogenmaß)
    oLon := Lon - gamma;
  End;
  oLat := RadToDeg(oLat);
  oLon := RadToDeg(oLon);
End;

Procedure StringCoordToComboboxEdit(Coord: String; LatCom: tcombobox;
  LatEdit: TEdit; LonCom: tcombobox; LonEdit: TEdit);
Var
  lats, lons: String;
Begin
  If Not SplitStringCoordToLatLon(Coord, lats, lons) Then Begin
    exit;
  End;
  If lats[1] = 'N' Then Begin
    LatCom.ItemIndex := 0;
  End
  Else Begin
    LatCom.ItemIndex := 1;
  End;
  LatEdit.text := trim(copy(lats, 2, length(lats)));

  If lons[1] = 'E' Then Begin
    LonCom.ItemIndex := 0;
  End
  Else Begin
    LonCom.ItemIndex := 1;
  End;
  LonEdit.text := trim(copy(lons, 2, length(lons)));
End;

Function GetConfigFolder(): String;
Begin
  If assigned(ini) Then Begin
    result := ExtractFilePath(ini.FileName);
  End
  Else Begin
    result := '';
  End;
End;

Function GetValue(Section, Ident, Def: String): String;
Begin
  result := def;
  If assigned(ini) Then Begin
    result := ini.ReadString(Section, Ident, Def);
  End;
  If (pos('"', result) = 1) And (length(result) > 2) Then Begin
    If (result[1] = '"') And (result[length(result)] = '"') Then Begin
      result := copy(result, 2, length(Result) - 2);
    End;
  End;
End;

Procedure SetValue(Section, Ident, Value: String);
Begin
  If assigned(ini) Then Begin
    ini.WriteString(Section, Ident, Value);
  End;
End;

Procedure DeleteValue(Section, Ident: String);
Begin
  If assigned(ini) Then Begin
    ini.DeleteKey(Section, Ident);
  End;
End;

Procedure DeleteSection(Section: String);
Begin
  If assigned(ini) Then Begin
    ini.EraseSection(Section);
  End;
End;

Function SectionExists(Section: String): Boolean;
Begin
  result := false;
  If Assigned(ini) Then Begin
    result := ini.SectionExists(Section);
  End;
End;

Function distance(lat1, lon1, lat2, lon2: Double): Double;
Begin
  If (abs(lat1 - lat2) < 0.000001) And (abs(lon1 - lon2) < 0.000001) Then Begin
    result := 0; // Distanz zu gering, das gäbe im Ergebnis einen NaN
  End
  Else Begin
    result := arcCOS(COS(degtorad(90 - lat2)) * COS(degtorad(90 - lat1)) + SIN(degtorad(90 - lat2)) * SIN(degtorad(90 - lat1)) * COS(degtorad(lon2 - lon1))) * 6371;
    result := result * 1000;
  End;
End;

Function distance2(lat1, lon1, lat2, lon2: Double): Double;
  Function CoordToInt(Coord: Double): integer;
  Var
    a, b, c: String;
  Begin
    DecodeKoordinate(coord, a, b, c);
    result :=
      strtoint(a) * 100000 +
      convert_dimension(0, 60000, strtoint(b) * 1000 + strtoint(c), 0, 100000) // Da die Minute von 0..59 geht muss sie umscalliert werden auf 0.99, sonst ist 9° 59.999 - 10° 00.000 nicht = 1
    ;
  End;

Var
  lat1i, lon1i, lat2i, lon2i: integer;
Begin
  lat1i := CoordToInt(lat1);
  lat2i := CoordToInt(lat2);
  lon1i := CoordToInt(lon1);
  lon2i := CoordToInt(lon2);
  result := sqrt(sqr(lat1i - lat2i) + sqr(lon1i - lon2i));
End;

Function LoadFieldNotesFromFile(Const Filename: String): TFieldNoteList;
Var
  f: TFileStream;
  sl: TStringList;
  m2, m: TMemoryStream;
  p, si: int64;
  s, t, buffer: String;
  c: WideChar;
  inString: Boolean;
  b1, b2: Byte;
  i, j: Integer;
Begin
  result := Nil;
  If Not FileExistsUTF8(Filename) Then exit;
  f := TFileStream.Create(Filename, fmOpenRead);
  m := TMemoryStream.Create;
  m.CopyFrom(f, f.Size);
  f.free;
  m.Position := 0;
  // Erkennung Big oder Little Endian
  b1 := 0;
  b2 := 0;
  m.read(b1, sizeof(b1));
  m.read(b2, sizeof(b2));
  If (b1 = $FE) And (b2 = $FF) Then Begin // Korrekt wäre FF FE
    // Korrektur Endianes
    m2 := TMemoryStream.Create;
    m2.Write(b2, sizeof(b2));
    m2.Write(b1, sizeof(b1));
    si := m.Size;
    p := 2;
    While p < si Do Begin // Quelle Einlesen und Byte gedreht speichern
      m.read(b1, sizeof(b1));
      m.read(b2, sizeof(b2));
      m2.Write(b2, sizeof(b2));
      m2.Write(b1, sizeof(b1));
      inc(p, 2);
    End;
    m2.Position := 0;
    m.Clear;
    m.CopyFrom(m2, m2.Size);
    m2.free;
    m.Position := 2; // Überspringen der BOM, da wir ja nun wissen das sie stimmt
  End
  Else Begin
    If (b1 = $FF) And (b2 = $FE) Then Begin // Das ist das Format, welches wir erwarten mit BOM
      // m.position := 2; // Steht eh schon auf 2
    End
    Else Begin
      // Keine Bekannte BOM
      If (b1 = $47) And (B2 = $43) Then Begin // Die Datei beginnt mit "GC"
        // Die Datei die wir hier laden ist von IOS
        // IOS setzt als CRT #13 #13 #10 ein
        // Die Zeichen sind UTF8 Codiert
        // Einlesen als TStringlist und Zeilenweise Speichern als das erwartete Format und Fertig ;)
        sl := TStringList.Create;
        sl.LoadFromFile(Filename);
        m.Clear;
        For i := 0 To sl.count - 1 Do Begin
          s := trim(sl[i]);
          If s <> '' Then Begin // Das Merkwürdige IOS CRT wird als immer eine Leere Zeile interpretiert, die wird hier ignoriert
            For j := 1 To UTF8Length(s) Do Begin
              c := UTF8ToUTF16(UTF8Copy(s, j, 1))[1];
              m.Write(c, sizeof(c));
            End;
            c := UTF8ToUTF16(#13)[1];
            m.Write(c, sizeof(c));
            c := UTF8ToUTF16(#10)[1];
            m.Write(c, sizeof(c));
          End;
        End;
        sl.free;
        m.Position := 0; // Ohne BOM gespeichert
      End
      Else Begin
        m.position := 0; // Wir haben wohl keine BOM, also lesen wir das als Datenbytes mit.
      End;
    End;
  End;
  si := m.Size;
  p := m.position;
  s := '';
  c := #0;
  inString := false;
  While p < si Do Begin
    m.read(c, sizeof(c));
    inc(p, sizeof(c));
    t := UTF16ToUTF8(c);
    If t = '"' Then
      inString := Not inString;
    If (t = #10) And (Not inString) Then Begin
      Try
        buffer := s;
        setlength(result, high(Result) + 2);
        result[high(result)].GC_Code := trim(copy(s, 1, pos(',', s) - 1));
        delete(s, 1, pos(',', s));
        result[high(result)].Date := trim(copy(s, 1, pos(',', s) - 1));
        delete(s, 1, pos(',', s));
        result[high(result)].Logtype := EnglishStringToLogType(trim(copy(s, 1, pos(',', s) - 1)));
        delete(s, 1, pos('"', s));
        // Befinden sich mehrere " im Text, dann sind die alle Doppelt
        // nur das 1. und letzte beschränkt den String, alle anderen müssen zu " konvertiert werden.
        result[high(result)].Comment := copy(s, 1, PosRev('"', s) - 1);
        result[high(result)].Comment := StringReplace(result[high(result)].Comment, '""', '"', [rfReplaceAll]);
        result[high(result)].Fav := false;
        result[high(result)].TBs := Nil;
        result[high(result)].reportProblem := rptNoProblem;
        result[high(result)].Image := '';
        // Wenn beim Import ein Need Maintenance kommt, dann machen wir den Grundsätzlich zum Write note, der User kann das später wieder ändern wenn er mag.
        If result[high(result)].Logtype = ltNeedsMaintenance Then Begin
          result[high(result)].Logtype := ltWriteNote;
          result[high(result)].reportProblem := rptOther;
        End;
        s := '';
      Except
        On av: Exception Do Begin
          Raise exception.Create(av.message + lineending + 'on line: ' + buffer);
        End;
      End;
    End
    Else Begin
      s := s + t;
    End;
  End;
  m.free;
End;

Function SaveFieldNotesToFile(Const Filename: String; Data: TFieldNoteList
  ): Boolean;
Var
  m: TMemoryStream;
  f: TFileStream;
  i, j: integer;
  c: WideChar;
  s: String;
  b: Byte;
Begin
  result := false;
  Try
    m := TMemoryStream.Create;
    // BOM schreiben
    b := $FF;
    m.Write(b, sizeof(b));
    b := $FE;
    m.Write(b, sizeof(b));
    For i := 0 To high(Data) Do Begin
      data[i].GC_Code := data[i].GC_Code + ',';
      For j := 1 To UTF8Length(data[i].GC_Code) Do Begin
        c := UTF8ToUTF16(UTF8Copy(data[i].GC_Code, j, 1))[1];
        m.Write(c, SizeOf(c));
      End;
      data[i].Date := data[i].Date + ',';
      For j := 1 To UTF8Length(data[i].Date) Do Begin
        c := UTF8ToUTF16(UTF8Copy(data[i].Date, j, 1))[1];
        m.Write(c, SizeOf(c));
      End;
      // Wenn ein "Problem" existiert, muss beim Export wieder ein NM gemacht werden, sonst würde das verloren gehen..
      If data[i].reportProblem <> rptNoProblem Then Begin
        s := LogTypeToEnglishString(ltNeedsMaintenance) + ',';
      End
      Else Begin
        s := LogTypeToEnglishString(data[i].Logtype) + ',';
      End;
      For j := 1 To UTF8Length(s) Do Begin
        c := UTF8ToUTF16(UTF8Copy(s, j, 1))[1];
        m.Write(c, SizeOf(c));
      End;
      // Wir haben ja einen Kommatext, also muss aus " wieder ein "" werden.
      data[i].Comment := '"' + Stringreplace(data[i].Comment, '"', '""', [rfReplaceAll]) + '"'#13#10;
      For j := 1 To UTF8Length(data[i].Comment) Do Begin
        c := UTF8ToUTF16(UTF8Copy(data[i].Comment, j, 1))[1];
        m.Write(c, SizeOf(c));
      End;
    End;
    m.Position := 0;
    f := TFileStream.Create(Filename, fmCreate Or fmOpenWrite);
    f.CopyFrom(m, m.Size);
    f.free;
    m.free;
    result := true;
  Except
    On e: Exception Do Begin
      ShowMessage(e.Message);
    End;
  End;
End;

Function CreateNewTBDatabase(Const Filename: String): Boolean;
Begin
  result := false;
  If Not assigned(tb_SQLite3Connection) Then Begin
    exit;
  End;
  If tb_SQLite3Connection.Connected Then
    tb_SQLite3Connection.Connected := false;

  (*
   * Verbinden auf Datenbank
   *)
  tb_SQLite3Connection.DatabaseName := Filename;
  Try
    tb_SQLite3Connection.Connected := true;
  Except
    On e: Exception Do Begin
      ShowMessage('Error, could not connect.' + LineEnding + 'Errormessage:' + LineEnding + e.Message);
      exit;
    End;
  End;
  (*
   * !! ACHTUNG !!
   *
   * Wird hier etwas geändert, dann muss das in Unit38 auch gemacht werden !
   *
   *)
  // Siehe ugctool.TTravelbugRecord
  If Not TB_CommitSQLTransactionQuery(
    'create table trackables(' + LineEnding +
    // Allgemein
    'TB_Code TEXT,' + LineEnding +
    'Discover_Code TEXT PRIMARY KEY,' + LineEnding +
    'LogState TEXT,' + LineEnding +
    'LogDate TEXT,' + LineEnding +
    'Owner TEXT,' + LineEnding +
    'ReleasedDate TEXT,' + LineEnding +
    'Origin TEXT,' + LineEnding +
    'Current_Goal TEXT,' + LineEnding +
    'About_this_item TEXT,' + LineEnding +
    'Comment TEXT,' + LineEnding +
    'Heading TEXT' + LineEnding +
    ');'
    ) Then Begin
    exit;
  End;
  TB_SQLTransaction.Commit;
  result := true;
End;

Function CreateNewDatabase(Const DataBasename: String): boolean;
Var
  p: String;
Begin
  result := false;
  If trim(DataBasename) = '' Then exit;
  If Not assigned(SQLite3Connection) Then Begin
    exit;
  End;
  If SQLite3Connection.Connected Then
    SQLite3Connection.Connected := false;
  (*
   * Anlegen Ordnerstruktur falls notwendig
   *)
  p := GetDataBaseDir();
  If Not DirectoryExistsutf8(p) Then Begin
    If Not CreateDirUTF8(p) Then Begin
      exit;
    End;
  End;
  p := p + DataBasename + '.db';
  (*
   * Evtl. alte .db Datei Löschen
   *)
  If FileExistsUTF8(p) Then Begin
    If Not DeleteFileUTF8(p) Then Begin
      exit;
    End;
  End;
  (*
   * Verbinden auf Datenbank
   *)
  SQLite3Connection.DatabaseName := p;
  Try
    SQLite3Connection.Connected := true;
  Except
    On e: Exception Do Begin
      ShowMessage('Error, could not connect.' + LineEnding + 'Errormessage:' + LineEnding + e.Message);
      exit;
    End;
  End;
  (*
   * Erzeugen neue Datenbankstruktur
   *
   * https://www.sqlite.org/datatype3.html
   *
   *)

  (*
   * Liste der Caches
   *)
  If Not CommitSQLTransactionQuery(format(CreateTableCachesCMD, ['caches'])) Then Begin
    exit;
  End;

  (*
   * Attribute der Attribute
   *)
  If Not CommitSQLTransactionQuery(
    'create table attributes(' + LineEnding +
    'CACHE_NAME TEXT,' + LineEnding +
    'ID INTEGER,' + LineEnding +
    'INC INTEGER,' + LineEnding +
    'ATTRIBUTE_TEXT TEXT,' + LineEnding +
    'FOREIGN KEY(CACHE_NAME) REFERENCES CACHES(NAME)' + LineEnding +
    ');'
    ) Then Begin
    exit;
  End;

  (*
   * Log der Logs
   *)
  If Not CommitSQLTransactionQuery(
    'create table logs(' + LineEnding +
    'CACHE_NAME TEXT,' + LineEnding +
    'ID INTEGER,' + LineEnding + // -- Ist zusammen mit Name der Primary Key
    'DATE TEXT,' + LineEnding +
    'TYPE TEXT,' + LineEnding +
    'FINDER_ID INTEGER,' + LineEnding +
    'FINDER TEXT,' + LineEnding +
    'TEXT_ENCODED INTEGER,' + LineEnding +
    'LOG_TEXT TEXT,' + LineEnding +
    'FOREIGN KEY(CACHE_NAME) REFERENCES CACHES(NAME)' + LineEnding +
    ');'
    ) Then Begin
    exit;
  End;

  (*
   * Wegpunktliste der Wegpunkte
   *)
  If Not CommitSQLTransactionQuery(
    'create table waypoints(' + LineEnding +
    'CACHE_NAME TEXT,' + LineEnding +
    'NAME TEXT,' + LineEnding +
    'TIME TEXT,' + LineEnding +
    'LAT REAL,' + LineEnding +
    'LON REAL,' + LineEnding +
    'CMT TEXT,' + LineEnding +
    'DESC TEXT,' + LineEnding +
    'URL TEXT,' + LineEnding +
    'URL_NAME TEXT,' + LineEnding +
    'SYM TEXT,' + LineEnding +
    'TYPE TEXT,' + LineEnding +
    'FOREIGN KEY(CACHE_NAME) REFERENCES CACHES(NAME)' + LineEnding +
    ');'
    ) Then Begin
    exit;
  End;
  SQLTransaction.Commit;
  result := true;
End;

(*
 * Entnommen / Portiert aus c:geo Quellcode "GCConstants.java" methode "gccodeToGCId"
 *)

Function GCCodeToGCiD(GC_Code: String): UInt64;
Const
  GC_BASE31 = 31;
  GC_BASE16 = 16;
  SEQUENCE_GCID = '0123456789ABCDEFGHJKMNPQRTVWXYZ';
Var
  gcid, base: uint64;
  geocodeWO: String;
  p: integer;
Begin
  // Test : GC3m3wh -> 2959000
  // Test : GC42 -> 66
  GC_Code := trim(GC_Code);
  If ((GC_Code = '') Or (length(GC_Code) < 3)) Then Begin
    result := 0;
    exit;
  End;
  base := GC_BASE31;
  geocodeWO := Uppercase(copy(GC_Code, 3, length(GC_Code)));

  If (length(geocodeWO) < 4) Or ((length(geocodeWO) = 4) And (pos(geocodeWO[1], SEQUENCE_GCID) <= 16)) Then Begin
    base := GC_BASE16;
  End;

  gcid := 0;
  For p := 1 To length(geocodeWO) Do Begin
    gcid := base * gcid + pos(geocodeWO[p], SEQUENCE_GCID) - 1;
  End;

  If (base = GC_BASE31) Then Begin
    gcid := gcid - 411120; // 16^4 - 16 * 31^3 = -411120
  End;
  result := gcid;
End;

Function GetDefaultFilterFor(FilterName: String): String;
Begin
  result := '';
  Case lowercase(trim(FilterName)) Of
    'export': result :=
      'where' + LineEnding +
        '-- All Mysteries, that have corrected coordinates' + LineEnding +
        ' ((((c.G_TYPE = "' + ToSQLString(Unknown_Cache) + '") and' + LineEnding +
        '    (c.cor_lat <> -1) and' + LineEnding +
        '    (c.cor_lon <> -1)) or' + LineEnding +
        '-- All Bonus Mysteries' + LineEnding +
        '    ((c.G_TYPE = "' + ToSQLString(Unknown_Cache) + '") and' + LineEnding +
        '     (c.g_Name like "%Bonus%")) or' + LineEnding +
        '-- All Bonus Mysteries' + LineEnding +
        '    ((c.G_TYPE = "' + ToSQLString(Unknown_Cache) + '") and' + LineEnding +
        '     (c.g_Name like "%Challenge%")) or' + LineEnding +
        '-- All other caches' + LineEnding +
        '     (c.G_TYPE <> "' + ToSQLString(Unknown_Cache) + '")))' + LineEnding +
        '-- The Cache is aviable and not found' + LineEnding +
        '   and c.G_ARCHIVED = 0' + LineEnding +
        '   and c.G_FOUND = 0' + LineEnding +
        'union' + LineEnding +
        '-- Select Caches that have Bonus or Challange' + LineEnding +
        '  select' + LineEnding +
        '    distinct c.G_TYPE, c.NAME, c.G_NAME, c.lat, c.lon, c.cor_lat, c.cor_lon, c.G_DIFFICULTY, c.G_TERRAIN, c.Fav' + LineEnding +
        '  from caches c' + LineEnding +
        '    inner join attributes a on a.cache_name = c.name -- include the attribute database to be able to search for attributes' + LineEnding +
        '  where' + LineEnding +
        '    -- Bonus cache' + LineEnding +
        '    (((a.id = 69) and (a.inc = 1)) or' + LineEnding +
        '    -- Challenge cache' + LineEnding +
        '    ((a.id = 71) and (a.inc = 1)))' + LineEnding +
        '    and c.G_ARCHIVED = 0' + LineEnding +
        '    and c.G_FOUND = 0';

    'founds': result :=
      'where' + LineEnding +
        'c.g_found = 1';

    'mysteries not solved yet': result :=
      'where' + LineEnding +
        '-- All Mysteries, that not have corrected coordinates' + LineEnding +
        '((c.G_TYPE = "' + ToSQLString(Unknown_Cache) + '") and' + LineEnding +
        ' (c.cor_lat = -1) and' + LineEnding +
        ' (c.cor_lon = -1))' + LineEnding +
        '-- The cache is aviable and not found' + LineEnding +
        '   and c.G_ARCHIVED=0 and c.G_FOUND = 0';

    'modified coordinates': result :=
      'where' + LineEnding +
        '-- All Mysteries, that have corrected coordinates' + LineEnding +
        '  ((c.cor_lat <> -1) and' + LineEnding +
        '   (c.cor_lon <> -1))' + LineEnding +
        '-- The cache is aviable and not found' + LineEnding +
        '   and c.G_ARCHIVED=0 and c.G_FOUND = 0';

    'demo-selection': result :=
      '-- This querie is for demo purpose' + LineEnding +
        '-- enable the parts you are interested in' + LineEnding +
        '-- to generate your own selection' + LineEnding +
        'where' + LineEnding +
        ' (1 = 1) -- Dummy statemant that is always true' + LineEnding +
        '-- The following lines are all optional uncomment' + LineEnding +
        '-- them on demand.' + LineEnding +
        '--' + LineEnding +
        '-- Selection by cache type' + LineEnding +
        '-- and (c.G_TYPE = "' + ToSQLString(Unknown_Cache) + '") -- Only Mysteries' + LineEnding +
        '-- and (c.G_TYPE = "' + ToSQLString(Traditional_Cache) + '") -- Only Tradies' + LineEnding +
        '-- and (c.G_TYPE = "' + ToSQLString(Multi_cache) + '") -- Only Multies' + LineEnding +
        '--' + LineEnding +
        '-- Selection by D-T Rating' + LineEnding +
        '-- if you want more than one D-T criteria at the same time' + LineEnding +
        '-- you have to "or" them' + LineEnding +
        '-- and ((c.g_terrain = 1.0) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 1.5) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 2.0) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 2.5) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 3.0) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 3.5) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 4.0) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 4.5) and (c.g_difficulty = 1.0))' + LineEnding +
        '-- and ((c.g_terrain = 5.0) and (c.g_difficulty = 1.0))' + LineEnding +
        '--' + LineEnding +
        '-- The cache is active and not found' + LineEnding +
        'and   (c.G_ARCHIVED = 0) and (c.G_FOUND = 0)';

    'same owner as': result :=
      '-- This is a more complex demo query' + LineEnding +
        '-- demonstrating how to do a natural join in sql' + LineEnding +
        '-- This query lists all chaches from the owner of gc5yp9t' + LineEnding +
        '-- that are not yet found and active.' + LineEnding +
        ', caches d -- we need a second access to the chaches table' + LineEnding +
        'where' + LineEnding +
        '-- Select a cache from the owner to get his owner id' + LineEnding +
        '-- if you want to get all caches from a different owner' + LineEnding +
        '-- just replace the gc code to a cache from this owner' + LineEnding +
        '  (d.Name like "gc5yp9t") ' + LineEnding +
        '  and (d.g_owner_id = c.g_owner_id) -- Select all caches with the same owner' + LineEnding +
        '-- The Cache is aviable and not found' + LineEnding +
        '  and c.G_ARCHIVED=0 and c.G_FOUND = 0';

    'caches marked as archived': result :=
      'where' + LineEnding +
        'c.G_ARCHIVED=1';

    'caches with set customer flag': result :=
      'where' + LineEnding +
        'c.Customer_Flag<>0';

    'lite caches': result :=
      'where' + LineEnding +
        'c.lite<>0';
  End;
  result := trim(result);
End;

Procedure Initccm(Lazy: Boolean);
Var
  s, // Source DateiName
  t, // Ziel DateiName
  p, // Config Pfad im System
  op // Pfad in dem die Application Liegt
  : String;
Begin
  (*
   * Die Default Darstellung aller Float Zahlen soll in "." notation geschehen.
   *)
  DefFormat := DefaultFormatSettings;
  DefFormat.DecimalSeparator := '.';
  umathsolver.SetDecimalSeparator('.');
  p := IncludeTrailingPathDelimiter(GetAppConfigDir(false));
  op := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0)));
  // ggf erstellen des CCM-Config Ordners
  If Not DirectoryExistsUTF8(p) Then Begin
    If Not CreateDir(p) Then Begin
      ShowMessage('Error could not create config folder: ' + p); // Hier gibt es noch keine Sprachunterstützung.
      halt(1);
      exit;
    End;
  End;
  (*
   * Ab Ver 1.99 wird die Config in einem vom Betriebsystem dafür vorgesehenen Verzeichnis gespeichert
   * Die evtl. schon existierende Datei einer alten Version wird hier entsprechend portiert.
   *)
  t := p + 'ccm.ini';
  s := op + 'ccm.ini';
  VeryFirstStartofCCM := false;
  If (Not FileExistsUTF8(t)) And (Not FileExistsUTF8(s)) Then Begin
    VeryFirstStartofCCM := true;
  End;
  If FileExistsUTF8(s) Then Begin
    If Not CopyFile(s, t, true, false) Then Begin
      ShowMessage('Error could not move config file from: "' + s + '" to "' + t + '"'); // Hier gibt es noch keine Sprachunterstützung.
      halt(1);
      exit;
    End;
    If Not DeleteFileUTF8(s) Then Begin
      ShowMessage('Error could not delete invalid config file: "' + s + '"'); // Hier gibt es noch keine Sprachunterstützung.
      halt(1);
      exit;
    End;
  End;
  ini := TIniFile.Create(t); // Öffnen der Ini- Für evtl Später
  If lazy Then exit;
  (*
   * Ab Ver 1.99 liegen die Datenbanken eigentlich im Localen User Verzeichnis
   * zur Wahrung der Abwärtskompatibilität wird hier der Datenbankpfad evtl angepasst.
   *)
  t := GetValue('General', 'Databases', '');
  If t = '' Then Begin // Wenn der Wert noch undefiniert ist
    s := op + 'databases' + PathDelim;
    If DirectoryExistsUTF8(s) Then Begin // Aber das "alte" Datenbankenverzeichnis existiert
      SetValue('General', 'Databases', s);
    End;
  End;
  // ---------------------- Kopieren der Sprachdateien in das Config Verzeichnis
  (*
   * Da die Sprachengine evtl. auch die Sprachdateien Beschreibt müssen diese ebenfalls in ein Schreibbares verzeichnis Aktualisiert werden
   *)
  s := op + 'ccmlang.de';
  t := p + 'ccmlang.de';
  If Not CopyFile(s, t, [cffOverwriteFile]) Then Begin
    ShowMessage('Error could not copy language file from: "' + s + '" to "' + t + '"'); // Hier gibt es noch keine Sprachunterstützung.
    halt(1);
    exit;
  End;
  s := op + 'ccmlang.en';
  t := p + 'ccmlang.en';
  If Not CopyFile(s, t, [cffOverwriteFile]) Then Begin
    ShowMessage('Error could not copy language file from: "' + s + '" to "' + t + '"'); // Hier gibt es noch keine Sprachunterstützung.
    halt(1);
    exit;
  End;
  // --------------------------------------- GGf Initialisieren der Config Datei
  // Anfügen diverser Default Einstellungen
  If VeryFirstStartofCCM Then Begin
    // Auf Plattformen die das HTML Anzeigen nicht können, setzt man das auf 1
    ini.WriteBool('General', 'NeverUseHTMLRenderer', false);

    // Default Tool
    ini.WriteInteger('Tools', 'Count', 2);
    ini.WriteString('Tools', 'Name0', 'OpenStreetmap');
    ini.WriteString('Tools', 'Type0', 'Link');
    ini.WriteString('Tools', 'Value0', 'http://garmin.openstreetmap.nl/');
    ini.WriteString('Tools', 'Name1', 'Geocaching');
    ini.WriteString('Tools', 'Type1', 'Link');
    ini.WriteString('Tools', 'Value1', 'http://Geocaching.com/');

    // Default Filter
    ini.WriteInteger('Queries', 'Count', 9);
    ini.WriteString('Queries', 'Name0', 'Export');
    ini.WriteString('Queries', 'Query0', ToSQLString(GetDefaultFilterFor('Export')));

    ini.WriteString('Queries', 'Name1', 'Founds');
    ini.WriteString('Queries', 'Query1', ToSQLString(GetDefaultFilterFor('Founds')));

    ini.WriteString('Queries', 'Name2', 'Mysteries not solved yet');
    ini.WriteString('Queries', 'Query2', ToSQLString(GetDefaultFilterFor('mysteries not solved yet')));

    ini.WriteString('Queries', 'Name3', 'Modified Coordinates');
    ini.WriteString('Queries', 'Query3', ToSQLString(GetDefaultFilterFor('Modified Coordinates')));

    ini.WriteString('Queries', 'Name4', 'Demo-Selection');
    ini.WriteString('Queries', 'Query4', ToSQLString(GetDefaultFilterFor('Demo-Selection')));

    ini.WriteString('Queries', 'Name5', 'Same owner as');
    ini.WriteString('Queries', 'Query5', ToSQLString(GetDefaultFilterFor('Same owner as')));

    ini.WriteString('Queries', 'Name6', 'Caches marked as archived');
    ini.WriteString('Queries', 'Query6', ToSQLString(GetDefaultFilterFor('Caches marked as archived')));

    ini.WriteString('Queries', 'Name7', 'Caches with set customer flag');
    ini.WriteString('Queries', 'Query7', ToSQLString(GetDefaultFilterFor('Caches with set customer flag')));

    ini.WriteString('Queries', 'Name8', 'Lite Caches');
    ini.WriteString('Queries', 'Query8', ToSQLString(GetDefaultFilterFor('Lite Caches')));

    // Default SQL-Admin
    ini.WriteInteger('SQLAdmin', 'Count', 2);
    ini.WriteString('SQLAdmin', 'Name0', 'Mark_all_unmodified_as_modified');
    ini.WriteString('SQLAdmin', 'Query0',
      ToSQLString(
      '-- Marks all caches in DB as modified' + LineEnding +
      '-- if they are not already marked as modified' + LineEnding +
      'update caches set' + LineEnding +
      'cor_lat = lat,' + LineEnding +
      'cor_lon = lon' + LineEnding +
      'where (cor_lat = -1) and (cor_lon = -1)' + LineEnding +
      ';'));

    ini.WriteString('SQLAdmin', 'Name1', 'Select_first_10_caches_in_database');
    ini.WriteString('SQLAdmin', 'Query1',
      ToSQLString(
      '-- This is a comment' + LineEnding +
      'select * from ' + LineEnding +
      'caches ' + LineEnding +
      'limit 10' + LineEnding +
      ';'));
  End;
End;

{ TSimpleIpHtml }

Function TSimpleIpHtml.LoadContentFromString(Const Content: String;
  Callback: TIpHtmlDataGetImageEvent): Boolean;
Var
  m: TMemoryStream;
Begin
  result := true;
  m := TMemoryStream.Create;
  m.Write(Content[1], length(Content));
  m.Position := 0;
  Try
    OnGetImageX := Callback;
    LoadFromStream(m);
  Except
    result := false;
  End;
  m.free;
End;

Finalization
  If assigned(ini) Then Begin
    ini.free;
    ini := Nil;
  End;
End.

