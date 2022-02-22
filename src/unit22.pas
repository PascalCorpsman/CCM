Unit Unit22;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, Menus, uccm;

Type

  { TForm22 }

  TForm22 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    ComboBox1: TComboBox;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure MenuItem2Click(Sender: TObject);
    Procedure MenuItem4Click(Sender: TObject);
    Procedure MenuItem5Click(Sender: TObject);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    { private declarations }
    fFieldNotes: tfieldNoteList;
    fFavsAvail: integer;
    Procedure ApplyMetaInfo(RowIndex: integer; Cache: String);
  public
    { public declarations }
    Procedure LoadOnlineLogSettings(FieldNoteList: tfieldNoteList);
  End;

Const
  (*
   * Achtung, in LoadOnlineLogSettings ist die Reihenfolge hart Codiert, das hier zu ändern ist also gefährlich !!
   *)
  LogOnlineColChecked = 0;
  LogOnlineColType = 1;
  LogOnlineColFav = 2;
  LogOnlineColCode = 3;
  LogOnlineColDescription = 4;
  LogOnlineColFirstTB = 5;

Var
  Form22: TForm22;

Implementation

{$R *.lfm}

Uses ugctoolwrapper, unit10, unit1, unit4, ulanguage;

Var
  row: integer = -1;

  { TForm22 }

Procedure TForm22.FormCreate(Sender: TObject);
Begin
  caption := 'Prepare caches for online logging.';
  StringGrid1.OnDrawCell := @form1.StringGrid1DrawCell;
End;

Procedure TForm22.MenuItem1Click(Sender: TObject);
Var
  i: integer;
Begin
  // All TBs in Row
  For i := LogOnlineColFirstTB To StringGrid1.ColCount - 1 Do Begin
    StringGrid1.Cells[i, StringGrid1.Selection.Top] := '1';
  End;
End;

Procedure TForm22.MenuItem2Click(Sender: TObject);
Var
  i: integer;
Begin
  // No TB in Row
  For i := LogOnlineColFirstTB To StringGrid1.ColCount - 1 Do Begin
    StringGrid1.Cells[i, StringGrid1.Selection.Top] := '0';
  End;
End;

Procedure TForm22.MenuItem4Click(Sender: TObject);
Begin
  form1.MenuItem50Click(Nil);
  StringGrid1.Invalidate;
End;

Procedure TForm22.MenuItem5Click(Sender: TObject);
Begin
  // Open Cache im Browser
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  OpenCacheInBrowser(StringGrid1.Cells[LogOnlineColCode, row]);
End;

Procedure TForm22.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  row := arow;
End;

Procedure TForm22.Button2Click(Sender: TObject);
Var
  Cnt, j, i: Integer;
  Log: tfieldNote;
  DoNotClose: Boolean;
  Errors: String;
Begin
  // Log All
  Button2.enabled := false;
  self.Enabled := false;
  form4.RefresStatsMethod(R_Starting, 0, 0, true);
  Application.ProcessMessages;
  Cnt := 0;
  DoNotClose := false;
  Errors := '';
  // Prüfen ob der user mehr Fav's vergeben hat als er besitzt
  For j := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[LogOnlineColChecked, j] = '1' Then Begin
      If StringGrid1.Cells[LogOnlineColFav, j] = '1' Then Begin
        inc(cnt);
      End;
    End;
  End;
  If (cnt > fFavsAvail) And (fFavsAvail <> -1) Then Begin
    ShowMessage(R_You_do_not_have_that_many_favs_available_to_log);
    Button2.enabled := true;
    self.Enabled := true;
    exit;
  End;
  // Prüfen das Fav's nur vergeben werden bei Dosen die Foundit oder Wbcam Photo Taken haben
  For j := 1 To StringGrid1.RowCount - 1 Do Begin
    // Dose soll geloggt werden und nen Fav bekommen
    If (StringGrid1.Cells[LogOnlineColChecked, j] = '1') And
      (StringGrid1.Cells[LogOnlineColFav, j] = '1') Then Begin
      If (fFieldNotes[j - 1].Logtype <> ltFoundit) And
        (fFieldNotes[j - 1].Logtype <> ltWebcamPhotoTaken) Then Begin
        If errors <> '' Then Begin
          Errors := Errors + ', ';
        End;
        Errors := Errors + fFieldNotes[j - 1].GC_Code;
      End;
    End;
  End;
  If errors <> '' Then Begin
    Showmessage(format(RF_Error_Favs_only_for_found_and_webcam_photo_taken_allowed, [Errors]));
    If form4.Visible Then form4.Close;
    exit;
  End;
  Errors := '';
  Cnt := 0;
  // Alle TB's entsprechend Setzen
  For j := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[LogOnlineColChecked, j] = '1' Then Begin
      If Form4.Abbrechen Then Begin
        DoNotClose := true; // Dafür Sorgen, das sich der Dialog nicht schließt.
        break;
      End;
      fFieldNotes[j - 1].Fav := StringGrid1.Cells[LogOnlineColFav, j] = '1';
      setlength(fFieldNotes[j - 1].TBs, 0);
      // Alle an gehackten als TB's übernehmen
      For i := LogOnlineColFirstTB To StringGrid1.ColCount - 1 Do Begin
        If StringGrid1.Cells[i, j] = '1' Then Begin
          setlength(fFieldNotes[j - 1].TBs, high(fFieldNotes[j - 1].TBs) + 2);
          fFieldNotes[j - 1].TBs[high(fFieldNotes[j - 1].TBs)] := GetValue('TBs', 'TBCode' + inttostr(i - LogOnlineColFirstTB), '');
        End;
      End;
      Log := fFieldNotes[j - 1];
      inc(cnt);
      form4.RefresStatsMethod(log.GC_Code, cnt, 0, false);
      If GCTLogOnline(Log) Then Begin
        StringGrid1.Cells[LogOnlineColChecked, j] := '0'; // Abwählen des Erfolgreich geloggten Cache
        SelectAndScrollToRow(StringGrid1, j);
        // Damit ein Schuh draus wird, müssen die Dosen auf der Form10 auch abgewählt werden.
        form10.UnCheckCache(log.GC_Code);
      End
      Else Begin
        Errors := LineEnding + GCTGetLastError;
        DoNotClose := true; // Todo: Evtl. Sollte sich der Dialog trotzdem Schließen, da das zugehörige Problem nur auf Form10 gelöst werden kann.
      End;
    End;
  End;
  If cnt = 0 Then Begin
    showmessage(R_Noting_Selected);
    DoNotClose := true;
  End;
  If form4.Visible Then form4.Close;
  self.Enabled := true;
  Button2.enabled := true;
  If errors <> '' Then Begin
    ShowMessage(format(RF_Error, [Errors]));
  End;
  If Not DoNotClose Then Begin
    showmessage(R_Finished);
    ModalResult := mrOK;
  End;
End;

Procedure TForm22.Button3Click(Sender: TObject);
Var
  i: Integer;
Begin
  // All
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[LogOnlineColChecked, i] := '1';
  End;
End;

Procedure TForm22.Button4Click(Sender: TObject);
Var
  i: Integer;
Begin
  // None
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[LogOnlineColChecked, i] := '0';
  End;
End;

Procedure TForm22.Button5Click(Sender: TObject);
Var
  cnt, i, j: integer;
  t, tbs: String;
  a: Array Of Integer;
Begin
  // Check T's Group on Selected
  If ComboBox1.ItemIndex = -1 Then exit;
  tbs := getvalue('TBGroups', 'Content' + inttostr(ComboBox1.ItemIndex), '');
  If trim(tbs) = '' Then exit;
  tbs := tbs + ',';
  cnt := strtointdef(getvalue('TBs', 'Count', '0'), 0);
  // Umwandeln der TB-Codes in der Gruppe in Spaltennummern in der Stringgrid
  a := Nil;
  While tbs <> '' Do Begin
    t := lowercase(trim(copy(tbs, 1, pos(',', tbs) - 1)));
    delete(tbs, 1, pos(',', tbs));
    For i := 0 To cnt - 1 Do Begin
      If t = lowercase(trim(getvalue('TBs', 'TBCode' + inttostr(i), ''))) Then Begin
        setlength(a, high(a) + 2);
        a[high(a)] := i + LogOnlineColFirstTB;
        break;
      End;
    End;
  End;
  If high(a) = -1 Then exit;
  // Markieren der entsprechenden
  For j := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[LogOnlineColChecked, j] = '1' Then Begin
      For i := 0 To high(a) Do Begin
        StringGrid1.Cells[a[i], j] := '1';
      End;
    End;
  End;
End;

Procedure TForm22.Button6Click(Sender: TObject);
Var
  j, i: Integer;
Begin
  // Uncheck All
  For j := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[LogOnlineColChecked, j] = '1' Then Begin
      For i := LogOnlineColFirstTB To StringGrid1.ColCount - 1 Do Begin
        StringGrid1.Cells[i, j] := '0';
      End;
    End;
  End;
End;

Procedure TForm22.LoadOnlineLogSettings(FieldNoteList: tfieldNoteList);
Var
  c: TGridColumn;
  cnt, i, j: integer;
Begin
  StringGrid1.RowCount := 1;
  StringGrid1.Columns.Clear;
  fFieldNotes := FieldNoteList;
  // Spalte Checked
  c := StringGrid1.Columns.Add;
  c.ButtonStyle := cbsCheckboxColumn;
  c.Title.Caption := '          ';
  // Spalte Typ
  c := StringGrid1.Columns.Add;
  c.Title.Caption := R_Type;
  // Spalte Fav
  c := StringGrid1.Columns.Add;
  c.ButtonStyle := cbsCheckboxColumn;
  fFavsAvail := GCTGetAvailableFavs();
  c.Title.Caption := R_Fav + ' (' + inttostr(fFavsAvail) + ')';
  // Spalte GC-Code
  c := StringGrid1.Columns.Add;
  c.Title.Caption := R_Cache;
  // Spalte Desctiption
  c := StringGrid1.Columns.Add;
  c.Title.Caption := R_Title;
  cnt := strtointdef(getvalue('TBs', 'Count', '0'), 0);
  If cnt <> 0 Then Begin
    For i := 0 To cnt - 1 Do Begin
      c := StringGrid1.Columns.Add;
      c.ButtonStyle := cbsCheckboxColumn;
      c.Title.Caption := getvalue('TBs', 'TBDescription' + inttostr(i), '');
    End;
  End;
  For i := 0 To high(FieldNoteList) Do Begin
    StringGrid1.RowCount := StringGrid1.RowCount + 1;
    StringGrid1.Cells[LogOnlineColChecked, StringGrid1.RowCount - 1] := '1';
    If FieldNoteList[i].Fav Then Begin // Übernehmen der Favs die im Dialog vorher schon gesetzt wurden.
      StringGrid1.Cells[LogOnlineColFav, StringGrid1.RowCount - 1] := '1';
    End
    Else Begin
      StringGrid1.Cells[LogOnlineColFav, StringGrid1.RowCount - 1] := '0';
    End;
    ApplyMetaInfo(StringGrid1.RowCount - 1, FieldNoteList[i].GC_Code);
    For j := 0 To cnt - 1 Do Begin
      StringGrid1.Cells[LogOnlineColFirstTB + j, StringGrid1.RowCount - 1] := '0';
    End;
  End;
  StringGrid1.AutoSizeColumns;
  StringGrid1.Columns[LogOnlineColType].Width := 60; // Die Spalte für die D/T Wertung setzten wir fest (siehe form1.create)
  // Die Types tragen wir erst hinter her ein, sonst stimt autosize nicht
  For i := 0 To high(FieldNoteList) Do Begin
    For j := 1 To Form10.StringGrid1.RowCount - 1 Do Begin
      If Form10.StringGrid1.Cells[GPSImportColCacheGCCode, j] = FieldNoteList[i].GC_Code Then Begin
        StringGrid1.Cells[LogOnlineColType, i + 1] := Form10.StringGrid1.Cells[GPSImportColType, j];
        break;
      End;
    End;
  End;
  ComboBox1.Items.Clear;
  cnt := strtointdef(getvalue('TBGroups', 'Count', '0'), 0);
  For i := 0 To cnt - 1 Do Begin
    ComboBox1.Items.Add(getvalue('TBGroups', 'Name' + inttostr(i), ''));
    // Schaun ob eine der Gruppen via Default angewählt werden soll
    If pos('default', lowercase(ComboBox1.Items[ComboBox1.Items.Count - 1])) <> 0 Then Begin
      ComboBox1.ItemIndex := i;
      Button5.Click;
    End;
  End;
End;

Procedure TForm22.ApplyMetaInfo(RowIndex: integer; Cache: String);
Var
  i: Integer;
Begin
  (*
   * Hier brauchts keinen Default, da wir wissen dass wir den Cache immer finden !!
   *)
  For i := 1 To Form10.StringGrid1.RowCount - 1 Do Begin
    If Form10.StringGrid1.Cells[GPSImportColCacheGCCode, i] = cache Then Begin
      StringGrid1.Cells[LogOnlineColCode, RowIndex] := Cache;
      StringGrid1.Cells[LogOnlineColDescription, RowIndex] := Form10.StringGrid1.Cells[GPSImportColCacheName, i];
      // StringGrid1.Cells[LogOnlineColType, RowIndex] := Form10.StringGrid1.Cells[GPSImportColType, i]; -- Deaktiviert wird von Hand nach autosize gemacht.
      exit;
    End;
  End;
End;

End.

