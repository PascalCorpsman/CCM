Unit Unit31;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm31 }

  TForm31 = Class(TForm)
    Button1: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Procedure Button1Click(Sender: TObject);
    Procedure Edit3KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCreate(Sender: TObject);
  private
  public
    ResultLat, ResultLon: Double;
    Procedure InitWithPoint(lat, lon: Double);
  End;

Var
  Form31: TForm31;

Implementation

{$R *.lfm}

Uses uccm, unit15, ulanguage, umathsolver;

{ TForm31 }

Procedure TForm31.FormCreate(Sender: TObject);
Begin
  caption := 'Edit userpoint';
  edit2.text := '';
  edit3.text := '';
End;

Procedure TForm31.Button1Click(Sender: TObject);
Var
  angles, dists: String;
  lat, lon: Double;
Begin
  // Projektion
  If Not StringToCoord(edit1.text, lat, lon) Then Begin
    Showmessage(R_Error_invalid_input_nothing_changed);
    exit;
  End;
  angles := Edit2.Text;
  dists := Edit3.Text;
  // Sicherstellen, das der Decimalseparator '.' ist
  If DefaultFormatSettings.DecimalSeparator <> '.' Then Begin
    angles := StringReplace(angles, DefaultFormatSettings.DecimalSeparator, '.', [rfReplaceAll]);
    dists := StringReplace(dists, DefaultFormatSettings.DecimalSeparator, '.', [rfReplaceAll]);
  End;
  angles := EvalString(angles);
  dists := EvalString(dists);
  ProjectCoord(lat, lon, strtofloatdef(angles, 0, DefFormat), strtofloatdef(dists, 0, DefFormat), ResultLat, ResultLon);
  ModalResult := mrOK;
End;

Procedure TForm31.Edit3KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then Button1.Click;
End;

Procedure TForm31.InitWithPoint(lat, lon: Double);
Begin
  edit1.text := CoordToString(lat, lon);
End;

End.

