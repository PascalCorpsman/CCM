Unit Unit30;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

Type

  { TForm30 }

  TForm30 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckGroup1: TCheckGroup;
    SaveDialog1: TSaveDialog;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private

  public

  End;

Var
  Form30: TForm30;

Implementation

{$R *.lfm}

Uses unit1, usqlite_helper, uccm, ulanguage, lconvencoding;

Const
  IndexCode = 0;
  IndexCoord1 = 1;
  IndexCoord2 = 2;
  IndexTitle = 3;
  IndexState = 4;
  IndexType = 5;
  IndexDifficulty = 6;
  IndexTerrain = 7;
  IndexDistance = 8;
  IndexHint = 9;
  IndexUserNote = 10;
  IndexHiddenDate = 11;
  IndexParkingAreaCoords = 12;

  { TForm30 }

Procedure TForm30.FormCreate(Sender: TObject);
Begin
  // Todo: Das Muss noch Sprachabhängig werden
  caption := 'Export as CSV-File';
  CheckGroup1.Items.Clear;
  // Achtung bei Änderung müssen die obigen Konstanten auch angepasst werden.
  CheckGroup1.Items.add('Code');
  CheckGroup1.Items.add('Coordinate (DEG)');
  CheckGroup1.Items.add('Coordinate (DEC)');
  CheckGroup1.Items.add('Title');
  CheckGroup1.Items.add('State'); // Found, Archived, Korrigiert
  CheckGroup1.Items.add('Type');
  CheckGroup1.Items.add('Difficulty');
  CheckGroup1.Items.add('Terrain');
  CheckGroup1.Items.add('Distance');
  CheckGroup1.Items.add('Hint'); // Der Hint aus dem Cache
  CheckGroup1.Items.add('User Note'); // Die Usernote die der User selbst eingefügt hat.
  CheckGroup1.Items.add('Hidden Date');
  CheckGroup1.Items.add('Parking Area Coords');
  CheckGroup1.Checked[IndexCode] := true;
  CheckGroup1.Checked[IndexTitle] := true;
End;

Procedure TForm30.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm30.Button1Click(Sender: TObject);
  Function Pretty(attribs: String): String;
  Begin
    result := '';
    If pos('A', attribs) <> 0 Then Begin
      result := R_Archived;
    End;
    If pos('C', attribs) <> 0 Then Begin
      result := result + ' ' + R_modified_coordinates;
    End;
    If pos('F', attribs) <> 0 Then Begin
      result := result + ' ' + R_found;
    End;
    result := trim(result);
  End;

Var
  c, i, j, k: integer;
  b: Boolean;
  sa: Array Of Array Of String;
  d: TDatetime;
  ClearCacheType, TypeSpezifier, DT, s: String;
  sl: TStringList;
  wl: TWaypointList;
Begin
  If CheckGroup1.Checked[IndexParkingAreaCoords] And
    (Not (CheckGroup1.Checked[IndexCoord1] Or CheckGroup1.Checked[IndexCoord2])) Then Begin
    showmessage(R_Error_You_have_to_select_at_least_deg_or_dec_coordinates_to_support_parking_area_coord_export);
    exit;
  End;
  b := false;
  c := 0;
  // Sind Export spalten angewählt ?
  For i := 0 To CheckGroup1.Items.Count - 1 Do Begin
    If CheckGroup1.Checked[i] Then Begin
      b := true;
      inc(c); // Anzahl der zu Exportierenden Spalten
    End;
    If (i = IndexParkingAreaCoords) And (CheckGroup1.Checked[IndexParkingAreaCoords]) Then Begin // Die parkplatz Koordinaten gibt es ja in 2 Formaten, deswegen hier die Aufspaltung
      dec(c);
      If (CheckGroup1.Checked[IndexCoord1]) Then inc(c);
      If (CheckGroup1.Checked[IndexCoord2]) Then inc(c);
    End;
  End;
  If b Then Begin
    b := form1.StringGrid1.RowCount > 1; // Sind Caches angewählt
  End;
  If Not b Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If SaveDialog1.Execute Then Begin
    sa := Nil;
    setlength(sa, c, form1.StringGrid1.RowCount);
    // Die Beschriftungen
    c := 0;
    For i := 0 To CheckGroup1.Items.Count - 1 Do Begin
      If CheckGroup1.Checked[i] Then Begin
        sa[c, 0] := CheckGroup1.Items[i];
        inc(c);
      End;
      If (i = IndexParkingAreaCoords) And (CheckGroup1.Checked[IndexParkingAreaCoords]) Then Begin
        dec(c);
        If (CheckGroup1.Checked[IndexCoord1]) Then Begin
          sa[c, 0] := CheckGroup1.Items[IndexParkingAreaCoords] + ' ' + CheckGroup1.Items[IndexCoord1];
          inc(c);
        End;
        If (CheckGroup1.Checked[IndexCoord2]) Then Begin
          sa[c, 0] := CheckGroup1.Items[IndexParkingAreaCoords] + ' ' + CheckGroup1.Items[IndexCoord2];
          inc(c);
        End;
      End;
    End;
    For j := 1 To form1.StringGrid1.RowCount - 1 Do Begin
      c := 0;
      For i := 0 To CheckGroup1.Items.Count - 1 Do Begin
        If CheckGroup1.Checked[i] Then Begin
          Case i Of
            IndexHiddenDate: Begin
                StartSQLQuery('Select time from caches where name = "' + form1.StringGrid1.Cells[MainColGCCode, j] + '"');
                d := StrToTime(SQLQuery.Fields[0].AsString);
                If d <> -1 Then Begin
                  sa[c, j] := FormatDateTime('DDDDD', d);
                End
                Else Begin
                  sa[c, j] := 'Error';
                End
              End;
            IndexHint: Begin
                StartSQLQuery('Select G_ENCODED_HINTS from caches where name = "' + form1.StringGrid1.Cells[MainColGCCode, j] + '"');
                sa[c, j] := '"' + StringReplace(FromSQLString(SQLQuery.Fields[0].AsString), '"', '""', [rfReplaceAll]) + '"';
              End;
            IndexUserNote: Begin
                StartSQLQuery('Select note from caches where name = "' + form1.StringGrid1.Cells[MainColGCCode, j] + '"');
                sa[c, j] := '"' + StringReplace(FromSQLString(SQLQuery.Fields[0].AsString), '"', '""', [rfReplaceAll]) + '"';
              End;
            IndexCode: sa[c, j] := form1.StringGrid1.Cells[MainColGCCode, j];
            IndexTitle: sa[c, j] := '"' + StringReplace(form1.StringGrid1.Cells[MainColTitle, j], '"', '""', [rfReplaceAll]) + '"';
            IndexParkingAreaCoords: Begin
                dec(c);
                wl := WaypointsFromDB(form1.StringGrid1.Cells[MainColGCCode, j]);
                If (CheckGroup1.Checked[IndexCoord1]) Then Begin
                  inc(c);
                  s := '';
                  For k := 0 To high(wl) Do Begin
                    If lowercase(wl[k].sym) = lowercase('Parking Area') Then Begin
                      s := s + ' ' + CoordToString(wl[k].lat, wl[k].Lon);
                    End;
                  End;
                  If trim(s) = '' Then Begin
                    sa[c, j] := R_None;
                  End
                  Else Begin
                    sa[c, j] := trim(s);
                  End;
                End;
                If (CheckGroup1.Checked[IndexCoord2]) Then Begin
                  inc(c);
                  s := '';
                  For k := 0 To high(wl) Do Begin
                    If lowercase(wl[k].sym) = lowercase('Parking Area') Then Begin
                      s := s + ' ' + format('%0.6f %0.6f', [wl[k].lat, wl[k].Lon]);
                    End;
                  End;
                  If trim(s) = '' Then Begin
                    sa[c, j] := R_None;
                  End
                  Else Begin
                    sa[c, j] := trim(s);
                  End;
                End;
              End;
            IndexCoord2: Begin
                StartSQLQuery('Select lat, lon, cor_lat, cor_lon from caches where name = "' + form1.StringGrid1.Cells[MainColGCCode, j] + '"');
                If SQLQuery.Fields[2].AsFloat <> -1 Then Begin
                  // Die Dose hat Modifizierte Koords, also geben wir diese aus
                  sa[c, j] := format('%0.6f %0.6f', [SQLQuery.Fields[2].AsFloat, SQLQuery.Fields[3].AsFloat], DefFormat);
                End
                Else Begin
                  // Die Normalen Koords der Dose
                  sa[c, j] := format('%0.6f %0.6f', [SQLQuery.Fields[0].AsFloat, SQLQuery.Fields[1].AsFloat], DefFormat);
                End;
              End;
            IndexCoord1: Begin
                StartSQLQuery('Select lat, lon, cor_lat, cor_lon from caches where name = "' + form1.StringGrid1.Cells[MainColGCCode, j] + '"');
                If SQLQuery.Fields[2].AsFloat <> -1 Then Begin
                  // Die Dose hat Modifizierte Koords, also geben wir diese aus
                  sa[c, j] := CoordToString(SQLQuery.Fields[2].AsFloat, SQLQuery.Fields[3].AsFloat);
                End
                Else Begin
                  // Die Normalen Koords der Dose
                  sa[c, j] := CoordToString(SQLQuery.Fields[0].AsFloat, SQLQuery.Fields[1].AsFloat);
                End;
              End;
            IndexState,
              IndexType,
              IndexDifficulty,
              IndexTerrain: Begin
                SplitCacheType(form1.StringGrid1.Cells[MainColType, j], ClearCacheType, TypeSpezifier, DT);
                Case i Of
                  IndexState: sa[c, j] := Pretty(TypeSpezifier);
                  IndexType: sa[c, j] := ClearCacheType;
                  IndexDifficulty: Begin
                      If dt <> '0.00x0.00' Then Begin // Labcaches haben das nicht
                        sa[c, j] := copy(dt, 1, pos('x', dt) - 1);
                        sa[c, j] := FloatToStr(StrToFloat(sa[c, j], DefFormat)); // Umwandeln der Zahlenformatierung in lokales Format
                      End
                      Else Begin
                        sa[c, j] := '-';
                      End;
                    End;
                  IndexTerrain: Begin
                      If dt <> '0.00x0.00' Then Begin // Labcaches haben das nicht
                        sa[c, j] := copy(dt, pos('x', dt) + 1, length(dt));
                        sa[c, j] := FloatToStr(StrToFloat(sa[c, j], DefFormat)); // Umwandeln der Zahlenformatierung in lokales Format
                      End
                      Else Begin
                        sa[c, j] := '-';
                      End;
                    End;
                End;
              End;
            IndexDistance: sa[c, j] := form1.StringGrid1.Cells[MainColDist, j];
          Else Begin
              Raise Exception.Create('Not implemented export for: ' + CheckGroup1.Items[i]);
            End;
          End;
          inc(c);
        End;
      End;
    End;
    // Alle Daten sind gesammelt -> Speichern
    sl := TStringList.Create;
    For j := 0 To Form1.StringGrid1.RowCount - 1 Do Begin
      s := '';
      For i := 0 To c - 1 Do Begin
        If i = 0 Then Begin
          s := sa[i, j];
        End
        Else Begin
          s := s + ';' + sa[i, j];
        End;
      End;
      sl.add(s);
    End;
    // Sicherstellen das der UTF8 BOM enthalten ist, sonst macht excel mucken
    sl.Text := utf8toutf8bom(sl.text);
    sl.SaveToFile(SaveDialog1.FileName);
    sl.free;
    showmessage(R_Finished);
  End;
End;

End.

