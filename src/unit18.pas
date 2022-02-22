Unit Unit18;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm18 }

  TForm18 = Class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Procedure Button1Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  End;

Var
  Form18: TForm18;

Implementation

{$R *.lfm}

Uses uccm;

{ TForm18 }

Procedure TForm18.FormCreate(Sender: TObject);
Begin
  caption := 'Script editor online help';
  memo1.text := 'Variables' + LineEnding +
    '$database$ = database selected when the script was started.' + LineEnding +
    '$promptdatabase$ = database selected by the prompt database dialog (to use the database select it)' + LineEnding + LineEnding +
    '$importdir$ = last used import directory' + LineEnding +
    '$workdir$ = temporary folder' + LineEnding +
    '$promptdir$ = folder selected by dialog';
End;

Procedure TForm18.Button1Click(Sender: TObject);
Begin
  close;
End;

End.

