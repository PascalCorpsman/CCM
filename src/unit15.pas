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
Unit Unit15;

{$MODE objfpc}{$H+}

{$DEFINE DebuggMode}

Interface

{$I ccm.inc}

Uses
  Classes, SysUtils, FileUtil, OpenGLContext, Forms, Controls, Graphics,
  Dialogs, Menus, ExtCtrls, StdCtrls, types, umapviewer, uonlineviewer
  , usqlite_helper // Muss vor uccm eingebunden werden !
  , uccm
  , ugctoolwrapper
  , uvectormath
  ;

Const
  (*
   * Historie: 1 = initialversion
   *           2 = ?
   *)
  RouteFileVersion: uint32 = 2;

  (*
   * Historie: 1 = initialversion
   *)
  UserPointFileVersion: uint32 = 1;

Type

  TCacheInfo = Record
    x, y: Double;
    icon: integer;
    name: String;
  End;

  { TForm15 }

  TForm15 = Class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
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
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem60: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem63: TMenuItem;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    OpenGLControl1: TOpenGLControl;
    PopupMenu1: TPopupMenu;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    Separator1: TMenuItem;
    Procedure Button10Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
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
    Procedure FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
    Procedure Label1Click(Sender: TObject);
    Procedure Label3Click(Sender: TObject);
    Procedure MenuItem10Click(Sender: TObject);
    Procedure MenuItem13Click(Sender: TObject);
    Procedure MenuItem14Click(Sender: TObject);
    Procedure MenuItem16Click(Sender: TObject);
    Procedure MenuItem17Click(Sender: TObject);
    Procedure MenuItem19Click(Sender: TObject);
    Procedure MenuItem1Click(Sender: TObject);
    Procedure MenuItem20Click(Sender: TObject);
    Procedure MenuItem21Click(Sender: TObject);
    Procedure MenuItem22Click(Sender: TObject);
    Procedure MenuItem24Click(Sender: TObject);
    Procedure MenuItem25Click(Sender: TObject);
    Procedure MenuItem26Click(Sender: TObject);
    Procedure MenuItem2Click(Sender: TObject);
    Procedure MenuItem3Click(Sender: TObject);
    Procedure MenuItem4Click(Sender: TObject);
    Procedure MenuItem62Click(Sender: TObject);
    Procedure MenuItem63Click(Sender: TObject);
    Procedure MenuItem6Click(Sender: TObject);
    Procedure MenuItem7Click(Sender: TObject);
    Procedure MenuItem8Click(Sender: TObject);
    Procedure MenuItem9Click(Sender: TObject);
    Procedure OpenGLControl1DblClick(Sender: TObject);
    Procedure OpenGLControl1MakeCurrent(Sender: TObject; Var Allow: boolean);
    Procedure OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    Procedure OpenGLControl1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; Var Handled: Boolean);
    Procedure OpenGLControl1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; Var Handled: Boolean);
    Procedure OpenGLControl1Paint(Sender: TObject);
    Procedure OpenGLControl1Resize(Sender: TObject);
  private
    { private declarations }
    fOnlineViewer: TOnlineViewer;
    renderedCached: Integer;
    fRoute: Array Of TVector2;

    mv: TMapViewer;
    Procedure CenterCaches(Sender: TObject);
    Function CalcZoomLevel(Distance: int64): integer;
    Procedure AddUserPointAt(lat, lon: Double);

    Function GetSplashHint(x, y: integer): String;
    Function GetLabAt(x, y: integer): TLABCacheInfo;
    Procedure ChangeIconTo(CacheHint: String; OpenGLIndex: integer);
    Procedure ResetIcon(CacheHint: String);
    Procedure ResetAllIcons();

    Function GetCachedCacheCount(): TPoint;
    Procedure RenderViewPort(vp: TViewport);

    Procedure AddRoutePoint(x, y: integer);
    Procedure DelRoutePoint(x, y: integer);
    Procedure IncPointOrder(x, y: integer);
    Procedure DecPointOrder(x, y: integer);

    Procedure RenderRoutePoints(vp: TViewport);
    Function GetAllCachedCaches(): TLiteCacheArray;
    Procedure ClearCaches();

    Procedure MergeLiteCachesToDB(Const Caches: TLiteCacheArray);
    Procedure MergeLabsCachesToDB(Const Labs: TLABCacheInfoArray);
    Procedure OnWaitEvent(Sender: TObject; Delay: Int64);

  public
    { public declarations }

    Function InitFormular(): boolean;
    Function GetAllCachesAround(vp: TViewport): TLiteCacheArray;
  End;

Var
  Form15: TForm15;
  Form15Initialized: Boolean = false; // Wenn True dann ist OpenGL initialisiert
  UserPointCount: integer;
  MoveX, MoveY: integer;
  Splashhint: String;
  Splashhint2: String;
  allowcnt: Integer = 0;

Implementation

{$R *.lfm}

Uses lazutf8, math, dglOpenGL, uopengl_graphikengine, ugraphics, uOpenGL_ASCII_Font,

  unit1, // Main Form
  unit4, // Der Info Dialog, dass man sieht dass noch was passiert
  unit13, // Preview des Caches
  unit14, // Location Editor
  unit31, // Edit Custom Location
  unit39, // Select via Listbox
  ulanguage,
  Clipbrd,
  LCLType,
  LCLIntf
  ;

{ TForm15 }

Procedure TForm15.FormCreate(Sender: TObject);
Begin
  caption := 'Map preview'; // Sollte eigentlich nie angezeigt werden, aber wenn Windows mal wieder nicht mit dem Laden hinter her kommt, dann schon ...
  mv := TMapViewer.create(OpenGLControl1);
  mv.CacheFolder := GetMapCacheDir();
  mv.ScrollGrid := strtoint(GetValue('General', 'MapPreviewScrollGrid', '1'));
  // Init dglOpenGL.pas , Teil 1
  If Not InitOpenGl Then Begin
    showmessage(R_Error_could_not_init_dglOpenGL_pas);
    Halt;
  End;
  GroupBox1.Align := alRight;
  OpenGLControl1.Align := alClient;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  fRoute := Nil;
  fOnlineViewer := TOnlineViewer.create(OpenGLControl1);
  fOnlineViewer.WaitEvent := @OnWaitEvent;
  edit1.text := '14';
  // Todo: Hier könnten noch viel Krassere Filter (ala d/t) rein, siehe hierzu die Auswertung, was mapsearch noch alles kann
End;

Procedure TForm15.FormCloseQuery(Sender: TObject; Var CanClose: boolean);
Begin
  Button10Click(Nil);
End;

Procedure TForm15.Button1Click(Sender: TObject);
Begin
  GroupBox1.Visible := Not GroupBox1.Visible;
End;

Procedure TForm15.Button10Click(Sender: TObject);
Begin
  // Stop any loading
  fOnlineViewer.EnableDownloading := false;
  fOnlineViewer.EnableLABDownloading := false;
  CheckBox3.Checked := false;
  CheckBox10.Checked := false;
  ClearCaches();
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm15.Button3Click(Sender: TObject);
Var
  c: TLiteCacheArray;
Begin
  // Merge All Cached Caches to DB
  c := fOnlineViewer.GetAllCachedCaches();
  MergeLiteCachesToDB(c);
  setlength(c, 0);
End;

Procedure TForm15.Button4Click(Sender: TObject);
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

Procedure TForm15.Button5Click(Sender: TObject);
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
  startZoom := mv.Zoom;
  StartPos := mv.GetMouseMapLongLat(OpenGLControl1.ClientWidth Div 2, OpenGLControl1.ClientHeight Div 2);
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

Procedure TForm15.Button6Click(Sender: TObject);
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

Procedure TForm15.Button7Click(Sender: TObject);
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

Procedure TForm15.Button8Click(Sender: TObject);
Var
  c: TLABCacheInfoArray;
Begin
  // Merge All Cached Labs to DB
  c := fOnlineViewer.GetAllLABsCaches();
  MergeLabsCachesToDB(c);
  setlength(c, 0);
End;

Procedure TForm15.Button9Click(Sender: TObject);
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

Procedure TForm15.CheckBox10Click(Sender: TObject);
Begin
  // Enable Disable Route
  If Not CheckBox10.Checked Then Begin
    setlength(fRoute, 0);
    form15.OpenGLControl1Paint(Nil);
  End;
End;

Procedure TForm15.CheckBox11Click(Sender: TObject);
Begin
  If (form15.mv.Zoom <= 11) And CheckBox11.Checked Then Begin
    If id_no = Application.MessageBox(pchar(format(RF_Activating_Download_in_Zoom_lt_could_cause_havy_download_times, [11])), pchar(R_Warning), MB_ICONQUESTION Or MB_YESNO) Then Begin
      CheckBox11.Checked := false;
    End;
  End;
  fOnlineViewer.EnableLABDownloading := CheckBox11.Checked;
  //  If CheckBox11.Checked Then Begin
  //    CheckBox3.Checked := true;
  //    fOnlineViewer.EnableDownloading := true;
  //  End;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox1Click(Sender: TObject);
Begin
  fOnlineViewer.HideOwn := CheckBox1.Checked;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox2Click(Sender: TObject);
Begin
  fOnlineViewer.HideFounds := CheckBox2.Checked;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox3Click(Sender: TObject);
Begin
  If (mv.Zoom <= 11) And CheckBox3.Checked Then Begin
    If id_no = Application.MessageBox(pchar(format(RF_Activating_Download_in_Zoom_lt_could_cause_havy_download_times, [11])), pchar(R_Warning), MB_ICONQUESTION Or MB_YESNO) Then Begin
      CheckBox3.Checked := false;
    End;
  End;
  fOnlineViewer.EnableDownloading := CheckBox3.Checked;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox4Click(Sender: TObject);
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

Procedure TForm15.CheckBox5Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Tradi := CheckBox5.Checked;
  If CheckBox5.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox6Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Multi := CheckBox6.Checked;
  If CheckBox6.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox7Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Mystery := CheckBox7.Checked;
  If CheckBox7.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox8Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Exclude := CheckBox8.Checked;
  If CheckBox8.Checked Then Begin
    CheckBox4.Checked := false;
  End;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.CheckBox9Click(Sender: TObject);
Begin
  fOnlineViewer.Caches_Event := CheckBox9.Checked;
  If CheckBox9.Checked Then CheckBox4.Checked := false;
  form15.OpenGLControl1Paint(Nil);
End;

Procedure TForm15.FormDestroy(Sender: TObject);
Begin
  mv.Free;
  mv := Nil;
  fOnlineViewer.Free;
  fOnlineViewer := Nil;
End;

Procedure TForm15.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState
  );
Var
  dummy: Boolean;
  i: Integer;
Begin
{$IFDEF Windows}
  If (ssCtrl In shift) Then Begin
    If (key = ord('S')) Then Begin
      MenuItem62Click(Nil);
    End;
    If (key = ord('C')) Then Begin
      MenuItem63Click(Nil);
    End;
  End;
{$ENDIF}
  If (Key = VK_ADD) Or (key = VK_PRIOR) Then Begin
    For i := 0 To strtoint(GetValue('General', 'MapPreviewScrollGrid', '1')) - 1 Do Begin
      dummy := false;
      OpenGLControl1.OnMouseWheelUp(self, [], point(MoveX, MoveY), dummy);
    End;
    OpenGLControl1MouseMove(Nil, [ssleft], MoveX, MoveY);
  End;
  If (Key = VK_SUBTRACT) Or (key = VK_NEXT) Then Begin
    For i := 0 To strtoint(GetValue('General', 'MapPreviewScrollGrid', '1')) - 1 Do Begin
      dummy := false;
      OpenGLControl1.OnMouseWheelDown(self, [], point(MoveX, MoveY), dummy);
    End;
    OpenGLControl1MouseMove(Nil, [ssleft], MoveX, MoveY);
  End;
End;

Procedure TForm15.Label1Click(Sender: TObject);
Begin
  // Check / UnCheck Enable Downloading
  CheckBox3.Checked := Not CheckBox3.Checked;
  CheckBox3Click(Nil);
End;

Procedure TForm15.Label3Click(Sender: TObject);
Begin
  // Check / UnCheck Enable Lab Downloading
  CheckBox11.Checked := Not CheckBox11.Checked;
  CheckBox11Click(Nil);
End;

Procedure TForm15.OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
Var
  img: TImageInfoRecord;
  r: TVector2;
  s: String;
  p: Tpoint;
Begin
  If ssleft In shift Then OpenGLControl1Paint(Nil);
  MoveX := x;
  MoveY := y;
  r := mv.GetMouseMapLongLat(X, y);
  caption := CoordToString(r.y, r.x) + format('= [ %1.6f , %1.6f ]', [r.y, r.x], DefFormat) + format(' ,Zoom : %d', [mv.Zoom]);
  //  If CheckBox3.Checked Then Begin
  p := GetCachedCacheCount;
  caption := caption + ', Rendered: ' + inttostr(p.x) + ', Cached: ' + inttostr(p.y);
  Application.ProcessMessages; // Wenn wir im Routen Modus sind sehen wir sonst nichts ...
  //  End;
  If mv.GetImageAtXY(MoveX, MoveY, img) Then Begin
    If Splashhint <> img.Label_ Then Begin
      Splashhint := img.Label_;
      OpenGLControl1Paint(Nil);
    End;
  End
  Else Begin
    If Splashhint <> '' Then Begin
      Splashhint := '';
      OpenGLControl1Paint(Nil);
    End;
  End;
  s := GetSplashHint(x, y);
  If s <> Splashhint2 Then Begin
    Splashhint2 := s;
    OpenGLControl1Paint(Nil);
  End;
End;

Procedure TForm15.OpenGLControl1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; Var Handled: Boolean);
Var
  z: integer;
Begin
  z := mv.Zoom;
  // Automatisches Abschalten des Ladens bei Zoom <= 11
  If CheckBox3.Checked And (z <= 11) Then Begin
    CheckBox3.Checked := false;
  End;
  OpenGLControl1MouseMove(Nil, [ssleft], MousePos.x, MousePos.y);
End;

Procedure TForm15.OpenGLControl1MouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; Var Handled: Boolean);
Begin
  OpenGLControl1MouseMove(Nil, [ssleft], MousePos.x, MousePos.y);
End;

Procedure TForm15.MenuItem10Click(Sender: TObject);
Var
  wp: TWaypointList;
  i, j: LongInt;
  WPIcon: integer;
Begin
  // Show Waypoints
  For i := 1 To Form1.StringGrid1.RowCount - 1 Do Begin
    wp := WaypointsFromDB(form1.StringGrid1.Cells[MainColGCCode, i]);
    For j := 0 To high(wp) Do Begin
      WPIcon := max(0, form1.CacheTypeToIconIndex(wp[j].sym));
      mv.AddImageOnCoord(
        wp[j].Lon, wp[j].lat, // Die Position
        OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(WPIcon) + ']'), // Das Bild
        Form1.ImageList1.Width, Form1.ImageList1.Height, // Die Dimensionen
        -Form1.ImageList1.Width Div 2, -Form1.ImageList1.Height Div 2, // Die Verschiebung
        '  ' + wp[j].Name + ': ' + form1.StringGrid1.Cells[MainColTitle, i], form1.StringGrid1.Cells[MainColGCCode, i] + ': ' + form1.StringGrid1.Cells[MainColTitle, i]);
    End;
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem13Click(Sender: TObject);
Var
  img: TImageInfoRecord;
  s: String;
Begin
  // Open Cache in Browser
  // via Datenbank
  If mv.GetImageAtXY(MoveX, MoveY, img) And (img.MetaInfo <> '') Then Begin
    If pos(':', img.MetaInfo) <> 0 Then Begin
      OpenCacheInBrowser(copy(img.MetaInfo, 1, pos(':', img.MetaInfo) - 1));
    End
    Else Begin
      OpenCacheInBrowser(img.MetaInfo);
    End;
  End;
  // Via Online suche
  s := GetSplashHint(MoveX, MoveY);
  If s <> '' Then Begin
    If pos(':', s) <> 0 Then Begin
      OpenCacheInBrowser(copy(s, 1, pos(':', s) - 1));
    End
    Else Begin
      OpenCacheInBrowser(s);
    End;
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem14Click(Sender: TObject);
Var
  r: TVector2;
Begin
  // Add Location here
  r := mv.GetMouseMapLongLat(moveX, movey);
  form14.edit4.text := format('%2.6f', [r.X]);
  form14.edit3.text := format('%2.6f', [r.y]);
  form14.Button3.Click;
  form14.ReloadLocations;
  Form14.ComboBox4.Text := Form14.ComboBox2.Text;
  Form14.ComboBox5.Text := Form14.ComboBox3.Text;
  Form14.Edit5.text := Form14.Edit1.Text;
  Form14.Edit6.text := Form14.Edit2.Text;
  form14.GroupBox1.Enabled := false;
  FormShowModal(form14, self);
  form14.GroupBox1.Enabled := true;
  If (form14.Edit3.Text <> '') And (form14.Edit4.Text <> '') Then Begin
    AddUserPointAt(StrToFloat(form14.edit4.text), StrToFloat(form14.edit3.text));
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem16Click(Sender: TObject);
Var
  img: TImageInfoRecord;
  rp: TVector2;
  s: String;
Begin
  //Copy Actual Coord to Clipboard
  If mv.GetImageAtXY(MoveX, MoveY, img) Then Begin
    If pos('userpoint ', lowercase(trim(img.Label_))) = 1 Then Begin
      Clipboard.AsText := CoordToString(img.y, img.x);
    End
    Else Begin
      If (img.MetaInfo <> '') Then Begin
        // Die Metainfo besteht entweder nur aus dem GC-Code oder aus GC-Code:GC description
        If pos(':', img.MetaInfo) <> 0 Then Begin
          s := copy(img.MetaInfo, 1, pos(':', img.MetaInfo) - 1);
        End
        Else Begin
          s := img.MetaInfo;
        End;
        // In S steht nun der GC-Code
        s := s;
        StartSQLQuery('Select c.lat, c.lon, c.cor_lat, c.cor_lon from caches c where c.name = "' + ToSQLString(s) + '"');
        If SQLQuery.EOF Then Begin
          // Es gibt die Dose nicht
          rp := mv.GetMouseMapLongLat(MoveX, MoveY);
          Clipboard.AsText := CoordToString(rp.y, rp.x);
        End
        Else Begin
          // Die Dose Existiert.
          If (SQLQuery.Fields[2].AsFloat <> -1) And (SQLQuery.Fields[3].AsFloat <> -1) Then Begin
            // Die Dose hat Korrigierte Koordinaten
            Clipboard.AsText := CoordToString(SQLQuery.Fields[2].AsFloat, SQLQuery.Fields[3].AsFloat);
          End
          Else Begin
            // Die Koords der Dose
            Clipboard.AsText := CoordToString(SQLQuery.Fields[0].AsFloat, SQLQuery.Fields[1].AsFloat);
          End;
        End;
      End
      Else Begin
        rp := mv.GetMouseMapLongLat(MoveX, MoveY);
        Clipboard.AsText := CoordToString(rp.y, rp.x);
      End;
    End;
  End
  Else Begin
    rp := mv.GetMouseMapLongLat(MoveX, MoveY);
    Clipboard.AsText := CoordToString(rp.y, rp.x);
  End;
End;

Procedure TForm15.MenuItem17Click(Sender: TObject);
Var
  img: TImageInfoRecord;
  rp: TVector2;
  s: String;
Begin
  //Wegpunkt Projektion
  If mv.GetImageAtXY(MoveX, MoveY, img) Then Begin
    If pos('userpoint ', lowercase(trim(img.Label_))) = 1 Then Begin
      form31.InitWithPoint(img.y, img.x);
      FormShowModal(form31, self);
      If form31.ModalResult = mrOK Then Begin
        form15.AddUserPointAt(form31.ResultLon, form31.ResultLat);
      End;
    End
    Else Begin
      If (img.MetaInfo <> '') Then Begin
        // Die Metainfo besteht entweder nur aus dem GC-Code oder aus GC-Code:GC description
        If pos(':', img.MetaInfo) <> 0 Then Begin
          s := copy(img.MetaInfo, 1, pos(':', img.MetaInfo) - 1);
        End
        Else Begin
          s := img.MetaInfo;
        End;
        // In S steht nun der GC-Code
        s := s;
        StartSQLQuery('Select c.lat, c.lon, c.cor_lat, c.cor_lon from caches c where c.name = "' + ToSQLString(s) + '"');
        If SQLQuery.EOF Then Begin
          // Es gibt die Dose nicht
          rp := mv.GetMouseMapLongLat(MoveX, MoveY);
          form31.InitWithPoint(rp.y, rp.x);
          FormShowModal(form31, self);
          If form31.ModalResult = mrOK Then Begin
            form15.AddUserPointAt(form31.ResultLon, form31.ResultLat);
          End;
        End
        Else Begin
          // Die Dose Existiert.
          If (SQLQuery.Fields[2].AsFloat <> -1) And (SQLQuery.Fields[3].AsFloat <> -1) Then Begin
            // Die Dose hat Korrigierte Koordinaten
            rp.y := SQLQuery.Fields[2].AsFloat;
            rp.x := SQLQuery.Fields[3].AsFloat;
          End
          Else Begin
            // Die Koords der Dose
            rp.y := SQLQuery.Fields[0].AsFloat;
            rp.x := SQLQuery.Fields[1].AsFloat;
          End;
          form31.InitWithPoint(rp.y, rp.x);
          FormShowModal(form31, self);
          If form31.ModalResult = mrOK Then Begin
            form15.AddUserPointAt(form31.ResultLon, form31.ResultLat);
          End;
        End;
      End
      Else Begin
        rp := mv.GetMouseMapLongLat(MoveX, MoveY);
        form31.InitWithPoint(rp.y, rp.x);
        FormShowModal(form31, self);
        If form31.ModalResult = mrOK Then Begin
          form15.AddUserPointAt(form31.ResultLon, form31.ResultLat);
        End;
      End;
    End;
  End
  Else Begin
    rp := mv.GetMouseMapLongLat(MoveX, MoveY);
    form31.InitWithPoint(rp.y, rp.x);
    FormShowModal(form31, self);
    If form31.ModalResult = mrOK Then Begin
      form15.AddUserPointAt(form31.ResultLon, form31.ResultLat);
    End;
  End;
End;

Procedure TForm15.MenuItem19Click(Sender: TObject);
Var
  ic, i: Integer;
  img: TImageInfoRecord;
  c: String;
Begin
  // Clear all Customer Flags
  CommitSQLTransactionQuery('Update caches set Customer_Flag = 0');
  SQLTransaction.Commit;
  For i := 0 To mv.ImageCount - 1 Do Begin
    img := mv.Image[i];
    If pos(':', img.MetaInfo) <> 0 Then Begin
      c := copy(img.MetaInfo, 1, pos(':', img.MetaInfo) - 1);
    End
    Else Begin
      c := img.MetaInfo;
    End;
    ic := max(0, form1.CacheTypeToIconIndex(form1.CacheNameToCacheType(c)));
    img.ImageIndex := OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(ic) + ']');
    mv.Image[i] := img;
  End;
  ResetAllIcons();
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem1Click(Sender: TObject);
Begin
  MenuItem1.Checked := true; // Normal
  MenuItem2.Checked := false; // Satellit
  MenuItem3.Checked := false; // Hybrid
  MenuItem20.Checked := false; // Terrain
  mv.Source := msGoogleNormal;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem20Click(Sender: TObject);
Begin
  MenuItem1.Checked := false; // Normal
  MenuItem2.Checked := false; // Satellit
  MenuItem3.Checked := false; // Hybrid
  MenuItem20.Checked := true; // Terrain
  mv.Source := msGoogleTerrain;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem21Click(Sender: TObject);

  Procedure AddLiteCacheToUserPoint(lc: TLiteCache);
  Var
    icon: integer;
    lat, lon: Double;
  Begin
    // Den Punkt als Userpoint anfügen
    icon := form1.CacheTypeToIconIndex(lc.G_Type);
    lat := lc.Lat;
    lon := lc.Lon;
    If (lc.Cor_Lat <> -1) And (lc.Cor_Lon <> -1) Then Begin
      lat := lc.Cor_Lat;
      lon := lc.Cor_Lon;
    End;
    mv.AddImageOnCoord(lon, lat,
      OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(icon) + ']'), // Das Bild
      Form1.ImageList1.Width, Form1.ImageList1.Height, // Die Dimensionen
      -Form1.ImageList1.Width Div 2, -Form1.ImageList1.Height Div 2, // Die Verschiebung
      '  ' + lc.GC_Code + ': ' + lc.G_Name,
      lc.GC_Code + ': ' + lc.G_Name);
  End;

Type
  data = Record
    lat, lon, clat, clon: Double;
    gc, n: String;
  End;
Var
  value, v: String;
  res: Array Of data;
  i: Integer;
  t: TLiteCacheArray;
Begin
  // Center at
  value := '';
  If InputQuery(R_Question, r_enter_search_text, false, value) Then Begin
    StartSQLQuery('Select distinct c.lat, c.lon, c.cor_lat, c.cor_lon, c.g_name, c.name from caches c where ' +
      'c.G_NAME like "%' + ToSQLString(trim(value)) + '%"' +
      'or c.name like "%' + ToSQLString(trim(value)) + '%"');
    res := Nil;
    If Not SQLQuery.EOF Then Begin
      setlength(res, SQLQuery.RecordCount);
      For i := 0 To SQLQuery.RecordCount - 1 Do Begin
        // Es gibt was zum auslesen
        res[i].lat := SQLQuery.Fields[0].AsFloat;
        res[i].lon := SQLQuery.Fields[1].AsFloat;
        res[i].clat := SQLQuery.Fields[2].AsFloat;
        res[i].clon := SQLQuery.Fields[3].AsFloat;
        res[i].n := SQLQuery.Fields[4].AsString;
        res[i].gc := SQLQuery.Fields[5].AsString;
        SQLQuery.Next;
      End;
    End;
    // Gibt es Lite Caches die Auf unsere Anfrage hin Reagieren ?
//    If CheckBox3.Checked Or CheckBox11.Checked Then Begin
    t := GetAllCachedCaches;
    For i := 0 To high(t) Do Begin
      If (pos(lowercase(trim(value)), lowercase(t[i].G_Name)) <> 0) Or
        (pos(lowercase(trim(value)), lowercase(t[i].GC_Code)) <> 0) Then Begin
        setlength(res, high(res) + 2);
        res[high(res)].lat := t[i].Lat;
        res[high(res)].lon := t[i].Lon;
        res[high(res)].clat := t[i].Cor_Lat;
        res[high(res)].clon := t[i].Cor_Lon;
        res[high(res)].n := t[i].G_Name;
        res[high(res)].gc := t[i].GC_Code;
      End;
    End;
    //    End;
    If length(res) > 1 Then Begin
      form39.caption := R_Select;
      form39.ListBox1.Clear;
      For i := 0 To high(res) Do Begin
        form39.ListBox1.Items.Add(res[i].gc + ': ' + res[i].n);
      End;
      form39.ListBox1.ItemIndex := 0;
      FormShowModal(form39, self);
      If form39.ModalResult = mrOK Then Begin
        res[0] := res[form39.ListBox1.ItemIndex];
      End
      Else Begin
        exit;
      End;
    End;
    If length(res) = 0 Then Begin
      // Nichts gefunden, wir versuchen das Ding als Lite Cache zu laden
      v := uppercase(trim(value));
      If pos('GC', v) <> 1 Then Begin
        v := 'GC' + v;
      End;
      If pos(' ', v) <> 0 Then Begin // Wenn jemand nach etwas mit 2 Worten sucht, kann das kein GC-Code Sein, dann können wir uns die aufwändige Anfrage sparen.
        t := Nil;
      End
      Else Begin
        t := GCTGetLiteCache(v);
      End;
      If assigned(t) Then Begin
        setlength(res, 1);
        res[high(res)].lat := t[0].Lat;
        res[high(res)].lon := t[0].Lon;
        res[high(res)].clat := t[0].Cor_Lat;
        res[high(res)].clon := t[0].Cor_Lon;
        res[high(res)].n := t[0].G_Name;
        res[high(res)].gc := t[0].GC_Code;
        AddLiteCacheToUserPoint(t[0]);
      End
      Else Begin
        // Nichts gefunden
        ShowMessage(format(RF_Error_could_not_find, [value]));
        exit;
      End;
    End;
    mv.Zoom := 14;
    If (res[0].clat <> -1) And (res[0].clon <> -1) Then Begin
      mv.CenterLongLat(res[0].clon, res[0].clat);
    End
    Else Begin
      mv.CenterLongLat(res[0].lon, res[0].lat);
    End;
    OpenGLControl1Paint(Nil);
  End;
End;

Procedure TForm15.MenuItem22Click(Sender: TObject);
Var
  m: TMemoryStream;
  i: integer;
  info: TImageInfoRecord;
  d: Double;
Begin
  // Export UserPointList
  If mv.ImageCount = 0 Then Begin
    showmessage(R_Error_No_Userpoints);
    exit;
  End;
  If SaveDialog2.Execute Then Begin
    m := TMemoryStream.Create;
    m.Write(UserPointFileVersion, sizeof(UserPointFileVersion));
    i := mv.ImageCount;
    m.Write(i, sizeof(i));
    For i := 0 To mv.ImageCount - 1 Do Begin
      info := mv.Image[i];
      d := info.x;
      m.Write(d, sizeof(d));
      d := info.y;
      m.Write(d, sizeof(d));
      m.WriteAnsiString(info.Label_); // wer weiß ob wir das mal brauchen...
    End;
    m.SaveToFile(SaveDialog2.FileName);
    m.free;
  End;
End;

Procedure TForm15.MenuItem24Click(Sender: TObject);
Var
  f: String;
  sl: TStringlist;
  c, i: Integer;
Begin
  // Empty Cache for Tiles
  f := GetMapCacheDir();
  sl := FindAllFiles(f, '*', false);
  c := 0;
  For i := 0 To sl.count - 1 Do Begin
    If Not DeleteFile(sl[i]) Then Begin
      showmessage(format(RF_Error_could_not_delete, [sl[i]]));
    End
    Else Begin
      inc(c);
    End;
  End;
  mv.EmptyTileCache;
  OpenGLControl1Paint(Nil);
  showmessage(format(RF_Finished_deleted_files, [c]));
End;

Procedure TForm15.MenuItem25Click(Sender: TObject);
Var
  value: String;
  lat, lon: Double;
  sa: TStringArray;
Begin
  // Center at coordinate
  value := '';
  If InputQuery(R_Question, r_enter_search_text, false, value) Then Begin
    value := trim(value);
    value := uppercase(value);
    If (pos('N', value) <> 0) Or (pos('S', value) <> 0) Then Begin
      // Annahme einer DEG Koordinate
      If Not StringToCoord(value, lat, lon) Then Begin
        showmessage(RF_Error_unable_to_decode_location);
        exit;
      End;
    End
    Else Begin
      // Annahme einer DEC Koordinate (wie sie von maps.google.com kommt :) )
      // Diese so umformatieren dass aus möglichst vielen Anfangsbedingungen
      // "Zahl","Zahl","Zahl","Zahl"
      // wird
      value := StringReplace(value, '.', ',', [rfReplaceAll]);
      value := StringReplace(value, ' ', ',', [rfReplaceAll]);
      While pos(',,', value) <> 0 Do Begin
        value := StringReplace(value, ',,', ',', [rfReplaceAll]);
      End;
      sa := value.Split(',');
      If length(sa) <> 4 Then Begin
        showmessage(RF_Error_unable_to_decode_location);
        exit;
      End;
      lat := StrToFloat(sa[0] + FormatSettings.DecimalSeparator + sa[1]);
      lon := StrToFloat(sa[2] + FormatSettings.DecimalSeparator + sa[3]);
    End;
    mv.Zoom := 14;
    mv.CenterLongLat(lon, lat);
    OpenGLControl1Paint(Nil);
  End;
End;

Procedure TForm15.MenuItem26Click(Sender: TObject);
Var
  m: TMemoryStream;
  fw: UInt32;
  cnt, i: integer;
  x, y: Double;
  sx, sy: Extended;
  s: String;
Begin
  // Import UserPointList
  If OpenDialog2.Execute Then Begin
    m := TMemoryStream.Create;
    m.LoadFromFile(OpenDialog2.FileName);
    fw := high(UInt32);
    m.Read(fw, sizeof(fw));
    If fw > UserPointFileVersion Then Begin
      showmessage(R_Error_invalid_Fileversion);
      m.free;
      exit;
    End;
    mv.ClearImagesOnCoords;
    cnt := 0;
    m.Read(cnt, sizeof(cnt));
    sx := 0;
    sy := 0;
    x := 0;
    y := 0;
    For i := 0 To cnt - 1 Do Begin
      m.Read(x, sizeof(x));
      m.Read(y, sizeof(y));
      s := m.ReadAnsiString(); // wer weiß ob wir das mal brauchen...
      sx := sx + x;
      sy := sy + y;
      AddUserPointAt(x, y);
    End;
    sx := sx / cnt;
    sy := sy / cnt;
    mv.Zoom := 14;
    mv.CenterLongLat(sx, sy);
    OpenGLControl1Paint(Nil);
    m.free;
  End;
End;

Procedure TForm15.MenuItem2Click(Sender: TObject);
Begin
  MenuItem1.Checked := false; // Normal
  MenuItem2.Checked := true; // Satellit
  MenuItem3.Checked := false; // Hybrid
  MenuItem20.Checked := false; // Terrain
  mv.Source := msGoogleSatellite;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem3Click(Sender: TObject);
Begin
  MenuItem1.Checked := false; // Normal
  MenuItem2.Checked := false; // Satellit
  MenuItem3.Checked := true; // Hybrid
  MenuItem20.Checked := false; // Terrain
  mv.Source := msGoogleHybrid;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem4Click(Sender: TObject);
Begin
  // Show Cachenames
  MenuItem4.Checked := Not MenuItem4.Checked;
  mv.ShowPointLabels := MenuItem4.Checked;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem62Click(Sender: TObject);
Var
  img_new, img: TImageInfoRecord;
  c, s: String;
Begin
  // Set Customer Flag
  If mv.GetImageAtXY(MoveX, MoveY, img) And (img.MetaInfo <> '') Then Begin
    If pos(':', img.MetaInfo) <> 0 Then Begin
      c := copy(img.MetaInfo, 1, pos(':', img.MetaInfo) - 1);
    End
    Else Begin
      c := img.MetaInfo;
    End;
    // Wir haben den GC-Code nun ists "einfach"
    CommitSQLTransactionQuery('Update caches set Customer_Flag=1 where name = "' + c + '"');
    SQLTransaction.Commit;
    // Die Karte Aktualisieren wir auch Gleich
    img_new := img;
    img_new.ImageIndex := OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(MainImageIndexCustomerFlag) + ']');
    mv.UpdateImage(img, img_new);
  End
  Else Begin
    c := GetSplashHint(MoveX, MoveY);
    If pos(':', c) <> 0 Then Begin
      s := c;
      c := copy(c, 1, pos(':', c) - 1);
      StartSQLQuery('select count(*) from caches where name like "' + c + '"');
      If SQLQuery.Fields[0].AsInteger = 0 Then Begin
        // Den Cache gibt es nicht in der Datenbank
        Showmessage(R_Error_you_have_to_download_the_cache_first);
      End
      Else Begin
        CommitSQLTransactionQuery('Update caches set Customer_Flag=1 where name = "' + c + '"');
        SQLTransaction.Commit;
        ChangeIconTo(s, MainImageIndexCustomerFlag);
      End;
    End;
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem63Click(Sender: TObject);
Var
  img_new, img: TImageInfoRecord;
  c, s: String;
  ic: integer;
Begin
  // Clear Customer Flag
  If mv.GetImageAtXY(MoveX, MoveY, img) And (img.MetaInfo <> '') Then Begin
    If pos(':', img.MetaInfo) <> 0 Then Begin
      c := copy(img.MetaInfo, 1, pos(':', img.MetaInfo) - 1);
    End
    Else Begin
      c := img.MetaInfo;
    End;
    // Wir haben den GC-Code nun ists "einfach"
    CommitSQLTransactionQuery('Update caches set Customer_Flag=0 where name = "' + c + '"');
    SQLTransaction.Commit;
    // Die Karte Aktualisieren wir auch Gleich
    img_new := img;
    ic := max(0, form1.CacheTypeToIconIndex(form1.CacheNameToCacheType(c)));
    img_new.ImageIndex := OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(ic) + ']');
    mv.UpdateImage(img, img_new);
  End
  Else Begin
    c := GetSplashHint(MoveX, MoveY);
    If pos(':', c) <> 0 Then Begin
      s := c;
      c := copy(c, 1, pos(':', c) - 1);
      StartSQLQuery('select count(*) from caches where name like "' + c + '"');
      If SQLQuery.Fields[0].AsInteger = 0 Then Begin
        // Den Cache gibt es nicht in der Datenbank => Nichts tun ...
      End
      Else Begin
        CommitSQLTransactionQuery('Update caches set Customer_Flag=0 where name = "' + c + '"');
        SQLTransaction.Commit;
        ResetIcon(s);
      End;
    End;
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.AddUserPointAt(lat, lon: Double);
Begin
  inc(UserPointCount);
  mv.AddImageOnCoord(lat, lon,
    OpenGL_GraphikEngine.Find('here.bmp'), // Das Bild
    32, 32, -16, -32, '  Userpoint ' + inttostr(UserPointCount), '');
End;

Function TForm15.GetSplashHint(x, y: integer): String;
Begin
  result := fOnlineViewer.Hint(x, y)
End;

Function TForm15.GetLabAt(x, y: integer): TLABCacheInfo;
Begin
  result := fOnlineViewer.GetLabAt(x, y);
End;

Procedure TForm15.ChangeIconTo(CacheHint: String; OpenGLIndex: integer);
Begin
  fOnlineViewer.ChangeIconTo(CacheHint, OpenGLIndex);
End;

Procedure TForm15.ResetIcon(CacheHint: String);
Begin
  fOnlineViewer.ResetIcon(CacheHint);
End;

Procedure TForm15.ResetAllIcons();
Begin
  fOnlineViewer.ResetAllIcons();
End;

Function TForm15.InitFormular(): boolean;
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

Function TForm15.GetCachedCacheCount(): TPoint;
Begin
  result := point(renderedCached, fOnlineViewer.CacheCount + fOnlineViewer.CacheLabCount);
End;

Procedure TForm15.RenderViewPort(vp: TViewport);
Begin
  renderedCached := fOnlineViewer.RenderViewPort(vp);
End;

Procedure TForm15.AddRoutePoint(x, y: integer);
Begin
  SetLength(fRoute, high(fRoute) + 2);
  froute[high(fRoute)] := form15.mv.GetMouseMapLongLat(x, y)
End;

Procedure TForm15.DelRoutePoint(x, y: integer);
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

Procedure TForm15.IncPointOrder(x, y: integer);
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

Procedure TForm15.DecPointOrder(x, y: integer);
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

Procedure TForm15.RenderRoutePoints(vp: TViewport);
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

Function TForm15.GetAllCachedCaches(): TLiteCacheArray;
Begin
  result := fOnlineViewer.GetAllCachedCaches();
End;

Function TForm15.GetAllCachesAround(vp: TViewport): TLiteCacheArray;
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

Procedure TForm15.ClearCaches();
Begin
  fOnlineViewer.ResetCache;
End;

Procedure TForm15.MenuItem6Click(Sender: TObject);
Var
  r: TVector2;
Begin
  // Add UserPoint
  r := mv.GetMouseMapLongLat(moveX, movey);
  form14.edit4.text := format('%2.6f', [r.X]);
  form14.edit3.text := format('%2.6f', [r.y]);
  form14.Button3.Click;
  form14.ReloadLocations;
  form14.GroupBox1.Enabled := false;
  FormShowModal(form14, self);
  form14.GroupBox1.Enabled := true;
  If (form14.Edit3.Text <> '') And (form14.Edit4.Text <> '') Then Begin
    AddUserPointAt(StrToFloat(form14.edit4.text), StrToFloat(form14.edit3.text));
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem7Click(Sender: TObject);
Var
  n, p: String;
  i: integer;
  x, y: Extended;
Begin
  // Show Locations
  For i := 0 To strtointdef(getValue('Locations', 'Count', '0'), 0) - 1 Do Begin
    n := GetValue('Locations', 'Name' + inttostr(i), '');
    p := GetValue('Locations', 'Place' + inttostr(i), '');
    y := StrToFloat(copy(p, 1, pos('x', p) - 1), DefFormat);
    x := StrToFloat(copy(p, pos('x', p) + 1, length(p)), DefFormat);
    mv.AddImageOnCoord(x, y,
      OpenGL_GraphikEngine.Find('here.bmp'), // Das Bild
      32, 32, -16, -32, '  ' + n, '');
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem8Click(Sender: TObject);
Begin
  mv.ReenableDownloading;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.MenuItem9Click(Sender: TObject);
Begin
  // Show 161m Ranges
  MenuItem9.Checked := Not MenuItem9.Checked;
  mv.show161Ranges := MenuItem9.Checked;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.OpenGLControl1DblClick(Sender: TObject);
Var
  li: TLABCacheInfo;
  img: TImageInfoRecord;
  s: String;
Begin
  If mv.GetImageAtXY(MoveX, MoveY, img) Then Begin
    If pos('userpoint ', lowercase(trim(img.Label_))) = 1 Then Begin
      form31.InitWithPoint(img.y, img.x);
      FormShowModal(form31, self);
    End
    Else Begin
      If (img.MetaInfo <> '') Then Begin
        // Die Metainfo besteht entweder nur aus dem GC-Code oder aus GC-Code:GC description
        If pos(':', img.MetaInfo) <> 0 Then Begin
          form13.OpenCache(copy(img.MetaInfo, 1, pos(':', img.MetaInfo) - 1));
        End
        Else Begin
          form13.OpenCache(img.MetaInfo);
        End;
        FormShowModal(form13, self);
      End;
    End;
  End
  Else Begin
    // Via Online suche
    s := GetSplashHint(MoveX, MoveY);
    If s <> '' Then Begin
      If pos(':', s) <> 0 Then Begin
        If pos('LAB', s) = 1 Then Begin
          li := GetLabAt(MoveX, MoveY);
          If li.Link <> '' Then Begin
            OpenURL(li.Link);
          End;
        End
        Else Begin
          OpenCacheInBrowser(copy(s, 1, pos(':', s) - 1));
        End;
      End
      Else Begin
        OpenCacheInBrowser(s);
      End;
    End
    Else Begin
      // Da liegt kein Cache, also Zoom in
      mv.ZoomInAtXY(MoveX, MoveY);
    End;
  End;
  OpenGLControl1Paint(Nil);
End;

Procedure TForm15.OpenGLControl1MakeCurrent(Sender: TObject; Var Allow: boolean
  );
Var
  s: String;
Begin
  inc(allowcnt);
  If allowcnt > 4 Then Begin
    allowcnt := 5;
    exit;
  End;
  // Sollen Dialoge beim Starten ausgeführt werden ist hier der Richtige Zeitpunkt
  If allowcnt = 1 Then Begin
    // Init dglOpenGL.pas , Teil 2
    ReadExtensions; // Anstatt der Extentions kann auch nur der Core geladen werden. ReadOpenGLCore;
    ReadImplementationProperties;
  End;
  If allowcnt >= 2 Then Begin // Dieses If Sorgt mit dem obigen dafür, dass der Code nur 1 mal ausgeführt wird.
    mv.MapLocalization := GetValue('General', 'MapLanguage', form1.getLang());
    mv.ProxyHost := getvalue('General', 'ProxyHost', '');
    mv.ProxyPass := getvalue('General', 'ProxyPass', '');
    mv.ProxyPort := getvalue('General', 'ProxyPort', '');
    mv.ProxyUser := getvalue('General', 'ProxyUser', '');
    mv.ClearImagesOnCoords;
    ClearCaches();
    (*
    Man bedenke, jedesmal wenn der Renderingcontext neu erstellt wird, müssen sämtliche Graphiken neu Geladen werden.
    Bei Nutzung der TOpenGLGraphikengine, bedeutet dies, das hier ein clear durchgeführt werden mus !!
    *)
    OpenGL_GraphikEngine.clear;
    s := GetImagesDir() + 'here.bmp';
    If OpenGL_GraphikEngine.LoadAlphaColorGraphik(s, ColorToRGB(clfuchsia)) = 0 Then Begin
      showmessage(format(RF_Error_could_not_load_userpoints_imageOpenGL_Errorcode, [s, glGetError(), gluErrorString(glGetError())]));
    End;
    glenable(GL_TEXTURE_2D); // Texturen
    Create_ASCII_Font;
    // Der Anwendung erlauben zu Rendern.
    Splashhint := '';
    Splashhint2 := '';
    Form15Initialized := True;
    CenterCaches(Nil);
    OpenGLControl1Resize(Nil);
    allowcnt := min(allowcnt, 4);
  End;
  If allowcnt < 4 Then Begin
{$IFNDEF DoNotInvalidateOpenGLWindow}
    Form15.Invalidate;
{$ENDIF}
  End;
End;

Procedure TForm15.OpenGLControl1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
  If CheckBox10.Checked Then Begin
    If RadioButton1.Checked Then Begin // Add Route Point
      AddRoutePoint(x, y);
    End;
    If RadioButton2.Checked Then Begin // Del Route Point
      delRoutePoint(x, y);
    End;
    If RadioButton3.Checked Then Begin // Inc Point Order
      IncPointOrder(x, y);
    End;
    If RadioButton4.Checked Then Begin // Dec Point Order
      DecPointOrder(x, y);
    End;
    OpenGLControl1Paint(Nil);
  End;
End;

Procedure TForm15.OpenGLControl1Paint(Sender: TObject);
Var
{$IFDEF DebuggMode}
  i: Cardinal;
  p: Pchar;
{$ENDIF}
  w, h: Single;
  vp: TViewport;
  pt: TVector2;
  txt: String;
Begin
  If Not Form15Initialized Then Exit;
  // Render Szene
  glClearColor(0.0, 0.0, 0.0, 0.0);
  glClear(GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity();
  mv.Render();
  //  If CheckBox3.Checked Or CheckBox11.Checked Then Begin
  pt := mv.GetMouseMapLongLat(0, 0);
  vp.Lon_min := pt.x;
  vp.Lat_min := pt.Y;
  pt := mv.GetMouseMapLongLat(OpenGLControl1.ClientWidth, OpenGLControl1.ClientHeight);
  vp.Lon_max := pt.x;
  vp.Lat_max := pt.Y;
  RenderViewPort(vp);
  RenderRoutePoints(vp);
  //  End;
  If (Splashhint <> '') Or (Splashhint2 <> '') Then Begin
    txt := Splashhint;
    If Splashhint2 <> '' Then txt := Splashhint2;
    Go2d(OpenGLControl1.Width, OpenGLControl1.Height);
    glColor4f(0, 0, 0, 0);
    glBindTexture(GL_TEXTURE_2D, 0); // Entladen des Texturspeichers
    w := OpenGL_ASCII_Font.TextWidth(txt);
    h := OpenGL_ASCII_Font.TextHeight(txt);
    glbegin(GL_QUADS);
    If MoveX + 15 + w > OpenGLControl1.Width Then Begin
      glVertex2f(MoveX - 10 - w, MoveY + 2.5);
      glVertex2f(MoveX - 10 - w, MoveY + 2.5 + h + 5);
      glVertex2f(MoveX, MoveY + 2.5 + h + 5);
      glVertex2f(MoveX, MoveY + 2.5);
      glend;
      OpenGL_ASCII_Font.Color := clwhite;
      OpenGL_ASCII_Font.Textout(MoveX - 5 - round(w), MoveY + 5, txt);
    End
    Else Begin
      glVertex2f(MoveX + 5, MoveY + 2.5);
      glVertex2f(MoveX + 5, MoveY + 2.5 + h + 5);
      glVertex2f(MoveX + 5 + w + 10, MoveY + 2.5 + h + 5);
      glVertex2f(MoveX + 5 + w + 10, MoveY + 2.5);
      glend;
      OpenGL_ASCII_Font.Color := clwhite;
      OpenGL_ASCII_Font.Textout(MoveX + 10, MoveY + 5, txt);
    End;
    Exit2d();
  End;
  OpenGLControl1.SwapBuffers;
{$IFDEF DebuggMode}
  i := glGetError();
  If i <> 0 Then Begin
    p := gluErrorString(i);
    showmessage(format(RF_OpenGLError, [i, p]));
    close;
  End;
{$ENDIF}
End;

Procedure TForm15.OpenGLControl1Resize(Sender: TObject);
Begin
  If Form15Initialized Then Begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glViewport(0, 0, OpenGLControl1.Width, OpenGLControl1.Height);
    gluPerspective(45.0, OpenGLControl1.Width / OpenGLControl1.Height, 0.1, 100.0);
    glMatrixMode(GL_MODELVIEW);
    OpenGLControl1Paint(Nil);
  End;
  button1.Left := OpenGLControl1.Left + OpenGLControl1.Width - Button1.Width - Scale96ToForm(8);
End;

Procedure TForm15.MergeLiteCachesToDB(Const Caches: TLiteCacheArray);
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

Procedure TForm15.MergeLabsCachesToDB(Const Labs: TLABCacheInfoArray);
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

Procedure TForm15.OnWaitEvent(Sender: TObject; Delay: Int64);
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

Procedure TForm15.CenterCaches(Sender: TObject);
Var
  p: TVector2;
  mip, map: TVector2;
  i: Integer;
  dx: Double;
  b: TBitmap;
  s: String;
  CacheInfos: Array Of TCacheInfo;
Begin
  If Not Form15Initialized Then exit;
  mv.ClearImagesOnCoords;
  UserPointCount := 0;
  b := TBitmap.Create;
  b.Width := Form1.ImageList1.Width;
  b.Height := Form1.ImageList1.Height;
  b.Transparent := false;
  // Erst mal die Icons aus Form1 in die Graphikengine laden
  For i := 0 To Form1.ImageList1.Count - 1 Do Begin
    b.canvas.brush.Color := clFuchsia;
    b.canvas.Rectangle(-1, -1, b.Width + 1, b.Height + 1);
    Form1.ImageList1.Draw(b.canvas, 0, 0, i);
    OpenGL_GraphikEngine.LoadAlphaColorGraphik(b, 'Form1.ImageList1.items[' + inttostr(i) + ']', ColorToRGB(clFuchsia));
  End;
  b.free;
  mip.X := 0;
  mip.Y := 0;
  map.X := 0;
  map.Y := 0;
  CacheInfos := Nil;
  setlength(CacheInfos, Form1.StringGrid1.RowCount - 1);
  For i := 1 To Form1.StringGrid1.RowCount - 1 Do Begin
    StartSQLQuery('Select lat, lon, cor_lat, cor_lon, g_type, g_name from caches where name = "' + Form1.StringGrid1.Cells[MainColGCCode, i] + '"');
    If SQLQuery.EOF Then Continue; // Wenn es die Dose nicht in der DB gibt wird sie Ignoriert.
    CacheInfos[i - 1].x := SQLQuery.Fields[0].AsFloat;
    CacheInfos[i - 1].y := SQLQuery.Fields[1].AsFloat;
    If (SQLQuery.Fields[2].AsFloat <> -1) And (SQLQuery.Fields[3].AsFloat <> -1) Then Begin
      CacheInfos[i - 1].x := SQLQuery.Fields[2].AsFloat;
      CacheInfos[i - 1].y := SQLQuery.Fields[3].AsFloat;
    End;
    If i = 1 Then Begin
      mip.X := CacheInfos[0].x;
      mip.Y := CacheInfos[0].y;
      map.X := CacheInfos[0].x;
      map.Y := CacheInfos[0].y;
    End
    Else Begin
      mip.X := min(CacheInfos[i - 1].x, mip.X);
      mip.Y := min(CacheInfos[i - 1].y, mip.y);
      map.X := max(CacheInfos[i - 1].x, map.X);
      map.Y := max(CacheInfos[i - 1].y, map.y);
    End;
    CacheInfos[i - 1].name := Form1.StringGrid1.Cells[MainColGCCode, i] + ': ' + FromSQLString(SQLQuery.Fields[5].AsString);
    // Achtung, die folgende Zeile macht ne neue Query auf, damit ist die oben gestellte anfrage ungültig, es darf nicht mehr auf SQLQuery.Fields zugergriffen werden !!
    CacheInfos[i - 1].icon := max(0, form1.CacheTypeToIconIndex(form1.CacheNameToCacheType(Form1.StringGrid1.Cells[MainColGCCode, i]))); // Wenn der Bildtyp unbekannt ist zeigen wir nen Tradi an.
    mv.AddImageOnCoord(
      CacheInfos[i - 1].y, CacheInfos[i - 1].x, // Die Position
      OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(CacheInfos[i - 1].icon) + ']'), // Das Bild
      Form1.ImageList1.Width, Form1.ImageList1.Height, // Die Dimensionen
      -Form1.ImageList1.Width Div 2, -Form1.ImageList1.Height Div 2, // Die Verschiebung
      CacheInfos[i - 1].name, Form1.StringGrid1.Cells[MainColGCCode, i] + ': ' + CacheInfos[i - 1].name);
  End;
  p.x := (mip.X + map.X) / 2;
  p.y := (mip.y + map.y) / 2;
  If (p.x = 0) And (p.y = 0) Then Begin
    // Der User hat offensichtlich gar keine Dose ausgewählt, oder keine Existierende, dann zentrieren wir auf der Home Location
    s := GetValue('Locations', 'Place' + getvalue('General', 'AktualLocation', ''), '');
    If s <> '' Then Begin
      p.x := strtofloat(copy(s, 1, pos('x', s) - 1), DefFormat);
      p.y := strtofloat(copy(s, pos('x', s) + 1, length(s)), DefFormat);
    End;
  End;
  // ACHTUNG ! der Zoom muss vor dem Center gesetzt werden, sonst geht es nicht !
  If high(CacheInfos) > 0 Then Begin
    dx := distance(mip.X, mip.Y, map.x, map.y);
    mv.Zoom := CalcZoomLevel(round(dx));
  End
  Else Begin
    mv.Zoom := 14;
  End;
  setlength(CacheInfos, 0);
  mv.CenterLongLat(p.y, p.x);
End;

Function TForm15.CalcZoomLevel(Distance: int64): integer;
Var
  d: Extended;
Begin
  // https://msdn.microsoft.com/en-us/library/bb259689.aspx
  result := 0;
  D := (Distance / (OpenGLControl1.Height / 1024)) / 1000; // Umrechnen Distance in Tiledistance in Meter
  If d < 78271.5170 Then result := 1;
  If d < 39135.7585 Then result := 2;
  If d < 19567.8792 Then result := 3;
  If d < 9783.9396 Then result := 4;
  If d < 4891.9698 Then result := 5;
  If d < 2445.9849 Then result := 6;
  If d < 1222.9925 Then result := 7;
  If d < 611.4962 Then result := 8;
  If d < 305.7481 Then result := 9;
  If d < 152.8741 Then result := 10;
  If d < 76.4370 Then result := 11;
  If d < 38.2185 Then result := 12;
  If d < 19.1093 Then result := 13;
  If d < 9.5546 Then result := 14;
  If d < 4.7773 Then result := 15;
  If d < 2.3887 Then result := 16;
  If d < 1.1943 Then result := 17;
  If d < 0.5972 Then result := 18;
  {
    // Der User kann so weit Rein Zoomen wenn er mag, automatisch ist bei 18 aber Schluß
    If d < 0.2986 Then result := 19;
    If d < 0.1493 Then result := 20;
    If d < 0.0746 Then result := 21;
    If d < 0.0373 Then result := 22;
    If d < 0.0187 Then result := 23;
  }
End;

End.

