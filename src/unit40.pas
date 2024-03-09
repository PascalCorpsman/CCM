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
Unit Unit40;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, uonlineviewer,
  ugctoolwrapper, uccm, umapviewer, uvectormath;

Const
  RouteFileVersion: uint32 = 2;

Type

  { TForm40 }

  TForm40 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    CheckBox1: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OpenDialog1: TOpenDialog;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    SaveDialog1: TSaveDialog;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure CheckBox10Click(Sender: TObject);
    Procedure CheckBox11Click(Sender: TObject);
    Procedure CheckBox1Click(Sender: TObject);
    Procedure CheckBox2Click(Sender: TObject);
    Procedure CheckBox3Click(Sender: TObject);
    Procedure CheckBox4Click(Sender: TObject);
    Procedure CheckBox5Click(Sender: TObject);
    Procedure CheckBox6Click(Sender: TObject);
    Procedure CheckBox7Click(Sender: TObject);
    Procedure CheckBox8Click(Sender: TObject);
    Procedure CheckBox9Click(Sender: TObject);
    Procedure FormCloseQuery(Sender: TObject; Var CanClose: boolean);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure Label1Click(Sender: TObject);
  private
    fOnlineViewer: TOnlineViewer;
    renderedCached: Integer;
    fRoute: Array Of TVector2;
    Procedure MergeLiteCachesToDB(Const Caches: TLiteCacheArray);
    Procedure MergeLabsCachesToDB(Const Labs: TLABCacheInfoArray);
    Procedure OnWaitEvent(Sender: TObject; Delay: Int64);
  public
    Function GetSplashHint(x, y: integer): String;
    Function GetLabAt(x, y: integer): TLABCacheInfo;
    Procedure ChangeIconTo(CacheHint: String; OpenGLIndex: integer);
    Procedure ResetIcon(CacheHint: String);
    Procedure ResetAllIcons();

    Function InitFormular(): boolean;
    Function GetCachedCacheCount(): TPoint;
    Procedure RenderViewPort(vp: TViewport);

    Procedure AddRoutePoint(x, y: integer);
    Procedure DelRoutePoint(x, y: integer);
    Procedure IncPointOrder(x, y: integer);
    Procedure DecPointOrder(x, y: integer);

    Procedure RenderRoutePoints(vp: TViewport);
    Function GetAllCachedCaches(): TLiteCacheArray;
    Function GetAllCachesAround(vp: TViewport): TLiteCacheArray;
    Procedure ClearCaches();
  End;

Var
  Form40: TForm40;

Implementation

{$R *.lfm}

Uses
  ulanguage,
  uOpenGL_ASCII_Font,
  dglOpenGL,
  uopengl_graphikengine,
  LCLType,
  unit1,
  Unit4,
  unit15;

Function LiteCacheToCache(Const LiteCache: TLiteCache): TCache;
Begin
  result.Lat := LiteCache.Lat;
  result.Lon := LiteCache.Lon;
  result.Cor_Lat := LiteCache.Cor_Lat;
  result.Cor_Lon := LiteCache.Cor_Lon;
  result.Time := LiteCache.Time;
  result.GC_Code := LiteCache.GC_Code;
  result.Desc := LiteCache.g_name + ' by ' + LiteCache.g_owner + ', ' + LiteCache.G_Type + ' (' + floattostr(LiteCache.G_Difficulty, DefFormat) + '/' + floattostr(LiteCache.G_Terrain, DefFormat) + ')';
  result.URL := 'https://coord.info/' + uppercase(LiteCache.GC_Code);
  result.URL_Name := LiteCache.G_Name;
  result.Sym := 'Geocache'; // Das Symbol welches auf der onlinekarte zum Anzeigen genutzt wird
  result.Type_ := LiteCache.G_Type;
  result.Note := '';
  result.Customer_Flag := 0;
  result.Lite := true;
  result.Fav := LiteCache.Fav;

  result.G_ID := LiteCache.G_ID;
  result.G_Available := LiteCache.G_Available;
  result.G_Archived := LiteCache.G_Archived;

  result.G_Found := LiteCache.G_Found;
  result.G_XMLNs := '';
  result.G_Name := LiteCache.G_Name;
  result.G_Placed_By := '';
  result.G_Owner_ID := 0;
  result.G_Owner := LiteCache.G_Owner;
  result.G_Type := LiteCache.G_Type;
  result.G_Container := LiteCache.G_Container;
  result.G_Attributes := Nil;
  result.G_Difficulty := LiteCache.G_Difficulty;
  result.G_Terrain := LiteCache.G_Terrain;
  result.G_Country := '';
  result.G_State := '';
  result.G_Short_Description := 'This is a lite cache, it has no listing.';
  result.G_Short_Description_HTML := false;
  result.G_Long_Description := 'This is a lite cache, it has no listing.';
  result.G_Long_Description_HTML := false;
  result.G_Encoded_Hints := '';
  If StrToTime(LiteCache.LastFound) <> -1 Then Begin
    setlength(result.Logs, 1);
    result.Logs[0].id := 0;
    result.Logs[0].date := LiteCache.LastFound;
    result.Logs[0].Type_ := 'Found it';
    result.Logs[0].Finder_ID := 0;
    result.Logs[0].Finder := 'Unknown';
    result.Logs[0].Text_Encoded := false;
    result.Logs[0].Log_Text := 'Last found date imported from a lite cache.';
  End
  Else Begin
    result.Logs := Nil;
  End;
End;

{ TForm40 }

Procedure TForm40.Button1Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm40.Button2Click(Sender: TObject);
Var
  c: TLiteCacheArray;
Begin
  // Merge All Cached Caches to DB
  c := fOnlineViewer.GetAllCachedCaches();
  MergeLiteCachesToDB(c);
  setlength(c, 0);
End;

Procedure TForm40.Button3Click(Sender: TObject);
Var
  c: TLiteCacheArray;
  vp: TViewport;
  pt: TVector2;
Begin
  // Merge All visual Caches To DB
  pt := form15.mv.GetMouseMapLongLat(0, 0);
  vp.Lon_min := pt.x;
  vp.Lat_min := pt.Y;
  pt := form15.mv.GetMouseMapLongLat(form15.OpenGLControl1.ClientWidth, form15.OpenGLControl1.ClientHeight);
  vp.Lon_max := pt.x;
  vp.Lat_max := pt.Y;
  c := fOnlineViewer.GetAllVisibleCaches(vp);
  MergeLiteCachesToDB(c);
  setlength(c, 0);
End;

Procedure TForm40.Button4Click(Sender: TObject);
Var
  i: integer;
  step, lat, lon: DOuble;
  p, dn, d, ap, np: TVector2;
  zoom, startZoom: integer;
  StartPos: TVector2;
  t: int64;
  s: String;
Begin
  // Start Recording
  If high(fRoute) < 1 Then Begin
    showmessage(r_to_les_waypoints);
    exit;
  End;
  zoom := strtointdef(edit1.text, 14);
  If zoom < 13 Then Begin
    If id_no = Application.MessageBox(pchar(format(RF_Activating_Download_in_Zoom_lt_could_cause_havy_download_times, [13])), pchar(R_Warning), MB_ICONQUESTION Or MB_YESNO) Then Begin
      exit;
    End;
  End;
  t := GetTickCount64;
  startZoom := form15.mv.Zoom;
  StartPos := form15.mv.GetMouseMapLongLat(form15.OpenGLControl1.ClientWidth Div 2, form15.OpenGLControl1.ClientHeight Div 2);
  CheckBox3.Checked := false;
  i := 0;
  s := format('%.7d', [GridStep * 500]); // halbe Gridstep * 1000
  EncodeKoordinate(step, copy(s, 1, 2), copy(s, 3, 2), copy(s, 5, 3)); // Halbe Schrittweite, mit derer uonlineviewer die Vieports Puffert.
  While i < high(fRoute) Do Begin
    ap := v2(fRoute[i].X, fRoute[i].y);
    np := v2(fRoute[i + 1].X, fRoute[i + 1].y);
    d := np - ap;
    dn := NormV2(d) * step;
    p := ap;
    While LenV2(ap - p) < lenv2(d) Do Begin
      form15.mv.Zoom := zoom;
      lat := p.x;
      lon := p.y;
      form15.mv.CenterLongLat(lat, lon);
      CheckBox3.Checked := true;
      form15.OpenGLControl1MouseMove(Nil, [ssLeft], Form15.OpenGLControl1.Width Div 2, form15.OpenGLControl1.Height Div 2);
      p := p + dn;
    End;
    inc(i);
  End;
  // Ganz zum Schluß den Letzten Punkt noch mal anfahren
  lat := fRoute[high(froute)].X;
  lon := fRoute[high(froute)].y;
  form15.mv.CenterLongLat(lat, lon);
  form15.OpenGLControl1Paint(Nil);
  // Wir Sind Fertig, springen nun wieder die Ursprungsansicht an
  CheckBox3.Checked := false;
  form15.mv.Zoom := startZoom;
  form15.mv.CenterLongLat(StartPos.X, StartPos.y);
  form15.OpenGLControl1Paint(Nil);
  t := GetTickCount64 - t;
  Showmessage(format(RF_Script_finished_in, [PrettyTime(t)], DefFormat));
End;

Procedure TForm40.Button5Click(Sender: TObject);
Var
  f: TFileStream;
  i: integer;
  p: TVector2;
  d: Double;
  b: Boolean;
Begin
  // Export Route
  If high(fRoute) = -1 Then Begin
    ShowMessage(R_Noting_Selected);
    exit;
  End;
  If SaveDialog1.Execute Then Begin
    f := TFileStream.Create(SaveDialog1.FileName, fmCreate Or fmOpenWrite);
    f.write(RouteFileVersion, sizeof(RouteFileVersion));
    // Viewport Einstellungen
    i := form15.mv.Zoom;
    f.Write(i, SizeOf(i));
    p := form15.mv.GetMouseMapLongLat(form15.OpenGLControl1.ClientWidth Div 2, form15.OpenGLControl1.ClientHeight Div 2);
    d := p.x;
    f.Write(d, SizeOf(d));
    d := p.y;
    f.Write(d, SizeOf(d));
    // Die Fenster Dimension
    i := form15.Width;
    f.Write(i, SizeOf(i));
    i := form15.Height;
    f.Write(i, SizeOf(i));
    // Die Suchparameter
    b := CheckBox1.Checked; // Hide Own
    f.Write(b, SizeOf(b));
    b := CheckBox2.Checked; // Hide founds
    f.Write(b, SizeOf(b));
    b := CheckBox4.Checked; // All
    f.Write(b, SizeOf(b));
    b := CheckBox8.Checked; // exclude
    f.Write(b, SizeOf(b));
    b := CheckBox5.Checked; // Tradi
    f.Write(b, SizeOf(b));
    b := CheckBox6.Checked; // Multi
    f.Write(b, SizeOf(b));
    b := CheckBox7.Checked; // Mystery
    f.Write(b, SizeOf(b));
    b := CheckBox9.Checked; // Events
    f.Write(b, SizeOf(b));
    i := strtointdef(edit1.text, 14);
    f.Write(i, SizeOf(i));
    // Alle Punkte
    i := length(fRoute);
    f.Write(i, SizeOf(i));
    For i := 0 To high(fRoute) Do Begin
      d := fRoute[i].X;
      f.Write(d, SizeOf(d));
      d := fRoute[i].Y;
      f.Write(d, SizeOf(d));
    End;
    f.free;
  End;
End;

Procedure TForm40.Button6Click(Sender: TObject);
Var
  f: TFileStream;
  i: integer;
  dx, dy: Double;
  b: Boolean;
  ver: uint32;
Begin
  // Import Route
  If OpenDialog1.Execute Then Begin
    CheckBox3.Checked := false;
    CheckBox10.Checked := true;
    f := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
    ver := 0; // Die Dateiversion
    f.read(ver, sizeof(RouteFileVersion));
    // Viewport Einstellungen
    i := 14;
    f.read(i, SizeOf(i));
    form15.mv.Zoom := i;
    dx := -1;
    f.Read(dx, SizeOf(dx));
    dy := -1;
    f.Read(dy, SizeOf(dy));
    If ver > 1 Then Begin // Ab Version 2 werden die Fenster Dimensionen mit gespeichert
      i := 0;
      f.read(i, SizeOf(i));
      If i <> 0 Then Begin
        form15.Width := i;
      End;
      i := 0;
      f.read(i, SizeOf(i));
      If i <> 0 Then Begin
        form15.Height := i;
      End;
    End;
    form15.mv.CenterLongLat(dx, dy);
    // Die Suchparameter
    b := false;
    f.Read(b, SizeOf(b));
    CheckBox1.Checked := b; // Hide Own
    f.Read(b, SizeOf(b));
    CheckBox2.Checked := b; // Hide founds
    f.Read(b, SizeOf(b));
    CheckBox4.Checked := b; // All
    f.Read(b, SizeOf(b));
    CheckBox8.Checked := b; // exclude
    f.Read(b, SizeOf(b));
    CheckBox5.Checked := b; // Tradi
    f.Read(b, SizeOf(b));
    CheckBox6.Checked := b; // Multi
    f.Read(b, SizeOf(b));
    CheckBox7.Checked := b; // Mystery
    f.Read(b, SizeOf(b));
    CheckBox9.Checked := b; // Events
    i := 14;
    f.read(i, SizeOf(i));
    edit1.text := inttostr(i);
    // Alle Punkte
    i := 0;
    f.read(i, SizeOf(i));
    setlength(fRoute, i);
    For i := 0 To high(fRoute) Do Begin
      f.Read(dx, SizeOf(dx));
      f.Read(dy, SizeOf(dy));
      fRoute[i].X := dx;
      fRoute[i].Y := dy;
    End;
    f.free;
    form15.OpenGLControl1Paint(Nil);
  End;
End;

Procedure TForm40.Button7Click(Sender: TObject);
Var
  c: TLABCacheInfoArray;
Begin
  // Merge All Cached Labs to DB
  c := fOnlineViewer.GetAllLABsCaches();
  MergeLabsCachesToDB(c);
  setlength(c, 0);
End;

Procedure TForm40.Button8Click(Sender: TObject);
Var
  c: TLABCacheInfoArray;
  vp: TViewport;
  pt: TVector2;
Begin
  // Merge All visual Caches To DB
  pt := form15.mv.GetMouseMapLongLat(0, 0);
  vp.Lon_min := pt.x;
  vp.Lat_min := pt.Y;
  pt := form15.mv.GetMouseMapLongLat(form15.OpenGLControl1.ClientWidth, form15.OpenGLControl1.ClientHeight);
  vp.Lon_max := pt.x;
  vp.Lat_max := pt.Y;
  c := fOnlineViewer.GetAllVisibleLabs(vp);
  MergeLabsCachesToDB(c);
  setlength(c, 0);
End;

Procedure TForm40.CheckBox10Click(Sender: TObject);
Begin
  If Not CheckBox10.Checked Then Begin
    setlength(fRoute, 0);
    form15.OpenGLControl1Paint(Nil);
  End;
End;

Procedure TForm40.CheckBox11Click(Sender: TObject);
Begin
  If (form15.mv.Zoom <= 11) And CheckBox11.Checked Then Begin
    If id_no = Application.MessageBox(pchar(format(RF_Activating_Download_in_Zoom_lt_could_cause_havy_download_times, [11])), pchar(R_Warning), MB_ICONQUESTION Or MB_YESNO) Then Begin
      CheckBox11.Checked := false;
    End;
  End;
  fOnlineViewer.EnableLABDownloading := CheckBox11.Checked;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox1Click(Sender: TObject);
Begin
  fOnlineViewer.HideOwn := CheckBox1.Checked;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox2Click(Sender: TObject);
Begin
  fOnlineViewer.HideFounds := CheckBox2.Checked;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox3Click(Sender: TObject);
Begin
  If (form15.mv.Zoom <= 11) And CheckBox3.Checked Then Begin
    If id_no = Application.MessageBox(pchar(format(RF_Activating_Download_in_Zoom_lt_could_cause_havy_download_times, [11])), pchar(R_Warning), MB_ICONQUESTION Or MB_YESNO) Then Begin
      CheckBox3.Checked := false;
    End;
  End;
  fOnlineViewer.EnableDownloading := CheckBox3.Checked;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox4Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_All := CheckBox4.Checked;
  If CheckBox4.Checked Then Begin
    CheckBox5.Checked := false;
    CheckBox6.Checked := false;
    CheckBox7.Checked := false;
    CheckBox8.Checked := false;
    CheckBox9.Checked := false;
  End;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox5Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Tradi := CheckBox5.Checked;
  If CheckBox5.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox6Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Multi := CheckBox6.Checked;
  If CheckBox6.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox7Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Mystery := CheckBox7.Checked;
  If CheckBox7.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox8Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Exclude := CheckBox8.Checked;
  If CheckBox8.Checked Then Begin
    CheckBox4.Checked := false;
  End;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.CheckBox9Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Event := CheckBox9.Checked;
  If CheckBox9.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.FormCloseQuery(Sender: TObject; Var CanClose: boolean);
Begin
  // Stop any loading
  fOnlineViewer.EnableDownloading := false;
  fOnlineViewer.EnableLABDownloading := false;
  CheckBox3.Checked := false;
  CheckBox10.Checked := false;
  ClearCaches();
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm40.FormCreate(Sender: TObject);
Begin
  caption := 'Online mode configurator';
  fRoute := Nil;
  fOnlineViewer := TOnlineViewer.create(form15.OpenGLControl1);
  fOnlineViewer.WaitEvent := @OnWaitEvent;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;
  Constraints.MinWidth := Width;
  Constraints.MaxWidth := Width;
  edit1.text := '14';
  // Todo: Hier könnten noch viel Krassere Filter (ala d/t) rein, siehe hierzu die Auswertung, was mapsearch noch alles kann
End;

Procedure TForm40.FormDestroy(Sender: TObject);
Begin
  fOnlineViewer.Free;
  fOnlineViewer := Nil;
End;

Procedure TForm40.Label1Click(Sender: TObject);
Begin
  CheckBox3.Checked := Not CheckBox3.Checked;
  CheckBox3Click(Nil);
End;

Procedure TForm40.MergeLiteCachesToDB(Const Caches: TLiteCacheArray);
Var
  cnt, i: integer;
  c: TCache;
  t: int64;
Begin
  t := GetTickCount64;
  cnt := 0;
  form4.RefresStatsMethod('', cnt, 0, true);
  For i := 0 To high(caches) Do Begin
    c := LiteCacheToCache(Caches[i]);
    If CacheToDB(c, false, false) Then Begin
      inc(cnt);
      If cnt Mod 5 = 0 Then Begin
        form4.RefresStatsMethod('', cnt, 0, false);
      End;
    End;
    If form4.Abbrechen Then break;
  End;
  SQLTransaction.Commit;
  form4.hide;
  t := GetTickCount64 - t;
  form1.RefreshDataBaseCacheCountinfo;
  Showmessage(format(RF_Script_finished_in, [PrettyTime(t)], DefFormat));
End;

Procedure TForm40.MergeLabsCachesToDB(Const Labs: TLABCacheInfoArray);
Var
  cnt, i, j: integer;
  c: TCacheArray;
  t: int64;
Begin
  t := GetTickCount64;
  cnt := 0;
  form4.RefresStatsMethod('', cnt, 0, true);
  For i := 0 To high(Labs) Do Begin
    c := GCTDownloadLAB(labs[i], CheckBox12.Checked);
    For j := 0 To high(c) Do Begin
      If CacheToDB(c[j], false, false) Then Begin
        inc(cnt);
        If cnt Mod 5 = 0 Then Begin
          form4.RefresStatsMethod('', cnt, 0, false);
        End;
      End;
      If form4.Abbrechen Then break;
    End;
  End;
  SQLTransaction.Commit;
  form4.hide;
  t := GetTickCount64 - t;
  form1.RefreshDataBaseCacheCountinfo;
  Showmessage(format(RF_Script_finished_in, [PrettyTime(t)], DefFormat));
End;

Procedure TForm40.OnWaitEvent(Sender: TObject; Delay: Int64);
Var
  t: QWord;
Begin
  t := GetTickCount64;
  While t + Delay >= GetTickCount64 Do Begin
    sleep(1);
    Application.ProcessMessages;
    If Not fOnlineViewer.EnableDownloading Then exit;
  End;
End;

Function TForm40.GetSplashHint(x, y: integer): String;
Begin
  result := fOnlineViewer.Hint(x, y);
End;

Function TForm40.GetLabAt(x, y: integer): TLABCacheInfo;
Begin
  result := fOnlineViewer.GetLabAt(x, y);
End;

Procedure TForm40.ChangeIconTo(CacheHint: String; OpenGLIndex: integer);
Begin
  fOnlineViewer.ChangeIconTo(CacheHint, OpenGLIndex);
End;

Procedure TForm40.ResetIcon(CacheHint: String);
Begin
  fOnlineViewer.ResetIcon(CacheHint);
End;

Procedure TForm40.ResetAllIcons();
Begin
  fOnlineViewer.ResetAllIcons();
End;

Function TForm40.InitFormular(): boolean;
Var
  p: TServerParameters;
Begin
  result := false;
  CheckBox3.Checked := false; // Downloading erst mal deaktivieren
  CheckBox11.Checked := false; // Downloading erst mal deaktivieren
  // 1. Rauskriegen ob wir Premium sind oder nicht
  p := GCTGetServerParams();
  If p.UserInfo.Username = '' Then exit; // konnte die Infos nicht hohlen.
  If trim(lowercase(p.UserInfo.Usertype)) = 'premium' Then Begin
    CheckBox1.Enabled := true;
    CheckBox2.Enabled := true;
    CheckBox1.Checked := true;
    CheckBox2.Checked := true;
  End
  Else Begin
    // Ohne Premium geht das nicht..
    CheckBox1.Enabled := false;
    CheckBox2.Enabled := false;
    CheckBox1.Checked := false;
    CheckBox2.Checked := false;
  End;
  CheckBox3.Enabled := true;
  CheckBox4.Checked := true;
  CheckBox4.OnClick(Nil);
  result := true;
End;

Function TForm40.GetCachedCacheCount(): TPoint;
Begin
  result := point(renderedCached, fOnlineViewer.CacheCount + fOnlineViewer.CacheLabCount);
End;

Procedure TForm40.RenderViewPort(vp: TViewport);
Begin
  renderedCached := fOnlineViewer.RenderViewPort(vp);
End;

Procedure TForm40.AddRoutePoint(x, y: integer);
Begin
  SetLength(fRoute, high(fRoute) + 2);
  froute[high(fRoute)] := form15.mv.GetMouseMapLongLat(x, y)
End;

Procedure TForm40.DelRoutePoint(x, y: integer);
Var
  p: TPoint;
  i, j: Integer;
Begin
  For i := 0 To high(fRoute) Do Begin
    p := form15.mv.GetMouseMapLongLatRev(fRoute[i]);
    If (abs(p.x - x) <= 16) And
      (abs(p.y - y) <= 16) Then Begin
      For j := i To high(fRoute) - 1 Do Begin
        fRoute[j] := fRoute[j + 1];
      End;
      setlength(fRoute, high(fRoute));
    End;
  End;
End;

Procedure TForm40.IncPointOrder(x, y: integer);
Var
  pr: TVector2;
  p: TPoint;
  i: Integer;
Begin
  For i := 0 To high(fRoute) - 1 Do Begin
    p := form15.mv.GetMouseMapLongLatRev(fRoute[i]);
    If (abs(p.x - x) <= 16) And
      (abs(p.y - y) <= 16) Then Begin
      pr := fRoute[i];
      fRoute[i] := fRoute[i + 1];
      fRoute[i + 1] := pr;
      form15.OpenGLControl1Paint(Nil);
      exit;
    End;
  End;
End;

Procedure TForm40.DecPointOrder(x, y: integer);
Var
  pr: TVector2;
  p: TPoint;
  i: Integer;
Begin
  For i := 1 To high(fRoute) Do Begin
    p := form15.mv.GetMouseMapLongLatRev(fRoute[i]);
    If (abs(p.x - x) <= 16) And
      (abs(p.y - y) <= 16) Then Begin
      pr := fRoute[i];
      fRoute[i] := fRoute[i - 1];
      fRoute[i - 1] := pr;
      form15.OpenGLControl1Paint(Nil);
      exit;
    End;
  End;

End;

Procedure TForm40.RenderRoutePoints(vp: TViewport);
Var
  i, yc, xc: integer;
  b: {$IFDEF USE_GL}Byte{$ELSE}Boolean{$ENDIF};
Begin
  Go2d(form15.OpenGLControl1.ClientWidth, form15.OpenGLControl1.ClientHeight);
  For i := 0 To high(fRoute) Do Begin
    yc := convert_dimension(vp.Lat_min, vp.Lat_max, fRoute[i].Y, 0, form15.OpenGLControl1.ClientHeight) - 16; // Das Offset Zentriert die Dose an der Listing Coordinate und schon sieht man nicht das bei Aktiver DB da 2 Symbole Gleichzeitig sind :-)
    xc := convert_dimension(vp.Lon_min, vp.Lon_max, fRoute[i].X, 0, form15.OpenGLControl1.Clientwidth) - 8; // Das Offset Zentriert die Dose an der Listing Coordinate und schon sieht man nicht das bei Aktiver DB da 2 Symbole Gleichzeitig sind :-)
    B := glIsEnabled(gl_Blend);
    If Not (b{$IFDEF USE_GL} = 1{$ENDIF}) Then
      glenable(gl_Blend);
    glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
    glColor3d(1, 1, 1);
    glBindTexture(GL_TEXTURE_2D, OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(MainImageIndexPointHere) + ']', true));
    glbegin(GL_QUADS);
    glTexCoord2f(0, 1);
    glVertex2f(Xc, Yc + 16);
    glTexCoord2f(1, 1);
    glVertex2f(Xc + 16, Yc + 16);
    glTexCoord2f(1, 0);
    glVertex2f(Xc + 16, Yc);
    glTexCoord2f(0, 0);
    glVertex2f(Xc, Yc);
    glend;
    If Not (b{$IFDEF USE_GL} = 1{$ENDIF}) Then
      gldisable(gl_blend);
    glColor3d(1, 1, 1);
    glBindTexture(GL_TEXTURE_2D, 0);
    OpenGL_ASCII_Font.Textout(xc + 16, yc, inttostr(i + 1));
  End;
  Exit2d();
End;

Function TForm40.GetAllCachedCaches(): TLiteCacheArray;
Begin
  result := fOnlineViewer.GetAllCachedCaches();
End;

Function TForm40.GetAllCachesAround(vp: TViewport): TLiteCacheArray;
Begin
  fOnlineViewer.EnableDownloading := true;
  (*
   * -- Das Problem, Archivierte Caches sind nicht in den Lite Caches enthalten,
   * hat man eine Aktualisierung wo viele Lite Caches mit drin sind, würde
   * ettliche male das bereits geladene neu geladen werden.
   * Das Kostet in Summe deutlich mehr Zeit, als es Kostet die ganzen Dosen für
   * die Dauer der Aktualisierung immer wieder "unnötig" mit zu prüfen.
   *)
  // fOnlineViewer.ResetCache;
  fOnlineViewer.Caches_All := true;
  fOnlineViewer.HideFounds := false;
  fOnlineViewer.HideOwn := False;
  fOnlineViewer.EnableDownloading := false;
  fOnlineViewer.DownloadViewPort(vp);
  result := fOnlineViewer.GetAllCachedCaches();
End;

Procedure TForm40.ClearCaches();
Begin
  fOnlineViewer.ResetCache;
End;

End.

