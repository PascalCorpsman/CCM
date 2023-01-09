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
Unit Unit17;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, sqldb, uccm;

Type

  { TForm17 }

  TForm17 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure StringGrid1Resize(Sender: TObject);
    Procedure StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
  private
    fGC_Code: String; // Den Brauchts für die Bearbeitung
    Function LCLToWP(Out wp: TWaypoint): Boolean;
    Procedure WaypointToStringgridLine(Const Waypoint: TWaypoint; RowIndex: integer);
    Procedure LoadWaypointlist(GC_Code: String; Const waypoints: TWaypointList);

  public
    Procedure LoadCache(GC_Code: String);
  End;

Const
  WayPointColSym = 0;
  WayPointColName = 1;
  WayPointColKoord = 2;
  WayPointColCMT = 3;

Var
  Form17: TForm17;

Implementation

{$R *.lfm}

Uses unit1, math, ulanguage;

{ TForm17 }

Procedure TForm17.FormCreate(Sender: TObject);
Var
  i: Integer;
Begin
  caption := 'Waypoint Editor';
  StringGrid1.ColWidths[WayPointColSym] := 75;
  StringGrid1.ColWidths[WayPointColName] := 75;
  StringGrid1.ColWidths[WayPointColKoord] := 150;
  StringGrid1.OnDrawCell := @Form1.StringGrid1DrawCell;

  ComboBox1.Clear;
  For i := 0 To Valid_POI_Types_Count - 1 Do Begin
    ComboBox1.Items.Add(POI_Types[i].Sym);
  End;
End;

Procedure TForm17.Button1Click(Sender: TObject);
Var
  wp: TWaypoint;
  i: integer;
  Title_Index: integer;
Begin
  If Not LCLToWP(wp) Then Begin
    showmessage(R_Error_while_parsing_waypoint);
    exit;
  End;
  // Gibt es den Wegpunkt mit dem gewählten titel schon ?
  Title_Index := -1;
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If lowercase(wp.Name) = lowercase(StringGrid1.Cells[WayPointColName, i]) Then Begin
      Title_Index := i;
      break;
    End;
  End;
  // Vorbedingungen prüfen
  If sender = Button1 Then Begin
    // Add
    If Title_index <> -1 Then Begin
      showmessage(format(RF_Waypoint_with_title_already_exists, [wp.Name]));
      exit;
    End;
  End
  Else Begin
    // Overwrite
    If Title_index = -1 Then Begin
      showmessage(format(RF_can_not_find_Waypoint_with_title, [wp.Name]));
      exit;
    End;
  End;
  // Einfügen oder Überschreiben
  If Not WaypointToDB(wp, true) Then Begin
    showmessage(R_Error_while_adding_waypoint);
  End
  Else Begin
    SQLTransaction.Commit;
    If sender = Button1 Then Begin
      // Add
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      Title_Index := StringGrid1.RowCount - 1;
    End;
    WaypointToStringgridLine(wp, Title_Index);
  End;
End;

Procedure TForm17.Button3Click(Sender: TObject);
Var
  wp: TWaypoint;
Begin
  // Delete Waypoint
  If Not LCLToWP(wp) Then Begin
    showmessage(R_Error_while_parsing_waypoint);
    exit;
  End;
  DelWaypoint(wp);
  StringGrid1.DeleteRow(StringGrid1.Selection.Top);
  If StringGrid1.RowCount = 1 Then Begin
    // Die Dose hat gar keine Wegpunkte
    ComboBox1.Text := '';
    Edit1.Text := '';
    Edit2.Text := '';
    Memo1.text := '';
  End
  Else Begin
    // Laden des
    SelectAndScrollToRow(StringGrid1, 1);
    StringGrid1Selection(Nil, 0, 1);
  End;
End;

Procedure TForm17.Button4Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm17.StringGrid1Resize(Sender: TObject);
Var
  i, j: integer;
Begin
  j := 0;
  For i := 0 To StringGrid1.ColCount - 1 Do Begin
    If i <> WayPointColCMT Then Begin
      j := j + StringGrid1.ColWidths[i];
    End;
  End;
  StringGrid1.ColWidths[WayPointColCMT] := max(25, StringGrid1.Width - j - 24);
End;

Procedure TForm17.StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
Begin
  ComboBox1.Text := StringGrid1.Cells[WayPointColSym, arow];
  Edit1.Text := StringGrid1.Cells[WayPointColName, arow];
  Edit2.Text := StringGrid1.Cells[WayPointColKoord, arow];
  Memo1.Text := StringGrid1.Cells[WayPointColCMT, arow];
End;

Procedure TForm17.WaypointToStringgridLine(Const Waypoint: TWaypoint;
  RowIndex: integer);
Begin
  StringGrid1.cells[WayPointColSym, RowIndex] := waypoint.sym;
  StringGrid1.cells[WayPointColName, RowIndex] := waypoint.Name; // Name des Wegpunktes "**Bla123"
  StringGrid1.cells[WayPointColKoord, RowIndex] := CoordToString(waypoint.lat, waypoint.Lon); // lat
  StringGrid1.cells[WayPointColCMT, RowIndex] := waypoint.cmt;
End;

Function TForm17.LCLToWP(Out wp: TWaypoint): Boolean;
Var
  lon: Double;
  lat: Double;
Begin
  result := false;
  wp.Name := Edit1.Text;
  wp.GC_Code := fGC_Code;
  wp.Time := GetTime(now);
  If Not StringToCoord(edit2.text, lat, lon) Then exit;
  wp.lat := lat;
  wp.Lon := lon;
  wp.cmt := Memo1.Text;
  wp.desc := fGC_Code + ' ' + copy(wp.sym, 1, pos(' ', wp.sym) - 1);
  wp.url := '';
  wp.url_name := wp.desc;
  wp.sym := ComboBox1.Text;
  wp.Type_ := 'Waypoint|' + wp.sym;
  wp.Used := false; // Egal, hat nichts mit der DB zu tun, nur damits initialisiert ist.
  result := true;
End;

Procedure TForm17.LoadWaypointlist(GC_Code: String;
  Const waypoints: TWaypointList);
Var
  i: Integer;
Begin
  fGC_Code := GC_Code;
  StringGrid1.BeginUpdate;
  StringGrid1.RowCount := 1 + length(waypoints);
  StringGrid1.FixedRows := 1;
  For i := 0 To high(waypoints) Do Begin
    WaypointToStringgridLine(waypoints[i], 1 + i);
  End;
  StringGrid1.EndUpdate;
  If StringGrid1.RowCount = 1 Then Begin
    // Die Dose hat gar keine Wegpunkte
    ComboBox1.Text := '';
    Edit1.Text := '';
    Edit2.Text := '';
    Memo1.text := '';
  End
  Else Begin
    // Laden des
    SelectAndScrollToRow(StringGrid1, 1);
    StringGrid1Selection(Nil, 0, 1);
  End;
End;

Procedure TForm17.LoadCache(GC_Code: String);
Var
  wl: TWaypointList;
Begin
  wl := WaypointsFromDB(GC_Code);
  StartSQLQuery('Select c.G_NAME from caches c where c.NAME = "' + GC_Code + '"');
  form17.Label2.Caption := GC_Code + ': ' + SQLQuery.Fields[0].AsString;
  form17.LoadWaypointlist(GC_Code, wl);
End;

End.

