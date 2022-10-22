Unit Unit35;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls, Types;

Type

  { TForm35 }

  TForm35 = Class(TForm)
    Button1: TButton;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure StringGrid1DblClick(Sender: TObject);
    Procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    Procedure StringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; Var Handled: Boolean);
    Procedure StringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; Var Handled: Boolean);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    // Dim1 = x, Dim2 = y, Dim3 = Anzahl, Dim4 = MainFormCol
    FFieldInfo: Array[1..13] Of Array Of Array Of Array Of String; // Der 13te Monat erstpart die Sonderfälle
  public
    Function ReloadCachesFromDB(): Tpoint;
  End;

Var
  Form35: TForm35;

Implementation

{$R *.lfm}

Uses usqlite_helper, math, uccm, Unit1, ulanguage;

Var
  scol: integer = -1;
  srow: integer = -1;

  { TForm35 }

Procedure TForm35.FormCreate(Sender: TObject);
Begin
  StringGrid1.ColWidths[0] := 35;
End;

Procedure TForm35.StringGrid1DblClick(Sender: TObject);
Var
  i, j, k, l: integer;
Begin
  If (scol <= 0) Or (srow <= 0) Then exit; // Komplett ungültige Zelle
  If StringGrid1.Cells[scol, srow] = 'X' Then exit; // Diesen Monat gibt es nicht
  form1.StringGrid1.BeginUpdate;
  If (scol = StringGrid1.ColCount - 1) Then Begin
    If (srow = StringGrid1.RowCount - 1) Then Begin
      // Auswahl einfach alles
      form1.ResetMainGridCaptions;
      form1.StringGrid1.RowCount := 1;
      For i := 1 To 12 Do Begin
        For j := 1 To StringGrid1.RowCount - 2 Do Begin
          For k := 0 To high(FFieldInfo[i, j - 1]) Do Begin
            form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
            For l := 0 To form1.StringGrid1.ColCount - 1 Do Begin
              form1.StringGrid1.Cells[l, form1.StringGrid1.RowCount - 1] := FFieldInfo[i, j - 1][k, l];
            End;
          End;
        End;
      End;
    End
    Else Begin
      // Auswahl eines Jahres
      form1.ResetMainGridCaptions;
      form1.StringGrid1.RowCount := 1;
      For i := 1 To 12 Do Begin
        For k := 0 To high(FFieldInfo[i, srow - 1]) Do Begin
          form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
          For l := 0 To form1.StringGrid1.ColCount - 1 Do Begin
            form1.StringGrid1.Cells[l, form1.StringGrid1.RowCount - 1] := FFieldInfo[i, srow - 1][k, l];
          End;
        End;
      End;
    End;
  End
  Else Begin
    If (srow = StringGrid1.RowCount - 1) Then Begin
      // Auswahl eines Monats in Allen Jahren
      form1.ResetMainGridCaptions;
      form1.StringGrid1.RowCount := 1;
      For j := 1 To StringGrid1.RowCount - 2 Do Begin
        For k := 0 To high(FFieldInfo[scol, j - 1]) Do Begin
          form1.StringGrid1.RowCount := form1.StringGrid1.RowCount + 1;
          For l := 0 To form1.StringGrid1.ColCount - 1 Do Begin
            form1.StringGrid1.Cells[l, form1.StringGrid1.RowCount - 1] := FFieldInfo[scol, j - 1][k, l];
          End;
        End;
      End;
    End;
  End;
  If (srow <> StringGrid1.RowCount - 1) And (scol <> StringGrid1.ColCount - 1) Then Begin
    // Auswahl eines einzelnen Monats
    form1.ResetMainGridCaptions;
    form1.StringGrid1.RowCount := high(FFieldInfo[scol, srow - 1]) + 2;
    For j := 0 To high(FFieldInfo[scol, srow - 1]) Do Begin
      For i := 0 To Form1.StringGrid1.ColCount - 1 Do Begin
        form1.StringGrid1.Cells[i, j + 1] := FFieldInfo[scol, srow - 1][j, i];
      End;
    End;
  End;
  form1.StringGrid1.EndUpdate(true);
  form1.StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [form1.StringGrid1.RowCount - 1]);
  form1.StatusBar1.Panels[MainSBarInfo].Text := '';
End;

Procedure TForm35.Button1Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm35.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
Var
  i: integer;
  t: String;
Begin
  If (aCol > 0) And (aRow > 0) Then Begin
    StringGrid1.Canvas.Font.Color := clWhite;
    i := strtointdef(StringGrid1.Cells[aCol, aRow], -1);
    If i <> -1 Then Begin
      If i = 0 Then Begin
        StringGrid1.Canvas.Brush.Color := clWhite;
        StringGrid1.Canvas.Font.Color := clBlack;
      End
      Else Begin
        StringGrid1.Canvas.Brush.Color := RGBToColor(0, 255 - min(128, i), 0);
      End;
    End
    Else Begin
      StringGrid1.Canvas.Brush.Color := clGray;
    End;
  End;
  t := StringGrid1.Cells[aCol, aRow];
  If (arow = 0) And (acol > 0) Then Begin
    t := StringGrid1.Columns[aCol - 1].Title.Caption;
  End;
  StringGrid1.Canvas.Rectangle(aRect.Left - 1, aRect.Top - 1, aRect.Right, aRect.Bottom);
  StringGrid1.Canvas.TextOut((aRect.Left + aRect.Right - StringGrid1.Canvas.TextWidth(t)) Div 2, (aRect.Top + aRect.Bottom - StringGrid1.Canvas.TextHeight(t)) Div 2, t);
  If (aRow = StringGrid1.RowCount - 1) And (acol <> 0) Then Begin // Die Letzte Zeile wird Optisch ein Wenig getrennt
    StringGrid1.Canvas.Pen.Color := clblack;
    StringGrid1.Canvas.Line(aRect.Left - 1, aRect.Top + 1, aRect.Right, aRect.Top + 1);
    StringGrid1.Canvas.Line(aRect.Left - 1, aRect.Top, aRect.Right, aRect.Top);
  End;
  If (aRow <> 0) And (acol = StringGrid1.ColCount - 1) Then Begin // Die Letzte Spalte wird Optisch ein Wenig getrennt
    StringGrid1.Canvas.Pen.Color := clBlack;
    StringGrid1.Canvas.Line(aRect.Left, aRect.Top - 1, aRect.Left, aRect.Bottom);
    StringGrid1.Canvas.Line(aRect.Left + 1, aRect.Top - 1, aRect.Left + 1, aRect.Bottom);
  End;
End;

Procedure TForm35.StringGrid1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; Var Handled: Boolean);
Begin
  StringGrid1.TopRow := StringGrid1.TopRow + 1;
End;

Procedure TForm35.StringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; Var Handled: Boolean);
Begin
  StringGrid1.TopRow := StringGrid1.TopRow - 1;
End;

Procedure TForm35.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  scol := acol;
  srow := arow;
End;

Function TForm35.ReloadCachesFromDB(): Tpoint;
Var
  g, month, years, i, j, k: integer;
  d: TDateTime;
Begin
  result.x := 0; // Die Anzahl der geskippten Caches aufgrund Datum
  result.y := 0; // Die Anzahl der geskippten Lab Caches
  StringGrid1.BeginUpdate;
  years := strtoint(FormatDateTime('YYYY', now)) - 2000;
  month := strtoint(FormatDateTime('MM', now));
  StringGrid1.RowCount := years + 3; // +1 weil das Jahr 2000 ja auch Zählt, +1 Weil Monatssummen
  For i := 0 To years Do Begin
    StringGrid1.Cells[0, i + 1] := inttostr(2000 + i);
  End;
  For i := 1 To StringGrid1.ColCount - 1 Do Begin
    setlength(FFieldInfo[i], StringGrid1.RowCount - 1); // Die Monatssummen kriegen so auch ein Nil Array erspart den Sonderfallaufwand bei minimal mehr Speicher
    For j := 1 To StringGrid1.RowCount - 1 Do Begin
      StringGrid1.Cells[i, j] := '0';
      setlength(FFieldInfo[i][j - 1], 0);
    End;
  End;
  // Aus X-en der Monate die es nicht gibt
  StringGrid1.Cells[1, 1] := 'X';
  StringGrid1.Cells[2, 1] := 'X';
  StringGrid1.Cells[3, 1] := 'X';
  StringGrid1.Cells[4, 1] := 'X';
  For i := month + 1 To 12 Do Begin
    StringGrid1.Cells[i, StringGrid1.RowCount - 2] := 'X';
  End;
  StringGrid1.Cells[0, StringGrid1.RowCount - 1] := R_Sum;
  // So Initialisert ist alles nun wird befüllt
  For i := 1 To form1.StringGrid1.RowCount - 1 Do Begin
    StartSQLQuery('Select Time, G_DIFFICULTY from caches where name ="' + form1.StringGrid1.Cells[MainColGCCode, i] + '"');
    // Ein Labcache hat eine Difficulty von < 0
    If round(SQLQuery.Fields[1].AsFloat * 2) - 2 < 0 Then Begin
      inc(result.y);
      Continue;
    End;
    d := StrToTime(FromSQLString(SQLQuery.Fields[0].AsString));
    If d <> -1 Then Begin
      years := strtoint(FormatDateTime('YYYY', d)) - 2000 + 1;
      month := strtoint(FormatDateTime('MM', d));
      // Das Datum liegt in der Zukunft (z.b. ein Event)
      If (years >= StringGrid1.RowCount - 1) Or (StringGrid1.Cells[month, years] = 'X') Then Begin
        inc(result.x);
        Continue;
      End;
      // Mit Zählen des passenden Monats
      StringGrid1.Cells[month, years] := inttostr(1 + strtoint(StringGrid1.Cells[month, years]));
      years := years - 1;
      // merken der Einträge von Form1
      setlength(FFieldInfo[month, years], high(FFieldInfo[month, years]) + 2);
      setlength(FFieldInfo[month, years][high(FFieldInfo[month, years])], form1.StringGrid1.ColCount);
      For j := 0 To form1.StringGrid1.ColCount - 1 Do Begin
        FFieldInfo[month, years][high(FFieldInfo[month, years])][j] := form1.StringGrid1.Cells[j, i];
      End;
    End
    Else Begin
      inc(result.x);
    End;
  End;
  // Berechnen der Monatssummen
  For i := 1 To 12 Do Begin
    k := 0;
    For j := 1 To StringGrid1.RowCount - 2 Do Begin
      k := k + strtointdef(StringGrid1.Cells[i, j], 0);
    End;
    StringGrid1.Cells[i, StringGrid1.RowCount - 1] := inttostr(k);
  End;
  // Berechnen der Jahressummen
  g := 0; // -- Die Over All Summe brauchen wir ja auch noch
  For j := 1 To StringGrid1.RowCount - 2 Do Begin
    k := 0;
    For i := 1 To 12 Do Begin
      k := k + strtointdef(StringGrid1.Cells[i, j], 0);
    End;
    StringGrid1.Cells[13, j] := inttostr(k);
    g := g + k;
  End;
  StringGrid1.Cells[StringGrid1.ColCount - 1, StringGrid1.RowCount - 1] := inttostr(g);
  StringGrid1.EndUpdate(true);
End;

End.

