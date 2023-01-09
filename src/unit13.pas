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
Unit Unit13;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, IpHtml, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Menus;

Type

  { TForm13 }

  TForm13 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    ImageList1: TImageList;
    ImageList2: TImageList;
    IpHtmlPanel1: TIpHtmlPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    ScrollBox1: TScrollBox;
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure Label5Click(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure MenuItem3Click(Sender: TObject);
  private
    { private declarations }
    Cache: String; // Der GC-Code des gerade geladenen Caches
    Procedure HTMLGetImageX(Sender: TIpHtmlNode; Const URL: String;
      Var Picture: TPicture);
  public
    { public declarations }
    Function OpenCache(GCCode: String): Boolean;
  End;

Var
  Form13: TForm13;

Implementation

{$R *.lfm}

Uses
  usqlite_helper, LazFileUtils, LazUTF8, uccm, unit17, unit1, unit20, unit7, imglist, LCLIntf,
  ugctoolwrapper, ulanguage;

Function DTToIndex(DT: Single): integer;
Begin
  result := round((DT * 2) - 2);
End;

{ TForm13 }

Procedure TForm13.FormCreate(Sender: TObject);
Var
  b: Tbitmap;
Begin
  panel1.caption := '';
  panel2.caption := '';
  IpHtmlPanel1.Align := alClient;
  Memo1.Align := alClient;
  Constraints.MinWidth := width;
  Constraints.MinHeight := Height;
  b := TBitmap.Create;
  b.Canvas.Brush.Color := clBtnFace;
  b.canvas.pen.color := clBtnFace;

  b.Width := ImageList1.Width;
  b.Height := ImageList1.Height;
  b.Canvas.Rectangle(0, 0, b.Width, b.Height);
  Image1.Picture.Assign(b);
  Image1.Width := ImageList1.Width;
  Image1.Height := ImageList1.Height;

  b.Width := ImageList2.Width;
  b.Height := ImageList2.Height;
  b.Canvas.Rectangle(0, 0, b.Width, b.Height);
  Image2.Picture.Assign(b);
  Image2.Width := ImageList2.Width;
  Image2.Height := ImageList2.Height;
  b.free;

  b := TBitmap.Create;
  b.Canvas.Brush.Color := clBtnFace;
  b.canvas.pen.color := clBtnFace;
  b.Width := ImageList2.Width;
  b.Height := ImageList2.Height;
  b.Canvas.Rectangle(0, 0, b.Width, b.Height);
  Image3.Picture.Assign(b);
  Image3.Width := ImageList2.Width;
  Image3.Height := ImageList2.Height;
  b.free;
End;

Procedure TForm13.Label5Click(Sender: TObject);
Var
  orig, s, slat, slon: String;
  lat, lon: Double;
Begin
  s := trim(copy(label5.caption, pos(':', label5.Caption) + 1, length(Label5.Caption)));
  orig := '';
  If pos(R_Orig + ': ', s) <> 0 Then Begin
    orig := copy(s, pos(R_Orig + ': ', s) + 6, length(s));
    s := copy(s, 1, pos(R_Orig + ': ', s) - 1);
  End;
  If StringToCoord(s, lat, lon) Then Begin
    label5.caption := r_coordinate + ': ' + format('%0.6f %0.6f', [lat, lon]);
    If orig <> '' Then Begin
      StringToCoord(orig, lat, lon);
      label5.caption := Label5.Caption + '   ' + R_Orig + ': ' + format('%0.6f %0.6f', [lat, lon]);
    End;
  End
  Else Begin
    slat := copy(s, 1, pos(' ', s) - 1);
    slon := copy(s, pos(' ', s) + 1, length(s));
    label5.caption := r_coordinate + ': ' + CoordToString(strtofloat(slat), strtofloat(slon));
    If orig <> '' Then Begin
      slat := copy(orig, 1, pos(' ', orig) - 1);
      slon := copy(orig, pos(' ', orig) + 1, length(orig));
      label5.caption := Label5.Caption + '   ' + R_Orig + ': ' + CoordToString(strtofloat(slat), strtofloat(slon));
    End;
  End;
End;

Procedure TForm13.MenuItem1Click(Sender: TObject);
Var
  s, t: String;
Begin
  If cache = '' Then exit;
  StartSQLQuery('Select c.G_NAME from caches c where c.name = "' + cache + '"');
  If SQLQuery.EOF Then exit;
  s := trim(FromSQLString(SQLQuery.Fields[0].AsString));
  t := trim(InputBox(R_enter_new_title, '', s));
  If (t <> '') And (t <> s) Then Begin
    CommitSQLTransactionQuery('Update caches set g_name = "' + ToSQLString(t) + '" where name = "' + cache + '"');
    SQLTransaction.Commit;
    OpenCache(cache);
  End;
End;

Procedure TForm13.MenuItem3Click(Sender: TObject);
Begin
  // Edit Listing text
  If cache = '' Then exit;
  StartSQLQuery('Select c.G_LONG_DESCRIPTION, c.G_NAME from caches c where c.name = "' + cache + '"');
  If SQLQuery.EOF Then exit;
  form7.Memo1.Text := FromSQLString(SQLQuery.Fields[0].AsString);
  form7.ModalResult := mrNone;
  form7.SetCaption(format(RF_Edit_listing, [FromSQLString(SQLQuery.Fields[1].AsString)]));
  FormShowModal(form7, self);
  If Form7.ModalResult = mrOK Then Begin
    CommitSQLTransactionQuery('Update caches set G_LONG_DESCRIPTION = "' + ToSQLString(form7.Memo1.Text) + '" where name = "' + cache + '"');
    SQLTransaction.Commit;
    OpenCache(cache);
  End;
End;

Procedure TForm13.Button2Click(Sender: TObject);
Begin
  // Show Logs
  Form20.LoadLogsFromCache(Cache);
  FormShowModal(form20, Self);
End;

Procedure TForm13.Button3Click(Sender: TObject);
Begin
  // Show Waypoints
  form17.LoadCache(Cache);
  FormShowModal(form17, Self);
End;

Procedure TForm13.Button4Click(Sender: TObject);
Begin
  // Edit Note
  EditCacheNote(self, cache);
End;

Procedure TForm13.Button5Click(Sender: TObject);
Begin
  // Add Spoiler Image
  form1.AddSpoilerImageToCache(Cache);
End;

Procedure TForm13.Button6Click(Sender: TObject);
Begin
  // Open in Browser
  OpenCacheInBrowser(cache);
End;

(* Das hier ist fast identisch zu Form42.HTMLGetImageX *)

Procedure TForm13.HTMLGetImageX(Sender: TIpHtmlNode; Const URL: String;
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
  f := GetDownloadsDir() + Cache + PathDelim + 'desc' + PathDelim + s;
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

Function TForm13.OpenCache(GCCode: String): Boolean;
Var
  s: String;
  NewHTML: TSimpleIpHtml;
  l, i: integer;
  b: TBitmap;
  img: TImage;
  C: TCache;
  d: TDateTime;
  failure: boolean;
Begin
  result := false;
  Cache := GCCode;
  c := CacheFromDB(GCCode, false);
  If c.GC_Code = '' Then Begin
    // Attribut Liste Leeren
    For i := ScrollBox1.ComponentCount - 1 Downto 0 Do Begin
      ScrollBox1.Components[i].free;
    End;
    Image1.Picture.bitmap.Canvas.Rectangle(-1, -1, Image1.Width + 1, Image1.Height + 1);
    Image2.Picture.bitmap.Canvas.Rectangle(-1, -1, Image2.Width + 1, Image2.Height + 1);
    Image3.Picture.bitmap.Canvas.Rectangle(-1, -1, Image3.Width + 1, Image3.Height + 1);
    label1.caption := '';
    label2.caption := '';
    label3.caption := '';
    label4.caption := '';
    label5.caption := '';
    memo1.Text := R_Cache_not_in_database_use_the_open_cache_in_browser_feature;
    memo1.visible := true;
    IpHtmlPanel1.visible := false;
    caption := format(RF_Details_of, [GCCode, GCCode]);
    exit; // Wir ham den Cache nicht in der Datenbank, kann beim Editieren von Field-Notes oder nachgeladenen Caches vorkommen.
  End;
  result := true;
  caption := format(RF_Details_of, [GCCode, c.G_Name]);
  If (C.Cor_Lat <> -1) And (C.Cor_Lon <> -1) Then Begin
    label5.caption := r_coordinate + ': ' + CoordToString(C.Cor_Lat, C.Cor_Lon) + '   ' + R_Orig + ': ' + CoordToString(c.Lat, C.Lon);
  End
  Else Begin
    label5.caption := r_coordinate + ': ' + CoordToString(c.Lat, C.Lon);
  End;

  If (Not c.G_Long_Description_HTML) Or (GetValue('General', 'NeverUseHTMLRenderer', '0') = '1') Then Begin
    // Anzeige als Normaler Text
    Memo1.text := FromSQLString(C.G_Long_Description);
    memo1.visible := true;
    IpHtmlPanel1.visible := false;
  End
  Else Begin
    // Anzeige Long Description, via HTML viewer Komponente
    s := (FromSQLString(C.G_Long_Description));
    s := UTF8BOM + s; // Als UTF8 String Markieren
    NewHTML := TSimpleIpHtml.Create;
    failure := Not NewHTML.LoadContentFromString(s, @HTMLGetImageX);
    If failure Then Begin
      memo1.Text := R_Error_could_not_load_listing;
      NewHTML.free;
      memo1.visible := true;
      IpHtmlPanel1.visible := false;
    End
    Else Begin
      IpHtmlPanel1.SetHtml(NewHTML); // NewHTML braucht nicht freigegeben werde, das macht IpHtmlPanel1
      memo1.visible := false;
      IpHtmlPanel1.visible := true;
    End;
  End;
  // Die Titelzeile zusammenbasteln
  // Todo: Das muss noch Sprachabhängig gehen...
  label1.caption := 'Type: ' + c.G_Type + ' | Size: ';
  Image1.Left := label1.Left + Label1.canvas.TextWidth(label1.caption) + 5;
  ImageList1.Draw(Image1.Picture.bitmap.Canvas, 0, 0, CacheSizeToIndex(c.G_Container));
  label2.caption := ' | Difficulty: ';
  label2.left := Image1.Left + image1.Width + 5;
  Image2.Left := label2.Left + Label2.canvas.TextWidth(label2.caption) + 5;
  ImageList2.Draw(Image2.Picture.bitmap.Canvas, 0, 0, DTToIndex(c.G_Difficulty));
  label3.caption := ' | Terrain: ';
  label3.left := Image2.Left + image2.Width + 5;
  Image3.Left := label3.Left + Label3.canvas.TextWidth(label3.caption) + 5;
  ImageList2.Draw(Image3.Picture.bitmap.Canvas, 0, 0, DTToIndex(c.G_Terrain));
  d := StrToTime(c.Time);
  If d <> -1 Then Begin
    label4.caption := ' | By: ' + c.G_Owner + ' | On: ' + FormatDateTime('DDDDDD', d);
  End
  Else Begin
    label4.caption := ' | By: ' + c.G_Owner + ' | On: ' + c.Time;
  End;
  label4.left := Image3.Left + image3.Width + 5;

  // Attribut Liste Erstellen
  For i := ScrollBox1.ComponentCount - 1 Downto 0 Do Begin
    ScrollBox1.Components[i].free;
  End;
  l := 0;
  For i := 0 To high(c.G_Attributes) Do Begin
    b := GetAttribImage(c.G_Attributes[i].id, c.G_Attributes[i].inc = 1);
    img := TImage.Create(ScrollBox1);
    img.Parent := ScrollBox1;
    img.Picture.Assign(b);
    img.Width := b.Width;
    img.Height := b.Height;
    img.Hint := c.G_Attributes[i].Attribute_Text;
    img.ShowHint := true;
    img.Transparent := true;
    b.free;
    img.Left := l;
    img.Top := 0;
    l := l + img.Width + 5;
  End;
End;

End.

