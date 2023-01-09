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
Unit ugctoolwrapper;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, uccm, ulanguage, ugctool, Dialogs;

Type
  TTravelbugRecord = ugctool.TTravelbugRecord;
  TTBLogState = ugctool.TTBLogState;
  TPocketQueries = ugctool.TPocketQueries;
  TServerParameters = ugctool.TServerParameters;
  TLiteCache = ugctool.TLiteCache;
  TLiteCacheArray = ugctool.TLiteCacheArray;
  TLABCacheInfo = ugctool.TLABCacheInfo;
  TLABCacheInfoArray = ugctool.TLABCacheInfoArray;
  TSearchParams = ugctool.TSearchParams;
  TUserNoteCoord = ugctool.TUserNoteCoord;
  TUserNoteResult = ugctool.TUserNoteResult;

  (*
   * Es werden die Reinen Funktionen bereit gestellt, der Rest drumrum wird
   * von der Unit erledigt.
   *)

Procedure GCTLogOut; // Nur für die Optionen, sonst nicht aufrufen !!!

(*
 * Loggt einen Cache
 *)
Function GCTLogOnline(Const Log: TFieldNote): Boolean;

(*
 * Ermittelt die Funde Nummer
 *)
Function GCTGetFoundNumber(Out Founds: integer): Boolean;

(*
 * Discovert einen TB
 *)
Function GCTDiscoverTb(tb: TTravelbugRecord): Boolean;

(*
 * Ermittelt den TBLogRecord
 *)
Function GCTGetTBLogRecord(TBCode: String; Out tb: TTravelbugRecord): Boolean;

(*
 * Ermittelt alle Pocket Queries, welche reade Downloadbar sind
 *)
Function GCTGetPocketQueries(Out PQ: TPocketQueries): Boolean;

(*
 * Lädt eine Datei Herunter (und loggt sich vorher ein)
 *)

Function GCTDownloadFile(Link: String; DestFilename: String; SupressError: Boolean = false): Boolean;

(*
 * Lädt die gpx Datei eines Caches herunter und legt sie unter DestFilename ab.
 *)
Function GCTDownloadCacheGPX(GC_Code: String; DestFilename: String; Silent: Boolean): Boolean;

(*
 * Lädt die Spoilerbilder zu einem Gegebenen GC-Code Heruter
 *)
Function GCTDownloadSpoiler(GC_Code: String): integer;

(*
 * Gibt an ob der Cache bereits gefunden wurde oder nicht
 *)
Function GCTGetCacheInfo(GC_Code: String): TCacheInfo;

(*
 * Gibt die Anzahl der zu Vergebenden Fav Punkte an
 *)
Function GCTGetAvailableFavs(): integer;

(*
 * Gibt den letzten Fehler des GCTools zurück
 *)
Function GCTGetLastError(): String;

(*
 * Gibt Infos über den Cacher, z.B. Premium oder nicht ..
 *)
Function GCTGetServerParams(): TServerParameters;

(*
 * Gibt gemäß den SP Suchparametern alle Caches innerhalb Viewport als LiteCaches zurück
 *)
Function GCTsearchMap(VP: TViewport; SP: TSearchParams; Out DataValid: Boolean): TLiteCacheArray;

(*
 * Gibt die LABS in der "Nähe" von lat / lon als Ladbare Liste zurück
 *)
Function GCTsearchLabsNear(Lat, Lon: Single; SP: TSearchParams): TLABCacheInfoArray;

(*
 * Lädt eine Lab-Cache herunter
 * Wenn WPsAsCache = True, dann werden alle Wegpunkte als Separater Cache gespeichert
 *                 = false, dann ist das Ergebnis nur 1 Cache mit vielen Wegpunkten
 *)
Function GCTDownloadLAB(LAB: TLABCacheInfo; WPsAsCache: Boolean): TCacheArray;

(*
 * Gibt entweder NIL oder genau einen Litecache zurück
 *)
Function GCTGetLiteCache(GC_Code: String): TLiteCacheArray;

(*
 * Ermittelt die UserNote und die Modifizierte Koordinate eines Caches, false, wenn ein Fehler auftrat
 *)
Function GCTGetOnlineNoteAndModifiedCoord(GC_Code: String; Out Data: TUserNoteCoord): boolean;

(*
 * Übermittelt die User Note und die Korrigierten Koords ins Web, false, wenn ein Fehler auftrat
 *)
Function GCTSetOnlineNoteAndModifiedCoord(GC_Code, Note: String;
  OnNeedUserNoteDecision: TNoteCallback; NoteAutoOK, NoteAutoAppent: Boolean;
  OnNoteEdit: TEditNoteCallback;
  CLat, CLon: Double; OnNeedUserCoordDecision: TCoordCallback; CoordAutoOK,
  CoordAutoOther: Boolean; Out Res: Integer): Boolean;

Function GCTClearOnlineNote(GC_Code: String): Boolean;
Function GCTClearOnlineCorrectedCoords(GC_Code: String): Boolean;

(*
 * Zum Zugriff auf die TB-Datenbank
 *)
Function TBLogstateToIntString(Value: TTBLogState): String;
Function TBLogstateToString(Value: TTBLogState): String;
Function TBIntStringToLogstate(Value: String): TTBLogState;
Function TBStringToLogstate(Value: String): TTBLogState;

Implementation

Function TBLogstateToIntString(Value: TTBLogState): String;
Begin
  result := '0';
  Case Value Of
    lsNotExisting: result := '0';
    lsNotDiscover: result := '1';
    lsNotYetActivated: result := '2';
    lsDiscovered: result := '3';
    lsLocked: result := '4';
    lsTBCode: Result := '5';
  End;
End;

Function TBLogstateToString(Value: TTBLogState): String;
Begin
  result := R_Not_Existing;
  Case Value Of
    lsNotExisting: result := R_Not_Existing;
    lsNotDiscover: result := R_Not_discovered;
    lsNotYetActivated: result := R_Not_yet_activated;
    lsDiscovered: result := R_Discovered;
    lsLocked: result := R_locked;
    lsTBCode: Result := R_TB_Code;
  End;
End;

Function TBIntStringToLogstate(Value: String): TTBLogState;
Begin
  result := lsNotExisting;
  If length(value) >= 1 Then Begin
    Case value[1] Of
      '0': result := lsNotExisting;
      '1': result := lsNotDiscover;
      '2': result := lsNotYetActivated;
      '3': result := lsDiscovered;
      '4': result := lsLocked;
      '5': result := lsTBCode;
    End;
  End;
End;

Function TBStringToLogstate(Value: String): TTBLogState;
Begin
  result := lsNotExisting; // Default = Problem
  value := lowercase(trim(value));
  If LowerCase(trim(R_Not_Existing)) = value Then result := lsNotExisting;
  If LowerCase(trim(R_Not_discovered)) = value Then result := lsNotDiscover;
  If LowerCase(trim(R_Not_yet_activated)) = value Then result := lsNotYetActivated;
  If LowerCase(trim(R_Discovered)) = value Then result := lsDiscovered;
  If LowerCase(trim(R_locked)) = value Then result := lsLocked;
  If LowerCase(trim(R_TB_Code)) = value Then result := lsTBCode;
End;

Var
  gctool: TGCTool = Nil;

Function GCTGetLastError: String;
Begin
  If assigned(gctool) Then Begin
    result := gctool.LastError;
  End
  Else Begin
    result := 'gctool not initialized.';
  End;
End;

Function GCTLogin(): Boolean;
Var
  puser, pport, phost, ppw, User, pw: String;
Begin
  result := false;
  If gctool.LoggedIn Then Begin // Wir sind schon eingeloggt
    result := true;
    exit;
  End;
  If Not gctool.LabLoggedIn Then Begin
    pHost := getvalue('General', 'ProxyHost', '');
    pport := getvalue('General', 'ProxyPort', '');
    puser := getvalue('General', 'ProxyUser', '');
    ppw := getvalue('General', 'ProxyPass', '');
    // Das Passwort für den Proxy
    If (phost <> '') And (pport <> '') And (puser <> '') And (ppw = '') Then Begin
      If trim(ppw) = '' Then Begin
        ppw := PasswordBox(R_Password_required, R_Please_enter_proxy_password);
      End;
      If ppw = '' Then Begin
        showmessage(R_No_valid_password_abort_now);
        exit;
      End;
    End;
    gctool.ProxyHost := phost;
    gctool.ProxyPort := pport;
    gctool.ProxyUser := puser;
    gctool.ProxyPass := ppw;
    user := getvalue('General', 'UserName', '');
    If trim(user) = '' Then Begin
      showmessage(R_No_geocaching_username_defined_go_to_the_options_to_define_abort_now);
      exit;
    End;
    pw := getvalue('General', 'Password', '');
    If trim(pw) = '' Then Begin
      pw := PasswordBox(R_Password_required, R_Please_enter_geocaching_online_password);
    End;
    If pw = '' Then Begin
      showmessage(R_No_valid_password_abort_now);
      exit;
    End;
    gctool.Username := user;
    gctool.Password := pw;
  End;
  result := gctool.Login;
  If Not result Then Begin
    showmessage(format(RF_Could_not_log_in_Error, [gctool.LastError]));
  End;
End;

Function GCTLabLogin(): Boolean;
Var
  puser, pport, phost, ppw, User, pw: String;
Begin
  result := false;
  If gctool.LabLoggedIn Then Begin // Wir sind schon eingeloggt
    result := true;
    exit;
  End;
  If Not gctool.LoggedIn Then Begin
    pHost := getvalue('General', 'ProxyHost', '');
    pport := getvalue('General', 'ProxyPort', '');
    puser := getvalue('General', 'ProxyUser', '');
    ppw := getvalue('General', 'ProxyPass', '');
    // Das Passwort für den Proxy
    If (phost <> '') And (pport <> '') And (puser <> '') And (ppw = '') Then Begin
      If trim(ppw) = '' Then Begin
        ppw := PasswordBox(R_Password_required, R_Please_enter_proxy_password);
      End;
      If ppw = '' Then Begin
        showmessage(R_No_valid_password_abort_now);
        exit;
      End;
    End;
    gctool.ProxyHost := phost;
    gctool.ProxyPort := pport;
    gctool.ProxyUser := puser;
    gctool.ProxyPass := ppw;
    user := getvalue('General', 'UserName', '');
    If trim(user) = '' Then Begin
      showmessage(R_No_geocaching_username_defined_go_to_the_options_to_define_abort_now);
      exit;
    End;
    pw := getvalue('General', 'Password', '');
    If trim(pw) = '' Then Begin
      pw := PasswordBox(R_Password_required, R_Please_enter_geocaching_online_password);
    End;
    If pw = '' Then Begin
      showmessage(R_No_valid_password_abort_now);
      exit;
    End;
    gctool.Username := user;
    gctool.Password := pw;
  End;
  result := gctool.LabLogin;
  If Not result Then Begin
    showmessage(format(RF_Could_not_log_in_Error, [gctool.LastError]));
  End;
End;

Procedure GCTLogOut;
Begin
  gctool.Logout;
End;

Function GCTGetServerParams: TServerParameters;
Begin
  result.UserInfo.Username := ''; // Nicht Initialisiert
  result.UserInfo.Usertype := ''; // Kein Premium
  If Not GCTLogin() Then exit;
  result := gctool.getServerParameters();
End;

Function GCTsearchMap(VP: TViewport; SP: TSearchParams; Out DataValid: Boolean
  ): TLiteCacheArray;
Begin
  result := Nil;
  If Not GCTLogin() Then exit;
  result := gctool.searchMap(vp, sp, DataValid);
End;

Function GCTsearchLabsNear(Lat, Lon: Single; SP: TSearchParams
  ): TLABCacheInfoArray;
Begin
  result := Nil;
  If Not GCTLogin() Then exit;
  If Not GCTLabLogin() Then exit;
  result := gctool.searchLabsNear(lat, lon, sp);
End;

Function GCTDownloadLAB(LAB: TLABCacheInfo; WPsAsCache: Boolean): TCacheArray;
Begin
  result := Nil;
  If Not GCTLogin() Then exit;
  If Not GCTLabLogin() Then exit;
  result := gctool.DownloadLAB(LAB, WPsAsCache);
End;

Function GCTGetLiteCache(GC_Code: String): TLiteCacheArray;
Begin
  result := Nil;
  If Not GCTLogin() Then exit;
  result := gctool.getLiteCache(GC_Code);
End;

Function GCTGetAvailableFavs: integer;
Begin
  result := -1;
  If Not GCTLogin() Then exit;
  result := gctool.getAvailableFavoritePoints;
End;

Function GCTLogOnline(Const Log: TFieldNote): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := gctool.postLog(Log);
End;

Function GCTGetFoundNumber(Out Founds: integer): Boolean;
Var
  fnds, tmp: String;
  i: Integer;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  fnds := gctool.GetFindCount;
  tmp := '';
  For i := 1 To length(fnds) Do Begin
    If fnds[i] In ['0'..'9'] Then Begin
      tmp := tmp + fnds[i];
    End;
  End;
  Founds := strtointdef(tmp, -1);
  If Founds = -1 Then Begin
    showmessage(format(RF_Unable_to_extract_find_count, [gctool.LastError]));
  End
  Else Begin
    result := true;
  End;
End;

Function GCTDiscoverTb(tb: TTravelbugRecord): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := gctool.DiscoverTB(tb);
End;

Function GCTGetTBLogRecord(TBCode: String; Out tb: TTravelbugRecord): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  tb := gctool.GetTBLogRecord(TBCode);
  result := true;
End;

Function GCTGetPocketQueries(Out PQ: TPocketQueries): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  pq := gctool.GetPocketQueries;
  If gctool.LastError <> '' Then Begin
    ShowMessage(gctool.LastError);
    pq := Nil;
    exit;
  End;
  result := true;
End;

Function GCTDownloadFile(Link: String; DestFilename: String;
  SupressError: Boolean): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := gctool.DownloadFile(Link, DestFilename);
  If (Not result) And (Not SupressError) Then Begin
    ShowMessage(gctool.LastError);
  End;
End;

Function GCTDownloadCacheGPX(GC_Code: String; DestFilename: String;
  Silent: Boolean): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := gctool.DownloadCacheGPX(GC_Code, DestFilename);
  If Not result Then Begin
    If Not silent Then Begin
      ShowMessage(gctool.LastError);
    End;
  End;
End;

Function GCTDownloadSpoiler(GC_Code: String): integer;
Begin
  result := 0;
  If Not GCTLogin() Then exit;
  result := gctool.DownloadSpoiler(GC_Code);
  If gctool.LastError <> '' Then Begin
    ShowMessage(gctool.LastError);
  End;
End;

Function GCTGetCacheInfo(GC_Code: String): TCacheInfo;
Begin
  Result.GC_Code := '';
  Result.State := csError;
  Result.Description := 'Error';
  If Not GCTLogin() Then exit;
  result := gctool.GetCacheInfo(GC_Code);
  If gctool.LastError <> '' Then Begin
    ShowMessage(gctool.LastError);
  End;
End;

Function GCTGetOnlineNoteAndModifiedCoord(GC_Code: String; Out
  Data: TUserNoteCoord): boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := true;
  data := gctool.GetOnlineNoteAndModifiedCoord(GC_Code);
End;

Function GCTSetOnlineNoteAndModifiedCoord(GC_Code, Note: String;
  OnNeedUserNoteDecision: TNoteCallback; NoteAutoOK, NoteAutoAppent: Boolean;
  OnNoteEdit: TEditNoteCallback;
  CLat, CLon: Double; OnNeedUserCoordDecision: TCoordCallback; CoordAutoOK,
  CoordAutoOther: Boolean; Out Res: Integer): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := true;
  res := gctool.SetOnlineNoteAndModifiedCoord(GC_Code,
    Note, OnNeedUserNoteDecision, NoteAutoOK, NoteAutoAppent, OnNoteEdit,
    CLat, CLon, OnNeedUserCoordDecision, CoordAutoOK, CoordAutoOther
    );
End;

Function GCTClearOnlineNote(GC_Code: String): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := true;
  If Not gctool.ClearOnlineNote(GC_Code) Then Begin
    // TODO: Qualifizierte Fehlermeldung Ausgeben
  End;
End;

Function GCTClearOnlineCorrectedCoords(GC_Code: String): Boolean;
Begin
  result := false;
  If Not GCTLogin() Then exit;
  result := true;
  If Not gctool.ClearOnlineKorrectedCoords(GC_Code) Then Begin
    // TODO: Qualifizierte Fehlermeldung Ausgeben
  End;
End;

Initialization
  gctool := TGCTool.create;

Finalization
  gctool.free;

End.

