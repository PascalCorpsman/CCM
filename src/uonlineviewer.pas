Unit uonlineviewer;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, uccm, ugctoolwrapper, OpenGLContext;

Const
  (*
   * Das Gitter in dem die Caches immer angefordert werden, je Größer es ist,
   * desto weniger Ladezeiten, allerdings bei mehr als 500 Caches pro Anfrage
   * muss diese Zerteilt werden => Ladezeit steigt.
   *)
  GridStep = 10;

Type

  TNormCoord = Record // Die Normierten Koordinaten in denen die Kartenteile geladen werden
    a, b: Integer;
  End;

  { TOnlineViewer }

  TOnlineViewer = Class
  private
    fCaches_All: Boolean;
    fCaches_Event: Boolean;
    fCaches_Exclude: Boolean;
    fCaches_Multi: Boolean;
    fCaches_Mystery: Boolean;
    fCaches_Tradi: Boolean;
    fHideFounds: Boolean;
    fHideOwn: Boolean;
    fOpenGLControl: TOpenGLControl; // Das OpenGLControl in dem Gerendert wird, dieses liefert die OnMouse* Events

    fLiteCaches: TLiteCacheArray;
    fLabs: TLABCacheInfoArray;
    fBlocks: Array Of TPoint; // Merker für die bereits geladenen Kartenblöcke
    fLABBlocks: Array Of TPoint; // Merker für die bereits geladenen Kartenblöcke
    Function GetCacheCount: integer;
    Function GetCacheLabCount: integer;
    Procedure RefreshCachesInBlock(x, y: integer);
    Procedure RefreshLABCachesInBlock(x, y: integer);
    Procedure Go2d(); // Todo: Ausbauen und den von umapviewer oder OpenGLAscii Font nehmen
    Procedure Exit2d(); // Todo: Ausbauen und den von umapviewer oder OpenGLAscii Font nehmen
    Procedure SetCaches_All(AValue: Boolean);
    Procedure SetCaches_Event(AValue: Boolean);
    Procedure SetCaches_Exclude(AValue: Boolean);
    Procedure SetCaches_Multi(AValue: Boolean);
    Procedure SetCaches_Mystery(AValue: Boolean);
    Procedure SetCaches_Tradi(AValue: Boolean);
    Procedure SetHideFounds(AValue: Boolean);
    Procedure SetHideOwn(AValue: Boolean);

  public
    EnableDownloading: Boolean; // Nur wenn True, wird überhaupt geladen
    EnableLABDownloading: Boolean; // Nur wenn True, wird überhaupt geladen
    Property CacheCount: integer read GetCacheCount;
    Property CacheLabCount: integer read GetCacheLabCount;
    (*
     * Cache Übergreifend
     *)
    Property HideOwn: Boolean read fHideOwn write SetHideOwn;
    Property HideFounds: Boolean read fHideFounds write SetHideFounds;
    (*
     * Cache Selectiv
     *)
    Property Caches_All: Boolean read fCaches_All write SetCaches_All;
    Property Caches_Exclude: Boolean read fCaches_Exclude write SetCaches_Exclude;
    Property Caches_Tradi: Boolean read fCaches_Tradi write SetCaches_Tradi;
    Property Caches_Multi: Boolean read fCaches_Multi write SetCaches_Multi;
    Property Caches_Mystery: Boolean read fCaches_Mystery write SetCaches_Mystery;
    Property Caches_Event: Boolean read fCaches_Event write SetCaches_Event;

    Constructor Create(Control: TOpenGLControl);
    Destructor Destroy; override;

    Function Hint(x, y: integer): String; // Gibt den Cache Hint zur gegebenen Koordinate in Pixel
    Function GetLabAt(x, y: integer): TLABCacheInfo; // Gibt den Labcache an gegebenen Koordinate in Pixel
    Procedure ChangeIconTo(HintText: String; OpenGLIconIndex: Integer);
    Procedure ResetIcon(HintText: String);
    Procedure ResetAllIcons();

    Function RenderViewPort(vp: TViewport): integer; // Rendert und lädt ggf alle caches in Viewport nach, result = anzahl der gesamt angezeigten dosen.
    Procedure ResetCache; // Löscht alle internen Puffer, wird auch bei einer Änderung von Suchparametern aufgerufen

    Function GetAllCachedCaches(): TLiteCacheArray; // Gibt alle bisher geladenen Caches zurück
    Function GetAllVisibleCaches(vp: TViewport): TLiteCacheArray; // Gibt nur die Caches zurück, welche im Sichtfeld sind

    Function GetAllLABsCaches(): TLABCacheInfoArray; // Gibt alle bisher geladenen LABs zurück
    Function GetAllVisibleLabs(vp: TViewport): TLABCacheInfoArray; // Gibt nur die LABs zurück, welche im Sichtfeld sind

    Procedure DownloadViewPort(vp: TViewport); // Lädt alles innerhalb des Viewports und der Suchparameter durch.
    Procedure DownloadLABViewPort(vp: TViewport); // Lädt alles innerhalb des Viewports und der Suchparameter durch.
  End;

Implementation

Uses
  unit1, // TODO: das sollte irgendwie wieder raus, ist wegen form1.CacheTypeToIconIndex drin
  umapviewer, dglOpenGL, math, uopengl_graphikengine;

Function sgn(value: integer): integer; // Wie Sign nur das die 0 auch =1 ist und damit dann Multipliziert werden kann...
Begin
  If value < 0 Then Begin
    result := -1;
  End
  Else Begin
    result := 1;
  End;
End;

(*
 * Rechnet eine Coordinate im DEC Format, um in DEG und Projeziert es dann
 * je nach Shrink auf die nächst höhere oder niedrigere Koordinate in  000 05 000 Schritten
 *)

Function CoordToNormalizedCoord(Coord: Double; Shrink: Boolean): TNormCoord;
Var
  a, b, c: String;
  nc: TNormCoord;
Begin
  If coord < 0 Then Begin
    // Da N/S, E/W an der 0 Spiegeln, machen wir das hier auch ;-)
    nc := CoordToNormalizedCoord(-Coord, Not Shrink);
    result.a := -nc.a;
    result.b := -nc.b;
  End
  Else Begin
    If Coord = 0 Then Begin
      If Shrink Then Begin
        result.a := 0;
        result.b := 0;
      End
      Else Begin
        result.a := 0;
        result.b := -GridStep;
      End;
    End
    Else Begin
      DecodeKoordinate(coord, a, b, c);
      result.a := strtoint(a);
      result.b := strtoint(b);
      If Shrink Then Begin
        // Bildet alles mit Rest [0..GridStep[ auf 0 ab
        result.b := result.b - (result.b Mod GridStep);
      End
      Else Begin
        // Bildet alles mit Rest [0..GridStep[ auf GridStep ab
        result.b := result.b + (GridStep - result.b Mod GridStep);
        If (result.b >= 60) Then Begin
          result.b := result.b - 60;
          inc(result.a);
        End;
      End;
    End;
  End;
End;

{ TOnlineViewer }

Procedure TOnlineViewer.RefreshCachesInBlock(x, y: integer);
Var
  i: Integer;
  a, b, c: integer;
  vp: TViewport;
  arr: TLiteCacheArray;
  sp: TSearchParams;
  s: String;
  retries: Integer;
  Valid: Boolean;
Begin
  // 1. Haben wir diesen Block schon mal geladen ?
  For i := 0 To high(fBlocks) Do Begin
    If (fBlocks[i].x = x) And (fBlocks[i].y = y) Then Begin
      exit;
    End;
  End;
  // 2. Den Block Brauchen wir noch also laden wir ihn
  // Links
  a := (x Div 100000);
  b := ((abs(x) Div 1000) Mod 100) * sgn(x); // Mod und negative Zahlen ist übel
  c := abs(x) Mod 1000;
  EncodeKoordinate(vp.Lat_min, inttostr(a), inttostr(b), inttostr(c));
  // Rechts
  b := b + GridStep;
  If b = 60 Then Begin
    b := b - 60;
    inc(a);
  End;
  EncodeKoordinate(vp.Lat_max, inttostr(a), inttostr(b), inttostr(c));
  // Oben
  a := (y Div 100000);
  b := ((abs(y) Div 1000) Mod 100) * sgn(y); // Mod und negative Zahlen ist übel
  c := abs(y) Mod 1000;
  EncodeKoordinate(vp.Lon_min, inttostr(a), inttostr(b), inttostr(c));
  // Unten
  b := b + GridStep;
  If b = 60 Then Begin
    b := b - 60;
    inc(a);
  End;
  EncodeKoordinate(vp.Lon_max, inttostr(a), inttostr(b), inttostr(c));
  // Die Suchparameter
  sp.Ho := HideOwn;
  sp.Hf := HideFounds;
  sp.All := fCaches_All;
  sp.Exclude := fCaches_Exclude;
  sp.Tradi := fCaches_Tradi;
  sp.Multi := fCaches_Multi;
  sp.Mystery := fCaches_Mystery;
  sp.Event := fCaches_Event;
  // Suche starten
  (*
   * Es sieht so als als würde der GC-Server hin und wieder keine Lust mehr haben zu antworten
   * => Wenn dem der Fall ist, dann bleibt Valid auf False und wir warten ein bischen und versuchen es wieder
   *    Wenn an der angefragten Stelle tatsächlich keine Caches Liegen bleibt Arr = Nil, aber Valid wird True
   *    Damit wird in dieser Situation nicht unnötig gewartet.
   *)
  retries := 10; // -- Keine Ahnung wie viel da Sinnvoll ist, aber es scheint als sei die Kombination aus Warten und wieder Versuchen Ausreichend...
  Valid := false;
  While (retries > 0) And (Not Valid) Do Begin
    arr := GCTsearchMap(vp, sp, Valid);
    If Not Valid Then Begin
      sleep(5000);
    End;
    dec(retries);
  End;
  // Alles geladene merken
  setlength(fBlocks, high(fBlocks) + 2);
  fBlocks[high(fBlocks)] := point(x, y);
  c := length(fLiteCaches);
  setlength(fLiteCaches, c + length(arr));
  For b := 0 To high(arr) Do Begin
    fLiteCaches[c + b] := arr[b];
    // Berechnen des RenderIconIndex
    s := arr[b].G_Type;
    If (arr[b].Cor_Lat <> -1) And (arr[b].Cor_Lon <> -1) Then Begin
      s := AddCacheTypeSpezifier(s, 'C');
    End;
    If (arr[b].G_Found <> 0) Then Begin
      s := AddCacheTypeSpezifier(s, 'F');
    End;
    // Die D/T Wertung geht in die Iconfindung nicht ein, also kann sie auch Ignoriert werden
    // s := s + format('|%fx%f', [SQLQuery1.Fields[7].AsFloat, SQLQuery1.Fields[8].AsFloat], DefFormat);
    fLiteCaches[c + b].RenderIconIndex := form1.CacheTypeToIconIndex(s);
    fLiteCaches[c + b].OldRenderIconIndex := form1.CacheTypeToIconIndex(s);
  End;
  setlength(arr, 0);
End;

Procedure TOnlineViewer.RefreshLABCachesInBlock(x, y: integer);
Var
  i, j: Integer;
  a, b, c: integer;
  vp: TViewport;
  lat, lon: Double;
  arr: TLABCacheInfoArray;
  sp: TSearchParams;
  s: String;
  bool: Boolean;
Begin
  // 1. Haben wir diesen Block schon mal geladen ?
  For i := 0 To high(fLABBlocks) Do Begin
    If (fLABBlocks[i].x = x) And (fLABBlocks[i].y = y) Then Begin
      exit;
    End;
  End;
  // 2. Den Block Brauchen wir noch also laden wir ihn
  // Links
  a := (x Div 100000);
  b := ((abs(x) Div 1000) Mod 100) * sgn(x); // Mod und negative Zahlen ist übel
  c := abs(x) Mod 1000;
  EncodeKoordinate(vp.Lat_min, inttostr(a), inttostr(b), inttostr(c));
  // Rechts
  b := b + GridStep;
  If b = 60 Then Begin
    b := b - 60;
    inc(a);
  End;
  EncodeKoordinate(vp.Lat_max, inttostr(a), inttostr(b), inttostr(c));
  // Oben
  a := (y Div 100000);
  b := ((abs(y) Div 1000) Mod 100) * sgn(y); // Mod und negative Zahlen ist übel
  c := abs(y) Mod 1000;
  EncodeKoordinate(vp.Lon_min, inttostr(a), inttostr(b), inttostr(c));
  // Unten
  b := b + GridStep;
  If b = 60 Then Begin
    b := b - 60;
    inc(a);
  End;
  EncodeKoordinate(vp.Lon_max, inttostr(a), inttostr(b), inttostr(c));
  lat := (vp.Lat_min + vp.Lat_max) / 2;
  lon := (vp.Lon_min + vp.Lon_max) / 2;
  // Die Suchparameter
  sp.Ho := HideOwn;
  sp.Hf := HideFounds;
  sp.All := fCaches_All; // -- Ist Quatsch gibts net
  sp.Exclude := fCaches_Exclude; // -- Ist Quatsch gibts net
  sp.Tradi := fCaches_Tradi; // -- Ist Quatsch gibts net
  sp.Multi := fCaches_Multi; // -- Ist Quatsch gibts net
  sp.Mystery := fCaches_Mystery; // -- Ist Quatsch gibts net
  sp.Event := fCaches_Event; // -- Ist Quatsch gibts net
  // Suche starten
  arr := GCTsearchLabsNear(lat, lon, sp);
  // Alles geladene merken
  setlength(fLABBlocks, high(fLABBlocks) + 2);
  fLABBlocks[high(fLABBlocks)] := point(x, y);
  c := length(fLabs);
  For i := 0 To high(arr) Do Begin
    bool := true;
    For j := 0 To c - 1 Do Begin // Alle die nach "c" stehen werden durch den Aktuellen "Batch" hinzugefügt und sind daher definitiv nicht doppelt.
      If fLabs[j].Link = arr[i].Link Then Begin
        bool := false;
        break;
      End;
    End;
    If bool Then Begin
      setlength(fLabs, high(fLabs) + 2);
      flabs[high(fLabs)] := arr[i];
      // Berechnen des RenderIconIndex
      s := Geocache_Lab_Cache;
      If (arr[i].isCompleted) Then Begin
        s := AddCacheTypeSpezifier(s, 'F');
      End;
      // Die D/T Wertung geht in die Iconfindung nicht ein, also kann sie auch Ignoriert werden
      // s := s + format('|%fx%f', [SQLQuery1.Fields[7].AsFloat, SQLQuery1.Fields[8].AsFloat], DefFormat);
      fLabs[high(fLabs)].RenderIconIndex := form1.CacheTypeToIconIndex(s);
      fLabs[high(fLabs)].OldRenderIconIndex := form1.CacheTypeToIconIndex(s);
    End;
  End;
  setlength(arr, 0);
End;

Function TOnlineViewer.GetCacheCount: integer;
Begin
  result := length(fLiteCaches);
End;

Function TOnlineViewer.GetCacheLabCount: integer;
Begin
  result := length(fLabs);
End;

Procedure TOnlineViewer.Go2d();
Begin
  glMatrixMode(GL_PROJECTION);
  glPushMatrix(); // Store The Projection Matrix
  glLoadIdentity(); // Reset The Projection Matrix
  glOrtho(0, fOpenGLControl.Width, fOpenGLControl.height, 0, -1, 1); // Set Up An Ortho Screen
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix(); // Store old Modelview Matrix
  glLoadIdentity(); // Reset The Modelview Matrix
End;

Procedure TOnlineViewer.Exit2d();
Begin
  glMatrixMode(GL_PROJECTION);
  glPopMatrix(); // Restore old Projection Matrix
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix(); // Restore old Projection Matrix
End;

Procedure TOnlineViewer.SetCaches_All(AValue: Boolean);
Begin
  If fCaches_All = AValue Then Exit;
  fCaches_All := AValue;
  ResetCache();
End;

Procedure TOnlineViewer.SetCaches_Event(AValue: Boolean);
Begin
  If fCaches_Event = AValue Then Exit;
  fCaches_Event := AValue;
  ResetCache();
End;

Procedure TOnlineViewer.SetCaches_Exclude(AValue: Boolean);
Begin
  If fCaches_Exclude = AValue Then Exit;
  fCaches_Exclude := AValue;
  ResetCache();
End;

Procedure TOnlineViewer.SetCaches_Multi(AValue: Boolean);
Begin
  If fCaches_Multi = AValue Then Exit;
  fCaches_Multi := AValue;
  ResetCache();
End;

Procedure TOnlineViewer.SetCaches_Mystery(AValue: Boolean);
Begin
  If fCaches_Mystery = AValue Then Exit;
  fCaches_Mystery := AValue;
  ResetCache();
End;

Procedure TOnlineViewer.SetCaches_Tradi(AValue: Boolean);
Begin
  If fCaches_Tradi = AValue Then Exit;
  fCaches_Tradi := AValue;
  ResetCache();
End;

Procedure TOnlineViewer.SetHideFounds(AValue: Boolean);
Begin
  If fHideFounds = AValue Then Exit;
  fHideFounds := AValue;
  ResetCache();
End;

Procedure TOnlineViewer.SetHideOwn(AValue: Boolean);
Begin
  If fHideOwn = AValue Then Exit;
  fHideOwn := AValue;
  ResetCache();
End;

Constructor TOnlineViewer.Create(Control: TOpenGLControl);
Begin
  Inherited create();
  ResetCache;
  fOpenGLControl := Control;
  fHideOwn := true;
  fHideFounds := true;
  EnableDownloading := false;
End;

Destructor TOnlineViewer.Destroy;
Begin
  ResetCache;
End;

Function TOnlineViewer.Hint(x, y: integer): String;
Var
  i: Integer;
Begin
  result := '';
  For i := 0 To high(fLiteCaches) Do Begin
    If (fLiteCaches[i].x <> -1) And (fLiteCaches[i].y <> -1) Then Begin
      If PointInRect(point(x, y), rect(fLiteCaches[i].x, fLiteCaches[i].y, fLiteCaches[i].x + 16, fLiteCaches[i].y + 16)) Then Begin
        result := fLiteCaches[i].GC_Code + ': ' + fLiteCaches[i].G_Name; // ! ACHTUNG ! das ist ein String, der in Form15.OpenCacheInBrowser genutzt wird.
        exit;
      End;
    End;
  End;
  For i := 0 To high(fLabs) Do Begin
    If (fLabs[i].x <> -1) And (fLabs[i].y <> -1) Then Begin
      If PointInRect(point(x, y), rect(fLabs[i].x, fLabs[i].y, fLabs[i].x + 16, fLabs[i].y + 16)) Then Begin
        result := 'LAB: ' + fLabs[i].Title; // ! ACHTUNG ! das ist ein String, der in Form15.OpenCacheInBrowser genutzt wird.
        exit;
      End;
    End;
  End;
End;

Function TOnlineViewer.GetLabAt(x, y: integer): TLABCacheInfo;
Var
  i: Integer;
Begin
  result.Link := '';
  result.ID := '';
  For i := 0 To high(fLabs) Do Begin
    If (fLabs[i].x <> -1) And (fLabs[i].y <> -1) Then Begin
      If PointInRect(point(x, y), rect(fLabs[i].x, fLabs[i].y, fLabs[i].x + 16, fLabs[i].y + 16)) Then Begin
        result := fLabs[i];
        exit;
      End;
    End;
  End;
End;

Procedure TOnlineViewer.ChangeIconTo(HintText: String; OpenGLIconIndex: Integer
  );
Var
  i: Integer;
Begin
  For i := 0 To high(fLiteCaches) Do Begin
    If fLiteCaches[i].GC_Code + ': ' + fLiteCaches[i].G_Name = HintText Then Begin
      fLiteCaches[i].RenderIconIndex := OpenGLIconIndex;
      break;
    End;
  End;
End;

Procedure TOnlineViewer.ResetIcon(HintText: String);
Var
  i: Integer;
Begin
  For i := 0 To high(fLiteCaches) Do Begin
    If fLiteCaches[i].GC_Code + ': ' + fLiteCaches[i].G_Name = HintText Then Begin
      fLiteCaches[i].RenderIconIndex := fLiteCaches[i].OldRenderIconIndex;
      break;
    End;
  End;
  For i := 0 To high(fLabs) Do Begin
    If 'LAB: ' + fLabs[i].Title = HintText Then Begin
      fLabs[i].RenderIconIndex := fLabs[i].OldRenderIconIndex;
      break;
    End;
  End;
End;

Procedure TOnlineViewer.ResetAllIcons();
Var
  i: Integer;
Begin
  For i := 0 To high(fLiteCaches) Do Begin
    fLiteCaches[i].RenderIconIndex := fLiteCaches[i].OldRenderIconIndex;
  End;
End;

Function TOnlineViewer.RenderViewPort(vp: TViewport): integer;
Var
  xc, yc, i: integer;
  b: {$IFDEF USE_GL}Byte{$ELSE}Boolean{$ENDIF};
Begin
  result := 0;
  If EnableDownloading Then Begin
    DownloadViewPort(vp);
  End;
  If EnableLABDownloading Then Begin
    DownloadLabViewPort(vp);
  End;
  // Alle Dosen sind vorhanden, also rendern wir sie
  Go2d();
  For i := 0 To high(fLiteCaches) Do Begin
    // Der Cache ist Sichtbar
    If (fLiteCaches[i].Lat >= min(vp.Lat_min, vp.Lat_max)) And
      (fLiteCaches[i].Lat <= Max(vp.Lat_min, vp.Lat_max)) And
      (fLiteCaches[i].Lon >= min(vp.Lon_min, vp.Lon_max)) And
      (fLiteCaches[i].Lon <= Max(vp.Lon_min, vp.Lon_max)) Then Begin
      inc(result);
      yc := convert_dimension(vp.Lat_min, vp.Lat_max, fLiteCaches[i].Lat, 0, fOpenGLControl.ClientHeight) - 8; // Das Offset Zentriert die Dose an der Listing Coordinate und schon sieht man nicht das bei Aktiver DB da 2 Symbole Gleichzeitig sind :-)
      xc := convert_dimension(vp.Lon_min, vp.Lon_max, fLiteCaches[i].Lon, 0, fOpenGLControl.Clientwidth) - 8; // Das Offset Zentriert die Dose an der Listing Coordinate und schon sieht man nicht das bei Aktiver DB da 2 Symbole Gleichzeitig sind :-)
      fLiteCaches[i].x := xc;
      fLiteCaches[i].y := yc;
      B := glIsEnabled(gl_Blend);
      If Not (b{$IFDEF USE_GL} = 1{$ENDIF}) Then
        glenable(gl_Blend);
      glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
      glColor3d(1, 1, 1);
      glBindTexture(GL_TEXTURE_2D, OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(fLiteCaches[i].RenderIconIndex) + ']', true));
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
    End
    Else Begin
      fLiteCaches[i].x := -1;
      fLiteCaches[i].y := -1;
    End;
  End;
  For i := 0 To high(fLabs) Do Begin
    // Der Cache ist Sichtbar
    If (fLabs[i].Lat >= min(vp.Lat_min, vp.Lat_max)) And
      (fLabs[i].Lat <= Max(vp.Lat_min, vp.Lat_max)) And
      (fLabs[i].Lon >= min(vp.Lon_min, vp.Lon_max)) And
      (fLabs[i].Lon <= Max(vp.Lon_min, vp.Lon_max)) Then Begin
      inc(result);
      yc := convert_dimension(vp.Lat_min, vp.Lat_max, fLabs[i].Lat, 0, fOpenGLControl.ClientHeight) - 8; // Das Offset Zentriert die Dose an der Listing Coordinate und schon sieht man nicht das bei Aktiver DB da 2 Symbole Gleichzeitig sind :-)
      xc := convert_dimension(vp.Lon_min, vp.Lon_max, fLabs[i].Lon, 0, fOpenGLControl.Clientwidth) - 8; // Das Offset Zentriert die Dose an der Listing Coordinate und schon sieht man nicht das bei Aktiver DB da 2 Symbole Gleichzeitig sind :-)
      fLabs[i].x := xc;
      fLabs[i].y := yc;
      B := glIsEnabled(gl_Blend);
      If Not (b{$IFDEF USE_GL} = 1{$ENDIF}) Then
        glenable(gl_Blend);
      glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
      glColor3d(1, 1, 1);
      glBindTexture(GL_TEXTURE_2D, OpenGL_GraphikEngine.Find('Form1.ImageList1.items[' + inttostr(fLabs[i].RenderIconIndex) + ']', true));
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
    End
    Else Begin
      fLabs[i].x := -1;
      fLabs[i].y := -1;
    End;
  End;
  Exit2d();
End;

Procedure TOnlineViewer.ResetCache;
Begin
  fBlocks := Nil;
  fLABBlocks := Nil;
  fLabs := Nil;
  fLiteCaches := Nil;
End;

Function TOnlineViewer.GetAllCachedCaches(): TLiteCacheArray;
Var
  i: integer;
Begin
  result := Nil;
  setlength(result, length(fLiteCaches));
  For i := 0 To high(result) Do Begin
    result[i] := fLiteCaches[i];
  End;
End;

Function TOnlineViewer.GetAllVisibleCaches(vp: TViewport): TLiteCacheArray;
Var
  c, i: integer;
Begin
  result := Nil;
  setlength(result, length(fLiteCaches));
  c := 0;
  For i := 0 To high(result) Do Begin
    If (fLiteCaches[i].Lat >= min(vp.Lat_min, vp.Lat_max)) And
      (fLiteCaches[i].Lat <= Max(vp.Lat_min, vp.Lat_max)) And
      (fLiteCaches[i].Lon >= min(vp.Lon_min, vp.Lon_max)) And
      (fLiteCaches[i].Lon <= Max(vp.Lon_min, vp.Lon_max)) Then Begin
      result[c] := fLiteCaches[i];
      inc(c);
    End;
  End;
  setlength(result, c);
End;

Function TOnlineViewer.GetAllLABsCaches(): TLABCacheInfoArray;
Var
  i: integer;
Begin
  result := Nil;
  setlength(result, length(fLabs));
  For i := 0 To high(result) Do Begin
    result[i] := fLabs[i];
  End;
End;

Function TOnlineViewer.GetAllVisibleLabs(vp: TViewport): TLABCacheInfoArray;
Var
  c, i: integer;
Begin
  result := Nil;
  setlength(result, length(fLabs));
  c := 0;
  For i := 0 To high(result) Do Begin
    If (fLabs[i].Lat >= min(vp.Lat_min, vp.Lat_max)) And
      (fLabs[i].Lat <= Max(vp.Lat_min, vp.Lat_max)) And
      (fLabs[i].Lon >= min(vp.Lon_min, vp.Lon_max)) And
      (fLabs[i].Lon <= Max(vp.Lon_min, vp.Lon_max)) Then Begin
      result[c] := fLabs[i];
      inc(c);
    End;
  End;
  setlength(result, c);
End;

Procedure TOnlineViewer.DownloadViewPort(vp: TViewport);
Var
  latmin, latmax, lonMin, LonMax: TNormCoord;
  lat, lon, lonmi, lonma, latmi, latma: integer;
Begin
  // 1. Wir Zerlegen den Viewport so, dass wir ihn
  latmin := CoordToNormalizedCoord(min(vp.Lat_min, vp.Lat_max), True);
  latmax := CoordToNormalizedCoord(max(vp.Lat_min, vp.Lat_max), false);
  lonmin := CoordToNormalizedCoord(min(vp.Lon_min, vp.Lon_max), True);
  lonmax := CoordToNormalizedCoord(max(vp.Lon_min, vp.Lon_max), false);
  // Nun da wir die "Normierten" Koordinaten haben, hohlen wir uns mal die Dosen dazu.
  latmi := latmin.a * 100000 + latmin.b * 1000;
  latma := latmax.a * 100000 + latmax.b * 1000;
  lonmi := lonmin.a * 100000 + lonmin.b * 1000;
  lonma := lonmax.a * 100000 + lonmax.b * 1000;
  lon := lonmi;
  While lon < lonma Do Begin
    lat := latmi;
    While lat < latma Do Begin
      RefreshCachesInBlock(lat, lon);
      lat := lat + GridStep * 1000;
      If (abs(lat) Mod 100000) >= 60000 Then Begin // die 10000 Koordinate läuft von 0.59 also muss sie bei 60 um 40 erhöht werden
        lat := lat + 40000;
      End;
    End;
    lon := lon + GridStep * 1000;
    If (abs(lon) Mod 100000) >= 60000 Then Begin // die 10000 Koordinate läuft von 0.59 also muss sie bei 60 um 40 erhöht werden
      lon := lon + 40000;
    End;
  End;
End;

Procedure TOnlineViewer.DownloadLABViewPort(vp: TViewport);
Var
  latmin, latmax, lonMin, LonMax: TNormCoord;
  lat, lon, lonmi, lonma, latmi, latma: integer;
Begin
  // 1. Wir Zerlegen den Viewport so, dass wir ihn
  latmin := CoordToNormalizedCoord(min(vp.Lat_min, vp.Lat_max), True);
  latmax := CoordToNormalizedCoord(max(vp.Lat_min, vp.Lat_max), false);
  lonmin := CoordToNormalizedCoord(min(vp.Lon_min, vp.Lon_max), True);
  lonmax := CoordToNormalizedCoord(max(vp.Lon_min, vp.Lon_max), false);
  // Nun da wir die "Normierten" Koordinaten haben, hohlen wir uns mal die Dosen dazu.
  latmi := latmin.a * 100000 + latmin.b * 1000;
  latma := latmax.a * 100000 + latmax.b * 1000;
  lonmi := lonmin.a * 100000 + lonmin.b * 1000;
  lonma := lonmax.a * 100000 + lonmax.b * 1000;
  lon := lonmi;
  While lon < lonma Do Begin
    lat := latmi;
    While lat < latma Do Begin
      RefreshLABCachesInBlock(lat, lon);
      lat := lat + GridStep * 1000;
      If (abs(lat) Mod 100000) >= 60000 Then Begin // die 10000 Koordinate läuft von 0.59 also muss sie bei 60 um 40 erhöht werden
        lat := lat + 40000;
      End;
    End;
    lon := lon + GridStep * 1000;
    If (abs(lon) Mod 100000) >= 60000 Then Begin // die 10000 Koordinate läuft von 0.59 also muss sie bei 60 um 40 erhöht werden
      lon := lon + 40000;
    End;
  End;
End;

End.

