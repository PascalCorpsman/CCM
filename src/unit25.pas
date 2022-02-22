Unit Unit25;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm25 }

  TForm25 = Class(TForm)
    Memo1: TMemo;
    Procedure FormCreate(Sender: TObject);
  private

  public

  End;

Var
  Form25: TForm25;

Implementation

{$R *.lfm}

{ TForm25 }

Procedure TForm25.FormCreate(Sender: TObject);
Begin
  Memo1.Align := alClient;
  caption := 'Result';
End;

End.

