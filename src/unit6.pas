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
Unit Unit6;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterSQL, SynCompletion, Forms,
  Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm6 }

  TForm6 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SynCompletion1: TSynCompletion;
    SynEdit1: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure ComboBox1Change(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    Function GetIndexOfFilter(Filter: String; ShowWarningIfNotFound: Boolean): integer; // Liefert den Index in der ccm.ini, welcher dem Filter zugeordnet ist
  public
    { public declarations }
  End;

Var
  Form6: TForm6;

Implementation

{$R *.lfm}

Uses unit1, unit27, usqlite_helper, uccm, LCLType, ulanguage;

{ TForm6 }

Procedure TForm6.ComboBox1Change(Sender: TObject);
Var
  index: integer;
Begin
  // Neu Laden einer anderen Query
  index := GetIndexOfFilter(ComboBox1.text, False);
  If index = -1 Then exit;
  SynEdit1.text := FromSQLString(GetValue('Queries', 'Query' + IntToStr(Index), ''));
End;

Procedure TForm6.FormCreate(Sender: TObject);
Begin
  caption := 'Filter editor';
  Constraints.MinWidth := width;
  Constraints.MinHeight := Height;
End;

Function TForm6.GetIndexOfFilter(Filter: String; ShowWarningIfNotFound: Boolean
  ): integer;
Var
  i: Integer;
Begin
  result := -1;
  For i := 0 To strtointdef(getValue('Queries', 'Count', '0'), 0) - 1 Do Begin
    If GetValue('Queries', 'Name' + inttostr(i), '') = Filter Then Begin
      result := i;
      exit;
    End;
  End;
  If ShowWarningIfNotFound Then Begin
    showmessage(format(RF_Could_not_locate_Query, [Filter]));
  End;
End;

Procedure TForm6.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm6.Button3Click(Sender: TObject);
Var
  index: integer;
Begin
  // Overwrite
  index := GetIndexOfFilter(ComboBox1.Text, true);
  If index = -1 Then exit;
  SetValue('Queries', 'Query' + inttostr(Index), ToSQLString(SynEdit1.text));
End;

Procedure TForm6.Button4Click(Sender: TObject);
Var
  Count, index, i, j: integer;
  sn: String;
Begin
  // Del
  // Schauen ob ein Skript ungültig wird
  For i := 0 To StrToInt(getvalue('Scripts', 'Count', '0')) - 1 Do Begin
    sn := getvalue('Scripts', 'Name' + inttostr(i), '');
    For j := 0 To strtoint(GetValue('Script_' + sn, 'Count', '0')) - 1 Do Begin
      If getvalue('Script_' + sn, 'Type' + inttostr(j), '') = inttostr(Script_Exec_Filter_Query) Then Begin
        If ComboBox1.Text = GetValue('Script_' + sn, 'filter' + IntToStr(j), '') Then Begin
          If id_no = Application.MessageBox(pchar(
            format(RF_Delete_Filter_Will_Fail_Script, [ComboBox1.Text, FromSQLString(sn), ComboBox1.Text])
            ), pchar(R_Warning), MB_YESNO Or MB_ICONWARNING) Then Begin
            exit;
          End;
          break;
        End;
      End;
    End;
  End;
  // Löschen aus der ini
  index := GetIndexOfFilter(ComboBox1.Text, true);
  If index = -1 Then exit;
  count := strtoint(getValue('Queries', 'Count', '0'));
  For i := index To count - 2 Do Begin
    SetValue('Queries', 'Name' + inttostr(i), GetValue('Queries', 'Name' + inttostr(i + 1), ''));
    SetValue('Queries', 'Query' + inttostr(i), GetValue('Queries', 'Query' + inttostr(i + 1), ''));
  End;
  DeleteValue('Queries', 'Name' + inttostr(count - 1));
  DeleteValue('Queries', 'Query' + inttostr(count - 1));
  SetValue('Queries', 'Count', inttostr(count - 1));
  // Löschen aus der Combobox
  For i := 0 To ComboBox1.Items.Count - 1 Do Begin
    If ComboBox1.Items[i] = ComboBox1.Text Then Begin
      ComboBox1.Text := '';
      SynEdit1.Text := '';
      ComboBox1.Items.Delete(i);
      break;
    End;
  End;
End;

Procedure TForm6.Button5Click(Sender: TObject);
Begin
  // Add Filter
  If (trim(Combobox1.text) = R_Customize) Or (Trim(ComboBox1.Text) = '-') Then Begin
    showmessage(format(RF_Value_not_Allowd, [Combobox1.text]));
    exit;
  End;
  SetValue('Queries', 'Name' + inttostr(ComboBox1.Items.Count), trim(Combobox1.text));
  SetValue('Queries', 'Query' + inttostr(ComboBox1.Items.Count), ToSQLString(SynEdit1.text));
  SetValue('Queries', 'Count', inttostr(ComboBox1.Items.Count + 1));
  ComboBox1.Items.Add(ComboBox1.Text);
End;

Procedure TForm6.Button6Click(Sender: TObject);
Begin
  // Online Hilfe
  showmessage('Like operator: ' + LineEnding +
    '"_" any single character' + LineEnding +
    '"%" any character including none' + LineEnding +
    ''' = Escape character' + LineEnding +
    '" = Escape character' + LineEnding + LineEnding +
    '|| = String Concatenation' + LineEnding +
    '+3 = NewLine' + LineEnding + LineEnding +
    '+5 = -' + LineEnding + LineEnding +
    'https://www.sqlite.org/lang.html = Language information');
End;

Procedure TForm6.Button7Click(Sender: TObject);
Var
  value: String;
  index: Integer;
Begin
  value := '';
  index := GetIndexOfFilter(ComboBox1.Text, false);
  If index = -1 Then Begin
    ShowMessage(R_Noting_Selected);
    exit;
  End;
  If InputQuery(R_Question, R_Enter_new_filter_name, false, value) Then Begin
    // 1. Prüfen ob es den neuen Filter mit Namen schon gibt
    If GetIndexOfFilter(value, false) <> -1 Then Begin
      showmessage(format(rF_error_already_exists, [value]));
      exit;
    End;
    // 2. Ersetzen
    SetValue('Queries', 'Name' + inttostr(Index), value);
    ComboBox1.Items[index] := value;
    ComboBox1.Text := value;
  End;
End;

Procedure TForm6.Button8Click(Sender: TObject);
Var
  s: String;
Begin
  // Reset Filter
  s := GetDefaultFilterFor(ComboBox1.Text);
  If s <> '' Then Begin
    SynEdit1.Text := s;
  End
  Else Begin
    ShowMessage(format(RF_Error_could_not_find_default_value_for, [ComboBox1.Text]));
  End;
End;

Procedure TForm6.Button1Click(Sender: TObject);
Begin
  // Test
  If StartSQLQuery('select count(*) from (' +
    unit1.QueryToMainGridSelector + 'from caches c '
    //select distinct c.name from caches c '
    + SynEdit1.Text + ')') Then Begin
    showmessage(format(RF_Your_query_results_in_caches, [form1.SQLQuery1.Fields[0].AsString]));
  End;
End;

End.

