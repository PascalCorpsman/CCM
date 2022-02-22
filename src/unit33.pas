Unit Unit33;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, Menus, ExtDlgs, uccm;

Type

  { TForm33 }

  TForm33 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CalendarDialog1: TCalendarDialog;
    Edit1: TEdit;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: char);
    Procedure Edit1KeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure MenuItem2Click(Sender: TObject);
    Procedure MenuItem3Click(Sender: TObject);
    Procedure MenuItem5Click(Sender: TObject);
    Procedure MenuItem7Click(Sender: TObject);
    Procedure StringGrid1Click(Sender: TObject);
    Procedure StringGrid1HeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    Procedure StringGrid1KeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1KeyUp(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    col, row: integer;
    keypressed: Boolean;
    History: TStringList;
    HistoryIndex: integer;
    Procedure Calculate_Selection_Count;
  public
    Procedure ResetHeaderCaptions;
  End;

Var
  Form33: TForm33;

Implementation

{$R *.lfm}

Uses unit4, unit7, lclintf, ulanguage, ugctoolwrapper, LCLType, math;

Const
  ColTBSelected = 0;
  ColTBCode = 1;
  ColTBDate = 2;
  ColTBState = 3;
  ColTBComment = 4;

Procedure SortColumn(Const StringGrid: TStringGrid; Const Column: integer; Const Direction: boolean);

  Function Compare(v1, v2: String): Integer;
  Var
    v1_, v2_: integer;
    d1, d2: TDateTime;
  Begin
    Case Column Of
      ColTBSelected: Begin
          v1_ := strtointdef(v1, -1);
          v2_ := strtointdef(v2, -1);
          result := v1_ - v2_;
        End;
      ColTBDate: Begin
          If trim(v1) = '-' Then Begin
            d1 := 0;
          End
          Else Begin
            d1 := StrToDateTimeFormat(v1, 'DD.MM.YYYY');
          End;
          If trim(v2) = '-' Then Begin
            d2 := 0;
          End
          Else Begin
            d2 := StrToDateTimeFormat(v2, 'DD.MM.YYYY');
          End;
          If d1 > d2 Then Begin
            result := 1;
          End
          Else Begin
            If d1 = d2 Then Begin
              result := 0;
            End
            Else Begin
              result := -1;
            End;
          End;
        End
    Else Begin
        result := CompareStr(lowercase(v1), lowercase(v2));
      End;
    End;
    If Not direction Then result := -result;
  End;

  Procedure Quick(li, re: integer);
  Var
    l, r, i: Integer;
    p, h: String;
  Begin
    If Li < Re Then Begin
      p := StringGrid.cells[Column, Trunc((li + re) / 2)]; // Auslesen des Pivo Elementes
      l := Li;
      r := re;
      While l < r Do Begin
        While Compare(StringGrid.cells[Column, l], p) < 0 Do
          inc(l);
        While Compare(StringGrid.cells[Column, r], p) > 0 Do
          dec(r);
        If L <= R Then Begin
          If l < r Then Begin // Nur Tauschen, wenn die Zeilen auch wirklich unterschiedlich sind.
            For i := 0 To StringGrid.ColCount - 1 Do Begin
              h := StringGrid.Cells[i, l];
              StringGrid.Cells[i, l] := StringGrid.Cells[i, r];
              StringGrid.Cells[i, r] := h;
            End;
          End;
          inc(l);
          dec(r);
        End;
      End;
      quick(li, r);
      quick(l, re);
    End;
  End;

Begin
  StringGrid.BeginUpdate;
  Quick(1, StringGrid.RowCount - 1);
  StringGrid.EndUpdate(true);
End;

{ TForm33 }

Procedure TForm33.FormCreate(Sender: TObject);
Begin
  caption := 'TB logger';
  col := 0;
  row := 0;
  keypressed := false;
  // rvb8d3 = Discover_code Babynoneck
  // TB8KVZX = TB-Code Babynoneck
  // edit1.text := 'rvb8d3,rvb8d2,PCQC7X, pcqc7y';
  StringGrid1.RowCount := 1;
  History := TStringList.create;
  HistoryIndex := -1;
End;

Procedure TForm33.FormDestroy(Sender: TObject);
Begin
  History.Free;
End;

Procedure TForm33.MenuItem1Click(Sender: TObject);
Begin
  // Open TB in Browser
  If (row > 0) Then Begin
    OpenURL(URL_OpenTBListing + lowercase(StringGrid1.Cells[ColTBCode, row]));
  End;
End;

Procedure TForm33.MenuItem2Click(Sender: TObject);
Var
  s: String;
Begin
  // Set discoverdate
  If row > 0 Then Begin
    CalendarDialog1.Date := now;
    If Not CalendarDialog1.Execute Then exit;
    s := FormatDateTime('DD.MM.YYYY', CalendarDialog1.Date);
    StringGrid1.Cells[ColTBDate, row] := s; //+ copy(StringGrid1.Cells[ColTBDate, row], 11, length(StringGrid1.Cells[ColTBDate, row]));
  End;
End;

Procedure TForm33.MenuItem3Click(Sender: TObject);
Var
  s: String;
  i: integer;
Begin
  // Set Discoverdate for all selected
  CalendarDialog1.Date := now;
  If Not CalendarDialog1.Execute Then exit;
  s := FormatDateTime('DD.MM.YYYY', CalendarDialog1.Date);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[ColTBSelected, i] = '1' Then Begin
      StringGrid1.Cells[ColTBDate, i] := s; //+ copy(StringGrid1.Cells[ColTBDate, i], 11, length(StringGrid1.Cells[ColTBDate, i]));
    End;
  End;
End;

Procedure TForm33.MenuItem5Click(Sender: TObject);
Var
  i: integer;
Begin
  // Select
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    StringGrid1.Cells[ColTBSelected, i] := '1';
  End;
  Calculate_Selection_Count();
End;

Procedure TForm33.MenuItem7Click(Sender: TObject);
Var
  i: integer;
Begin
  // DeSelect
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    StringGrid1.Cells[ColTBSelected, i] := '0';
  End;
  Calculate_Selection_Count();
End;

Procedure TForm33.StringGrid1Click(Sender: TObject);
Begin
  // So ist Spalte 1 Editierbar, und der Rest nicht ;)
  If (col = ColTBSelected) And (row > 0) And Not Keypressed Then Begin
    If StringGrid1.Cells[col, row] = '1' Then
      StringGrid1.Cells[col, row] := '0'
    Else
      StringGrid1.Cells[col, row] := '1';
    Calculate_Selection_Count();
  End;
End;

Procedure TForm33.StringGrid1HeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
Var
  s: String;
Begin
  // Sortieren der Jeweiligen Spalte Alphabetisch Auf oder Absteigend
  Case Index Of
    ColTBSelected: Begin // Sortieren nach Checked
        s := StringGrid1.Columns[ColTBSelected].Title.caption;
        If pos('(', s) <> 0 Then Begin
          s := copy(s, 1, pos('(', s) - 1);
          s := trim(s);
        End;
        //StringGrid1.Columns[ColTBSelected].Title.caption := R_Select;
        StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code;
        StringGrid1.Columns[ColTBDate].Title.caption := R_date;
        StringGrid1.Columns[ColTBState].Title.caption := R_State;
        StringGrid1.Columns[ColTBComment].Title.caption := R_comment;
        If (S = R_Select) Or (S = R_Select + ' /\') Then Begin
          StringGrid1.Columns[ColTBSelected].Title.caption := R_Select + ' \/';
          SortColumn(StringGrid1, ColTBSelected, true);
        End
        Else Begin
          StringGrid1.Columns[ColTBSelected].Title.caption := R_Select + ' /\';
          SortColumn(StringGrid1, ColTBSelected, false);
        End;
      End;
    ColTBCode: Begin // Sortieren nach Code
        StringGrid1.Columns[ColTBSelected].Title.caption := R_Select;
        //StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code;
        StringGrid1.Columns[ColTBDate].Title.caption := R_date;
        StringGrid1.Columns[ColTBState].Title.caption := R_State;
        StringGrid1.Columns[ColTBComment].Title.caption := R_comment;
        If (StringGrid1.Columns[ColTBCode].Title.caption = R_Discover_Code) Or (StringGrid1.Columns[ColTBCode].Title.caption = R_Discover_Code + ' /\') Then Begin
          StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code + ' \/';
          SortColumn(StringGrid1, ColTBCode, true);
        End
        Else Begin
          StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code + ' /\';
          SortColumn(StringGrid1, ColTBCode, false);
        End;
      End;
    ColTBDate: Begin // Sortieren nach Datum
        StringGrid1.Columns[ColTBSelected].Title.caption := R_Select;
        StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code;
        //StringGrid1.Columns[ColTBDate].Title.caption := R_date;
        StringGrid1.Columns[ColTBState].Title.caption := R_State;
        StringGrid1.Columns[ColTBComment].Title.caption := R_comment;
        If (StringGrid1.Columns[ColTBDate].Title.caption = R_date) Or (StringGrid1.Columns[ColTBDate].Title.caption = R_date + ' /\') Then Begin
          StringGrid1.Columns[ColTBDate].Title.caption := R_date + ' \/';
          SortColumn(StringGrid1, ColTBDate, true);
        End
        Else Begin
          StringGrid1.Columns[ColTBDate].Title.caption := R_date + ' /\';
          SortColumn(StringGrid1, ColTBDate, false);
        End;
      End;
    ColTBState: Begin // Sortieren nach State
        StringGrid1.Columns[ColTBSelected].Title.caption := R_Select;
        StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code;
        StringGrid1.Columns[ColTBDate].Title.caption := R_date;
        //StringGrid1.Columns[ColTBState].Title.caption := R_State;
        StringGrid1.Columns[ColTBComment].Title.caption := R_comment;
        If (StringGrid1.Columns[ColTBState].Title.caption = R_State) Or (StringGrid1.Columns[ColTBState].Title.caption = R_State + ' /\') Then Begin
          StringGrid1.Columns[ColTBState].Title.caption := R_State + ' \/';
          SortColumn(StringGrid1, ColTBState, true);
        End
        Else Begin
          StringGrid1.Columns[ColTBState].Title.caption := R_State + ' /\';
          SortColumn(StringGrid1, ColTBState, false);
        End;
      End;
    ColTBComment: Begin // Sortieren nach Commentar
        StringGrid1.Columns[ColTBSelected].Title.caption := R_Select;
        StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code;
        StringGrid1.Columns[ColTBDate].Title.caption := R_date;
        StringGrid1.Columns[ColTBState].Title.caption := R_State;
        //StringGrid1.Columns[ColTBComment].Title.caption := R_comment;
        If (StringGrid1.Columns[ColTBComment].Title.caption = R_comment) Or (StringGrid1.Columns[ColTBComment].Title.caption = R_comment + ' /\') Then Begin
          StringGrid1.Columns[ColTBComment].Title.caption := R_comment + ' \/';
          SortColumn(StringGrid1, ColTBComment, true);
        End
        Else Begin
          StringGrid1.Columns[ColTBComment].Title.caption := R_comment + ' /\';
          SortColumn(StringGrid1, ColTBComment, false);
        End;
      End;
  End;
  Calculate_Selection_Count;
  StringGrid1.AutoSizeColumns;
End;

Procedure TForm33.StringGrid1KeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := true;
  If (key = 32) And (row > 0) And (Row < StringGrid1.RowCount) Then Begin
    If StringGrid1.Cells[ColTBSelected, row] = '1' Then Begin
      StringGrid1.Cells[ColTBSelected, row] := '0';
    End
    Else Begin
      StringGrid1.Cells[ColTBSelected, row] := '1';
    End;
    Calculate_Selection_Count();
  End;
End;

Procedure TForm33.StringGrid1KeyUp(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := false;
End;

Procedure TForm33.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  col := acol;
  row := arow;
End;

Procedure TForm33.Calculate_Selection_Count;
Var
  i, c: integer;
Begin
  c := 0;
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[ColTBSelected, i] = '1' Then inc(c);
  End;
  If pos('/\', StringGrid1.Columns[ColTBSelected].Title.caption) <> 0 Then Begin
    StringGrid1.Columns[ColTBSelected].Title.caption := R_Select + ' /\ (' + inttostr(c) + ')';
  End
  Else Begin
    If pos('\/', StringGrid1.Columns[ColTBSelected].Title.caption) <> 0 Then Begin
      StringGrid1.Columns[ColTBSelected].Title.caption := R_Select + ' \/ (' + inttostr(c) + ')';

    End
    Else Begin
      StringGrid1.Columns[ColTBSelected].Title.caption := R_Select + ' (' + inttostr(c) + ')';
    End;
  End;
End;

Procedure TForm33.ResetHeaderCaptions;
Begin
  StringGrid1.Columns[ColTBSelected].Title.caption := R_Select;
  StringGrid1.Columns[ColTBCode].Title.caption := R_Discover_Code;
  StringGrid1.Columns[ColTBDate].Title.caption := R_date;
  StringGrid1.Columns[ColTBState].Title.caption := R_State;
  StringGrid1.Columns[ColTBComment].Title.caption := R_comment;
End;

Procedure TForm33.Button1Click(Sender: TObject);
  Function StrToGCHTMLStr(Value: String): String;
  Begin
    value := trim(value);
    result := '<p>' + StringReplace(value, LineEnding, '</p>' + LineEnding + '<p>', [rfReplaceAll]) + '</p>';
  End;
Var
  i, j, k: integer;
  tb: TTravelbugRecord;
Begin
  edit1.SetFocus;
  // Loggen der TB's
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[ColTBSelected, i] = '1' Then Begin
      If trim(StringGrid1.Cells[ColTBComment, i]) = '' Then Begin
        ShowMessage(format(RF_Discovering_a_TB_with_no_comment_will_fail_Please_unselect_or_write_a_comment, [StringGrid1.Cells[ColTBSelected, i]]));
        exit;
      End;
    End;
  End;
  j := 0;
  k := 0;
  form4.RefresStatsMethod('', 0, 0, true);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[ColTBSelected, i] = '1' Then Begin
      SelectAndScrollToRow(StringGrid1, i);
      inc(j);
      (*
       * Hier werden nicht alle Felder befüllt, nur die die zum Discovern benötigt werden !
       *)
      tb.Comment := StringGrid1.Cells[ColTBComment, i];
      tb.Discover_Code := StringGrid1.Cells[ColTBCode, i];
      tb.LogDate := StringGrid1.Cells[ColTBDate, i];
      form4.RefresStatsMethod(tb.Discover_Code, j, 0, false);
{$IFDEF Windows}
      form4.BringToFront;
{$ENDIF}
      (*
       * Da die Texte Ressourcenstrings sind, geht case leider nicht :(
       *)
      If (StringGrid1.Cells[ColTBState, i] = R_Discovered) Or
        (StringGrid1.Cells[ColTBState, i] = R_Not_discovered) Then Begin
        tb.LogState := ugctoolwrapper.TTBLogState.lsDiscovered;
      End;
      If (StringGrid1.Cells[ColTBState, i] = R_Not_Existing) Then Begin // Einen nicht existierenden können wir nicht Loggen
        Continue;
      End;
      If GCTDiscoverTb(tb) Then Begin
        StringGrid1.Cells[ColTBSelected, i] := '0';
        Calculate_Selection_Count();
        Application.ProcessMessages;
        inc(k);
        tb.Comment := StrToGCHTMLStr(tb.comment); // Die Logs werden immer in HTML gespeichert
        // Aktualisieren in der datenbank
        TB_CommitSQLTransactionQuery('Update trackables set' +
          ' LogDate="' + ToSQLString(tb.LogDate) + '" ' +
          ', Comment="' + ToSQLString(tb.Comment) + '" ' +
          ', LogState="' + TBLogstateToIntString(TTBLogState.lsDiscovered) + '" ' + // Auf Discovered setzen
          'where Discover_Code = "' + ToSQLString(Uppercase(tb.Discover_Code)) + '";'
          );
        TB_SQLTransaction.Commit;
      End;
    End;
    If Form4.Abbrechen Then Begin
      k := j + 1; // Sicherstellen, dass unten die Richtige Fehlermeldung kommt.
      break;
    End;
  End;
  If form4.visible Then form4.hide;
  If j <> k Then Begin
    showmessage(R_Error_could_not_discover_all_TBs_see_table);
  End
  Else Begin
    showmessage(R_Finished);
  End;
End;

Procedure TForm33.Button2Click(Sender: TObject);
Var
  inlist, t, s: String;
  b: Boolean;
  cnt, i: integer;
  ls: TTravelbugRecord;
Begin
  // Add to list
  Button2.Enabled := false;
  Button8.Enabled := false;
  edit1.Enabled := false;
  If trim(edit1.text) = '' Then Begin
    ShowMessage(R_No_TB_Codes_entered);
    edit1.Enabled := true;
    edit1.SetFocus;
    exit;
  End;
  s := edit1.text + ',';
  s := FilterStringForValidChars(uppercase(s), '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', ',');
  inlist := '';
  cnt := 0;
  form4.RefresStatsMethod('', cnt, 0, true);
  History.Add(edit1.text);
  HistoryIndex := History.Count - 1;
  While (s <> '') And Not form4.Abbrechen Do Begin
    ResetHeaderCaptions;
    Calculate_Selection_Count;
    t := trim(copy(s, 1, pos(',', s) - 1));
    delete(s, 1, pos(',', s));
    If t <> '' Then Begin
      inc(cnt);
      form4.RefresStatsMethod(t, cnt, 0, false);
{$IFDEF Windows}
      form4.BringToFront;
{$ENDIF}
      b := false;
      // Doppelte erkennen
      For i := 1 To StringGrid1.RowCount - 1 Do Begin
        If lowercase(t) = lowercase(StringGrid1.Cells[ColTBCode, i]) Then Begin
          b := true;
          break;
        End;
      End;
      If b Then Begin
        If inlist <> '' Then inlist := inlist + ', ';
        inlist := inlist + uppercase(t);
      End
      Else Begin
        StringGrid1.RowCount := StringGrid1.RowCount + 1;
        StringGrid1.Cells[ColTBCode, StringGrid1.RowCount - 1] := Uppercase(t);
        SelectAndScrollToRow(StringGrid1, StringGrid1.RowCount - 1);
        // Nachsehen ob wir den TB schon kennen
        TB_StartSQLQuery('Select TB_Code, Discover_Code, LogState, LogDate, Owner, ReleasedDate, Origin, Current_Goal, About_this_item, Comment, Heading from trackables where (Discover_Code = "' + ToSQLString(Uppercase(t)) + '") or (TB_Code = "' + ToSQLString(Uppercase(t)) + '")');
        ls.Discover_Code := uppercase(t);
        ls.LogState := TTBLogState.lsNotExisting;
        If Not TB_SQLQuery.EOF Then Begin
          ls.TB_Code := FromSQLString(TB_SQLQuery.Fields[0].AsString);
          ls.Discover_Code := FromSQLString(TB_SQLQuery.Fields[1].AsString);
          ls.LogState := TBIntStringToLogstate(TB_SQLQuery.Fields[2].AsString);
          ls.LogDate := FromSQLString(TB_SQLQuery.Fields[3].AsString);
          ls.Owner := FromSQLString(TB_SQLQuery.Fields[4].AsString);
          ls.ReleasedDate := FromSQLString(TB_SQLQuery.Fields[5].AsString);
          ls.Origin := FromSQLString(TB_SQLQuery.Fields[6].AsString);
          ls.Current_Goal := FromSQLString(TB_SQLQuery.Fields[7].AsString);
          ls.About_this_item := FromSQLString(TB_SQLQuery.Fields[8].AsString);
          ls.Comment := FromSQLString(TB_SQLQuery.Fields[9].AsString);
          ls.Heading := FromSQLString(TB_SQLQuery.Fields[10].AsString);
          If (ls.LogState = TTBLogState.lsNotYetActivated) Or // Noch nicht Aktivierte TB's betrachten wir als noch nicht in der Datenbank, evtl sind sie ja nun activiert.
          (ls.LogState = TTBLogState.lsLocked) Then Begin // Gesperrte TB's prüfen wir ob sie nun nicht mehr gesperrt sind.
            ls.LogState := TTBLogState.lsNotExisting;
          End;
        End;
        // Wir haben den TB nicht in der Datenbank, also laden wir ihn Klassisch
        If (ls.LogState = TTBLogState.lsNotExisting) Then Begin
          If Not GCTGetTBLogRecord(t, ls) Then Begin
            // Wenn der TB nicht geladen werden kann, konnten wir uns nicht Einloggen => Abbruch
            edit1.Enabled := true;
            edit1.SetFocus;
            showmessage(format(RF_Could_not_log_in_Error, [GCTGetLastError()]));
            exit;
          End
          Else Begin
            // Nun haben wir den TB, dann übernehmen wir in mal in die Datenbank
            If ls.LogState <> TTBLogState.lsNotExisting Then Begin // Wir adden nur, was es auch gibt.
              (*
               * Es kann immer sein, dass wir den TB schon mal als nur TB-Code gesehen hatten, dann muss dieser vorher gelöscht werden.
               *)
              TB_StartSQLQuery('Select TB_Code from trackables where (TB_Code = "' + ToSQLString(Uppercase(ls.TB_Code)) + '")');
              If Not TB_SQLQuery.EOF Then Begin
                // Dat Ding gibt es schon, also erst mal Raus löschen
                TB_CommitSQLTransactionQuery('Delete from trackables where (TB_Code = "' + ToSQLString(Uppercase(ls.TB_Code)) + '")');
              End;
              TB_CommitSQLTransactionQuery('Insert or Replace into trackables (TB_Code, Discover_Code, LogState, LogDate, Owner, ReleasedDate, Origin, Current_Goal, About_this_item, Comment, Heading) values(' +
                '"' + ToSQLString(Uppercase(ls.TB_Code)) + '" ' +
                ', "' + ToSQLString(Uppercase(ls.Discover_Code)) + '" ' +
                ', "' + TBLogstateToIntString(ls.LogState) + '" ' +
                ', "' + ToSQLString(ls.LogDate) + '" ' +
                ', "' + ToSQLString(ls.Owner) + '" ' +
                ', "' + ToSQLString(ls.ReleasedDate) + '" ' +
                ', "' + ToSQLString(ls.Origin) + '" ' +
                ', "' + ToSQLString(ls.Current_Goal) + '" ' +
                ', "' + ToSQLString(ls.About_this_item) + '" ' +
                ', "' + ToSQLString(ls.Comment) + '" ' +
                ', "' + ToSQLString(ls.Heading) + '" ' +
                ');'
                );
            End;
            TB_SQLTransaction.Commit;
          End;
        End;
        // Auswertung
        Case ls.LogState Of
          TTBLogState.lsTBCode: Begin
              StringGrid1.Cells[ColTBState, StringGrid1.RowCount - 1] := R_TB_Code;
              StringGrid1.Cells[ColTBSelected, StringGrid1.RowCount - 1] := '0';
              StringGrid1.Cells[ColTBDate, StringGrid1.RowCount - 1] := '-';
            End;
          TTBLogState.lsDiscovered: Begin
              StringGrid1.Cells[ColTBState, StringGrid1.RowCount - 1] := R_Discovered;
              StringGrid1.Cells[ColTBSelected, StringGrid1.RowCount - 1] := '0';
              StringGrid1.Cells[ColTBDate, StringGrid1.RowCount - 1] := ls.LogDate;
            End;
          TTBLogState.lsNotExisting: Begin
              StringGrid1.Cells[ColTBState, StringGrid1.RowCount - 1] := R_Not_Existing;
              StringGrid1.Cells[ColTBSelected, StringGrid1.RowCount - 1] := '0';
              StringGrid1.Cells[ColTBDate, StringGrid1.RowCount - 1] := '-';
            End;
          TTBLogState.lsNotDiscover: Begin
              StringGrid1.Cells[ColTBState, StringGrid1.RowCount - 1] := R_Not_discovered;
              StringGrid1.Cells[ColTBSelected, StringGrid1.RowCount - 1] := '1';
              StringGrid1.Cells[ColTBDate, StringGrid1.RowCount - 1] := FormatDateTime('DD.MM.YYYY', now);
            End;
          TTBLogState.lsNotYetActivated: Begin
              StringGrid1.Cells[ColTBState, StringGrid1.RowCount - 1] := R_Not_yet_activated;
              StringGrid1.Cells[ColTBSelected, StringGrid1.RowCount - 1] := '0';
              StringGrid1.Cells[ColTBDate, StringGrid1.RowCount - 1] := '-';
            End;
          TTBLogState.lsLocked: Begin
              StringGrid1.Cells[ColTBState, StringGrid1.RowCount - 1] := R_locked;
              StringGrid1.Cells[ColTBSelected, StringGrid1.RowCount - 1] := '0';
              StringGrid1.Cells[ColTBDate, StringGrid1.RowCount - 1] := '-';
            End;
        End;
        StringGrid1.AutoSizeColumns;
        Calculate_Selection_Count;
        Application.ProcessMessages;
      End;
    End;
  End;
  If form4.Visible Then form4.Hide;
  edit1.Enabled := true;
  edit1.text := '';
  Button2.Enabled := true;
  Button8.Enabled := true;
  edit1.SetFocus;
  If inlist <> '' Then Begin
    showmessage(format(RF_The_following_TBs_are_ignored_they_are_already_in_the_list, [inlist]));
  End;
End;

Procedure TForm33.Button3Click(Sender: TObject);
Var
  i: Integer;
Begin
  // Select all
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[ColTBSelected, i] := '1';
  End;
  edit1.SetFocus;
End;

Procedure TForm33.Button4Click(Sender: TObject);
Var
  i: Integer;
Begin
  // select none
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[ColTBSelected, i] := '0';
  End;
  edit1.SetFocus;
End;

Procedure TForm33.Button5Click(Sender: TObject);
Var
  i: integer;
  b: Boolean;
  s: String;
Begin
  // Set Comment for Selected
  edit1.SetFocus;
  b := false;
  s := '';
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[ColTBSelected, i] = '1' Then Begin
      b := true;
      s := StringGrid1.Cells[ColTBComment, i];
      break;
    End;
  End;
  If Not b Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  form7.ModalResult := mrNone;
  form7.memo1.text := s;
  form7.memo1.WordWrap := true;
  form7.SetCaption(R_Enter_log_text);
  FormShowModal(form7, self);
  form7.memo1.WordWrap := false;
  If form7.ModalResult = mrOK Then Begin
    For i := 1 To StringGrid1.RowCount - 1 Do Begin
      If StringGrid1.Cells[ColTBSelected, i] = '1' Then Begin
        StringGrid1.Cells[ColTBComment, i] := form7.Memo1.Text;
      End;
    End;
  End;
  StringGrid1.AutoSizeColumns;
End;

Procedure TForm33.Button6Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm33.Button7Click(Sender: TObject);
Var
  i: integer;
Begin
  // Delete selected
  For i := StringGrid1.RowCount - 1 Downto 1 Do Begin
    If StringGrid1.Cells[ColTBSelected, i] = '1' Then Begin
      StringGrid1.DeleteRow(i);
    End;
  End;
  edit1.SetFocus;
End;

Procedure TForm33.Button8Click(Sender: TObject);
Var
  sl: TStringList;
  s: String;
Begin
  // Import Commalist
  If OpenDialog1.Execute Then Begin
    sl := TStringList.Create;
    sl.LoadFromFile(OpenDialog1.FileName);
    s := sl.Text;
    sl.free;
    s := StringReplace(s, #13, ',', [rfReplaceAll]);
    s := StringReplace(s, #10, ',', [rfReplaceAll]);
    s := StringReplace(s, ';', ',', [rfReplaceAll]);
    edit1.text := s;
    Button2.Click;
  End;
End;

Procedure TForm33.Button9Click(Sender: TObject);
Var
  sl: TStringList;
  s: String;
  i: Integer;
Begin
  If SaveDialog1.Execute Then Begin
    s := '';
    For i := 1 To StringGrid1.RowCount - 1 Do Begin
      If StringGrid1.Cells[ColTBSelected, i] = '1' Then Begin
        If s = '' Then Begin
          s := StringGrid1.Cells[ColTBCode, i];
        End
        Else Begin
          s := s + ',' + StringGrid1.Cells[ColTBCode, i];
        End;
      End;
    End;
    sl := TStringList.Create;
    sl.Text := s;
    sl.SaveToFile(SaveDialog1.FileName);
    sl.free;
  End;
  edit1.SetFocus;
End;

Procedure TForm33.Edit1KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then Begin
    Button2.Click;
  End;
End;

Procedure TForm33.Edit1KeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState
  );
Begin
  If key = vk_up Then Begin
    If (HistoryIndex < history.Count) And (HistoryIndex >= 0) Then Begin
      edit1.text := History[HistoryIndex];
      HistoryIndex := max(0, HistoryIndex - 1);
    End;
  End;
  If key = vk_Down Then Begin
    If (HistoryIndex < history.Count) And (HistoryIndex >= 0) Then Begin
      HistoryIndex := min(History.Count - 1, HistoryIndex + 1);
      edit1.text := History[HistoryIndex];
    End;
  End;
End;

End.

