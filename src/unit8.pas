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
Unit Unit8;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm8 }

  TForm8 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Procedure Button1Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  End;

Var
  Form8: TForm8;

Implementation

{$R *.lfm}

Uses ulanguage;

{ TForm8 }

Procedure TForm8.FormCreate(Sender: TObject);
Begin
  caption := 'Import directory';
End;

Procedure TForm8.Button1Click(Sender: TObject);
Begin
  SelectDirectoryDialog1.FileName := edit1.Text;
  If SelectDirectoryDialog1.Execute Then Begin
    Edit1.Text := SelectDirectoryDialog1.FileName;
  End;
End;

End.

