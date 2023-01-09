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
Unit Unit5;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm5 }

  TForm5 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: char);
    Procedure Edit3KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

    (*
     * Ruft den Dialog auf und Handelt alles Ab was nötig ist.
     * True, wenn was geändert wurde
     *)
    Function ModifyCoordinate(GC_Code: String; Sender: TForm): Boolean;
  End;

Var
  Form5: TForm5;

Implementation

{$R *.lfm}

Uses unit31, uccm, ulanguage, umapviewer;

{ TForm5 }

Procedure TForm5.Button3Click(Sender: TObject);
Var
  lat, lon: String;
Begin
  // Reset
  RadioButton1.Checked := true;
  lat := trim(copy(label1.Caption, pos(':', label1.caption) + 1, length(Label1.Caption)));
  lon := trim(copy(label2.Caption, pos(':', label2.caption) + 1, length(Label2.Caption)));
  StringCoordToComboboxEdit(lat + lon, ComboBox2, Edit1, ComboBox3, Edit2);
  form5.edit3.text := ComboBox2.Text + ' ' + Edit1.Text + ' ' + ComboBox3.Text + ' ' + Edit2.Text;
End;

Procedure TForm5.Button4Click(Sender: TObject);
Var
  lat, Lon: Double;
  s: String;
Begin
  // Wegpunkt Projektion
  If Form5.RadioButton1.Checked Then Begin
    s := form5.ComboBox2.Text + form5.Edit1.Text + ' ' + form5.ComboBox3.Text + form5.Edit2.Text;
  End
  Else Begin
    s := Edit3.Text;
  End;
  If Not StringToCoord(s, lat, lon) Then Begin
    Showmessage(R_Error_invalid_input_nothing_changed);
    exit;
  End;
  form31.InitWithPoint(lat, lon);
  FormShowModal(form31, self);
  If form31.ModalResult = mrOK Then Begin
    s := CoordToString(form31.ResultLat, form31.ResultLon);
    // Übernehmen in die Edit Felder
    If Form5.RadioButton1.Checked Then Begin
      If s[1] = 'N' Then Begin
        ComboBox2.ItemIndex := 0;
      End
      Else Begin
        ComboBox2.ItemIndex := 1;
      End;
      delete(s, 1, 1);
      If pos('E', s) = 0 Then Begin
        // * W *
        ComboBox2.ItemIndex := 1;
        edit1.text := trim(copy(s, 1, pos('W', s) - 1));
        delete(s, 1, pos('W', s));
        edit2.text := Trim(s);
      End
      Else Begin
        // * E *
        ComboBox2.ItemIndex := 0;
        edit1.text := trim(copy(s, 1, pos('E', s) - 1));
        delete(s, 1, pos('E', s));
        edit2.text := Trim(s);
      End;
    End
    Else Begin
      edit3.text := s;
    End;
  End;
End;

Procedure TForm5.Edit1KeyPress(Sender: TObject; Var Key: char);
Begin
  RadioButton1.Checked := true;
  RadioButton2.Checked := false;
  If key = #13 Then Begin
    Button2.Click;
  End;
  If key = #27 Then Begin
    Button1.Click;
  End;
End;

Procedure TForm5.Edit3KeyPress(Sender: TObject; Var Key: char);
Begin
  RadioButton1.Checked := false;
  RadioButton2.Checked := true;
  If key = #13 Then Begin
    Button2.Click;
  End;
  If key = #27 Then Begin
    Button1.Click;
  End;
End;

Procedure TForm5.FormCreate(Sender: TObject);
Begin
  caption := 'Modify coordinate';
  Tform(self).Constraints.MaxHeight := Tform(self).Height;
  Tform(self).Constraints.MinHeight := Tform(self).Height;
  Tform(self).Constraints.Maxwidth := Tform(self).width;
  Tform(self).Constraints.Minwidth := Tform(self).width;
End;

procedure TForm5.FormShow(Sender: TObject);
begin
  Edit1.SetFocus;
end;

Function TForm5.ModifyCoordinate(GC_Code: String; Sender: TForm): Boolean;
Var
  t, lat, lon, clat, clon: Double;
  c, d: String;
Begin
  result := false;
  StartSQLQuery('Select lat, lon, cor_lat, cor_lon from caches where name = "' + GC_Code + '"');
  If SQLQuery.EOF Then exit;
  lat := SQLQuery.Fields[0].AsFloat;
  lon := SQLQuery.Fields[1].AsFloat;
  clat := SQLQuery.Fields[2].AsFloat;
  clon := SQLQuery.Fields[3].AsFloat;

  c := CoordToString(lat, lon);
  StringCoordToComboboxEdit(c,
    form5.ComboBox2, form5.edit1,
    form5.ComboBox3, form5.edit2
    );
  form5.Label1.Caption := 'Orig: ' + form5.ComboBox2.Text + ' ' + form5.edit1.text;
  form5.Label2.Caption := 'Orig: ' + form5.ComboBox3.Text + ' ' + form5.edit2.text;
  If (clon = -1) Or (clat = -1) Then Begin
    // Es gibt noch keine Modifizierten Koordinaten
    label3.Visible := false;
    label4.Visible := false;
  End
  Else Begin
    d := c;
    // Es gibt Modifizierte Koordinaten
    c := CoordToString(clat, clon);
    If c <> d Then Begin // Nur wenn sich die Koords tatsächlich unterscheiden wird Modifiziert angezeigt, sonst sind sie ja eigentlich gleich.
      label3.Visible := true;
      label4.Visible := true;
    End
    Else Begin
      label3.Visible := false;
      label4.Visible := false;
    End;
    StringCoordToComboboxEdit(c,
      form5.ComboBox2, form5.edit1,
      form5.ComboBox3, form5.edit2
      );
  End;
  form5.edit3.text := form5.ComboBox2.Text + ' ' + form5.Edit1.Text + ' ' + form5.ComboBox3.Text + ' ' + form5.Edit2.Text;
  form5.ModalResult := mrNone;
  form5.caption := 'Modify Coordinate : ' + GC_Code;
  form5.RadioButton1.Checked := true;
  form5.RadioButton2.Checked := false;
  FormShowModal(form5, Sender);
  If form5.ModalResult = mrOK Then Begin
    If Form5.RadioButton1.Checked Then Begin
      form5.Edit3.Text := form5.ComboBox2.Text + form5.Edit1.Text + ' ' + form5.ComboBox3.Text + form5.Edit2.Text;
    End;
    If Not StringToCoord(form5.Edit3.Text, clat, clon) Then Begin
      clat := -1;
      clon := -1;
    End;
    If (clat <> -1) And (clon <> -1) Then Begin
      result := true;
      EncodeKoordinate(t, '00', '00', '001');
      If (abs(lat - clat) < t) And (abs(lon - clon) < t) Then Begin
        // Reset der Koords
        clat := -1;
        clon := -1;
      End;
      CommitSQLTransactionQuery('Update caches set ' +
        'COR_LAT = ' + floattostr(clat, DefFormat) + ' ' +
        ',COR_Lon = ' + floattostr(clon, DefFormat) + ' ' +
        'where name = "' + GC_Code + '";');
      SQLTransaction.Commit;
    End
    Else Begin
      Showmessage(R_Error_invalid_input_nothing_changed);
    End;
  End;
End;

End.

