(******************************************************************************)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* This file is part of CCM                                                   *)
(*                                                                            *)
(*  See the file license.md, located under:                                   *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(******************************************************************************)
Unit Unit42;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, IpHtml;

Type

  { TForm42 }

  TForm42 = Class(TForm)
    Button1: TButton;
    IpHtmlPanel1: TIpHtmlPanel;
    IpHtmlPanel2: TIpHtmlPanel;
    IpHtmlPanel3: TIpHtmlPanel;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Procedure FormCreate(Sender: TObject);
  private
    Trackable: String;

    Procedure HTMLGetImageX(Sender: TIpHtmlNode; Const URL: String;
      Var Picture: TPicture);

  public
    Procedure LoadTBFromQuery();

  End;

Var
  Form42: TForm42;

Implementation

{$R *.lfm}

Uses usqlite_helper, uccm, ulanguage, LazFileUtils, ugctoolwrapper;

{ TForm42 }

(* Das hier ist fast identisch zu Form13.HTMLGetImageX *)

Procedure TForm42.FormCreate(Sender: TObject);
Begin
  caption := 'TB-Detail view';
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
End;

Procedure TForm42.HTMLGetImageX(Sender: TIpHtmlNode; Const URL: String;
  Var Picture: TPicture);
Var
  f, p, s: String;
  PicCreated: boolean;
  jp: TJPEGImage;
  png: TPortableNetworkGraphic;
  bmp: TBitmap;
Begin
  // Wenn eine Internetverbindung besteht, die Bilder nachladen ??
  s := ExcludeTrailingPathDelimiter(Url);
  s := ExtractFileName(s);
  s := FilterForValidFilenameChars(s);
  If s = '' Then Begin // Wir kriegen keinen Vernünftigen Dateienamen hin -> Raus
    Picture := Nil;
    exit;
  End;
  f := GetDownloadsDir() + Trackable + PathDelim + 'desc' + PathDelim + s;
  p := ExtractFilePath(f);
  If Not DirectoryExistsUTF8(p) Then Begin
    If Not ForceDirectoriesUTF8(p) Then Begin
      Picture := Nil;
      exit;
    End;
  End;
  // Das Image gibts noch nicht also laden
  If Not FileExistsUTF8(f) Then Begin
    GCTDownloadFile(url, f, true);
  End;
  // Hat das downloaden geklappt, dann kann das Bild geladen werden
  If FileExistsUTF8(f) Then Begin
    Try
      PicCreated := False;
      If Picture = Nil Then Begin
        Picture := TPicture.Create;
        PicCreated := True;
      End;
      Case GetFileTypeByFirstBytes(f) Of
        // Das Dateiformat ist uns noch nicht Bekannt, also versuchen wir es mal so :)
        ftUnknown: Begin
            Picture.LoadFromFile(f);
          End;
        ftJPG: Begin
            jp := TJPEGImage.Create;
            jp.LoadFromFile(f);
            Picture.Assign(jp);
            jp.free;
          End;
        ftPNG: Begin
            png := TPortableNetworkGraphic.Create;
            png.LoadFromFile(f);
            Picture.Assign(png);
            png.free;
          End;
        ftBMP: Begin
            bmp := TBitmap.Create;
            bmp.LoadFromFile(f);
            Picture.Assign(bmp);
            bmp.free;
          End;
      End;
    Except
      If PicCreated Then
        Picture.Free;
      Picture := Nil;
    End;
  End
  Else Begin
    picture := Nil;
  End;
End;

Procedure TForm42.LoadTBFromQuery();
Var
  NewHTML: TSimpleIpHtml;
  s: String;
Begin
  If TB_SQLQuery.EOF Then Begin
    // Kein TB gefunden, das ist noch nicht erschöpfend kommt aber aktuell auch nicht vor...
    IpHtmlPanel1.Visible := false;
    IpHtmlPanel2.Visible := false;
    IpHtmlPanel3.Visible := false;
    label16.caption := '-';
  End
  Else Begin
    Trackable := FromSQLString(TB_SQLQuery.FieldByName('TB_Code').AsString);
    IpHtmlPanel1.Visible := true;
    IpHtmlPanel2.Visible := true;
    IpHtmlPanel3.Visible := true;
    NewHTML := TSimpleIpHtml.create;
    s := FromSQLString(TB_SQLQuery.FieldByName('About_this_item').AsString);
    s := UTF8BOM + s;
    NewHTML.LoadContentFromString(s, @HTMLGetImageX);
    IpHtmlPanel1.SetHtml(NewHTML); // NewHTML braucht nicht freigegeben werde, das macht IpHtmlPanel1

    NewHTML := TSimpleIpHtml.create;
    s := FromSQLString(TB_SQLQuery.FieldByName('Current_Goal').AsString);
    s := UTF8BOM + s;
    NewHTML.LoadContentFromString(s, @HTMLGetImageX);
    IpHtmlPanel2.SetHtml(NewHTML); // NewHTML braucht nicht freigegeben werde, das macht IpHtmlPanel1

    NewHTML := TSimpleIpHtml.create;
    s := FromSQLString(TB_SQLQuery.FieldByName('Comment').AsString);
    If s = '' Then Begin
      s := '<p>' + format(RF_Error_no_logtext_for, [Trackable]) + '</p>';
    End;
    If pos('<p>', trim(s)) <> 1 Then Begin // Allte Commits haben keine HTML-Kennung, durch diesen "Hack" werden sie zumindest lesbar.
      s := '<p>' + trim(s) + '</p>';
    End;
    s := UTF8BOM + s;
    NewHTML.LoadContentFromString(s, @HTMLGetImageX);
    IpHtmlPanel3.SetHtml(NewHTML); // NewHTML braucht nicht freigegeben werde, das macht IpHtmlPanel1

    Label5.Caption := FromSQLString(TB_SQLQuery.FieldByName('Owner').AsString);
    Label7.Caption := FromSQLString(TB_SQLQuery.FieldByName('ReleasedDate').AsString);
    Label9.Caption := FromSQLString(TB_SQLQuery.FieldByName('Origin').AsString);
    Label11.Caption := FromSQLString(TB_SQLQuery.FieldByName('Logdate').AsString);

    Label14.Caption := FromSQLString(TB_SQLQuery.FieldByName('TB_Code').AsString);
    Label15.Caption := FromSQLString(TB_SQLQuery.FieldByName('Discover_Code').AsString);
    Label16.Caption := FromSQLString(TB_SQLQuery.FieldByName('Heading').AsString);
  End;
End;

End.

