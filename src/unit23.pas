Unit Unit23;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, Menus;

Type

  { TForm23 }

  TForm23 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
    Procedure StringGrid2SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
  private
    { private declarations }
    row: integer;
  public
    { public declarations }
    Procedure LoadTBList;
    Procedure LoadTBGroupList;
  End;

Var
  Form23: TForm23;

Implementation

{$R *.lfm}

Uses uccm, ulanguage, LCLIntf;

{ TForm23 }

Procedure TForm23.LoadTBList;
Var
  cnt, i: integer;
Begin
  StringGrid1.BeginUpdate;
  cnt := strtointdef(getvalue('TBs', 'Count', '0'), 0);
  StringGrid1.RowCount := 1 + cnt;
  For i := 0 To cnt - 1 Do Begin
    StringGrid1.cells[0, i + 1] := GetValue('TBs', 'TBCode' + inttostr(i), '');
    StringGrid1.cells[1, i + 1] := GetValue('TBs', 'TBDescription' + inttostr(i), '');
  End;
  StringGrid1.AutoSizeColumns;
  StringGrid1.EndUpdate;
End;

Procedure TForm23.LoadTBGroupList;
Var
  cnt, i: integer;
Begin
  StringGrid2.BeginUpdate;
  cnt := strtointdef(getvalue('TBGroups', 'Count', '0'), 0);
  StringGrid2.RowCount := 1 + cnt;
  For i := 0 To cnt - 1 Do Begin
    StringGrid2.cells[0, i + 1] := GetValue('TBGroups', 'Name' + inttostr(i), '');
    StringGrid2.cells[1, i + 1] := GetValue('TBGroups', 'Content' + inttostr(i), '');
  End;
  StringGrid2.AutoSizeColumns;
  StringGrid2.EndUpdate;
End;

Procedure TForm23.FormCreate(Sender: TObject);
Begin
  caption := 'Travel Bug editor';
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  StringGrid1.Columns[0].Title.Caption := 'TB-Code';
  StringGrid1.Columns[1].Title.Caption := 'Description';
  StringGrid1.AutoSizeColumn(1);

  StringGrid2.Columns[0].Title.Caption := 'Group';
  StringGrid2.Columns[1].Title.Caption := 'TBs';
  StringGrid2.AutoSizeColumn(1);

  edit1.text := '';
  edit2.text := '';
  edit3.text := '';
End;

Procedure TForm23.MenuItem1Click(Sender: TObject);
Begin
  // Open TB in Browser
  OpenURL(URL_OpenTBListing + lowercase(StringGrid1.Cells[0, row]));
End;

Procedure TForm23.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  row := aRow;
  edit1.text := StringGrid1.Cells[0, aRow];
  edit2.text := StringGrid1.Cells[1, aRow];
End;

Procedure TForm23.StringGrid2SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  edit3.text := StringGrid2.Cells[0, arow];
End;

Procedure TForm23.Button1Click(Sender: TObject);
Var
  cnt, i: integer;
  TBCode: String;
Begin
  // Add
  TBCode := trim(uppercase(Edit1.text));
  If pos('TB', TBCode) <> 1 Then Begin
    showmessage(R_Error_trackable_code_has_to_begin_with_TB);
    exit;
  End;
  cnt := strtointdef(getvalue('TBs', 'Count', '0'), 0);
  For i := 0 To cnt - 1 Do Begin
    If Uppercase(getValue('TBs', 'TBCode' + inttostr(i), '')) = TBCode Then Begin
      ShowMessage(format(RF_error_already_exists, [tbcode]));
      exit;
    End;
  End;
  SetValue('TBs', 'TBCode' + inttostr(cnt), TBCode);
  SetValue('TBs', 'TBDescription' + inttostr(cnt), edit2.text);
  SetValue('TBs', 'Count', inttostr(cnt + 1));
  LoadTBList;
End;

Procedure TForm23.Button2Click(Sender: TObject);
Var
  cnt, index, i: integer;
  TBCode: String;
Begin
  // Overwrite TB
  TBCode := uppercase(Edit1.Text);
  index := -1;
  cnt := strtointdef(getvalue('TBs', 'Count', '0'), 0);
  For i := 0 To cnt - 1 Do Begin
    If Uppercase(getValue('TBs', 'TBCode' + inttostr(i), '')) = TBCode Then Begin
      index := i;
      break;
    End;
  End;
  If index = -1 Then Begin
    showmessage(format(RF_Error_could_not_find, [TBCode]));
    exit;
  End;
  SetValue('TBs', 'TBCode' + inttostr(index), TBCode);
  SetValue('TBs', 'TBDescription' + inttostr(index), edit2.text);
  LoadTBList;
End;

Procedure TForm23.Button3Click(Sender: TObject);
Var
  s: String;
  i: integer;
Begin
  // Del tb
  If StringGrid1.Selection.Top < 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  // den TB aus den Gruppen löschen
  s := StringGrid1.Cells[0, StringGrid1.Selection.Top];
  For i := 1 To StringGrid2.RowCount - 1 Do Begin
    If pos(s, StringGrid2.Cells[1, i]) <> 0 Then Begin
      SelectAndScrollToRow(StringGrid2, i);
      Button6Click(Nil);
    End;
  End;
  // Den Eigentlichen TB löschen
  For i := StringGrid1.Selection.Top To StringGrid1.RowCount - 1 Do Begin
    SetValue('TBs', 'TBCode' + inttostr(i - 1), GetValue('TBs', 'TBCode' + inttostr(i), ''));
    SetValue('TBs', 'TBDescription' + inttostr(i - 1), GetValue('TBs', 'TBDescription' + inttostr(i), ''));
  End;
  i := strtointdef(getvalue('TBs', 'Count', '0'), 0);
  SetValue('TBs', 'Count', inttostr(i - 1));
  LoadTBList;
End;

Procedure TForm23.Button5Click(Sender: TObject);
Var
  s: String;
Begin
  // Add TB to Group
  If StringGrid1.Selection.Top < 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If StringGrid2.Selection.Top < 1 Then Begin
    showmessage(R_No_group_to_add_to);
    exit;
  End;
  s := StringGrid2.Cells[1, StringGrid2.Selection.Top];
  If pos(StringGrid1.Cells[0, StringGrid1.Selection.Top], s) <> 0 Then Begin
    showmessage(R_TB_is_already_member_of_the_group);
    exit;
  End;
  If trim(s) = '' Then Begin
    s := StringGrid1.Cells[0, StringGrid1.Selection.Top];
  End
  Else Begin
    s := s + ', ' + StringGrid1.Cells[0, StringGrid1.Selection.Top];
  End;
  StringGrid2.Cells[1, StringGrid2.Selection.Top] := s;
  StringGrid2.AutoSizeColumns;
  SetValue('TBGroups', 'Content' + inttostr(StringGrid2.Selection.Top - 1), s);
End;

Procedure TForm23.Button6Click(Sender: TObject);
Var
  t, s: String;
Begin
  // Del TB from Group
  If StringGrid1.Selection.Top < 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If StringGrid2.Selection.Top < 1 Then Begin
    showmessage(R_No_group_to_delete_tb_from_to);
    exit;
  End;
  s := StringGrid1.Cells[0, StringGrid1.Selection.Top];
  t := StringGrid2.Cells[1, StringGrid2.Selection.Top];
  If pos(s, t) = 0 Then Begin
    showmessage(R_TB_is_not_in_group_can_not_delete);
    exit;
  End;
  If pos(', ' + s, t) <> 0 Then Begin
    delete(t, pos(', ' + s, t), length(s) + 2);
  End
  Else Begin
    If pos(s + ', ', t) <> 0 Then Begin
      delete(t, pos(s + ', ', t), length(s) + 2);
    End
    Else Begin
      delete(t, pos(s, t), length(s));
    End;
  End;
  StringGrid2.Cells[1, StringGrid2.Selection.Top] := t;
  StringGrid2.AutoSizeColumns;
  SetValue('TBGroups', 'Content' + inttostr(StringGrid2.Selection.Top - 1), t);
End;

Procedure TForm23.Button7Click(Sender: TObject);
Var
  cnt: LongInt;
Begin
  // Add Group
  cnt := strtointdef(getvalue('TBGroups', 'Count', '0'), 0);
  SetValue('TBGroups', 'Name' + inttostr(cnt), edit3.text);
  SetValue('TBGroups', 'Content' + inttostr(cnt), '');
  SetValue('TBGroups', 'Count', inttostr(cnt + 1));
  LoadTBGroupList;
End;

Procedure TForm23.Button8Click(Sender: TObject);
Var
  i: integer;
Begin
  // del Group
  If StringGrid2.Selection.Top < 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  For i := StringGrid2.Selection.Top To StringGrid1.RowCount - 1 Do Begin
    SetValue('TBGroups', 'Name' + inttostr(i - 1), GetValue('TBGroups', 'Name' + inttostr(i), ''));
    SetValue('TBGroups', 'Content' + inttostr(i - 1), GetValue('TBGroups', 'Content' + inttostr(i), ''));
  End;
  i := strtointdef(getvalue('TBGroups', 'Count', '0'), 0);
  SetValue('TBGroups', 'Count', inttostr(i - 1));
  LoadTBGroupList;
End;

Procedure TForm23.Button9Click(Sender: TObject);
Begin
  // Rename Group
  If StringGrid2.Selection.Top < 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  SetValue('TBGroups', 'Name' + inttostr(StringGrid2.Selection.Top - 1), edit3.text);
  LoadTBGroupList;
End;

End.

