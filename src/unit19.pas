Unit Unit19;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm19 }

  TForm19 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    Procedure Button1Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure ListBox1Click(Sender: TObject);
  private
    { private declarations }
    Function GetIndexOfTool(Tool: String; ShowWarningIfNotFound: Boolean): integer; // Liefert den Index in der ccm.ini, welcher dem Filter zugeordnet ist
    Function CheckSettings(overwrite: Boolean): Boolean;
  public
    { public declarations }
    Procedure ReloadToolEntries;
  End;

Var
  Form19: TForm19;

Implementation

{$R *.lfm}

Uses uccm, ulanguage;

{ TForm19 }

Procedure TForm19.FormCreate(Sender: TObject);
Begin
  caption := 'Tool editor';
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
End;

Procedure TForm19.Button4Click(Sender: TObject);
Var
  Count: integer;
  s: String;
Begin
  // Add
  If Not CheckSettings(false) Then Begin
    showmessage(R_Incomplete_settings);
    exit;
  End;
  Count := StrToIntDef(Getvalue('Tools', 'Count', '0'), 0);
  SetValue('Tools', 'Name' + inttostr(count), edit1.text);
  Case ComboBox1.ItemIndex Of // Achtung ist Doppelt, gibts in Overwrite auch
    0: s := 'Exe';
    1: s := 'Link';
    2: Begin
        s := 'Root';
        ComboBox2.Items.Add(Edit1.text);
      End;
  End;
  SetValue('Tools', 'Type' + inttostr(count), s);
  SetValue('Tools', 'Value' + inttostr(count), edit2.text);
  SetValue('Tools', 'Parent' + inttostr(count), ComboBox2.Text);
  SetValue('Tools', 'Count', inttostr(count + 1));
  ListBox1.Items.add(Edit1.text);
End;

Procedure TForm19.Button5Click(Sender: TObject);
Begin
  showmessage(R_Tools_Help);
End;

Procedure TForm19.Button6Click(Sender: TObject);
Var
  n, t, v, p: String;
Begin
  // Nach Oben Schieben
  If ListBox1.ItemIndex > 0 Then Begin
    n := GetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex), '');
    t := GetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex), '');
    v := GetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex), '');
    p := GetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex), '');
    SetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex - 1), ''));
    SetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex - 1), ''));
    SetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex - 1), ''));
    SetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex - 1), ''));
    SetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex - 1), n);
    SetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex - 1), t);
    SetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex - 1), v);
    SetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex - 1), p);
    ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex - 1);
    ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
  End;
End;

Procedure TForm19.Button7Click(Sender: TObject);
Var
  n, t, v, p: String;
Begin
  // Nach Unten Schieben
  If ListBox1.ItemIndex < ListBox1.Count - 1 Then Begin
    n := GetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex), '');
    t := GetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex), '');
    v := GetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex), '');
    p := GetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex), '');
    SetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex + 1), ''));
    SetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex + 1), ''));
    SetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex + 1), ''));
    SetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex), GetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex + 1), ''));
    SetValue('Tools', 'Name' + inttostr(ListBox1.ItemIndex + 1), n);
    SetValue('Tools', 'Type' + inttostr(ListBox1.ItemIndex + 1), t);
    SetValue('Tools', 'Value' + inttostr(ListBox1.ItemIndex + 1), v);
    SetValue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex + 1), p);
    ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex + 1);
    ListBox1.ItemIndex := ListBox1.ItemIndex + 1;
  End;
End;

Procedure TForm19.Button3Click(Sender: TObject);
Var
  index: integer;
  s: String;
Begin
  // Overwrite
  index := GetIndexOfTool(Edit1.Text, true);
  If (Not CheckSettings(true)) Or (index = -1) Then Begin
    showmessage(R_Incomplete_settings);
    exit;
  End;
  Case ComboBox1.ItemIndex Of // Achtung ist Doppelt, gibts in Add auch
    0: s := 'Exe';
    1: s := 'Link';
    2: s := 'Root';
  End;
  SetValue('Tools', 'Type' + inttostr(Index), s);
  SetValue('Tools', 'Value' + inttostr(Index), edit2.text);
  SetValue('Tools', 'Parent' + inttostr(Index), ComboBox2.text);
End;

Procedure TForm19.Button1Click(Sender: TObject);
Var
  count, index, i: integer;
  s: String;
Begin
  // Delete
  index := GetIndexOfTool(Edit1.text, true);
  If index = -1 Then exit;
  count := strtoint(getValue('Tools', 'Count', '0'));
  If lowercase(GetValue('Tools', 'Type' + inttostr(index), '')) = 'root' Then Begin
    // Wir löschen einen Root Knoten
    s := lowercase(GetValue('Tools', 'Name' + inttostr(index), ''));
    For i := 0 To ComboBox2.Items.Count - 1 Do Begin
      If lowercase(ComboBox2.Items[i]) = s Then Begin
        ComboBox2.Items.Delete(i);
        break;
      End;
    End;
    // Nachdem der Restcode damit Klar kommt, wenn ein Node einen nicht gültigen parent hat, brauchen wir diesen nicht zu löschen *g*
  End;
  For i := index To count - 2 Do Begin
    SetValue('Tools', 'Name' + inttostr(i), GetValue('Tools', 'Name' + inttostr(i + 1), ''));
    SetValue('Tools', 'Type' + inttostr(i), GetValue('Tools', 'Type' + inttostr(i + 1), ''));
    SetValue('Tools', 'Value' + inttostr(i), GetValue('Tools', 'Value' + inttostr(i + 1), ''));
    SetValue('Tools', 'Parent' + inttostr(i), GetValue('Tools', 'Parent' + inttostr(i + 1), ''));
  End;
  DeleteValue('Tools', 'Name' + inttostr(count - 1));
  DeleteValue('Tools', 'Type' + inttostr(count - 1));
  DeleteValue('Tools', 'Value' + inttostr(count - 1));
  DeleteValue('Tools', 'Parent' + inttostr(count - 1));
  SetValue('Tools', 'Count', inttostr(count - 1));
  // Löschen aus der Listbox
  For i := 0 To ListBox1.Items.Count - 1 Do Begin
    If ListBox1.Items[i] = edit1.text Then Begin
      edit1.text := '';
      edit2.text := '';
      ListBox1.Items.Delete(i);
      ComboBox2.Text := '';
      break;
    End;
  End;
End;

Procedure TForm19.ListBox1Click(Sender: TObject);
Var
  s: String;
Begin
  // Select a entry
  If ListBox1.ItemIndex <> -1 Then Begin
    edit1.text := ListBox1.Items[ListBox1.ItemIndex];
    Case lowercase(Getvalue('Tools', 'Type' + inttostr(ListBox1.ItemIndex), '')) Of
      'exe': ComboBox1.ItemIndex := 0;
      'link': ComboBox1.ItemIndex := 1;
      'root': ComboBox1.ItemIndex := 2;
    End;
    edit2.text := Getvalue('Tools', 'Value' + inttostr(ListBox1.ItemIndex), '');
    s := Getvalue('Tools', 'Parent' + inttostr(ListBox1.ItemIndex), '');
    If pos(lowercase(s), lowercase(ComboBox2.Items.Text)) = 0 Then s := '';
    ComboBox2.Text := s;
  End
  Else Begin
    edit1.text := '';
    Edit2.text := '';
  End;
End;

Function TForm19.GetIndexOfTool(Tool: String; ShowWarningIfNotFound: Boolean
  ): integer;
Var
  i: Integer;
Begin
  result := -1;
  For i := 0 To strtointdef(getValue('Tools', 'Count', '0'), 0) - 1 Do Begin
    If GetValue('Tools', 'Name' + inttostr(i), '') = Tool Then Begin
      result := i;
      exit;
    End;
  End;
  If ShowWarningIfNotFound Then Begin
    showmessage(format(RF_Could_not_locate_tool_Did_you_really_added_it_first, [Tool]));
  End;
End;

Function TForm19.CheckSettings(overwrite: Boolean): Boolean;
Begin
  If (trim(edit1.text) = '') Then Begin
    result := false;
    exit;
  End;
  If Not overwrite Then Begin
    // Gibt es den Namen schon ?
    If pos(lowercase(edit1.text), lowercase(ComboBox2.Text)) <> 0 Then Begin
      result := false;
    End;
  End;
  result := true;
  Case ComboBox1.ItemIndex Of
    0, 1: Begin // Die Normalen Einträge
        If (trim(edit2.text) = '') Then Begin
          result := false;
        End;
      End;
    2: Begin // Die Root Nodes
        result := ComboBox2.Text = ''; // Root nodes dürfen keinen Parent haben
        If trim(Edit2.text) <> '' Then result := false; // Root Nodes dürfen keinen Befehl haben
      End;
  End;
End;

Procedure TForm19.ReloadToolEntries;
Var
  i: Integer;
Begin
  listbox1.Items.Clear;
  ComboBox2.items.clear;
  ComboBox2.Items.add('');
  For i := 0 To strtointdef(Getvalue('Tools', 'Count', '0'), 0) - 1 Do Begin
    listbox1.Items.Add(Getvalue('Tools', 'Name' + inttostr(i), '- - -'));
    If lowercase(Getvalue('Tools', 'Type' + inttostr(i), '')) = 'root' Then Begin
      ComboBox2.Items.Add(Getvalue('Tools', 'Name' + inttostr(i), '- - -'));
    End;
  End;
  // Reset auf leer
  edit1.text := '';
  Edit2.text := '';
  ComboBox1.ItemIndex := 0;
  listbox1.ItemIndex := -1;
End;

End.

