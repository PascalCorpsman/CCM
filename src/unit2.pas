Unit Unit2;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm2 }

  TForm2 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Procedure Edit1KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  End;

Var
  Form2: TForm2;

Implementation

{$R *.lfm}

Uses ulanguage;

{ TForm2 }

Procedure TForm2.FormCreate(Sender: TObject);
Begin
  caption := 'Enter name';
End;

Procedure TForm2.Edit1KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then button2.Click;
  If key = #27 Then button1.Click;
End;

End.

