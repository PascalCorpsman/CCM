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
Unit Unit38;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Menus;

Type

  { TForm38 }

  TForm38 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Edit3KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCreate(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure MenuItem2Click(Sender: TObject);
    Procedure StringGrid1DblClick(Sender: TObject);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    row: integer;
  public

    Procedure PrepareLCL;

  End;

Var
  Form38: TForm38;

Implementation

{$R *.lfm}

Uses usqlite_helper, uccm, ulanguage, ugctoolwrapper, unit42, unit4, LCLIntf, LazFileUtils;

Const
  TB_DiscoverCode_Col = 0;
  TB_Code_Col = 1;
  TB_Logstate_Col = 2;
  TB_LogDate_Col = 3;
  TB_Owner_col = 4;
  TB_Heading_col = 5;

  { TForm38 }

Procedure TForm38.FormCreate(Sender: TObject);
Begin
  caption := 'Travelbug Database Editor';
  label5.caption := '';
  StringGrid1.RowCount := 1;
  StringGrid1.AutoSizeColumns;
  row := 0;

  button4.Visible := lowercase(getvalue('General', 'UserName', '')) = 'corpsman';
End;

Procedure TForm38.MenuItem1Click(Sender: TObject);
Begin
  // Open TB in Browser
  If (row > 0) Then Begin
    OpenURL(URL_OpenTBListing + lowercase(StringGrid1.Cells[TB_Code_Col, row]));
  End;
End;

Procedure TForm38.MenuItem2Click(Sender: TObject);
Var
  tb: TTravelbugRecord;
  i: LongInt;
Begin
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    Form4.RefresStatsMethod(StringGrid1.Cells[TB_DiscoverCode_Col, i], StringGrid1.Selection.Bottom - i + 1, 0, i = StringGrid1.Selection.Top);
    Application.ProcessMessages;
    If GCTGetTBLogRecord(StringGrid1.Cells[TB_DiscoverCode_Col, i], tb) Then Begin
      TB_CommitSQLTransactionQuery('Insert or Replace into trackables (TB_Code, Discover_Code, LogState, LogDate, Owner, ReleasedDate, Origin, Current_Goal, About_this_item, Comment, Heading) values(' +
        '"' + ToSQLString(Uppercase(tb.TB_Code)) + '" ' +
        ', "' + ToSQLString(Uppercase(tb.Discover_Code)) + '" ' +
        ', "' + TBLogstateToIntString(tb.LogState) + '" ' +
        ', "' + ToSQLString(tb.LogDate) + '" ' +
        ', "' + ToSQLString(tb.Owner) + '" ' +
        ', "' + ToSQLString(tb.ReleasedDate) + '" ' +
        ', "' + ToSQLString(tb.Origin) + '" ' +
        ', "' + ToSQLString(tb.Current_Goal) + '" ' +
        ', "' + ToSQLString(tb.About_this_item) + '" ' +
        ', "' + ToSQLString(tb.Comment) + '" ' +
        ', "' + ToSQLString(tb.Heading) + '" ' +
        ');'
        );
      TB_SQLTransaction.Commit;
      StringGrid1.Cells[TB_Code_Col, i] := tb.TB_Code;
      StringGrid1.Cells[TB_DiscoverCode_Col, i] := tb.Discover_Code;
      StringGrid1.Cells[TB_LogDate_Col, i] := tb.LogDate;
      StringGrid1.Cells[TB_Logstate_Col, i] := TBLogstateToString(tb.LogState);
      StringGrid1.Cells[TB_Owner_col, i] := tb.Owner;
      StringGrid1.Cells[TB_Heading_col, i] := tb.Heading;
    End;
    Application.ProcessMessages;
    If form4.Abbrechen Then break;
  End;
  form4.Hide;
End;

Procedure TForm38.StringGrid1DblClick(Sender: TObject);
Begin
  // Zeige TB-Details, alles was wir haben
  If (row > 0) And (row < StringGrid1.RowCount) Then Begin
    TB_StartSQLQuery('Select * from trackables where TB_Code = "' + ToSQLString(StringGrid1.Cells[TB_Code_Col, row]) + '"');
    Form42.LoadTBFromQuery();
    FormShowModal(Form42, self);
  End;
End;

Procedure TForm38.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  row := arow;
End;

Procedure TForm38.Button1Click(Sender: TObject);
Var
  q: String;
Begin
  // Starte Abfrage
  StringGrid1.RowCount := 1;
  q := '';
  If Edit3.Text <> '' Then Begin
    q := 'where owner like "%' + ToSQLString(Edit3.Text) + '%"';
  End;
  If Edit1.Text <> '' Then Begin
    If q = '' Then Begin
      q := ' where ';
    End
    Else Begin
      q := q + ' and ';
    End;
    q := q + 'logdate like "' + ToSQLString(Edit1.Text) + '"';
  End;
  If ComboBox2.Text <> '' Then Begin
    If q = '' Then Begin
      q := ' where ';
    End
    Else Begin
      q := q + ' and ';
    End;
    q := q + 'logstate = ' + TBLogstateToIntString(TBStringToLogstate(ComboBox2.Text));
  End;
  If edit2.text <> '' Then Begin
    If q = '' Then Begin
      q := ' where ';
    End
    Else Begin
      q := q + ' and ';
    End;
    q := q + '((TB_Code like "%' + ToSQLString(Edit2.Text) + '%") or (Discover_Code like "%' + ToSQLString(Edit2.Text) + '%"))';
  End;
  If edit4.text <> '' Then Begin
    If q = '' Then Begin
      q := ' where ';
    End
    Else Begin
      q := q + ' and ';
    End;
    q := q + '((About_this_item like "%' + ToSQLString(Edit4.Text) + '%") or (Comment like "%' + ToSQLString(Edit4.Text) + '%") or (Heading like "%' + ToSQLString(Edit4.Text) + '%"))';
  End;
  TB_StartSQLQuery('Select TB_Code, Discover_Code, LogDate, LogState, Owner, Heading from trackables ' + q);
  StringGrid1.BeginUpdate;
  While Not TB_SQLQuery.EOF Do Begin
    StringGrid1.RowCount := StringGrid1.RowCount + 1;
    StringGrid1.Cells[TB_Code_Col, StringGrid1.RowCount - 1] := FromSQLString(TB_SQLQuery.Fields[0].AsString);
    StringGrid1.Cells[TB_DiscoverCode_Col, StringGrid1.RowCount - 1] := FromSQLString(TB_SQLQuery.Fields[1].AsString);
    StringGrid1.Cells[TB_LogDate_Col, StringGrid1.RowCount - 1] := FromSQLString(TB_SQLQuery.Fields[2].AsString);
    StringGrid1.Cells[TB_Logstate_Col, StringGrid1.RowCount - 1] := TBLogstateToString(TBIntStringToLogstate(TB_SQLQuery.Fields[3].AsString));
    StringGrid1.Cells[TB_Owner_col, StringGrid1.RowCount - 1] := FromSQLString(TB_SQLQuery.Fields[4].AsString);
    StringGrid1.Cells[TB_Heading_col, StringGrid1.RowCount - 1] := FromSQLString(TB_SQLQuery.Fields[5].AsString);
    TB_SQLQuery.Next;
  End;
  StringGrid1.AutoSizeColumns;
  StringGrid1.EndUpdate();
  label5.caption := format(RF_Your_Query_results_in_datasets, [StringGrid1.RowCount - 1]);
End;

Procedure TForm38.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm38.Button3Click(Sender: TObject);
Var
  sl: TStringList;
  s: String;
  i, j: Integer;
Begin
  If StringGrid1.RowCount <= 1 Then Begin
    ShowMessage(R_Noting_Selected);
    exit;
  End;
  If SaveDialog1.Execute Then Begin
    sl := TStringList.Create;
    // Captions
    s := '';
    For i := 0 To StringGrid1.ColCount - 1 Do Begin
      s := s + '"' + StringReplace(StringGrid1.Columns[i].Title.Caption, '"', '""', [rfReplaceAll]) + '";';
    End;
    sl.Add(s);
    // Content
    For j := 1 To StringGrid1.RowCount - 1 Do Begin
      s := '';
      For i := 0 To StringGrid1.ColCount - 1 Do Begin
        s := s + '"' + StringReplace(StringGrid1.Cells[i, j], '"', '""', [rfReplaceAll]) + '";';
      End;
      sl.Add(s);
    End;
    sl.SaveToFile(SaveDialog1.FileName);
    sl.free;
    ShowMessage(R_Finished);
  End;
End;

Procedure TForm38.Button4Click(Sender: TObject);
Var
  od: String;
  data: Array Of Array[0..9] Of String;
  j, i: Integer;
Begin
  If OpenDialog1.Execute Then Begin
    If Not FileExistsUTF8(OpenDialog1.Filename) Then Begin
      showmessage(format(RF_Could_Not_Load, [OpenDialog1.Filename]));
      exit;
    End;
    od := tb_SQLite3Connection.DatabaseName;
    If tb_SQLite3Connection.Connected Then
      tb_SQLite3Connection.Connected := false;
    tb_SQLite3Connection.DatabaseName := OpenDialog1.Filename;
    Try
      tb_SQLite3Connection.Connected := true;
    Except
      On e: Exception Do Begin
        ShowMessage(format(RF_Error_Could_not_Connect, [e.Message]));
        exit;
      End;
    End;
    // Die gesamte Quell Datenbank einlesen
    TB_StartSQLQuery('Select ' +
      'TB_Code, ' +
      'Discover_Code, ' +
      'LogState, ' +
      'LogDate, ' +
      'Owner, ' +
      'ReleasedDate, ' +
      'Origin, ' +
      'Current_Goal, ' +
      'About_this_item, ' +
      'Comment from trackables');
    data := Nil;
    setlength(data, TB_SQLQuery.RecordCount);
    For j := 0 To TB_SQLQuery.RecordCount - 1 Do Begin
      For i := 0 To high(data[j]) Do Begin
        data[j, i] := TB_SQLQuery.Fields[i].AsString;
      End;
      TB_SQLQuery.Next;
    End;
    // Zurück schalten auf die Eigene
    tb_SQLite3Connection.Connected := false;
    tb_SQLite3Connection.DatabaseName := od;
    tb_SQLite3Connection.Connected := true;
    // Nun stück Für Stück in die Zieldatenbank mergen
    For j := 0 To high(data) Do Begin
      If data[j, 0] <> data[j, 1] Then Begin // Nur wenn TB-Code und Discovercode unterschiedlich sind => also tatsächlich ein Discovered
        TB_StartSQLQuery('Select TB_Code from trackables where Discover_Code = "' + data[j, 1] + '"');
        If TB_SQLQuery.EOF Then Begin // Es gibt den TB noch nicht in der Datenbank
          TB_CommitSQLTransactionQuery('Insert or Replace into trackables (TB_Code, Discover_Code, LogState, LogDate, Owner, ReleasedDate, Origin, Current_Goal, About_this_item, Comment) values(' +
            '"' + data[j, 0] + '" ' +
            ', "' + data[j, 1] + '" ' +
            ', "' + data[j, 2] + '" ' +
            ', "' + data[j, 3] + '" ' +
            ', "' + data[j, 4] + '" ' +
            ', "' + data[j, 5] + '" ' +
            ', "' + data[j, 6] + '" ' +
            ', "' + data[j, 7] + '" ' +
            ', "' + data[j, 8] + '" ' +
            ', "' + data[j, 9] + '" ' +
            ');'
            );
        End;
      End;
    End;
    TB_SQLTransaction.Commit;
    ShowMessage(R_Finished);
  End;
End;

Procedure TForm38.Edit3KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then Button1.Click;
End;

Procedure TForm38.PrepareLCL;
Begin
  // Owner
  Edit3.text := '';
  // Datum
  edit1.text := '';
  label4.caption := format(RF_eg_time, [FormatDateTime('DD.MM.YYYY', now)]);
  // Code
  Edit2.text := '';
  // Text
  Edit4.text := '';
  // State
  ComboBox2.Items.Clear;
  ComboBox2.items.add(''); // Keine Auswahl
  ComboBox2.ItemIndex := 0;
  // TB-Logstate
  TB_StartSQLQuery('Select distinct LogState from trackables order by LogState asc');
  While Not TB_SQLQuery.EOF Do Begin
    ComboBox2.items.add(TBLogstateToString(TBIntStringToLogstate(TB_SQLQuery.Fields[0].AsString)));
    TB_SQLQuery.Next;
  End;
  // Gesamt Anzahl aller TB's
  TB_StartSQLQuery('Select count(*) from trackables');
  label8.caption := R_Total + ': ' + TB_SQLQuery.Fields[0].AsString;
End;

End.

