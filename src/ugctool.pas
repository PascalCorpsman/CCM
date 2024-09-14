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
Unit ugctool;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, StrUtils, HttpSend, fphttpclient, synautil, uccm, uJSON, Dialogs;

(*
 * Die URL der Offiziellen API-Dokumentation :
 *           https://api.groundspeak.com/documentation
 *
 * Neu: https://api.groundspeak.com/LiveV6/geocaching.svc/help
 *
 * Die SweggerUI der Lab-Caches:
 *           https://labs-api.geocaching.com/swagger/ui/index
 *           https://github.com/mirsch/lab2gpx
 *           https://gcutils.de/lab2gpx
 *
 * Der Quellcode von C:geo liegt unter: https://github.com/cgeo/cgeo
 *
 * Besonders interessant \connector\gc\GCWebAPI.java
 *
 *)

Const
  // Alle URLs, auf die wir reagieren können, sollten diese sich im Laufe der Zeit ändern

  //  Real_API = 'https://api.groundspeak.com'; -- Für die wäre dann der GC_API_KEY
  API_URL = 'https://www.geocaching.com/api/proxy';
  API_LAB_URL = 'https://labs-api.geocaching.com/api';

  //API_Download_GPX_URL = 'https://www.geocaching.com/play/map/api/gpx/';
  Authorisation_URL = 'https://www.geocaching.com/account/oauth/token';
  LOGIN_URL = 'https://www.geocaching.com/account/signin';
  LAB_Login_URL = 'https://labs.geocaching.com/login';
  GeocacheDashBoardURL = 'https://www.geocaching.com/profile/';
  PocketQueryURL = 'https://www.geocaching.com/pocket';

  // Alle URLs, die wenn sie sich ändern von Hand umgeändert werden müssen
  GeocachePraefixURL = 'https://www.geocaching.com/play/geocache/';
  //  TrackableURL = 'https://www.geocaching.com/api/proxy/trackable/activities';
  FavouritesURL = 'https://www.geocaching.com/datastore/favorites.svc';
  TrackableListingURL = 'https://www.geocaching.com/track/';
  TrackabkeGetCSRFTokenUrl = 'https://www.geocaching.com/api/auth/csrf';

  (*
   * If you get a compiler error at this point, than you cloned the source from the
   * offizial Git REPO.
   * Unfortunatunelly it is not allowed to share the consumer keys in public.
   *
   * To be able to compile the code you need to declare the following 2 string
   * constants here:
   *
    LAB_CONSUMER_KEY = '';
    GC_API_Key = '';
   *)
{$I gc_secret.inc}

  (* Die Rückgabebits für SetOnlineNoteAndModifiedCoord müssen alle Disjunkt sein *)
  NCR_OK = 0; // Löscht Alle Bits
  NCR_Note_Auto_all = 1;
  NCR_Note_Auto_Append = 2;
  NCR_Coord_Auto_OK = 4;
  NCR_Coord_Auto_Other = 8;
  NCR_ERROR = 16;

Type

  TUserCoordResult =
    (
    ucrError,
    ucrAbort, // Abbruch durch Benutzer
    ucrOK,
    ucrOKAll,
    ucrOKAllOther
    );

  TUserNoteResult = (
    unrError, // Irgendwo ist ein Fehler aufgetreten
    unrAbort, // Abbruch durch Benutzer
    unrOK, // Alles Paletti
    unrOKAll, // Alles Paletti, user hat entschieden alle Online durch die Lokalen zu ersetzen
    unrOKAppendAll // Alles Paletti, user hat entschieden alle Lokalen an die Onlien an zu hängen
    );

  TNoteCallback = Function(GC_Code, OnlineNote: String; Var LocalNote: String): TUserNoteResult Of Object;
  TCoordCallback = Function(GC_Code: String; OnlineLat, OnlineLon: Double; Var Lat: Double; Var Lon: Double): TUserCoordResult Of Object;
  TEditNoteCallback = Function(GC_Code: String; Var Note: String): Boolean Of Object;

  TLABCacheInfo = Record
    (* -- Alle Parameter die durch searchLabsNear definiert werden -- *)
    ID: String;
    Title: String;
    Link: String;
    RatingAvg: Single;
    RatingCount: integer;
    Lat: Double;
    Lon: Double;
    isOwned: Boolean;
    isCompleted: Boolean;
    StageCount: integer;
    (* -- Alle Parameter die eigentlich nicht hier rein gehören, aber uns eben das Leben erleichtern --*)
    RenderIconIndex: integer; // -- Wird im uonlineviewer beim Übernehmen initialisiert
    OldRenderIconIndex: integer; // -- Wird im uonlineviewer beim Übernehmen initialisiert
    x, y: integer; // Die zuletzt berechnete Position auf dem RenderingContext
  End;

  TUserNoteCoord = Record
    UserNote: String;
    Lat: Double;
    Lon: Double;
  End;

  TLABCacheInfoArray = Array Of TLABCacheInfo;

  TStringArray = Array Of String;

  TCacheState = (csError, csFound, csNotFound);

  TCacheInfo = Record
    GC_Code: String;
    Description: String;
    State: TCacheState;
  End;

  TTBLogState = (lsNotDiscover, lsLocked, lsNotExisting, lsNotYetActivated, lsDiscovered, lsTBCode);

  TFeedBack = Procedure(Sender: TObject; Cache: String) Of Object;

  TTravelbugRecord = Record
    TB_Code: String; // der Öffentliche Code des TB'S
    Discover_Code: String; // Der Code der auf dem TB steht mit dem er discovert werden kann
    LogState: TTBLogState; // Gefunden / nicht gefunden ...
    LogDate: String; // Das Letzte Datum an dem der TB Discovered wurde
    Owner: String; // Klartextname des Owners
    ReleasedDate: String; // Wann wurde der TB veröffentlicht
    Origin: String; // Wo wurde er Veröffentlicht
    Heading: String; // Quasi der Titel des TB's
    Current_Goal: String; // Das Aktuelle Ziel des TB's
    About_this_item: String; // Kurzbeschreibung des TB's
    Comment: String; // Der Kommentar beim Loggen
  End;

  TPocketQuerie = Record
    Name: String;
    Link: String;
    Size: String;
    WPCount: Integer;
    Timestamp: String;
  End;

  TPocketQueries = Array Of TPocketQuerie;

  (*
   * Datentyp zum Zugriff auf die Groundspeak Live API
   *)
  TAPIToken = Record
    access_token: String; // Der Eigentliche wert des Tokens
    token_type: String; // "Bearer"
    expires_at: TDatetime; // Zeitpunkt an welchem dieser Token Abläuft, wird beim Hohlen berechnet und gesetzt
  End;

  TUserInfo = Record
    Username: String; // wenn '', dann nicht initialisiert
    ReferenceCode: String;
    Usertype: String;
    DateFormat: String;
    UnitSetName: String;
    Roles: String;
    publicGUID: String;
    AvatarURL: String;
  End;

  TappOptions = Record
    LocalRegion: String;
    CoordInfoURL: String;
    PaymentURL: String;
  End;

  TServerParameters = Record
    UserInfo: TUserInfo;
    appOptions: TappOptions;
  End;

  TMapSettings = Record
    UserSession: String;
    Home_lat: Double;
    Home_lon: Double;
    MapBaseUrl: String;
    userOptions: String;
    SessionToken: String;
    subscriberType: integer;
    enablePersonalization: Boolean;
  End;

  TSearchParams = Record
    Ho: Boolean; // Hide Own
    Hf: Boolean; // Hide Found
    All: Boolean;
    Exclude: boolean;
    Tradi: Boolean;
    Multi: boolean;
    Mystery: Boolean;
    Event: Boolean;
  End;

  { TrackableLog }

  TrackableLog = Class(TJSONObj)
  private
    fAction: TTBLogType;
    fDate: String;
    fGC_Code: String;
    fReferenceCode: String;
  public
    Constructor Create(Action: TTBLogType; Date: String; GC_Code: String; ReferenceCode: String); reintroduce;
    Function ToString(FrontSpace: String = ''): String; override;
  End;

  { TGCLog }

  TGCLog = Class(TJSONObj)
  private
  public
    ID: String; // GC_Code umgerechnet in GC ID
    GC_Code: String;
    LogDate: String;
    Fav: String;
    LogType: String;
    LogText: String;
    Constructor Create(); reintroduce;
    Function ToString(FrontSpace: String = ''): String; override;
  End;

  { THintElement }

  THintElement = Class(TJSONObj)
  private
    fHint, fUserToken: String;
  public
    Constructor Create(Hint, UserToken: String); reintroduce;
    Function ToString(FrontSpace: String = ''): String; override;
  End;

  { TCoordElement }

  TCoordElement = Class(TJSONObj)
  private
    fLat, FLon: Double;
    fUserToken: String;
  public
    Constructor Create(Lat, Lon: Double; UserToken: String); reintroduce;
    Function ToString(FrontSpace: String = ''): String; override;
  End;

  { TGCTool }

  TGCTool = Class
  private
    fMapSettings: TMapSettings;
    fServerParameters: TServerParameters;
    fLastError: String; // Der Zuletzt aufgetretene Fehler als klartext, im Idealfall ist dieser String immer leer
    fLoggedIn: Boolean; // True, wenn Eingeloggt
    fLabLoggedIn: Boolean; // True, wenn Eingeloggt
    fClient: THTTPSend; // Die Komponente zum Zugriff auf das Netz
    // TODO: Das kann wahrscheinlich Raus, aktuell schadet es aber auch nicht und es läuft ja ..
    FAPIToken: TAPIToken; // Wird zum Zugriff auf die Groundspeak Live API benötigt.

    // Das ist angelehnt an die Noch generischere Variante aus uupdate.pas
    Function Follow_Links(URL: String): String; // Nachdem eine HTTPMethod get Aufgerufen wurde, verfolgt diese Routine alle Nachfolgenden Links
    Procedure RefreshAPIToken; // Hohlt einen neuen API Token, wenn notwendig

    Procedure SetProxyHost(AValue: String);
    Procedure SetProxyPass(AValue: String);
    Procedure SetProxyPort(AValue: String);
    Procedure SetProxyUser(AValue: String);
    Procedure ExtractViewStates(Out __VIEWSTATES: TStringArray; Out __VIEWSTATEGENERATOR: String);

    Function postAPI(Path: String; Filename: String): String; overload; // Upload eines Bildes unter Verwendung einer Multipart Form
    Function postAPI(Path: String; Params: TJSONObj): String; overload;
    Function postJSON(URL: String; Params: TJSONObj; AddToHeader: String = ''): String; overload;

    Function patchAPI(Path: String): String;

    Function getAPI(Path: String; Params: String = ''): String; (*overload;
    Function getAPI(Path: String; params: TKeyValueArray): String; overload;
    Function getAPI(Path: String; Params: TJSONObj): String; overload;
    *)
    Function getAPI_LAB(Path: String; Params: String = ''): String;

    Function postLogTrackable(GC_Code: String; logDate: String; Tbs: TStringArray): Boolean; overload;
    Function postLogTrackable(trackableLogs: TJSONArray): Boolean; overload;

    Function getMapSettings: TMapSettings;
    Function ExtractFormAuthToken: String;
    Procedure RemoveFormAuthToken;
    Function ExtractUserToken(): String; // Wurde eine Seite mittels // https://coord.info/' + GC_Code geladen kann so das Usertocken erhalten werden "" bei Fehler
    Function ExtractUserNote(): String; // Wurde eine Seite mittels // https://coord.info/' + GC_Code geladen kann so die UserNote des Caches geladen werden
    Procedure ExtractModifiedCoord(Out Lat: Double; Out Lon: Double); // Wurde eine Seite mittels // https://coord.info/' + GC_Code geladen kann so die Modifizierte Koordinate ermittelt werden, -1 Wenn keine gefunden wurde
  public
    Username: String;
    Password: String;

    Property ProxyHost: String write SetProxyHost;
    Property ProxyPort: String write SetProxyPort;
    Property ProxyUser: String write SetProxyUser;
    Property ProxyPass: String write SetProxyPass;

    Property LastError: String read fLastError;

    Property LoggedIn: Boolean read fLoggedIn;
    Property LabLoggedIn: Boolean read fLabLoggedIn;

    Constructor Create;
    Destructor Destroy; override;

    (*
     * Gibt ettliche Infos über den Cacher.
     *)
    Function getServerParameters(): TServerParameters;

    (*
     * True, wenn wir uns erfolgreich auf www.Geocaching.com einloggen konnten.
     *)
    Function Login: Boolean;

    (*
     * Zum Ausloggen ;)
     *)
    Procedure Logout;

    (*
     * Logt einen Cache, alle TB's die mit angehängt sind werden als besucht geloggt
     *
     * Wenn Result = true, alles gut
     * Result = false, bei irgend einem Fehler (TB's oder Log, Grund steht dann in LastError)
     *)
    Function postLog(Log: TFieldNote): Boolean;

    (*
     * Zeigt die Anzahl der Funde an
     *)
    Function GetFindCount: String; // Todo: Umschreiben auf API

    (*
     * Lädt die Verfügbaren Pocketqueries und gibt diese zurück.
     *)
    Function GetPocketQueries: TPocketQueries; // Todo: Umschreiben auf API

    (*
     * Lädt die Datei auf die Link zeigt herunter und speichert sie als DestFilename ab (und das als eingelogter User)
     *)
    Function DownloadFile(Link: String; DestFilename: String): Boolean;

    (*
     * gibt an ob der TB gefunden wurde, nicht gefunden wurde, oder gar nicht existiert und wann
     *)
    Function GetTBLogRecord(TBCode: String): TTravelbugRecord; // Todo: Umschreiben auf API

    (*
     * Versucht den TB zu loggen, true bei Erfolg.
     *)
    Function DiscoverTB(Data: TTravelbugRecord): Boolean; // Todo: Umschreiben auf API

    (*
     * Lädt die GPX Datei eines Caches herunter und speichert sie in Filename ab.
     *)
    Function DownloadCacheGPX(GC_Code: String; Filename: String): Boolean;

    (*
     * Lädt die Spoilerbilder zu einem GC Code herunter und speichert sie ccm passend ab
     *)
    Function DownloadSpoiler(GC_Code: String): integer; // Todo: Umschreiben auf API

    (*
     * Gibt an ob der Cache mit dem GC-Code bereits gefunden wurde oder nicht
     *)
    Function GetCacheInfo(GC_Code: String): TCacheInfo; // Todo: Umschreiben auf API

    (*
     * Gibt die Anzahl der zum Vergeben möglichen Fav Punkte Zurück
     * -1 bei Fehler
     *)
    Function getAvailableFavoritePoints: integer;

    (*
     * Gibt gemäß den SearchParams alle Caches innerhalb von Viewport als LiteCaches zurück
     *)
    Function searchMap(viewport: TViewport; SearchParams: TSearchParams; Out
      DataValid: Boolean): TLiteCacheArray;

    (*
     * Gibt entweder genau 1 Cache zurück, oder NIL, wenn dieser nicht gefunden werden kann
     *)
    Function getLiteCache(GC_Code: String): TLiteCacheArray;

    // -------------------------------------------------------------------------
    // Ab hier LAB Interfaces
    // -------------------------------------------------------------------------
    (*
     * True, wenn wir uns erfolgreich auf labs.geocaching.com einloggen konnten.
     *)
    Function LabLogin: Boolean;

    (*
     * Gibt die LABs in der "Nähe" von lat / lon als Ladbare Liste zurück
     *)
    Function searchLabsNear(Lat, Lon: Single; SP: TSearchParams): TLABCacheInfoArray;

    (*
     * Lädt eine Lab-Cache herunter
     * Wenn WPsAsCache = True, dann werden alle Wegpunkte als Separater Cache gespeichert
     *                 = false, dann ist das Ergebnis nur 1 Cache mit vielen Wegpunkten
     *)
    Function DownloadLAB(LAB: TLABCacheInfo; WPsAsCache: Boolean): TCacheArray;

    (**************************************************************************)
    (* Es folgen Routinen die direkt Online Arbeiten                          *)
    (**************************************************************************)

    (*
     * Aktualisiert die User Note online.
     * Wenn Note = '' wird nichts gemacht (zum UserNote Löschen gibt es andere Funktionen!)
     * Wenn Online bereits eine User Note Angelegt ist die sich von der Eingabe unterscheidet
     * wird die Callback aufgerufen und der User muss entscheiden was passiert. Ist der UserNote
     * aktuell noch nicht vergeben wird er einfach gesetzt.
     *)
    Function SetOnlineNoteAndModifiedCoord(GC_Code,
      Note: String; OnNeedUserNoteDecision: TNoteCallback; NoteAutoOK, NoteAutoAppent: Boolean;
      OnNoteEdit: TEditNoteCallback;
      CLat, CLon: Double; OnNeedUserCoordDecision: TCoordCallback; CoordAutoOK, CoordAutoOther: Boolean
      ): Integer;

    (*
     * Löscht die UserNote eines Chaches
     *)
    Function ClearOnlineNote(GC_Code: String): Boolean;

    (*
     * Reset der Korrigierten Koords
     *)
    Function ClearOnlineKorrectedCoords(GC_Code: String): Boolean;

    (*
     * Lädt die Usernote und die Korrigierte Koordinate aus dem Listing
     *)
    Function GetOnlineNoteAndModifiedCoord(GC_Code: String): TUserNoteCoord;
  End;

  (*
   * True, wenn die Usernote kleiner = der Anzahl der Erlaubten Zeichen ist.
   *)
Function IsUserNoteLenValid(UserNote: String): Boolean;

Implementation

Uses
  math,
  LazUTF8,
  LazFileUtils,
  ulanguage,
  umultipartformdatastream,
  DateUtils,
  ssl_Openssl;

Function LogStateToOption(State: TLogtype): String;
Begin // https://api.groundspeak.com/documentation#geocache-log-types
  (*
   * Die Zahlenwerte stehen bei der Deklaration von TLogtype
   *)
  result := '4'; // Default Write Note, richtet keinen Schaden an ;)
  Case state Of
    ltFoundit: result := '2';
    ltDidNotFoundit: result := '3';
    ltWriteNote: result := '4';
    //ltArchive:result := '5';
    // 6 = Permanently Archived (deprecated)
    ltNeedsArchive: result := '7';
    ltWillAttend: result := '9';
    ltAttended: result := '10';
    ltWebcamPhotoTaken: result := '11';
    //ltUnarchive:result:= '12';
    // 22 = Temporarily Disable Listing
    // 23 = Enable Listing
    // 24 = Publish Listing
    // 25 = Retract Listing
    ltNeedsMaintenance: result := '45';
    // ltOwnerMaintenance: result := '46';
    // 47 = Update Coordinates
    // 68 = Post Reviewer Note
    // 74 = Announcement
    ltUnattempted: result := '4'; // Den gibt es nur bei Garmin, nicht bei GC -> Write Note
  Else Begin
      Raise exception.create('Error missing Logtype for: TGCTool.LogStateToOption');
    End;
  End;
End;

Function TBLogStateToOption(State: TTBLogType): String;
Begin // https://api.groundspeak.com/documentation#trackable-log-types
  result := '4';
  Case state Of
    tlWriteNote: result := '4';
    tlRetrieveFromCache: result := '13';
    tlDroppedOff: result := '14';
    tlTransfer: result := '15';
    tlMarkMissing: result := '16';
    tlGrabIt: result := '19'; // (not from a Cache)
    tlDiscoveredIt: result := '48';
    tlMoveToCollection: result := '69';
    tlMoveToinventory: result := '70';
    tlVisited: result := '75';
  Else Begin
      Raise exception.create('Error missing Logtype for: TGCTool.TBLogStateToOption');
    End;
  End;
End;

Function formatDouble(dbl: double): String;
Begin
  result := format('%.6f', [dbl], DefFormat);
End;

Function formatBoolean(bool: boolean): String;
Begin
  result := BoolToStr(bool, 'true', 'false');
End;

Function formatGCDate(date: TDatetime): String;
Begin
  result := formatdatetime('yyyy-MM-dd', date);
End;

(*
 * Führt gemäß : https://en.wikipedia.org/wiki/Percent-encoding
 * ein Percent encoding durch -> Wandelt also z.b. & nach %27
 *)

Function EncodeURI(Value: String): String;
Begin
  result := value;
  result := StringReplace(result, '%', '%25', [rfReplaceAll]); // -- Das muss natürlich zuerst !!

  result := StringReplace(result, '!', '%21', [rfReplaceAll]);
  result := StringReplace(result, '"', '%22', [rfReplaceAll]);
  result := StringReplace(result, '#', '%23', [rfReplaceAll]);
  result := StringReplace(result, '$', '%24', [rfReplaceAll]);
  result := StringReplace(result, '&', '%26', [rfReplaceAll]);
  result := StringReplace(result, '''', '%27', [rfReplaceAll]);
  result := StringReplace(result, '(', '%28', [rfReplaceAll]);
  result := StringReplace(result, ')', '%29', [rfReplaceAll]);
  result := StringReplace(result, '*', '%2A', [rfReplaceAll]);
  result := StringReplace(result, '+', '%2B', [rfReplaceAll]);
  result := StringReplace(result, ',', '%2C', [rfReplaceAll]);
  result := StringReplace(result, '/', '%2F', [rfReplaceAll]);
  result := StringReplace(result, ':', '%3A', [rfReplaceAll]);
  result := StringReplace(result, ';', '%3B', [rfReplaceAll]);
  result := StringReplace(result, '=', '%3D', [rfReplaceAll]);
  result := StringReplace(result, '?', '%3F', [rfReplaceAll]);
  result := StringReplace(result, '@', '%40', [rfReplaceAll]);
  result := StringReplace(result, '[', '%5B', [rfReplaceAll]);
  result := StringReplace(result, ']', '%5D', [rfReplaceAll]);

  // https://de.wikipedia.org/wiki/Hilfe:Sonderzeichenreferenz
  result := StringReplace(result, 'Ä', '%C3%84', [rfReplaceAll]);
  result := StringReplace(result, 'Ö', '%C3%96', [rfReplaceAll]);
  result := StringReplace(result, 'Ü', '%C3%9C', [rfReplaceAll]);
  result := StringReplace(result, 'ß', '%C3%9F', [rfReplaceAll]);
  result := StringReplace(result, 'ä', '%C3%A4', [rfReplaceAll]);
  result := StringReplace(result, 'ö', '%C3%B6', [rfReplaceAll]);
  result := StringReplace(result, 'ü', '%C3%BC', [rfReplaceAll]);
  result := StringReplace(result, 'ẞ', '%E1%BA%9E', [rfReplaceAll]);

  result := StringReplace(result, ' ', '+', [rfReplaceAll]);
End;

Procedure CopyStreamToStrings(Stream: TStream; Strings: TStrings);
Var
  Buffer: String;
Begin
  Buffer := '';
  SetLength(Buffer, Stream.Size);
  Stream.Seek(0, soFromBeginning);
  Stream.Read(Buffer[1], Stream.Size);
  Strings.Text := Buffer;
End;

Procedure CopyStringsToStream(Strings: TStrings; Stream: TStream);
Var
  Buffer: String;
Begin
  Buffer := Strings.Text;
  Stream.Seek(0, soFromBeginning);
  Stream.Write(Buffer[1], Length(Buffer));
End;

(*
 * Achtung, wenn hier ein Datentyp erweitert wird (in einen den es noch nicht gibt)
 * Dann muss dieser auch in:
 *   Unit1.TForm1.CacheTypeToIconIndex
 *   Unit1.CachetToWPT
 *
 * Eingetragen werden
 *)

Function GC_TypetoCCMType(Value: integer): String;
Begin // https://api.groundspeak.com/documentation#type
  Case value Of
    2: result := Traditional_Cache;
    3: result := Multi_cache;
    4: result := Virtual_Cache;
    5: result := Letterbox_Hybrid;
    6: result := Event_Cache;
    8: result := Unknown_Cache;
    9: result := Project_APE_Cache;
    11: result := Webcam_Cache;
    //12 	Locationless (Reverse) Cache
    13: result := Cache_In_Trash_Out_Event;
    137: result := Earthcache;
    453: result := Mega_Event_Cache;
    //1304 	GPS Adventures Exhibit
    1858: result := Wherigo_Cache;
    3653: result := Event_Cache; // 3653 = Community Celebration Event
    3773: result := Unknown_Cache; //3773 = Geocaching HQ
    3774: result := Event_Cache; // 3774 = Geocaching HQ Celebration
    4738: result := Event_Cache; // 4738 = Geocaching HQ Block Party
    7005: result := Giga_Event_Cache;
  Else Begin
      Raise Exception.Create('GC_TypetoCCMType: Missing type for: ' + inttostr(value));
    End;
  End;
End;

Function GC_ContainerToCCMContainer(Value: integer): String;
Begin // https://api.groundspeak.com/documentation#geocache-sizes
  result := csNotChosen; // -- Den gibts in der Liste gar nicht ..
  Case value Of
    1: result := csUnknown;
    2: result := csMicro;
    3: result := csRegular;
    4: result := csLarge;
    5: result := csVirtual;
    6: result := csOther;
    8: result := csSmall;
  Else Begin
      Raise Exception.Create('GC_ContainerToCCMContainer: Missing size for: ' + inttostr(value));
    End;
  End;
End;

Function JSONNodeToLiteCache(Const Node: TJSONNode): TLiteCache;
(*
 * https://api.groundspeak.com/documentation#lite-geocache
 *)

(*
 -- Es gibt 2 Prinzipielle Datensätze für Lite Caches, diese Routine lädt beide:

{-- Datensatz, wenn via searchMap ein Lite Cache rein kommt
  "id":3367962,
  "name":"Gute alte Zeiten.....",
  "code":"GC42VDW",
  "premiumOnly":false,                     -- Wird nicht ausgewertet, weil die DB das nicht hat
  "favoritePoints":6,
  "geocacheType":8,
  "containerType":8,
  "difficulty":1.5,
  "terrain":2.0,
  "userFound":false,
  "userDidNotFind":false,                  -- Wird nicht ausgewertet, weil die DB das nicht hat
  "cacheStatus":0,
  "postedCoordinates":  {
    "latitude":47.75,
    "longitude":9.086667
  },
  "userCorrectedCoordinates":      {       -- Manchmal ist das noch mit drin, aber nicht immer, Merkt sich ob es Korrigierte Koordinaten gibt.
   "latitude":48.8468666666667,
   "longitude":9.40535
  }
  "detailsUrl":"\/geocache\/GC42VDW",      -- Wird nicht ausgewertet, da das der CCM nicht nutzt
  "hasGeotour":false,                      -- Wird nicht ausgewertet, weil die DB das nicht hat
  "hasLogDraft":false,                     -- Wird nicht ausgewertet, weil die DB das nicht hat
  "placedDate":"2012-12-14T00:00:00",
  "owner":  {
    "code":"PRREQP",                       -- Wird nicht ausgewertet, weil die DB das nicht hat (die DB hat nur eine Owner ID, keinen Code)
    "username":"Los Muertos"
  },
  "lastFoundDate":"2020-06-20T12:00:00"    -- Damit wird ein "Pseudolog" generiert
}

{-- Datensatz, wenn via getLiteCache ein Lite Cache rein kommt
  "id":629734,
  "referenceCode":"GC13Y2Y",
  "difficulty":0.0,
  "terrain":0.0,
  "favoritePoints":0,
  "guid":"00000000-0000-0000-0000-000000000000",
  "placedDate":"2007-06-26T00:00:00",
  "postedCoordinates":  {
    "latitude":52.509467,
    "longitude":13.3727
  },
  "userCorrectedCoordinates":      {       -- Manchmal ist das noch mit drin, aber nicht immer, Merkt sich ob es Korrigierte Koordinaten gibt.
   "latitude":48.8468666666667,
   "longitude":9.40535
  }
  "callerSpecific":  {
    "found":"2016-09-20T12:00:00",
    "favorited":false
  },
  "owner":  {
    "id":816735,
    "referenceCode":"PR1A6N7",
    "userName":"riechkolben"
  },
  "geocacheType":  {
    "id":2,
    "name":"Traditional Cache"
  },
  "state":  {
    "isArchived":false,
    "isAvailable":true,
    "isPremiumOnly":false,                 -- Wird nicht ausgewertet, weil die DB das nicht hat
    "isPublished":true                     -- Wird nicht ausgewertet, weil die DB das nicht hat
  }
}
*)
Var
  //sl: TStringlist;
  jn: TJSONNode;
  jv: TJSONValue;
Begin
  //  sl := TStringList.Create;
  //  sl.text := Node.ToString('');
  //  sl.SaveToFile('LiteCache_V3.json');
  //  sl.free;
  result.Lat := strtofloat((node.FindPath('postedCoordinates.latitude') As TJSONValue).Value, DefFormat);
  result.Lon := strtofloat((node.FindPath('postedCoordinates.longitude') As TJSONValue).Value, DefFormat);
  jn := node.FindPath('userCorrectedCoordinates') As TJSONNode;
  If assigned(jn) Then Begin
    result.Cor_Lat := strtofloat((node.FindPath('userCorrectedCoordinates.latitude') As TJSONValue).Value, DefFormat);
    result.Cor_Lon := strtofloat((node.FindPath('userCorrectedCoordinates.longitude') As TJSONValue).Value, DefFormat);
  End
  Else Begin
    result.Cor_Lat := -1;
    result.Cor_Lon := -1;
  End;
  result.Time := (node.FindPath('placedDate') As TJSONValue).Value;
  jv := (node.FindPath('referenceCode') As TJSONValue);
  If assigned(jv) Then Begin
    result.GC_Code := jv.Value;
  End
  Else Begin
    jv := (node.FindPath('Code') As TJSONValue);
    If assigned(jv) Then Begin
      result.GC_Code := jv.Value;
    End
    Else Begin
      Raise exception.create('Error, could not extract cache name in: ' + node.ToString(''));
    End;
  End;
  result.Fav := strtoint((node.FindPath('favoritePoints') As TJSONValue).Value);
  jv := node.FindPath('name') As TJSONValue;
  If assigned(jv) Then Begin
    result.G_Name := jv.Value;
  End
  Else Begin
    result.G_Name := result.GC_Code; // Information nicht vorhanden
  End;
  result.G_ID := strtoint((node.FindPath('id') As TJSONValue).Value);
  jv := node.FindPath('cacheStatus') As TJSONValue;
  result.G_Available := true;
  result.G_Archived := false;
  If assigned(jv) Then Begin
    Case jv.Value Of // TODO: Das könnte evtl besser aufgelöst werden..
      '1': Begin // unpublished
          result.G_Available := true;
          result.G_Archived := false;
        End;
      '2': Begin // Active
          result.G_Available := false;
          result.G_Archived := false;
        End;
      '3': Begin // Disabled
          result.G_Available := true;
          result.G_Archived := false;
        End;
      '4': Begin // Locked
          result.G_Available := true;
          result.G_Archived := false;
        End;
      '5': Begin // Archived
          result.G_Available := true;
          result.G_Archived := true;
        End;
    End;
  End
  Else Begin
    result.G_Available := lowercase(trim((node.FindPath('state.isAvailable') As TJSONValue).Value)) = 'true';
    result.G_Archived := lowercase(trim((node.FindPath('state.isArchived') As TJSONValue).Value)) = 'true';
  End;
  jv := node.FindPath('userFound') As TJsonvalue;
  If assigned(jv) Then Begin
    result.G_Found := ord(lowercase(jv.Value) = 'true');
  End
  Else Begin
    result.G_Found := 0; // Information nicht vorhanden
  End;
  jv := node.FindPath('geocacheType.id') As TJSONValue;
  If assigned(jv) Then Begin
    result.G_Type := GC_TypetoCCMType(strtoint(jv.Value));
  End
  Else Begin
    jv := node.FindPath('geocacheType') As TJSONValue;
    If assigned(jv) Then Begin
      result.G_Type := GC_TypetoCCMType(strtoint(jv.Value));
    End
    Else Begin
      Raise exception.create('Error, could not extract cache id in: ' + node.ToString(''));
    End;
  End;
  jv := node.FindPath('containerType') As TJSONValue;
  If assigned(jv) Then Begin
    result.G_Container := GC_ContainerToCCMContainer(strtointdef(jv.Value, 0));
  End
  Else Begin
    result.G_Container := csUnknown; // Information nicht vorhanden
  End;
  result.G_Difficulty := strtofloat((node.FindPath('difficulty') As TJSONValue).Value, DefFormat);
  result.G_Terrain := strtofloat((node.FindPath('terrain') As TJSONValue).Value, DefFormat);
  result.G_Owner := (node.FindPath('owner.username') As TJSONValue).Value;
  jv := node.FindPath('lastFoundDate') As TJSONValue;
  If assigned(jv) Then Begin
    result.LastFound := jv.Value;
  End
  Else Begin
    result.LastFound := result.Time; // Information nicht vorhanden
  End;
End;

Function CleanUpUserNote(Value: String): String;
Begin
  result := trim(Value);
  result := StringReplace(result, '<', '&lt;', [rfReplaceAll]);
  result := StringReplace(result, '>', '&gt;', [rfReplaceAll])
End;

Function UnCleanUpUserNote(Value: String): String;
Begin
  result := trim(Value);
  result := StringReplace(result, '&lt;', '<', [rfReplaceAll]);
  result := StringReplace(result, '&gt;', '>', [rfReplaceAll])
End;

Function IsUserNoteLenValid(UserNote: String): Boolean;
Begin
{$IFDEF WINDOWS}
  usernote := StringReplace(UserNote, LineEnding, #13, [rfReplaceAll]);
{$ENDIF}
  result := Length(CleanUpUserNote(UserNote)) <= 2499; // Offiziell sind es 2500, aber wir bauen ein klein bisschen Sicherheit ein.
End;

(*
 * Listing = HTML-Seite eines TB'S
 *)

Function ExtractTB_Code(Const listing: TStringlist): String;
Var
  i, j, k: integer;
Begin
  //  <a href="https://coord.info/TB8KVZX" class="CoordInfoLink">
  result := '';
  For i := 0 To listing.Count - 1 Do Begin
    If pos('https://coord.info/', listing[i]) <> 0 Then Begin
      j := pos('https://coord.info/', listing[i]) + Length('https://coord.info/');
      For k := j + 1 To length(listing[i]) Do Begin
        If listing[i][k] = '"' Then Begin
          result := copy(listing[i], j, k - j);
          exit;
        End;
      End;
    End;
  End;
End;

{ TCoordElement }

Constructor TCoordElement.Create(Lat, Lon: Double; UserToken: String);
Begin
  fUserToken := UserToken;
  fLat := Lat;
  FLon := Lon;
End;

Function TCoordElement.ToString(FrontSpace: String): String;
Begin
  If (fLat = -1) And (FLon = -1) Then Begin
    result := '{"dto":{"ut":"' + fUserToken + '"}}';
  End
  Else Begin
    result := '{"dto":{"data":{"lat":' + floattostr(flat, DefFormat) + ',"lng":' + floattostr(FLon, DefFormat) + '},"ut":"' + fUserToken + '"}}';
  End;
End;

{ THintElement }

Constructor THintElement.Create(Hint, UserToken: String);
Begin
  fHint := Hint;
  fUserToken := UserToken;
End;

Function THintElement.ToString(FrontSpace: String): String;
Begin
  // TODO: Rauskriegen ob das mit den FAVS noch geht !
  Result := '{"dto":{"et":' + StringToJsonString(fHint) + ',"ut":"' + fUserToken + '"}}';
End;

{ TGCLog }

Constructor TGCLog.Create();
Begin

End;

Function TGCLog.ToString(FrontSpace: String): String;
Begin
  // TODO: Rauskriegen ob das mit den FAVS noch geht !
  Result :=
    '{' +
    '"geocache": {' +
    '"id":' + ID + ',' +
    '"referenceCode":"' + GC_Code + '"' +
    '}, ' +
    '"callerSpecific": {' +
    ' "found":"' + LogDate + '",' +
    ' "favorited":' + Fav +
    '},' +
    '"logType":"' + LogType + '",' +
    '"logDate":"' + LogDate + '",' +
    '"logText":' + StringToJsonString(LogText) + ',' +
    '"usedFavoritePoint":' + Fav +
    '}';
End;

(*
{ attachImageRequest }

Constructor attachImageRequest.Create(Guid, ThumbnailURL: String);
Begin
  fGuid := Guid;
  fThumbnailURL := ThumbnailURL;
End;

Function attachImageRequest.ToString(FrontSpace: String): String;
Begin
// Das ist alles was die c:geo web API bereit stellt.
Result := '{' +
'"name":"",' +
//    '"uuid":"",' +
'"guid":"' + fGuid + '",' +
'"thumbnailUrl":"' + StringToJsonString(fThumbnailURL) + '",' +
'"dateTaken":"' + FormatDateTime('YYYY-MM-DD', Now) + '",' +
'"description":"",' +
//    '"qqButtonId":"b8613f43-aa43-49aa-ab14-d2564148c04f",' +
//    '"qqThumbnailId":0,' +
//    '"id":0,' +
//    '"filename":"smile.jpg",' +
//    '"lastModified":1575029233740,' +
//  '"webkitRelativePath":"",' +
//    '"size":4849,' +
'"type":"image\/jpeg"' +
'}';
End;
// *)

{ TrackableLog }

Constructor TrackableLog.Create(Action: TTBLogType; Date: String; GC_Code: String;
  ReferenceCode: String);
Begin
  Inherited create();
  fAction := Action;
  fDate := Date;
  fGC_Code := GC_Code;
  fReferenceCode := ReferenceCode;
End;

Function TrackableLog.ToString(FrontSpace: String): String;
Begin
  result := '{"logType":{"id":"' + TBLogStateToOption(fAction) + '"},"date":"' + fDate + '","geocache":{"gcCode":"' + fGC_Code + '"},"referenceCode":"' + fReferenceCode + '"}'
End;

{ TGCTool }

Constructor TGCTool.Create;
Begin
  Inherited Create;
  fServerParameters.UserInfo.Username := '';
  fMapSettings.UserSession := '';
  fClient := THTTPSend.Create;
  fClient.KeepAlive := true; // Braucht man das, ich weis es nicht ?
  fClient.UserAgent := 'Mozilla Firefox'; // Wir geben uns mal als jemand anders aus ;)
  FAPIToken.expires_at := now - 1; // das Token ist gestern Abelaufen
  fLoggedIn := false;
  fLabLoggedIn := false;
End;

Destructor TGCTool.Destroy;
Begin
  fClient.free;
End;

Function TGCTool.ExtractFormAuthToken: String;
Const
  TAG_NAME = '<input name="__RequestVerificationToken" type="hidden" value="';
Var
  CopyPos: Int64;
  HttpResponse: String;
  List: TStringList;
Begin
  result := '';
  list := TStringList.Create;
  CopyStreamToStrings(fClient.Document, list);
  HttpResponse := list.Text;
  list.free;
  (* Hier ermitteln wir das zweite Token, welches nur für den Login-Prozess genutzt wird. Das sollte man sicherlich eleganter machen,
     über DOM oder die Internet Tools. *)
  CopyPos := Pos(TAG_NAME, HttpResponse);
  If CopyPos <> 0 Then Begin
    HttpResponse := Copy(HttpResponse, CopyPos + Length(TAG_NAME), length(HttpResponse));
    Result := Copy2Symb(HttpResponse, '"');
  End;
End;

Procedure TGCTool.RemoveFormAuthToken;
Var
  i: Integer;
Begin
  For i := fClient.Cookies.Count - 1 Downto 0 Do Begin
    If pos('__RequestVerificationToken', fClient.Cookies[i]) <> 0 Then Begin
      fClient.Cookies.Delete(i);
    End;
  End;
End;

Function TGCTool.ExtractUserToken: String;
Var
  sl: TStringList;
  i: Integer;
  t: String;
Begin
  Result := '';
  sl := TStringList.Create;
  CopyStreamToStrings(fclient.Document, sl);
  For i := 0 To sl.Count - 1 Do Begin
    If pos('userToken = ''', sl[i]) <> 0 Then Begin
      t := sl[i];
      delete(t, 1, pos('''', t));
      delete(t, pos('''', t), length(t));
      result := t;
      break;
    End;
  End;
  sl.free;
End;

Function TGCTool.ExtractUserNote: String;
Var
  sl: TStringList;
  i: Integer;
Begin
  Result := '';
  sl := TStringList.Create;
  CopyStreamToStrings(fclient.Document, sl);
  For i := 0 To sl.Count - 1 Do Begin
    If result <> '' Then Begin
      // Mehrzeilige Notes
      result := result + LineEnding + sl[i];
    End
    Else Begin
      // Den Start Triggern
      If pos('id="srOnlyCacheNote"', sl[i]) <> 0 Then Begin
        result := copy(sl[i], pos('>', sl[i]) + 1, length(sl[i]));
      End;
    End;
    // Groundspeak ist so dämlich, dass die das Token im Note nicht zulassen, das macht das "ende" erkennen einfach ;)
    If pos('</div>', result) <> 0 Then Begin
      result := copy(result, 1, pos('</div>', result) - 1);
      break;
    End;
  End;
  sl.free;
End;

Procedure TGCTool.ExtractModifiedCoord(Out Lat: Double; Out Lon: Double);
Var
  sl: TStringList;
  i: Integer;
  s: String;
Begin
  lat := -1;
  lon := -1;
  sl := TStringList.Create;
  CopyStreamToStrings(fclient.Document, sl);
  For i := 0 To sl.Count - 1 Do Begin
    // -- Cache hat keine Modifizierten Koords
    // MapTilesEnvironment = 'production';ga('send', 'event', 'Geocaching', 'CacheDetailsMemberType', 'Premium');var userDefinedCoords = {"status":"success","data":{"isUserDefined":false,"oldLatLngDisplay":"N 48° 48.464' E 009° 23.070'"}};
    // -- Cache hat Modifizierte Koords
    // MapTilesEnvironment = 'production';ga('send', 'event', 'Geocaching', 'CacheDetailsMemberType', 'Premium');var userDefinedCoords = {"status":"success","data":{"isUserDefined":true,"newLatLng":[48.80775,9.3845166666666664],"oldLatLng":[48.807733,9.3845],"oldLatLngDisplay":"N 48° 48.464' E 009° 23.070'"}};
    If pos('"oldLatLngDisplay"', sl[i]) <> 0 Then Begin
      // Wenn der Cache überhaupt Korrigierte Koords hat, dann gibt es in dieser Zeile einen Eintrag "newLatLng"
      If pos('"newLatLng"', sl[i]) <> 0 Then Begin
        // "newLatLng":[48.80775,9.3845166666666664],"oldLatLng":[48.807733,9.3845],"oldLatLngDisplay":"N 48° 48.464' E 009° 23.070'"}};
        s := copy(sl[i], pos('"newLatLng"', sl[i]), length(sl[i]));
        // 48.80775,9.3845166666666664],"oldLatLng":[48.807733,9.3845],"oldLatLngDisplay":"N 48° 48.464' E 009° 23.070'"}};
        s := copy(s, pos('[', s) + 1, length(s));
        lat := StrToFloatDef(copy(s, 1, pos(',', s) - 1), -1, DefFormat);
        // 9.3845166666666664],"oldLatLng":[48.807733,9.3845],"oldLatLngDisplay":"N 48° 48.464' E 009° 23.070'"}};
        delete(s, 1, pos(',', s));
        lon := StrToFloatDef(copy(s, 1, pos(']', s) - 1), -1, DefFormat);
      End;
      break;
    End;
  End;
  sl.free;
End;

Procedure TGCTool.SetProxyHost(AValue: String);
Begin
  fClient.ProxyHost := AValue;
End;

Procedure TGCTool.SetProxyPass(AValue: String);
Begin
  fClient.ProxyPass := AValue;
End;

Procedure TGCTool.SetProxyPort(AValue: String);
Begin
  fClient.ProxyPort := AValue;
End;

Procedure TGCTool.SetProxyUser(AValue: String);
Begin
  fClient.ProxyUser := AValue;
End;

Procedure TGCTool.ExtractViewStates(Out __VIEWSTATES: TStringArray; Out
  __VIEWSTATEGENERATOR: String);
Var
  sl: TStringlist;
  states, i, j: Integer;
  b: Boolean;
  s: String;
Begin
  __VIEWSTATES := Nil;
  __VIEWSTATEGENERATOR := '';
  sl := TStringList.Create;
  CopyStreamToStrings(fClient.Document, sl);
  states := 1; // Wenn das __VIEWSTATEFIELDCOUNT feld nicht existiert mindestens eins annehmen !
  // Anzahl der Felder ermitteln
  For i := 0 To sl.count - 1 Do Begin
    If pos('id="__VIEWSTATEFIELDCOUNT" value="', sl[i]) <> 0 Then Begin
      s := copy(sl[i], pos('value="', sl[i]) + 1, length(sl[i]));
      s := copy(s, pos('"', s) + 1, length(s));
      s := copy(s, 1, pos('"', s) - 1);
      states := strtointdef(s, -1);
      break;
    End;
  End;
  If states <= 0 Then exit;
  setlength(__VIEWSTATES, states);
  For i := 0 To high(__VIEWSTATES) Do Begin
    __VIEWSTATES[i] := '';
  End;
  For i := 0 To sl.count - 1 Do Begin
    If pos('id="__VIEWSTATEGENERATOR" value="', sl[i]) <> 0 Then Begin
      __VIEWSTATEGENERATOR := copy(sl[i], pos('value="', sl[i]) + 1, length(sl[i]));
      __VIEWSTATEGENERATOR := copy(__VIEWSTATEGENERATOR, pos('"', __VIEWSTATEGENERATOR) + 1, length(__VIEWSTATEGENERATOR));
      __VIEWSTATEGENERATOR := copy(__VIEWSTATEGENERATOR, 1, pos('"', __VIEWSTATEGENERATOR) - 1);
    End;
    b := true;
    For j := 0 To high(__VIEWSTATES) Do Begin
      If j = 0 Then Begin
        s := '__VIEWSTATE';
      End
      Else Begin
        s := '__VIEWSTATE' + inttostr(j);
      End;
      If pos('name="' + s + '" id="' + s + '"', sl[i]) <> 0 Then Begin
        __VIEWSTATES[j] := copy(sl[i], pos('value="', sl[i]) + 1, length(sl[i]));
        __VIEWSTATES[j] := copy(__VIEWSTATES[j], pos('"', __VIEWSTATES[j]) + 1, length(__VIEWSTATES[j]));
        __VIEWSTATES[j] := copy(__VIEWSTATES[j], 1, pos('"', __VIEWSTATES[j]) - 1);
      End;
      If __VIEWSTATES[j] = '' Then b := false;
    End;
    If (__VIEWSTATEGENERATOR <> '') And b Then break;
  End;
  sl.free;
  For i := 0 To high(__VIEWSTATES) Do Begin
    If __VIEWSTATES[i] = '' Then Begin
      setlength(__VIEWSTATES, 0);
      __VIEWSTATEGENERATOR := '';
      exit;
    End;
  End;
End;

Function TGCTool.postAPI(Path: String; Filename: String): String;
Var
  guids: String;
  guid: TGuid;
  f: TFilestream;
  body: TStringlist;
  mfd: TMultiPartFormDataStream;
Begin
  mfd := TMultiPartFormDataStream.Create;
  result := '';
  If CreateGUID(guid) <> 0 Then Begin
    fLastError := fLastError + LineEnding + 'Could not create guid';
    exit;
  End;
  guids := GUIDToString(guid);
  guids := copy(guids, 2, length(guids) - 2); // die GUID ist in { } eingefasst, das muss wieder weg.

  RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig

  // Füllen mit den Nutzdaten
  mfd.AddFormField('guid', guids);

  f := TFileStream.Create(Filename, fmOpenRead);
  mfd.AddFormField('qqfilename', ExtractFileName(Filename));
  mfd.AddFormField('qqtotalfilesize', inttostr(f.Size));
  mfd.AddFile('qqfile', ExtractFileName(Filename), 'image/jpeg', f);
  f.free;

  // Übernehmen der mfd in das zu sendende Dokument
  mfd.PrepareStreamForDispatch;

  fClient.Clear; // Löscht Header, Body und Mimetype
  fClient.MimeType := mfd.RequestContentType;
  fClient.Headers.Add('Accept: application/json');
  fClient.Headers.Add('Accept-Language: de,en-US;q=0.7,en;q=0.3');
  fClient.Headers.Add('Accept-Encoding: gzip, deflate, br');

  fClient.Document.CopyFrom(mfd, mfd.size);
  mfd.free;

  // und Raus ;-)
  fClient.HTTPMethod('POST', API_URL + path);

  // Auswerten der Antwort
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  result := body.text;
  body.free;
  If fClient.ResultCode <> 201 Then Begin
    fLastError := fLastError + 'HTML Error: ' + inttostr(fClient.ResultCode) + LineEnding + Result;
    result := '';
  End;
End;

Function TGCTool.postAPI(Path: String; Params: TJSONObj): String;
Begin
  result := postJSON(API_URL + path, Params);
End;

Function TGCTool.postJSON(URL: String; Params: TJSONObj; AddToHeader: String): String;
Var
  body: TStringlist;
  t: String;
Begin
  result := '';
  RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig
  fClient.Clear; // Löscht Header, Body und Mimetype
  fClient.MimeType := 'application/json';
  If AddToHeader <> '' Then Begin
    fClient.Headers.Add(AddToHeader);
  End;
  body := TStringList.Create;
  t := params.ToString();
  body.Add(t);
  CopyStringsToStream(body, fClient.Document);
  body.free;
  fClient.HTTPMethod('POST', URL);
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  result := body.text;
  body.free;
  If fClient.ResultCode <> 200 Then Begin
    fLastError := fLastError + 'HTML Error: ' + inttostr(fClient.ResultCode) + LineEnding + Result;
    result := '';
  End;
End;

Function TGCTool.patchAPI(Path: String): String;
Var
  body: TStringlist;
Begin
  result := '';
  RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig
  fClient.Clear; // Löscht Header, Body und Mimetype
  fClient.MimeType := 'application/json';
  fClient.HTTPMethod('PATCH', API_URL + path);
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  result := body.text;
  body.free;
  If fClient.ResultCode <> 200 Then Begin
    fLastError := fLastError + 'HTML Error: ' + inttostr(fClient.ResultCode) + LineEnding + Result;
    result := '';
  End;
End;

Function TGCTool.getAPI_LAB(Path: String; Params: String): String;
Var
  body: TStringlist;
Begin
  result := '';
  RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig
  fClient.Clear; // Löscht Header, Body und Mimetype
  //fClient.MimeType := 'application/json';
  // Dieser Get sendet nichts, ...
  //body := TStringList.Create;
  //t := params.ToString();
  //body.Add(t);
  //CopyStringsToStream(body, fClient.Document);
  //body.free;
  params := trim(params);
  If params <> '' Then Begin
    params := '?' + Params;
  End;
  fClient.Headers.Add('X-Consumer-Key: ' + LAB_CONSUMER_KEY);
  fClient.HTTPMethod('GET', API_LAB_URL + path + Params);
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  result := body.text;
  body.free;
  If fClient.ResultCode <> 200 Then Begin
    fLastError := fLastError + 'HTML Error: ' + inttostr(fClient.ResultCode) + LineEnding + Result;
    result := '';
  End;
End;

Function TGCTool.getAPI(Path: String; Params: String): String;
Var
  body: TStringlist;
Begin
  result := '';
  RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig
  fClient.Clear; // Löscht Header, Body und Mimetype
  //fClient.MimeType := 'application/json';
  // Dieser Get sendet nichts, ...
  //body := TStringList.Create;
  //t := params.ToString();
  //body.Add(t);
  //CopyStringsToStream(body, fClient.Document);
  //body.free;
  params := trim(params);
  If params <> '' Then Begin
    params := '?+params&' + Params;
  End;
  fClient.HTTPMethod('GET', API_URL + path + Params);
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  result := body.text;
  body.free;
  If fClient.ResultCode <> 200 Then Begin
    fLastError := fLastError + 'HTML Error: ' + inttostr(fClient.ResultCode) + LineEnding + Result;
    result := '';
  End;
End;

(*
Function TGCTool.getAPI(Path: String; params: TKeyValueArray): String;
Var
  body: TStringlist;
  i: Integer;
  t: String;
Begin
  result := '';
  RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig
  fClient.Clear; // Löscht Header, Body und Mimetype
  fClient.MimeType := 'application/x-www-form-urlencoded; charset=UTF-8';
  body := TStringList.Create;
  t := '';
  For i := 0 To high(params) Do Begin
    t := t + EncodeURI(params[i].key) + '=' + EncodeURI(params[i].Value);
    If i <> high(params) Then t := t + '&';
  End;
  body.Add(t);
  CopyStringsToStream(body, fClient.Document);
  body.free;
  fClient.HTTPMethod('GET', API_URL + path);
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  result := body.text;
  body.free;
  If fClient.ResultCode <> 200 Then Begin
    fLastError := fLastError + 'HTML Error: ' + inttostr(fClient.ResultCode) + LineEnding + Result;
    result := '';
  End;
End;

Function TGCTool.getAPI(Path: String; Params: TJSONObj): String;
Var
  body: TStringlist;
  t: String;
Begin
  result := '';
  RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig
  fClient.Clear; // Löscht Header, Body und Mimetype
  fClient.MimeType := 'application/json';
  body := TStringList.Create;
  t := params.ToString();
  body.Add(t);
  CopyStringsToStream(body, fClient.Document);
  body.free;
  fClient.HTTPMethod('GET', API_URL + path);
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  result := body.text;
  body.free;
  If fClient.ResultCode <> 200 Then Begin
    fLastError := fLastError + 'HTML Error: ' + inttostr(fClient.ResultCode) + LineEnding + Result;
    result := '';
  End;
End; // *)

(**
 * Sends trackable logs in groups of 10.
 * https://github.com/cgeo/cgeo/issues/7249
 *
 * https://www.geocaching.com/api/proxy/trackable/activities
 * <div>
 *   "postData": {
 *       "mimeType": "application/json",
 *       "text": "[{"logType":{"id":"75"},"date":"2017-08-19","geocache":{"gcCode":"GC..."},"referenceCode":"TB..."}]"
 *   }
 * </div>
 *)

Function TGCTool.postLogTrackable(GC_Code: String; logDate: String;
  Tbs: TStringArray): Boolean;
Var
  i: integer;
  trackableLogs: TJSONArray;
  tbl: TrackableLog;
Begin
  trackableLogs := TJSONArray.Create;
  For i := 0 To high(Tbs) Do Begin
    // if (tb.action != LogTypeTrackable.DO_NOTHING && tb.brand == TrackableBrand.TRAVELBUG) {
    tbl := TrackableLog.Create(tlVisited, logDate, GC_Code, tbs[i]); // Aktuell unterstützen wir nur "besucht"
    trackableLogs.AddObj(tbl);
    // }
    If trackableLogs.ObjCount = 10 Then Begin
      If postLogTrackable(trackableLogs) Then Begin
        trackableLogs.Clear;
      End
      Else Begin
        trackableLogs.free;
        result := false;
        exit;
      End;
    End;
  End;
  result := (trackableLogs.ObjCount = 0) Or postLogTrackable(trackableLogs);
  trackableLogs.free;
End;

Function TGCTool.postLogTrackable(trackableLogs: TJSONArray): Boolean;
Var
  response: String;
Begin
  result := false;
  response := postAPI('/trackable/activities', trackableLogs);
  If (pos('"referencecode"', lowercase(response)) <> 0) Then Begin
    result := true;
  End;
End;

Function TGCTool.getServerParameters: TServerParameters;
Var
  sl: TStringlist;
  s: String;
  p: TJSONParser;
  jo: TJSONObj;
  ui, ao, n: TJSONNode;
Begin
  If fServerParameters.UserInfo.Username <> '' Then Begin
    result := fServerParameters;
  End
  Else Begin
    fClient.Clear;
    fclient.HTTPMethod('GET', 'https://www.geocaching.com/play/serverparameters/params');
    sl := TStringList.Create;
    CopyStreamToStrings(fClient.Document, sl);
    s := sl.Text;
    sl.free;
    // Die Antwort ist in JSON, also nutzen wir doch den JSON Parser ;)
    s := copy(s, pos('{', s) - 1, length(s));
    s := trim(s);
    If (length(s) <> 0) And (s[length(s)] = ';') Then Begin
      delete(s, length(s), 1);
    End;
    p := TJSONParser.Create;
    jo := p.Parse(s);
    p.free;
    If assigned(jo) Then Begin
      Try
        n := jo As TJSONNode;
        // user:info
        ui := (n.Obj[0] As TJSONNodeObj).Value As TJSONNode;
        fServerParameters.UserInfo.Username := (ui.Obj[0] As TJSONValue).Value;
        fServerParameters.UserInfo.ReferenceCode := (ui.Obj[1] As TJSONValue).Value;
        fServerParameters.UserInfo.Usertype := (ui.Obj[2] As TJSONValue).Value;
        // 3 = isLoggedIn
        fServerParameters.UserInfo.DateFormat := (ui.Obj[4] As TJSONValue).Value;
        fServerParameters.UserInfo.UnitSetName := (ui.Obj[5] As TJSONValue).Value;
        fServerParameters.UserInfo.Roles :=
          (((ui.Obj[6] As TJSONNodeObj).Value As TJSONArray).Obj[0] As TJSONTerminal).Value + ',' +
          (((ui.Obj[6] As TJSONNodeObj).Value As TJSONArray).Obj[1] As TJSONTerminal).Value;
        fServerParameters.UserInfo.publicGUID := (ui.Obj[7] As TJSONValue).Value;
        fServerParameters.UserInfo.AvatarURL := (ui.Obj[8] As TJSONValue).Value;
        // app:options
        ao := (n.Obj[1] As TJSONNodeObj).Value As TJSONNode;
        fServerParameters.appOptions.LocalRegion := (ao.Obj[0] As TJSONValue).Value;
        fServerParameters.appOptions.CoordInfoURL := (ao.Obj[1] As TJSONValue).Value;
        fServerParameters.appOptions.PaymentURL := (ao.Obj[2] As TJSONValue).Value;
      Except
        On av: exception Do Begin
          fServerParameters.UserInfo.Username := '';
          fLastError := fLastError + 'getServerParameters: ' + av.Message;
        End;
      End;
      jo.Free;
    End;
    result := fServerParameters
  End;
End;

Function TGCTool.getMapSettings: TMapSettings;
Var
  body: TStringList;
  s: String;
  i: Integer;
Begin
  If fMapSettings.UserSession = '' Then Begin
    // Anfragen der default Map Seite, damit wir an das Session Token kommen
    fClient.Clear;
    fClient.HTTPMethod('GET', 'https://www.geocaching.com/map/default.aspx');
    Follow_Links('https://www.geocaching.com/map/default.aspx');
    body := TStringList.Create;
    CopyStreamToStrings(fclient.Document, body);
    (*
    Das sind die paar Relevanten Zeilen Code die wir suchen.
    MapSettings.User.Session = new Groundspeak.UserSession('H3VFZ', {userOptions:'XPTf', sessionToken:'DUXIzP', subscriberType: 3, enablePersonalization: true });
    MapSettings.User.Home = { "lat":48.80179, "lng":9.39188 };
    ga('send', 'event', 'Geocaching', 'Map', 'Load-Google');MapSettings.MapBaseUrl = '//tiles0{s}.geocaching.com/';
    *)
    For i := 0 To body.Count - 1 Do Begin
      If pos('new Groundspeak.UserSession(', body[i]) <> 0 Then Begin
        s := body[i];
        s := copy(s, pos('''', s) + 1, length(s)); // Löschen "MapSettings.User.Session = new Groundspeak.UserSession('"
        fMapSettings.UserSession := copy(s, 1, pos('''', s) - 1); // Kopieren der UserSession
        s := copy(s, pos('''', s) + 1, length(s)); // Löschen "H3VFZ'"
        s := copy(s, pos('''', s) + 1, length(s)); // Löschen ", {userOptions:'"
        fMapSettings.userOptions := copy(s, 1, pos('''', s) - 1); // Kopieren der userOptions
        s := copy(s, pos('''', s) + 1, length(s)); // Löschen "XPTf'"
        s := copy(s, pos('''', s) + 1, length(s)); // Löschen ", sessionToken:'"
        fMapSettings.SessionToken := copy(s, 1, pos('''', s) - 1); // Kopieren der sessionToken
        s := copy(s, pos('''', s) + 1, length(s)); // Löschen "DUXIzP'"
        s := copy(s, pos(':', s) + 1, length(s)); // Löschen ", subscriberType:"
        fMapSettings.subscriberType := strtointdef(trim(copy(s, 1, pos(',', s) - 1)), 0);
        s := copy(s, pos(':', s) + 1, length(s)); // Löschen ", enablePersonalization:"
        fMapSettings.enablePersonalization := lowercase(trim(copy(s, 1, pos('}', s) - 1))) = 'true';
      End;
      If pos('MapSettings.User.Home = {', body[i]) <> 0 Then Begin
        s := body[i];
        s := copy(s, pos(':', s) + 1, length(s)); // Löschen "MapSettings.User.Home = { "lat":"
        fMapSettings.Home_lat := StrToFloatDef(trim(copy(s, 1, pos(',', s) - 1)), 0.0, DefFormat);
        s := copy(s, pos(':', s) + 1, length(s)); // Löschen "48.80179, "lng":"
        fMapSettings.Home_lon := StrToFloatDef(trim(copy(s, 1, pos('}', s) - 1)), 0.0, DefFormat);
      End;
      If pos('MapSettings.MapBaseUrl =', body[i]) <> 0 Then Begin
        s := body[i];
        s := copy(s, pos('//', s), length(s)); // Löschen "ga('send', 'event', 'Geocaching', 'Map', 'Load-Google');MapSettings.MapBaseUrl = '"
        fMapSettings.MapBaseUrl := copy(s, 1, pos('''', s) - 1);
        break; // Nun haben wir alles also Raus
      End;
    End;
    body.free;
    // TODO: Evtl noch prüfen ob was wir geladen haben auch Sinnvoll und Richtig ist, wenn Unsinnig : fMapSettings.UserSession := '';
  End;
  result := fMapSettings;
End;

Function TGCTool.Login: Boolean;

(*
 * Stellt bei Bedarf auf En um,
 * true, wenn eine Umstellung durchgeführt wurde.
 * false, wenn schon Englisch war
 *)
  Function SwitchToEnglish(): Boolean;
  Var
    List: TStringList;
    b: Boolean;
    i: integer;
  Begin
    result := false;
    list := TStringList.Create;
    CopyStreamToStrings(fClient.Document, list);
    // 1. Prüfen ob wir schon auf En stehen
    b := false;
    For i := 0 To list.count - 1 Do Begin
      If b Then Begin
        If pos('class="selected"', list[i]) <> 0 Then Begin
          If pos('>English<', list[i]) <> 0 Then Begin
            // Sind schon auf Eng, also Raus
            list.free;
            exit;
          End
          Else Begin
            // Nicht Englisch
            break;
          End;
        End;
        If pos('</div>', list[i]) <> 0 Then break;
      End
      Else Begin
        If pos('<div class="language-dropdown', list[i]) <> 0 Then Begin
          b := true;
        End;
      End;
    End;
    // 2. Wir sind offensichtlich nicht eng -> Umschalten auf Eng
    list.free;
    result := true;
    fClient.Headers.Clear;
    fClient.HTTPMethod('GET', 'https://www.geocaching.com/play/culture/set?model.SelectedCultureCode=en-US');
    //If fClient.ResultCode = 302 Then Begin
    //  -- Wenn die weiterleitung kommt, dann hat das mit der Sprachumschaltung funktioniert.
    //End;
  End;

  Function GetAuthToken_: String;
  Begin
    (* Alter Header vom vorherigen Request/Response löschen. *)
    fClient.Headers.Clear;
    (* Bevor wir den Login-Prozess starten können, benötigen wir das Token für den Login-Vorgang. Dazu starten wir einen Aufruf auf /account/login,
       holen uns also das HTML-Formular. *)
    fClient.HTTPMethod('GET', LOGIN_URL);
    Follow_Links(LOGIN_URL);
    If SwitchToEnglish() Then Begin
      fClient.Headers.Clear;
      fClient.HTTPMethod('GET', LOGIN_URL);
      Follow_Links(LOGIN_URL);
    End;
    result := ExtractFormAuthToken;
    If (trim(result) = '') Or (fClient.ResultCode <> 200) Then Begin
      fLastError := 'HTTP.ResultCode: ' + inttostr(fClient.ResultCode) + ' ; ' + fClient.ResultString + LineEnding +
        'HTTP.Sock.LastError: ' + inttostr(fClient.Sock.LastError) + ' ; ' + fClient.Sock.LastErrorDesc + LineEnding +
        'HTTP.Sock.SSL.LastError: ' + inttostr(fClient.Sock.SSL.LastError) + ' ; ' + fClient.Sock.SSL.LastErrorDesc;
      (*
       * Wenns nicht klappt, eine Abhilfe schafft evtl:
       *
       *   sudo aptitude install libssl-dev
       *)
      result := '';
    End;
  End;
Var
  Request: TStringList;
  FormAuthToken_: String;
Begin
  (*
   * Wenn was nicht geht im FF mittels "STRG" + "SHIFT" + "K" den Netzwerk analysator starten
   * dann rechts "Persistent logs" oder "Logs nicht leeren" und ab gehts zum Debuggen.
   *)
  result := false;
  fLoggedIn := false;
  fLastError := '';
  fServerParameters.UserInfo.Username := '';
  fMapSettings.UserSession := '';
  If (trim(Username) = '') Or (trim(Password) = '') Then Begin
    fLastError := 'Invalid username or password.';
    exit;
  End;
  (*
   * Initialisier der Verbindung
   *)
  fClient.Clear;
  RemoveFormAuthToken;
  FormAuthToken_ := GetAuthToken_(); // Login Authentifizierung hohlen
  If FormAuthToken_ = '' Then exit; // Kein Token, kein Login
  Try
    (* Zuerst basteln wir uns den Login_Request zusammen. Das Format ist der Standard für codierte Formulare. EncodeURLElelement ist wichtig,
       damit Sonderzeichen vernünftig übertragen werden. *)
    Request := TStringList.Create;
    Request.Add('__RequestVerificationToken=' + FormAuthToken_ + '&'
      + 'UsernameOrEmail=' + EncodeURLElement(Username) + '&'
      + 'Password=' + EncodeURLElement(Password) + '&');
    (* Den ertsellten Request kopieren wir in das Document des Client. Dieses wird dann beim Ausführen von HTTPMethod als Content gesendet. *)
    CopyStringsToStream(Request, fClient.Document);
    (* Wichtig: Korrekten MimeType für den Request senden. Sonst nimmt der Server das nicht an. *)
    fClient.MimeType := 'application/x-www-form-urlencoded';
    (* Alter Header vom vorherigen Request/Response löschen. *)
    fClient.Headers.Clear;
    fClient.HTTPMethod('POST', LOGIN_URL);
    (* Nach erfolgreichen Login will der Server uns an die Übersichtsseite weiterleiten. Interessiert uns in diesem Fall nicht,
       wir wollen nur wissen ob der Login geklappt hat. Kommt als 302 als Status für Weiterleitung zurück, ist alles in Ordnung. *)
    Result := (fClient.ResultCode = 302);
    //    CopyStreamToStrings(fClient.Document, form1.SynEdit1.Lines);
    If Not result Then Begin
      If (fClient.ResultCode = 200) Then Begin
        fLastError := 'Geocaching password was not accepted, please double check the writing of your username and password.';
        Request.Clear;
        //        CopyStreamToStrings(fclient.Document, Request); -- Debugg
        //        Request.SaveToFile('/sda5/sda5/Temp/result.html'); -- Debugg
      End
      Else Begin
        fLastError := 'Unable to log in : ' + LineEnding +
          'HTTP.ResultCode: ' + inttostr(fClient.ResultCode) + ' ; ' + fClient.ResultString + LineEnding +
          'HTTP.Sock.LastError: ' + inttostr(fClient.Sock.LastError) + ' ; ' + fClient.Sock.LastErrorDesc + LineEnding +
          'HTTP.Sock.SSL.LastError: ' + inttostr(fClient.Sock.SSL.LastError) + ' ; ' + fClient.Sock.SSL.LastErrorDesc;
      End;
    End;
  Finally
    FreeAndNil(Request);
  End;
  fLoggedIn := result;
End;

Function TGCTool.LabLogin: Boolean;
Var
  Request: TStringList;
  auth: String;
Begin
  (*
   * Wenn was nicht geht im FF mittels "STRG" + "SHIFT" + "K" den Netzwerk analysator starten
   * dann rechts "Persistent logs" oder "Logs nicht leeren" und ab gehts zum Debuggen.
   *)
  result := false;
  fLabLoggedIn := false;
  fLastError := '';
  If (trim(Username) = '') Or (trim(Password) = '') Then Begin
    fLastError := 'Invalid username or password.';
    exit;
  End;
  RemoveFormAuthToken;
  fClient.Clear;
  fClient.HTTPMethod('GET', LAB_Login_URL);
  Follow_Links(LAB_Login_URL);
  auth := ExtractFormAuthToken();
  If (trim(auth) = '') Or (fClient.ResultCode <> 200) Then Begin
    fLastError := 'HTTP.ResultCode: ' + inttostr(fClient.ResultCode) + ' ; ' + fClient.ResultString + LineEnding +
      'HTTP.Sock.LastError: ' + inttostr(fClient.Sock.LastError) + ' ; ' + fClient.Sock.LastErrorDesc + LineEnding +
      'HTTP.Sock.SSL.LastError: ' + inttostr(fClient.Sock.SSL.LastError) + ' ; ' + fClient.Sock.SSL.LastErrorDesc;
    (*
     * Wenns nicht klappt, eine Abhilfe schafft evtl:
     *
     *   sudo aptitude install libssl-dev
     *)
    result := false;
    exit;
  End;
  Try
    (* Zuerst basteln wir uns den Login_Request zusammen. Das Format ist der Standard für codierte Formulare. EncodeURLElelement ist wichtig,
       damit Sonderzeichen vernünftig übertragen werden. *)
    Request := TStringList.Create;
    Request.Add('__RequestVerificationToken=' + auth + '&'
      + 'Username=' + EncodeURLElement(Username) + '&'
      + 'Password=' + EncodeURLElement(Password) + '&');
    (* Den ertsellten Request kopieren wir in das Document des Client. Dieses wird dann beim Ausführen von HTTPMethod als Content gesendet. *)
    CopyStringsToStream(Request, fClient.Document);
    (* Wichtig: Korrekten MimeType für den Request senden. Sonst nimmt der Server das nicht an. *)
    fClient.MimeType := 'application/x-www-form-urlencoded';
    (* Alter Header vom vorherigen Request/Response löschen. *)
    fClient.Headers.Clear;
    fClient.HTTPMethod('POST', LAB_Login_URL);
    (* Nach erfolgreichen Login will der Server uns an die Übersichtsseite weiterleiten. Interessiert uns in diesem Fall nicht,
       wir wollen nur wissen ob der Login geklappt hat. Kommt als 302 als Status für Weiterleitung zurück, ist alles in Ordnung. *)
    Result := (fClient.ResultCode = 302);
    //    CopyStreamToStrings(fClient.Document, form1.SynEdit1.Lines);
    If Not result Then Begin
      If (fClient.ResultCode = 200) Then Begin
        fLastError := 'Geocaching password was not accepted, please double check the writing of your username and password.';
        Request.Clear;
        //        CopyStreamToStrings(fclient.Document, Request); -- Debugg
        //        Request.SaveToFile('/sda5/sda5/Temp/result.html'); -- Debugg
      End
      Else Begin
        fLastError := 'Unable to log in : ' + LineEnding +
          'HTTP.ResultCode: ' + inttostr(fClient.ResultCode) + ' ; ' + fClient.ResultString + LineEnding +
          'HTTP.Sock.LastError: ' + inttostr(fClient.Sock.LastError) + ' ; ' + fClient.Sock.LastErrorDesc + LineEnding +
          'HTTP.Sock.SSL.LastError: ' + inttostr(fClient.Sock.SSL.LastError) + ' ; ' + fClient.Sock.SSL.LastErrorDesc;
      End;
    End;
  Finally
    FreeAndNil(Request);
  End;
  fLabLoggedIn := result;
End;

Procedure TGCTool.Logout;
Begin
  fLoggedIn := false;
  fLabLoggedIn := false;
  fClient.Cookies.Clear;
  fClient.Clear;
End;

Function TGCTool.postLog(Log: TFieldNote): Boolean;

  Function ProblemtoComment(pt: TReportProblemLogType): String;
  Begin
    Case pt Of
      rptLogfull: result := R_NM_Logbook_Full;
      rptdamaged: result := R_NM_Container_damaged;
      rptmissing: result := R_NM_Container_missing;
      rptarchive: result := R_NM_Needs_Archive;
      //      rptNoProblem: result := ;
      rptOther: result := R_NM_Other;
    Else Begin
        result := r_unknown;
      End;
    End;
  End;

  Function ProblemToLogtype(pt: TReportProblemLogType): TLogtype;
  Begin
    result := ltWriteNote; // Wir wissen es nicht
    Case pt Of
      rptNoProblem: result := ltWriteNote;
      rptLogfull: result := ltNeedsMaintenance;
      rptDamaged: result := ltNeedsMaintenance;
      rptMissing: result := ltNeedsMaintenance;
      rptArchive: result := ltNeedsArchive;
      rptOther: result := ltNeedsMaintenance;
    End;
  End;

Var
  (*  attachImageResponse, thumbnailUrl,//*)
  guid, logref, patchresponse, postimageresponse, response, logInfo, logDate: String;
  lg: TFieldNote;
  PostImage: Boolean;
  jp: TJSONParser;
  jo: TJSONObj;
  jLog: TGCLog;
  (* aIR: attachImageRequest; //*)
Begin
  result := false;
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  fLastError := '';

  If log.Fav And (log.Logtype <> ltFoundit) Then Begin
    fLastError := 'Error Favourite point logging is only allowed on "Webcam Photo taken" / "Found it" logs.';
    exit;
  End;

  //if (StringUtils.isBlank(log)) {
  //          Log.w("GCWebAPI.postLog: No log text given");
  //          return new ImmutablePair<>(StatusCode.NO_LOG_TEXT, "");
  //      }

{$IFDEF Linux}
  logInfo := trim(StringReplace(log.Comment, LineEnding, #13#10, [rfReplaceAll])); // windows' eol and remove leading and trailing whitespaces
{$ELSE}
  logInfo := trim(log.Comment);
{$ENDIF}

  // Log.i("Trying to post log for cache #" + geocache.getCacheId() + " - action: " + logType
  //        + "; date: " + date + ", log: " + logInfo
  //        + "; trackables: " + trackables.size());
  PostImage := false;

  If (log.Image <> '') And FileExistsUTF8(log.Image) Then Begin // Das Bild als Draft hochladen
    postimageresponse := postAPI('/web/v1/LogDrafts/images', log.Image);
    If pos('success', lowercase(postimageresponse)) <> 0 Then Begin
      PostImage := true;
    End
    Else Begin
      fLastError := fLastError + 'Unable to upload: "' + log.Image + '"';
      exit;
    End;
  End;

  logDate := formatGCDate(StrToTime(log.date));

  //   Make the post body
  jLog := TGCLog.Create();
  jLog.Id := inttostr(GCCodeToGCiD(Log.GC_Code));
  jLog.GC_Code := Log.GC_Code;
  jLog.Fav := formatBoolean(log.Fav);
  jLog.LogType := LogStateToOption(log.Logtype);
  jLog.LogDate := logDate;
  jLog.LogText := logInfo;

  response := postAPI('/web/v1/geocache/' + lowerCase(Log.GC_Code) + '/GeocacheLog', jLog);
  jLog.free;
  If pos('"referencecode"', lowercase(response)) = 0 Then Begin // Eigentlich müssten wir das Ergebnis JSON technisch analysieren, da wir das aber wegschmeisen reicht es auch auf das "Feld" direkt zu prüfen ;)
    fLastError := fLastError + LineEnding + 'Could not log cache "' + Log.GC_Code + '" as requested, logtype "' + LogtypeToString(log.Logtype) + '" is not available.';
    exit;
  End;
  If Not (postLogTrackable(log.GC_Code, logDate, log.TBs)) Then Begin
    fLastError := fLastError + LineEnding + 'Could not log travel bugs, for "' + Log.GC_Code + '" [HTMLResult=' + inttostr(fClient.ResultCode) + ']';
    exit;
  End;
  If PostImage Then Begin
    jp := TJSONParser.Create;
    // 1. Patch Bild auf Log
    // 1.1 Extrahieren GUID aus dem Image Responce
    jo := jp.Parse(postimageresponse);
    If Not assigned(jo) Then Begin
      fLastError := fLastError + LineEnding + 'Could not extract GUID from image upload result.';
      jp.free;
      exit;
    End;
    guid := (jo.FindPath('guid') As TJSONValue).Value;
    (* thumbnailUrl := (jo.FindPath('thumbnailUrl') As TJSONValue).Value; //*)
    jo.free;
    // 1.2 Extrahieren LOG-Referencecode Log Responce
    jo := jp.Parse(response);
    logref := (jo.FindPath('referenceCode') As TJSONValue).Value;
    jo.free;
    patchresponse := patchAPI('/web/v1/LogDrafts/images/' + guid + '?geocacheLogReferenceCode=' + logref);
    If pos(lowercase(guid), lowercase(patchresponse)) = 0 Then Begin
      fLastError := fLastError + LineEnding + 'Could not patch image to log.';
      jp.free;
      exit;
    End;
    jp.free;
    // 2. Attach image to log
    // TODO: Rauskriegen ob das immer der Fall ist.
    (* -- Es geht auch ohne ..
    aIR := attachImageRequest.Create(guid, thumbnailUrl);
    attachImageResponse := postAPI('/web/v1/geocaches/logs/' + logref + '/images/' + guid, aIR);
    air.free;

    // Eigentlich sollte GC mit:
{
  "guid":"2d140184-2b41-4817-8423-65c16dba94b8",
  "name":"",
  "description":"",
  "dateTaken":"2019-11-29T00:00:00"
}
     // Antworten, aber das geschieht nicht, warum ist noch nicht verstanden. Das Bild wird online angezeigt und sieht gut aus ..

    If attachImageResponse = '' Then Begin
      fLastError := fLastError + 'Error, could not attach image to log.';
      exit;
    End;
    // *)
  End;
  If log.reportProblem <> rptNoProblem Then Begin
    lg.GC_Code := log.GC_Code;
    lg.Date := log.Date;
    lg.Logtype := ProblemToLogtype(log.reportProblem);
    lg.Comment := ProblemtoComment(log.reportProblem);
    lg.TBs := Nil;
    lg.Fav := false;
    lg.reportProblem := rptNoProblem;
    lg.Image := '';
    postLog(lg);
  End;
  // Log.i("Log successfully posted to cache #" + geocache.getCacheId());
  result := true;
End;

Function TGCTool.GetFindCount: String;
  Function ExtractFindsCount(): String;
  Const
    TAG_NAME = '"findCount": ';
  Var
    CopyPos: Int64;
    List: TSTringlist;
    HttpResponse: String;
  Begin
    List := TStringList.Create;
    CopyStreamToStrings(fClient.Document, list);
    HttpResponse := list.text;
    list.free;
    (* Suchaktion für den Find Count auf der Geocachingseite. Das nur als kleines Gimmick für den Nutzer. *)
    CopyPos := Pos(TAG_NAME, HttpResponse);
    HttpResponse := Copy(HttpResponse, CopyPos + Length(TAG_NAME), length(HttpResponse));
    Result := Copy2Symb(HttpResponse, ',');
  End;
Begin
  result := '';
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  fLastError := '';
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', GeocacheDashBoardURL);
  follow_Links(GeocacheDashBoardURL);
  If fClient.ResultCode <> 200 Then Begin
    fLastError := 'Could not extract log count. [HTMLResult=' + inttostr(fClient.ResultCode) + ']';
    exit;
  End;
  Result := ExtractFindsCount();
End;

Function TGCTool.GetPocketQueries: TPocketQueries;
(* -- Das wäre zwar Cool und der erste Schritt der Anfrage der Liste klappt auch,
      doch die Liste beinhaltet nur Referenzcodes und die müssen erst noch in DL-Links aufgelöst werden
      und wie das geht ist noch nicht bekannt !
Var
  sl: TStringList;
Begin
  result := Nil;
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  fLastError := '';
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', 'https://www.geocaching.com/api/proxy/web/v1/lists?type=' + 'pq');
  If fClient.ResultCode <> 200 Then Begin
    fLastError := 'Error got html errorcode: ' + inttostr(fClient.ResultCode);
    exit;
  End;
  sl := TStringList.Create;
  CopyStreamToStrings(fClient.Document, sl);
  sl.SaveToFile('erg.JSON'); -- Bis hier her gehts
  sl.free;
  fClient.HTTPMethod('GET', 'https://geocaching.com/api/proxy/web/v1/lists/'+'PQJH61P' + '/geocaches/zipped');
  If fClient.ResultCode <> 200 Then Begin
    fLastError := 'Error got html errorcode: ' + inttostr(fClient.ResultCode);
    exit;
  End;
  sl := TStringList.Create;
  CopyStreamToStrings(fClient.Document, sl);
  sl.SaveToFile('erg.zip');
  sl.free;
End; *)
Var
  sl: TStringList;
  i, state: Integer;
  s: String;
Begin
  result := Nil;
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  fLastError := '';
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', PocketQueryURL);
  follow_Links(PocketQueryURL);
  If fClient.ResultCode <> 200 Then Begin
    fLastError := 'Could not extract pocket queries. [HTMLResult=' + inttostr(fClient.ResultCode) + ']';
    exit;
  End;
  sl := TStringList.Create;
  CopyStreamToStrings(fClient.Document, sl);
  state := 0;
  For i := 0 To sl.count - 1 Do Begin
    Case State Of
      0: Begin // Finden des Begins der Tabelle die die Links hällt
          If pos('<table id="uxOfflinePQTable" class="PocketQueryListTable Table">', sl[i]) <> 0 Then Begin
            state := 1;
          End;
        End;
      1: Begin // Finden des Links zum DL
          If (pos('</table>', sl[i]) <> 0) Then break; // Die tabelle ist zu ende
          If (pos('a href="', sl[i]) <> 0) Then Begin
            setlength(result, high(result) + 2);
            s := copy(sl[i], pos('"', sl[i]) + 1, length(sl[i]));
            s := copy(s, 1, pos('"', s) - 1);
            result[high(result)].Link := 'https://geocaching.com' + s;
            State := 2;
          End;
        End;
      2: Begin // Extrahieren des Namens
          s := copy(sl[i], 1, pos('<', sl[i]) - 1);
          result[high(result)].Name := trim(s);
          state := 20;
        End;
      10: Begin // Lesen File Size
          result[high(result)].Size := trim(sl[i]);
          state := 22;
        End;
      11: Begin // Extrahieren der Wegpunkte
          result[high(result)].WPCount := strtointdef(trim(sl[i]), 0);
          state := 24;
        End;
      12: Begin // Extrahieren des erstelldatums
          result[high(result)].Timestamp := trim(sl[i]);
          state := 1;
        End;
      20, 22, 24: Begin // Weiter Spulen zum Nächsten "TD
          If pos('<td', sl[i]) <> 0 Then Begin
            state := state Div 2;
          End;
        End;
    End;
  End;
  sl.free;
  // Todo: Checken ob alles geklappt hat:
End;

Function TGCTool.DownloadFile(Link: String; DestFilename: String): Boolean;
Var
  f: TFileStream;
Begin
  result := false;
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  fLastError := '';
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', Link);
  follow_Links(Link);
  If fClient.ResultCode <> 200 Then Begin
    fLastError := 'Could not download file. [HTMLResult=' + inttostr(fClient.ResultCode) + ']';
    exit;
  End;
  If fClient.Document.Size <> 0 Then Begin
    f := TFileStream.Create(DestFilename, fmOpenWrite Or fmCreate);
    f.CopyFrom(fClient.Document, fClient.Document.Size);
    f.Free;
    result := true;
  End;
End;

Function TGCTool.GetTBLogRecord(TBCode: String): TTravelbugRecord;

  Function ExtractLog(Const listing: TStringlist): String;
  Var
    i: Integer;
    Link: String;
    sl: TStringlist;
    b: Boolean;
  Begin
    result := '';
    // 1. Suchen nach dem Follow Link
    Link := '';
    For i := 0 To listing.Count - 1 Do Begin
      If pos('<a id="ctl00_ContentBody_InteractionLogLink" title="', listing[i]) <> 0 Then Begin
        link := copy(listing[i], pos('href="', listing[i]) + 6, length(listing[i]));
        link := copy(link, 1, pos('">', link) - 1);
        break;
      End;
    End;
    If link = '' Then exit;
    // 2. Auslesen der nachfolgenden Seite -> da steht der Log
    Link := 'https://www.geocaching.com' + Link;
    fClient.Headers.Clear;
    fClient.HTTPMethod('GET', Link);
    follow_Links(Link);
    If fClient.ResultCode <> 200 Then Begin
      exit;
    End;
    sl := TStringList.Create;
    CopyStreamToStrings(fclient.Document, sl);
    b := false;
    For i := 0 To sl.Count - 1 Do Begin
      If b Then Begin
        If pos('</span>', sl[i]) <> 0 Then Begin
          result := result + LineEnding + trim(copy(sl[i], 1, pos('</span>', sl[i]) - 1));
          break;
        End
        Else Begin
          result := result + LineEnding + trim(sl[i]);
        End;
      End
      Else Begin
        If pos('<span id="ctl00_ContentBody_LogBookPanel1_LogText">', sl[i]) <> 0 Then Begin
          result := copy(sl[i], pos('">', sl[i]) + 2, length(sl[i]));
          result := trim(result);
          b := true;
        End;
      End;
    End;
    result := trim(result);
    sl.free;
  End;

  Function ExtractHeading(Const listing: TStringlist): String;
  Var
    i, j: integer;
  Begin
    //  <span id="ctl00_ContentBody_lbHeading">babynoneck´ s Logbuchstempel</span>
    result := '';
    For i := 0 To listing.Count - 1 Do Begin
      If pos('ctl00_ContentBody_lbHeading', listing[i]) <> 0 Then Begin
        If pos('</', listing[i]) <> 0 Then Begin
          // Einzeilige Caption
          result := copy(listing[i], pos('">', listing[i]) + 2, length(listing[i]));
          result := copy(result, 1, pos('</', result) - 1);
          break;
        End
        Else Begin
          // Mehrzeilige Caption -- Bisher noch nicht getestet, kommt das überhaupt vor ?
          result := copy(listing[i], pos('">', listing[i]) + 2, length(listing[i]));
          For j := i + 1 To listing.count - 1 Do Begin
            If pos('</', listing[j]) <> 0 Then Begin
              result := result + copy(listing[j], pos('</', listing[j]) - 1);
              break;
            End
            Else Begin
              result := result + listing[j];
            End;
          End;
          break;
        End;
      End;
    End;
  End;

  Function ExtractOwner(Const listing: TStringlist): String;
  Var
    i, j, k: integer;
  Begin
    // <a id="ctl00_ContentBody_BugDetails_BugOwner" title="Profil&#32;dieses&#32;Users&#32;besuchen" href="https://www.geocaching.com/profile/?guid=1b7f5507-e22a-4faa-a88a-4d139654991c">babynoneck</a>
    result := '';
    For i := 0 To listing.Count - 1 Do Begin
      If pos('ctl00_ContentBody_BugDetails_BugOwner', listing[i]) <> 0 Then Begin
        j := pos('</a>', listing[i]);
        For k := j - 1 Downto 1 Do Begin
          If listing[i][k] = '>' Then Begin
            result := copy(listing[i], k + 1, j - k - 1);
            exit;
          End;
        End;
      End;
    End;
  End;

  Function ExtractReleasedDate(Const listing: TStringlist): String;
  Var
    i, j, k: integer;
  Begin
    // <span id="ctl00_ContentBody_BugDetails_BugReleaseDate">Thursday, 31 August 2017</span>
    result := '';
    For i := 0 To listing.Count - 1 Do Begin
      If pos('ctl00_ContentBody_BugDetails_BugReleaseDate', listing[i]) <> 0 Then Begin
        j := pos('</span>', listing[i]);
        For k := j - 1 Downto 1 Do Begin
          If listing[i][k] = '>' Then Begin
            result := copy(listing[i], k + 1, j - k - 1);
            result := trim(copy(result, pos(',', result) + 1, length(result)));
            exit;
          End;
        End;
      End;
    End;
  End;

  Function ExtractOrigin(Const listing: TStringlist): String;
  Var
    i, j, k: integer;
  Begin
    // <span id="ctl00_ContentBody_BugDetails_BugOrigin">Baden-Württemberg, Germany</span>
    result := '';
    For i := 0 To listing.Count - 1 Do Begin
      If pos('ctl00_ContentBody_BugDetails_BugOrigin', listing[i]) <> 0 Then Begin
        j := pos('</span>', listing[i]);
        For k := j - 1 Downto 1 Do Begin
          If listing[i][k] = '>' Then Begin
            result := copy(listing[i], k + 1, j - k - 1);
            exit;
          End;
        End;
      End;
    End;
  End;

  Function ExtractCurrent_Goal(Const listing: TStringlist): String;
  Var
    divcnt, state, i: integer;
  Begin
    result := '';
    (*
     <div id="TrackableGoal">
     <p>
         <p>Den Owner beim Cachen begleiten ;-)</p>
     </p>
     </div>
     *)
    state := 0;
    For i := 0 To listing.Count - 1 Do Begin
      Case state Of
        0: Begin
            If pos('<div id="TrackableGoal">', listing[i]) <> 0 Then Begin
              state := 1;
              divcnt := 1;
            End;
          End;
        1: Begin
            If pos('<div', listing[i]) <> 0 Then inc(divcnt);
            If pos('</div>', listing[i]) <> 0 Then dec(divcnt);
            If divcnt = 0 Then exit;
            If result <> '' Then Begin
              result := result + LineEnding + listing[i];
            End
            Else Begin
              result := listing[i];
            End;
          End;
      End;
    End;
  End;

  Function ExtractAbout_this_item(Const listing: TStringlist): String;
  Var
    divcnt, state, i: integer;
  Begin
    result := '';
    (*
    <div id="TrackableDetails">
        <p>

        </p>
        <p>
            <p>Dieser Stempel kann in Logb&uuml;chern gefunden werden. Bitte schreibt dazu, in welchem Logbuch zu welchem Cache ihr mich gesehen habt. Alle anderen Logs werden gel&ouml;scht!!!</p>

    <p>This stamp can be found in logbooks. Please tell me, in which cache you&acute;ve found me. All other logs will be deleted!!!</p>

    <p>&nbsp;</p>
        </p>
    </div>
     *)
    state := 0;
    For i := 0 To listing.Count - 1 Do Begin
      Case state Of
        0: Begin
            If pos('<div id="TrackableDetails">', listing[i]) <> 0 Then Begin
              state := 1;
              divcnt := 1;
            End;
          End;
        1: Begin
            If pos('<div', listing[i]) <> 0 Then inc(divcnt);
            If pos('</div>', listing[i]) <> 0 Then dec(divcnt);
            If divcnt = 0 Then exit;
            If result <> '' Then Begin
              result := result + LineEnding + listing[i];
            End
            Else Begin
              result := listing[i];
            End;
          End;
      End;
    End;
  End;

Var
  sl: TStringList;
  c, b: Boolean;
  i: Integer;
  s: String;
Begin
  result.TB_Code := ''; // Done
  result.Discover_Code := TBCode; // Done
  result.LogState := lsNotExisting; // Done
  result.LogDate := '-'; // Done
  result.Owner := ''; // Done
  result.ReleasedDate := ''; // Done
  result.Origin := ''; // Done
  result.Current_Goal := ''; // Done
  result.About_this_item := ''; // Done
  result.Comment := ''; // Der Log wird extrahiert wenn er existiert, sonst ''
  result.Heading := '';
  fLastError := '';
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', URL_OpenTBListing + lowercase(TBCode));
  follow_Links(URL_OpenTBListing + lowercase(TBCode));
  If fClient.ResultCode <> 200 Then Begin
    fLastError := 'Could not load listing. [HTMLResult=' + inttostr(fClient.ResultCode) + ']';
    exit;
  End;
  sl := TStringList.Create;
  CopyStreamToStrings(fclient.Document, sl);
  result.Owner := ExtractOwner(sl);
  result.TB_Code := ExtractTB_Code(sl);
  result.ReleasedDate := ExtractReleasedDate(sl);
  result.Origin := ExtractOrigin(sl);
  result.Current_Goal := ExtractCurrent_Goal(sl);
  result.About_this_item := ExtractAbout_this_item(sl);
  result.Heading := ExtractHeading(sl);
  b := false;
  c := false;
  // Der User hat den TB-Code und nicht den Discover-Code eingegeben
  For i := 0 To sl.count - 1 Do Begin
    // Nachdem die TB nummer auch noch anders wo im Listing stehen kann, muss hier explizit auf das relevante "span" geprüft werden.
    If pos('ctl00_ContentBody_BugDetails_BugTBNum', sl[i]) <> 0 Then Begin
      If pos('<strong>' + uppercase(TBCode) + '</strong>', sl[i]) <> 0 Then Begin
        result.LogState := lsTBCode;
        sl.free;
        exit;
      End;
    End;
  End;
  For i := 0 To sl.count - 1 Do Begin
    If pos('ctl00_ContentBody_OptionTable', sl[i]) <> 0 Then b := true;
    If b Then Begin
      If pos('/images/logtypes/13.png', sl[i]) <> 0 Then Begin // Retrieved it
        result.LogState := lsDiscovered;
        result.Comment := ExtractLog(sl);
      End;
      If pos('/images/logtypes/48.png', sl[i]) <> 0 Then Begin // Discovered it
        result.LogState := lsDiscovered;
        result.Comment := ExtractLog(sl);
      End;
      If result.LogState = lsDiscovered Then Begin
        If pos('class="loggedOnDate"', sl[i]) <> 0 Then Begin
          c := true;
        End;
        If c Then Begin
          If pos('href="', sl[i]) <> 0 Then Begin
            s := copy(sl[i], pos('>', sl[i]) + 1, length(sl[i]));
            s := copy(s, 1, pos('<', s) - 1);
            // TODO: Aus dem S das so extrahieren, das es kompatibel wird zu dem Default Log Zeitstempel
            s := trim(FilterStringForValidChars(s, ' .0123456789', #0));
            result.LogDate := s;
            sl.free;
            exit;
          End;
        End;
      End;
      If pos('images/icons/16/write_log.png', sl[i]) <> 0 Then Begin
        result.LogState := lsNotDiscover;
        // Wenn im Logtext "(locked)" steht, dann ist die Dose gesperrt, zum Glück ist das in jeder Sprache gleich.
        If pos('(locked)', sl[i + 1]) <> 0 Then Begin
          result.LogState := lsLocked;
        End;
        sl.free;
        exit;
      End;
      If pos('</table>', sl[i]) <> 0 Then break; // Ende der Tabelle
    End;
  End;
  If pos('/images/icons/16/trackable_error.png', sl.text) <> 0 Then Begin
    result.LogState := lsNotExisting; // -- ist eh schon, aber wer weis was noch passiert..
    If pos('<a href="activate.aspx"', sl.text) <> 0 Then Begin
      result.LogState := lsNotYetActivated;
    End;
    If result.LogState = lsNotExisting Then Begin
      result.TB_Code := '';
      result.LogDate := '-';
      result.Owner := '';
      result.ReleasedDate := '';
      result.Origin := '';
      result.Current_Goal := '';
      result.About_this_item := '';
    End;
    sl.free;
    exit;
  End;
  fLastError := 'Unable to parse html document, please contact the programmer.';
  sl.free;
End;

Function TGCTool.DiscoverTB(Data: TTravelbugRecord): Boolean;

  Function ExtractButtonURL(Const listing: TStringlist): String;
  Var
    i: Integer;
  Begin
    result := '';
    For i := 0 To listing.count - 1 Do Begin
      If pos('href="log.aspx?wid=', listing[i]) <> 0 Then Begin
        result := copy(listing[i], pos('href="log.aspx?wid=', listing[i]), length(listing[i]));
        result := copy(result, pos('"', result) + 1, length(result));
        result := copy(result, 1, pos('"', result) - 1);
        break;
      End;
    End;
    // Todo: Klären ob man hier evtl HTMLStringToString einsetzen muss
    result := StringReplace(result, '&amp;', '&', [rfReplaceAll]);
  End;

  Function Extract_csrfToken(): String;
  Var
    sl: TStringList;
    i: SizeInt;
    t: String;
  Begin
    result := '';
    sl := TStringList.Create;
    CopyStreamToStrings(fclient.Document, sl);
    i := pos('"csrfToken":"', sl.text);
    If i <> 0 Then Begin
      t := copy(sl.text, i + length('"csrfToken":"'), length(sl.text));
      result := copy(t, 1, pos('"', t) - 1);
    End;
    //  "csrfToken":"ZD4tpsJn-I5gLaYAjwSc3KDDoTU0Xo11fn9c"
    sl.free;
  End;

  (*
   * Wandelt das Logdatum das vom CCM als "DD.MM.YYYY" kommt um in
   * 'YYYY-MM-DD''T''HH:NN:SS''Z'''
   *)
  Function ConvertLogdate(aDate: String): String;
  Var
    Value: TDateTime;
  Begin
    value := ScanDateTime('DD.MM.YYYY', aDate);
    result := GetTime(value);
  End;

  Function TravelbugRecordToJSon(): TJSONObj;
  Var
    jn: TJSONNode;
  Begin
    //  '{"images":[],"logDate":"2024-01-21T16:43:18.520Z","logText":"TEST","logType":48,"trackingCode":"xxxxxx","usedFavoritePoint":false}'
    jn := TJSONNode.Create;
    jn.AddObj(TJSONNodeObj.Create('Images', TJSONArray.Create));
    jn.AddObj(TJSONValue.Create('logDate', ConvertLogdate(data.LogDate), true));
    jn.AddObj(TJSONValue.Create('logText', data.Comment, true));
    jn.AddObj(TJSONValue.Create('logType', TBLogStateToOption(tlDiscoveredIt), false));
    jn.AddObj(TJSONValue.Create('trackingCode', data.Discover_Code, true));
    jn.AddObj(TJSONValue.Create('usedFavoritePoint', 'false', false));
    result := jn;
  End;

Var
  postURL: String;
  sl: TStringlist;
  res, CSRFToken: String;
  jo: TJSONObj;
Begin
  result := false;
  fLastError := '';
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  If length(Data.Comment) > 3980 Then Begin
    fLastError := 'Logtext is to big.';
    exit;
  End;
  // Aufrufen des Listings
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', TrackableListingURL + 'details.aspx?tracker=' + lowercase(data.Discover_Code));
  Follow_Links(TrackableListingURL + 'details.aspx?tracker=' + lowercase(data.Discover_Code));
  sl := TStringList.Create;
  CopyStreamToStrings(fclient.Document, sl);
  postURL := ExtractButtonURL(sl);
  If postURL = '' Then Begin
    fLastError := 'Could not extract discoverbutton id';
    sl.free;
    exit;
  End;
  data.TB_Code := ExtractTB_Code(sl);
  If data.TB_Code = '' Then Begin
    fLastError := 'Could not extract TB_Code';
    sl.free;
    exit;
  End;
  sl.free;
  // Aufruf Log Seite:
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', TrackabkeGetCSRFTokenUrl);
  Follow_Links(TrackabkeGetCSRFTokenUrl);
  CSRFToken := Extract_csrfToken();
  If CSRFToken = '' Then Begin
    fLastError := 'Could not extract crf token';
    exit;
  End;
  postURL := 'https://www.geocaching.com/api/live/v1/logs/' + data.TB_Code + '/trackableLog';
  jo := TravelbugRecordToJSon();
  res := postJSON(postURL, jo, 'CSRF-Token: ' + CSRFToken);
  jo.free;
  // Kleine Heuristik, die Prüft ob das Loggen erfolgreich war ..
  result := pos('"id":48', res) <> 0;
  If Not result Then Begin
    fLastError := 'Could not discover [HTMLResult=' + inttostr(fClient.ResultCode) + ']' + LineEnding + fLastError;
  End;
End;

Function TGCTool.DownloadCacheGPX(GC_Code: String; Filename: String): Boolean;
//(* Altes Download Verfahren, bis das neue wieder tut ;)
Var
  Body, Request: TStringList;
  url: String;
  __VIEWSTATES: TStringArray;
  __VIEWSTATEGENERATOR: String;
  i: Integer;
Begin
  result := false;
  // 1. Listing öffnen
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', URL_OpenCacheListing + GC_Code);
  url := Follow_Links(URL_OpenCacheListing + GC_Code);
  If url = '' Then Begin
    url := URL_OpenCacheListing + GC_Code;
  End;
  // 2. Die Formulardaten extrahieren
  ExtractViewStates(__VIEWSTATES, __VIEWSTATEGENERATOR);
  If (length(__VIEWSTATES) = 0) Or
    (__VIEWSTATEGENERATOR = '') Then Begin
    fLastError := 'TGCTool.DownloadCacheGPX: Could not extract viewstates';
    exit;
  End;
  // 3. Anfrage erstellen
  Body := TStringList.Create;
  body.Text :=
    '__EVENTTARGET=ctl00$ContentBody$lnkGpxDownload' + // Das hier sorgt dafür das wir den Link bekommen
  '&__EVENTARGUMENT=' +
    '&__VIEWSTATEFIELDCOUNT=' + inttostr(length(__VIEWSTATES));
  For i := 0 To high(__VIEWSTATES) Do Begin
    If i = 0 Then Begin
      body.text := body.text + '&__VIEWSTATE=' + EncodeURI(__VIEWSTATES[0]);
    End
    Else Begin
      body.text := body.text + '&__VIEWSTATE' + inttostr(i) + '=' + EncodeURI(__VIEWSTATES[i]);
    End;
  End;
  body.text := body.text +
    '&__VIEWSTATEGENERATOR=' + __VIEWSTATEGENERATOR;
  fClient.MimeType := 'application/x-www-form-urlencoded';
  fClient.Headers.Clear;
  fClient.Document.Clear;
  CopyStringsToStream(body, fClient.Document);
  // 4. Absenden
  fClient.HTTPMethod('POST', url);
  Body.free;
  Follow_Links(url); // Nicht sicher ob man das wirklich noch braucht, es schadet aber auch nicht *g*
  // 5. und ergebnis Speichern
  Request := TStringList.Create;
  CopyStreamToStrings(fclient.Document, Request);
  result := fClient.ResultCode = 200; // alles Paletti *g*
  If result Then Begin
    Try
      Request.SaveToFile(Filename);
    Except
      result := false;
    End;
  End
  Else Begin
    fLastError := 'Unable to download, result code: ' + inttostr(fClient.ResultCode) + LineEnding + Request.Text;
  End;
  Request.Free;
  //  *)
(* Das ist die Alte Version, aber die API_Download_GPX_URL funktioniert nicht mehr :(
Var
  Request: TStringList;
Begin
  result := false;
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  fClient.Headers.Clear;
  //RefreshAPIToken; // Hohlen eines API-Tokens, falls notwendig
  //fClient.MimeType := 'application/gpx+xml'; -- hilft auch nicht
  fClient.HTTPMethod('POST', API_Download_GPX_URL + GC_Code); //-- War ein Get
  Request := TStringList.Create;
  CopyStreamToStrings(fclient.Document, Request);
  result := fClient.ResultCode = 200; // alles Paletti *g*
  If result Then Begin
    Try
      Request.SaveToFile(Filename);
    Except
      result := false;
    End;
  End else begin
    fLastError := 'Unable to download, result code: ' + inttostr(fClient.ResultCode) + LineEnding + Request.Text;
  end;
  Request.Free;
  // *)
End;

Function TGCTool.DownloadSpoiler(GC_Code: String): integer;
Var
  line, p, t, u: String;
  sl: TStringList;
  i, st: Integer;
  k: SizeInt;
Begin
  // Ein Listing das z.B. Spoiler beinhalted: GC55D1F
  result := 0;
  fLastError := '';
  // 1. Listing öffnen
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', URL_OpenCacheListing + GC_Code);
  Follow_Links(URL_OpenCacheListing + GC_Code);
  p := GetSpoilersDir() + GC_Code + PathDelim;
  sl := TStringList.Create;
  CopyStreamToStrings(fClient.Document, sl);
  // in sl.text steht nun der SeitenQuelltext
  For i := 0 To sl.count - 1 Do Begin
    // Ein Potentieller Spoiler
    If (pos('spoiler', lowercase(sl[i])) <> 0) And (pos('href="', sl[i]) <> 0) Then Begin
      line := sl[i];
      While pos('href="', line) <> 0 Do Begin
        delete(line, 1, pos('href="', line) + 5);
        t := '';
        st := 0;
        For k := 1 To length(sl[i]) Do Begin
          Case (st) Of
            0: Begin // Auslesen des href
                If line[k] = '"' Then Begin
                  st := 1;
                End
                Else Begin
                  t := t + line[k];
                End;
              End;
            1: Begin
                If line[k] = '>' Then Begin
                  u := '';
                  st := 2;
                End;
              End;
            2: Begin
                If line[k] = '<' Then Begin
                  If (pos('spoiler', lowercase(u)) <> 0) And (pos('http', lowercase(t)) <> 0) Then Begin
                    // Wir haben einen Tag Gefunden der mit Spoiler betitelt ist und nen Link hat.
                    // 1. Schaun ob wir die Datei schon haben
                    // 1.1 Nein, dann laden
                    If Not DirectoryExistsutf8(p) Then Begin
                      If Not ForceDirectoriesUTF8(p) Then Begin
                        break;
                      End;
                    End;
                    If Not FileExistsUTF8(p + ExtractFileName(t)) Then Begin
                      If DownLoadFile(t, p + ExtractFileName(t)) Then inc(result);
                    End;
                  End;
                  break;
                End
                Else Begin
                  u := u + line[k];
                End;
              End;
          End;
        End;
      End;
    End;
  End;
  sl.free;
End;

Function TGCTool.GetCacheInfo(GC_Code: String): TCacheInfo;
Var
  list: TStringList;
  i: integer;
  tmp: String;
  triggered: Boolean;
Begin
  fLastError := '';
  Result.GC_Code := '';
  Result.State := csError;
  Result.Description := '';
  // Das Listing Laden
  fClient.Headers.Clear;
  fClient.HTTPMethod('GET', URL_OpenCacheListing + GC_Code);
  Follow_Links(URL_OpenCacheListing + GC_Code);
  If fClient.ResultCode <> 200 Then Begin // 404
    If fClient.ResultCode = 404 Then Begin
      Result.Description := '404 - could not find';
    End;
    exit;
  End;
  list := TStringList.Create;
  CopyStreamToStrings(fClient.Document, list);
  triggered := false;
  For i := 0 To list.Count - 1 Do Begin
    // Titel des Caches
    If pos('id="ctl00_ContentBody_CacheName"', list[i]) <> 0 Then Begin
      tmp := copy(list[i], pos('>', list[i]) + 1, length(list[i]));
      tmp := copy(tmp, 1, pos('<', tmp) - 1);
      result.Description := tmp;
    End;
    // in diesem Tag kann man die Dose loggen /write Note etc ..
    If pos('<div class="CacheDetailNavigation NoPrint">', list[i]) <> 0 Then Begin
      triggered := true;
      result.State := csNotFound;
    End;
    // Wenn das "Gefunden" Icon zu sehen ist, dann ist die Sache Klar
    If triggered And (Pos('<img src="/images/logtypes/48/2.png"', list[i]) <> 0) Then Begin
      result.State := csFound;
    End;
    // Wenn der jetzt loggen Button kommt ist die Sache entschieden
    If pos('id="ctl00_ContentBody_GeoNav_logButton"', list[i]) <> 0 Then Begin
      triggered := false;
    End;
    // Wir haben alle Informationen gesammelt die uns interessieren
    If (result.State <> csError) And (Not triggered) And (result.Description <> '') Then break;
  End;
  list.free;
  If (result.State <> csError) And (Result.Description <> '') Then Begin
    result.GC_Code := GC_Code;
  End
  Else Begin
    Result.State := csError;
    result.GC_Code := '';
  End;
End;

Function TGCTool.getAvailableFavoritePoints: integer;
Var
  r: String;
Begin
  result := -1;
  fLastError := '';
  If Not LoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  r := getAPi('/web/v1/users/' + getServerParameters().UserInfo.ReferenceCode + '/availablefavoritepoints');
  result := strtointdef(trim(r), -1);
End;

Function TGCTool.searchMap(viewport: TViewport; SearchParams: TSearchParams;
  Out DataValid: Boolean): TLiteCacheArray;

  Procedure LoadCachesToResult(Const data: TJSONArray);
  Var
    c, i: integer;
  Begin
    c := length(result);
    setlength(result, c + data.ObjCount);
    For i := 0 To data.ObjCount - 1 Do Begin
      result[c + i] := JSONNodeToLiteCache(data.Obj[i] As TJSONNode);
    End;
  End;

Const
  Take = 500; // Laut onlinedoku sind maximal 100 erlaubt, c:geo hat aber auch 500 drin stehen *g*

Var
  ss, t, s, res, params: String;
  p: TJSONParser;
  tmp, jo: TJSONObj;
  cnt, Skip: integer;
  //sl: TStringList;
Begin
  DataValid := false;
  result := Nil;
  fLastError := '';
  If Not fLoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  cnt := 0;
  skip := -take; // Wir haben noch nichts gehohlt, also entsprechend mit -take vor initialisieren
  While (length(result) + skip < cnt) Do Begin
    skip := skip + take;
    params :=
      'box=' + EncodeURI(
      formatDouble(max(viewport.Lat_max, viewport.Lat_min)) + ','
      + formatDouble(min(viewport.Lon_min, viewport.Lon_max)) + ','
      + formatDouble(min(viewport.Lat_max, viewport.Lat_min)) + ','
      + formatDouble(max(viewport.Lon_max, viewport.Lon_min))) +
      '&lite=true' + // Wir wollen nur "Lite" caches.
    '&take=' + inttostr(take) +
      '&asc=' + EncodeURI('"true"') +
      '&skip=' + inttostr(Skip) +
      '&sort=distance' +
      '&origin=' + EncodeURI(formatDouble((viewport.Lat_min + viewport.Lat_max) / 2) + ',' + formatDouble((viewport.Lon_min + viewport.Lon_max) / 2));
    //if (!Settings.getCacheType().equals(CacheType.ALL)) {
    //            params.put("ct", Settings.getCacheType().wptTypeId);
    //        }
    If (Not SearchParams.All) Then Begin
      s := '';
      If SearchParams.Tradi Then s := s + '2,';
      If SearchParams.Multi Then s := s + '3,';
      If SearchParams.Event Then s := s + '6,';
      If SearchParams.Mystery Then s := s + '8,';
      If SearchParams.Exclude Then Begin
        If s <> '' Then Begin
          t := '~2~3~4~5~6~8~9~11~12~13~137~453~1304~1858~3653~3773~3774~4738~7005~'; // Die Liste aller Cache Arten die es gibt
          While s <> '' Do Begin
            ss := copy(s, 1, pos(',', s) - 1);
            delete(s, 1, pos(',', s));
            T := StringReplace(t, '~' + ss + '~', '~', [rfReplaceAll]);
          End;
          T := StringReplace(t, '~', ',', [rfReplaceAll]);
          delete(t, 1, 1);
          s := t;
        End;
      End;
      If s <> '' Then Begin
        delete(s, length(s), 1); // Das Überflüssige ',' am ende wieder weg machen
        params := params + '&ct=' + s;
      End;
    End;

    //Hide owned/hide found caches, only works for premium members
    If lowercase(getServerParameters().UserInfo.Usertype) = 'premium' Then Begin
      If SearchParams.Ho Then Begin
        params := params + '&ho=1'; // Hide Own
      End;
      If SearchParams.Hf Then Begin
        params := params + '&hf=1'; // Hide Founds
      End;
    End;
    //params := params + '&app=cgeo'; // -- Das scheint es nicht zu brauchen, dann sagen wir, wer wir sind.
    params := params + '&app=ccm'; // Wir sagen wer wir sind.
    res := getAPI('/web/search/v2', params);
    //sl := TStringList.Create;
    //sl.LoadFromFile('/home/corpsman/Desktop/dl_0.txt');
    //res := sl.Text;
    //sl.free;
    //sl := TStringList.Create;
    //sl.Text := res;
    //sl.SaveToFile('/home/corpsman/Desktop/dl_' + inttostr(Skip) + '.txt');
    //sl.SaveToFile('C:\Data\MEA.rep\Temp\Wahnsinn.txt');
    //sl.free;
    p := TJSONParser.Create;
    jo := p.Parse(res);
    If assigned(jo) Then Begin
      DataValid := true;
      LoadCachesToResult((((jo As TJSONNode).Obj[0]) As TJSONNodeObj).Value As TJSONArray);
      If cnt = 0 Then Begin // Schauen wie viele es gesamt gibt.
        tmp := jo.FindPath('total');
        If assigned(tmp) Then Begin
          cnt := strtointdef((tmp As TJSONValue).Value, 0);
        End;
      End;
      jo.free;
    End
    Else Begin
      DataValid := false;
    End;
    p.free;
  End;
End;


(*
 * Quelle: https://gsak.net/board/index.php?showtopic=34284&st=40&#entry270581
 *)
 // https://www.schraegstrichpunkt.de/adventure-lab-caches-in-gsak-integrieren/

Function TGCTool.searchLabsNear(Lat, Lon: Single; SP: TSearchParams
  ): TLABCacheInfoArray;
//  {
//     "Id":"7cab766a-e196-4f82-a15a-f68644bb0b8c",
//     "Title":"Kleiner Spaziergang durch Zell",
//     "KeyImageUrl":"https:\/\/gsmediadata.blob.core.windows.net\/mediacontainer\/2ca28e97-8d79-4cf4-be66-9009c1520536",
//     "SmartLink":"Zell",
//     "DeepLink":"https:\/\/labs.geocaching.com\/goto\/Zell",
//     "FirebaseDynamicLink":"https:\/\/adventurelab.page.link\/5ZkU",
//     "Description":"",
//     "OwnerPublicGuid":"08e6b998-5b48-4003-922a-4eb9915e2041",
//     "Visibility":2,
//     "CreatedUtc":"0001-01-01T00:00:00",
//     "PublishedUtc":"2020-10-18T11:50:33.437",
//     "IsArchived":false,
//     "RatingsAverage":4.4,
//     "RatingsTotalCount":46,
//     "Location":      {
//       "Latitude":48.73015,
//       "Longitude":9.36833333333334,
//       "Altitude":
//     },
//     "StagesTotalCount":5,
//     "IsTest":false,
//     "IsComplete":false
//   }
  Function JSONToLab(Const jo: TJSONNode): TLABCacheInfo;
  Begin
    result.ID := (jo.FindPath('id') As TJSONValue).Value;
    result.Title := (jo.FindPath('title') As TJSONValue).Value;
    result.Link := (jo.FindPath('firebaseDynamicLink') As TJSONValue).Value;
    result.RatingAvg := strtofloatdef((jo.FindPath('ratingsAverage') As TJSONValue).Value, 0, DefFormat);
    result.RatingCount := strtointdef((jo.FindPath('ratingsTotalCount') As TJSONValue).Value, 0);
    result.Lat := strtofloatdef((jo.FindPath('location.latitude') As TJSONValue).Value, 0, DefFormat);
    result.Lon := strtofloatdef((jo.FindPath('location.longitude') As TJSONValue).Value, 0, DefFormat);
    If assigned(jo.FindPath('isOwned')) Then Begin
      result.isOwned := lowercase((jo.FindPath('isOwned') As TJSONValue).Value) = 'true';
    End
    Else Begin
      result.isOwned := false;
    End;
    result.isCompleted := lowercase((jo.FindPath('isComplete') As TJSONValue).Value) = 'true';
    result.StageCount := strtointdef((jo.FindPath('stagesTotalCount') As TJSONValue).Value, 0);
  End;

Var
  res: String;
  body: TStringlist;
  p: TJSONParser;
  ja: TJSONArray;
  jn: TJSONNode;
  jv: TJSONValue;

  c, i, j, k: Integer;
  li: TLABCacheInfo;
Begin
  result := Nil;
  fLastError := '';
  If (Not fLabLoggedIn) Or (Not fLoggedIn) Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  res := getAPI_LAB('/Adventures/SearchV3', 'origin.latitude=' + floattostr(lat, DefFormat) + '&origin.longitude=' + floattostr(lon, DefFormat) + '&radiusMeters=10000&skip=0&take=500');
  p := TJSONParser.Create;
  Try
    jn := p.Parse(res) As TJSONNode;
    If Not assigned(jn) Then Begin
      p.free;
      exit;
    End;
    jv := jn.FindPath('TotalCount') As TJSONValue;
    If strtointdef(jv.Value, 0) > 0 Then Begin
      ja := jn.FindPath('Items') As TJSONArray;
    End
    Else Begin
      jn.free;
      p.free;
      exit;
    End;
  Except
    fLastError := res;
    jn.free;
    p.free;
    exit;
  End;
  setlength(result, ja.ObjCount);
  // Laden der "Found" Infos
  fClient.Clear;
  // TODO: Url als Const nach oben auslagern
  // TODO: Kann man das auf die API umstellen ?
  fClient.HTTPMethod('GET', 'https://labs.geocaching.com/logs');
  body := TStringList.Create;
  CopyStreamToStrings(fclient.Document, body);
  c := 0;
  For i := 0 To ja.ObjCount - 1 Do Begin
    li := JSONToLab(ja.Obj[i] As TJSONNode);
    If pos(li.ID, body.Text) = 0 Then Begin // Einfach, der Lab wurde noch nie gefunden und ist nicht Complett
      result[c] := li;
      inc(c);
    End
    Else Begin
      // Es gibt mindestens 1 Log zu diesem Lab, aber ist er auch Vollständig ?
      For j := 0 To body.Count - 1 Do Begin
        If pos(li.ID, body[j]) <> 0 Then Begin // Springen zu der Position wo die Logs zum Lab stehen
          For k := j + 1 To body.Count - 1 Do Begin
            If pos('"Completed locations"', body[k]) <> 0 Then Begin // Auslesen der Log anzahl
              res := body[k];
              res := copy(res, pos('"Completed locations"', res), length(res));
              res := copy(res, pos('>', res) + 1, length(res));
              res := trim(copy(res, 1, pos('<', res) - 1));
              If inttostr(li.StageCount) = res Then Begin
                li.isCompleted := true;
                If Not SP.Hf Then Begin
                  result[c] := li;
                  inc(c);
                End;
              End
              Else Begin // Der Lab ist noch nicht fertig -> aufnehmen
                result[c] := li;
                inc(c);
              End;
              break;
            End;
            If pos('</a>', body[k]) <> 0 Then Begin // Fehler, das darf eigentlich nie vorkommen, verhindert im verrücktesten Fall, aber das wir die Statistiken eines anderen Logs auslesen
              result[c] := li;
              inc(c);
              break;
            End;
          End;
          break;
        End;
      End;
    End;
  End;
  If (c <> length(result)) Then Begin
    setlength(result, c);
  End;
  body.free;
  jn.free;
  p.free;
End;

Function TGCTool.DownloadLAB(LAB: TLABCacheInfo; WPsAsCache: Boolean
  ): TCacheArray;
Var
  c: TCache;
  userlogs, res: String;
  p: TJSONParser;
  jn: TJSONNode;
  wpts: TJSONArray;
  i: Integer;
Begin
  result := Nil;
  fLastError := '';
  If (Not fLabLoggedIn) Or (Not fLoggedIn) Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  res := getAPI_LAB('/Adventures/' + LAB.ID);
  p := TJSONParser.Create;
  jn := p.Parse(res) As TJSONNode;
  If Not assigned(jn) Then Begin
    p.free;
    exit;
  End;
  // Alles Plausibel, wir legen einen neuen Labcache an
  c.GC_Code := 'Egal wird eh überschrieben ;)';
  c.Lat := StrToFloat((jn.FindPath('Location.Latitude') As TJSONValue).Value, DefFormat);
  c.Lon := StrToFloat((jn.FindPath('Location.Longitude') As TJSONValue).Value, DefFormat);
  c.Cor_Lat := Invalid_Coord;
  c.Cor_Lon := Invalid_Coord;
  c.fav := 0;
  c.Time := GetTime(StrToTime((jn.FindPath('PublishedUtc') As TJSONValue).Value));
  c.Desc := (jn.FindPath('Title') As TJSONValue).Value;
  c.URL := (jn.FindPath('DeepLink') As TJSONValue).Value; // oder FirebaseDynamicLink ?
  c.URL_Name := '';
  c.Sym := 'Geocache';
  c.Type_ := '';
  c.Note := '';
  c.G_ID := 0;
  c.G_Available := true;
  c.G_Archived := false;
  //   c.G_NEED_ARCHIVED := 0
  If LAB.isCompleted Then Begin
    c.G_Found := 1;
  End
  Else Begin
    c.G_Found := 0;
  End;
  c.G_XMLNs := 'http://www.groundspeak.com/cache/1/0/1';
  c.G_Name := (jn.FindPath('Title') As TJSONValue).Value;
  c.G_Placed_By := (jn.FindPath('OwnerUsername') As TJSONValue).Value;
  c.G_Owner_ID := 0;
  c.G_Owner := (jn.FindPath('OwnerUsername') As TJSONValue).Value;
  c.G_Type := Geocache_Lab_Cache;
  c.G_Container := '';
  c.G_Difficulty := 0;
  c.G_Terrain := 0;
  c.G_Country := '';
  c.G_State := '';
  c.G_Short_Description := (jn.FindPath('Title') As TJSONValue).Value;
  c.G_Short_Description_HTML := false;
  c.G_Long_Description := StringReplace((jn.FindPath('Description') As TJSONValue).Value, #12, '', [rfReplaceAll]);
  c.G_Long_Description_HTML := false;
  c.G_Encoded_Hints := '';
  c.Customer_Flag := 0;
  c.Lite := false;
  c.Logs := Nil;
  // Attribute noch setzen
  c.Waypoints := Nil;
  c.G_Attributes := Nil;
  wpts := jn.FindPath('GeocacheSummaries') As TJSONArray;
  userlogs := '';
  If (c.G_Found = 0) And WPsAsCache Then Begin
    (* // Das Geht zwar so, ist dann aber recht Langsam, weil jeder einzelne Add die Logs lädt => sehr viel Laden des immer Gleichen Kontents, deswegen erst mal raus genommen
       // Hier müsste man die Userlogs 1 mal zentral laden und dann speichern
    fClient.Clear;
    // TODO: Url als Const nach oben auslagern
    fClient.HTTPMethod('GET', 'https://labs.geocaching.com/logs');
    body := TStringList.Create;
    CopyStreamToStrings(fclient.Document, body);
    userlogs := body.text;
    body.free;
    // *)
  End;
  If WPsAsCache Then Begin
    setlength(result, wpts.ObjCount);
    For i := 0 To wpts.ObjCount - 1 Do Begin
      result[i] := c;
      If c.G_Found = 0 Then Begin
        (*
         * Eigentlich sollte man den Titel berücksichtigen, aber das müsste mit der KeyImageUrl auch gehen
         *)
        If pos((wpts.FindPath('[' + inttostr(i) + '].KeyImageUrl') As TJSONValue).Value, userlogs) <> 0 Then Begin
          c.G_Found := 1;
        End;
      End;
      result[i].G_Name := (wpts.FindPath('[' + inttostr(i) + '].Title') As TJSONValue).Value;
      result[i].Time := GetTime(StrToTime((wpts.FindPath('[' + inttostr(i) + '].LastUpdateDateTimeUtc') As TJSONValue).Value));
      result[i].Lat := StrToFloat((wpts.FindPath('[' + inttostr(i) + '].Location.Latitude') As TJSONValue).Value, DefFormat);
      result[i].Lon := StrToFloat((wpts.FindPath('[' + inttostr(i) + '].Location.Longitude') As TJSONValue).Value, DefFormat);
      result[i].G_Long_Description := StringReplace((wpts.FindPath('[' + inttostr(i) + '].Description') As TJSONValue).Value
        + LineEnding + 'Question:' + LineEnding +
        (wpts.FindPath('[' + inttostr(i) + '].Question') As TJSONValue).Value, #12, '', [rfReplaceAll]);
      result[i].G_Encoded_Hints := StringReplace((wpts.FindPath('[' + inttostr(i) + '].CompletionAwardMessage') As TJSONValue).Value, #12, '', [rfReplaceAll]);
    End;
  End
  Else Begin
    setlength(c.Waypoints, wpts.ObjCount);
    For i := 0 To wpts.ObjCount - 1 Do Begin
      c.Waypoints[i].GC_Code := 'Ist Egal das repariert der ccm-Importer';
      c.Waypoints[i].Name := (wpts.FindPath('[' + inttostr(i) + '].Title') As TJSONValue).Value;
      c.Waypoints[i].Time := GetTime(StrToTime((wpts.FindPath('[' + inttostr(i) + '].LastUpdateDateTimeUtc') As TJSONValue).Value));
      c.Waypoints[i].lat := StrToFloat((wpts.FindPath('[' + inttostr(i) + '].Location.Latitude') As TJSONValue).Value, DefFormat);
      c.Waypoints[i].Lon := StrToFloat((wpts.FindPath('[' + inttostr(i) + '].Location.Longitude') As TJSONValue).Value, DefFormat);
      c.Waypoints[i].cmt := StringReplace((wpts.FindPath('[' + inttostr(i) + '].Description') As TJSONValue).Value
        + LineEnding + 'Question:' + LineEnding +
        (wpts.FindPath('[' + inttostr(i) + '].Question') As TJSONValue).Value
        + LineEnding + 'CompletionAwardMessage:' + LineEnding +
        (wpts.FindPath('[' + inttostr(i) + '].CompletionAwardMessage') As TJSONValue).Value
        , #12, '', [rfReplaceAll]);
      c.Waypoints[i].desc := 'LAB-Waypoint';
      c.Waypoints[i].url := '';
      c.Waypoints[i].url_name := '';
      c.Waypoints[i].sym := 'Virtual Stage';
      c.Waypoints[i].Type_ := 'Waypoint|' + c.Waypoints[i].sym;
      // Für interne Verarbeitungen, hat nichts mit der SQL Datanbank zu tun
      c.Waypoints[i].Used := false;
    End;
    setlength(Result, 1);
    result[0] := c;
  End;
  jn.free;
  p.free;
End;

Function TGCTool.SetOnlineNoteAndModifiedCoord(GC_Code, Note: String;
  OnNeedUserNoteDecision: TNoteCallback; NoteAutoOK, NoteAutoAppent: Boolean;
  OnNoteEdit: TEditNoteCallback; CLat, CLon: Double;
  OnNeedUserCoordDecision: TCoordCallback; CoordAutoOK, CoordAutoOther: Boolean
  ): Integer;

Var
  oclat, oclon: Double;
  oNote, responce, ut: String;
  i: Integer;
  hie: THintElement;
  ce: TCoordElement;
  r: TUserNoteResult;
  cr: TUserCoordResult;
  b: Boolean;
Begin
  result := NCR_ERROR;
  (* Das Ganze Zerlegt sich in 2 Teile *)
  If (Trim(Note) = '') And (CLat = -1) And (CLon = -1) Then exit; // Offensichtlich soll gar nichts Aktualisiert werden ...
  // Laden was wir für beide Brauchen

  // 1. Load Listing
  fClient.Clear;
  fClient.HTTPMethod('GET', 'https://coord.info/' + GC_Code);
  Follow_Links('https://coord.info/' + GC_Code);
  i := fClient.ResultCode;
  If i <> 200 Then exit;
  ut := ExtractUserToken();
  If ut = '' Then exit;
  oNote := CleanUpUserNote(ExtractUserNote());
  Note := CleanUpUserNote(Note);
  ExtractModifiedCoord(oclat, oclon);

  result := NCR_OK;
  // 1. UserNote
  If (trim(Note) <> '') And (oNote <> Note) Then Begin
    b := true;
    If (oNote <> '') Then Begin
      If NoteAutoOK Then Begin
        // Nichts zu tun Note ist ja schon Initialisiert
      End
      Else Begin
        If NoteAutoAppent Then Begin
          note := trim(oNote) + LineEnding + Note; // Anhängen der Notiz an die die Online ist
        End
        Else Begin
          oNote := UnCleanUpUserNote(oNote);
          Note := UnCleanUpUserNote(Note);
          r := OnNeedUserNoteDecision(GC_Code, oNote, Note);
          Case r Of
            unrError, unrAbort: b := false;
            unrOKAll: result := result Or NCR_Note_Auto_all;
            unrOKAppendAll: result := result Or NCR_Note_Auto_Append;
          End;
        End;
      End;
    End;
    If b Then Begin
      Note := CleanUpUserNote(Note);
      b := true;
      While (Not IsUserNoteLenValid(note)) And b Do Begin
        Note := UnCleanUpUserNote(Note);
        b := OnNoteEdit(GC_Code, Note);
        Note := CleanUpUserNote(Note);
      End;
      // 3. Upload new data
      hie := THintElement.Create(Note, ut);
      responce := postJSON('https://www.geocaching.com/seek/cache_details.aspx/SetUserCacheNote', hie);
      hie.free;
      If pos('success', lowercase(responce)) = 0 Then Begin
        result := result Or NCR_ERROR;
      End;
    End;
  End;

  // 2. Korrigierte Koordinaten
  If (CLat <> -1) And (CLon <> -1) Then Begin
    b := true;
    If (oCLat <> -1) And (oCLon <> -1) Then Begin
      If CoordAutoOK Then Begin
        // Nichts zu tun Clat / CLon ist ja schon Initialisiert
      End
      Else Begin
        If CoordAutoOther Then Begin
          b := false; // Wir brauchen nichts hoch laden, weil die Online Version nicht geändert werden soll !
        End
        Else Begin
          cr := OnNeedUserCoordDecision(GC_Code, oclat, oclon, clat, clon);
          Case cr Of
            ucrError, ucrAbort: b := false;
            ucrOKAll: result := result Or NCR_Coord_Auto_OK;
            ucrOKAllOther: result := result Or NCR_Coord_Auto_Other;
          End;
        End;
      End;
    End;
    If b Then Begin
      ce := TCoordElement.Create(CLat, CLon, ut);
      responce := postJSON('https://www.geocaching.com/seek/cache_details.aspx/SetUserCoordinate', ce);
      ce.free;
      If pos('success', lowercase(responce)) = 0 Then Begin
        result := result Or NCR_ERROR;
      End;
    End;
  End;
End;

Function TGCTool.ClearOnlineNote(GC_Code: String): Boolean;
Var
  i: Integer;
  hie: THintElement;
  ut, responce: String;
Begin
  result := false;
  fClient.Clear;
  // 1. Load Listing
  fClient.HTTPMethod('GET', 'https://coord.info/' + GC_Code);
  Follow_Links('https://coord.info/' + GC_Code);
  i := fClient.ResultCode;
  If i <> 200 Then exit;
  ut := ExtractUserToken();
  If ut = '' Then exit;
  hie := THintElement.Create('', ut);
  responce := postJSON('https://www.geocaching.com/seek/cache_details.aspx/SetUserCacheNote', hie);
  hie.free;
  If pos('success', lowercase(responce)) <> 0 Then Begin
    result := true;
  End
End;

Function TGCTool.ClearOnlineKorrectedCoords(GC_Code: String): Boolean;
Var
  i: Integer;
  ce: TCoordElement;
  ut, responce: String;
Begin
  result := false;
  fClient.Clear;
  // 1. Load Listing
  fClient.HTTPMethod('GET', 'https://coord.info/' + GC_Code);
  Follow_Links('https://coord.info/' + GC_Code);
  i := fClient.ResultCode;
  If i <> 200 Then exit;
  ut := ExtractUserToken();
  If ut = '' Then exit;
  ce := TCoordElement.Create(-1, -1, ut);
  responce := postJSON('https://www.geocaching.com/seek/cache_details.aspx/ResetUserCoordinate', ce);
  ce.free;
  If pos('success', lowercase(responce)) <> 0 Then Begin
    result := true;
  End
End;

Function TGCTool.GetOnlineNoteAndModifiedCoord(GC_Code: String): TUserNoteCoord;
Var
  i: Integer;
Begin
  result.Lat := -1;
  result.Lon := -1;
  result.UserNote := '';
  fClient.Clear;
  fClient.HTTPMethod('GET', 'https://coord.info/' + GC_Code);
  Follow_Links('https://coord.info/' + GC_Code);
  i := fClient.ResultCode;
  If i <> 200 Then exit;
  result.UserNote := ExtractUserNote();
  ExtractModifiedCoord(result.Lat, result.Lon);
End;

Function TGCTool.getLiteCache(GC_Code: String): TLiteCacheArray;
Var
  res: String;
  //sl:TStringList;
  p: TJSONParser;
  jo: TJSONObj;
Begin
  result := Nil;
  fLastError := '';
  If Not LoggedIn Then Begin
    fLastError := 'Not logged in.';
    exit;
  End;
  res := getAPI('/web/v1/geocache/' + lowercase(GC_Code), '');
  If trim(res) = '' Then exit;
  p := TJSONParser.Create;
  jo := p.Parse(res);
  If Not assigned(jo) Then Begin
    p.free;
    exit;
  End;
  setlength(result, 1);
  result[0] := JSONNodeToLiteCache(jo As TJSONNode);
  jo.free;
  p.free;
  //sl := TStringList.Create;
  //sl.text := res;
  //sl.SaveToFile('test.json');
  //sl.free;
End;

(*
 * Wenn Result <> '', dann wird dann entspricht dies der letzten gefolgten URL
 *)

Function TGCTool.Follow_Links(URL: String): String;
  Function ExtractBaseURL(U: String): String;
  Var
    Prot, User, Pass, Host, Port, Path, Para: String;
  Begin
    Prot := '';
    User := '';
    Pass := '';
    Host := '';
    Port := '';
    Path := '';
    Para := '';
    ParseURL(u, Prot, User, Pass, Host, Port, Path, Para);
    result := Prot + '://' + host + '/';
  End;
Var
  t: String;
  timeout, i: Integer;
Begin
  result := '';
  If URL = '' Then exit;
  url := ExtractBaseURL(url);
  timeout := 20;
  While ((fClient.ResultCode = 303) Or (fClient.ResultCode = 302) Or (fClient.ResultCode = 301)) And (timeout >= 0) Do Begin
    dec(timeout);
    t := '';
    For i := 0 To fClient.Headers.Count - 1 Do Begin
      If pos('location', lowercase(fClient.Headers[i])) <> 0 Then Begin
        t := fClient.Headers[i];
        t := copy(t, pos(':', t) + 1, length(t));
        t := trim(t);
        If pos('http', lowercase(t)) = 0 Then Begin
          If t[1] = '/' Then delete(t, 1, 1);
          t := URL + t;
        End;
        fClient.Headers.Clear;
        fClient.Document.Clear;
        result := t;
        url := ExtractBaseURL(t);
        fClient.HTTPMethod('GET', t);
        break;
      End;
    End;
    If t = '' Then Begin
      // das Location feld konnte im Header nicht gefunden werden.
      exit;
    End;
  End;
End;

Procedure TGCTool.RefreshAPIToken;

  Function get_API_Token(): TAPIToken;
  Const
    OneSecondAsTDateTime: Double = 1 / (24 * 3600);
  Var
    List: TSTringlist;
    res: String;
    p: TJSONParser;
    jn: TJSONNode;
  Begin
    (*
    {"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1bmlxdWVfbmFtZSI6IkNvcnBzbWFuIiwic3ViIjoiN2ZjNzk0NmMtMWRhZC00ZDFiLWI3MTEtMzI0ZjYwMmRjMWVjIiwiYWlkIjoiMTQzMDg1MTkiLCJsZ2QiOiIzNmE3MDY0OS1kOWU5LTQzNzktOWY2MS1jYzAwZTkyMDVlOTQiLCJpc3MiOiJodHRwczovL29hdXRoLmdlb2NhY2hpbmcuY29tL3Rva2VuIiwiYXVkIjoiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy91c2VyZGF0YTogMTdiMWJhYjQtNmM1My00NTRjLThlYTktMmE2NjQ4OTFhNDMxIiwiZXhwIjoxNTA3MTAyMjM5LCJuYmYiOjE1MDcwOTg2Mzl9.GJzLHCLarcZMM_BWqXxATxf_47FL3Ma-w2-lEZLkEsU","token_type":"bearer","expires_in":"3599"}
    *)
    List := TStringList.Create;
    CopyStreamToStrings(fClient.Document, list);
    res := list.text;
    list.free;
    p := TJSONParser.Create;
    jn := p.Parse(res) As TJSONNode;
    result.access_token := (jn.FindPath('access_token') As TJSONValue).Value;
    result.token_type := (jn.FindPath('token_type') As TJSONValue).Value;
    (*
     * Die Gültigkeitsdauer des Tokens wird in Sekunden übertragen
     * c:geo multipliziert diesen wert mit 0.8, also machen wir das
     * auch.
     *)
    result.expires_at := now + (strtointdef((jn.FindPath('expires_in') As TJSONValue).Value, 0) * 0.8) * OneSecondAsTDateTime;
    jn.free;
    p.free;
  End;
Begin
  // das Token braucht es nicht mehr, der Code bleibt aber noch mal drin.
//  Exit;
  If FAPIToken.expires_at <= now Then Begin
    (*
     * Geht nur, wenn wir eingeloggt sind.
     *
     * Weitere Details siehe: https://tools.ietf.org/html/rfc6750
     *)
    fClient.Headers.Clear;
    fClient.HTTPMethod('GET', Authorisation_URL);
    Follow_Links(Authorisation_URL);
    // rc := fClient.ResultCode;
    // CopyStreamToStrings(fClient.Document, form1.SynEdit1.Lines); // -- Debugg
    FAPIToken := get_API_Token();
  End;
End;

End.

