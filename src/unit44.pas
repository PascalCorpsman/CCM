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
Unit Unit44;

{$MODE ObjFPC}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ugctool;

Type

  { TForm44 }

  TForm44 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private

  public
    ResultLon, ResultLat: Double;
    Function ShowDialog(Sender: TForm; aCaption, aLabelLeft: String; alatLeft, alonLeft: Double; aLabelRight: String; alatRight, alonRight: Double; aOption_2, aOption_1: String): TUserCoordResult;

  End;

Var
  Form44: TForm44;

Implementation

{$R *.lfm}

Uses ulanguage, uccm, Unit4;

{ TForm44 }

Procedure TForm44.FormCreate(Sender: TObject);
Begin
  Constraints.MinWidth := Width;
  Constraints.MaxWidth := Width;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;
End;

Procedure TForm44.Button3Click(Sender: TObject);

Begin
  // Option 1
  If Not StringToCoord(Edit2.Text, ResultLat, ResultLon) Then Begin
    ShowMessage(R_Error_invalid_input_nothing_changed);
    exit;
  End;
  If CheckBox1.Checked Then Begin
    modalresult := mrAll;
  End
  Else Begin
    modalresult := mrOK;
  End;
End;

Procedure TForm44.Button2Click(Sender: TObject);
Begin
  // Option 2
  If Not StringToCoord(Edit1.Text, ResultLat, ResultLon) Then Begin
    ShowMessage(R_Error_invalid_input_nothing_changed);
    exit;
  End;
  If CheckBox1.Checked Then Begin
    modalresult := mrYesToAll;
  End
  Else Begin
    modalresult := mrOK;
  End;
End;

Function TForm44.ShowDialog(Sender: TForm; aCaption, aLabelLeft: String;
  alatLeft, alonLeft: Double; aLabelRight: String; alatRight,
  alonRight: Double; aOption_2, aOption_1: String): TUserCoordResult;
Var
  i: Integer;
Begin
  caption := aCaption;
  label1.caption := aLabelLeft;
  label2.Caption := aLabelRight;
  edit1.text := CoordToString(alatleft, alonleft);
  edit2.Text := CoordToString(alatRight, alonRight);
  Button2.Caption := aOption_2;
  Button3.Caption := aOption_1;
  form4.Hide; // Den Fortschrittsdialog ausschalten, er wird automatisch wieder eingeblendet
  FormShowModal(self, sender);
  (*
   * ModalResult:
   *   mrCancel: Abbruch
   *   mrOK: Bestätigt, Option1 => Text Rechts, Option2 => Text Links + Text Rechts
   *   mrAll: Bestägigt, Text Rechts für alle Übernehmen
   *   mrYesToAll: Bestätigt, Text Links + Text Rechts für alle Übernehmen
   *)
  i := ModalResult;
  result := ucrError;
  Case i Of
    mrOK: result := ucrOK;
    mrCancel: result := ucrAbort;
    mrAll: result := ucrOKAll;
    mrYesToAll: result := ucrOKAllOther;
  End;
End;

End.

