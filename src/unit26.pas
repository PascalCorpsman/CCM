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
Unit Unit26;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus;

Type

  { TForm26 }

  TForm26 = Class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    Procedure Button1Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure ListBox1DblClick(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
  private

  public

  End;

Var
  Form26: TForm26;

Implementation

{$R *.lfm}

Uses unit24, math;

{ TForm26 }

Procedure TForm26.Button1Click(Sender: TObject);
Begin
  ListBox1.Items.Clear;
End;

Procedure TForm26.FormCreate(Sender: TObject);
Begin
  caption := 'History';
  panel1.caption := '';
  panel1.align := alBottom;
  ListBox1.Align := alclient;
End;

Procedure TForm26.ListBox1DblClick(Sender: TObject);
Begin
  If listbox1.itemindex <> -1 Then Begin
    form24.SynEdit1.Lines.Text := listbox1.items[listbox1.itemindex];
  End;
End;

Procedure TForm26.MenuItem1Click(Sender: TObject);
Var
  i: Integer;
Begin
  If listbox1.itemindex <> -1 Then Begin
    i := listbox1.itemindex;
    ListBox1.Items.Delete(i);
    i := min(i, ListBox1.Items.Count - 1);
    If i <> -1 Then
      listbox1.itemindex := i;
  End;
End;

End.

