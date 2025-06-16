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
Unit Unit14;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm14 }

  TForm14 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure ComboBox1Change(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }

  public
    { public declarations }
    Procedure ReloadLocations;
  End;

Var
  Form14: TForm14;

Implementation

{$R *.lfm}

Uses uccm, LCLType, ulanguage;

{ TForm14 }

Procedure TForm14.Button1Click(Sender: TObject);
Var
  clat, clon: Double;
Begin
  If Not StringToCoord(ComboBox2.Text + Edit1.Text + ComboBox3.Text + Edit2.Text, clat, clon) Then Begin
    showmessage(R_Could_not_decode);
    edit3.text := '';
    edit4.text := '';
    exit;
  End;
  edit3.text := floattostr(clat);
  edit4.text := floattostr(clon);
End;

Procedure TForm14.Button2Click(Sender: TObject);
Begin
  Modalresult := mrOK;
End;

Procedure TForm14.Button3Click(Sender: TObject);
Var
  c: String;
Begin
  c := CoordToString(strtofloat(edit3.text), strtofloat(edit4.text));
  StringCoordToComboboxEdit(c, ComboBox2, Edit1, ComboBox3, Edit2);
End;

Procedure TForm14.Button4Click(Sender: TObject);
Var
  count, index, i: integer;
Begin
  // Delete
  // In Ini
  index := GetIndexOfLocation(ComboBox1.Text, true);
  If index = -1 Then exit;
  If index = strtointdef(GetValue('General', 'AktualLocation', ''), -1) Then Begin
    If id_no = Application.MessageBox(pchar(format(RF_Deleting_Location, [ComboBox1.Text, ComboBox1.Text])), pchar(R_Warning), MB_YESNO Or MB_ICONWARNING) Then Begin
      exit;
    End;
    Setvalue('General', 'AktualLocation', '');
  End;

  count := strtoint(getValue('Locations', 'Count', '0'));
  For i := index To count - 2 Do Begin
    SetValue('Locations', 'Name' + inttostr(i), GetValue('Queries', 'Name' + inttostr(i + 1), ''));
    SetValue('Locations', 'Place' + inttostr(i), GetValue('Queries', 'Place' + inttostr(i + 1), ''));
  End;
  DeleteValue('Locations', 'Name' + inttostr(count - 1));
  DeleteValue('Locations', 'Place' + inttostr(count - 1));
  SetValue('Locations', 'Count', inttostr(count - 1));

  // Löschen aus der Combobox
  For i := 0 To ComboBox1.Items.Count - 1 Do Begin
    If ComboBox1.Items[i] = ComboBox1.Text Then Begin
      ComboBox1.Text := '';
      edit5.text := '';
      edit6.text := '';
      ComboBox1.Items.Delete(i);
      break;
    End;
  End;
End;

Procedure TForm14.Button5Click(Sender: TObject);
Var
  Count: integer;
  s: String;
  lat, lon: Double;
Begin
  // Add
  If Trim(ComboBox1.Text) = '' Then Begin
    showmessage(R_No_Location_Name_defined);
    exit;
  End;
  If StringToCoord(ComboBox4.Text + edit5.text + ComboBox5.Text + Edit6.text, lat, lon) Then Begin
    count := strtoint(GetValue('Locations', 'Count', '0'));
    SetValue('Locations', 'Name' + inttostr(Count), ComboBox1.Text);
    s := format('%0.6fx%0.6f', [lat, lon], DefFormat);
    SetValue('Locations', 'Place' + inttostr(Count), s);
    SetValue('Locations', 'Count', inttostr(Count + 1));
    ReloadLocations;
    If CheckBox1.Checked Then Begin
      setvalue('General', 'AktualLocation', inttostr(count));
    End;
  End
  Else Begin
    showmessage(format(RF_Error_unable_to_decode_location, [ComboBox4.Text + edit5.text, ComboBox5.Text + Edit6.text]));
  End;
End;

Procedure TForm14.Button6Click(Sender: TObject);
Var
  Index: integer;
  lat, lon: Double;
  s: String;
Begin
  // Overwrite
  index := GetIndexOfLocation(ComboBox1.Text, true);
  If index = -1 Then Begin
    showmessage(format(RF_Error_could_not_find, [ComboBox1.Text]));
    exit;
  End;
  If StringToCoord(ComboBox4.Text + edit5.text + ComboBox5.Text + Edit6.text, lat, lon) Then Begin
    s := format('%0.6fx%0.6f', [lat, lon], DefFormat);
    SetValue('Locations', 'Place' + inttostr(Index), s);
  End
  Else Begin
    showmessage(format(RF_Error_unable_to_decode_location, [ComboBox4.Text + edit5.text, ComboBox5.Text + Edit6.text]));
  End;
End;

Procedure TForm14.ComboBox1Change(Sender: TObject);
Var
  lat, lon: Extended;
  index: integer;
  s: String;
  c: String;
Begin
  index := GetIndexOfLocation(ComboBox1.Text, false);
  If index = -1 Then exit;
  s := getvalue('Locations', 'Place' + inttostr(index), '');
  lat := strtofloat(copy(s, 1, pos('x', s) - 1), DefFormat);
  lon := strtofloat(copy(s, pos('x', s) + 1, length(s)), DefFormat);
  c := CoordToString(lat, lon);
  StringCoordToComboboxEdit(c, ComboBox4, edit5, ComboBox5, edit6);
End;

Procedure TForm14.FormCreate(Sender: TObject);
Begin
  // Eigentlich sollte das der Dialog sein, in dem man Locations wie "Home" anlegen kann, aber diese Funktionalität sollte erhalten bleiben
  Caption := 'Location editor';
  edit1.text := '48° 48.550';
  edit2.text := '9° 2.123';
  button1.click;
End;

Procedure TForm14.ReloadLocations;
Var
  i: Integer;
Begin
  ComboBox1.Clear;
  ComboBox1.Text := '';
  Edit5.text := '';
  Edit6.text := '';
  For i := 0 To strtointdef(getvalue('Locations', 'Count', '0'), 0) - 1 Do Begin
    ComboBox1.Items.Add(getvalue('Locations', 'Name' + inttostr(i), ''));
  End;
End;

End.

