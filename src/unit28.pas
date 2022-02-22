Unit Unit28;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm28 }

  TForm28 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Procedure FormCreate(Sender: TObject);
  private

  public

  End;

Var
  Form28: TForm28;

Implementation

{$R *.lfm}

{ TForm28 }

Procedure TForm28.FormCreate(Sender: TObject);
Begin
  caption := 'Warning';
End;

End.

