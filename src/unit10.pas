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
Unit Unit10;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls, Menus, ExtDlgs, usqlite_helper, uccm;

Type

  { TForm10 }

  TForm10 = Class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TBitBtn;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CalendarDialog1: TCalendarDialog;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    Separator1: TMenuItem;
    StringGrid1: TStringGrid;
    Procedure Button10Click(Sender: TObject);
    Procedure Button11Click(Sender: TObject);
    Procedure Button12Click(Sender: TObject);
    Procedure Button13Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure MenuItem10Click(Sender: TObject);
    Procedure MenuItem11Click(Sender: TObject);
    Procedure MenuItem14Click(Sender: TObject);
    Procedure MenuItem15Click(Sender: TObject);
    Procedure MenuItem16Click(Sender: TObject);
    Procedure MenuItem17Click(Sender: TObject);
    Procedure MenuItem18Click(Sender: TObject);
    Procedure MenuItem19Click(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure MenuItem20Click(Sender: TObject);
    Procedure MenuItem21Click(Sender: TObject);
    Procedure MenuItem23Click(Sender: TObject);
    Procedure MenuItem24Click(Sender: TObject);
    Procedure MenuItem26Click(Sender: TObject);
    Procedure MenuItem27Click(Sender: TObject);
    Procedure MenuItem29Click(Sender: TObject);
    Procedure MenuItem30Click(Sender: TObject);
    Procedure MenuItem32Click(Sender: TObject);
    Procedure MenuItem33Click(Sender: TObject);
    Procedure MenuItem3Click(Sender: TObject);
    Procedure MenuItem5Click(Sender: TObject);
    Procedure MenuItem6Click(Sender: TObject);
    Procedure MenuItem8Click(Sender: TObject);
    Procedure MenuItem9Click(Sender: TObject);
    Procedure PopupMenu1Popup(Sender: TObject);
    Procedure StringGrid1ButtonClick(Sender: TObject; aCol, aRow: Integer);
    Procedure StringGrid1Click(Sender: TObject);
    Procedure StringGrid1DblClick(Sender: TObject);
    Procedure StringGrid1HeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    Procedure StringGrid1KeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1KeyUp(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure StringGrid1Resize(Sender: TObject);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    { private declarations }
    Function GetSelectedFieldNoteList(Out skipped_LabCaches: Boolean): TFieldNoteList; // Gibt alle in der Stringgrid selektierten Caches zurück
    Procedure SetSelectedStatesTo(NewState: TLogtype);
    Procedure SetSelectedProblemTo(NewProblem: TReportProblemLogType);
  public
    { public declarations }
    fpw: String;
    Procedure UnCheckCache(Cache: String);
    Procedure Calculate_Selection_Count();
    (*
     * Lädt die Übergebene Fieldnote Liste und startet danach das Formular
     * Wenn Append = True, dann ist das Formular schon offen, und wird nicht nochmal gestartet, Caller wird dann ignoriert
     *)
    Procedure LoadFieldNoteList(Caller: TForm; Const list: TFieldNoteList;
      Append: Boolean);
  End;

Const
  GPSImportColChecked = 0;
  GPSImportColFav = 1;
  GPSImportColType = 2;
  GPSImportColCacheGCCode = 3;
  GPSImportColCacheName = 4;
  GPSImportColCacheFoundDate = 5;
  GPSImportColCacheFoundState = 6;
  GPSImportColCacheProblem = 7;
  GPSImportColCacheImage = 8;
  GPSImportColCacheImageFilename = 9;
  GPSImportColCacheComment = 10;

Var
  Form10: TForm10;

  Form10FieldNotesFilename: String;

Implementation

{$R *.lfm}

Uses
  unit1, // Main Form
  unit5, // Modify Koordinates
  unit4, // Fortschrittsanzeige
  unit7, // Note Editor
  unit13, // Preview des Caches
  unit22, // TB / Cache Log Window
  unit33, // Log Trackables
  ugctoolwrapper, // Online Logger
  ulanguage,
  lazutf8,
  LCLType, LCLIntf, LazFileUtils, math;

Var
  col: integer = -1;
  row: integer = -1;
  Keypressed: Boolean = false;

Procedure SortColumn(Const StringGrid: TStringGrid; Const Column: integer; Const Direction: boolean);

  Function Compare(v1, v2: String): Integer;
  Var
    v1_, v2_: integer;
    d1, d2: TDateTime;
  Begin
    Case Column Of
      GPSImportColChecked: Begin
          v1_ := strtointdef(v1, -1);
          v2_ := strtointdef(v2, -1);
          result := v1_ - v2_;
        End;
      GPSImportColCacheFoundDate: Begin
          d1 := StrToTime(v1);
          d2 := StrToTime(v2);
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

{ TForm10 }

Procedure TForm10.LoadFieldNoteList(Caller: TForm; Const list: TFieldNoteList; Append: Boolean
  );
Var
  oCount, res, k, j: Integer;
  litesText, lites, f, n, s, m, l: String;
  liste: TFieldNoteList;
Begin
  If high(list) = -1 Then Begin
    showmessage(R_No_Logs_found_in_List);
    exit;
  End;
  If append Then Begin
    oCount := form10.StringGrid1.RowCount;
    form10.StringGrid1.RowCount := form10.StringGrid1.RowCount + length(list);
  End
  Else Begin
    oCount := 1;
    form10.StringGrid1.RowCount := 1 + length(list);
  End;
  form10.caption := format(RF_Visits_Editor_found, [length(list)]);
  m := '';
  n := '';
  f := '';
  lites := '';
  litesText := '';
  // Reset der Captions -> "unsortiert"
  form10.StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
  form10.StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
  form10.StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
  form10.StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
  form10.StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
  form10.StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
  form10.StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
  form10.StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
  form10.StringGrid1.Columns[GPSImportColCacheImage].Title.caption := R_Image;
  form10.StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
  For j := 0 To high(list) Do Begin
    form10.StringGrid1.Cells[GPSImportColCacheImage, j + oCount] := R_Load;
    form10.StringGrid1.Cells[GPSImportColCacheImageFilename, j + oCount] := ''; // Kein Dateiname
    form10.StringGrid1.Cells[GPSImportColChecked, j + oCount] := '1';
    form10.StringGrid1.Cells[GPSImportColFav, j + oCount] := inttostr(ord(list[j].Fav));
    form10.StringGrid1.Cells[GPSImportColCacheGCCode, j + oCount] := list[j].GC_Code;
    StartSQLQuery('Select G_NAME, G_TYPE, G_DIFFICULTY, G_TERRAIN, G_Found, Lite, Customer_Flag from caches where name ="' + list[j].GC_Code + '"');
    form10.StringGrid1.Cells[GPSImportColCacheFoundDate, j + oCount] := list[j].Date;
    form10.StringGrid1.Cells[GPSImportColCacheFoundState, j + oCount] := inttostr(LogtypeToLogtypeIndex(list[j].Logtype));
    form10.StringGrid1.Cells[GPSImportColCacheComment, j + oCount] := list[j].Comment;
    form10.StringGrid1.Cells[GPSImportColCacheProblem, j + oCount] := inttostr(ProblemTypeToProblemTypeIndex(list[j].reportProblem));
    If SQLQuery.EOF Then Begin
      form10.StringGrid1.Cells[GPSImportColCacheName, j + oCount] := R_Not_In_Database;
      form10.StringGrid1.Cells[GPSImportColType, j + oCount] := '-';
      If n <> '' Then n := n + ',';
      n := n + list[j].GC_Code;
    End
    Else Begin
      If SQLQuery.Fields[5].AsInteger <> 0 Then Begin
        If lites <> '' Then lites := lites + ',';
        lites := lites + list[j].GC_Code;
        If litesText <> '' Then litesText := litesText + ',';
        litesText := litesText + FromSQLString(SQLQuery.Fields[0].AsString);
      End;
      form10.StringGrid1.Cells[GPSImportColCacheName, j + oCount] := FromSQLString(SQLQuery.Fields[0].AsString);
      // Hier wird Absichtlich kein CacheNameToCacheType aufgerufen, da wir gerade dabei sind das ding als Geloggt zu loggen, ..
      form10.StringGrid1.Cells[GPSImportColType, j + oCount] := SQLQuery.Fields[1].AsString + format('|%fx%f', [SQLQuery.Fields[2].AsFloat, SQLQuery.Fields[3].AsFloat], DefFormat);
      // Wenn die aus irgend einem Grund schon als CustomFlag gesetzt ist sollte das der User dennoch sehen.
      If SQLQuery.Fields[6].AsString = '1' Then Begin
        form10.StringGrid1.Cells[GPSImportColType, j + oCount] := AddCacheTypeSpezifier(form10.StringGrid1.Cells[GPSImportColType, j + oCount], 'U');
      End;
      // Prüfen ob irgend eine Dose bereits als Geloggt in der DB markiert ist
      If (trim(form10.StringGrid1.Cells[GPSImportColCacheFoundState, j + oCount]) = inttostr(LogtypeToLogtypeIndex(ltFoundIt))) And
        (SQLQuery.Fields[4].AsInteger <> 0) Then Begin
        If f <> '' Then f := f + ',';
        f := f + list[j].GC_Code;
        form10.StringGrid1.Cells[GPSImportColCacheFoundState, j + oCount] := inttostr(LogtypeToLogtypeIndex(ltWriteNote));
      End;
      // TODO: die Strings 'event'  und 'webcam cache' müssen durch globale Constaten ersetzt werden..
      // Einen Event können wir nicht finden, den müssen wir Attended setzen
      If pos('event', lowercase(SQLQuery.Fields[1].AsString)) <> 0 Then Begin
        If trim(form10.StringGrid1.Cells[GPSImportColCacheFoundState, j + oCount]) = inttostr(LogtypeToLogtypeIndex(ltFoundIt)) Then Begin
          form10.StringGrid1.Cells[GPSImportColCacheFoundState, j + oCount] := inttostr(LogtypeToLogtypeIndex(ltAttended));
          m := m + SQLQuery.Fields[0].AsString + LineEnding;
        End;
      End;
      // Einen Webcam Cache können wir nicht finden, aber ein Photo davon machen
      If pos('webcam cache', lowercase(SQLQuery.Fields[1].AsString)) <> 0 Then Begin
        If trim(form10.StringGrid1.Cells[GPSImportColCacheFoundState, j + oCount]) = inttostr(LogtypeToLogtypeIndex(ltFoundIt)) Then Begin
          form10.StringGrid1.Cells[GPSImportColCacheFoundState, j + oCount] := inttostr(LogtypeToLogtypeIndex(ltWebcamPhotoTaken));
          m := m + SQLQuery.Fields[0].AsString + LineEnding;
        End;
      End;
    End;
  End;
  If utf8pos('✔', form10.button4.Caption) <> 0 Then Begin
    form10.button4.Caption := trim(UTF8Copy(form10.button4.Caption, 1, utf8pos('✔', form10.button4.Caption) - 1));
  End;
  If utf8pos('✔', form10.button5.Caption) <> 0 Then Begin
    form10.button5.Caption := trim(UTF8Copy(form10.button5.Caption, 1, utf8pos('✔', form10.button5.Caption) - 1));
  End;
  If utf8pos('✔', form10.button9.Caption) <> 0 Then Begin
    form10.button9.Caption := trim(UTF8Copy(form10.button9.Caption, 1, utf8pos('✔', form10.button9.Caption) - 1));
  End;
  If utf8pos('✔', form10.button10.Caption) <> 0 Then Begin
    form10.button10.Caption := trim(UTF8Copy(form10.button10.Caption, 1, utf8pos('✔', form10.button10.Caption) - 1));
  End;
  If utf8pos('✔', form10.button11.Caption) <> 0 Then Begin
    form10.button11.Caption := trim(UTF8Copy(form10.button11.Caption, 1, utf8pos('✔', form10.button11.Caption) - 1));
  End;
  // Anfrage ob nicht existierende Caches nachgeladen werden sollen
  If (n <> '') Or (lites <> '') Then Begin
    res := ID_NO;
    If n <> '' Then Begin
      res := Application.MessageBox(pchar(format(RF_The_Caches_are_missing_in_database_redownload_them, [StringReplace(n, ',', ', ', [rfReplaceAll])])), pchar(R_Question), MB_YESNO Or MB_ICONQUESTION);
    End;
    If (lites <> '') And (res = ID_NO) Then Begin
      n := ''; // Die Anderen wollte der User ja definitiv nicht geladen haben..
      res := Application.MessageBox(pchar(format(RF_The_Caches_Are_Lite_Caches_redownload_them, [StringReplace(litesText, ',', ', ', [rfReplaceAll])])), pchar(R_Question), MB_YESNO Or MB_ICONQUESTION);
    End;
    // Wie übernehmen die Lites in die N
    If n <> '' Then n := n + ',';
    n := n + lites;
    If ID_YES = res Then Begin
      // Nachladen/ Importieren aller Caches
      n := n + ',';
      s := '';
      k := 0;
      self.Enabled := false;
      Form4.RefresStatsMethod('', 0, 0, true);
      While n <> '' Do Begin
        inc(k);
        l := copy(n, 1, pos(',', n) - 1);
        delete(n, 1, pos(',', n));
        If trim(l) <> '' Then Begin
          Form4.RefresStatsMethod(l, k, 0, false);
          If form1.DownloadAndImportCacheByGCCode(l, true) <> 0 Then Begin
            If s <> '' Then s := s + ', ';
            s := s + l;
          End;
          // Beim Abbruch durch den User, skippen wir den Rest und zeigen das dann auch an.
          If form4.Abbrechen Then Begin
            If s <> '' Then s := s + ', ';
            s := s + StringReplace(n, ',', ', ', [rfReplaceAll]);
            s := trim(s);
            If (s <> '') And (s[length(s)] = ',') Then Begin
              delete(s, length(s), 1); // Das letzte "," abschneiden
            End;
            n := '';
          End;
        End;
      End;
      self.Enabled := true;
      If form4.Visible Then form4.Hide;
      If s = '' Then Begin
        // Es hat geklappt am einfachsten einfach alles noch mal neu machen *g*
        If append Then Begin // Das Append wieder
          form10.StringGrid1.RowCount := form10.StringGrid1.RowCount - length(list);
        End;
        LoadFieldNoteList(Caller, list, Append);
      End
      Else Begin
        // Es hat nicht geklappt
        showmessage(format(RF_unable_to_redownload_caches, [StringReplace(s, ',', ', ', [rfReplaceAll])]));
        // Wir übernehmen, die die geladen werden konnten und starten nochmal von Vorne
        s := s + ',';
        Liste := Nil;
        For j := 0 To high(list) Do Begin
          If pos(form10.StringGrid1.Cells[GPSImportColCacheGCCode, j + oCount] + ',', s) = 0 Then Begin
            //form10.StringGrid1.Cells[GPSImportColChecked, j + oCount] := '0';
          //End
          //Else Begin
            setlength(liste, high(liste) + 2);
            liste[high(liste)] := list[j];
          End;
        End;
        LoadFieldNoteList(Caller, liste, Append);
      End;
      exit;
    End;
  End;
  // Prüfen ob alle Caches das Datum von heute haben
  l := '';
  s := copy(GetTime(now), 1, 10);
  For j := 0 To high(list) Do Begin
    If form10.StringGrid1.Cells[GPSImportColChecked, j + oCount] = '1' Then Begin
      If copy(list[j].Date, 1, 10) <> s Then Begin
        If l <> '' Then l := l + ', ';
        If form10.StringGrid1.Cells[GPSImportColCacheName, j + oCount] <> R_Not_In_Database Then Begin
          l := l + '"' + form10.StringGrid1.Cells[GPSImportColCacheName, j + oCount] + '"';
        End
        Else Begin
          l := l + '"' + form10.StringGrid1.Cells[GPSImportColCacheGCCode, j + oCount] + '"';
        End;
      End;
    End;
  End;
  // Prüfen ob irgend eine Dose Doppelt ist.
  s := '';
  For j := 0 To high(list) - 1 Do Begin
    For k := j + 1 To high(list) Do Begin
      If (lowercase(trim(list[j].GC_Code)) = lowercase(trim(list[k].GC_Code))) Then Begin
        If form10.StringGrid1.Cells[GPSImportColChecked, j + oCount] = '1' Then Begin
          If form10.StringGrid1.Cells[GPSImportColCacheName, j + oCount] <> R_Not_In_Database Then Begin
            s := s + form10.StringGrid1.Cells[GPSImportColCacheName, j + oCount] + LineEnding;
          End
          Else Begin
            s := s + form10.StringGrid1.Cells[GPSImportColCacheGCCode, j + oCount] + LineEnding;
          End;
          break; // Wenn einer Doppelt ist, den Dreifachen nicht erkennen
        End;
      End;
    End;
  End;
  If f <> '' Then Begin
    showmessage(format(RF_caches_already_found_change_to_write_note, [StringReplace(f, ',', ', ', [rfReplaceAll])]));
  End;
  If s <> '' Then Begin
    showmessage(format(RF_Attention_Double_Caches, [StringReplace(s, ',', ', ', [rfReplaceAll])]));
  End;
  If m <> '' Then Begin
    showmessage(format(RF_Changed_State_To, [R_Found_it, r_Attended, r_Webcam_Photo_taken, StringReplace(m, ',', ', ', [rfReplaceAll])]));
  End;
  If l <> '' Then Begin
    If GetValue('General', 'WarnFoundImportIfNotFromToday', '1') = '1' Then Begin
      Showmessage(format(RF_Logdate_Not_From_Today, [StringReplace(l, ',', ', ', [rfReplaceAll])]));
    End;
  End;
  form10.Calculate_Selection_Count;
  If Not append Then Begin
    FormShowModal(form10, Caller);
  End;
End;

Procedure TForm10.StringGrid1Resize(Sender: TObject);
Var
  i, j: integer;
Begin
  j := 0;
  For i := 0 To StringGrid1.ColCount - 1 Do Begin
    If i <> GPSImportColCacheComment Then Begin
      j := j + StringGrid1.ColWidths[i];
    End;
  End;
  StringGrid1.ColWidths[GPSImportColCacheComment] := max(25, StringGrid1.Width - j - 24);
End;

Procedure TForm10.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  col := acol;
  row := arow;
End;

Function TForm10.GetSelectedFieldNoteList(Out skipped_LabCaches: Boolean
  ): TFieldNoteList;
Var
  skip: Boolean;
  i: Integer;
  errormessage: String;
Begin
  result := Nil;
  skipped_LabCaches := false;
  errormessage := '';
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[GPSImportColChecked, i] = '1' Then Begin
      skip := false;
      // Versuch eine Heuristik zu machen, die angibt, wenn es nachher beim Import nach Groundspeack Knallt
      If (trim(StringGrid1.cells[GPSImportColCacheGCCode, i]) = '') Or
        (trim(StringGrid1.cells[GPSImportColCacheFoundDate, i]) = '') Or
        (trim(StringGrid1.cells[GPSImportColCacheFoundState, i]) = '') Then Begin
        skip := true;
        If (trim(StringGrid1.Cells[GPSImportColCacheName, i]) = '') Or
          (trim(StringGrid1.Cells[GPSImportColCacheName, i]) = R_Not_In_Database) Then Begin
          errormessage := errormessage + LineEnding + StringGrid1.Cells[GPSImportColCacheGCCode, i];
        End
        Else Begin
          errormessage := errormessage + LineEnding + StringGrid1.Cells[GPSImportColCacheName, i];
        End;
      End;
      // Lab Caches werden nicht zurück in das fieldnote file geschrieben,
      // www.Geocaching.com würde ne böse Fehlermeldung bringen, wenn wir versuchten die zu importieren
      If pos('lab_', lowercase(StringGrid1.Cells[GPSImportColCacheGCCode, i])) = 1 Then Begin
        skipped_LabCaches := true;
      End
      Else Begin
        If skip Then Begin
          StringGrid1.Cells[GPSImportColChecked, i] := '0';
        End
        Else Begin
          setlength(result, high(result) + 2);
          result[high(result)].GC_Code := StringGrid1.Cells[GPSImportColCacheGCCode, i];
          result[high(result)].Date := StringGrid1.Cells[GPSImportColCacheFoundDate, i];
          result[high(result)].Logtype := LogtypeIndexToLogtype(strtoint(StringGrid1.Cells[GPSImportColCacheFoundState, i]));
          result[high(result)].Comment := StringGrid1.Cells[GPSImportColCacheComment, i];
          result[high(result)].reportProblem := ProblemtypeIndexToProblemtype(strtoint(StringGrid1.Cells[GPSImportColCacheProblem, i]));
          result[high(result)].Image := StringGrid1.Cells[GPSImportColCacheImageFilename, i];
          result[high(result)].Fav := StringGrid1.Cells[GPSImportColFav, i] = '1';
          result[high(result)].TBs := Nil;
        End;
      End;
    End;
  End;
  Calculate_Selection_Count();
  If errormessage <> '' Then Begin
    Showmessage(format(RF_Error_You_Selected_invalid_logs, [errormessage]));
  End;
End;

Procedure TForm10.SetSelectedStatesTo(NewState: TLogtype);
Var
  i: LongInt;
Begin
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    StringGrid1.Cells[GPSImportColCacheFoundState, i] := inttostr(LogtypeToLogtypeIndex(NewState));
  End;
End;

Procedure TForm10.SetSelectedProblemTo(NewProblem: TReportProblemLogType);
Var
  i: LongInt;
Begin
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    StringGrid1.Cells[GPSImportColCacheProblem, i] := inttostr(ProblemTypeToProblemTypeIndex(NewProblem));
  End;
End;

Procedure TForm10.UnCheckCache(Cache: String);
Var
  i: Integer;
Begin
  cache := lowercase(trim(cache));
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If lowercase(trim(StringGrid1.Cells[GPSImportColCacheGCCode, i])) = cache Then Begin
      StringGrid1.Cells[GPSImportColChecked, i] := '0';
      SelectAndScrollToRow(StringGrid1, i);
      break;
    End;
  End;
  Calculate_Selection_Count;
End;

Procedure TForm10.Calculate_Selection_Count();
Var
  i, c: integer;
Begin
  c := 0;
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[GPSImportColChecked, i] = '1' Then inc(c);
  End;
  If pos('/\', StringGrid1.Columns[GPSImportColChecked].Title.caption) <> 0 Then Begin
    StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select + ' /\ (' + inttostr(c) + ')';
  End
  Else Begin
    If pos('\/', StringGrid1.Columns[GPSImportColChecked].Title.caption) <> 0 Then Begin
      StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select + ' \/ (' + inttostr(c) + ')';
    End
    Else Begin
      StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select + ' (' + inttostr(c) + ')';
    End;
  End;
End;

Procedure TForm10.FormCreate(Sender: TObject);
Begin
  StringGrid1.ColWidths[GPSImportColChecked] := 75;
  StringGrid1.ColWidths[GPSImportColFav] := 60;
  StringGrid1.ColWidths[GPSImportColType] := 60;
  StringGrid1.ColWidths[GPSImportColCacheGCCode] := 75;
  StringGrid1.ColWidths[GPSImportColCacheName] := 150;
  StringGrid1.ColWidths[GPSImportColCacheFoundDate] := 150;
  StringGrid1.ColWidths[GPSImportColCacheFoundState] := 100;
  StringGrid1.ColWidths[GPSImportColCacheImage] := 75;
  StringGrid1.ColWidths[GPSImportColCacheProblem] := 100;
  StringGrid1.OnDrawCell := @Form1.StringGrid1DrawCell;
End;

Procedure TForm10.MenuItem1Click(Sender: TObject);
Begin
  // Open in Browser
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  OpenCacheInBrowser(StringGrid1.Cells[GPSImportColCacheGCCode, row]);
End;

Procedure TForm10.MenuItem20Click(Sender: TObject);
Begin
  SetSelectedStatesTo(ltUnattempted);
End;

Procedure TForm10.MenuItem21Click(Sender: TObject);
Var
  i: integer;
Begin
  // Select
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    StringGrid1.Cells[GPSImportColChecked, i] := '1';
  End;
  Calculate_Selection_Count();
End;

Procedure TForm10.MenuItem23Click(Sender: TObject);
Var
  i: integer;
Begin
  // DeSelect
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    StringGrid1.Cells[GPSImportColChecked, i] := '0';
  End;
  Calculate_Selection_Count();
End;

Procedure TForm10.MenuItem24Click(Sender: TObject);
Begin
  // Setzen auf Attended
  SetSelectedStatesTo(ltWillAttend);
End;

Procedure TForm10.MenuItem26Click(Sender: TObject);
Var
  s, t: String;
  list: TFieldNoteList;
Begin
  // Nachträgliches anfügen weiterer GC-Codes
  s := InputBox(R_Enter_GC_Codes, R_Enter_GC_Codes + ':', '');
  s := StringReplace(s, ',', ' ', [rfReplaceAll]) + ',';
  If trim(s) = '' Then exit;
  // Aus der Eingabe eine Gültige TFieldNoteList erzeugen
  list := Nil;
  While s <> '' Do Begin
    t := uppercase(trim(copy(s, 1, pos(',', s) - 1)));
    delete(s, 1, pos(',', s));
    If t <> '' Then Begin
      If pos('GC', t) <> 1 Then Begin
        t := 'GC' + t;
      End;
      setlength(list, high(list) + 2);
      list[high(list)].GC_Code := t;
      list[high(list)].Date := GetTime(now);
      list[high(list)].Logtype := ltFoundit;
      list[high(list)].Comment := '';
      list[high(list)].Fav := false;
      list[high(list)].TBs := Nil;
      list[high(list)].reportProblem := rptNoProblem;
      list[high(list)].Image := '';
    End;
  End;
  LoadFieldNoteList(Nil, list, true);
End;

Procedure TForm10.MenuItem27Click(Sender: TObject);
Begin
  MenuItem27.Checked := Not MenuItem27.Checked;
  StringGrid1.Columns[GPSImportColFav].Visible := MenuItem27.Checked;
  StringGrid1.Invalidate;
End;

Procedure TForm10.MenuItem29Click(Sender: TObject);
Var
  r: TRect;
  i, j: integer;
Begin
  // Set Customer Flag
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set Customer_Flag=1 where name = "' + StringGrid1.Cells[GPSImportColCacheGCCode, i] + '"');
    StringGrid1.Cells[GPSImportColType, i] := AddCacheTypeSpezifier(StringGrid1.Cells[GPSImportColType, i], 'U');
    // Das Form1 ist auch sichtbar, also löschen wir da auch
    For j := 1 To form1.StringGrid1.RowCount - 1 Do Begin
      If Form1.StringGrid1.Cells[MainColGCCode, j] = StringGrid1.Cells[GPSImportColCacheGCCode, i] Then Begin
        form1.StringGrid1.Cells[MainColType, j] := AddCacheTypeSpezifier(form1.StringGrid1.Cells[MainColType, j], 'U');
      End;
    End;
  End;
  StringGrid1.Invalidate;
  form1.StringGrid1.Invalidate;
  SQLTransaction.Commit;
End;

Procedure TForm10.MenuItem30Click(Sender: TObject);
Var
  r: TRect;
  i, j: integer;
Begin
  // Clear Customer Flag
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set Customer_Flag=0 where name = "' + StringGrid1.Cells[GPSImportColCacheGCCode, i] + '"');
    StringGrid1.Cells[GPSImportColType, i] := RemoveCacheTypeSpezifier(StringGrid1.Cells[GPSImportColType, i], 'U');
    // Das Form1 ist auch sichtbar, also löschen wir da auch
    For j := 1 To form1.StringGrid1.RowCount - 1 Do Begin
      If Form1.StringGrid1.Cells[MainColGCCode, j] = StringGrid1.Cells[GPSImportColCacheGCCode, i] Then Begin
        form1.StringGrid1.Cells[MainColType, j] := RemoveCacheTypeSpezifier(form1.StringGrid1.Cells[MainColType, j], 'U');
      End;
    End;
  End;
  StringGrid1.Invalidate;
  form1.StringGrid1.Invalidate;
  SQLTransaction.Commit;
End;

Procedure TForm10.MenuItem32Click(Sender: TObject);
Var
  i: Integer;
Begin
  // Clear All Customer flags
  CommitSQLTransactionQuery('Update caches set Customer_Flag = 0');
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[GPSImportColType, i] := RemoveCacheTypeSpezifier(StringGrid1.Cells[GPSImportColType, i], 'U');
  End;
  StringGrid1.Invalidate;
  // Das Form1 ist auch sichtbar, also löschen wir da auch
  For i := 1 To form1.StringGrid1.RowCount - 1 Do Begin
    form1.StringGrid1.Cells[MainColType, i] := RemoveCacheTypeSpezifier(form1.StringGrid1.Cells[MainColType, i], 'U');
  End;
  form1.StringGrid1.Invalidate;
  SQLTransaction.Commit;
End;

Procedure TForm10.MenuItem33Click(Sender: TObject);
Begin
  // Clear Problems
  SetSelectedProblemTo(rptNoProblem);
End;

Procedure TForm10.MenuItem3Click(Sender: TObject);
Begin
  form1.MenuItem50Click(Nil);
  StringGrid1.Invalidate;
End;

Procedure TForm10.MenuItem10Click(Sender: TObject);
Begin
  // Setzen auf Webcam photo taken
  SetSelectedStatesTo(ltWebcamPhotoTaken);
End;

Procedure TForm10.MenuItem11Click(Sender: TObject);
Begin
  // Edit user note
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  EditCacheNote(self, StringGrid1.Cells[GPSImportColCacheGCCode, row]);
End;

Procedure TForm10.MenuItem14Click(Sender: TObject);
Begin
  // Modify Coordinates
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  If (trim(StringGrid1.Cells[GPSImportColCacheName, row]) = '') Or
    (trim(StringGrid1.Cells[GPSImportColCacheName, row]) = R_Not_In_Database) Then Begin
    showmessage(R_Not_In_Database);
  End;
  form5.ModifyCoordinate(StringGrid1.Cells[GPSImportColCacheGCCode, row], self);
End;

Procedure TForm10.MenuItem15Click(Sender: TObject);
Begin
  SetSelectedProblemTo(rptlogfull);
End;

Procedure TForm10.MenuItem16Click(Sender: TObject);
Begin
  SetSelectedProblemTo(rptdamaged);
End;

Procedure TForm10.MenuItem17Click(Sender: TObject);
Begin
  SetSelectedProblemTo(rptmissing);
End;

Procedure TForm10.MenuItem18Click(Sender: TObject);
Begin
  SetSelectedProblemTo(rptarchive);
End;

Procedure TForm10.MenuItem19Click(Sender: TObject);
Begin
  SetSelectedProblemTo(rptOther);
End;

Procedure TForm10.MenuItem5Click(Sender: TObject);
Begin
  // Setzen auf Found it
  SetSelectedStatesTo(ltFoundit);
End;

Procedure TForm10.MenuItem6Click(Sender: TObject);
Begin
  // Setzen auf Attended
  SetSelectedStatesTo(ltAttended);
End;

Procedure TForm10.MenuItem8Click(Sender: TObject);
Var
  s: String;
  i: integer;
Begin
  // Set Log Date
  CalendarDialog1.Date := now;
  If Not CalendarDialog1.Execute Then exit;
  s := copy(GetTime(CalendarDialog1.Date), 1, 10);
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    StringGrid1.Cells[GPSImportColCacheFoundDate, i] := s + copy(StringGrid1.Cells[GPSImportColCacheFoundDate, i], 11, length(StringGrid1.Cells[GPSImportColCacheFoundDate, i]));
  End;
End;

Procedure TForm10.MenuItem9Click(Sender: TObject);
Begin
  // Set State -> Write Note
  SetSelectedStatesTo(ltWriteNote);
End;

Procedure TForm10.PopupMenu1Popup(Sender: TObject);
Begin
  MenuItem3.Checked := form1.MenuItem50.Checked;
End;

Procedure TForm10.StringGrid1ButtonClick(Sender: TObject; aCol, aRow: Integer);
Begin
  // Der Load Image Button
  If acol = GPSImportColCacheImage Then Begin
    If OpenPictureDialog1.Execute Then Begin
      StringGrid1.Cells[aCol, aRow] := R_loaded;
      StringGrid1.Cells[GPSImportColCacheImageFilename, aRow] := OpenPictureDialog1.FileName;
    End
    Else Begin
      StringGrid1.Cells[aCol, aRow] := R_load;
      StringGrid1.Cells[GPSImportColCacheImageFilename, aRow] := '';
    End;
  End;
End;

Procedure TForm10.StringGrid1Click(Sender: TObject);
Begin
  // So ist Spalte 1, 2 Editierbar, und der Rest nicht ;)
  If ((col = GPSImportColChecked) Or (col = GPSImportColFav)) And (row > 0) And Not Keypressed Then Begin
    If StringGrid1.Cells[col, row] = '1' Then
      StringGrid1.Cells[col, row] := '0'
    Else
      StringGrid1.Cells[col, row] := '1';
  End;
  Calculate_Selection_Count();
  StringGrid1.Invalidate;
End;

Procedure TForm10.StringGrid1DblClick(Sender: TObject);
Begin
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  //
  If Not Form13.OpenCache(StringGrid1.Cells[GPSImportColCacheGCCode, row]) Then Begin
    showmessage(R_Cache_not_in_database_use_the_open_cache_in_browser_feature);
  End
  Else Begin
    FormShowModal(form13, self);
  End;
End;

Procedure TForm10.StringGrid1HeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
Var
  s: String;
Begin
  // Sortieren der Jeweiligen Spalte Alphabetisch Auf oder Absteigend
  Case Index Of
    GPSImportColCacheImageFilename,
      GPSImportColCacheImage: Begin
        // Nach den Bildern darf man nicht sortieren, vorerst
      End;
    GPSImportColChecked: Begin // Sortieren nach Checked
        s := StringGrid1.Columns[GPSImportColChecked].Title.caption;
        If pos('(', s) <> 0 Then Begin
          s := copy(s, 1, pos('(', s) - 1);
          s := trim(s);
        End;
        //StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (s = R_Select) Or (s = R_Select + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select + ' \/';
          SortColumn(StringGrid1, GPSImportColChecked, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select + ' /\';
          SortColumn(StringGrid1, GPSImportColChecked, false);
        End;
      End;
    GPSImportColFav: Begin // Sortiern nach Favs
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        //StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColFav].Title.caption = R_Fav) Or (StringGrid1.Columns[GPSImportColFav].Title.caption = R_Fav + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav + ' \/';
          SortColumn(StringGrid1, GPSImportColFav, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav + ' /\';
          SortColumn(StringGrid1, GPSImportColFav, false);
        End;
      End;
    GPSImportColType: Begin // Sortieren nach Typ
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        //StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColType].Title.caption = R_Type) Or (StringGrid1.Columns[GPSImportColType].Title.caption = R_Type + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColType].Title.caption := R_Type + ' \/';
          SortColumn(StringGrid1, GPSImportColType, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColType].Title.caption := R_Type + ' /\';
          SortColumn(StringGrid1, GPSImportColType, false);
        End;
      End;
    GPSImportColCacheGCCode: Begin
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        //StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption = R_Code) Or (StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption = R_Code + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code + ' \/';
          SortColumn(StringGrid1, GPSImportColCacheGCCode, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code + ' /\';
          SortColumn(StringGrid1, GPSImportColCacheGCCode, false);
        End;
      End;
    GPSImportColCacheName: Begin
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        //StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColCacheName].Title.caption = R_Title) Or (StringGrid1.Columns[GPSImportColCacheName].Title.caption = R_Title + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title + ' \/';
          SortColumn(StringGrid1, GPSImportColCacheName, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title + ' /\';
          SortColumn(StringGrid1, GPSImportColCacheName, false);
        End;
      End;
    GPSImportColCacheFoundDate: Begin
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        //StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption = R_date) Or (StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption = R_date + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date + ' \/';
          SortColumn(StringGrid1, GPSImportColCacheFoundDate, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date + ' /\';
          SortColumn(StringGrid1, GPSImportColCacheFoundDate, false);
        End;
      End;
    GPSImportColCacheFoundState: Begin
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        //StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption = R_State) Or (StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption = R_State + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State + ' \/';
          SortColumn(StringGrid1, GPSImportColCacheFoundState, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State + ' /\';
          SortColumn(StringGrid1, GPSImportColCacheFoundState, false);
        End;
      End;
    GPSImportColCacheProblem: Begin
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        //StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColCacheProblem].Title.caption = R_problem) Or (StringGrid1.Columns[GPSImportColCacheProblem].Title.caption = R_problem + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem + ' \/';
          SortColumn(StringGrid1, GPSImportColCacheProblem, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem + ' /\';
          SortColumn(StringGrid1, GPSImportColCacheProblem, false);
        End;
      End;
    GPSImportColCacheComment: Begin
        StringGrid1.Columns[GPSImportColChecked].Title.caption := R_Select;
        StringGrid1.Columns[GPSImportColFav].Title.caption := R_Fav;
        StringGrid1.Columns[GPSImportColType].Title.caption := R_Type;
        StringGrid1.Columns[GPSImportColCacheGCCode].Title.caption := R_Code;
        StringGrid1.Columns[GPSImportColCacheName].Title.caption := R_Title;
        StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption := R_date;
        StringGrid1.Columns[GPSImportColCacheFoundState].Title.caption := R_State;
        StringGrid1.Columns[GPSImportColCacheProblem].Title.caption := R_problem;
        //StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment;
        If (StringGrid1.Columns[GPSImportColCacheComment].Title.caption = R_comment) Or (StringGrid1.Columns[GPSImportColCacheComment].Title.caption = R_comment + ' /\') Then Begin
          StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment + ' \/';
          SortColumn(StringGrid1, GPSImportColCacheComment, true);
        End
        Else Begin
          StringGrid1.Columns[GPSImportColCacheComment].Title.caption := R_comment + ' /\';
          SortColumn(StringGrid1, GPSImportColCacheComment, false);
        End;
      End;
  End;
  Calculate_Selection_Count(); // Die Selection Anzahl wieder anfügen
End;

Procedure TForm10.StringGrid1KeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := true;
  If (key = 32) And (row > 0) And (Row < StringGrid1.RowCount) Then Begin
    If StringGrid1.Cells[GPSImportColChecked, row] = '1' Then Begin
      StringGrid1.Cells[GPSImportColChecked, row] := '0';
    End
    Else Begin
      StringGrid1.Cells[GPSImportColChecked, row] := '1';
    End;
    Calculate_Selection_Count();
  End;
End;

Procedure TForm10.StringGrid1KeyUp(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  Keypressed := false;
End;

Procedure TForm10.Button1Click(Sender: TObject);
Var
  i: Integer;
Begin
  For i := 1 To StringGrid1.RowCount - 1 Do
    StringGrid1.Cells[GPSImportColChecked, i] := '1';
  Calculate_Selection_Count();
End;

Procedure TForm10.Button4Click(Sender: TObject);
Var
  list: TFieldNoteList;
  c, b: Boolean;
Begin
  // Write Bach selected notes to file
  list := GetSelectedFieldNoteList(b);
  If Not assigned(list) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If (length(list) <> (StringGrid1.RowCount - 1)) Then Begin
    showmessage(R_You_have_not_selected_all_entries_the_missing_ones_are_not_exported);
  End;
  c := false;
  If Form10FieldNotesFilename = '' Then Begin
    If SaveDialog1.Execute Then Begin
      c := true;
      Form10FieldNotesFilename := SaveDialog1.FileName;
    End
    Else Begin
      ShowMessage(R_No_file_to_save_selected_abort_now);
      exit;
    End;
  End;
  If SaveFieldNotesToFile(Form10FieldNotesFilename, list) Then Begin
    If b Then Begin
      showmessage(R_Labcache_Warning);
    End
    Else Begin
      Showmessage(R_Finished);
    End;
    Button4.Caption := Button4.Caption + ' ✔';
  End;
  If c Then Form10FieldNotesFilename := '';
End;

Procedure TForm10.Button10Click(Sender: TObject);
Var
  i, j, c: Integer;
Begin
  j := strtoint(GetValue('General', 'LogCount', '0'));
  // Vor dem Hinzufügen der Signatur, nach Datum sortieren!
  If (StringGrid1.Columns[GPSImportColCacheFoundDate].Title.caption <> R_date + ' \/') Then Begin
    StringGrid1HeaderClick(StringGrid1, true, GPSImportColCacheFoundDate);
  End;
  c := 0;
  // Add Found Numbering
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If (
      (trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltFoundIt))) Or
      (trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltAttended))) Or
      (trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltWebcamPhotoTaken)))
      ) And (StringGrid1.Cells[GPSImportColChecked, i] = '1') Then Begin // Nur tatsächlich gefundene und gewählte
      inc(c);
      StringGrid1.Cells[GPSImportColCacheComment, i] := StringGrid1.Cells[GPSImportColCacheComment, i] + LineEnding + StringReplace(format(Getvalue('General', 'LogCountFormat', '# %d'), [c + j], DefFormat), '\n', LineEnding, [rfReplaceAll, rfIgnoreCase]);
      If GetValue('General', 'AppendCCMLink', '0') = '1' Then Begin
        StringGrid1.Cells[GPSImportColCacheComment, i] := StringGrid1.Cells[GPSImportColCacheComment, i] + LineEnding + LineEnding +
          'Created by [CCM](https://corpsman.de/index.php?doc=projekte/ccm)';
      End;
    End;
  End;
  SetValue('General', 'Logcount', inttostr(j + c));
  Button10.Caption := Button10.Caption + ' ✔';
End;

Procedure TForm10.Button11Click(Sender: TObject);
Var
  wnu, wnw, user: String;
  fn: TFieldNoteList;
  Labs: Boolean;
  i: Integer;
Begin
  button11.enabled := false;
  fn := GetSelectedFieldNoteList(Labs);
  If labs Then Begin
    showmessage(R_You_Tried_To_Log_Labcaches);
  End;
  If Not assigned(fn) Then Begin
    showmessage(R_Noting_Selected);
    button11.enabled := true;
    exit;
  End;
  // Beschränkung des Logtextes auf Maximal 4000 Zeichen
  user := '';
  wnw := '';
  wnu := '';
  For i := 0 To high(fn) Do Begin
    If utf8length(fn[i].Comment) > 3980 Then Begin
      user := user + fn[i].GC_Code + LineEnding;
    End;
    If (fn[i].Logtype = ltWriteNote) And (fn[i].reportProblem = rptNoProblem) Then Begin
      wnw := wnw + fn[i].GC_Code + LineEnding;
    End;
    If fn[i].Logtype = ltUnattempted Then Begin
      wnu := wnu + fn[i].GC_Code + LineEnding;
    End;
  End;
  If user <> '' Then Begin
    showmessage(format(RF_Error_to_long_logtext_for, [user]));
    button11.enabled := true;
    exit;
  End;
  // Leere des Logtexte = fehler
  user := '';
  For i := 0 To high(fn) Do Begin
    If trim(fn[i].Comment) = '' Then Begin
      user := user + fn[i].GC_Code + LineEnding;
    End;
  End;
  If user <> '' Then Begin
    showmessage(format(RF_Error_no_logtext_for, [user]));
    button11.enabled := true;
    exit;
  End;
  If wnw <> '' Then Begin
    showmessage(format(RF_Attention_the_Caches_are_only_write_notes, [wnw]));
  End;
  If wnu <> '' Then Begin
    (*
     * Caches, welche zu write Note werden, weil sie "Unversucht" sind.
     *)
    showmessage(format(RF_Attention_the_Caches_will_be_logged_as_write_notes, [wnu]));
  End;
  form22.LoadOnlineLogSettings(fn);
  FormShowModal(form22, self);
  If form22.ModalResult = mrOK Then Begin
    Button11.Caption := Button11.Caption + ' ✔';
  End;
  button11.enabled := true;
End;

Procedure TForm10.Button12Click(Sender: TObject);
Var
  finds: integer;
Begin
  If GCTGetFoundNumber(finds) Then Begin
    If ID_YES = Application.MessageBox(pchar(
      format(RF_Refresh_Found_Number, [getValue('General', 'LogCount', ''), finds, finds])), pchar(R_Question), MB_YESNO) Then Begin
      SetValue('General', 'LogCount', inttostr(finds));
    End;
  End;
End;

Procedure TForm10.Button13Click(Sender: TObject);
Begin
  form33.StringGrid1.RowCount := 1;
  form33.Edit1.Text := '';
  FormShowModal(form33, self);
End;

Procedure TForm10.Button2Click(Sender: TObject);
Var
  i: Integer;
Begin
  For i := 1 To StringGrid1.RowCount - 1 Do
    StringGrid1.Cells[GPSImportColChecked, i] := '0';
  Calculate_Selection_Count();
End;

Procedure TForm10.Button3Click(Sender: TObject);
Var
  i: integer;
  b: Boolean;
  s: String;
Begin
  b := false;
  s := '';
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[GPSImportColChecked, i] = '1' Then Begin
      b := true;
      s := StringGrid1.Cells[GPSImportColCacheComment, i];
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
      If StringGrid1.Cells[GPSImportColChecked, i] = '1' Then Begin
        StringGrid1.Cells[GPSImportColCacheComment, i] := form7.Memo1.Text;
      End;
    End;
  End;
End;

Procedure TForm10.Button5Click(Sender: TObject);
Var
  s: String;
  i, id: Integer;
  b: boolean;
Begin
  // Mark as Logged
  b := false; // Merken ob Caches geloggt werden sollten, welche nicht in der DB sind.
  s := GetValue('General', 'Username', '');
  id := strtoint(GetValue('General', 'UserID', '-1'));
  If (trim(s) = '') Or (id = -1) Then Begin
    showmessage(R_Error_could_not_log_when_username_and_userid_is_not_set);
    exit;
  End;
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If StringGrid1.Cells[GPSImportColChecked, i] = '1' Then Begin
      If form10.StringGrid1.Cells[GPSImportColCacheName, i] = R_Not_In_Database Then Begin // Wenn der Eintrag nicht in der DB ist, kann er auch nicht geloggt werden
        If ((trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltFoundit))) Or
          (trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltAttended))) Or
          (trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltWebcamPhotoTaken)))
          ) Then Begin // Nur tatsächlich gefundene werden auch geloggt
          b := true;
        End;
      End
      Else Begin
        If ((trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltFoundit))) Or
          (trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltAttended))) Or
          (trim(StringGrid1.Cells[GPSImportColCacheFoundState, i]) = inttostr(LogtypeToLogtypeIndex(ltWebcamPhotoTaken)))
          ) Then Begin // Nur tatsächlich gefundene werden auch geloggt
          StartSQLQuery('Select Count(*) from logs where Cache_name="' + StringGrid1.Cells[GPSImportColCacheGCCode, i] + '" and Finder_id = ' + inttostr(id) + ';');
          If SQLQuery.EOF Or (SQLQuery.Fields[0].AsInteger = 0) Then Begin
            // Neuen Logeintrag einfügen
            CommitSQLTransactionQuery('Insert into logs (Cache_Name, ID, Date, Type, Finder_id, Finder, Text_Encoded, Log_text) values (' +
              '"' + StringGrid1.Cells[GPSImportColCacheGCCode, i] + '" ' +
              ', ' + inttostr(0) + ' ' +
              ', "' + ToSQLString(StringGrid1.Cells[GPSImportColCacheFoundDate, i]) + '" ' +
              ', "' + ToSQLString(StringGrid1.Cells[GPSImportColCacheFoundState, i]) + '" ' +
              ', ' + inttostr(ID) + ' ' +
              ', "' + ToSQLString(s) + '" ' +
              ', ' + inttostr(ord(0)) + ' ' +
              ', "' + ToSQLString(StringGrid1.Cells[GPSImportColCacheComment, i]) + '" ' +
              ');');
          End
          Else Begin
            // Bestehenden überschreiben
            CommitSQLTransactionQuery('Update logs set TYPE="' + ToSQLString(StringGrid1.Cells[GPSImportColCacheFoundState, i]) + '"' +
              ', log_text="' + ToSQLString(ToSQLString(StringGrid1.Cells[GPSImportColCacheComment, i])) + '" ' +
              ' where Cache_name="' + StringGrid1.Cells[GPSImportColCacheGCCode, i] + '" and Finder_id = ' + inttostr(id) + ';');
          End;
          CommitSQLTransactionQuery('Update caches set g_found=1 where name="' + StringGrid1.Cells[GPSImportColCacheGCCode, i] + '"');
        End;
      End;
    End;
  End;
  form1.SQLTransaction1.Commit;
  If b Then Begin
    showmessage(R_Warning_some_caches_where_not_in_database_Could_not_mark_all_caches_in_db);
  End
  Else Begin
    showmessage(r_Finished);
  End;
  Button5.Caption := Button5.Caption + ' ✔';
End;

Procedure TForm10.Button7Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm10.Button8Click(Sender: TObject);
Var
  b: Boolean;
Begin
  // Clear Garmin => Lösche Geocache_visits.txt
  If Form10FieldNotesFilename = '' Then exit;
  If id_yes = application.MessageBox(pchar(R_Did_you_upload_the_geocache_visits_txt_to_www_geocaching_com_and_marked_as_logged_in_DB), pchar(R_Question), MB_YESNO Or MB_ICONQUESTION) Then Begin
    b := true;
    Try
      b := DeleteFileUTF8(Form10FieldNotesFilename);
    Except
      b := false;
    End;
    If Not b Then Begin
      showmessage(format(RF_Error_could_not_delete, [Form10FieldNotesFilename]));
    End;
    StringGrid1.RowCount := 1;
  End;
End;

Procedure TForm10.Button9Click(Sender: TObject);
Begin
  OpenURL(URL_UploadFieldNotes);
  Button9.Caption := Button9.Caption + ' ✔';
End;

End.

