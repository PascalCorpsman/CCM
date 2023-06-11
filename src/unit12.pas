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
Unit Unit12;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, ExtCtrls, Buttons, Types, uccm;

Const
  PreviewIndexUnknown = -1; // Es gibt mehr als die unten gelisteten Cachetypen, alle anderen stehen dann hier..
  PreviewIndexAll = 0;
  PreviewIndexTraditionalCache = 1;
  PreviewIndexMultiCache = 2;
  PreviewIndexMysterieCache = 3;
  PreviewIndexLetterbox = 4;
  PreviewIndexWhereIGo = 5;
  PreviewIndexEarthCache = 6;
  PreviewIndexVirtualCache = 7;
  PreviewIndexEvent = 8;
  PreviewIndexCito = 9;
  PreviewIndexWebcamCache = 10;

Type

  TCacheStat = Record
    Kind: integer;
    GC_Code: String;
    MainFormInfo: Array Of String;
    Attributes: Array Of TAttribute;
    Size: Integer;
  End;

  { TForm12 }

  TForm12 = Class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    SpeedButton112: TSpeedButton;
    SpeedButton113: TSpeedButton;
    SpeedButton114: TSpeedButton;
    SpeedButton115: TSpeedButton;
    SpeedButton116: TSpeedButton;
    SpeedButton117: TSpeedButton;
    SpeedButton118: TSpeedButton;
    SpeedButton119: TSpeedButton;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure ComboBox1Change(Sender: TObject);
    Procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    Procedure FormCreate(Sender: TObject);
    Procedure SpeedButton112Click(Sender: TObject);
    Procedure StringGrid1DblClick(Sender: TObject);
    Procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    { private declarations }
    scol: integer;
    srow: integer;
    fcaches: Array[0..9, 0..9] Of Array Of TCacheStat;
    Procedure SelectByAttrib(Sender: TObject);
  public
    { public declarations }
    Procedure ClearCacheStats;
    Function ReloadCachesFromDB: integer;
    Procedure VisualiseCaches(Selector: integer; FinalRun: Boolean);
  End;

Var
  Form12: TForm12;

Implementation

Uses math, unit1, ulanguage;

{$R *.lfm}

{ TForm12 }

Procedure TForm12.Button1Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm12.ComboBox1Change(Sender: TObject);
Begin
  VisualiseCaches(ComboBox1.ItemIndex, true);
End;

Procedure TForm12.ComboBox1DrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
Begin
  ComboBox1.Canvas.FillRect(arect);
  (*
  All
  Tradies
  Multies
  Mysteries
  Letterboxes
  Where I Go's
  Earthcaches
  Virtual
  Event
  Cito
  Webcam
  *)
  Case Index Of
    PreviewIndexAll: ComboBox1.Canvas.TextRect(ARect, ARect.Left + 1, ARect.Top + 1, ComboBox1.Items[Index]);
    PreviewIndexTraditionalCache: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexTraditionalCache);
    PreviewIndexMultiCache: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexMultiCache);
    PreviewIndexMysterieCache: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexMysterieCache);
    PreviewIndexLetterbox: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexLetterbox);
    PreviewIndexWhereIGo: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexWhereIGo);
    PreviewIndexEarthCache: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexEarthCache);
    PreviewIndexVirtualCache: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexVirtualCache);
    PreviewIndexEvent: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexEventCache);
    PreviewIndexCito: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexCITO);
    PreviewIndexWebcamCache: form1.ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, MainImageIndexWebcamCache);
  End;
End;

Procedure TForm12.FormCreate(Sender: TObject);
Begin
  Constraints.MinWidth := Width;
  Constraints.MaxWidth := Width;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;
  caption := '81-Matrix';
  StringGrid1.Cells[0, 0] := '';
  StringGrid1.Cells[1, 0] := '1';
  StringGrid1.Cells[2, 0] := '1.5';
  StringGrid1.Cells[3, 0] := '2';
  StringGrid1.Cells[4, 0] := '2.5';
  StringGrid1.Cells[5, 0] := '3';
  StringGrid1.Cells[6, 0] := '3.5';
  StringGrid1.Cells[7, 0] := '4';
  StringGrid1.Cells[8, 0] := '4.5';
  StringGrid1.Cells[9, 0] := '5';
  StringGrid1.Cells[10, 0] := '';
  StringGrid1.Cells[0, 1] := '1';
  StringGrid1.Cells[0, 2] := '1.5';
  StringGrid1.Cells[0, 3] := '2';
  StringGrid1.Cells[0, 4] := '2.5';
  StringGrid1.Cells[0, 5] := '3';
  StringGrid1.Cells[0, 6] := '3.5';
  StringGrid1.Cells[0, 7] := '4';
  StringGrid1.Cells[0, 8] := '4.5';
  StringGrid1.Cells[0, 9] := '5';
  StringGrid1.Cells[0, 10] := '';

End;

Procedure TForm12.SpeedButton112Click(Sender: TObject);
Var
  selector, sIndex: integer;
  x, y, i, j: integer;
Begin
  // Selektiert nach Size und Selector
  sIndex := TSpeedButton(sender).ImageIndex;

  form1.StringGrid1.BeginUpdate;
  form1.ResetMainGridCaptions;
  form1.StringGrid1.RowCount := 1;
  selector := ComboBox1.ItemIndex;
  For x := 1 To 9 Do Begin
    For y := 1 To 9 Do Begin
      For i := 0 To length(fcaches[x - 1, y - 1]) - 1 Do Begin
        If (fcaches[x - 1, y - 1][i].Size = sIndex) And
          ((selector = PreviewIndexAll) Or
          (fcaches[x - 1, y - 1][i].Kind = selector)) Then Begin
          form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
          For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
            Form1.StringGrid1.Cells[j, form1.StringGrid1.RowCount - 1] := fcaches[x - 1, y - 1][i].MainFormInfo[j];
          End;
        End;
      End;
    End;
  End;
  form1.StringGrid1.EndUpdate(true);
  form1.StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [form1.StringGrid1.RowCount - 1]);
  form1.StatusBar1.Panels[MainSBarInfo].Text := '';
End;

Procedure TForm12.StringGrid1DblClick(Sender: TObject);
Var
  x, y, i, j: Integer;
Begin
  // Beim Doppelklick auf die Zellen dann alle diese Dosen in der Form1 Selectiert werden
  // Eine Dose aus der 81-Matrix
  If (scol > 0) And (scol < 10) And
    (srow > 0) And (srow < 10) Then Begin
    form1.StringGrid1.BeginUpdate;
    form1.ResetMainGridCaptions;
    form1.StringGrid1.RowCount := 1;
    For i := 0 To length(fcaches[scol - 1, srow - 1]) - 1 Do Begin
      If (fcaches[scol - 1, srow - 1][i].Kind = ComboBox1.ItemIndex) Or (0 = ComboBox1.ItemIndex) Then Begin
        form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
        For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
          Form1.StringGrid1.Cells[j, form1.StringGrid1.RowCount - 1] := fcaches[scol - 1, srow - 1][i].MainFormInfo[j];
        End;
      End;
    End;
    form1.StringGrid1.EndUpdate(true);
  End;
  // Eine Dose aus der D-Reihe
  If (scol = 10) And (srow < 10) Then Begin
    form1.StringGrid1.BeginUpdate;
    form1.ResetMainGridCaptions;
    form1.StringGrid1.RowCount := 1;
    For x := 1 To 10 Do Begin
      For i := 0 To length(fcaches[x - 1, srow - 1]) - 1 Do Begin
        If (fcaches[x - 1, srow - 1][i].Kind = ComboBox1.ItemIndex) Or (0 = ComboBox1.ItemIndex) Then Begin
          form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
          For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
            Form1.StringGrid1.Cells[j, form1.StringGrid1.RowCount - 1] := fcaches[x - 1, srow - 1][i].MainFormInfo[j];
          End;
        End;
      End;
    End;
    form1.StringGrid1.EndUpdate(true);
  End;
  // Eine Dose aus der T-Reihe
  If (scol < 10) And (srow = 10) Then Begin
    form1.StringGrid1.BeginUpdate;
    form1.ResetMainGridCaptions;
    form1.StringGrid1.RowCount := 1;
    For y := 1 To 10 Do Begin
      For i := 0 To length(fcaches[scol - 1, y - 1]) - 1 Do Begin
        If (fcaches[scol - 1, y - 1][i].Kind = ComboBox1.ItemIndex) Or (0 = ComboBox1.ItemIndex) Then Begin
          form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
          For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
            Form1.StringGrid1.Cells[j, form1.StringGrid1.RowCount - 1] := fcaches[scol - 1, y - 1][i].MainFormInfo[j];
          End;
        End;
      End;
    End;
    form1.StringGrid1.EndUpdate(true);
  End;
  // Alle
  If (scol = 10) And (srow = 10) Then Begin
    form1.StringGrid1.BeginUpdate;
    form1.ResetMainGridCaptions;
    form1.StringGrid1.RowCount := 1;
    For x := 1 To 10 Do Begin
      For y := 1 To 10 Do Begin
        For i := 0 To length(fcaches[x - 1, y - 1]) - 1 Do Begin
          If (fcaches[x - 1, y - 1][i].Kind = ComboBox1.ItemIndex) Or (0 = ComboBox1.ItemIndex) Then Begin
            form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
            For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
              Form1.StringGrid1.Cells[j, form1.StringGrid1.RowCount - 1] := fcaches[x - 1, y - 1][i].MainFormInfo[j];
            End;
          End;
        End;
      End;
    End;
    form1.StringGrid1.EndUpdate(true);
  End;
  form1.StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [form1.StringGrid1.RowCount - 1]);
  form1.StatusBar1.Panels[MainSBarInfo].Text := '';
End;

Procedure TForm12.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
Var
  i: integer;
Begin
  StringGrid1.Canvas.Brush.Color := clwhite;
  StringGrid1.Canvas.Pen.Color := clwhite;
  If (aCol > 0) And (aRow > 0) And (aCol < 10) And (aRow < 10) Then Begin
    StringGrid1.Canvas.Pen.Color := clGray;
    i := strtoint(StringGrid1.Cells[aCol, aRow]);
    If i <> 0 Then Begin
      StringGrid1.Canvas.Brush.Color := RGBToColor(0, 255 - min(128, i), 0);
    End;
  End;
  If (((acol = 10) And (arow <> 0)) Or
    ((arow = 10) And (acol <> 0)))
    And (Not ((arow = 10) And (acol = 10))) Then Begin
    StringGrid1.Canvas.brush.Color := clSilver;
  End;
  StringGrid1.Canvas.Rectangle(aRect.Left - 1, aRect.Top - 1, aRect.Right, aRect.Bottom);
  StringGrid1.Canvas.TextOut((aRect.Left + aRect.Right - StringGrid1.Canvas.TextWidth(StringGrid1.Cells[aCol, aRow])) Div 2, (aRect.Top + aRect.Bottom - StringGrid1.Canvas.TextHeight(StringGrid1.Cells[aCol, aRow])) Div 2, StringGrid1.Cells[aCol, aRow]);
End;

Procedure TForm12.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  scol := acol;
  srow := arow;
End;

Procedure TForm12.SelectByAttrib(Sender: TObject);
  Function ListHasAttrib(Const List: Array Of TAttribute; id, inc: integer): Boolean;
  Var
    i: Integer;
  Begin
    result := false;
    For i := 0 To high(list) Do Begin
      If (list[i].id = id) And (list[i].inc = inc) Then Begin
        result := true;
        exit;
      End;
    End;
  End;

Var
  id, inc, x, y, i, j: integer;
Begin
  // Todo: Bäh, das knallt, sobald es ein Attribut gibt, welches numerisch > 999 ist :(
  id := TImage(sender).Tag Mod 1000;
  inc := TImage(sender).Tag Div 1000;
  // Laden aller Caches die die ID / Inc Kombination in ihren Attributen haben..
  form1.StringGrid1.BeginUpdate;
  form1.StringGrid1.RowCount := 1;
  For x := 1 To 10 Do Begin
    For y := 1 To 10 Do Begin
      For i := 0 To length(fcaches[x - 1, y - 1]) - 1 Do Begin
        If (fcaches[x - 1, y - 1][i].Kind = ComboBox1.ItemIndex) Or (0 = ComboBox1.ItemIndex) Then Begin
          If ListHasAttrib(fcaches[x - 1, y - 1][i].Attributes, id, inc) Then Begin
            form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
            For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
              Form1.StringGrid1.Cells[j, form1.StringGrid1.RowCount - 1] := fcaches[x - 1, y - 1][i].MainFormInfo[j];
            End;
          End;
        End;
      End;
    End;
  End;
  form1.StringGrid1.EndUpdate(true);
  form1.StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [form1.StringGrid1.RowCount - 1]);
  form1.StatusBar1.Panels[MainSBarInfo].Text := '';
End;

Procedure TForm12.ClearCacheStats;
Var
  i, j, k: Integer;
Begin
  scol := 0;
  srow := 0;
  For i := 0 To 9 Do Begin
    For j := 0 To 9 Do Begin
      For k := 0 To high(fcaches[i, j]) Do Begin
        SetLength(fcaches[i, j][k].MainFormInfo, 0);
      End;
      SetLength(fcaches[i, j], 0);
    End;
  End;
  label5.caption := '0';
  label6.caption := '0';
  label7.caption := '0';
  label8.caption := '0';
  label9.caption := '0';
  label10.caption := '0';
  label11.caption := '0';
  label12.caption := '0';
End;

Function TForm12.ReloadCachesFromDB: integer;
Type
  TSAttribute = Record
    GC_Code: String;
    id: integer;
    inc: integer;
    text: String;
  End;
Var
  a: Array Of TSAttribute;
  c, x, y, z, i, j: Integer;
  f1, f2: Double;
Begin
  result := 0;
  scol := 0;
  srow := 0;
  ClearCacheStats();
  // Füllen mit den Einzelwerten
  For i := 1 To form1.StringGrid1.RowCount - 1 Do Begin
    StartSQLQuery('Select G_DIFFICULTY, G_TERRAIN, G_Type, G_CONTAINER from caches where name ="' + form1.StringGrid1.Cells[MainColGCCode, i] + '"');
    f1 := SQLQuery.Fields[1].AsFloat;
    f2 := SQLQuery.Fields[0].AsFloat;
    x := round(f1 * 2) - 2;
    y := round(f2 * 2) - 2;
    If (x < 0) Or (y < 0) Then Begin // Ist die Dose ein Lab-Cache, dann hat sie ungültige DT-Wertungen und damit wird sie ignoriert.
      inc(result);
    End
    Else Begin
      setlength(fcaches[x, y], high(fcaches[x, y]) + 2);
      fcaches[x, y][high(fcaches[x, y])].GC_Code := form1.StringGrid1.Cells[MainColGCCode, i];
      fcaches[x, y][high(fcaches[x, y])].Size := CacheSizeToIndex(SQLQuery.Fields[3].AsString);
      setlength(fcaches[x, y][high(fcaches[x, y])].MainFormInfo, form1.StringGrid1.ColCount);
      For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
        fcaches[x, y][high(fcaches[x, y])].MainFormInfo[j] := form1.StringGrid1.Cells[j, i];
      End;
      (*
       * Ist a bissl Unglücklich aber die IconIndexe von Form1 müssen hier in die Iconindexe der Previewform umgewandelt werden
       *)
      Case form1.CacheTypeToIconIndex(SQLQuery.Fields[2].AsString) Of
        MainImageIndexTraditionalCache: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexTraditionalCache;
        MainImageIndexMultiCache: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexMultiCache;
        MainImageIndexMysterieCache: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexMysterieCache;
        MainImageIndexLetterbox: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexLetterbox;
        MainImageIndexWhereIGo: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexWhereIGo;
        MainImageIndexEarthCache: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexEarthCache;
        MainImageIndexVirtualCache: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexVirtualCache;
        MainImageIndexEventCache: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexEvent;
        MainImageIndexCITO: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexCito;
        MainImageIndexWebcamCache: fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexWebcamCache;
      Else
        fcaches[x, y][high(fcaches[x, y])].Kind := PreviewIndexUnknown; // Icontyp nicht gelistet
      End;
      { -- Das wurde durch den Codeblock unten ersetzt, da es langsammer ist, witzigerweise bereits ab 30-50 Dosen, Bei > 2000 Dosen macht es Faktor 3-5 aus
      // Der Cache wird berücksichtigt, also sammeln wir nun noch alle seine Attribute
      StartSQLQuery('Select a.id, a.inc, Attribute_text from caches c, attributes a where (c.name ="' + form1.StringGrid1.Cells[MainColGCCode, i] + '") and (c.name = a.cache_name)');
      //StartSQLQuery('Select a.id, a.inc, Attribute_text from caches c inner join attributes a on c.name = a.cache_name where (c.name ="' + form1.StringGrid1.Cells[MainColGCCode, i] + '")'); // -- Die Inner Join Variante
      c := 0;
      setlength(fcaches[x, y][high(fcaches[x, y])].Attributes, 25); // Die Online Listings lassen maximal 12 Attribute zu, daher ist das hier ausreichend
      While Not SQLQuery.EOF Do Begin
        fcaches[x, y][high(fcaches[x, y])].Attributes[c].id := SQLQuery.Fields[0].AsInteger;
        fcaches[x, y][high(fcaches[x, y])].Attributes[c].inc := SQLQuery.Fields[1].AsInteger;
        fcaches[x, y][high(fcaches[x, y])].Attributes[c].Attribute_Text := SQLQuery.Fields[2].AsString;
        inc(c);
        If c > high(fcaches[x, y][high(fcaches[x, y])].Attributes) Then Begin // Überlaufschutz sollte es je doch mal mehr attribute geben ...
          setlength(fcaches[x, y][high(fcaches[x, y])].Attributes, high(fcaches[x, y][high(fcaches[x, y])].Attributes) + 26);
        End;
        SQLQuery.Next;
      End;
      setlength(fcaches[x, y][high(fcaches[x, y])].Attributes, c);
      //}
    End;
  End;
  // Wir zeigen die ersten Zwischenergebnisse schon mal an, dann muss der User nicht so lange warten.
  ComboBox1.ItemIndex := 0;
  VisualiseCaches(PreviewIndexAll, false);
  If Not form12.Visible Then Begin
    form12.show;
  End;
  Application.ProcessMessages;
  //{ -- Anfang Optimierter Block // Alle Attribute Aktualisieren
  // Der Cache wird berücksichtigt, also sammeln wir nun noch alle seine Attribute
  c := 0;
  StartSQLQuery('Select cache_name, id, inc, Attribute_text from attributes order by cache_name asc');
  a := Nil;
  setlength(a, 1024);
  While Not SQLQuery.EOF Do Begin
    a[c].GC_Code := SQLQuery.Fields[0].AsString;
    a[c].id := SQLQuery.Fields[1].AsInteger;
    a[c].inc := SQLQuery.Fields[2].AsInteger;
    a[c].text := SQLQuery.Fields[3].AsString;
    inc(c);
    If c > high(a) Then Begin
      setlength(a, length(a) + 1024);
    End;
    SQLQuery.Next;
  End;
  setlength(a, c);
  For x := 0 To 9 Do Begin
    For y := 0 To 9 Do Begin
      For z := 0 To high(fcaches[x, y]) Do Begin
        c := 0;
        setlength(fcaches[x, y][z].Attributes, 128);
        For i := 0 To high(a) Do Begin
          If a[i].GC_Code = fcaches[x, y][z].GC_Code Then Begin
            fcaches[x, y][z].Attributes[c].id := a[i].id;
            fcaches[x, y][z].Attributes[c].inc := a[i].inc;
            fcaches[x, y][z].Attributes[c].Attribute_Text := a[i].text;
            inc(c);
            If c > high(fcaches[x, y][z].Attributes) Then Begin // Das Darf eigentlich nicht vorkommen da es nur 70+41=111 Attribute gibt, aber man weis ja nie was mal kommt...
              setlength(fcaches[x, y][z].Attributes, high(fcaches[x, y][z].Attributes) + 129);
            End;
          End
          Else Begin
            If c <> 0 Then break; // Abbruch, da keine weiteren Attribute für den Cache mehr kommen
          End;
        End;
        setlength(fcaches[x, y][z].Attributes, c);
      End;
    End;
  End;
  setlength(a, 0);
  // -- Ende Optimierter Block }
  ComboBox1.ItemIndex := 0;
  VisualiseCaches(PreviewIndexAll, true);
  (*
   * Getestet mit einer Abfrage von ca 4477 Caches
   * Orig                =  2330 ms (Aufbau Stringgrid = 900ms, Aufbau Attribute = 1430ms)
   * Inner Join          = 12500 ms
   *  Naiv implementiert = 12900 ms
   *)
End;

Procedure TForm12.VisualiseCaches(Selector: integer; FinalRun: Boolean);
Var
  Attributes: Array Of Record
    id: integer;
    inc: integer;
    Count: integer;
    Text: String;
  End;

  Procedure CountAttribs(Const arr: Array Of TAttribute);
  Var
    i, j: integer;
  Begin
    For i := 0 To high(arr) Do Begin
      For j := 0 To high(Attributes) Do Begin
        If (Attributes[j].id = arr[i].id) And (Attributes[j].inc = arr[i].inc) Then Begin
          // Das Attribut gibt es schon also zählen wir es
          Attributes[j].Count := Attributes[j].Count + 1;
          break;
        End;
        If (Attributes[j].id = -1) Then Begin // Wir sind durch den Initialisierten Bereich durchgelaufen und initialisieren ein neues Feld mit den Attributen
          Attributes[j].id := arr[i].id;
          Attributes[j].inc := arr[i].inc;
          Attributes[j].Text := arr[i].Attribute_Text;
          Attributes[j].Count := 1;
          break;
        End;
        If j = high(Attributes) Then Begin
          // Wenn wir hier her kamen, dann ist das Attribute Array zu klein gewählt worden => Wir machen es größer
          setlength(Attributes, high(Attributes) + 2);
          Attributes[high(Attributes)].id := arr[i].id;
          Attributes[high(Attributes)].inc := arr[i].inc;
          Attributes[high(Attributes)].Text := arr[i].Attribute_Text;
          Attributes[high(Attributes)].Count := 1;
        End;
      End;
    End;
  End;

  Function CountOf(Const Data: Array Of TCacheStat; Selector: integer): integer;
  Var
    i: integer;
    l: TLabel;
  Begin
    result := 0;
    For i := 0 To high(data) Do Begin
      If data[i].Kind = Selector Then Begin
        inc(result);
        CountAttribs(data[i].Attributes);
        l := TLabel(FindComponent('Label' + inttostr(5 + data[i].Size)));
        If assigned(l) Then Begin
          l.caption := inttostr(strtoint(l.caption) + 1);
        End
        Else Begin
          // Damn, das darf nicht vorkommen
        End;
      End;
    End;
  End;

Var
  c, d, t, x, y, i, j, k: Integer;
  b: TBitmap;
  img: TImage;
  lpos, lneg, l: TLabel;
  p: TScrollBox;
Begin
  //  Löschen aller alten Attribute und dazugehörigen Labels..
  For i := ScrollBox1.ComponentCount - 1 Downto 0 Do Begin
    If (ScrollBox1.Components[i] Is TImage) Or (ScrollBox1.Components[i] Is TLabel) Then ScrollBox1.Components[i].Free;
  End;
  For i := ScrollBox2.ComponentCount - 1 Downto 0 Do Begin
    If (ScrollBox2.Components[i] Is TImage) Or (ScrollBox2.Components[i] Is TLabel) Then ScrollBox2.Components[i].Free;
  End;
  label5.caption := '0';
  label6.caption := '0';
  label7.caption := '0';
  label8.caption := '0';
  label9.caption := '0';
  label10.caption := '0';
  label11.caption := '0';
  label12.caption := '0';
  setlength(Attributes, 200); // Egal wie Groß wird im zweifel erweitert
  For i := 0 To high(Attributes) Do Begin // Alle Uninitialisiert
    Attributes[i].id := -1;
  End;
  form12.StringGrid1.BeginUpdate;
  d := 0;
  t := 0;
  // Bilden der einzelnen Summen nach D / T- Wertung
  For i := 0 To 9 Do Begin
    For j := 0 To 9 Do Begin
      If Selector = PreviewIndexAll Then Begin
        form12.StringGrid1.Cells[i + 1, j + 1] := inttostr(length(fcaches[i, j]));
        t := t + (i + 2) * length(fcaches[i, j]); // Aufsummieren der 2 Fachen T-Summe
        d := d + (j + 2) * length(fcaches[i, j]); // Aufsummieren der 2 Fachen D-Summe
        For k := 0 To high(fcaches[i, j]) Do Begin
          CountAttribs(fcaches[i, j][k].Attributes);
          l := TLabel(FindComponent('Label' + inttostr(5 + fcaches[i, j][k].Size)));
          If assigned(l) Then Begin
            l.caption := inttostr(strtoint(l.caption) + 1);
          End
          Else Begin
            // Damn, das darf nicht vorkommen
          End;
        End;
      End
      Else Begin
        c := CountOf(fcaches[i, j], Selector); // Der Aufruf CountOf hat den Nebeneffect CountAttribs
        form12.StringGrid1.Cells[i + 1, j + 1] := inttostr(c);
        t := t + (i + 2) * c; // Aufsummieren der 2 Fachen T-Summe
        d := d + (j + 2) * c; // Aufsummieren der 2 Fachen D-Summe
      End;
    End;
  End;
  // Füllen mit den Summen
  For i := 1 To 9 Do Begin
    x := 0;
    y := 0;
    For j := 1 To 9 Do Begin
      x := x + strtoint(form12.StringGrid1.Cells[i, j]);
      y := y + strtoint(form12.StringGrid1.Cells[j, i]);
    End;
    form12.StringGrid1.Cells[i, 10] := inttostr(x);
    form12.StringGrid1.Cells[10, i] := inttostr(y);
  End;
  x := 0;
  For i := 1 To 9 Do Begin
    x := x + strtoint(form12.StringGrid1.Cells[i, 10]);
  End;
  form12.StringGrid1.Cells[10, 10] := inttostr(x);
  form12.StringGrid1.EndUpdate();
  form12.StringGrid1.Invalidate;
  // X = Anzahl der Caches gesammt, d, t = doppelte D/T-Summe
  If x = 0 Then Begin
    label4.caption := format('%s %s: %0.2f' + LineEnding + '%s %s: %0.2f', [R_average, R_Difficulty, 0.0, R_average, R_terrain, 0.0]);
  End
  Else Begin
    label4.caption := format('%s %s: %0.2f' + LineEnding + '%s %s: %0.2f', [R_average, R_Difficulty, d / (2 * x), R_average, R_terrain, t / (2 * x)]);
  End;
  // Visualisieren der oben gesammelten Attribut informationen
  lpos := Nil;
  lneg := Nil;
  If (high(Attributes) = -1) Or (Attributes[0].id = -1) Then Begin
    // Wenn das Gerade der Pass ist wo die Attribute noch fehlen, dann zeigen wir das dem User an
    lpos := TLabel.Create(ScrollBox1);
    lpos.Parent := ScrollBox1;
    lpos.left := 15;
    lpos.top := 15;
    lpos.caption := r_Loading;
    lneg := TLabel.Create(ScrollBox2);
    lneg.Parent := ScrollBox2;
    lneg.left := 15;
    lneg.top := 15;
    lneg.caption := r_Loading;
  End;
  ScrollBox1.DisableAlign;
  ScrollBox2.DisableAlign;
  For i := 0 To high(Attributes) Do Begin
    If Attributes[i].id = -1 Then break;
    b := GetAttribImage(Attributes[i].id, Attributes[i].inc <> 0);
    If Attributes[i].inc <> 0 Then Begin
      p := ScrollBox1;
    End
    Else Begin
      p := ScrollBox2;
    End;
    img := TImage.Create(p);
    img.Parent := p;
    l := TLabel.Create(p);
    l.Parent := p;
    img.Picture.Assign(b);
    img.Width := b.Width;
    img.Height := b.Height;
    img.Hint := Attributes[i].Text;
    img.ShowHint := true;
    // Todo: Bäh, das knallt, sobald es ein Attribut gibt, welches numerisch > 999 ist :(
    If Attributes[i].id >= 1000 Then Begin
      Raise Exception.Create('Please contact programmer, attribut with value > 999 found.');
    End;
    img.Tag := Attributes[i].id + 1000 * Attributes[i].inc;
    img.OnDblClick := @SelectByAttrib;
    img.Transparent := true;
    b.free;
    img.Left := ((p.ComponentCount Div 2) - 1) * (img.Width + 5);
    img.Top := 2;
    l.left := img.left;
    l.top := img.top + img.Height;
    l.caption := inttostr(Attributes[i].Count);
  End;
  // Es Gibt Attribute, aber keine Passen -> aus den Labeln muss nun ein "Keine"
  If FinalRun And assigned(lpos) Then Begin
    lpos.Caption := R_Not_Found;
    lneg.Caption := R_Not_Found;
  End;
  ScrollBox1.EnableAlign;
  ScrollBox2.EnableAlign;
End;

End.

