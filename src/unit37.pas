Unit Unit37;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm37 }

  TForm37 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    Procedure Button3Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private

  public

  End;

Var
  Form37: TForm37;

Implementation

{$R *.lfm}

Uses
  unit15, uccm;

{ TForm37 }

Procedure TForm37.FormCreate(Sender: TObject);
Begin
  Constraints.MinHeight := height;
  Constraints.MinWidth := Width;
  Edit1.text := '';
  Memo1.Text := '';
  Edit2.text := '';
End;

Procedure TForm37.Button3Click(Sender: TObject);
Begin
  allowcnt := 0;
  Form15Initialized := false;
  FormShowModal(form15, self);
End;

End.

