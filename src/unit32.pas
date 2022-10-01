Unit Unit32;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, ugctoolwrapper;

Type

  { TForm32 }

  TForm32 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure StringGrid1Click(Sender: TObject);
    Procedure StringGrid1KeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1KeyUp(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    fpocketqueries: TPocketQueries;
    col, row: integer;
    keypressed: Boolean;
  public
    NeedStartScript: Boolean;
    Procedure ReloadScriptCombobox;
  End;

Var
  Form32: TForm32;

Implementation

{$R *.lfm}

Uses usqlite_helper, uccm, LazFileUtils, ulanguage;

Const
  ColChecked = 0;
  ColName = 1;
  ColFileSize = 2;
  ColWPs = 3;
  ColTimeStamp = 4;
  ColLink = 5;

  { TForm32 }

Procedure TForm32.Button1Click(Sender: TObject);
Var
  n: String;
  i: Integer;
Begin
  If Not GCTGetPocketQueries(fpocketqueries) Then exit;
  n := FormatDateTime('dd.mm.yyyy', now);
  StringGrid1.RowCount := 1 + length(fpocketqueries);
  For i := 0 To high(fpocketqueries) Do Begin
    If pos(n, fpocketqueries[i].Timestamp) <> 0 Then Begin
      StringGrid1.Cells[ColChecked, i + 1] := '1';
    End
    Else Begin
      StringGrid1.Cells[ColChecked, i + 1] := '0';
    End;
    StringGrid1.Cells[ColName, i + 1] := fpocketqueries[i].Name;
    StringGrid1.Cells[ColFileSize, i + 1] := fpocketqueries[i].Size;
    StringGrid1.Cells[ColWPs, i + 1] := inttostr(fpocketqueries[i].WPCount);
    StringGrid1.Cells[ColTimeStamp, i + 1] := fpocketqueries[i].Timestamp;
    StringGrid1.Cells[ColLink, i + 1] := fpocketqueries[i].Link;
  End;
  StringGrid1.AutoAdjustColumns;
End;

Procedure TForm32.Button2Click(Sender: TObject);
Var
  i: Integer;
Begin
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[ColChecked, i] := '1';
  End;
End;

Procedure TForm32.Button3Click(Sender: TObject);
Var
  i: Integer;
Begin
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[ColChecked, i] := '0';
  End;
End;

Procedure TForm32.Button4Click(Sender: TObject);
Var
  j, k, i: integer;
  id: String;
  sl: Tstringlist;
  t: int64;
Begin
  NeedStartScript := false;
  t := gettickcount64();
  id := GetValue('General', 'LastImportDir', '');
  If (id = '') Or Not DirectoryExistsUTF8(id) Then Begin
    showmessage(R_The_default_import_directory_was_not_set_yet_please_do_so_now);
    If SelectDirectory(R_Please_select_import_directory, '', id) Then Begin
      SetValue('General', 'LastImportDir', id);
    End
    Else Begin
      exit;
    End;
  End;
  If CheckBox2.Checked Then Begin
    // Vorheriges Rauslöschen aller .zip und .gpx Dateien
    sl := FindAllFiles(id, '', false);
    For i := 0 To sl.count - 1 Do Begin
      Case lowercase(ExtractFileExt(sl[i])) Of
        '.zip',
          '.gpx': Begin
            If Not DeleteFileUTF8(sl[i]) Then Begin
              showmessage(format(RF_Error_could_not_delete, [sl[i]]));
              exit;
            End;
          End;
      End;
    End;
    sl.free;
  End;
  j := 0;
  k := 0;
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[ColChecked, i] = '1' Then Begin
      // Anzeigen wo wir gerade stehen..
      SelectAndScrollToRow(StringGrid1, i);
      Application.ProcessMessages;
      inc(j);
      If GCTDownloadFile(StringGrid1.Cells[ColLink, i], IncludeTrailingPathDelimiter(id) + StringGrid1.Cells[ColName, i] + '.zip') Then Begin
        inc(k);
        StringGrid1.Cells[ColChecked, i] := '0';
      End;
    End;
  End;
  If j <> k Then Begin
    showmessage(R_Could_not_download_all_needed_files_abort_now);
    exit;
  End;
  If j = 0 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If CheckBox1.Checked Then Begin
    NeedStartScript := true;
    close;
  End
  Else Begin
    showmessage(format(RF_Finished_after, [PrettyTime((GetTickCount64() - t))]));
  End;
End;

Procedure TForm32.Button5Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm32.FormCreate(Sender: TObject);
Begin
  caption := 'Download pocket queries';
  Constraints.MinWidth := width;
  Constraints.MinHeight := Height;
  StringGrid1.RowCount := 1;
End;

Procedure TForm32.StringGrid1Click(Sender: TObject);
Begin
  // So ist Spalte 1 Editierbar, und der Rest nicht ;)
  If (col = ColChecked) And (row > 0) And Not Keypressed Then Begin
    If StringGrid1.Cells[col, row] = '1' Then
      StringGrid1.Cells[col, row] := '0'
    Else
      StringGrid1.Cells[col, row] := '1';
  End;
End;

Procedure TForm32.StringGrid1KeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := true;
  If (key = 32) And (row > 0) And (Row < StringGrid1.RowCount) Then Begin
    If StringGrid1.Cells[ColChecked, row] = '1' Then Begin
      StringGrid1.Cells[ColChecked, row] := '0';
    End
    Else Begin
      StringGrid1.Cells[ColChecked, row] := '1';
    End;
  End;
End;

Procedure TForm32.StringGrid1KeyUp(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := false;
End;

Procedure TForm32.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  col := acol;
  row := arow;
End;

Procedure TForm32.ReloadScriptCombobox;
Var
  i: Integer;
Begin
  ComboBox1.Items.Clear;
  For i := 0 To strtoint(getvalue('Scripts', 'Count', '0')) - 1 Do Begin
    ComboBox1.Items.Add(FromSQLString(getvalue('Scripts', 'Name' + inttostr(i), '')));
  End;
  ComboBox1.Text := '';
End;

End.

