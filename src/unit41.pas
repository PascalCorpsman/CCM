Unit Unit41;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

Type

  { TForm41 }

  TForm41 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Procedure Button2Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure Label3Click(Sender: TObject);
  private

  public
    Procedure ShowVersionInformations();

  End;

Var
  Form41: TForm41;

Implementation

{$R *.lfm}

Uses unit3, uccm, LCLIntf, zbase, ssl_openssl_lib, LCLVersion;

{ TForm41 }

Procedure TForm41.FormCreate(Sender: TObject);
Begin
  Constraints.MinWidth := Width;
  Constraints.MaxWidth := Width;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;

  label7.caption :=
    'This program is postcardware for non commercial use only,' + LineEnding +
    'if you use it, send me a postcard.' + LineEnding + LineEnding +
    'Uwe Schächterle' + LineEnding +
    'Buhlstraße 85' + LineEnding +
    '71384 Weinstadt Beutelsbach' + LineEnding +
    'Germany' + LineEnding + LineEnding +
    'There is no warranty, usage on your own risk.';
End;

Procedure TForm41.FormShow(Sender: TObject);
Begin
  label8.top := label7.top + label7.Height - label8.Height;
End;

Procedure TForm41.Label3Click(Sender: TObject);
Begin
  // Visit Website
  OpenURL('https://www.corpsman.de/index.php?doc=projekte/ccm');
End;

Procedure TForm41.ShowVersionInformations();
Var
  SSL_Version, SQL_Version: String;
Begin
  if SQLite3Connection.Connected then begin
  StartSQLQuery('select sqlite_version();');
  SQLQuery.First; // Reset des Record Zeigers zum Iterativen Auslesen
  If Not SQLQuery.EOF Then Begin
    SQL_Version := SQLQuery.Fields[0].AsString;
  End
  Else Begin
    SQL_Version := 'Unknown';
  End;
  end else begin
    SQL_Version := 'Not loaded yet.';
  end;
  SSL_Version := SSLeayversion(0);

  label4.caption :=
    'Corpsman Cache Manager ver. ' + Version + ', ' + inttostr(sizeof(Pointer) * 8) + ' Bit, ' + {$I %DATE%} + ' ' + {$I %TIME%} + LineEnding + LineEnding +
  SSL_Version + LineEnding +
    'SQLite ' + SQL_Version + LineEnding +
    'ZLib ' + zlibVersion() + LineEnding + LineEnding +
    'Used Lazarus IDE ' + lcl_version + LineEnding +
    'Compiled with FPC ' + {$I %FPCVERSION%};
End;

Procedure TForm41.Button2Click(Sender: TObject);
Begin
  button2.Enabled := false;
  form3.CheckForNewVersion;
End;

End.

