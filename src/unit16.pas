Unit Unit16;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm16 }

  TForm16 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    Procedure FormCreate(Sender: TObject);
    Procedure ListBox1DblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Function Filename: String;
  End;

Var
  Form16: TForm16;

Implementation

Uses lazutf8, LazFileUtils, uccm;

{$R *.lfm}

{ TForm16 }

Procedure TForm16.FormCreate(Sender: TObject);
Begin
  caption := 'Load database';
  Tform(self).Constraints.MaxHeight := Tform(self).Height;
  Tform(self).Constraints.MinHeight := Tform(self).Height;
  Tform(self).Constraints.Maxwidth := Tform(self).width;
  Tform(self).Constraints.Minwidth := Tform(self).width;
End;

Procedure TForm16.ListBox1DblClick(Sender: TObject);
Begin
  modalresult := mrOK;
End;

Function TForm16.Filename: String;
Var
  p: String;
Begin
  result := '';
  If ListBox1.ItemIndex <> -1 Then Begin
    p := GetDataBaseDir();
    result := p + RemoveCacheCountInfo(ListBox1.Items[ListBox1.ItemIndex]) + '.db';
  End;
End;

End.

