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
Unit Unit24;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SynEdit,
  SynHighlighterSQL, sqldb;

Type

  { TForm24 }

  TForm24 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SynEdit1: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure FormShow(Sender: TObject);
  private
  public
    Procedure ReloadQueries;
  End;

Var
  Form24: TForm24;
  form24ShowOnce: Boolean = true;

Implementation

{$R *.lfm}

Uses
  usqlite_helper,
  uccm,
  unit1,
  unit25,
  unit26,
  LazUTF8,
  db, math, ulanguage;

{ TForm24 }

Function Lowerformat(Value: String): String;
Begin
  value := lowercase(value);
  While pos('#13', value) <> 0 Do
    delete(value, pos('#13', value), 1);
  While pos('#10', value) <> 0 Do
    delete(value, pos('#10', value), 1);
  result := trim(value);
End;

Function ToLen(Len: Integer; value: String): String;
Begin
  While UTF8Length(value) < len Do
    value := ' ' + value;
  result := value;
End;

Procedure TForm24.Button1Click(Sender: TObject);

Type
  TCol = Record
    MaxLen: Integer;
    Data: Array Of String;
  End;

  TTableCache = Array Of TCol;

Var
  stt, st: String;
  f: TField;
  s: TStringlist;
  a: TTableCache;
  j, c, i: Integer;
  b: Boolean;
  SQLQuery: TSQLQuery;
Begin
  If ComboBox3.ItemIndex = 0 Then Begin
    SQLQuery := form1.SQLQuery1;
  End
  Else Begin
    SQLQuery := form1.SQLQuery2;
  End;
  // As Query
  If Not form1.SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  SQLQuery.Active := false;
  SQLQuery.SQL.Clear;

  If Not Form26.Visible Then Begin
    form26.left := form24.left - form26.width - 8;
    form26.top := form24.top;
    BringFormBackToScreen(Form26);
    Form26.Show;
  End;
  form26.BringToFront;

  If Not Form25.Visible Then Begin
    form25.left := form24.left + form24.Width + 8;
    form25.top := form24.top;
    BringFormBackToScreen(Form25);
    Form25.Show;
  End;
  form25.BringToFront;

  st := SynEdit1.Lines.Text;
  stt := Lowerformat(st);
  b := false;
  For i := 0 To form26.ListBox1.Count - 1 Do Begin
    If stt = Lowerformat(form26.ListBox1.Items[i]) Then Begin
      b := true;
      form26.ListBox1.ItemIndex := i;
      break;
    End;
  End;
  // Einfügen in die History
  If Not b Then Begin
    form26.ListBox1.Items.add(st);
  End;
  If Length(st) <> 0 Then Begin
    SQLQuery.SQL.Text := st;
  End
  Else Begin
    exit;
  End;
  Try
    SQLQuery.Open;
  Except
    On e: Exception Do Begin
      ShowMessage(format(RF_Error_invalid_Query, [e.Message]));
      exit;
    End;
  End;
  // Wenn überhaupt etwas ausgelesen werden konnte
  a := Nil;
  If SQLQuery.Fields.Count <> 0 Then Begin
    setlength(a, SQLQuery.Fields.Count);
    // Die Labels Setzen
    s := TStringlist.create;
    SQLQuery.Fields.GetFieldNames(s);
    For i := 0 To s.count - 1 Do Begin
      setlength(a[i].Data, 1);
      a[i].Data[0] := s[i];
      a[i].MaxLen := length(s[i]);
    End;
    // Auslesen aller gesendeter Daten
    While (Not SQLQuery.EOF) Do Begin
      For i := 0 To s.count - 1 Do Begin
        setlength(a[i].Data, high(a[i].Data) + 2);
        f := SQLQuery.Fields.FieldByName(s[i]);
        If assigned(f) Then Begin
          a[i].Data[high(a[i].Data)] := f.AsString;
          // Speichern der Maximalen Breite
          a[i].MaxLen := max(a[i].MaxLen, length(a[i].Data[high(a[i].Data)]));
        End;
      End;
      SQLQuery.Next;
    End;
    s.free;
  End;
  // Löschen der Alten Ausgabe
  form25.memo1.Clear;
  // Konvertierung der Ausgabe
  If assigned(a) Then Begin
    For j := 0 To high(a[0].Data) Do Begin
      st := '';
      For i := 0 To high(a) Do Begin
        If i <> high(a) Then
          st := st + ToLen(a[i].MaxLen, a[i].Data[j]) + '|'
        Else
          st := st + ToLen(a[i].MaxLen, a[i].Data[j]);
      End;
      form25.memo1.Lines.add(st);
      If j = 0 Then Begin
        c := length(st);
        st := '';
        While length(st) < c Do
          st := st + '-';
        form25.memo1.Lines.add(st);
      End;
    End;
  End;
  form25.Show;
End;

Procedure TForm24.Button2Click(Sender: TObject);
Var
  st, stt: String;
  b: Boolean;
  i: Integer;
Begin
  // As transaction
  If Not form1.SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  st := SynEdit1.Lines.Text;
  If Length(st) = 0 Then Begin
    exit;
  End;
  stt := Lowerformat(st);
  b := false;
  For i := 0 To form26.ListBox1.Count - 1 Do Begin
    If stt = Lowerformat(form26.ListBox1.Items[i]) Then Begin
      b := true;
      form26.ListBox1.ItemIndex := i;
      break;
    End;
  End;
  // Einfügen in die History
  If Not b Then Begin
    form26.ListBox1.Items.add(st);
  End;
  If ComboBox3.ItemIndex = 0 Then Begin
    If CommitSQLTransactionQuery(SynEdit1.Text) Then Begin
      Form1.SQLTransaction1.Commit;
    End;
  End
  Else Begin
    If TB_CommitSQLTransactionQuery(SynEdit1.Text) Then Begin
      Form1.SQLTransaction2.Commit;
    End
  End;
  If form25.Visible Then form25.Close;
  showmessage(R_Finished);
End;

Procedure TForm24.Button3Click(Sender: TObject);
Begin
  // Close
  If Form25.Visible Then Form25.Close;
  If Form26.Visible Then Form26.Close;
  ModalResult := mrClose;
End;

Procedure TForm24.Button4Click(Sender: TObject);
Begin
  // Load
  If ComboBox1.ItemIndex <> -1 Then Begin
    SynEdit1.Text := FromSQLString(getValue('SQLAdmin', 'Query' + inttostr(ComboBox1.ItemIndex), ''));
  End;
End;

Procedure TForm24.Button5Click(Sender: TObject);
Begin
  // Save Query as
  SetValue('SQLAdmin', 'Name' + inttostr(ComboBox1.Items.Count), Edit1.text);
  SetValue('SQLAdmin', 'Query' + inttostr(ComboBox1.Items.Count), ToSQLString(SynEdit1.text));
  SetValue('SQLAdmin', 'Count', inttostr(ComboBox1.Items.Count + 1));
  ReloadQueries;
  ComboBox1.text := Edit1.Text;
End;

Procedure TForm24.Button6Click(Sender: TObject);
Var
  i: Integer;
Begin
  // Delete Query
  If ComboBox2.ItemIndex <> -1 Then Begin
    For i := ComboBox2.ItemIndex To strtoint(getValue('SQLAdmin', 'Count', '0')) - 1 Do Begin
      SetValue('SQLAdmin', 'Name' + inttostr(i), GetValue('SQLAdmin', 'Name' + inttostr(i), ''));
      SetValue('SQLAdmin', 'Query' + inttostr(i), GetValue('SQLAdmin', 'Query' + inttostr(i), ''));
    End;
    SetValue('SQLAdmin', 'Count', inttostr(strtoint(GetValue('SQLAdmin', 'Count', '1')) - 1));
    ReloadQueries;
  End;
End;

Procedure TForm24.Button7Click(Sender: TObject);
Begin
  // Online Hilfe
  showmessage('Like operator: ' + LineEnding +
    '"_" any single character' + LineEnding +
    '"%" any character including none' + LineEnding +
    ''' = Escape character' + LineEnding +
    '" = Escape character' + LineEnding + LineEnding +
    '|| = String Concatenation' + LineEnding +
    '+3 = NewLine' + LineEnding + LineEnding +
    'https://www.sqlite.org/lang.html = Language information');
End;

Procedure TForm24.FormShow(Sender: TObject);
Begin
  If form24ShowOnce Then Begin
    form24ShowOnce := false;
    form24.edit1.text := R_New_Query_Name;
    top := Screen.Monitors[0].Top;
    left := Screen.Monitors[0].Left + form26.width + 8;
  End;
End;

Procedure TForm24.ReloadQueries;
Var
  a, b: String;
  i: Integer;
Begin
  // Aktualisiert alle Querie namen in den Comboboxen
  a := ComboBox1.Text;
  b := ComboBox1.Text;
  ComboBox1.Clear;
  ComboBox2.Clear;
  For i := 0 To strtoint(getValue('SQLAdmin', 'Count', '0')) - 1 Do Begin
    ComboBox1.Items.Add(getValue('SQLAdmin', 'Name' + inttostr(i), ''));
    ComboBox2.Items.Add(getValue('SQLAdmin', 'Name' + inttostr(i), ''));
  End;
  For i := 0 To ComboBox1.Items.Count - 1 Do Begin
    If a = ComboBox1.Items[i] Then Begin
      ComboBox1.Text := a;
      break;
    End;
  End;
  For i := 0 To ComboBox2.Items.Count - 1 Do Begin
    If b = ComboBox2.Items[i] Then Begin
      ComboBox2.Text := b;
      break;
    End;
  End;
End;

End.

