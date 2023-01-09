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
Unit Unit43;

{$MODE ObjFPC}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ugctool;

Type

  { TForm43 }

  TForm43 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Procedure Button1Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure Memo2Change(Sender: TObject);
  private
  public
    ResultNote: String;

    Function ShowDialog(Sender: TForm; aCaption, aLabelLeft, aTextLeft, aLabelRight, aTextRight, aOption_2, aOption_1: String): TUserNoteResult;
  End;

Var
  Form43: TForm43;

Implementation

{$R *.lfm}

Uses ulanguage, uccm, Unit4;

{ TForm43 }

Procedure TForm43.FormCreate(Sender: TObject);
Begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  Panel2.Caption := '';
End;

Procedure TForm43.Memo2Change(Sender: TObject);
Begin
  label3.caption := inttostr(length(memo2.text));
End;

Function TForm43.ShowDialog(Sender: TForm; aCaption, aLabelLeft, aTextLeft,
  aLabelRight, aTextRight, aOption_2, aOption_1: String): TUserNoteResult;
Var
  i: Integer;
Begin
  caption := aCaption;
  label1.caption := aLabelLeft;
  label2.Caption := aLabelRight;
  memo1.text := aTextLeft;
  memo2.Text := aTextRight;
  Memo2Change(Nil);
  Button3.Caption := aOption_2;
  Button1.Caption := aOption_1;
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
  result := unrError;
  Case i Of
    mrOK: result := unrOK;
    mrCancel: result := unrAbort;
    mrAll: result := unrOKAll;
    mrYesToAll: result := unrOKAppendAll;
  End;
End;

Procedure TForm43.Button1Click(Sender: TObject);
Begin
  // Option 1
  ResultNote := Memo2.Text;
  If Not IsUserNoteLenValid(ResultNote) Then Begin
    ShowMessage(R_Error_Length_of_UserNote_is_to_Long);
    exit;
  End;
  If CheckBox1.Checked Then Begin
    modalresult := mrAll;
  End
  Else Begin
    modalresult := mrOK;
  End;
End;

Procedure TForm43.Button3Click(Sender: TObject);
Begin
  // Append Local after Online
  ResultNote := trim(Memo1.Text) + LineEnding + Memo2.Text;
  If Not IsUserNoteLenValid(ResultNote) Then Begin
    ShowMessage(R_Error_Length_of_UserNote_is_to_Long);
    exit;
  End;
  If CheckBox1.Checked Then Begin
    modalresult := mrYesToAll;
  End
  Else Begin
    modalresult := mrOK;
  End;
End;

End.

