Unit Unit7;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm7 }

  TForm7 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    Procedure Button3Click(Sender: TObject);
    Procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
    defcaption: String;
  public
    { public declarations }
    Procedure SetCaption(NewCaption: String);
  End;

Var
  Form7: TForm7;

Implementation

{$R *.lfm}

{ TForm7 }

Procedure TForm7.Button3Click(Sender: TObject);
Begin
  memo1.clear;
  caption := defcaption;
End;

Procedure TForm7.Memo1Change(Sender: TObject);
Begin
  If length(trim(Memo1.Lines.Text)) <> 0 Then Begin
    caption := defcaption + ' [' + inttostr(length(trim(Memo1.Lines.Text))) + ']';
  End
  Else Begin
    caption := defcaption;
  End;
End;

Procedure TForm7.SetCaption(NewCaption: String);
Begin
  defcaption := NewCaption;
  Memo1Change(Nil);
End;

End.

