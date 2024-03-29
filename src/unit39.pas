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
Unit Unit39;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm39 }

  TForm39 = Class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Procedure Button1Click(Sender: TObject);
    Procedure ListBox1DblClick(Sender: TObject);
  private

  public

  End;

Var
  Form39: TForm39;

Implementation

{$R *.lfm}

{ TForm39 }

Procedure TForm39.Button1Click(Sender: TObject);
Begin
  ModalResult := mrOK;
End;

Procedure TForm39.ListBox1DblClick(Sender: TObject);
Begin
  ModalResult := mrOK;
End;

End.

