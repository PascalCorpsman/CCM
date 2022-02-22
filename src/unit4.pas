Unit Unit4;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uccm;

Type

  { TForm4 }

  TForm4 = Class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Procedure Button1Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    FAbbrechen: Boolean;
  public
    { public declarations }
    (*
     * Restart = True => Abbrechen wird zu false
     * Result = True => Benutzer hat Abbrechen gedrückt
     *)
    Property Abbrechen: Boolean read FAbbrechen;

    (*
     * Wenn Result = true  => User hat abbrechen gedrückt
     *             = false => ganz normal weiter
     *)
    Function RefresStatsMethod(Filename: String; Count, Waypoints: integer; Restart: Boolean): Boolean;
  End;

Var
  Form4: TForm4;

Implementation

{$R *.lfm}

Uses ulanguage;

{ TForm4 }

Procedure TForm4.FormCreate(Sender: TObject);
Begin
  uccm.RefresStatsMethod := @RefresStatsMethod;
  caption := 'Information';
  Tform(self).Constraints.MaxHeight := Tform(self).Height;
  Tform(self).Constraints.MinHeight := Tform(self).Height;
  Tform(self).Constraints.Maxwidth := Tform(self).width;
  Tform(self).Constraints.Minwidth := Tform(self).width;
End;

Procedure TForm4.Button1Click(Sender: TObject);
Begin
  FAbbrechen := true;
End;

Function TForm4.RefresStatsMethod(Filename: String; Count, Waypoints: integer;
  Restart: Boolean): Boolean;
Begin
  If Restart Then Begin
    FAbbrechen := false;
  End;
  If (Not form4.Visible) Or Restart Then Begin
    (*
     * Am Coolsten wäre natürlich wenn dieser Fortschrittsbalken Modal wäre
     * das geht aber nicht, denn dann würde das Programm ja stehenbleiben
     * So muss also derjenige der das RefresStatsMethod aufruft sich selbst auf
     * enabled = false stellen und danach wieder frei schalten
     *)
    Application.BringToFront;
    Form4.Show;
    Form4.BringToFront;
    Form4.SetFocus;
  End;
  label2.caption := ExtractFileName(Filename);
  label4.caption := inttostr(count);
  label6.caption := inttostr(Waypoints);
  Application.ProcessMessages;
  result := FAbbrechen;
End;

End.

