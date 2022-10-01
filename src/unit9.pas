Unit Unit9;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  process, UTF8Process, usqlite_helper, uccm, lclintf;

Type

  { TForm9 }

  TForm9 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }

  public
    { public declarations }
    (*
     * Exportiert alle POI Files und nimmte Filename als Basis
     *)
    Function ExportPOI(Folder: String): Boolean;

    (*
     * Gibt die Wegpunkte, aller Caches die in Form1 gerade angewählt sind.
     *)
    Function GetAllWaypoints(): TWaypointList;

    (*
     * Fügt all die cahes an, welche Korrigierte Koordinaten haben
     *)
    Procedure AppendModified(Var List: TWaypointList);

    (*
     * Nimmt alle Wegpunkte aus Waypointlist, welche als Sym Sym haben oder wenn Sym = '' Alle
     * und Speichert diese in Filename
     * Result  < 0 => Fehler
     * Result >= 0 => Anzahl exportierter Datensätze
     *
     * Jeder Waypoint der benutzt wird, dessen .used wird auf True gesetzt
     *)
    Function CreateWaypointFile(Var Waypoints: TWaypointList; Filename, Sym: String; ExportForGSAK: Boolean): integer;
  End;

Var
  Form9: TForm9;

Implementation

{$R *.lfm}

Uses unit1, Laz2_DOM, laz2_XMLwrite, lazutf8, LazFileUtils, LCLType, umapviewer, ulanguage;

{ TForm9 }

Function WaypointToDomNode(Const doc: TXMLDocument; Const Waypoint: TWaypoint; ExportForGSAK: Boolean): TDomNode;
Var
  s: String;
Begin
  result := doc.CreateElement('wpt');
  TDOMElement(result).SetAttribute('lat', floattostr(Waypoint.lat, DefFormat));
  TDOMElement(result).SetAttribute('lon', floattostr(Waypoint.Lon, DefFormat));
  AddTag(doc, result, 'time', Waypoint.Time);
  // -- So wärs der Wegpunktname
  //  AddTag(doc, result, 'name', Waypoint.Name);
  // -- So ists der Cachename + seine Kurz Beschreibung
  StartSQLQuery('Select G_NAME from caches where name="' + Waypoint.GC_Code + '"');
  s := FromSQLString(SQLQuery.Fields[0].AsString);
  //  AddTag(doc, result, 'name', Waypoint.GC_Code + ':' + s);
  If ExportForGSAK Then Begin
    // GSAK kommt nicht damit Klar, dass nach dem Wegpunkt namen noch etwas steht.
    AddTag(doc, result, 'name', Waypoint.Name);
  End
  Else Begin
    AddTag(doc, result, 'name', Waypoint.Name + ':' + s);
  End;
  AddTag(doc, result, 'cmt', Waypoint.cmt);
  AddTag(doc, result, 'desc', Waypoint.desc);
  AddTag(doc, result, 'url', Waypoint.url);
  AddTag(doc, result, 'urlname', Waypoint.url_name);
  AddTag(doc, result, 'sym', Waypoint.sym);
  AddTag(doc, result, 'type', Waypoint.Type_);
End;

Procedure TForm9.Button1Click(Sender: TObject);
Var
  i: int64;
  j, k: integer;
  b: Boolean;
Begin
  // Prüfen ob es den Eintrag schon gibt, und ggf übernehmen
  k := strtoint(getvalue('GPSPOI', 'Count', '0'));
  b := false;
  For j := 0 To k - 1 Do Begin
    If getvalue('GPSPOI', 'Folder' + inttostr(j), '') = ComboBox1.Text Then Begin
      b := true;
      break;
    End;
  End;
  If Not b Then Begin
    If ID_YES = Application.MessageBox(pchar(format(RF_The_folder_is_not_in_the_export_add, [ComboBox1.Text])), pchar(R_Question), MB_YESNO Or MB_ICONQUESTION) Then Begin
      SetValue('GPSPOI', 'Count', inttostr(k + 1));
      SetValue('GPSPOI', 'Folder' + inttostr(k), ComboBox1.Text);
    End;
  End;
  // Der Eigentliche POI Export
  i := GetTickCount64;
  ExportPOI(ComboBox1.Text);
  i := GetTickCount64 - i;
  Showmessage(format(RF_Script_finished_in, [PrettyTime(i)], DefFormat));
End;

Function TForm9.ExportPOI(Folder: String): Boolean;
Var
  wpl: TWaypointList;
  i, j: Integer;
  imgName, fnameBase, fnameExt, s, workdir, Imagespath: String;
{$IFDEF LINUX}
  sl: TStringList;
{$ENDIF}
  p: TProcessUTF8;
  gpsbabelfolder, Filename: String;
Begin
  result := false;
  // 0 Prechecks
  If folder = '' Then Begin
    showmessage(R_Error_invalid_POI_folder);
    exit;
  End;
  If Not ForceDirectoriesUTF8(folder) Then Begin
    showmessage(R_Error_Could_not_create_POI_folder);
    exit;
  End;
{$IFDEF Windows}
  gpsbabelfolder := IncludeTrailingPathDelimiter(GetValue('General', 'GPSBabelFolder', FindDefaultExecutablePath('gpsbabel.exe', '')));
{$ELSE}
  gpsbabelfolder := ''; // Wird nur unter Windows benötigt.
{$ENDIF}
  Filename := IncludeTrailingPathDelimiter(folder) + ExtractFileNameOnly(SQLite3Connection.DatabaseName) + '.gpi';
  If Not GetWorkDir(workdir) Then Begin
    exit;
  End;
  If FileExistsUTF8(workdir + 'ccm_wpts.gpx') Then Begin
    If Not DeleteFileUTF8(workdir + 'ccm_wpts.gpx') Then Begin
      showmessage(format(RF_Error_could_not_delete, [workdir + 'ccm_wpts.gpx']));
      exit;
    End;
  End;
  workdir := IncludeTrailingPathDelimiter(workdir);
  Imagespath := GetImagesDir();
  // 1.1 Alle Alten POI Dateien mit der Gleichen Filenamebasis Löschen
  fnameBase := ExtractFileNameWithoutExt(Filename);
  fnameExt := ExtractFileExt(Filename);
  For i := 0 To high(POI_Types) Do Begin
    s := fnameBase + POI_Types[i].FileNameAdd + fnameExt;
    If FileExistsUTF8(s) Then Begin
      If Not DeleteFileUTF8(s) Then Begin
        showmessage(format(RF_Error_could_not_delete, [s]));
        exit;
      End;
    End;
  End;
  // 1.2 Auslesen aller Wegpunkte aller selektierten Caches und sammeln derer Wegpunkte in wpls
  wpl := GetAllWaypoints();
  // Todo: Klären ob man bei GSAK Export das nicht evtl abschaltet...
  If GetValue('General', 'ExportModifiedPOI', '0') = '1' Then Begin
    AppendModified(wpl);
  End;

  // 2.1 Speichern der Wegpunkte Getrennt nach "Sym" in jeweils in eine tmp Datei
  For i := 0 To high(POI_Types) Do Begin
    j := CreateWaypointFile(wpl, workdir + 'ccm_wpts.gpx', POI_Types[i].Sym, false);
    If j < 0 Then Begin
      // Hier wird der ZielDateiname angegeben, oben der Temporäre
      showmessage(format(RF_Error_could_not_create, [fnameBase + POI_Types[i].FileNameAdd + fnameExt]));
      setlength(wpl, 0);
      exit;
    End;
    imgName := fnameBase + POI_Types[i].FileNameAdd + ExtractFileExt(POI_Types[i].Bitmap);
    If j > 0 Then Begin
      // 2.2 Mittels Babel eine passende poi Datei erstellen
      // 2.3 Die .bmp Datei dahin kopieren wo die poi Datei erstellt wurde
      If Not FileExistsUTF8(imgName) Then Begin
        CopyFile(Imagespath + POI_Types[i].Bitmap, imgName);
      End;
      // 2.2.1 ShelScript welches gpsBabel steuert erstellen
{$IFDEF LINUX}
      sl := TStringList.Create;
      sl.add('#!/bin/bash');
{$ENDIF}
      // Aufbauen des Befehls für GPSBabel
      s := gpsbabelfolder + 'gpsbabel -i gpx -f "' + workdir + 'ccm_wpts.gpx' + '" -o garmin_gpi,category="Geocache Waypoints"';
      s := s + ',bitmap="' + imgName + '"';
      s := s + ' -F "' + fnameBase + POI_Types[i].FileNameAdd + fnameExt + '"';
      //  s := s + '> ' + workdir + 'gpsbabel_log.txt'; -- Das File wird erstellt gibt aber nichts aus ..
{$IFDEF LINUX}
      sl.add(s);
      sl.SaveToFile(workdir + 'create_gpi.sh');
      sl.free;
      // 2.2.2 Skript Ausführbar machen
      p := TProcessUTF8.Create(Nil);
      p.Options := [poWaitOnExit];
      p.Executable := 'chmod';
      p.Parameters.Add('+x');
      p.Parameters.Add(workdir + 'create_gpi.sh');
      p.Execute;
      p.free;
{$ENDIF}
      // 2.2.3 Skript ausführen
      p := TProcessUTF8.Create(Nil);
      p.Options := [poWaitOnExit{$IFDEF Windows}, poNoConsole{$ENDIF}];
{$IFDEF LINUX}
      p.Executable := workdir + 'create_gpi.sh';
      p.Execute;
{$ELSE}
      p.Executable := s;
      If FileExistsUTF8(gpsbabelfolder + 'gpsbabel.exe') Then Begin
        p.Execute;
      End;
{$ENDIF}
      p.free;
      If Not FileExistsUTF8(fnameBase + POI_Types[i].FileNameAdd + fnameExt) Then Begin
        showmessage(R_Error_Could_not_create_GPI);
        exit;
      End;
      // 2.4 Temporäre Dateien löschen
{$IFDEF LINUX}
      DeleteFileUTF8(workdir + 'create_gpi.sh');
{$ENDIF}
      DeleteFileUTF8(workdir + 'ccm_wpts.gpx');
    End
    Else Begin
      // Nichts zu erstellen, sicherstellen das auch nichts da ist
      If FileExistsUTF8(imgName) Then Begin
        If Not DeleteFileUTF8(imgName) Then Begin
          showmessage(format(RF_Error_could_not_delete, [imgName]));
        End;
      End;
      { -- Braucht nicht, da oben schon gelöscht..
      If FileExistsUTF8(fnameBase + POI_Types[i].FileNameAdd + fnameExt) Then Begin
        If Not DeleteFileUTF8(fnameBase + POI_Types[i].FileNameAdd + fnameExt) Then Begin
          showmessage('Error could not delete : "' + fnameBase + POI_Types[i].FileNameAdd + fnameExt + '"');
        End;
      End;
      }
    End;
  End;
  // 3 Prüfen ob auch ja alle Waypoints irgendwo exportiert wurden
  For i := 0 To high(wpl) Do Begin
    If Not wpl[i].Used Then Begin
      ShowMessage(format(RF_Error_category_not_exported, [wpl[i].sym]));
      setlength(wpl, 0);
      exit;
    End;
  End;
  setlength(wpl, 0);
  result := true;
End;

Function TForm9.GetAllWaypoints(): TWaypointList;
Var
  i, j, k: Integer;
  wpl: TWaypointList;
Begin
  result := Nil;
  For i := 1 To form1.StringGrid1.RowCount - 1 Do Begin
    wpl := WaypointsFromDB(form1.StringGrid1.cells[MainColGCCode, i]);
    If assigned(wpl) Then Begin
      j := high(result) + 1;
      setlength(result, length(result) + length(wpl));
      For k := 0 To high(wpl) Do Begin
        result[j + k] := wpl[k];
        // Alle Wegpunkte als nicht genutzt markieren
        result[j + k].Used := false;
      End;
    End;
  End;
End;

Procedure TForm9.AppendModified(Var List: TWaypointList);
Var
  i: Integer;
  wp: TWaypoint;
  clat, clon, lat, lon, t: Double;
Begin
  EncodeKoordinate(t, '00', '00', '001');
  For i := 1 To form1.StringGrid1.RowCount - 1 Do Begin
    StartSQLQuery('Select c.lat, c.lon, c.cor_lat, c.cor_lon, c.G_TYPE from caches c Where c.name="' + form1.StringGrid1.cells[MainColGCCode, i] + '"');
    clat := SQLQuery.Fields[2].AsFloat;
    clon := SQLQuery.Fields[3].AsFloat;
    If (clat <> -1) And (clon <> -1) Then Begin // Der Cache hat Korrigierte Koordinaten
      lat := SQLQuery.Fields[0].AsFloat;
      lon := SQLQuery.Fields[1].AsFloat;
      If GetValue('General', 'ExportPOIMysteriesOrigCoords', '0') = '1' Then Begin // Das Exportiert den Mysterie mit seinen Original Koordinaten
        If SQLQuery.Fields[4].AsString = Unknown_Cache Then Begin
          If (abs(lat - clat) > t) Or (abs(lon - clon) > t) Then Begin // Nur Mysteries, welche auch Tatsächlich veränderte Koords haben
            wp.Name := form1.StringGrid1.cells[MainColGCCode, i];
            wp.GC_Code := form1.StringGrid1.cells[MainColGCCode, i];
            wp.lat := lat;
            wp.Lon := lon;
            wp.sym := POI_Types[high(POI_Types) - 1].Sym; // Als vorletzten POI Typ haben wir die Graphik für Mystery
            wp.Time := GetTime(now);
            // Was man da Rein schreibt ist im Prinzip wurscht, da auf dem GPS es von der Dose überlagert wird und man es dann nicht klicken kann *g*
            wp.cmt := wpt_t_Final;
            wp.desc := wp.GC_Code;
            wp.url := '';
            wp.url_name := wp.GC_Code;
            wp.Type_ := 'Waypoint|Physical Stage';
            setlength(List, high(List) + 2);
            list[high(list)] := wp;
          End;
        End;
      End;
      If GetValue('General', 'ExludeModifiedPOIMysteries', '1') = '1' Then Begin // Das macht das "!" bei exportieren Mysteries wieder weg
        If SQLQuery.Fields[4].AsString = Unknown_Cache Then Begin
          lat := clat;
          lon := clon;
        End;
      End;
      If (abs(lat - clat) > t) Or (abs(lon - clon) > t) Then Begin // sind die Korrigierten Koords auch wirklich anders als die des Listings ?
        wp.Name := form1.StringGrid1.cells[MainColGCCode, i];
        wp.GC_Code := form1.StringGrid1.cells[MainColGCCode, i];
        wp.lat := clat;
        wp.Lon := clon;
        wp.sym := POI_Types[high(POI_Types)].Sym; // Als letzten POI Typ haben wir die Graphik für Modified
        wp.Time := GetTime(now);
        // Was man da Rein schreibt ist im Prinzip wurscht, da auf dem GPS es von der Dose überlagert wird und man es dann nicht klicken kann *g*
        wp.cmt := wpt_t_Final;
        wp.desc := wp.GC_Code;
        wp.url := '';
        wp.url_name := wp.GC_Code;
        wp.Type_ := 'Waypoint|Physical Stage';
        setlength(List, high(List) + 2);
        list[high(list)] := wp;
      End;
    End;
  End;
End;

Procedure TForm9.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm9.FormCreate(Sender: TObject);
Begin
  caption := 'POI export';
End;

Function TForm9.CreateWaypointFile(Var Waypoints: TWaypointList; Filename,
  Sym: String; ExportForGSAK: Boolean): integer;
Var
  Doc: TXMLDocument;
  gpx, wpt: TDomnode;
  cnt, i: integer;
Begin
  sym := LowerCase(trim(sym));
  result := -1;
  cnt := 0;
  Doc := TXMLDocument.Create;
  NewDocGPX(doc, gpx);
  AddTag(Doc, gpx, 'keywords', 'cache, geocache, waypoints');
  For i := 0 To high(Waypoints) Do Begin
    If (sym = '') Or (lowercase(trim(Waypoints[i].sym)) = sym) Then Begin
      wpt := WaypointToDomNode(doc, Waypoints[i], ExportForGSAK);
      Waypoints[i].used := true;
      gpx.AppendChild(wpt);
      inc(cnt);
    End;
  End;
  doc.AppendChild(gpx);
  If cnt <> 0 Then Begin
    WriteXML(doc, Filename);
  End;
  doc.free;
  result := cnt;
End;

End.

