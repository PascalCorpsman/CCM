Unit Unit34;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, Menus;

Type

  { TForm34 }

  TForm34 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCreate(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure StringGrid1Click(Sender: TObject);
    Procedure StringGrid1KeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1KeyUp(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1Resize(Sender: TObject);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private

  public

  End;

Const
  LogGCCode_CheckedCol = 0;
  LogGCCode_GCCodeCol = 1;
  LogGCCode_StateCol = 2;
  LogGCCode_DescriptionCol = 3;

Var
  Form34: TForm34;

Implementation

{$R *.lfm}

Uses uccm, ugctoolwrapper, ugctool, ulanguage, math;

Var
  col: integer = -1;
  row: integer = -1;
  Keypressed: Boolean = false;

  { TForm34 }

Procedure TForm34.Button1Click(Sender: TObject);
Var
  r, s, t: String;
  gi: TCacheInfo;
Begin
  If trim(edit1.text) = '' Then exit;
  button1.enabled := false;
  s := edit1.text + ',';
  r := '';
  While length(s) <> 0 Do Begin
    t := trim(copy(s, 1, pos(',', s) - 1));
    delete(s, 1, pos(',', s));
    t := Uppercase(t);
    // Komfortfunktion Anfügen GC, sollte das fehlern :)
    If pos('GC', t) <> 1 Then Begin
      t := 'GC' + t;
    End;
    // 1. Suchen ob wir die Dose evtl schon in der DB haben
    gi.GC_Code := '';
    StartSQLQuery('select c.G_Name, c.G_Found from caches c where c.name="' + ToSQLString(t) + '"');
    If Not SQLQuery.EOF Then Begin
      // Die Dose gibt es doch schon
      gi.GC_Code := t;
      If SQLQuery.Fields[1].AsInteger <> 0 Then Begin
        gi.State := csFound;
      End
      Else Begin
        gi.State := csNotFound;
      End;
      gi.Description := SQLQuery.Fields[0].AsString;
    End;
    // 2. Wir haben die Dose nicht, also schauen wir online nach
    If gi.GC_Code = '' Then Begin
      gi := GCTGetCacheInfo(t);
    End;
    If gi.State = csError Then Begin
      If r <> '' Then r := r + ', ';
      r := r + t;
    End
    Else Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      If gi.State = csNotFound Then Begin
        StringGrid1.Cells[LogGCCode_CheckedCol, StringGrid1.RowCount - 1] := '1';
        StringGrid1.Cells[LogGCCode_StateCol, StringGrid1.RowCount - 1] := R_Not_Found;
      End
      Else Begin
        StringGrid1.Cells[LogGCCode_CheckedCol, StringGrid1.RowCount - 1] := '0';
        StringGrid1.Cells[LogGCCode_StateCol, StringGrid1.RowCount - 1] := R_found;
      End;
      StringGrid1.Cells[LogGCCode_GCCodeCol, StringGrid1.RowCount - 1] := gi.GC_Code;
      StringGrid1.Cells[LogGCCode_DescriptionCol, StringGrid1.RowCount - 1] := gi.Description;
    End;
  End;
  edit1.text := '';
  edit1.SetFocus;
  button1.enabled := true;
  If r <> '' Then Begin
    showmessage(format(RF_Could_not_find_Cache_info_for, [r]));
  End;
End;

Procedure TForm34.Button4Click(Sender: TObject);
Var
  i: integer;
Begin
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[LogGCCode_CheckedCol, i] := '1';
  End;
End;

Procedure TForm34.Button5Click(Sender: TObject);
Var
  i: integer;
Begin
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[LogGCCode_CheckedCol, i] := '0';
  End;
End;

Procedure TForm34.Edit1KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then Begin
    Button1.Click;
  End;
End;

Procedure TForm34.FormCreate(Sender: TObject);
Begin
  Constraints.MinHeight := height;
  Constraints.MinWidth := Width;
  StringGrid1.ColWidths[LogGCCode_StateCol] := 105;
  StringGrid1Resize(Nil);
End;

Procedure TForm34.MenuItem1Click(Sender: TObject);
Begin
  // Open in Browser
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  OpenCacheInBrowser(StringGrid1.Cells[LogGCCode_GCCodeCol, row]);
End;

Procedure TForm34.StringGrid1Click(Sender: TObject);
Begin
  // So ist Spalte 1 Editierbar, und der Rest nicht ;)
  If (col = LogGCCode_CheckedCol) And (row > 0) And Not Keypressed Then Begin
    If StringGrid1.Cells[col, row] = '1' Then
      StringGrid1.Cells[col, row] := '0'
    Else
      StringGrid1.Cells[col, row] := '1';
  End;
End;

Procedure TForm34.StringGrid1KeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := true;
  If (key = 32) And (row > 0) And (Row < StringGrid1.RowCount) Then Begin
    If StringGrid1.Cells[LogGCCode_CheckedCol, row] = '1' Then Begin
      StringGrid1.Cells[LogGCCode_CheckedCol, row] := '0';
    End
    Else Begin
      StringGrid1.Cells[LogGCCode_CheckedCol, row] := '1';
    End;
  End;
End;

Procedure TForm34.StringGrid1KeyUp(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := false;
End;

Procedure TForm34.StringGrid1Resize(Sender: TObject);
Begin
  StringGrid1.ColWidths[LogGCCode_DescriptionCol] := max(25, StringGrid1.Width
    - StringGrid1.ColWidths[LogGCCode_CheckedCol]
    - StringGrid1.ColWidths[LogGCCode_GCCodeCol]
    - StringGrid1.ColWidths[LogGCCode_StateCol]
    - 24);
End;

Procedure TForm34.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  col := acol;
  row := arow;
End;

End.

