(*

Kommt ein Linkerfehler wegen OpenGL dann:

sudo apt-get install freeglut3-dev

Für die SSL-Verschlüsselung:

sudo aptitude install libssl-dev

Das Paket libsqlite3-dev mus installiert werden.

sudo aptitude install libsqlite3-dev

Das Paket gpsbabel mus installiert werden

sudo aptitude install gpsbabel

Für Lazarus mus das Paket

SQLDBLaz

installiert werden.

für mehr Details siehe :

http://www.sqlite.org/sqlite.html

oder

http://www.sqlite.org/lang.html -- SYNTAX

oder

http://reeg.junetz.de/DSP/node10.html#SECTION04220000000000000000

*)
Unit Unit1;

{$MODE objfpc}{$H+}

Interface

{$I ccm.inc}

Uses
  Classes, SysUtils, FileUtil, UniqueInstance, Forms, Controls, Graphics,
  Dialogs, Menus, StdCtrls, Grids, ComCtrls, ExtDlgs, sqldb, sqlite3conn,
  uupdate // Der Dialog der Versucht raus zu kriegen ob ein Update gemacht werden muss
  , usqlite_helper
  , uccm
  , ugctool // Für die Typen
  ;

Const
  // Die Indexe der Imagelist1
  MainIndexUnknownImage = -1;
  MainImageIndexTraditionalCache = 0;
  MainImageIndexMysterieCache = 1;
  MainImageIndexVirtualCache = 2;
  MainImageIndexMultiCache = 3;
  // = 4 ?? -- das war mal das alte CITO Icon ?
  // = 5 ??
  MainImageIndexLetterbox = 6;
  MainImageIndexKoordsModified = 7;
  MainImageIndexFoundCache = 8;
  MainImageIndexCacheArchived = 9;
  MainImageIndexEventCache = 10;
  MainImageIndexCITO = 11;
  MainImageIndexEarthCache = 12;
  MainImageIndexPointHere = 13; // -- Wenn der User im Online Modus eine Route festlegt sieht man hier die "Nadel"
  MainImageIndexWhereIGo = 14;
  MainImageIndexWebcamCache = 15;
  MainImageIndexLabCache = 16;
  MainImageIndexFavourite = 17;
  MainImageIndexCustomerFlag = 18;
  MainImageIndexProjectAPE = 19;
  MainImageIndexLocationLess = 20;
  // Während des Startens werden noch length(POI_Types) viele Bilder angehängt !

  // Die Spalten im MainStringgrid
  MainColType = 0;
  MainColFav = 1;
  MainColGCCode = 2;
  MainColDist = 3;
  MainColTitle = 4;

  // Die Spalten der Statusbar
  MainSBarCCount = 0; // MainStatusBarCacheCount = Die Gesamt Anzahl an Caches die in der Datenbank vorhanden sind
  MainSBarCQCount = 1; // MainStatusBarCacheQueryCount = Die Anzahl an Caches die gerade durch die Anfrage selektiert wurde
  MainSBarInfo = 2; // Info's die gerade ausgegeben werden.

Type

  { TForm1 }

  TForm1 = Class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit2: TEdit;
    ImageList1: TImageList;
    ImageList2: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem100: TMenuItem;
    MenuItem101: TMenuItem;
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
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem53: TMenuItem;
    MenuItem54: TMenuItem;
    MenuItem55: TMenuItem;
    MenuItem56: TMenuItem;
    MenuItem57: TMenuItem;
    MenuItem58: TMenuItem;
    MenuItem59: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem60: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    MenuItem67: TMenuItem;
    MenuItem68: TMenuItem;
    MenuItem69: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem70: TMenuItem;
    MenuItem71: TMenuItem;
    MenuItem72: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    MenuItem75: TMenuItem;
    MenuItem76: TMenuItem;
    MenuItem77: TMenuItem;
    MenuItem78: TMenuItem;
    MenuItem79: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem80: TMenuItem;
    MenuItem81: TMenuItem;
    MenuItem82: TMenuItem;
    MenuItem83: TMenuItem;
    MenuItem84: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem86: TMenuItem;
    MenuItem87: TMenuItem;
    MenuItem88: TMenuItem;
    MenuItem89: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem90: TMenuItem;
    MenuItem91: TMenuItem;
    MenuItem92: TMenuItem;
    MenuItem93: TMenuItem;
    MenuItem94: TMenuItem;
    MenuItem95: TMenuItem;
    MenuItem96: TMenuItem;
    MenuItem97: TMenuItem;
    MenuItem98: TMenuItem;
    MenuItem99: TMenuItem;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    OpenDialog3: TOpenDialog;
    OpenPictureDialog1: TOpenPictureDialog;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    SQLite3Connection1: TSQLite3Connection;
    SQLite3Connection2: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLQuery2: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    SQLTransaction2: TSQLTransaction;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    UniqueInstance1: TUniqueInstance;
    Procedure Button1Click(Sender: TObject);
    Procedure ComboBox1Change(Sender: TObject);
    Procedure ComboBox2KeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCloseQuery(Sender: TObject; Var CanClose: boolean);
    Procedure FormCreate(Sender: TObject);
    Procedure FormResize(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure MenuItem100Click(Sender: TObject);
    Procedure MenuItem101Click(Sender: TObject);
    Procedure MenuItem10Click(Sender: TObject);
    Procedure MenuItem13Click(Sender: TObject);
    Procedure MenuItem14Click(Sender: TObject);
    Procedure MenuItem15Click(Sender: TObject);
    Procedure MenuItem17Click(Sender: TObject);
    Procedure MenuItem18Click(Sender: TObject);
    Procedure MenuItem19Click(Sender: TObject);
    Procedure MenuItem21Click(Sender: TObject);
    Procedure MenuItem22Click(Sender: TObject);
    Procedure MenuItem25Click(Sender: TObject);
    Procedure MenuItem26Click(Sender: TObject);
    Procedure MenuItem27Click(Sender: TObject);
    Procedure MenuItem28Click(Sender: TObject);
    Procedure MenuItem29Click(Sender: TObject);
    Procedure MenuItem2Click(Sender: TObject);
    Procedure MenuItem33Click(Sender: TObject);
    Procedure MenuItem34Click(Sender: TObject);
    Procedure MenuItem35Click(Sender: TObject);
    Procedure MenuItem37Click(Sender: TObject);
    Procedure MenuItem39Click(Sender: TObject);
    Procedure MenuItem3Click(Sender: TObject);
    Procedure MenuItem41Click(Sender: TObject);
    Procedure MenuItem42Click(Sender: TObject);
    Procedure MenuItem43Click(Sender: TObject);
    Procedure MenuItem44Click(Sender: TObject);
    Procedure MenuItem46Click(Sender: TObject);
    Procedure MenuItem47Click(Sender: TObject);
    Procedure MenuItem48Click(Sender: TObject);
    Procedure MenuItem4Click(Sender: TObject);
    Procedure MenuItem50Click(Sender: TObject);
    Procedure MenuItem51Click(Sender: TObject);
    Procedure MenuItem52Click(Sender: TObject);
    Procedure MenuItem53Click(Sender: TObject);
    Procedure MenuItem54Click(Sender: TObject);
    Procedure MenuItem56Click(Sender: TObject);
    Procedure MenuItem59Click(Sender: TObject);
    Procedure MenuItem5Click(Sender: TObject);
    Procedure MenuItem62Click(Sender: TObject);
    Procedure MenuItem63Click(Sender: TObject);
    Procedure MenuItem65Click(Sender: TObject);
    Procedure MenuItem66Click(Sender: TObject);
    Procedure MenuItem67Click(Sender: TObject);
    Procedure MenuItem69Click(Sender: TObject);
    Procedure MenuItem74Click(Sender: TObject);
    Procedure MenuItem75Click(Sender: TObject);
    Procedure MenuItem77Click(Sender: TObject);
    Procedure MenuItem78Click(Sender: TObject);
    Procedure MenuItem79Click(Sender: TObject);
    Procedure MenuItem7Click(Sender: TObject);
    Procedure MenuItem80Click(Sender: TObject);
    Procedure MenuItem81Click(Sender: TObject);
    Procedure MenuItem82Click(Sender: TObject);
    Procedure MenuItem84Click(Sender: TObject);
    Procedure MenuItem85Click(Sender: TObject);
    Procedure MenuItem86Click(Sender: TObject);
    Procedure MenuItem87Click(Sender: TObject);
    Procedure MenuItem88Click(Sender: TObject);
    Procedure MenuItem90Click(Sender: TObject);
    Procedure MenuItem91Click(Sender: TObject);
    Procedure MenuItem92Click(Sender: TObject);
    Procedure MenuItem93Click(Sender: TObject);
    Procedure MenuItem94Click(Sender: TObject);
    Procedure MenuItem95Click(Sender: TObject);
    Procedure MenuItem96Click(Sender: TObject);
    Procedure MenuItem98Click(Sender: TObject);
    Procedure MenuItem99Click(Sender: TObject);
    Procedure StringGrid1DblClick(Sender: TObject);
    Procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    Procedure StringGrid1HeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    Procedure StringGrid1KeyPress(Sender: TObject; Var Key: char);
    Procedure StringGrid1Resize(Sender: TObject);
    Procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      Var CanSelect: Boolean);
    Procedure UniqueInstance1OtherInstance(Sender: TObject;
      ParamCount: Integer; Const Parameters: Array Of String);
  private
    { private declarations }
    row: integer;
    fUpdater: TUpdater;
    fCacheCountInActualDB: integer;
    Form1ShowOnce: Boolean;
    Procedure LoadAndApplyLanguage;
    Procedure UpdateResultCallback(AlwaysShowResult: Boolean;
      OnlineVersions: TVersionArray);
    Procedure QueryToMainGrid(StartTime: int64);
    Function MoveSelectionToOtherDB(NewDBName: String): Boolean; // Verschiebt alle gerade sichtbaren Caches in die andere Datenbank
    Function CopySelectionToOtherDB(NewDBName: String): Boolean; // Kopiert alle gerade sichtbaren Caches in die andere Datenbank
    Function SelectCutSetToOtherDB(OtherDBName: String): Boolean; // Wählt die Schnitt menge zwischen der Aktuellen und der Angegebenen Datenbank in der Aktuellen Datenbank aus
    Function ExportAsPocketQuery(Filename: String): Boolean;
    Function ExportAsGSAKGPX(Filename: String; ExportAsCGeo: Boolean): Boolean;
    Function ExportAsCGEOZIP(Filename: String): Boolean;
    Function CreateDatabaseFromGSAKGPX(Filename, DBName: String): integer; // -1 = Fehler, >= 0 Anzahl der Importierten Caches
    Procedure CallScript(Script_name: String);

    Procedure OnGPSExportClick(Sender: TObject); // Export as GGZ
    Procedure OnGPSImportClick(Sender: TObject); // Import field notes
    Procedure OnGPSSpoilerClick(Sender: TObject); // Laden aller Spoiler Bilder aus den Listings
    Procedure OnScriptClick(Sender: TObject); // Startet ein Script
    Procedure OnToolsClick(Sender: TObject); // Öffnen eines Tools (Exe oder Link)

    (*
     * Erzeugen der diversen Menü's
     *)
    Procedure CreateExportMenu;
    Procedure CreateFieldImportMenu;
    Procedure CreateScriptMenu;
    Procedure CreateSpoilerMenu;
    Procedure CreateToolsMenu;

    Procedure CreateWaypointImages;

    Function ImportDirectory(Dirname: String): integer; // Importiert alle Dateien aus dem Verzeichnis und wählt danach diejenigen Dosen aus, welche nicht "erneuert" wurden. Result = Anzahl der importierten Dosen

    (*
     * Exportiert alle Gewählten Caches und speichert sie in einer .ggz Datei ab
     *)
    Function DoGPSExport(Const ggzFilename: String): Boolean;
    Function CreateGPXFiles(FilesPerGPX: integer): TStringlist;

    Function CacheTypeToDTIcon(CacheType: String): integer; // Extrahiert aus CacheTypt die DT-Wertung als Dezimalstellen <D><T> (1..9)

    Function OpenTBDatabase(): Boolean;
    Procedure OnApplicationRestore(Sender: TObject);
    Function AddSearchRemember(NewSearch: String): boolean; // True, wenn NewSearch in die Liste aufgenommen wurde.
    Procedure RefreshSearchRemember();
    Procedure CloseDataBase();
    Function OnCompareUserNote_Locale_to_Online(GC_Code, OnlineNote: String; Var LocalNote: String): TUserNoteResult; // Callback zum Vergleich OnlineHint Local Hint mit Ziel Online Hint
    Function OnCompareUserNote_Online_to_Locale(GC_Code, LocalNote: String; Var OnlineNote: String): TUserNoteResult; //

    Function OnCompereCorrectedCoords_Locale_to_Online(GC_Code: String; onlineLat, onlineLon: Double; Var localeLat: Double; Var localeLon: Double): TUserCoordResult;
    Function OnCompereCorrectedCoords_Online_to_Locale(GC_Code: String; localeLat, localeLon: Double; Var onlineLat: Double; Var onlineLon: Double): TUserCoordResult;
    Function OnNoteEdit(GC_Code: String; Var Note: String): Boolean; // Callback für den DB->Online Dialog
    Procedure CheckIniFileVersion();
  public
    { public declarations }
    Procedure RefreshDataBaseCacheCountinfo();

    Function getLang(): String; // Liefert die Gewünschte Sprache für die Anwendung als 2 zeichen zurück (Aktuell nur de oder en)

    (*
     * Lädt die GPX Datei eines caches herunter und importiert diese
     *
     * Silent = true = Keine Fehlermeldungen von GCT anzeigen
     *
     * result: 0 = Erfolg
     *         1 = kann nicht runter laden
     *         2 = kann nicht importieren
     *         3 = undefinierter Fehler)
     *)
    Function DownloadAndImportCacheByGCCode(GCCode: String; Silent: Boolean = true): integer;

    Function NewDatabase(DataBaseName: String): Boolean;
    Function OpenDataBase(FileName: String; ResetGui: Boolean): Boolean;

    Procedure CheckForNewVersion(AlwaysShowResult: Boolean); // startet einen Thread der das macht, weils a bissle dauern kann ->

    Procedure AddSpoilerImageToCache(CacheName: String);

    Procedure CreateFilterMenu; // Wird auch von Unit6 (Filter Editor) Aufgerufen

    Function CacheTypeToIconIndex(CacheType: String): integer; // Wandelt einen Cachnamen in einen BildIndex um, geht auch mit Wegpunkt Syms
    Function CacheNameToCacheType(CacheName: String): String; // Fügt dem Cachnamen entsprechend des "Found" / Archived ... den Suffix an.

    Procedure ResetMainGridCaptions;
  End;

Const
  // Select Statement, welches mindestens gemacht werden muss, bevor die QueryToMainGrid methode aufgerufen werden kann
  // Irgendwo muss dann noch kommen "from caches c" folgen
  QueryToMainGridSelector = 'Select distinct c.G_TYPE, c.NAME, c.G_NAME, c.lat, c.lon, c.cor_lat, c.cor_lon, c.G_DIFFICULTY, c.G_TERRAIN, c.Fav ';

Var
  Form1: TForm1;

Procedure EditCacheNote(Sender: TForm; CacheName: String);
Procedure ShowCacheHint(Sender: TForm; CacheName: String);

Implementation

{$R *.lfm}

Uses
  ulanguage,
  unit2, // Abfrage Datenbankname Dialog
  unit3, // Optionen Dialog
  unit4, // Der Info Dialog, dass man sieht dass noch was passiert
  unit5, // Modify Koordinates Dialog
  Unit6, // Filter Editor
  Unit7, // Note Editor
  Unit8, // Import Directory
  Unit9, // Export Poi files
  Unit10, // Field-Notes Editor
  Unit11, // Select Database
  Unit12, // 81 - Matrix
  Unit13, // Preview des Caches
  Unit14, // Location Editor
  Unit15, // Map Preview
  Unit16, // Load Database
  Unit17, // Edit Waypoints
  // Unit18, // -- Online Hilfe Script Editor
  Unit19, // Tool Editor
  Unit20, // -- Preview Logeinträge eines Caches
  Unit21, // Folder and File Editor
  unit22, // TB-Online Editor (Auswahldialog welche TB's bei welchen Dosenlogs mit dabei sein sollen)
  Unit23, // TB-Editor (Owner TB's die er hat um sie von Dose zu Dose mit zu nehmen)
  Unit24, // SQL Admin Tool
  // Unit25, // -- Ergebnis der Query des SQL-Admin Tools
  // Unit26, // -- Historie der SQL-Anfragen SQL-Admin Tool
  Unit27, // Script Editor
  Unit28, // -- Dialog Script überschreiben (Script Editor)
  Unit29, // Customize Filter
  Unit30, // Export as CSV
  // Unit31, // Edit Dialog für Custom Points
  Unit32, // Download Pocket Queries
  Unit33, // TB-Logger (Dialog zum discovern von fremden TB's)
  Unit34, // Log Caches by GC-Code
  unit35, // Jasmer Anzeige
  unit36, // Wizard
  unit37, // LAB-Caches
  unit38, // TB-Database Editor
  // unit39, // Select via Listbox Dialog
  unit40, // Online Modus im Map Preview
  unit41, // About
  unit42, // TB-Detail dialog
  unit43, // Online User Note Diff Dialog
  unit44, // Online Corrected Koord Diff Dialog
  ugctoolwrapper, // Online Logger
  LazFileUtils, LCLIntf, Laz2_DOM, laz2_XMLwrite, lazutf8, IpHtml, math, LCLType,
  ugpx2ggz, zipper, UTF8Process, Clipbrd;

Procedure SortColumn(Const StringGrid: TStringGrid; Const Column: integer; Const Direction: boolean);

  Function Compare(v1, v2: String): Integer;
  Var
    v1_, v2_: integer;
  Begin
    Case Column Of
      MainColFav: Begin
          v1_ := strtointdef(v1, -1);
          v2_ := strtointdef(v2, -1);
          result := v1_ - v2_;
        End;
      MainColDist: Begin // Spalte 2 wird natürlich der km wert als Zahl gerechnet und nicht als String ;)
          If (trim(v1) = '') Or (trim(v2) = '') Then Begin
            result := 0;
          End
          Else Begin
            v1_ := round(strtofloat(trim(copy(v1, 1, pos('k', v1) - 1))) * 10);
            v2_ := round(strtofloat(trim(copy(v2, 1, pos('k', v2) - 1))) * 10);
            result := v1_ - v2_;
          End;
        End;
    Else Begin
        result := CompareStr(lowercase(v1), lowercase(v2));
      End;
    End;
    If Not direction Then result := -result;
  End;

  Procedure Quick(li, re: integer);
  Var
    l, r, i: Integer;
    p, h: String;
  Begin
    If Li < Re Then Begin
      p := StringGrid.cells[Column, Trunc((li + re) / 2)]; // Auslesen des Pivo Elementes
      l := Li;
      r := re;
      While l < r Do Begin
        While Compare(StringGrid.cells[Column, l], p) < 0 Do
          inc(l);
        While Compare(StringGrid.cells[Column, r], p) > 0 Do
          dec(r);
        If L <= R Then Begin
          If l < r Then Begin // Nur Tauschen, wenn die Zeilen auch wirklich unterschiedlich sind.
            For i := 0 To StringGrid.ColCount - 1 Do Begin
              h := StringGrid.Cells[i, l];
              StringGrid.Cells[i, l] := StringGrid.Cells[i, r];
              StringGrid.Cells[i, r] := h;
            End;
          End;
          inc(l);
          dec(r);
        End;
      End;
      quick(li, r);
      quick(l, re);
    End;
  End;

Begin
  StringGrid.BeginUpdate;
  Quick(1, StringGrid.RowCount - 1);
  StringGrid.EndUpdate(true);
End;

Procedure EditCacheNote(Sender: TForm; CacheName: String);
Begin
  StartSQLQuery('Select note from caches where name = "' + CacheName + '"');
  If SQLQuery.EOF Then exit;
  form7.Memo1.Text := FromSQLString(SQLQuery.Fields[0].AsString);
  form7.ModalResult := mrNone;
  form7.SetCaption(format(RF_Edit_Note, [CacheName]));
  FormShowModal(form7, Sender);
  If Form7.ModalResult = mrOK Then Begin
    CommitSQLTransactionQuery('Update caches set note = "' + ToSQLString(form7.Memo1.Text) + '" where name = "' + CacheName + '"');
    SQLTransaction.Commit;
  End;
End;

Procedure ShowCacheHint(Sender: TForm; CacheName: String);
Begin
  StartSQLQuery('Select G_ENCODED_HINTS from caches where name = "' + CacheName + '"');
  If SQLQuery.EOF Then exit;
  form7.Memo1.Text := FromSQLString(SQLQuery.Fields[0].AsString);
  form7.ModalResult := mrNone;
  form7.SetCaption(format(RF_Hint, [CacheName]));
  form7.Memo1.ReadOnly := true;
  FormShowModal(form7, Sender);
  form7.Memo1.ReadOnly := false;
End;

{ TForm1 }

Procedure TForm1.MenuItem5Click(Sender: TObject);
Begin
  // Close
  close;
End;

Procedure TForm1.MenuItem62Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
Begin
  // Set Customer Flag
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set Customer_Flag=1 where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    StringGrid1.Cells[MainColType, i] := AddCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'U');
  End;
  StringGrid1.Invalidate;
  SQLTransaction1.Commit;
End;

Procedure TForm1.MenuItem63Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
Begin
  // Clear Customer Flag
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set Customer_Flag=0 where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    StringGrid1.Cells[MainColType, i] := RemoveCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'U');
  End;
  StringGrid1.Invalidate;
  SQLTransaction1.Commit;
End;

Procedure TForm1.MenuItem65Click(Sender: TObject);
Var
  i: Integer;
Begin
  // Clear All Customer flags
  CommitSQLTransactionQuery('Update caches set Customer_Flag = 0');
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[MainColType, i] := RemoveCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'U');
  End;
  StringGrid1.Invalidate;
  SQLTransaction1.Commit;
End;

Procedure TForm1.MenuItem66Click(Sender: TObject);
Var
  fn: String;
Begin
  // Delete Database
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Error_not_connected_to_database);
    exit;
  End;
  If IDNO = Application.MessageBox(pchar(R_Delete_Database_can_not_be_undone), pchar(r_Warning), MB_YESNO Or MB_ICONQUESTION) Then Begin
    exit;
  End;
  fn := SQLite3Connection1.DatabaseName;
  SQLite3Connection1.Connected := false;
  If Not DeleteFileUTF8(fn) Then Begin
    showmessage(format(RF_Error_could_not_delete, [fn]));
  End;
  // Zugehörige Statistic auch wieder Löschen
  DeleteValue('DB_Statistics', DataBaseNameToIniString(fn));
  CloseDataBase();
  // Automatisches Neu laden/ erstellen einer Datenbank
  form16.modalresult := mrcancel;
  GetDBList(form16.ListBox1.Items, '');
  If form16.ListBox1.Items.Count <> 0 Then Begin
    // Es gibt noch Datenbanken
    MenuItem2Click(Nil);
  End
  Else Begin
    // Es wurde die Letzte Datenbank gelöscht
    MenuItem4Click(Nil);
  End;
End;

Procedure TForm1.MenuItem67Click(Sender: TObject);
Var
  t: int64;
  f: String;
Begin
  form32.CheckBox1.checked := getvalue('PocketDL', 'StartScriptAfterDL', '0') = '1';
  form32.CheckBox2.checked := getvalue('PocketDL', 'ClearImportDirBeforeDL', '0') = '1';
  form32.ReloadScriptCombobox;
  form32.ComboBox1.Text := getvalue('PocketDL', 'ScriptAfterDL', '');
  form32.NeedStartScript := false;
  form32.checkbox2.caption := R_clear_temp_folder_before_download;
  f := GetValue('General', 'LastImportDir', '');
  If f <> '' Then Begin
    form32.CheckBox2.Caption := form32.CheckBox2.Caption + ' (' + f + ')';
  End
  Else Begin
    showmessage(R_No_Import_Folder_Set);
    exit;
  End;
  FormShowModal(form32, self);
  RefreshDataBaseCacheCountinfo();
  Setvalue('PocketDL', 'StartScriptAfterDL', inttostr(ord(form32.CheckBox1.checked)));
  Setvalue('PocketDL', 'ClearImportDirBeforeDL', inttostr(ord(form32.CheckBox2.checked)));
  Setvalue('PocketDL', 'ScriptAfterDL', form32.ComboBox1.Text);
  If form32.NeedStartScript Then Begin
    Application.ProcessMessages; // Dem Dialog Zeit geben sich zu beenden
    t := GetTickCount64;
    CallScript(form32.ComboBox1.Text);
    t := GetTickCount64 - t;
    Showmessage(format(RF_Script_finished_in, [PrettyTime(t)], DefFormat));
  End;
End;

Procedure TForm1.MenuItem69Click(Sender: TObject);
Begin
  // Log Trackables
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  form33.StringGrid1.RowCount := 1;
  form33.ResetHeaderCaptions;
  form33.Edit1.Text := '';
  form33.StringGrid1.AutoSizeColumns;
  FormShowModal(form33, self);
End;

Procedure TForm1.MenuItem74Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
  list: TFieldNoteList;
Begin
  // Log Caches
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  r := StringGrid1.Selection;
  list := Nil;
  setlength(list, r.bottom - r.top + 1);
  For i := r.Top To r.Bottom Do Begin
    list[i - r.top].GC_Code := StringGrid1.Cells[MainColGCCode, i];
    list[i - r.top].Date := GetTime(now);
    list[i - r.top].Logtype := ltFoundIt;
    list[i - r.top].Comment := '';
    list[i - r.top].Fav := false;
    list[i - r.top].reportProblem := rptNoProblem;
    list[i - r.top].Image := '';
  End;
  Form10FieldNotesFilename := '';
  Form10.LoadFieldNoteList(self, list, false);
End;

Procedure TForm1.MenuItem75Click(Sender: TObject);
Begin
  // Edit hint
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  ShowCacheHint(Self, StringGrid1.Cells[MainColGCCode, row]);
End;

Procedure TForm1.MenuItem77Click(Sender: TObject);
Begin
  // Show Logs
  If (row > 0) And (row < StringGrid1.RowCount) Then Begin
    Form20.LoadLogsFromCache(StringGrid1.Cells[MainColGCCode, row]);
    FormShowModal(form20, Self);
  End;
End;

Procedure TForm1.MenuItem78Click(Sender: TObject);
Var
  r: TRect;
  i, j: integer;
  nd, ni, q: String;
Begin
  // redownload Listings
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  nd := '';
  ni := '';
  self.Enabled := false;
  // Die Notwendigen Globalen Variablen anpassen
  For i := r.Top To r.Bottom Do Begin
    // den User Informieren (für jeden Cache einzeln)
    Form4.RefresStatsMethod(StringGrid1.Cells[MainColGCCode, i], r.Bottom - i + 1, 0, i = r.top);
    Case DownloadAndImportCacheByGCCode(StringGrid1.Cells[MainColGCCode, i], True) Of
      0: Begin // Fehlerfrei
          // Aktualisieren des Fund / Archiviert status
          q := QueryToMainGridSelector + 'from caches c where c.NAME = "' + ToSQLString(StringGrid1.Cells[MainColGCCode, i]) + '"';
          StartSQLQuery(q);
          StringGrid1.cells[MainColType, i] := format('|%fx%f', [SQLQuery1.Fields[7].AsFloat, SQLQuery1.Fields[8].AsFloat], DefFormat);
          StringGrid1.Cells[MainColType, i] := CacheNameToCacheType(StringGrid1.Cells[MainColGCCode, i]) + StringGrid1.cells[MainColType, i];
          // TODO: Theoretisch könnte / Müsste hier auch Distanz und Title angepasst werden !
        End;
      1: Begin // Kann nicht runterladen
          If nd = '' Then Begin
            nd := StringGrid1.Cells[MainColGCCode, i];
          End
          Else Begin
            nd := nd + ', ' + StringGrid1.Cells[MainColGCCode, i];
          End;
        End;
      2: Begin // Kann nicht importieren
          If ni = '' Then Begin
            ni := StringGrid1.Cells[MainColGCCode, i];
          End
          Else Begin
            ni := ni + ', ' + StringGrid1.Cells[MainColGCCode, i];
          End;
        End;
    Else Begin // unbekannter Fehler
        self.Enabled := true;
        exit; //Todo: Wäre da eine Fehlermeldung nicht besser ?
      End;
    End;
    If Form4.Abbrechen Then Begin
      Showmessage(R_Process_aborted);
      For j := i + 1 To r.Bottom Do Begin
        If nd = '' Then Begin
          nd := StringGrid1.Cells[MainColGCCode, j];
        End
        Else Begin
          nd := nd + ', ' + StringGrid1.Cells[MainColGCCode, j];
        End;
      End;
      break;
    End;
  End;
  If Form4.Visible Then form4.Hide;
  If (nd <> '') And (ni <> '') Then Begin
    ShowMessage(format(RF_Error_Could_Not_Download_and_not_import, [nd, ni]));
  End
  Else Begin
    If (nd <> '') Then Begin
      ShowMessage(format(RF_Error_Could_Not_Download, [nd]));
    End;
    If (ni <> '') Then Begin
      ShowMessage(format(RF_Error_Could_Not_import, [ni]));
    End;
  End;
  If (nd = '') And (ni = '') Then Begin
    ShowMessage(R_Finished);
  End;
  //Todo: Wenn sich der Logstatus durch die Aktualisierung ändert, dann kriegt das Stringgrid das nicht mit, die Anfrage müsste erneut gesendet werden ...
  self.Enabled := true;
End;

Procedure TForm1.MenuItem79Click(Sender: TObject);
Var
  i: integer;
  list: TFieldNoteList;
Begin
  // Log Caches by GC-Code
  form34.Edit1.Text := '';
  form34.StringGrid1.RowCount := 1;
  FormShowModal(form34, self);
  If Form34.ModalResult = mrOK Then Begin
    list := Nil;
    For i := 1 To Form34.StringGrid1.RowCount - 1 Do Begin
      If form34.StringGrid1.Cells[LogGCCode_CheckedCol, i] = '1' Then Begin
        setlength(list, high(list) + 2);
        list[high(list)].GC_Code := form34.StringGrid1.Cells[LogGCCode_GCCodeCol, i];
        list[high(list)].Date := GetTime(now);
        list[high(list)].Logtype := ltFoundIt;
        list[high(list)].Comment := '';
        list[high(list)].Fav := false;
        list[high(list)].reportProblem := rptNoProblem;
        list[high(list)].Image := '';
        list[high(list)].TBs := Nil;
      End;
    End;
    If high(list) <> -1 Then Begin
      Form10FieldNotesFilename := '';
      Form10.LoadFieldNoteList(self, list, false);
    End
    Else Begin
      ShowMessage(R_Noting_Selected);
    End;
  End;
End;

Procedure TForm1.MenuItem7Click(Sender: TObject);
Var
  i: Integer;
  s: String;
Begin
  // Options
  form3.edit1.text := getvalue('General', 'UserName', '');
  form3.edit3.text := getvalue('General', 'UserID', '');
  form3.edit2.text := getvalue('General', 'CachesPerGPXContainer', '900');
  form3.edit4.text := getvalue('General', 'Logcount', '0');
  form3.edit5.text := getvalue('General', 'ProxyHost', '');
  form3.edit6.text := getvalue('General', 'ProxyPort', '');
  form3.edit7.text := getvalue('General', 'ProxyUser', '');
  form3.edit8.text := getvalue('General', 'ProxyPass', '');
  form3.edit9.text := getvalue('General', 'LogCountFormat', '# %d');
  form3.edit10.text := getvalue('General', 'MapPreviewScrollGrid', '1');
  form3.edit11.text := getvalue('General', 'Password', '');
  form3.edit12.text := getvalue('General', 'GPSBabelFolder', '');
  form3.edit13.text := GetDataBaseDir();
  form3.edit14.text := getvalue('General', 'SearchRemember', '5');
  form3.CheckBox1.Checked := GetValue('General', 'NeverUseHTMLRenderer', '0') = '1';
  form3.CheckBox2.Checked := GetValue('General', 'WarnFoundImportIfNotFromToday', '1') = '1';
  form3.CheckBox3.Checked := GetValue('General', 'CheckDailyForNewVersion', '1') = '1';
  form3.CheckBox4.Checked := GetValue('General', 'ExportModifiedPOI', '0') = '1';
  form3.CheckBox4Change(Nil); // Die Sichtbarkeit von Checkbox5 anpassen
  form3.CheckBox5.Checked := GetValue('General', 'ExludeModifiedPOIMysteries', '1') = '1';
  form3.CheckBox6.Checked := GetValue('General', 'RestoreFormularPositions', '1') = '1';
  form3.CheckBox7.Checked := GetValue('General', 'AppendCCMLink', '0') = '1';
  form3.CheckBox8.Checked := GetValue('General', 'DisableWizard', '0') = '1';
  form3.CheckBox9.Checked := GetValue('General', 'ExportPOIMysteriesOrigCoords', '0') = '1';
  form3.ComboBox1.items.clear;
  For i := 0 To strtoint(getvalue('Locations', 'Count', '0')) - 1 Do Begin
    form3.ComboBox1.items.Add(getvalue('Locations', 'Name' + inttostr(i), ''));
  End;
  form3.ComboBox1.ItemIndex := max(-1, strtointdef(getvalue('General', 'AktualLocation', '-1'), -1));
  form3.ModalResult := mrNone;
  form3.ComboBox2.Text := '';
  form3.ComboBox3.Text := '';
  s := GetValue('General', 'Language', getLang());
  For i := 0 To form3.ComboBox2.items.count - 1 Do Begin
    If pos(s, form3.ComboBox2.items[i]) = 1 Then Begin
      form3.ComboBox2.Text := form3.ComboBox2.items[i];
      break;
    End;
  End;
  If form3.ComboBox2.Text = '' Then Begin
    form3.ComboBox2.Text := form3.ComboBox2.items[0]; // Englisch
  End;
  s := GetValue('General', 'MapLanguage', getLang());
  For i := 0 To form3.ComboBox3.items.count - 1 Do Begin
    If pos(s, form3.ComboBox3.items[i]) = 1 Then Begin
      form3.ComboBox3.Text := form3.ComboBox3.items[i];
      break;
    End;
  End;
  If form3.ComboBox3.Text = '' Then Begin
    form3.ComboBox3.Text := form3.ComboBox3.items[0]; // Englisch
  End;
  form3.Form3ShowWarningOnce := true;
  form3.Form3ShowMapWarningOnce := true;
  FormShowModal(form3, self);
  If form3.ModalResult = mrOK Then Begin
    setvalue('General', 'UserName', form3.edit1.text);
    setvalue('General', 'UserID', form3.edit3.text);
    setvalue('General', 'CachesPerGPXContainer', form3.edit2.text);
    setvalue('General', 'AktualLocation', inttostr(form3.ComboBox1.ItemIndex));
    Setvalue('General', 'Logcount', inttostr(strtointdef(form3.edit4.text, 0)));
    setvalue('General', 'ProxyHost', form3.edit5.text);
    setvalue('General', 'ProxyPort', form3.edit6.text);
    setvalue('General', 'ProxyUser', form3.edit7.text);
    setvalue('General', 'ProxyPass', form3.edit8.text);
    setvalue('General', 'LogCountFormat', form3.edit9.text);
    Setvalue('General', 'MapPreviewScrollGrid', inttostr(strtointdef(form3.edit9.text, 1)));
    setvalue('General', 'Password', form3.edit11.text);
    setvalue('General', 'GPSBabelFolder', form3.edit12.text);
    setValue('General', 'NeverUseHTMLRenderer', inttostr(ord(form3.CheckBox1.Checked)));
    setValue('General', 'WarnFoundImportIfNotFromToday', inttostr(ord(form3.CheckBox2.Checked)));
    setValue('General', 'CheckDailyForNewVersion', inttostr(ord(form3.CheckBox3.Checked)));
    SetValue('General', 'ExportModifiedPOI', inttostr(ord(form3.CheckBox4.Checked)));
    SetValue('General', 'ExludeModifiedPOIMysteries', inttostr(ord(form3.CheckBox5.Checked)));
    setValue('General', 'Language', copy(form3.ComboBox2.text, 1, 2));
    setValue('General', 'MapLanguage', copy(form3.ComboBox3.text, 1, 2));
    setValue('General', 'RestoreFormularPositions', inttostr(ord(form3.CheckBox6.Checked)));
    setValue('General', 'AppendCCMLink', inttostr(ord(form3.CheckBox7.Checked)));
    setValue('General', 'DisableWizard', inttostr(ord(form3.CheckBox8.Checked)));
    setValue('General', 'ExportPOIMysteriesOrigCoords', inttostr(ord(form3.CheckBox9.Checked)));
    setvalue('General', 'SearchRemember', form3.edit14.text);
    RefreshSearchRemember();
    CheckForNewVersion(false);
    If form3.edit13.text <> GetDataBaseDir() Then Begin
      showmessage(format(Rf_You_changed_databasefolder, [GetDataBaseDir(), form3.edit13.text]));
      CloseDataBase();
      SetValue('General', 'Databases', form3.edit13.text);
      setvalue('General', 'LastDB', '');
    End;
  End;
End;

Procedure TForm1.MenuItem80Click(Sender: TObject);
Var
  skipped: Tpoint;
Begin
  // Show Jasmer
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  skipped := Form35.ReloadCachesFromDB;
  If Not form35.Visible Then form35.show;
  If skipped.x <> 0 Then Begin
    showmessage(format(RF_Skipped_caches_as_the_date_lies_in_the_future, [skipped.x]));
  End;
  If skipped.y <> 0 Then Begin
    showmessage(format(RF_Skipped_labcaches, [skipped.y]));
  End;
End;

Procedure TForm1.MenuItem81Click(Sender: TObject);
Var
  query, q, t, s: String;
  cnt: integer;
  tm: Int64;
Begin
  // Download by GC-Code
  (*
   * Wir Akzeptieren GC-Codes Separiert nach Komma oder ' ', mit und Ohne Führendes "GC"
   *)
  s := InputBox(R_Enter_GC_Codes, R_Enter_GC_Codes + ':', '');
  s := StringReplace(s, ',', ' ', [rfReplaceAll]);
  If trim(s) = '' Then exit;
  form1.Enabled := false;
  s := s + ' ';
  cnt := 0;
  q := '';
  tm := GetTickCount64;
  Form4.RefresStatsMethod('', cnt, 0, true);
  While (s <> '') And Not form4.Abbrechen Do Begin
    t := trim(uppercase(copy(s, 1, pos(' ', s) - 1)));
    delete(s, 1, pos(' ', s));
    If t <> '' Then Begin // Wenn der Benutzer die Caches via ", " trennt haben wir sonst zu viele Falsch Positive
      If pos('GC', t) <> 1 Then Begin
        t := 'GC' + t;
      End;
      inc(cnt);
      Form4.RefresStatsMethod(t, cnt, 0, false);
      If DownloadAndImportCacheByGCCode(t, false) = 0 Then Begin
        If q = '' Then Begin
          q := '(c.name = "' + ToSQLString(t) + '")';
        End
        Else Begin
          q := q + ' or ' + LineEnding + '(c.name = "' + ToSQLString(t) + '")';
        End;
      End
      Else Begin
        showmessage(format(RF_Error_Could_Not_Download, [t]));
      End;
    End;
  End;
  If Form4.Visible Then form4.Hide;
  // Alles was Importiert wurde, wird nun auch Angewählt *g*
  If q = '' Then Begin
    // Keine Ergebnisse, also auch nichts anzeigen
  End
  Else Begin
    Query := QueryToMainGridSelector + 'from caches c where ' + q;
    StartSQLQuery(query);
    QueryToMainGrid(tm);
  End;
  form1.Enabled := true;
End;

Procedure TForm1.MenuItem82Click(Sender: TObject);
Begin
  // Wizard
  // Wir Starten Den Wizard wollen aber das alles noch mal abgeklappert wird
  form36.StartWizzard(true, true, true);
  // Sämtliche Menüs werden noch mal neu erstellt, sollte sich was geändert haben (evtl etwas overfitted ;) ).
  CreateExportMenu;
  CreateFilterMenu;
  CreateFieldImportMenu;
  CreateScriptMenu;
  CreateSpoilerMenu;
  CreateToolsMenu;
End;

Procedure TForm1.MenuItem84Click(Sender: TObject);
Var
  tm, desc, longdesc, coord: String;
  lat, lon: Double;
  e: Boolean;
  c: TCache;
  query: String;
Label
  ReEnterLab;
Begin
  form37.ModalResult := mrNone;
  tm := GetValue('Locations', 'Place' + getvalue('General', 'AktualLocation', '0'), '');
  If tm <> '' Then Begin
    lat := strtofloat(copy(tm, 1, pos('x', tm) - 1), DefFormat);
    lon := strtofloat(copy(tm, pos('x', tm) + 1, length(tm)), DefFormat);
  End
  Else Begin
    lat := -1;
    lon := -1;
  End;
  form37.Edit1.Text := ''; // Desc
  form37.Edit2.Text := CoordToString(lat, lon); // Koord
  form37.Edit3.Text := GetTime(Now);
  form37.Memo1.Text := ''; // Long Desc
  ReEnterLab:
  FormShowModal(form37, self);
  If form37.ModalResult = mrOK Then Begin
    desc := trim(form37.Edit1.Text);
    longdesc := trim(form37.Memo1.Text);
    Coord := trim(form37.Edit2.Text);
    tm := form37.Edit3.TEXT;
    e := StringToCoord(Coord, lat, lon);
    If (trim(desc) = '') Or (trim(longdesc) = '') Or (Not e) Or (StrToTime(tm) = -1) Then Begin
      showmessage(R_Error_No_valid_input);
      Goto ReEnterLab;
    End;
    // Alles Plausibel, wir legen einen neuen Labcache an
    c.GC_Code := desc;
    c.Lat := lat;
    c.Lon := lon;
    c.Cor_Lat := -1;
    c.Cor_Lon := -1;
    c.fav := 0;
    c.Time := GetTime(StrToTime(tm));
    c.Desc := desc;
    c.URL := '';
    c.URL_Name := '';
    c.Sym := 'Geocache';
    c.Type_ := '';
    c.Note := '';
    c.G_ID := 0;
    c.G_Available := true;
    c.G_Archived := false;
    // c.G_NEED_ARCHIVED := 0
    c.G_Found := 0;
    c.G_XMLNs := 'http://www.groundspeak.com/cache/1/0/1';
    c.G_Name := desc;
    c.G_Placed_By := '';
    c.G_Owner_ID := 0;
    c.G_Owner := '';
    c.G_Type := Geocache_Lab_Cache;
    c.G_Container := '';
    c.G_Difficulty := 0;
    c.G_Terrain := 0;
    c.G_Country := '';
    c.G_State := '';
    c.G_Short_Description := desc;
    c.G_Short_Description_HTML := false;
    c.G_Long_Description := longdesc;
    c.G_Long_Description_HTML := false;
    c.G_Encoded_Hints := '';

    c.Customer_Flag := 0;
    c.Lite := false;
    c.Logs := Nil;
    // Attribute noch setzen
    c.Waypoints := Nil;
    c.G_Attributes := Nil;
    If Not CacheToDB(c, true, true) Then Begin
      showmessage(R_Error_No_valid_input);
      Goto ReEnterLab;
    End
    Else Begin
      SQLTransaction1.Commit;
      RefreshDataBaseCacheCountinfo();
      // Laden des gerade erstellten LAB
      Query := QueryToMainGridSelector + 'from caches c where c.name="' + c.GC_Code + '";';
      StartSQLQuery(query);
      QueryToMainGrid(GetTickCount64());
    End;
  End;
End;

Procedure TForm1.MenuItem85Click(Sender: TObject);
Begin
  // Travel Bug Database Editor
  form38.PrepareLCL;
  FormShowModal(form38, self);
End;

Procedure TForm1.MenuItem86Click(Sender: TObject);
Var
  s: String;
  list: TFieldNoteList;
Begin
  // Log By Geocache_Visits.txt
  If OpenDialog3.Execute Then Begin
    s := OpenDialog3.FileName;
    If (s <> '') And FileExistsUTF8(s) Then Begin
      Form10FieldNotesFilename := s;
      list := LoadFieldNotesFromFile(s);
      Form10.LoadFieldNoteList(self, list, false);
    End;
  End;
End;

Procedure TForm1.MenuItem87Click(Sender: TObject);
Begin
  MenuItem87.Checked := Not MenuItem87.Checked;
  StringGrid1.Columns[MainColFav].Visible := MenuItem87.Checked;
  StringGrid1Resize(Nil);
  // Die capctions
 //- laden via lite caches
End;

Procedure TForm1.MenuItem88Click(Sender: TObject);
Type
  // TODO: Theoretisch könnte man hier ja alles Updaten was der LiteCache so her gibt ...
  TTempCache = Record
    used: boolean;
    favs: Integer;
    Code: String;
    Time: String;
  End;
Var
  c: Array Of TTempCache;
  i, j, k: integer;
  vp: TViewport;
  lc: TLiteCacheArray;
  b: Boolean;
  archived: integer;
  t: int64;
  cache: TCache;
Begin
  // Refresh Favs / Hidden Date
  If StringGrid1.RowCount <= 1 Then Begin
    ShowMessage(R_Noting_Selected);
    exit;
  End;
  t := GetTickCount64;
  c := Nil;
  setlength(c, StringGrid1.RowCount - 1);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    c[i - 1].favs := 0;
    c[i - 1].used := false;
    c[i - 1].Code := StringGrid1.Cells[MainColGCCode, i];
    c[i - 1].Time := '';
  End;
  archived := 0;
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    If Not (c[i - 1].used) Then Begin
      Form4.RefresStatsMethod(StringGrid1.Cells[MainColTitle, i], i, 0, i = 1); // Wir refreshen jedes mal, wenn neu nachgeladen werden muss
      // 1. Die Coords aus der DB hohlen
      StartSQLQuery('Select lat, lon from caches where name = "' + ToSQLString(c[i - 1].Code) + '"');
      vp.Lat_min := SQLQuery1.Fields[0].AsFloat;
      vp.Lon_min := SQLQuery1.Fields[1].AsFloat;
      vp.Lat_max := SQLQuery1.Fields[0].AsFloat;
      vp.Lon_max := SQLQuery1.Fields[1].AsFloat;
      // 2. das Fenster Hohlen
      lc := Form40.GetAllCachesAround(vp);
      // 3. Alles Updaten
      For j := 0 To high(lc) Do Begin
        For k := i - 1 To high(c) Do Begin
          If c[k].Code = lc[j].GC_Code Then Begin
            c[k].used := true;
            c[k].favs := lc[j].Fav;
            c[k].Time := lc[j].Time;
            break;
          End;
        End;
      End;
      If Not (c[i - 1].used) Then Begin
        inc(archived);
      End;
      If form4.Abbrechen Then Begin
        form4.Hide;
        exit;
      End;
    End;
  End;
  // Übernehmen in die SQL-Datenbank und Anzeigen auf dem Hauptformular
  b := false;
  For i := 0 To high(c) Do Begin
    If i Mod 100 = 0 Then Begin
      Form4.RefresStatsMethod(StringGrid1.Cells[MainColTitle, i + 1], i, 0, false); // Wir refreshen jedes mal, wenn neu nachgeladen werden muss
    End;
    If c[i].used Then Begin
      StringGrid1.Cells[MainColFav, i + 1] := inttostr(c[i].favs);
      cache := CacheFromDB(c[i].Code, true);
      If cache.Fav <> c[i].favs Then Begin
        b := true;
        CommitSQLTransactionQuery('Update Caches set Fav = ' + inttostr(c[i].favs) + ' where name ="' + c[i].Code + '"');
      End;
      If cache.Time <> c[i].Time Then Begin
        b := true;
        CommitSQLTransactionQuery('Update Caches set Time = "' + c[i].Time + '" where name ="' + c[i].Code + '"');
      End;
    End
    Else Begin
      StringGrid1.Cells[MainColFav, i + 1] := '';
    End;
    If form4.Abbrechen Then Begin
      form4.Hide;
      exit;
    End;
  End;
  If b Then Begin
    SQLTransaction1.Commit;
  End;
  StringGrid1.Invalidate;
  form4.Hide;
  t := GetTickCount64() - t;
  If archived <> 0 Then Begin
    showmessage(format(RF_Archived_caches_could_not_be_updated, [archived]) + LineEnding + LineEnding +
      format(RF_Script_finished_in, [PrettyTime(t)], DefFormat));
  End
  Else Begin
    Showmessage(format(RF_Script_finished_in, [PrettyTime(t)], DefFormat));
  End;
End;

Procedure TForm1.MenuItem90Click(Sender: TObject);
Begin
  // Tutorial: How to install CCM
  OpenURL('https://www.youtube.com/watch?v=XDlOMkwiAGs');
End;

Procedure TForm1.MenuItem91Click(Sender: TObject);
Begin
  // Tutorial: Working with Databases
  OpenURL('https://www.youtube.com/watch?v=QlKnDJi_hL8');
End;

Procedure TForm1.MenuItem92Click(Sender: TObject);
Begin
  // Tutorial: Creating Skripts
  OpenURL('https://www.youtube.com/watch?v=3Inn9QPoyuw');
End;

Procedure TForm1.MenuItem93Click(Sender: TObject);
Begin
  // Tutorial: How to handle TB's
  OpenURL('https://www.youtube.com/watch?v=oYHXZXe7-7s');
End;

Procedure TForm1.MenuItem94Click(Sender: TObject);
Var
  i: integer;
Begin
  // Clear History
  For i := 0 To strtointdef(getvalue('General', 'SearchRemember', '5'), 5) - 1 Do Begin
    setvalue('SearchRemember', 'Last' + inttostr(i), '');
  End;
  RefreshSearchRemember;
End;

Procedure TForm1.MenuItem95Click(Sender: TObject);
Begin
  Clipboard.AsText := ComboBox2.Text;
End;

Procedure TForm1.MenuItem96Click(Sender: TObject);
Var
  i, j: integer;
  nc, c: TCache;
  w: TWaypointList;
Begin
  // Convert Waypoints into Caches
  (*
   * Die Convertierung geht von einem LAB aus der mittels "Function TGCTool.DownloadLAB(LAB: TLABCacheInfo; WPsAsCache: Boolean" erstellt wurde !
   *)
  For i := StringGrid1.Selection.Bottom Downto StringGrid1.Selection.Top Do Begin
    c := CacheFromDB(StringGrid1.Cells[MainColGCCode, i]);
    w := WaypointsFromDB(StringGrid1.Cells[MainColGCCode, i]);
    If length(w) >= 1 Then Begin
      For j := 0 To high(w) Do Begin
        nc := c; // Clon des "alten"
        nc.GC_Code := 'Egal wird eh überschrieben ;)';
        nc.G_Name := w[j].Name;
        nc.Time := w[j].Time;
        nc.Lat := w[j].lat;
        nc.Lon := w[j].Lon;
        nc.G_Long_Description := w[j].cmt;
        nc.G_Encoded_Hints := 'See listing ..';
        If Not CacheToDB(nc, false, false) Then Begin
          showmessage('Error while converting WP to Cache, hope you have a bakup..');
          exit;
        End;
      End;
      DelCache(StringGrid1.Cells[MainColGCCode, i]);
      StringGrid1.DeleteRow(i);
    End
    Else Begin
      // Der Cache hat gar keine Wegpunkte -> wir machen hier mal lieber nichts
    End;
  End;
  SQLTransaction1.Commit;
  StringGrid1.Invalidate;
  RefreshDataBaseCacheCountinfo();
End;

Procedure TForm1.MenuItem98Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
  Data: TUserNoteCoord;
  un: String;
  cr: TUserNoteResult;
  ccr: TUserCoordResult;
  CAutoOnline, CAutoLocal: Boolean;
  AutoOK, AutoAppendOK: Boolean;
  clat, clon: Double;
Begin
  // Download Usernotes/ Corrected coords
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If lowercase(GCTGetServerParams().UserInfo.Usertype) <> 'premium' Then Begin
    showmessage(R_Error_This_feature_is_only_available_if_you_have_a_premium_account);
    exit;
  End;
  r := StringGrid1.Selection;
  self.Enabled := false;
  RefresStatsMethod('', 0, r.Bottom - r.Top + 1, true);
  AutoOK := false;
  AutoAppendOK := false;
  CAutoOnline := false;
  CAutoLocal := false;
  For i := r.Top To r.Bottom Do Begin
    If RefresStatsMethod(StringGrid1.Cells[MainColGCCode, i], i - r.Top + 1, r.Bottom - r.Top + 1, false) Then Begin
      break;
    End;
    If GCTGetOnlineNoteAndModifiedCoord(StringGrid1.Cells[MainColGCCode, i], data) Then Begin
      data.UserNote := trim(data.UserNote);
      If trim(data.UserNote) <> '' Then Begin
        // Übernehmen der Usernote
        StartSQLQuery('Select note from caches where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
        If SQLQuery.EOF Then exit;
        un := trim(FromSQLString(SQLQuery.Fields[0].AsString));
        If un <> Data.UserNote Then Begin
          cr := unrOK;
          If AutoOK Then Begin
            // Nichts, data.Usernote ist ja schon korrekt initialisiert, die Lokale wird dann "vernichtet"
          End
          Else Begin
            If AutoAppendOK Then Begin
              // Automatisch die Online Usernote an die Lokale anhängen
              data.UserNote := trim(un) + LineEnding + data.UserNote;
            End
            Else Begin
              If un <> '' Then Begin
                cr := OnCompareUserNote_Online_to_Locale(StringGrid1.Cells[MainColGCCode, i], un, data.UserNote);
                (*
                 * Hier muss nur der Rückgabewert ausgewertet werden, das Ergebnis in data.UserNote wird automatisch korrigiert.
                 *)
                //If (cr = unrAbort) Or (cr = unrError) Then Continue;
                If cr = unrOKAll Then AutoOK := true;
                If cr = unrOKAppendAll Then AutoOK := true;
              End;
            End;
          End;
          If (cr <> unrAbort) And (cr <> unrError) Then Begin
            CommitSQLTransactionQuery('Update caches set note = "' + ToSQLString(data.UserNote) + '" where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
          End;
        End;
      End;
      If (data.Lat <> -1) And (data.Lon <> -1) Then Begin
        // Übernehmen der Korrigierten Koordinaten
        StartSQLQuery('Select cor_lat, cor_lon from caches where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
        clat := SQLQuery.Fields[0].AsFloat;
        clon := SQLQuery.Fields[1].AsFloat;
        If Not CompareCoords(clat, clon, data.Lat, data.Lon) Then Begin
          ccr := ucrOK;
          If CAutoOnline Then Begin
            // Nichts, data.lat / lon sind ja schon richtig
          End
          Else Begin
            If CAutoLocal Then Begin
              // Automatisch die lokale variante übernehmen, wenn diese "gesetzt" ist, sonst wird natürlich die Online Variante gewählt
              If (clat <> -1) And (clon <> -1) Then Begin
                data.Lat := clat;
                data.Lon := clon;
              End;
            End
            Else Begin
              If (clat <> -1) And (clon <> -1) Then Begin
                ccr := OnCompereCorrectedCoords_Online_to_Locale(StringGrid1.Cells[MainColGCCode, i], clat, clon, data.Lat, data.Lon);
                (*
                 * Hier muss nur der Rückgabewert ausgewertet werden, das Ergebnis in data.UserNote wird automatisch korrigiert.
                 *)
                //If (ccr = ucrAbort) Or (ccr = ucrError) Then Continue;
                If ccr = ucrOKAll Then CAutoOnline := true;
                If ccr = ucrOKAllOther Then CAutoLocal := true;
              End;
            End;
          End;
          If (ccr <> ucrAbort) And (ccr <> ucrError) Then Begin
            CommitSQLTransactionQuery('Update caches set ' +
              'COR_LAT = ' + floattostr(data.Lat, DefFormat) + ' ' +
              ',COR_Lon = ' + floattostr(data.Lon, DefFormat) + ' ' +
              'where name = "' + StringGrid1.Cells[MainColGCCode, i] + '";');
          End;
        End;
      End;
    End
    Else Begin
      // Es konnte sich nicht eingeloggt werden.
      break;
    End;
  End;
  SQLTransaction.Commit; // Am Schluß alles Commiten
  Form4.Hide;
  self.Enabled := true;
  ShowMessage(R_Finished);
End;

Procedure TForm1.MenuItem99Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
  un: String;
  clat, clon: Double;
  res: Integer;
  CoordAutoOK, CoordAutoOther,
    NoteAutoOK, NoteAutoAppend: Boolean;
  gc_errors: String;
Begin
  // Upload Usernotes/ corrected coords
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If lowercase(GCTGetServerParams().UserInfo.Usertype) <> 'premium' Then Begin
    showmessage(R_Error_This_feature_is_only_available_if_you_have_a_premium_account);
    exit;
  End;
  r := StringGrid1.Selection;
  self.Enabled := false;
  RefresStatsMethod('', 0, r.Bottom - r.Top + 1, true);
  NoteAutoOK := false;
  NoteAutoAppend := false;
  CoordAutoOK := false;
  CoordAutoOther := false;
  gc_errors := '';
  For i := r.Top To r.Bottom Do Begin
    If RefresStatsMethod(StringGrid1.Cells[MainColGCCode, i], i - r.Top + 1, r.Bottom - r.Top + 1, false) Then Begin
      break;
    End;
    // 1. Auslesen aus DB
    StartSQLQuery('Select note from caches where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    un := FromSQLString(SQLQuery.Fields[0].AsString);
    StartSQLQuery('Select cor_lat, cor_lon from caches where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    clat := SQLQuery.Fields[0].AsFloat;
    clon := SQLQuery.Fields[1].AsFloat;
    // 2. Ab damit ins Netz
    If (GCTSetOnlineNoteAndModifiedCoord(
      StringGrid1.Cells[MainColGCCode, i],
      un, @OnCompareUserNote_Locale_to_Online, NoteAutoOK, NoteAutoAppend, @OnNoteEdit,
      clat, clon, @OnCompereCorrectedCoords_Locale_to_Online, CoordAutoOK, CoordAutoOther, res)) Then Begin
      // Es gibt eigentlich nichts zu tun außer sich die "Flags" zu merken
      If (res And NCR_Note_Auto_all) <> 0 Then NoteAutoOK := true;
      If (res And NCR_Note_Auto_Append) <> 0 Then NoteAutoAppend := true;
      If (res And NCR_Coord_Auto_OK) <> 0 Then CoordAutoOK := true;
      If (res And NCR_Coord_Auto_Other) <> 0 Then CoordAutoOther := true;
      If (res And NCR_ERROR) <> 0 Then Begin
        If gc_errors = '' Then Begin
          gc_errors := StringGrid1.Cells[MainColGCCode, i];
        End
        Else Begin
          gc_errors := gc_errors + ', ' + StringGrid1.Cells[MainColGCCode, i];
        End;
      End;
    End
    Else Begin
      // Es konnte sich nicht eingeloggt werden.
      break;
    End;
  End;
  Form4.Hide;
  self.Enabled := true;
  If gc_errors <> '' Then Begin
    showmessage(Format(RF_The_Following_Caches_have_had_Errors_during_Upload_Please_Check, [gc_errors]));
  End
  Else Begin
    ShowMessage(R_Finished);
  End;
End;

Procedure TForm1.StringGrid1DblClick(Sender: TObject);
Begin
  // Open cache Preview
  If (row > 0) And (row < StringGrid1.RowCount) Then Begin
    If form13.OpenCache(StringGrid1.Cells[MainColGCCode, row]) Then Begin
      FormShowModal(form13, self);
    End
    Else Begin
      showmessage(R_Not_Existing);
    End;
  End;
End;

Procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
Var
  c: TColor;
  w, h, jj, ii, IconCol, x, y: integer;
  sr: TStringGrid;
  t: String;
Begin
  // Alle Stringgrids, welche Cacheinformationen Zeichnen nutzen die selbe Render Routine
  IconCol := -1; // Stringgrid ohne Bildchen
  If sender = StringGrid1 Then IconCol := MainColType; // Form1 ists Spalte 0
  If sender = Form10.StringGrid1 Then IconCol := GPSImportColType; // Form10 ists Spalte 1
  If sender = Form17.StringGrid1 Then IconCol := WayPointColSym; // Form17 ists Spalte 0
  If Sender = Form22.StringGrid1 Then IconCol := LogOnlineColType; // Form22 ists Spalte 1
  If ((sender = Form22.StringGrid1) And (arow > 0) And (acol = LogOnlineColFav)) Or
    ((sender = Form10.StringGrid1) And (arow > 0) And (acol = GPSImportColFav)) Then Begin // Der Log Online Dialog rendert zusätzlich noch Favs ;)
    sr := Sender As TStringGrid;
    c := sr.Canvas.Pen.Color;
    sr.Canvas.Pen.Color := clNone;
    sr.Canvas.Rectangle(aRect);
    If sr.cells[acol, aRow] = '1' Then Begin
      ImageList1.Draw(sr.Canvas, aRect.Left + (aRect.Right - aRect.Left - 16) Div 2,
        aRect.Top + (aRect.Bottom - aRect.Top - 16) Div 2, MainImageIndexFavourite);
    End;
    sr.Canvas.Pen.Color := c;
  End;
  If (sender = Form10.StringGrid1) And (arow > 0) And (acol = GPSImportColCacheFoundState) Then Begin // Der Field Note Editor Rendert die Logstates
    sr := Sender As TStringGrid;
    c := sr.Canvas.Pen.Color;
    sr.Canvas.Pen.Color := clNone;
    sr.Canvas.Rectangle(aRect);
    t := LogtypeToString(LogtypeIndexToLogtype(strtoint(sr.Cells[acol, arow])));
    w := ((arect.Right - aRect.Left) - Canvas.TextWidth(t)) Div 2;
    h := ((arect.Bottom - aRect.Top) - Canvas.TextHeight(t)) Div 2;
    sr.canvas.TextOut(arect.left + w, arect.Top + h, t);
    sr.Canvas.Pen.Color := c;
  End;
  If (sender = Form10.StringGrid1) And (arow > 0) And (acol = GPSImportColCacheProblem) Then Begin // Der Field Note Editor Rendert die Problemstates
    sr := Sender As TStringGrid;
    c := sr.Canvas.Pen.Color;
    sr.Canvas.Pen.Color := clNone;
    sr.Canvas.Rectangle(aRect);
    t := ProblemToString(ProblemtypeIndexToProblemtype(strtoint(sr.Cells[acol, arow])));
    w := ((arect.Right - aRect.Left) - Canvas.TextWidth(t)) Div 2;
    h := ((arect.Bottom - aRect.Top) - Canvas.TextHeight(t)) Div 2;
    sr.canvas.TextOut(arect.left + w, arect.Top + h, t);
    sr.Canvas.Pen.Color := c;
  End;

  If (arow > 0) And (acol = IconCol) Then Begin // Das Rendern der Icons und D/T-Wertungen
    sr := Sender As TStringGrid;
    c := sr.Canvas.Pen.Color;
    sr.Canvas.Pen.Color := clNone;
    sr.Canvas.Rectangle(aRect);
    ii := CacheTypeToIconIndex(sr.Cells[acol, arow]);
    If ii <> -1 Then Begin
      If MenuItem50.Checked Then Begin
        jj := CacheTypeToDTIcon(sr.Cells[acol, arow]);
      End
      Else Begin
        jj := -1;
      End;
      If jj < 0 Then Begin
        ImageList1.Draw(sr.Canvas, aRect.Left + (aRect.Right - aRect.Left - 16) Div 2,
          aRect.Top + (aRect.Bottom - aRect.Top - 16) Div 2, ii);
      End
      Else Begin
        ImageList1.Draw(sr.Canvas, aRect.Left + (aRect.Right - aRect.Left - (16 + 24)) Div 2,
          aRect.Top + (aRect.Bottom - aRect.Top - 16) Div 2, ii);
        ImageList2.Draw(sr.Canvas, aRect.Left + (aRect.Right - aRect.Left - (16 + 24)) Div 2 + 16 + 4,
          aRect.Top + (aRect.Bottom - aRect.Top - 16) Div 2, jj Mod 10);
        ImageList2.Draw(sr.Canvas, aRect.Left + (aRect.Right - aRect.Left - (16 + 24)) Div 2 + 16 + 12 + 4,
          aRect.Top + (aRect.Bottom - aRect.Top - 16) Div 2, (jj Div 10) + 9);
      End;
    End
    Else Begin
      x := sr.Canvas.TextWidth(sr.Cells[acol, arow]);
      y := sr.Canvas.TextHeight(sr.Cells[acol, arow]);
      sr.Canvas.TextOut(aRect.Left + (aRect.Right - aRect.Left - x) Div 2,
        aRect.Top + (aRect.Bottom - aRect.Top - y) Div 2,
        sr.Cells[acol, arow]);
    End;
    sr.Canvas.Pen.Color := c;
  End;
End;

Procedure TForm1.StringGrid1HeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
Begin
  // Sortieren der Jeweiligen Spalte Alphabetisch Auf oder Absteigend
  Case Index Of
    MainColType: Begin // Sortieren nach Name
        //StringGrid1.Columns[MainColType].Title.caption  := R_Form1_Type;
        StringGrid1.Columns[MainColFav].Title.caption := R_Fav;
        StringGrid1.Columns[MainColGCCode].Title.caption := R_Code;
        StringGrid1.Columns[MainColDist].Title.caption := 'km';
        StringGrid1.Columns[MainColTitle].Title.caption := R_Title;
        If (StringGrid1.Columns[MainColType].Title.caption = R_Type_DT) Or (StringGrid1.Columns[MainColType].Title.caption = R_Type_DT + ' /\') Then Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type_DT + ' \/';
          SortColumn(StringGrid1, MainColType, true);
        End
        Else Begin
          If (StringGrid1.Columns[MainColType].Title.caption = R_Type_DT + ' \/') Then Begin
            StringGrid1.Columns[MainColType].Title.caption := R_Type_DT + ' /\';
            SortColumn(StringGrid1, MainColType, false);
          End
          Else Begin
            If (StringGrid1.Columns[MainColType].Title.caption = R_Type) Or (StringGrid1.Columns[MainColType].Title.caption = R_Type + ' /\') Then Begin
              // Aufsteigend Sortieren
              StringGrid1.Columns[MainColType].Title.caption := R_Type + ' \/';
              SortColumn(StringGrid1, MainColType, true);
            End
            Else Begin
              // Absteigend Sortieren
              StringGrid1.Columns[MainColType].Title.caption := R_Type + ' /\';
              SortColumn(StringGrid1, MainColType, false);
            End;
          End;
        End;
      End;
    MainColFav: Begin // Sortieren nach Fav
        If MenuItem50.Checked Then Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type_DT;
        End
        Else Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type;
        End;
        //StringGrid1.Columns[MainColFav].Title.caption := R_Fav;
        StringGrid1.Columns[MainColGCCode].Title.caption := R_Code;
        StringGrid1.Columns[MainColDist].Title.caption := 'km';
        StringGrid1.Columns[MainColTitle].Title.caption := R_Title;
        If (StringGrid1.Columns[MainColFav].Title.caption = R_Fav) Or (StringGrid1.Columns[MainColFav].Title.caption = R_Fav + ' /\') Then Begin
          // Aufsteigend Sortieren
          StringGrid1.Columns[MainColFav].Title.caption := R_Fav + ' \/';
          SortColumn(StringGrid1, MainColFav, true);
        End
        Else Begin
          // Absteigend Sortieren
          StringGrid1.Columns[MainColFav].Title.caption := R_Fav + ' /\';
          SortColumn(StringGrid1, MainColFav, false);
        End;
      End;
    MainColGCCode: Begin // Sortieren nach Typ
        If MenuItem50.Checked Then Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type_DT;
        End
        Else Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type;
        End;
        StringGrid1.Columns[MainColFav].Title.caption := R_Fav;
        //StringGrid1.Columns[MainColGCCode].Title.caption := R_Form1_Code;
        StringGrid1.Columns[MainColDist].Title.caption := 'km';
        StringGrid1.Columns[MainColTitle].Title.caption := R_Title;
        If (StringGrid1.Columns[MainColGCCode].Title.caption = R_Code) Or (StringGrid1.Columns[MainColGCCode].Title.caption = R_Code + ' /\') Then Begin
          // Aufsteigend Sortieren
          StringGrid1.Columns[MainColGCCode].Title.caption := R_Code + ' \/';
          SortColumn(StringGrid1, MainColGCCode, true);
        End
        Else Begin
          // Absteigend Sortieren
          StringGrid1.Columns[MainColGCCode].Title.caption := R_Code + ' /\';
          SortColumn(StringGrid1, MainColGCCode, false);
        End;
      End;
    MainColDist: Begin // Sortieren nach Distanz
        If MenuItem50.Checked Then Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type_DT;
        End
        Else Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type;
        End;
        StringGrid1.Columns[MainColFav].Title.caption := R_Fav;
        StringGrid1.Columns[MainColGCCode].Title.caption := R_Code;
        //StringGrid1.Columns[MainColDist].Title.caption := 'km';
        StringGrid1.Columns[MainColTitle].Title.caption := R_Title;
        If (StringGrid1.Columns[MainColDist].Title.caption = 'km') Or (StringGrid1.Columns[MainColDist].Title.caption = 'km /\') Then Begin
          // Aufsteigend Sortieren
          StringGrid1.Columns[MainColDist].Title.caption := 'km \/';
          SortColumn(StringGrid1, MainColDist, true);
        End
        Else Begin
          // Absteigend Sortieren
          StringGrid1.Columns[MainColDist].Title.caption := 'km /\';
          SortColumn(StringGrid1, MainColDist, false);
        End;
      End;
    MainColTitle: Begin // Sortieren nach Titel
        If MenuItem50.Checked Then Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type_DT;
        End
        Else Begin
          StringGrid1.Columns[MainColType].Title.caption := R_Type;
        End;
        StringGrid1.Columns[MainColFav].Title.caption := R_Fav;
        StringGrid1.Columns[MainColGCCode].Title.caption := R_Code;
        StringGrid1.Columns[MainColDist].Title.caption := 'km';
        //StringGrid1.Columns[MainColTitle].Title.caption := R_Title;
        If (StringGrid1.Columns[MainColTitle].Title.caption = R_Title) Or (StringGrid1.Columns[MainColTitle].Title.caption = R_Title + ' /\') Then Begin
          // Aufsteigend Sortieren
          StringGrid1.Columns[MainColTitle].Title.caption := R_Title + ' \/';
          SortColumn(StringGrid1, MainColTitle, true);
        End
        Else Begin
          // Absteigend Sortieren
          StringGrid1.Columns[MainColTitle].Title.caption := R_Title + ' /\';
          SortColumn(StringGrid1, MainColTitle, false);
        End;
      End;
  End;
End;

Procedure TForm1.StringGrid1KeyPress(Sender: TObject; Var Key: char);
Begin
  // Weiterleitung nach Preview Cache
  If key = #13 Then StringGrid1.OnDblClick(Nil);
End;

Procedure TForm1.StringGrid1Resize(Sender: TObject);
Begin
  // Automatisches Anpassen der Spaltenbreiten
  If StringGrid1.Columns[MainColFav].Visible Then Begin
    StringGrid1.ColWidths[MainColTitle] := max(25, StringGrid1.Width - StringGrid1.ColWidths[MainColType] - StringGrid1.ColWidths[MainColGCCode] - StringGrid1.ColWidths[MainColDist] - StringGrid1.ColWidths[MainColFav] - 24);
  End
  Else Begin
    StringGrid1.ColWidths[MainColTitle] := max(25, StringGrid1.Width - StringGrid1.ColWidths[MainColType] - StringGrid1.ColWidths[MainColGCCode] - StringGrid1.ColWidths[MainColDist] - 24);
  End;
End;

Procedure TForm1.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  Var CanSelect: Boolean);
Begin
  // Speichern welche Zeile gerade durch den User angewählt wurde.
  Row := aRow;
End;

Procedure TForm1.UniqueInstance1OtherInstance(Sender: TObject;
  ParamCount: Integer; Const Parameters: Array Of String);
Begin
  (*
   * eine 2. Instanz des CCM wurde gestartet. Dann bringen wir uns mal wieder in den Vordergrund
   *)
  BringFormBackToScreen(form1);
  Application.Restore;
  Application.BringToFront;
End;

Function TForm1.getLang: String;
  Function strinarr(value: String; arr: Array Of String): Boolean;
  Var
    i: integer;
  Begin
    result := false;
    For i := 0 To high(arr) Do Begin
      If arr[i] = value Then Begin
        result := true;
        exit;
      End;
    End;
  End;
Begin
  result := Get_System_Default_Language();
  If length(result) > 2 Then result := result[1] + result[2];
  result := GetValue('General', 'Language', result);
  result := lowercase(result);
  // Aktuell wird nur Deutsch und Englisch unterstützt
  // Sollten noch weitere Sprachen hinzu kommen, sind diese hier
  // ein zu fügen.
  If Not (strinarr(result, [
    'en', // Englisch -- Entwicklungssprache
    'de' // Deutsch
    ])) Then Begin
    result := 'en';
  End;
End;

Procedure TForm1.LoadAndApplyLanguage;
Var
  folder, lang: String;
  i: Integer;
Begin
  // Raussuchen der Aktuellen SystemSprache bzw der gespeicherten
  lang := getLang();
  folder := IncludeTrailingPathDelimiter(GetAppConfigDir(false));
  // Wenn der CCM via IDE gestartet wird (ein paramstr = '-lazarus-ide')
  // Dann Aktivieren wir das Nachfragen nach Änderungen in der Hauptsprache
  For i := 1 To ParamCount Do Begin
    If lowercase(ParamStr(i)) = '-lazarus-ide' Then Begin
      Language.AskNameChanges := true;
      lang := 'en';
      setValue('General', 'Language', lang);
      folder := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0))); // Wieder auf die Original Datei verweisen
      break;
    End;
  End;
  lang := folder + 'ccmlang.' + lang;
  (*
   * Bevor die Sprache umgestellt werden kann muss erst mal aufgeräumt werden
   *)
  Language.AddIgnoredIdentifier('Form1.Caption'); // Anzeige, welche DB gerade ausgwählt ist
  Language.AddIgnoredIdentifier('Form1.OpenPictureDialog1.Filter'); // Bilder Auswahldialog
  Language.AddIgnoredIdentifier('Form1.ComboBox2.items'); // Filter für Suchanfragen
  Language.AddIgnoredComponent(form1.StatusBar1); // Schnell Anzeige
  Language.AddIgnoredComponent(form1.StringGrid1); // Die Liste der Caches
  Language.AddIgnoredComponent(form1.ComboBox1); // Die Filter Anzeige
  Language.AddIgnoredComponent(form3.ComboBox1); // Die Home Lokation
  Language.AddIgnoredComponent(form3.ComboBox2); // Die Sprachauswahl
  Language.AddIgnoredComponent(Form4.Label2); // -- Progressbar Info1
  Language.AddIgnoredComponent(Form4.Label4); // -- Progressbar Info1
  Language.AddIgnoredComponent(Form4.Label6); // -- Progressbar Info1
  Language.AddIgnoredComponent(Form5.Label1); // Anzeige Koord
  Language.AddIgnoredComponent(Form5.Label2); // Anzeige Koord
  Language.AddIgnoredComponent(Form5.ComboBox2); // N/S Auswahl
  Language.AddIgnoredComponent(Form5.ComboBox3); // W/E Auswahl
  Language.AddIgnoredComponent(Form6.Label3); // Präfix SQL-Query
  Language.AddIgnoredIdentifier('Form7.Caption'); // Edit Note / Show Hint - Dialog
  Language.AddIgnoredIdentifier('Form10.Caption'); // Field note Editor
  Language.AddIgnoredComponent(form10.StringGrid1); // Die Liste der Fieldnotes
  Language.AddIgnoredComponent(Form12.ComboBox1); // 81-Matrix Anzeige auswahl nach typ
  Language.AddIgnoredComponent(Form12.label4); // Anzeige DT-Wertung
  Language.AddIgnoredComponent(Form12.label5); // Anzeige Size
  Language.AddIgnoredComponent(Form12.label6); // Anzeige Size
  Language.AddIgnoredComponent(Form12.label7); // Anzeige Size
  Language.AddIgnoredComponent(Form12.label8); // Anzeige Size
  Language.AddIgnoredComponent(Form12.label9); // Anzeige Size
  Language.AddIgnoredComponent(Form12.label10); // Anzeige Size
  Language.AddIgnoredComponent(Form12.label11); // Anzeige Size
  Language.AddIgnoredComponent(Form12.label12); // Anzeige Size
  Language.AddIgnoredComponent(Form12.StringGrid1); // Anzeige 81-Matrix
  Language.AddIgnoredIdentifier('Form13.Caption'); // Cache preview
  Language.AddIgnoredComponent(Form13.Label1); // Cache preview
  Language.AddIgnoredComponent(Form13.Label2); // Cache preview
  Language.AddIgnoredComponent(Form13.Label3); // Cache preview
  Language.AddIgnoredComponent(Form13.Label4); // Cache preview
  Language.AddIgnoredComponent(Form13.Label5); // Cache preview
  Language.AddIgnoredComponent(Form14.ComboBox5); // W/E Auswahl
  Language.AddIgnoredComponent(Form14.ComboBox4); // N/S Auswahl
  Language.AddIgnoredComponent(Form14.ComboBox3); // W/E Auswahl
  Language.AddIgnoredComponent(Form14.ComboBox2); // N/S Auswahl
  Language.AddIgnoredIdentifier('Form15.Caption'); // Map-Preview
  Language.AddIgnoredComponent(Form17.ComboBox1); // Auswahl Wegpunkt Typ
  Language.AddIgnoredComponent(Form17.Label2); // Cachename
  Language.AddIgnoredComponent(Form19.ComboBox2); // Auswahl der Root Nodes (user Generierter Code)
  Language.AddIgnoredComponent(form19.button7); // Auswahl im Tool Editor
  Language.AddIgnoredComponent(form19.button6); // Auswahl im Tool Editor
  Language.AddIgnoredComponent(Form20); // Logs vorschau
  Language.AddIgnoredComponent(Form22.StringGrid1); // Beim online loggen die Übersicht der TB's
  Language.AddIgnoredIdentifier('Form24.Caption'); // SQL Admit Konsole
  Language.AddIgnoredComponent(Form24.ComboBox1); // Auswahl Filter
  Language.AddIgnoredComponent(Form27.ComboBox1); // Skript Namen
  Language.AddIgnoredComponent(Form27.Label4); // Beschriftung Skript Editor
  Language.AddIgnoredComponent(Form27.Label5); // Beschriftung Skript Editor
  Language.AddIgnoredComponent(Form27.Label6); // Beschriftung Skript Editor
  Language.AddIgnoredComponent(Form27.CheckBox1); // Beschriftung Skript Editor
  Language.AddIgnoredComponent(Form27.CheckBox2); // Beschriftung Skript Editor
  Language.AddIgnoredComponent(Form28.Label1); // Skript überschreiben
  Language.AddIgnoredComponent(Form29.ComboBox1); // Die Auswahl der Attribute des Custom Filter Dialogs
  Language.AddIgnoredComponent(form29.label4); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label5); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label6); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label7); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label8); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label9); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label10); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label11); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label12); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label13); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label14); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label15); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label16); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label17); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label18); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label19); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label20); // DT-Anzeige
  Language.AddIgnoredComponent(form29.label21); // DT-Anzeige
  Language.AddIgnoredComponent(Form32.CheckBox2); // Anzeige des Import Verzeichnisses beim DL-Dialog
  Language.AddIgnoredComponent(Form34.Edit1); // Eingabefeld beim Loggen nach GC-Code

  Language.AddIgnoredComponent(Form36.ComboBox4); // N/S Auswahl
  Language.AddIgnoredComponent(Form36.ComboBox5); // W/E Auswahl

  Language.AddIgnoredComponent(Form37.edit1); // LAB-Cache Editor
  Language.AddIgnoredComponent(Form37.edit2); // LAB-Cache Editor
  Language.AddIgnoredComponent(Form37.edit3); // LAB-Cache Editor
  Language.AddIgnoredComponent(Form37.Memo1); // LAB-Cache Editor

  Language.AddIgnoredComponent(Form38.Label4); // Beispiel Datum
  Language.AddIgnoredComponent(Form38.Label5); //
  Language.AddIgnoredComponent(Form38.Label8); //

  Language.AddIgnoredIdentifier('Form39.Caption'); // Beschriftung Auswahl

  Language.AddIgnoredComponent(Form41.Label2); // "Uwe Schächterle"
  Language.AddIgnoredIdentifier('Form41.Label3.hint'); // URL für Webseite
  Language.AddIgnoredComponent(Form41.Label4); // Versions Informationen
  Language.AddIgnoredComponent(Form41.Label5); // SSL-Hinweis
  Language.AddIgnoredComponent(Form41.Label7); // Lizenz

  Language.AddIgnoredComponent(Form42.Label5); // TB-Vorschau
  Language.AddIgnoredComponent(Form42.Label7); // TB-Vorschau
  Language.AddIgnoredComponent(Form42.Label9); // TB-Vorschau
  Language.AddIgnoredComponent(Form42.Label11); // TB-Vorschau
  Language.AddIgnoredComponent(Form42.Label14); // TB-Vorschau
  Language.AddIgnoredComponent(Form42.Label15); // TB-Vorschau
  Language.AddIgnoredComponent(Form42.Label16); // TB-Vorschau

  Language.AddIgnoredIdentifier('Form43.Caption'); // User Note Diff dialog
  Language.AddIgnoredComponent(Form43.Panel1);
  Language.AddIgnoredComponent(Form43.Panel2);
  Language.AddIgnoredComponent(Form43.Panel3);
  Language.AddIgnoredComponent(Form43.Panel4);
  Language.AddIgnoredComponent(Form43.Button1); // User Note Diff dialog
  Language.AddIgnoredComponent(Form43.Button3); // User Note Diff dialog
  Language.AddIgnoredComponent(Form43.label1); // User Note Diff dialog
  Language.AddIgnoredComponent(Form43.Label2); // User Note Diff dialog
  Language.AddIgnoredComponent(Form43.Label3); // User Note Diff dialog
  Language.AddIgnoredComponent(Form43.Memo1); // User Note Diff dialog
  Language.AddIgnoredComponent(Form43.Memo2); // User Note Diff dialog

  Language.AddIgnoredIdentifier('Form44.Caption'); // Coord Diff dialog
  Language.AddIgnoredComponent(Form44.Button2); // Coord Diff dialog
  Language.AddIgnoredComponent(Form44.Button3); // Coord Diff dialog
  Language.AddIgnoredComponent(Form44.label1); // Coord Diff dialog
  Language.AddIgnoredComponent(Form44.Label2); // Coord Diff dialog
  Language.AddIgnoredComponent(Form44.Edit1); // Coord Diff dialog
  Language.AddIgnoredComponent(Form44.Edit2); // Coord Diff dialog

  // Das eigentliche setzen der Sprache
  Language.CurrentLanguage := lang;
End;

Procedure TForm1.UpdateResultCallback(AlwaysShowResult: Boolean;
  OnlineVersions: TVersionArray);
Var
  lang, ReleaseText, Dir: String;
  Ver: TVersion;
  i: Integer;
Begin
  // Wenn Need Update = True, dann muss der User gefragt werden
  If Not assigned(OnlineVersions) Then Begin
    If AlwaysShowResult Then Begin
      ShowMessage(fUpdater.LastError);
    End;
    exit;
  End;
  // Suchen der Version die zu uns gehört
  ver.name := '';
  For i := 0 To high(OnlineVersions) Do Begin
    If LowerCase(OnlineVersions[i].Name) = 'ccm' Then Begin
      ver := OnlineVersions[i];
      break;
    End;
  End;
  If ver.name = '' Then Begin
    showmessage(R_Could_not_Download_valid_Version_Information);
    exit;
  End;
  If strtofloat(ver.Version, DefFormat) > strtofloat(Version, DefFormat) Then Begin
    ReleaseText := ver.ReleaseText;
    // Evtl. gibts einen Releasetext in der gerade gewählten Sprache, dann nehmen wir den ;)
    lang := getLang();
    For i := 0 To high(ver.Additionals) Do Begin
      If lowercase(Ver.Additionals[i].Ident) = 'release_text_' + lang Then Begin
        ReleaseText := Ver.Additionals[i].Value;
        break;
      End;
    End;
    If ID_YES = application.MessageBox(pchar(
      format(RF_VersionInfo, [version, ver.Version, ReleaseText])), pchar(R_Information), MB_YESNO Or MB_ICONINFORMATION) Then Begin
      If Not GetWorkDir(dir) Then Begin
        showmessage(R_Unable_to_create_workdir);
      End
      Else Begin
        self.Enabled := false;
        form4.RefresStatsMethod(R_Starting_update_please_wait, 0, 0, True);
        If fUpdater.DoUpdate_Part1(dir, ver) Then Begin
          self.Enabled := true;
          close;
        End
        Else Begin
          showmessage(format(RF_An_Error_Occured, [fUpdater.LastError]));
          If form4.visible Then form4.Hide;
          self.Enabled := true;
        End;
      End;
    End;
  End
  Else Begin
    If AlwaysShowResult Then Begin
      showmessage(R_Your_Version_is_up_to_date);
    End;
  End;
End;

Procedure TForm1.CheckForNewVersion(AlwaysShowResult: Boolean);
Var
  adate: String;
Begin
  (*
   * Kann so oft wie es will aufgerufen werden, geht maximal 1 mal Pro Tag
   *)
  If GetValue('General', 'CheckDailyForNewVersion', '1') = '1' Then Begin
    adate := FormatDateTime('YYYY-MM-DD', now);
    If GetValue('General', 'LastCheckForNewVersion', '-') <> adate Then Begin
      setValue('General', 'LastCheckForNewVersion', adate);
      fUpdater.ProxyHost := getvalue('General', 'ProxyHost', '');
      fUpdater.ProxyPort := getvalue('General', 'ProxyPort', '');
      fUpdater.ProxyUser := getvalue('General', 'ProxyUser', '');
      fUpdater.ProxyPass := getvalue('General', 'ProxyPass', '');
      fUpdater.GetVersions(URL_CheckForUpdate, AlwaysShowResult, @UpdateResultCallback);
    End;
  End;
End;

Function TForm1.OpenTBDatabase: Boolean;
Var
  fn: String;
Begin
  result := true;
  If SQLite3Connection2.Connected Then exit; // Wir sind schon verbunden raus
  result := false;
  fn := GetDataBaseDir() + 'trackables.tdb';
  If Not FileExistsUTF8(fn) Then Begin
    CreateNewTBDatabase(fn);
    result := true;
    exit;
  End;
  If Not FileExistsUTF8(fn) Then Begin
    showmessage(format(RF_Could_Not_Load, [fn]));
    exit;
  End;
  SQLite3Connection2.DatabaseName := fn;
  Try
    SQLite3Connection2.Connected := true;
  Except
    On e: Exception Do Begin
      ShowMessage(format(RF_Error_Could_not_Connect, [e.Message]));
      exit;
    End;
  End;

  // Ab Version 2.26 des ccm unterstützt dieser das "Heading" in den TB's, wenn es dass noch nicht gibt fügen wir es nun an
  If Not ColumnExistsInTBTable('Heading', 'trackables') Then Begin
    TB_CommitSQLTransactionQuery('Alter Table trackables add column Heading');
    SQLTransaction2.Commit;
    TB_CommitSQLTransactionQuery('Update trackables set Heading = ""');
    SQLTransaction2.Commit;
  End;
  result := true;
End;

Procedure TForm1.OnApplicationRestore(Sender: TObject);
Begin
  (*
   * Besonders unter Windows kann es passieren, dass die Z-Reihenfolge der Fenster durcheinander kommt.
   * => Die Anwendung blockiert dann komplett, ein minimieren und maximieren kann dies nun retten.
   *)
  If Form4.Visible Then Begin
    Form4.BringToFront;
  End;
End;

Procedure TForm1.RefreshDataBaseCacheCountinfo;
Begin
  StartSQLQuery('Select count(*) from caches');
  If SQLQuery1.EOF Then Begin
    fCacheCountInActualDB := -1;
  End
  Else Begin
    fCacheCountInActualDB := SQLQuery1.Fields[0].AsInteger;
  End;
  StatusBar1.Panels[MainSBarCCount].Text := R_Total + ': ' + inttostr(fCacheCountInActualDB);

  SetValue('DB_Statistics', DataBaseNameToIniString(SQLite3Connection1.DatabaseName), inttostr(fCacheCountInActualDB));
End;

Function TForm1.AddSearchRemember(NewSearch: String): boolean;
Var
  i, j: integer;
  cnt: LongInt;
  s: String;
Begin
  result := false;
  NewSearch := trim(NewSearch);
  // Gibt es die Suchanfrage bereits ?
  For i := 0 To ComboBox2.Items.Count - 1 Do Begin
    If lowercase(NewSearch) = lowercase(ComboBox2.Items[i]) Then Begin
      If i <> 0 Then Begin // Die neue Suchanfrage ist nicht die 1. also sortieren wir die Reihenfolge um
        result := true;
        For j := i Downto 1 Do Begin
          s := getvalue('SearchRemember', 'Last' + inttostr(j - 1), '');
          setvalue('SearchRemember', 'Last' + inttostr(j), s);
        End;
        setvalue('SearchRemember', 'Last0', NewSearch);
      End;
      exit;
    End;
  End;
  // Es Gibt Die Suchanfrage noch nicht also Shiften wir alle um 1 nach Oben
  result := true;
  cnt := strtointdef(getvalue('General', 'SearchRemember', '5'), 5);
  For i := cnt - 1 Downto 1 Do Begin
    s := getvalue('SearchRemember', 'Last' + inttostr(i - 1), '');
    setvalue('SearchRemember', 'Last' + inttostr(i), s);
  End;
  // Und fügen das neueste oben ein
  setvalue('SearchRemember', 'Last0', NewSearch);
End;

Procedure TForm1.RefreshSearchRemember;
Var
  cnt, i: integer;
  s: String;
Begin
  ComboBox2.Items.Clear;
  cnt := strtointdef(getvalue('General', 'SearchRemember', '5'), 5);
  For i := 0 To cnt - 1 Do Begin
    s := getvalue('SearchRemember', 'Last' + inttostr(i), '');
    If s <> '' Then Begin
      ComboBox2.Items.Add(s);
    End;
  End;
End;

Procedure TForm1.CloseDataBase;
Begin
  SQLite3Connection1.Connected := false;
  StringGrid1.Columns[MainColType].Title.caption := R_Type;
  StringGrid1.Columns[MainColFav].Title.caption := R_Fav;
  StringGrid1.Columns[MainColGCCode].Title.caption := R_Code;
  StringGrid1.Columns[MainColDist].Title.caption := 'km';
  StringGrid1.Columns[MainColTitle].Title.caption := R_Title;
  // Das hier ist doppelt (auch in TForm1.create)
  StringGrid1.ColWidths[MainColType] := 60;
  StringGrid1.ColWidths[MainColGCCode] := 75;
  StringGrid1.ColWidths[MainColDist] := 50;
  StringGrid1.ColWidths[MainColFav] := 40;
  StringGrid1.RowCount := 1;
  ComboBox2.text := '';
  Edit2.text := '';
  ComboBox1.text := '-';
  caption := R_Not_Connected;
  StatusBar1.Panels[MainSBarCQCount].Text := '';
  StatusBar1.Panels[MainSBarCCount].Text := '';
  StatusBar1.Panels[MainSBarInfo].Text := '';
End;

Function TForm1.OnCompareUserNote_Locale_to_Online(GC_Code, OnlineNote: String;
  Var LocalNote: String): TUserNoteResult;
Begin
  result := Form43.ShowDialog(self,
    format(RF_Edit_Usernote_for, [GC_Code]),
    R_Online_Usernote, OnlineNote,
    R_Usernote_from_database, LocalNote,
    R_Append_db_note_to_online,
    R_Replace_with_db_version
    );
  If result In [unrOK, unrOKAll, unrOKAppendAll] Then Begin
    LocalNote := form43.ResultNote;
  End;
End;

Function TForm1.OnCompareUserNote_Online_to_Locale(GC_Code, LocalNote: String;
  Var OnlineNote: String): TUserNoteResult;
Begin
  result := Form43.ShowDialog(self,
    format(RF_Edit_Usernote_for, [GC_Code]),
    R_Usernote_from_database, LocalNote,
    R_Online_Usernote, OnlineNote,
    R_Append_online_note_to_db,
    R_Replace_db_note_by_online);
  If result In [unrOK, unrOKAll, unrOKAppendAll] Then Begin
    OnlineNote := form43.ResultNote;
  End;
End;

Function TForm1.OnCompereCorrectedCoords_Locale_to_Online(GC_Code: String;
  onlineLat, onlineLon: Double; Var localeLat: Double; Var localeLon: Double
  ): TUserCoordResult;
Begin
  result := Form44.ShowDialog(self,
    format(RF_Edit_modified_Coords_for, [GC_Code]),
    R_Modified_coordinate_from_database, localeLat, localeLon,
    R_Modified_coordinate_from_website, onlineLat, onlineLon,
    R_Replace_with_db_version,
    R_No_Change
    );
  If result In [ucrOK, ucrOKAll, ucrOKAllOther] Then Begin
    localeLat := form44.ResultLat;
    localeLon := form44.ResultLon;
  End;
End;

Function TForm1.OnCompereCorrectedCoords_Online_to_Locale(GC_Code: String;
  localeLat, localeLon: Double; Var onlineLat: Double; Var onlineLon: Double
  ): TUserCoordResult;
Begin
  result := Form44.ShowDialog(self,
    format(RF_Edit_modified_Coords_for, [GC_Code]),
    R_Modified_coordinate_from_database, localeLat, localeLon,
    R_Modified_coordinate_from_website, onlineLat, onlineLon,
    R_No_Change,
    R_Replace_with_online_version);
  If result In [ucrOK, ucrOKAll, ucrOKAllOther] Then Begin
    onlineLat := form44.ResultLat;
    onlineLon := form44.ResultLon;
  End;
End;

Function TForm1.OnNoteEdit(GC_Code: String; Var Note: String): Boolean;
Begin
  result := false;
  form7.Memo1.Text := Note;
  form7.SetCaption(format(RF_Edit_Note, [GC_Code + ': ' + R_Note_To_long]));
  form4.Hide;
  FormShowModal(form7, self);
  If Form7.ModalResult = mrOK Then Begin
    note := form7.Memo1.Text;
    result := true;
  End;
End;

Procedure TForm1.CheckIniFileVersion;
Var
  iniVersion, df, inif: String;
  iv, v, i: Integer;
Begin
  iniversion := GetValue('General', 'Version', '0.0');
  // Versionen sind immer mit 2 nachkommastellen, der Integer Vergleich ist soo viel besser !
  iv := round(StrToFloatDef(iniVersion, 0, DefFormat) * 100);
  v := round(StrToFloatDef(Version, 0, DefFormat) * 100);
  If v <= iv Then exit; // Alles Super die Versionen passen oder wir laden eine "Neuere" Version, dann machen wir mal lieber nichts..
  (*
   * Die Appversion ist neuer als die der .ini Datei, Prüfen ob diverse Einstellungen Angepasst werden müssen
   *)
  // Alle Default Filter Checken
  For i := 0 To strtointdef(GetValue('Queries', 'Count', '0'), 0) - 1 Do Begin
    df := GetDefaultFilterFor(GetValue('Queries', 'Name' + inttostr(i), ''));
    If df <> '' Then Begin // Wir haben eine Querry gefunden die einen Default wert definiert hat.
      inif := trim(FromSQLString(GetValue('Queries', 'Query' + inttostr(i), '')));
      If df <> inif Then Begin
        If ID_YES = Application.MessageBox(pchar(format(RF_Default_value_for_filter_changed_do_you_want_to_apply_the_new_default_value, [GetValue('Queries', 'Name' + inttostr(i), '')])), pchar(R_Question), MB_YESNO Or MB_ICONQUESTION) Then Begin
          SetValue('Queries', 'Query' + inttostr(i), ToSQLString(df));
        End;
      End;
    End;
  End;

  // Alle Checks sind erledigt -> Hoch ziehen der Ini Version
  SetValue('General', 'Version', Version);
End;

Function TForm1.OpenDataBase(FileName: String; ResetGui: Boolean): Boolean;
Var
  cl: TStringList;
Begin
  result := false;
  caption := R_Not_Connected;
  If SQLite3Connection1.Connected Then
    SQLite3Connection1.Connected := false;
  If Not FileExistsUTF8(Filename) Then Begin
    showmessage(format(RF_Could_Not_Load, [FileName]));
    exit;
  End;
  SQLite3Connection1.DatabaseName := Filename;
  Try
    SQLite3Connection1.Connected := true;
  Except
    On e: Exception Do Begin
      ShowMessage(format(RF_Error_Could_not_Connect, [e.Message]));
      exit;
    End;
  End;
  // Ab Version 0.73 des ccm unterstützt dieser ein "Customer Flag" für jeden Cache dieses wird bei älteren Datenbanken automatisch angefügt.
  If Not ColumnExistsInTable('Customer_Flag', 'caches') Then Begin
    CommitSQLTransactionQuery('Alter Table caches add column Customer_Flag');
    SQLTransaction1.Commit;
    MenuItem65Click(Nil); // Clear All Customer Flags
  End;
  // Ab Version 1.67 des ccm unterstützt dieser die "Lite" geocaches diese sind nicht vollständig definiert
  If Not ColumnExistsInTable('Lite', 'caches') Then Begin
    CommitSQLTransactionQuery('Alter Table caches add column Lite');
    CommitSQLTransactionQuery('Update caches set Lite = 0'); // Alle Caches die schon da waren sind keine Lite Caches
    SQLTransaction1.Commit;
  End;
  // Ab Version 1.68 des ccm unterstützt dieser die "Fav" in einem Cacht
  If Not ColumnExistsInTable('Fav', 'caches') Then Begin
    CommitSQLTransactionQuery('Alter Table caches add column Fav');
    CommitSQLTransactionQuery('Update caches set Fav = 0'); // Alle Caches die schon da waren sind keine Lite Caches
    SQLTransaction1.Commit;
  End;
  (*
   * !! Achtung !!
   * Das umbenennen einer Spalte in eine andere zerstört die Datenbank und erstellt sie neu
   * Dabei ist es wichtig, dass das Aktuellste DB-Model genutzt wird
   * => Alle Änderungen, die Also Spalten in eine Datenbank anfügen müssen folglich oberhalb dieses
   *    Kommentars stehen, sonst knallt es.
   *)
  // Von Version 1.63 bis 1.67 wurde die Spalte lite fälschlicherweise light genannt.
  If ColumnExistsInTable('Light', 'caches') Then Begin
    // 1. Alle Werte der Spalte Light in die Spalte Lite übernehmen
    CommitSQLTransactionQuery('Update caches set Lite = Light'); // Alle Caches die schon da waren sind keine Light Caches
    SQLTransaction1.Commit; // -- Es bleibt zu Prüfen ob man sich das sparen kann, dann ginge es schneller ...
    // 2. Die Spalte Light Löschen gemäß https://www.sqlite.org/lang_altertable.html
    // Neue korreckte Tabelle erstellen
    CommitSQLTransactionQuery(format(CreateTableCachesCMD, ['caches_new']));
    cl := GetAllColumsFromTable('caches_new');
    cl.Delimiter := ',';
    // Copy data
    CommitSQLTransactionQuery('Insert into caches_new (' + cl.DelimitedText + ') select ' + cl.DelimitedText + ' from caches');
    // Drop old table
    CommitSQLTransactionQuery('Drop table caches');
    // Rename new into old
    CommitSQLTransactionQuery('Alter Table caches_new rename to caches');
    SQLTransaction1.Commit;
    cl.free;
  End;
  caption := format(RF_Connected_To, [ExtractFileNameOnly(FileName)]);
  Setvalue('General', 'LastDB', FileName);
  If ResetGui Then Begin
    StringGrid1.RowCount := 1;
    StatusBar1.Panels[MainSBarCQCount].Text := '';
    StatusBar1.Panels[MainSBarInfo].Text := '';
  End;
  RefreshDataBaseCacheCountinfo(); // Das muss immer gemacht werden, damit die Statistiken auch immer stimmen
  result := OpenTBDatabase;
End;

(*
 * -1 im Fehlerfall, sonst Index des Cachetyps oder des POI Symbols
 *)

Function TForm1.CacheTypeToIconIndex(CacheType: String): integer;
Var
  CT, TI, DT: String;
  i: Integer;
Begin
  SplitCacheType(CacheType, ct, ti, dt);
  result := MainIndexUnknownImage;
  ct := lowercase(ct);
  If lowercase(Traditional_Cache) = ct Then result := MainImageIndexTraditionalCache;
  If lowercase(Unknown_Cache) = ct Then result := MainImageIndexMysterieCache;
  If lowercase(Multi_cache) = ct Then result := MainImageIndexMultiCache;
  If lowercase(Letterbox_Hybrid) = ct Then result := MainImageIndexLetterbox;
  If lowercase(Mega_Event_Cache) = ct Then result := MainImageIndexEventCache;
  If lowercase(Giga_Event_Cache) = ct Then result := MainImageIndexEventCache;
  If lowercase(Community_Celebration_Event) = ct Then result := MainImageIndexEventCache;
  If lowercase(Event_Cache) = ct Then result := MainImageIndexEventCache;
  If lowercase(Cache_In_Trash_Out_Event) = ct Then result := MainImageIndexCITO;
  If lowercase(Earthcache) = ct Then result := MainImageIndexEarthCache;
  If lowercase(Wherigo_Cache) = ct Then result := MainImageIndexWhereIGo;
  If lowercase(Virtual_Cache) = ct Then result := MainImageIndexVirtualCache;
  If lowercase(Webcam_Cache) = ct Then result := MainImageIndexWebcamCache;
  If lowercase(Geocache_Lab_Cache) = ct Then result := MainImageIndexLabCache;
  If lowercase(Project_APE_Cache) = ct Then result := MainImageIndexProjectAPE;
  If lowercase(LocationLess_Cache) = ct Then result := MainImageIndexLocationLess;
  (*
   * Hat der User das Customer Flag Gesetzt kommt das "U"
   * Wurde ein Cache gefunden kommt der Smily
   * Wurden die Koords Modifiziert dann das Puzzleteil mit Grünem hacken
   * Ist er Archiviert, dann sind die Koords Egal also das Blatt mit Rotem X
   * => Festlegung frei Schnauze ;)
   *)
  If Pos('U', ti) <> 0 Then Begin
    Result := MainImageIndexCustomerFlag;
  End
  Else Begin
    If Pos('F', ti) <> 0 Then Begin
      Result := MainImageIndexFoundCache;
    End
    Else Begin
      If Pos('A', ti) <> 0 Then Begin
        Result := MainImageIndexCacheArchived;
      End
      Else Begin
        If Pos('C', ti) <> 0 Then Begin
          Result := MainImageIndexKoordsModified;
        End;
      End;
    End;
  End;
  // Die POI- Graphiken laufen komplett unabhängig
  For i := 0 To high(POI_Types) Do Begin
    If ct = lowercase(POI_Types[i].Sym) Then Begin
      result := ImageList1.Count - length(POI_Types) + i;
      break;
    End;
  End;
End;

Function TForm1.CacheTypeToDTIcon(CacheType: String): integer;
Var
  CT, TI, DT: String;
  d, t: integer;
Begin
  SplitCacheType(CacheType, ct, ti, dt);
  result := -1;
  If dt <> '' Then Begin // Labcaches haben kein DT
    d := round(strtofloat(copy(dt, 1, pos('x', dt) - 1), DefFormat) * 2) - 2;
    t := round(strtofloat(copy(dt, pos('x', dt) + 1, length(dt)), DefFormat) * 2) - 2;
    result := d + 10 * t;
  End;
End;

Function TForm1.NewDatabase(DataBaseName: String): Boolean;
Var
  fn: String;
Begin
  result := false;
  fn := GetDataBaseDir() + DataBaseName + '.db';
  If FileExistsUTF8(fn) Then Begin
    If Application.MessageBox(pchar(format(RF_Database_exists_replace, [DataBaseName])), pchar(R_Question), MB_ICONQUESTION Or MB_YESNO) = ID_no Then exit;
  End;
  If Not CreateNewDatabase(DataBaseName) Then Begin
    Showmessage(format(RF_Error_could_not_create, [DataBaseName]));
    caption := R_Not_Connected;
    exit;
  End;
  caption := format(RF_Connected_To, [DataBaseName]);
  Setvalue('General', 'LastDB', SQLite3Connection1.DatabaseName);
  StringGrid1.RowCount := 1;
  StatusBar1.Panels[MainSBarCQCount].Text := '';
  StatusBar1.Panels[MainSBarInfo].Text := '';
  RefreshDataBaseCacheCountinfo();
  result := OpenTBDatabase;
End;

Procedure TForm1.AddSpoilerImageToCache(CacheName: String);
Var
  p: String;
Begin
  If OpenPictureDialog1.Execute Then Begin
    p := GetSpoilersDir() + CacheName + PathDelim;
    If Not ForceDirectoriesUTF8(p) Then Begin
      showmessage(format(RF_Error_could_not_create, [p]));
      exit;
    End;
    If Not CopyFile(OpenPictureDialog1.FileName, p + ExtractFileName(
      OpenPictureDialog1.FileName)) Then Begin
      showmessage(R_Error_unable_to_copy_file);
    End;
  End;
End;

Function TForm1.CacheNameToCacheType(CacheName: String): String;
Var
  username: String;
Begin
  StartSQLQuery('Select G_Type, cor_lat, cor_lon, g_Found, G_ARCHIVED, Customer_Flag from caches where name = "' + CacheName + '"');
  result := FromSQLString(SQLQuery1.Fields[0].AsString);
  If (SQLQuery1.Fields[1].AsFloat <> -1) And (SQLQuery1.Fields[2].AsFloat <> -1) Then Begin
    result := AddCacheTypeSpezifier(result, 'C');
  End;
  username := GetValue('General', 'Username', '');
  If username <> '' Then Begin
    // Haben wir diese Dose schon geloggt ?
    If (SQLQuery1.Fields[3].AsInteger = 1) Then Begin
      result := AddCacheTypeSpezifier(result, 'F');
    End
  End;
  // Ist die Dose Archiviert ?
  If (SQLQuery1.Fields[4].AsInteger = 1) Then Begin
    result := AddCacheTypeSpezifier(result, 'A');
  End;
  // Ist das user Flag gesetzt
  If (SQLQuery1.Fields[5].AsString = '1') Then Begin
    result := AddCacheTypeSpezifier(result, 'U');
  End;
End;

Procedure TForm1.ResetMainGridCaptions;
Begin
  If MenuItem50.Checked Then Begin
    StringGrid1.Columns[MainColType].Title.caption := R_Type_DT;
  End
  Else Begin
    StringGrid1.Columns[MainColType].Title.caption := R_Type;
  End;
  StringGrid1.Columns[MainColFav].Title.caption := R_Fav;
  StringGrid1.Columns[MainColGCCode].Title.caption := R_Code;
  StringGrid1.Columns[MainColDist].Title.caption := 'km';
  StringGrid1.Columns[MainColTitle].Title.caption := R_Title;
End;

Function TForm1.ImportDirectory(Dirname: String): integer;

Type
  TFiletype = (ftZip, ftGPX, ftUnknown);

  Function GuessFileType(Const Filename: String): TFileType;
    // Quelle : https://www.garykessler.net/library/file_sigs.html
  Var
    f: TFileStream;
    b: Array[0..4] Of byte;
    i: integer;
  Begin
    result := ftUnknown;
    f := TFileStream.Create(Filename, fmOpenRead);
    i := 0;
    For i := 0 To 4 Do Begin
      b[i] := 0;
      f.Read(b[i], 1);
    End;
    f.Free;
    // Kennung von .zip Dateien = "PK.."
    If (b[0] = $50) And
      (b[1] = $4B) And
      (b[2] = $03) And
      (b[3] = $04) Then Begin
      result := ftZip;
    End;
    // Kennung von .xml Dateien "<?xml"
    If (b[0] = $3C) And
      (b[1] = $3F) And
      (b[2] = $78) And
      (b[3] = $6D) And
      (b[4] = $6C) Then Begin
      result := ftGPX;
    End;
  End;

Var
  sl: TStringlist;
  j, i: integer;
  t: Int64;
Begin
  sl := FindAllFiles(Dirname, '', false);
  // Alle Caches Markieren als nicht gefunden
  CommitSQLTransactionQuery('Update caches set G_NEED_ARCHIVED = 1');
  SQLTransaction1.Commit;
  result := 0;
  self.Enabled := false;
  For i := 0 To sl.count - 1 Do Begin
    j := 0;
    Case GuessFileType(sl[i]) Of
      ftZip: Begin
          j := ImportZipFile(sl[i]);
          result := result + j;
        End;
      ftGPX: Begin
          j := ImportGPXFile(sl[i]);
          result := result + j;
        End;
    End;
    If Form4.Abbrechen Then Begin
      break;
    End;
    If GetValue('General', 'DeleteImportedFiles', '0') = '1' Then Begin
      If j <> 0 Then Begin // Es wird nur gelöscht, wenn oben auch etwas importiert wurde
        DeleteFileUTF8(sl[i]);
      End;
    End;
  End;
  sl.free;
  If form4.visible Then form4.close;
  RefreshDataBaseCacheCountinfo();
  self.Enabled := true;
  // Nun da alles Importiert ist, werden alle Datensätze angewählt, die Nicht importiert wurden, und noch nicht archiviert sind.
  ComboBox2.text := '';
  Edit2.text := '';
  ComboBox1.ItemIndex := 0;
  t := GetTickCount64;
  StartSQLQuery(QueryToMainGridSelector + 'from caches c Where (c.G_NEED_ARCHIVED=1) and (c.G_ARCHIVED=0)');
  QueryToMainGrid(t);
End;

Procedure TForm1.CreateExportMenu;
Var
  j, i: integer;
  t: TMenuItem;
Begin
  // Alte Löschen
  For i := MenuItem12.ComponentCount - 1 Downto 0 Do Begin
    MenuItem12.Components[i].free;
  End;
  j := strtoint(GetValue('GPSExport', 'Count', '0'));
  For i := 0 To j - 1 Do Begin
    t := TMenuItem.Create(MenuItem12);
    t.Caption := GetValue('GPSExport', 'Name' + inttostr(i), '- - -');
    t.Tag := i;
    t.OnClick := @OnGPSExportClick;
    MenuItem12.Add(t);
  End;
End;

Procedure TForm1.CreateScriptMenu;
Var
  j, i: integer;
  t: TMenuItem;
Begin
  // Alte Löschen
  For i := MenuItem57.ComponentCount - 1 Downto 0 Do Begin
    MenuItem57.Components[i].free;
  End;
  j := strtoint(GetValue('Scripts', 'Count', '0'));
  MenuItem57.Visible := j <> 0;
  For i := 0 To j - 1 Do Begin
    t := TMenuItem.Create(MenuItem57);
    t.Caption := FromSQLString(GetValue('Scripts', 'Name' + inttostr(i), '- - -'));
    t.Tag := i;
    t.OnClick := @OnScriptClick;
    MenuItem57.Add(t);
  End;
End;

Procedure TForm1.CreateSpoilerMenu;
Var
  j, i: integer;
  t: TMenuItem;
  s: String;
Begin
  // Alte Löschen
  For i := MenuItem40.ComponentCount - 1 Downto 0 Do Begin
    MenuItem40.Components[i].free;
  End;
  j := strtoint(GetValue('GPSSpoilerExport', 'Count', '0'));
  For i := 0 To j - 1 Do Begin
    s := GetValue('GPSSpoilerExport', 'Folder' + inttostr(i), '');
    If (s <> '') And (DirectoryExistsUTF8(s)) Then Begin
      t := TMenuItem.Create(MenuItem40);
      t.Caption := GetValue('GPSSpoilerExport', 'Name' + inttostr(i), '- - -');
      t.Tag := i;
      t.OnClick := @OnGPSSpoilerClick;
      MenuItem40.Add(t);
    End;
  End;
End;

Procedure TForm1.CreateToolsMenu;
Var
  k, j, i: integer;
  t2, t: TMenuItem;
  s: String;
Begin
  j := strtoint(GetValue('Tools', 'Count', '0'));
  MenuItem45.Visible := j <> 0;
  // Bisherige Löschen
  For i := MenuItem45.Count - 1 Downto 0 Do Begin
    MenuItem45.Items[i].Free;
  End;
  // Neu erzeugen
  // Wir erstellen das Menü im 2-pass Verfahren
  // 1. Alle Root Nodes
  For i := 0 To j - 1 Do Begin
    s := lowercase(GetValue('Tools', 'Type' + inttostr(i), ''));
    If s = 'root' Then Begin
      // Ein Wurzelknoten
      t := TMenuItem.Create(MenuItem45);
      t.Caption := GetValue('Tools', 'Name' + inttostr(i), '- - -');
      MenuItem45.Add(t);
    End;
  End;
  // 2. Alle Anderen Nodes
  For i := 0 To j - 1 Do Begin
    s := lowercase(GetValue('Tools', 'Type' + inttostr(i), ''));
    If s <> 'root' Then Begin
      // Ein Normaler Knoten, dieser wird entweder in eine Root eingehängt oder
      // ist in der Wurzel
      s := getvalue('Tools', 'Parent' + inttostr(i), '');
      If s = '' Then Begin // Der Knoten ist ganz normal in der Root
        t := TMenuItem.Create(MenuItem45);
        t.Caption := GetValue('Tools', 'Name' + inttostr(i), '- - -');
        t.Tag := i;
        t.OnClick := @OnToolsClick;
        MenuItem45.Add(t);
      End
      Else Begin // Der Knoten ist ein Unterknoten einer Wurzel
        // Suchen der Wurzel
        t2 := Nil;
        For k := 0 To MenuItem45.Count - 1 Do Begin
          If MenuItem45.Items[k].Caption = s Then Begin
            t2 := MenuItem45.Items[k];
            break;
          End;
        End;
        If assigned(t2) Then Begin
          // Wurzel gefunden Einhängen
          t := TMenuItem.Create(t2);
          t.Caption := GetValue('Tools', 'Name' + inttostr(i), '- - -');
          t.Tag := i;
          t.OnClick := @OnToolsClick;
          t2.Add(t);
        End
        Else Begin
          // Wir haben die Wurzel nicht gefunden, also Hängen wir das Element einfach in die Root => Spart Fehlermeldungen
          t := TMenuItem.Create(MenuItem45);
          t.Caption := GetValue('Tools', 'Name' + inttostr(i), '- - -');
          t.Tag := i;
          t.OnClick := @OnToolsClick;
          MenuItem45.Add(t);
        End;
      End;
    End;
  End;
End;

Procedure TForm1.CreateWaypointImages;
Var
  Imagespath: String;
  i: Integer;
  bm: TBitmap;
Begin
  Imagespath := GetImagesDir();
  For i := 0 To high(POI_Types) Do Begin
    If Not FileExistsUTF8(Imagespath + POI_Types[i].Bitmap) Then Begin
      showmessage('Error could not open : ' + Imagespath + POI_Types[i].Bitmap);
      Continue;
    End;
    bm := TBitmap.Create;
    bm.LoadFromFile(Imagespath + POI_Types[i].Bitmap);
    bm.TransparentColor := clFuchsia;
    bm.Transparent := true;
    ImageList1.Add(bm, Nil);
    bm.free;
  End;
End;

Procedure TForm1.CreateFieldImportMenu;
Var
  j, i: integer;
  t: TMenuItem;
Begin
  // Alte Löschen
  For i := MenuItem20.ComponentCount - 1 Downto 0 Do Begin
    MenuItem20.Components[i].free;
  End;
  j := strtoint(GetValue('GPSImport', 'Count', '0'));
  For i := 0 To j - 1 Do Begin
    t := TMenuItem.Create(MenuItem20);
    t.Caption := GetValue('GPSImport', 'Name' + inttostr(i), '- - -');
    t.Tag := i;
    t.OnClick := @OnGPSImportClick;
    MenuItem20.Add(t);
  End;
End;

Function TForm1.DoGPSExport(Const ggzFilename: String): Boolean;
Var
  i: integer;
  sl: TStringList;
  Workdir, s: String;
  CachesPerGPXContainer: integer;
Begin
  result := false;
  If ggzFilename = '' Then Begin
    showmessage(R_Error_invalid_ggz_filename);
    exit;
  End;
  // Gibt es überhaupt Caches zu Exportieren
  i := StringGrid1.RowCount - 1;
  If i = 0 Then Begin
    showmessage(R_Error_no_caches_for_export_selected);
    exit;
  End;

  CachesPerGPXContainer := strtoint(GetValue('General', 'CachesPerGPXContainer', '900'));
  If CachesPerGPXContainer <= 1 Then Begin
    showmessage(format(RF_Error_invalid_value_for_CachesPerGPXContainer, [inttostr(CachesPerGPXContainer)]));
    exit;
  End;
  // Die Ausgabe Datei / Verzeichnis laden / Prüfen / Löschen
  s := ExtractFilePath(ggzFilename);
  If Not DirectoryExistsUTF8(s) Then Begin
    If Not ForceDirectoriesUTF8(s) Then Begin
      showmessage(format(RF_Error_could_not_create, [s]));
      exit;
    End;
  End;
  // Löschen des Alten ggz-Files
  If FileExistsUTF8(ggzFilename) Then Begin
    If Not DeleteFileUTF8(ggzFilename) Then Begin
      showmessage(format(RF_Error_could_not_delete, [ggzFilename]));
      exit;
    End;
  End;
  // Erzeugen der gpx Dateien
  sl := CreateGPXFiles(CachesPerGPXContainer);
  // Die GGZ Datei erzeugen
  self.Enabled := false;
  form4.RefresStatsMethod(format(RF_Create, [ExtractFileName(ggzFilename)]), StringGrid1.RowCount - 1, 0, True);
  If Not (GetWorkDir(Workdir)) Then Begin
    showmessage(R_Unable_to_create_workdir);
    self.Enabled := true;
    exit;
  End;
  If gpx2ggz(sl, ggzFilename, Workdir) Then Begin
    // Löschen der Temporären gpx Dateien
    For i := 0 To sl.Count - 1 Do Begin
      DeleteFileUTF8(sl[i]);
    End;
    sl.free;
  End
  Else Begin
    sl.free;
    showmessage(format(RF_Error_could_not_create, [ggzFilename]));
  End;
  self.Enabled := true;
  form4.Close;
  result := true;
End;

Var
  LabCacheCounter: integer = 10000; // Das wird hoffentlich nicht benötigt, weil beim Import eines Lab-Caches bereits alles korrigiert wurde.

Function BooleanToString(Value: Boolean): String;
Begin
  // Wird in XML-Daten verwendet nicht Sprachabhängig!
  If value Then Begin
    result := 'True';
  End
  Else Begin
    result := 'False';
  End;
End;

Function CachetToWPT(Const Doc: TXMLDocument; CacheName: String; Skip_Attributes: Boolean; ExportForGSAK, ExportForCGEO: Boolean): TDOMNode;
Var
  Cache: Tcache;
  glog, glogs, ga, gs, tmp: TDOMNode;
  i: Integer;
  s: String;
Begin
  cache := CacheFromDB(CacheName, Skip_Attributes);
  (*
   * Einen Lab Cache in einen "Mysterie" Umwandeln
   *)
  If Cache.G_Type = Geocache_Lab_Cache Then Begin
    Cache.Time := GetTime(now);
    (*
     * Das Problem ist, das das Oregon650 nur die ersten 9 Zeichen des Namens
     * auswertet, und diese müssen in der Gesamten Datenbank Eindeutig sein.
     * Da die Labcaches aber in der Regel keine GC-Codes haben knallts hier
     * => das Oregon zeigt die Labcaches einfach nicht an.
     *
     * Einzig bekannter Workaround ist das wir die Caches mit eigenen
     * GC-Codes versorgen -> Online Logbar sind sie eh nicht, wir verlieren
     *                       dann aber den Bezug zu unserer Datenbank.
     *
     * Im Idealfall hat der CCM beim Import den cache.GC_Code aber bereits gefixt.
     *)
    If length(Cache.GC_Code) > 9 Then Begin
      Cache.GC_Code := 'LAB_' + inttostr(LabCacheCounter);
      LabCacheCounter := LabCacheCounter + 1;
    End;
    Cache.Sym := 'Geocache';
    Cache.Type_ := 'Geocache|Unknown Cache';
    cache.G_Owner_ID := 12345;
    cache.G_Owner := 'GC-Headquater';
    Cache.G_Type := Unknown_Cache;
    Cache.G_Container := 'other';
    // Irgend ein Attribut sollte die Dose schon haben..
    If length(Cache.G_Attributes) = 0 Then Begin
      setlength(Cache.G_Attributes, 1);
      cache.G_Attributes[0].Attribute_Text := 'Short hike (less than 1km)';
      cache.G_Attributes[0].id := 55;
      cache.G_Attributes[0].inc := 1;
    End;
    Cache.G_Difficulty := 1;
    Cache.G_Terrain := 1;
    Cache.G_Country := 'Germany';
    Cache.G_State := 'Berlin';
    CacheName := cache.GC_Code; // Sonst steigt der unten aus ..
  End;
  If cache.GC_Code <> CacheName Then Begin // Fehler konnte Cache nicht laden
    result := Nil;
    exit;
  End;
  result := Doc.CreateElement('wpt');
  If (cache.Cor_Lat = -1) Or (cache.Cor_Lon = -1) Then Begin
    TDOMElement(result).SetAttribute('lat', floattostr(cache.Lat, DefFormat));
    TDOMElement(result).SetAttribute('lon', floattostr(cache.Lon, DefFormat));
  End
  Else Begin
    TDOMElement(result).SetAttribute('lat', floattostr(cache.Cor_Lat, DefFormat));
    TDOMElement(result).SetAttribute('lon', floattostr(cache.Cor_Lon, DefFormat));
  End;
  AddTag(doc, result, 'time', cache.Time);
  AddTag(doc, result, 'name', cache.GC_Code);
  AddTag(doc, result, 'desc', cache.Desc);
  AddTag(doc, result, 'cmt', cache.Desc); // Why ever das doppelt ist ?
  AddTag(doc, result, 'url', cache.URL);
  AddTag(doc, result, 'urlname', cache.URL_Name);
  AddTag(doc, result, 'sym', cache.Sym);
  AddTag(doc, result, 'type', cache.Type_);
  If ExportForGSAK And (((cache.Cor_Lat <> -1) Or (cache.Cor_Lon <> -1)) Or (Cache.Note <> '')) Then Begin
    gs := Doc.CreateElement('gsak:wptExtension');
    TDOMElement(gs).SetAttribute('xmlns:gsak', 'http://www.gsak.net/xmlv1/6');
    If ((cache.Cor_Lat <> -1) Or (cache.Cor_Lon <> -1)) Then Begin
      Addtag(doc, gs, 'gsak:LatBeforeCorrect', floattostr(cache.Lat, DefFormat));
      Addtag(doc, gs, 'gsak:LonBeforeCorrect', floattostr(cache.Lon, DefFormat));
    End;
    If ExportForCGEO And (Cache.Note <> '') Then Begin
      Addtag(doc, gs, 'gsak:GcNote', cache.Note);
    End;
    result.AppendChild(gs);
  End;
  gs := Doc.CreateElement('groundspeak:cache');
  TDOMElement(gs).SetAttribute('id', inttostr(cache.G_ID));
  TDOMElement(gs).SetAttribute('available', BooleanToString(cache.G_Available));
  TDOMElement(gs).SetAttribute('archived', BooleanToString(cache.G_Archived));
  If trim(Cache.G_XMLNs) = '' Then Begin
    // Wenn der Tag Leer ist, dann kann C:Geo das File nicht importieren..
    TDOMElement(gs).SetAttribute('xmlns:groundspeak', 'http://www.groundspeak.com/cache/1/0/1');
  End
  Else Begin
    TDOMElement(gs).SetAttribute('xmlns:groundspeak', cache.G_XMLNs);
  End;
  Addtag(doc, gs, 'groundspeak:name', cache.G_Name);
  Addtag(doc, gs, 'groundspeak:placed_by', cache.G_Placed_By);
  tmp := Addtag(doc, gs, 'groundspeak:owner', cache.G_Owner);
  TDOMElement(tmp).SetAttribute('id', inttostr(cache.G_Owner_ID));
  Addtag(doc, gs, 'groundspeak:type', cache.G_Type);
  Addtag(doc, gs, 'groundspeak:container', cache.G_Container);
  If Not Skip_Attributes Then Begin
    ga := Doc.CreateElement('groundspeak:attributes');
    For i := 0 To high(Cache.G_Attributes) Do Begin
      tmp := AddTag(doc, ga, 'groundspeak:attribute', cache.G_Attributes[i].Attribute_Text);
      TDOMElement(tmp).SetAttribute('id', inttostr(cache.G_Attributes[i].id));
      TDOMElement(tmp).SetAttribute('inc', inttostr(cache.G_Attributes[i].inc));
    End;
    gs.AppendChild(ga);
  End;
  Addtag(doc, gs, 'groundspeak:difficulty', Format('%1.1f', [cache.G_Difficulty], DefFormat));
  Addtag(doc, gs, 'groundspeak:terrain', Format('%1.1f', [cache.G_Terrain], DefFormat));
  Addtag(doc, gs, 'groundspeak:country', cache.G_Country);
  Addtag(doc, gs, 'groundspeak:state', cache.G_State);
  tmp := Addtag(doc, gs, 'groundspeak:short_description', cache.G_Short_Description);
  TDOMElement(tmp).SetAttribute('html', BooleanToString(cache.G_Short_Description_HTML));
  s := Cache.G_Long_Description;
  tmp := Addtag(doc, gs, 'groundspeak:long_description', s);
  TDOMElement(tmp).SetAttribute('html', BooleanToString(cache.G_Long_Description_HTML));
  If (Cache.Note <> '') And (Not ExportForGSAK) And (Not ExportForCGEO) Then Begin
    addtag(doc, gs, 'groundspeak:encoded_hints',
      R_CCM_User_Note + LineEnding +
      htmlStringToString(cache.Note) + LineEnding +
      R_CCM_End_User_Note + LineEnding +
      cache.G_Encoded_Hints);
  End
  Else Begin
    addtag(doc, gs, 'groundspeak:encoded_hints', cache.G_Encoded_Hints);
  End;
  glogs := doc.CreateElement('groundspeak:logs');
  // Für GSAK den hint als ersten Log einfügen ;)
  If (Cache.Note <> '') And ExportForGSAK And (Not ExportForCGEO) Then Begin
    glog := doc.CreateElement('groundspeak:log');
    TDOMElement(glog).SetAttribute('id', '-2');
    AddTag(doc, glog, 'groundspeak:date', GetTime(now));
    AddTag(doc, glog, 'groundspeak:type', 'Write note');
    tmp := AddTag(doc, glog, 'groundspeak:finder', 'GSAK');
    TDOMElement(tmp).SetAttribute('id', '0');
    tmp := AddTag(doc, glog, 'groundspeak:text', cache.Note);
    TDOMElement(tmp).SetAttribute('encoded', BooleanToString(false));
    glogs.AppendChild(glog);
  End;
  For i := 0 To high(Cache.Logs) Do Begin
    glog := doc.CreateElement('groundspeak:log');
    TDOMElement(glog).SetAttribute('id', inttostr(cache.logs[i].id));
    AddTag(doc, glog, 'groundspeak:date', cache.logs[i].date);
    AddTag(doc, glog, 'groundspeak:type', cache.logs[i].Type_);
    tmp := AddTag(doc, glog, 'groundspeak:finder', cache.logs[i].Finder);
    TDOMElement(tmp).SetAttribute('id', inttostr(cache.logs[i].Finder_ID));
    tmp := AddTag(doc, glog, 'groundspeak:text', cache.logs[i].Log_Text);
    TDOMElement(tmp).SetAttribute('encoded', BooleanToString(cache.logs[i].Text_Encoded));
    glogs.AppendChild(glog);
  End;
  gs.AppendChild(glogs);
  gs.AppendChild(doc.CreateElement('groundspeak:travelbugs')); // Keine Travelbugs im Cache
  result.AppendChild(gs);
End;

Function TForm1.CreateGPXFiles(FilesPerGPX: integer): TStringlist;
Var
  cnt, cnt2, i: integer;
  s, workdir: String;
  Doc: TXMLDocument;
  gpx, wpt: TDOMNode;
Begin
  // Das Arbeitsverzeichniss Laden / Erstellen
  If Not GetWorkDir(workdir) Then Begin
    showmessage(format(RF_Error_could_not_create, [workdir]));
    exit;
  End;
  self.Enabled := false;
  form4.RefresStatsMethod('', 0, 0, True);
  NewDocGPX(doc, gpx);
  cnt := 0;
  cnt2 := 0;
  result := TStringList.create;
  LabCacheCounter := 10000; // Reset, falls das schon öfters gemacht wurde
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    // 1. Alle Caches im Temp Verzeichniss erzeugen
    wpt := CachetToWPT(doc, StringGrid1.Cells[MainColGCCode, i], false, false, false);
    If Not assigned(wpt) Then Begin
      // Todo : Qualifizierte Fehlermeldung
      Continue;
    End;
    gpx.AppendChild(wpt);
    inc(cnt2);
    // Größenbeschränkung für die gpx Dateien
    If (i Mod FilesPerGPX = 0) Then Begin
      s := workdir + 'CacheList' + inttostr(cnt) + '.gpx';
      doc.AppendChild(gpx);
      writeXMLFile(Doc, s);
      result.Add(s);
      inc(cnt);
      cnt2 := 0;
      doc.free;
      NewDocGPX(doc, gpx);
    End;
    If i Mod 10 = 0 Then Begin
      If form4.RefresStatsMethod('CacheList' + inttostr(cnt) + '.gpx', i, 0, false) Then Begin
        doc.free;
        self.Enabled := true;
        If Form4.Visible Then form4.Hide;
        exit;
      End;
    End;
  End;
  If cnt2 <> 0 Then Begin
    s := workdir + 'CacheList' + inttostr(cnt) + '.gpx';
    doc.AppendChild(gpx);
    writeXMLFile(Doc, s);
    result.Add(s);
  End;
  doc.free;
  self.Enabled := true;
  If Form4.Visible Then form4.Hide;
End;

Procedure TForm1.QueryToMainGrid(StartTime: int64);
Var
  locLat, locLon: Double;
  b: Boolean;
  distd: Double;
  s, dist: String;
  i: Integer;
Begin
  s := GetValue('Locations', 'Place' + getvalue('General', 'AktualLocation', ''), '');
  If s <> '' Then Begin
    loclat := strtofloat(copy(s, 1, pos('x', s) - 1), DefFormat);
    loclon := strtofloat(copy(s, pos('x', s) + 1, length(s)), DefFormat);
  End
  Else Begin
    locLat := -1;
    locLon := -1;
  End;
  StringGrid1.RowCount := 1;
  StringGrid1.BeginUpdate;
  // Die SQLTransaktion dazu bringen RecordCount richtig zu bestimmen
  SQLQuery1.Last;
  StringGrid1.RowCount := SQLQuery1.RecordCount + 1; // Dem Stringgrid schon mal sagen wieviele Datensätze erzeugt werden Spart Rechenzeit ohne Ende ;)
  SQLQuery1.First; // Reset des Record Zeigers zum Iterativen Auslesen
  i := 1;
  While Not SQLQuery1.EOF Do Begin
    b := true;
    // Prüfen ob Distanzkriterium Anschlägt.
    If locLat = -1 Then Begin
      dist := ''; // Keine Location definiert, also auch keine Distanz berechenbar
      distd := 0;
    End
    Else Begin
      If (SQLQuery1.Fields[5].AsFloat <> -1) And (SQLQuery1.Fields[6].AsFloat <> -1) Then Begin
        // Cache hat Corrigierte Koordinaten
        distd := distance(locLat, locLon, SQLQuery1.Fields[5].AsFloat, SQLQuery1.Fields[6].AsFloat) / 1000;
      End
      Else Begin
        // Ganz normal
        distd := distance(locLat, locLon, SQLQuery1.Fields[3].AsFloat, SQLQuery1.Fields[4].AsFloat) / 1000;
      End;
      dist := format('%1.1fkm', [distd]);
    End;
    // Feine Distanzprüfung
    If (trim(Edit2.Text) <> '') And (distd <> 0) Then Begin
      If (trim(Edit2.text)[1] = '-') Then Begin
        // Der Offset "-0.05" (= 0.1 / 2)  sorgt dafür das alle die als genau auf der Grenze Angezeigt werden auch tatsächlich in beiden Teilmengen enthalten sind, ohne wären sie nur in der Positivmenge
        b := distd >= abs(StrToFloatDef(Edit2.Text, 0)) - 0.05;
      End
      Else Begin
        b := distd <= StrToFloatDef(Edit2.Text, 0);
      End;
    End;
    If b Then Begin
      StringGrid1.cells[MainColType, i] := format('|%fx%f', [SQLQuery1.Fields[7].AsFloat, SQLQuery1.Fields[8].AsFloat], DefFormat);
      StringGrid1.cells[MainColGCCode, i] := FromSQLString(SQLQuery1.Fields[1].AsString);
      StringGrid1.cells[MainColDist, i] := dist;
      StringGrid1.cells[MainColTitle, i] := FromSQLString(SQLQuery1.Fields[2].AsString);
      StringGrid1.cells[MainColFav, i] := SQLQuery1.Fields[9].AsString;
      inc(i);
    End;
    SQLQuery1.Next;
  End;
  StringGrid1.RowCount := i;
  // Da hier neue SQL anfragen gestellt werden, muss das separat gemacht werden
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    StringGrid1.Cells[MainColType, i] := CacheNameToCacheType(StringGrid1.Cells[MainColGCCode, i]) + StringGrid1.cells[MainColType, i];
  End;
  ResetMainGridCaptions();
  StringGrid1HeaderClick(StringGrid1, true, MainColDist); // Sortieren nach KM Absteigend
  StringGrid1.EndUpdate();
  StartTime := GetTickCount64 - StartTime;
  StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [StringGrid1.RowCount - 1]);
  StatusBar1.Panels[MainSBarInfo].Text := format(RF_Time, [PrettyTime(StartTime)]);
End;

Function TForm1.MoveSelectionToOtherDB(NewDBName: String): Boolean;
Var
  p, von, nach: String;
  i, j: Integer;
  c: Array Of TCache;
  w: Array Of TWaypointList;
  RestoreDontImportFoundCaches: Boolean;
Begin
  result := false;
  von := SQLite3Connection1.DatabaseName;
  p := GetDataBaseDir();
  nach := p + NewDBName + '.db';
  If von = nach Then exit;
  If Not FileExistsUTF8(nach) Then exit;
  form1.Enabled := false;
  form4.RefresStatsMethod('', 0, 0, true);
  // Der User hat angewiesen die Dosen zu verschieben, dann ist egal ob er sie in der Zieldatenbank schon gefunden hat oder nicht!
  RestoreDontImportFoundCaches := false;
  If GetValue('General', 'DontImportFoundCaches', '1') = '1' Then Begin
    RestoreDontImportFoundCaches := true;
    SetValue('General', 'DontImportFoundCaches', '0');
  End;
  // 1. Alle Caches Kopieren
  c := Nil;
  w := Nil;
  setlength(c, StringGrid1.RowCount - 1);
  setlength(w, StringGrid1.RowCount - 1);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    form4.RefresStatsMethod(StringGrid1.Cells[MainColTitle, i], i, 0, i = 1);
    // 1. Alles zum Cache laden
    c[i - 1] := CacheFromDB(StringGrid1.Cells[MainColGCCode, i]);
    w[i - 1] := WaypointsFromDB(StringGrid1.Cells[MainColGCCode, i]);
    If form4.abbrechen Then Begin
      Showmessage(R_Process_aborted);
      setlength(c, 0);
      setlength(w, 0);
      form4.Close;
      form1.Enabled := true;
      exit;
    End;
  End;
  // 2. Alle Caches übertragen
  OpenDataBase(Nach, false);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    form4.RefresStatsMethod(StringGrid1.Cells[MainColTitle, i], i, 0, i = 1);
    cachetoDB(c[i - 1], true, false);
    For j := 0 To high(w[i - 1]) Do Begin
      // Bei Labs werden diese in der Neuen DB, meistens "Umbenannt", damit dann
      // die WP's auch stimmen, muss das hier Händisch nachgeführt werden
      If pos('LAB_', c[i - 1].GC_Code) = 1 Then Begin
        w[i - 1][j].GC_Code := c[i - 1].GC_Code;
      End;
      WaypointtoDB(w[i - 1][j], true);
    End;
    If form4.abbrechen Then Begin
      Showmessage(R_Process_aborted);
      setlength(c, 0);
      setlength(w, 0);
      RefreshDataBaseCacheCountinfo(); // Das Sorgt dafür das die Vorschau der nach Datenbank wieder stimmt
      OpenDataBase(von, false);
      form4.Close;
      form1.Enabled := true;
      exit;
    End;
  End;
  SQLTransaction.Commit;
  // 3. Alle Caches Löschen
  setlength(c, 0);
  setlength(w, 0);
  RefreshDataBaseCacheCountinfo(); // Das Sorgt dafür das die Vorschau der nach Datenbank wieder stimmt
  OpenDataBase(von, false);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    form4.RefresStatsMethod(StringGrid1.Cells[MainColTitle, i], i, 0, i = 1);
    DelCache(StringGrid1.Cells[MainColGCCode, i]);
    If form4.abbrechen Then Begin
      Showmessage(R_Process_aborted);
      StringGrid1.BeginUpdate;
      For j := 1 To i Do Begin
        StringGrid1.DeleteRow(1);
      End;
      StringGrid1.EndUpdate();
      StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [StringGrid1.RowCount - 1]);
      StatusBar1.Panels[MainSBarInfo].Text := '';
      RefreshDataBaseCacheCountinfo();
      form4.Close;
      form1.Enabled := true;
      exit;
    End;
  End;
  // haben ja Alle Caches gelöscht, also ist die Stringgrid nun Leer
  StringGrid1.RowCount := 1;
  StatusBar1.Panels[MainSBarCQCount].Text := '';
  StatusBar1.Panels[MainSBarInfo].Text := '';
  RefreshDataBaseCacheCountinfo();
  If RestoreDontImportFoundCaches Then Begin
    SetValue('General', 'DontImportFoundCaches', '1');
  End;
  form4.Close;
  form1.Enabled := true;
  result := true;
End;

Function TForm1.CopySelectionToOtherDB(NewDBName: String): Boolean;
Var
  von, p, nach: String;
  i: Integer;
  c: Array Of TCache;
  w: Array Of TWaypointList;
  j: Integer;
  RestoreDontImportFoundCaches: Boolean;
Begin
  result := false;
  Von := SQLite3Connection1.DatabaseName;
  p := GetDataBaseDir();
  nach := p + NewDBName + '.db';
  form1.Enabled := false;
  form4.RefresStatsMethod('', 0, 0, true);
  If von = nach Then exit;
  If Not FileExistsUTF8(nach) Then exit;
  // Der User hat angewiesen die Dosen zu Kopieren, dann ist egal ob er sie in der Zieldatenbank schon gefunden hat oder nicht!
  RestoreDontImportFoundCaches := false;
  If GetValue('General', 'DontImportFoundCaches', '1') = '1' Then Begin
    RestoreDontImportFoundCaches := true;
    SetValue('General', 'DontImportFoundCaches', '0');
  End;
  // 1. Alle Caches Kopieren
  c := Nil;
  w := Nil;
  setlength(c, StringGrid1.RowCount - 1);
  setlength(w, StringGrid1.RowCount - 1);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    form4.RefresStatsMethod(StringGrid1.Cells[MainColTitle, i], i, 0, i = 1);
    // 1. Alles zum Cache laden
    c[i - 1] := CacheFromDB(StringGrid1.Cells[MainColGCCode, i]);
    w[i - 1] := WaypointsFromDB(StringGrid1.Cells[MainColGCCode, i]);
    If form4.abbrechen Then Begin
      Showmessage(R_Process_aborted);
      setlength(c, 0);
      setlength(w, 0);
      form4.Close;
      form1.Enabled := true;
      exit;
    End;
  End;
  // 2. Alle Caches übertragen
  OpenDataBase(Nach, false);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    form4.RefresStatsMethod(StringGrid1.Cells[MainColTitle, i], i, 0, i = 1);
    cachetoDB(c[i - 1], true, false);
    For j := 0 To high(w[i - 1]) Do Begin
      // Bei Labs werden diese in der Neuen DB, meistens "Umbenannt", damit dann
      // die WP's auch stimmen, muss das hier Händisch nachgeführt werden
      If pos('LAB_', c[i - 1].GC_Code) = 1 Then Begin
        w[i - 1][j].GC_Code := c[i - 1].GC_Code;
      End;
      WaypointtoDB(w[i - 1][j], true);
    End;
    If form4.abbrechen Then Begin
      Showmessage(R_Process_aborted);
      setlength(c, 0);
      setlength(w, 0);
      RefreshDataBaseCacheCountinfo(); // Damit stimmt die Statistik der Nach Datenbank auch wieder
      OpenDataBase(von, false);
      form4.Close;
      form1.Enabled := true;
      exit;
    End;
  End;
  SQLTransaction.Commit;
  // 3. Alte DB wieder Öffnen
  setlength(c, 0);
  setlength(w, 0);
  RefreshDataBaseCacheCountinfo(); // Damit stimmt die Statistik der Nach Datenbank auch wieder
  OpenDataBase(von, false);
  If RestoreDontImportFoundCaches Then Begin
    SetValue('General', 'DontImportFoundCaches', '1');
  End;
  form4.close;
  form1.Enabled := true;
  result := true;
End;

Function TForm1.SelectCutSetToOtherDB(OtherDBName: String): Boolean;
Var
  datasets: Array Of Array Of String;
  Queries: Array Of String;
  gegen, von: String;
  StartTime: int64;
  cnt, i, j, k: integer;
Begin
  result := false;
  StartTime := GetTickCount64;
  Von := SQLite3Connection1.DatabaseName;
  gegen := OtherDBName;
  If Not FileExistsUTF8(gegen) Then exit;
  // Zu vergleichende Datenbank aufmachen
  OpenDataBase(gegen, false);

  // Liste aller GC-Codes hohlen
  (*
   * Die SQL Engine mag es nicht, wenn mehr als 1000 "or" mit einander verknüpft werden
   * Also mus die Logik hier die Anfrage auf mehrere Verteilen, das unschöne daran
   * ist natürlich, dass wir alle Zwischenergebnisse wegspeichern müssen.
   * Da wir aber erwarten, das dies nicht viele sind kann man das so ineffizient machen
   * wie es unten steht ;)
   *)
  StartSQLQuery('Select name from caches');
  Queries := Nil;
  setlength(Queries, 1);
  Queries[0] := '';
  cnt := 0;
  // Aufbauen der einzelnen Queries
  While Not SQLQuery1.EOF Do Begin
    If Queries[high(Queries)] = '' Then Begin
      Queries[high(Queries)] := '(c.name = "' + SQLQuery1.Fields[0].AsString + '")';
      cnt := 1;
    End
    Else Begin
      Queries[high(Queries)] := Queries[high(Queries)] + ' or (c.name = "' + SQLQuery1.Fields[0].AsString + '")';
      inc(cnt);
      If cnt >= 750 Then Begin
        setlength(Queries, high(Queries) + 2);
        Queries[high(Queries)] := '';
      End;
    End;
    SQLQuery1.Next;
  End;
  // Wieder alte DB aufmachen und mittels query die doppelten hohlen
  OpenDataBase(von, false);
  datasets := Nil; // Keine Ergebnisse
  For i := 0 To high(Queries) Do Begin
    If (Queries[i] <> '') Then Begin
      StartSQLQuery(QueryToMainGridSelector + ' from caches c where ' + Queries[i]);
      QueryToMainGrid(StartTime);
      // Zwischenspeichern der Ergebnisse
      For j := 1 To StringGrid1.RowCount - 1 Do Begin
        setlength(datasets, High(datasets) + 2, StringGrid1.ColCount);
        For k := 0 To StringGrid1.ColCount - 1 Do Begin
          datasets[high(datasets), k] := StringGrid1.Cells[k, j];
        End;
      End;
    End;
  End;
  // Nun da alle Datensätze gehohlt wurden -> auch alle Anzeigen
  StringGrid1.RowCount := 1 + length(datasets);
  For i := 0 To high(datasets) Do Begin
    For k := 0 To StringGrid1.ColCount - 1 Do Begin
      StringGrid1.Cells[k, i + 1] := datasets[i, k];
    End;
    setlength(datasets[i], 0);
  End;
  setlength(datasets, 0);
  result := true;
End;

Function TForm1.ExportAsPocketQuery(Filename: String): Boolean;
Var
  workdir: String;
  sl: TStringList;
  z: tzipper;
  i: Integer;
  wpl: TWaypointList;
Begin
  result := false;
  // 1. Alle Caches in eine GPX Datei Exportieren
  sl := CreateGPXFiles(StringGrid1.RowCount + 10); // so ists sicher nur eine Datei
  If Not assigned(sl) Then Begin
    form4.close;
    exit;
  End;
  // 2. Alle Wegpunkte
  If Not GetWorkDir(workdir) Then Begin
    showmessage(R_Unable_to_create_workdir);
    exit;
  End;
  wpl := form9.GetAllWaypoints();
  i := form9.CreateWaypointFile(wpl, workdir + 'CacheList0_wpts.gpx', '', true);
  If i < 0 Then Begin
    showmessage(R_Error_while_creating_Waypointlist);
    setlength(wpl, 0);
    form4.close;
    exit;
  End;
  setlength(wpl, 0);
  If i > 0 Then Begin // Es kann auch sein, dass gar keine Wegpunktliste Erzeugt wurde.
    sl.add(workdir + 'CacheList0_wpts.gpx');
  End;
  // 3. als Zip Packen
  z := TZipper.Create;
  z.FileName := FileName;
  For i := 0 To sl.Count - 1 Do Begin
    z.Entries.AddFileEntry(sl[i], extractfilename(sl[i]));
  End;
  z.ZipAllFiles;
  z.free;
  // 4. Löschen aller Temp Files
  For i := 0 To sl.Count - 1 Do Begin
    DeleteFileUTF8(sl[i]);
  End;
  sl.free;
  form4.close;
  result := true;
End;

Function TForm1.ExportAsCGEOZIP(Filename: String): Boolean;
Var
  wd: String;
  z: TZipper;
Begin
  result := false;
  // 1. Export als GSAK gpx
  If Not GetWorkDir(wd) Then exit;
  wd := IncludeTrailingPathDelimiter(wd) + 'cgeo_export.gpx';
  If FileExistsUTF8(wd) Then Begin
    If Not DeleteFileUTF8(wd) Then Begin
      showmessage(format(RF_Error_could_not_delete, [wd]));
      exit;
    End;
  End;
  result := ExportAsGSAKGPX(wd, true);
  // 2. Packen als .zip Datei
  enabled := false;
  form4.RefresStatsMethod('Creating zip file.', 0, 0, true);
  z := TZipper.Create;
  z.FileName := FileName;
  z.Entries.AddFileEntry(wd, extractfilename(wd));
  z.ZipAllFiles;
  z.free;
  form4.Hide;
  Enabled := true;
  // 3. Löschen tmp Dateien
  If Not DeleteFileUTF8(wd) Then Begin
    showmessage(format(RF_Error_could_not_delete, [wd]));
    exit;
  End;
  result := true;
End;

Function TForm1.ExportAsGSAKGPX(Filename: String; ExportAsCGeo: Boolean
  ): Boolean;
Type
  TSAttribute = Record
    GC_Code: String;
    id: integer;
    inc: integer;
    Text: String;
  End;
Var
  a: Array Of TSAttribute;
  aptr: integer;

  Procedure AppendAttribs(GC_Code: String; Var Doc: TXMLDocument; Var wpt: TDOMNode);
  Var
    aptrbkup: integer;
    gs, ga, tmp: TDOMNode;
  Begin
    If aptr > high(a) Then exit;
    // Suchen der Stelle an derer der Cache seine attribute stehen hat
    aptrbkup := aptr;
    While (aptr <= high(a)) And (a[aptr].GC_Code <> GC_Code) Do Begin
      inc(aptr);
    End;
    gs := wpt.FindNode('groundspeak:cache');
    If Not assigned(gs) Then exit;
    ga := Doc.CreateElement('groundspeak:attributes');
    // Der Cache hatte keine Attribute -> Reset und Raus.
    If aptr > high(a) Then Begin
      aptr := aptrbkup;
      gs.AppendChild(ga);
      exit;
    End;
    // Der Cache hat Attribute, also fügen wir diese mal an..
    While (aptr <= high(a)) And (a[aptr].GC_Code = GC_Code) Do Begin
      tmp := AddTag(doc, ga, 'groundspeak:attribute', a[aptr].Text);
      TDOMElement(tmp).SetAttribute('id', inttostr(a[aptr].id));
      TDOMElement(tmp).SetAttribute('inc', inttostr(a[aptr].inc));
      inc(aptr);
    End;
    gs.AppendChild(ga);
  End;

Var
  i, c: integer;

  Doc: TXMLDocument;
  gpx, wpt: TDOMNode;
Begin
  result := false;
  form1.Enabled := false;
  form4.RefresStatsMethod('', 0, 0, True);
  // Das Problem ist, wenn der Export sehr Groß = viele Caches ist, dann kann es vorkommen, dass es ewig dauert
  // z.B. sind bei 160000 caches ca. 10 mal mehr Attribute in der Attribute Datenbank enthalten
  // Jeder Zugriff auf die Datenbank ist dann extrem teuer
  c := 0;
  StartSQLQuery('Select cache_name, id, inc, attribute_text from attributes order by cache_name asc');
  a := Nil;
  setlength(a, 1024);
  While Not SQLQuery1.EOF Do Begin
    a[c].GC_Code := SQLQuery1.Fields[0].AsString;
    a[c].id := SQLQuery1.Fields[1].AsInteger;
    a[c].inc := SQLQuery1.Fields[2].AsInteger;
    a[c].Text := SQLQuery1.Fields[3].AsString;
    inc(c);
    If c > high(a) Then Begin
      setlength(a, length(a) + 1024);
    End;
    SQLQuery1.Next;
  End;
  setlength(a, c);
  // Die Liste der Caches die wir abarbeiten muss gleich Sortiert sein wie die der Attribute
  If StringGrid1.Columns[MainColGCCode].Title.caption <> R_Code + ' \/' Then Begin
    StringGrid1HeaderClick(self, true, MainColGCCode);
  End;
  LabCacheCounter := 10000; // Reset, falls das schon öfters gemacht wurde
  NewDocGPX(doc, gpx);
  aptr := 0;
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    wpt := CachetToWPT(doc, StringGrid1.Cells[MainColGCCode, i], true, true, ExportAsCGeo);
    If Not assigned(wpt) Then Begin
      // Todo : Qualifizierte Fehlermeldung
      Continue;
    End;
    AppendAttribs(StringGrid1.Cells[MainColGCCode, i], doc, wpt);
    gpx.AppendChild(wpt);
    If i Mod 10 = 0 Then Begin
      If form4.RefresStatsMethod(R_Cache, i, 0, false) Then Begin
        form4.close;
        form1.Enabled := true;
        exit;
      End;
    End;
  End;
  doc.AppendChild(gpx);
  writeXMLFile(Doc, FileName);
  setlength(a, 0);
  doc.free;
  form4.close;
  form1.Enabled := true;
  result := true;
End;

Function TForm1.CreateDatabaseFromGSAKGPX(Filename, DBName: String): integer;
Var
  s, p: String;
  l: TSTringlist;
  i: Integer;
Begin
  result := -1;
  l := TStringlist.create;
  GetDBList(l, '');
  For i := 0 To l.Count - 1 Do Begin
    s := RemoveCacheCountInfo(l[i]);
{$IFDEF Windows}
    s := lowercase(s);
{$ENDIF}
    If s = DBName Then Begin
      If ID_NO = Application.MessageBox(pchar(format(RF_Database_already_exist_overwrite, [DBName])), pchar(R_Warning), MB_YESNO Or MB_ICONQUESTION) Then Begin
        l.free;
        exit;
      End;
    End;
  End;
  l.free;
  CreateNewDatabase(DBName);
  p := GetDataBaseDir();
  p := p + DBName + '.db';
  OpenDataBase(p, true);
  self.Enabled := false;
  result := ImportNoncheckedGPXFile(FileName);
  If form4.visible Then form4.close;
  self.Enabled := true;
  If ID_YES = Application.MessageBox(pchar(format(RF_Delete, [FileName])), pchar(R_Question), MB_YESNO Or MB_ICONQUESTION) Then Begin
    If Not DeleteFileUTF8(FileName) Then Begin
      ShowMessage(format(RF_Error_could_not_delete, [Filename]));
    End;
  End;
End;

Procedure TForm1.OnGPSExportClick(Sender: TObject);
Var
  t: int64;
  s: String;
Begin
  If Not SQLite3Connection.Connected Then Begin
    showmessage(R_Error_not_connected_to_database);
    exit;
  End;
  t := GetTickCount64;
  s := GetValue('GPSExport', 'Folder' + inttostr((sender As TComponent).tag), '');
  s := IncludeTrailingPathDelimiter(s) + ExtractFileNameOnly(SQLite3Connection.DatabaseName) + '.ggz';
  DoGPSExport(s);
  t := GetTickCount64 - t;
  showmessage(format(RF_Finished_after, [PrettyTime(t)], DefFormat));
End;

Procedure TForm1.OnGPSImportClick(Sender: TObject);
Var
  list: TFieldNoteList;
  s: String;
Begin
  // Fiel Notes Editieren
  s := trim(GetValue('GPSImport', 'Filename' + inttostr((sender As TComponent).Tag), ''));
  If (s <> '') And FileExistsUTF8(s) Then Begin
    Form10FieldNotesFilename := s;
    list := LoadFieldNotesFromFile(s);
    Form10.LoadFieldNoteList(self, list, false);
  End
  Else Begin
    showmessage(format(RF_Error_Could_not_find, [s]));
  End;
End;

Procedure TForm1.OnGPSSpoilerClick(Sender: TObject);
Var
  t: int64;
  i, j: integer;
  SpoilerRootDir, P, CacheName: String;
  sl: TStringList;
  cnt: integer;
Begin
  // GPS Spoiler Export
  i := (sender As TComponent).Tag;
  SpoilerRootDir := GetValue('GPSSpoilerExport', 'Folder' + inttostr(i), '');
  t := GetTickCount64;
  cnt := 0;
  form1.Enabled := false;
  Form4.RefresStatsMethod(R_Export_Spoilers, cnt, 0, true);
  For i := 1 To StringGrid1.RowCount - 1 Do Begin
    CacheName := StringGrid1.Cells[MainColGCCode, i];
    p := GetSpoilersDir() + CacheName + PathDelim;
    sl := FindAllFiles(p, '*');
    For j := 0 To sl.count - 1 Do Begin
      If TransferSpoilerImage(SpoilerRootDir, CacheName, sl[j]) Then Begin
        inc(cnt);
      End;
    End;
    If sl.Count <> 0 Then Begin
      If Form4.RefresStatsMethod(R_Export_Spoilers, cnt, 0, false) Then Begin
        break;
      End;
    End;
    sl.free;
  End;
  form4.Hide;
  form1.Enabled := true;
  t := GetTickCount64 - t;
  Showmessage(format(RF_Finished_after, [PrettyTime(t)], DefFormat));
End;

Procedure TForm1.OnScriptClick(Sender: TObject);
Var
  index: integer;
  t: int64;
Begin
  index := (sender As TComponent).Tag;
  t := GetTickCount64;
  CallScript(getvalue('Scripts', 'Name' + inttostr(index), ''));
  t := GetTickCount64 - t;
  Showmessage(format(RF_Finished_after, [PrettyTime(t)], DefFormat));
End;

Procedure TForm1.CallScript(Script_name: String);
Var
  varpromptdatabase, varDatabase, DontImportFoundCaches, DeleteImportedFiles: String;

  (*
   * In: ein Datenbankname oder $**$
   *
   * Out: ein Dateiname der geladen werden kann
   *)
  Function ResolveDatabase(Database: String): String;
  Var
    p: String;
  Begin
    result := Database;
    If lowercase(trim(Database)) = '$database$' Then result := varDatabase;
    If lowercase(trim(Database)) = '$promptdatabase$' Then result := varpromptdatabase;
    p := GetDataBaseDir();
    result := p + result + '.db';
  End;

  Function ResolveFilename(Filename: String): String;
  Var
    wd: String;
  Begin
    result := Filename;
    If pos('$workdir$', Filename) <> 0 Then Begin
      GetWorkDir(wd);
      wd := IncludeTrailingPathDelimiter(wd);
      result := StringReplace(result, '$workdir$', wd, [rfReplaceAll, rfIgnoreCase]);
      result := StringReplace(result, '//', PathDelim, [rfReplaceAll]);
      result := StringReplace(result, '/\', PathDelim, [rfReplaceAll]);
      result := StringReplace(result, '\/', PathDelim, [rfReplaceAll]);
      result := StringReplace(result, '\\', PathDelim, [rfReplaceAll]);
{$IFDEF Linux}
      result := StringReplace(result, '\', PathDelim, [rfReplaceAll]);
{$ELSE}
      result := StringReplace(result, '/', PathDelim, [rfReplaceAll]);
{$ENDIF}
    End;
  End;
Var
  varpromptDirectory, s: String;
  index: Integer;
Begin
  varpromptDirectory := '';
  varDatabase := ExtractFileNameOnly(SQLite3Connection1.DatabaseName);
  varpromptdatabase := '';
  For index := 0 To strtoint(getvalue('Script_' + Script_name, 'Count', '0')) - 1 Do Begin
    // Anzeigen wo wir gerade sind.
    StatusBar1.Panels[MainSBarInfo].Text := Form27.SkriptIndexCaption(Script_name, index);
    Application.ProcessMessages;
    Case strtoint(getvalue('Script_' + Script_name, 'Type' + inttostr(index), '-1')) Of
      Script_Select_Database: Begin
          s := getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
          s := ResolveDatabase(s);
          If Not OpenDataBase(s, true) Then Begin
            showmessage(format(RF_Error_in_Script_on_Load, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_Prompt_Database: Begin
          form16.modalresult := mrcancel;
          GetDBList(form16.ListBox1.Items, '');
          FormShowModal(form16, self);
          If form16.modalresult = mrOK Then Begin
            varpromptdatabase := ExtractFileNameOnly(form16.Filename);
          End
          Else Begin
            showmessage(R_No_database_selected_abort_script);
            exit;
          End;
        End;
      Script_Create_Database: Begin
          s := getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
          s := ResolveDatabase(s);
          s := ExtractFileNameOnly(s);
          If Not CreateNewDatabase(s) Then Begin
            showmessage(format(RF_Unable_Create_Script, [s]));
            exit;
          End;
          OpenDataBase(ResolveDatabase(s), true);
        End;
      Script_Create_Database_From_GSAK_GPX: Begin
          s := getvalue('Script_' + Script_name, 'Filename' + inttostr(index), '');
          s := ResolveFilename(s);
          If CreateDatabaseFromGSAKGPX(s, ExtractFileNameOnly(s)) < 0 Then Begin
            showmessage(format(RF_Unable_Create_From_Script, [s]));
            exit;
          End;
        End;
      Script_Del_Database: Begin
          s := getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
          s := ResolveDatabase(s);
{$IFDEF windows}
          If lowercase(SQLite3Connection1.DatabaseName) = lowercase(s) Then Begin
{$ELSE}
          If SQLite3Connection1.DatabaseName = s Then Begin
{$ENDIF}
            showmessage(format(RF_Error_could_not_delete_Script, [ExtractFileNameOnly(s)]));
            exit;
          End;
          If FileExistsUTF8(s) Then Begin
            If Not DeleteFileUTF8(s) Then Begin
              showmessage(format(RF_Error_could_not_delete_Script, [ExtractFileNameOnly(s)]));
              exit;
            End;
          End;
        End;
      Script_Prompt_Directory: Begin
          SelectDirectoryDialog1.FileName := varpromptDirectory;
          If SelectDirectoryDialog1.Execute Then Begin
            varpromptDirectory := SelectDirectoryDialog1.FileName;
          End
          Else Begin
            showmessage(R_No_directory_selected_abort_script);
            exit;
          End;
        End;
      Script_Import_directory: Begin
          DontImportFoundCaches := GetValue('General', 'DontImportFoundCaches', '');
          DeleteImportedFiles := GetValue('General', 'DeleteImportedFiles', '');
          SetValue('General', 'DontImportFoundCaches', getvalue('Script_' + Script_name, 'NotImportFound' + inttostr(index), '0'));
          SetValue('General', 'DeleteImportedFiles', Getvalue('Script_' + Script_name, 'DelAfterImport' + inttostr(index), '0'));
          s := ResolveDirectory(Getvalue('Script_' + Script_name, 'Directory' + inttostr(index), GetValue('General', 'LastImportDir', '')), varpromptDirectory);
          If ImportDirectory(s) = 0 Then Begin
            SetValue('General', 'DontImportFoundCaches', DontImportFoundCaches);
            SetValue('General', 'DeleteImportedFiles', DeleteImportedFiles);
            showmessage(format(RF_Nothing_imported_from_abort_script, [s]));
            exit;
          End;
          SetValue('General', 'DontImportFoundCaches', DontImportFoundCaches);
          SetValue('General', 'DeleteImportedFiles', DeleteImportedFiles);
        End;
      Script_Exec_Filter_Query: Begin
          ComboBox2.text := getvalue('Script_' + Script_name, 'search' + inttostr(index), '');
          edit2.text := getvalue('Script_' + Script_name, 'distance' + inttostr(index), '');
          combobox1.text := getvalue('Script_' + Script_name, 'filter' + inttostr(index), '');
          Button1.Click; // Auswählen der Daten
        End;
      Script_Exec_SQL_Query: Begin
          s := QueryToMainGridSelector + ' from caches c ' + FromSQLString(getvalue('Script_' + Script_name, 'query' + inttostr(index), ''));
          StartSQLQuery(s);
          QueryToMainGrid(GetTickCount64());
        End;
      Script_Exec_SQL_Transaction: Begin
          s := FromSQLString(getvalue('Script_' + Script_name, 'transaction' + inttostr(index), ''));
          If Not CommitSQLTransactionQuery(s) Then Begin
            // Keine Fehlermeldung, da die Transaktion eine gemeldet hat.
            exit;
          End;
          SQLTransaction1.Commit;
        End;
      Script_Select_cut_set_to_database: Begin
          s := getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
          s := ResolveDatabase(s);
          If Not SelectCutSetToOtherDB(s) Then Begin
            showmessage(format(RF_Unable_Get_Cut_Set_Script, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_copy_selection_to_database: Begin
          s := getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
          s := ResolveDatabase(s);
          s := ExtractFileNameOnly(s);
          If Not CopySelectionToOtherDB(s) Then Begin
            showmessage(format(RF_Error_in_Script_on_Copy, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_Move_selection_to_database: Begin
          s := getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
          s := ResolveDatabase(s);
          s := ExtractFileNameOnly(s);
          If Not MoveSelectionToOtherDB(s) Then Begin
            showmessage(format(RF_Error_in_Script_on_Move, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_ReDownloadListing: Begin
          MenuItem44Click(Nil); // Select All
          MenuItem78Click(Nil); // Redownload Listings
        End;
      Script_Delete_selection: Begin
          MenuItem44Click(Nil); // Select All
          MenuItem37Click(Nil); // Delete Selection
        End;
      Script_Mark_selection_as_archived: Begin
          MenuItem44Click(Nil); // Select All
          MenuItem43Click(Nil); // Mark Selection as Archived
        End;
      Script_Export_as_pocket_query: Begin
          s := getvalue('Script_' + Script_name, 'filename' + inttostr(index), '');
          s := ResolveFilename(s);
          If Not ExportAsPocketQuery(s) Then Begin
            showmessage(format(RF_Error_in_Script_on_ExportPQ, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_Export_as_GSAK_GPX: Begin
          s := getvalue('Script_' + Script_name, 'filename' + inttostr(index), '');
          s := ResolveFilename(s);
          If Not ExportAsGSAKGPX(s, false) Then Begin
            showmessage(format(RF_Error_in_Script_on_Export_GPX, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_Export_selection_to_as_ggz: Begin
          s := getvalue('Script_' + Script_name, 'Folder' + inttostr(index), '');
          s := ResolveDirectory(s, varpromptDirectory);
          s := IncludeTrailingPathDelimiter(s) + ExtractFileNameOnly(SQLite3Connection.DatabaseName) + '.ggz';
          If Not DoGPSExport(s) Then Begin
            showmessage(format(RF_Error_in_Script_on_Expor_GGZ, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_Export_selection_to_as_poi: Begin
          s := getvalue('Script_' + Script_name, 'Folder' + inttostr(index), '');
          s := ResolveDirectory(s, varpromptDirectory);
          If Not form9.ExportPOI(s) Then Begin
            showmessage(format(RF_Error_in_Script_on_Expor_POI, [FromSQLString(Script_name)]));
            exit;
          End;
        End;
      Script_Call_Script: Begin
          s := getvalue('Script_' + Script_name, 'script_name' + inttostr(index), '');
          CallScript(s);
        End;
      Script_Showmessage: Begin
          Showmessage(pchar(FromSQLString(getvalue('Script_' + Script_name, 'text' + inttostr(index), ''))));
        End;
      Script_Show_yes_no_question: Begin
          If ID_YES = Application.MessageBox(pchar(FromSQLString(getvalue('Script_' + Script_name, 'text' + inttostr(index), ''))), 'Question', MB_YESNO Or MB_ICONQUESTION) Then Begin
            If getvalue('Script_' + Script_name, 'onYes' + inttostr(index), '0') = '0' Then exit;
          End
          Else Begin
            If getvalue('Script_' + Script_name, 'onNo' + inttostr(index), '0') = '0' Then exit;
          End;
        End;
    Else Begin
        showmessage(format(RF_Not_implemented_abord_now, [getvalue('Script_' + Script_name, 'Type' + inttostr(index), '-1')]));
        exit;
      End;
    End;
  End;
End;

Function TForm1.DownloadAndImportCacheByGCCode(GCCode: String; Silent: Boolean
  ): integer;
Var
  wd, fn, bimp, bdel: String;
  BM: TRefresStatsMethod;
  oe: Boolean;
Begin
  result := 3;
  If Not GetWorkDir(wd) Then exit;
  BM := RefresStatsMethod;
  RefresStatsMethod := Nil; // Der User wird schon informiert über diesen Code also schalten wir die andere Information ab
  bdel := GetValue('General', 'DeleteImportedFiles', '0');
  setValue('General', 'DeleteImportedFiles', '1'); // Wir löschen die File auf jeden
  bimp := GetValue('General', 'DontImportFoundCaches', '1');
  setValue('General', 'DontImportFoundCaches', '0'); // Der User wollte aktualisieren, egal ob er die Dose schon hat oder eben nicht.
  fn := wd + GCCode + '.gpx';
  oe := self.Enabled;
  self.Enabled := false;
  If GCTDownloadCacheGPX(GCCode, fn, Silent) Then Begin
    If ImportGPXFile(fn) = 0 Then Begin
      result := 2;
    End
    Else Begin
      result := 0;
    End;
  End
  Else Begin
    result := 1;
  End;
  // Die globalen Variablen wieder her stellen
  If oe Then Begin
    self.Enabled := true;
  End;
  RefresStatsMethod := bm;
  setValue('General', 'DeleteImportedFiles', bdel);
  setValue('General', 'DontImportFoundCaches', bimp);
  RefreshDataBaseCacheCountinfo(); // es hat sich ggf was geändert.
End;

Procedure TForm1.OnToolsClick(Sender: TObject);
Var
  i: integer;
  s: String;
  p: TProcessUTF8;
Begin
  i := TMenuItem(sender).Tag;
  s := GetValue('Tools', 'Value' + inttostr(i), '');
  Case lowercase(GetValue('Tools', 'Type' + inttostr(i), '')) Of
    'exe': Begin
        If Not FileExistsUTF8(s) Then Begin
          ShowMessage(format(RF_Error_could_not_find, [s]));
          exit;
        End;
        p := TProcessUTF8.Create(Nil);
        p.Executable := s;
        p.Options := [];
        p.Execute;
        p.free;
      End
  Else
    OpenURL(s);
  End;
End;

Procedure TForm1.CreateFilterMenu;
Var
  i: integer;
Begin
  ComboBox1.Clear;
  ComboBox1.Items.Add('-');
  For i := 0 To strtoint(getvalue('Queries', 'Count', '0')) - 1 Do Begin
    ComboBox1.Items.Add(getvalue('Queries', 'Name' + inttostr(i), ''));
  End;
  Combobox1.items.add(r_Customize); // !! Achtung !!, der Quellcode verläst sich darauf das das als letztes kommt !!
  ComboBox1.ItemIndex := 0;
End;

Procedure TForm1.MenuItem4Click(Sender: TObject);
Begin
  // New Database
  form2.Edit1.Text := '';
  form2.ModalResult := mrnone;
  FormShowModal(form2, self);
  If form2.ModalResult = mrOK Then Begin
    NewDataBase(form2.Edit1.Text);
  End;
End;

Procedure TForm1.MenuItem50Click(Sender: TObject);
Begin
  MenuItem50.Checked := Not MenuItem50.Checked;
  setvalue('General', 'ShowDT', inttostr(ord(MenuItem50.Checked)));
  If MenuItem50.Checked Then Begin
    StringGrid1.Columns[MainColType].Title.caption := R_Type_DT;
  End
  Else Begin
    StringGrid1.Columns[MainColType].Title.caption := R_Type;
  End;
  StringGrid1.Invalidate;
End;

Procedure TForm1.MenuItem51Click(Sender: TObject);
Begin
  // Tool Editor
  form19.ReloadToolEntries;
  FormShowModal(form19, self);
  CreateToolsMenu;
End;

Procedure TForm1.MenuItem52Click(Sender: TObject);
Var
  t: int64;
  i: integer;
Begin
  If Opendialog2.execute Then Begin
    form2.Edit1.Text := ExtractFileNameOnly(OpenDialog2.FileName);
    form2.ModalResult := mrNone;
    FormShowModal(form2, self);
    If form2.ModalResult = mrOK Then Begin
      t := GetTickCount64;
      i := CreateDatabaseFromGSAKGPX(OpenDialog2.FileName, form2.Edit1.Text);
      t := gettickcount64 - t;
      showmessage(format(RF_Imported_Caches_in, [i, PrettyTime(t)], DefFormat));
    End;
  End;
End;

Procedure TForm1.MenuItem53Click(Sender: TObject);
Var
  t: int64;
Begin
  // Export nach GSAK GPX
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  If StringGrid1.RowCount <= 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If Not SaveDialog2.Execute Then exit;
  t := GetTickCount64;
  If Not ExportAsGSAKGPX(SaveDialog2.FileName, false) Then Begin
    showmessage(format(RF_Error_could_not_create, [SaveDialog2.FileName]));
  End
  Else Begin
    t := GetTickCount64 - t;
    showmessage(format(RF_Finished_after, [PrettyTime(t)], DefFormat));
  End;
End;

Procedure TForm1.MenuItem54Click(Sender: TObject);
Begin
  If GetValue('General', 'SQLAdminWarning', '1') = '1' Then Begin
    If ID_NO = Application.MessageBox(
      pchar(R_SQL_Admin_Warning), pchar(R_Warning), MB_YESNO Or MB_ICONWARNING) Then Begin
      exit;
    End;
  End;
  SetValue('General', 'SQLAdminWarning', '0');
  form24.caption := caption;
  form24.ComboBox3.ItemIndex := 0; // Zurücksetzen auf Cache
  form24.ReloadQueries;
  form6.SynCompletion1.Editor := Form24.SynEdit1;
  FormShowModal(form24, self);
End;

Procedure TForm1.MenuItem56Click(Sender: TObject);
Begin
  // Script Editor
  Form27.ReloadScriptCombobox;
  FormShowModal(form27, self);
  CreateScriptMenu;
End;

Procedure TForm1.MenuItem59Click(Sender: TObject);
Begin
  // Export as CSV File
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  form30.Show;
End;

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  uccm.Initccm(false); // Initialisieren der uccm.pas
  Form1ShowOnce := true;
  fCacheCountInActualDB := -1;
  form1.Constraints.MinWidth := width;
  form1.Constraints.MinHeight := 250;
  fUpdater := TUpdater.Create;
  // Das hier ist doppelt (auch in TForm1.CloseDataBase)
  StringGrid1.ColWidths[MainColType] := 60;
  StringGrid1.ColWidths[MainColGCCode] := 75;
  StringGrid1.ColWidths[MainColDist] := 50;
  StringGrid1.ColWidths[MainColFav] := 40;
  StringGrid1.Columns[MainColFav].Visible := false; // Per Default, machen wir keine Fav Auswertung.
  StringGrid1.RowCount := 1;
  ComboBox2.text := '';
  Edit2.text := '';
  ComboBox1.text := '-';
  // Die Komponenten Rein Reichen
  uccm.SQLite3Connection := SQLite3Connection1;
  uccm.SQLQuery := SQLQuery1;
  uccm.SQLTransaction := SQLTransaction1;
  // Die TB-Komponente Rein Reichen
  uccm.TB_SQLite3Connection := SQLite3Connection2;
  uccm.TB_SQLQuery := SQLQuery2;
  uccm.TB_SQLTransaction := SQLTransaction2;
  (* Alle Einstellungen die gemacht werden müssen, geht natürlich auch im OI *)
  (*
   * Die Komponente die die verbindung zum SQL-Server aufbaut
   *)
  SQLite3Connection1.DatabaseName := ''; // Name der Datenbank, case sensitiv
  SQLite3Connection1.Password := ''; // Kein Passwort
  SQLite3Connection1.UserName := ''; // Keine Ahnung für was das ist
  SQLite3Connection1.Transaction := SQLTransaction1;
  SQLite3Connection2.DatabaseName := ''; // Name der Datenbank, case sensitiv
  SQLite3Connection2.Password := ''; // Kein Passwort
  SQLite3Connection2.UserName := ''; // Keine Ahnung für was das ist
  SQLite3Connection2.Transaction := SQLTransaction2;
  (*
   * Transaction Komponente
   *)
  SQLTransaction1.DataBase := SQLite3Connection1;
  SQLTransaction2.DataBase := SQLite3Connection2;
  (*
   * Die Query Komponente
   *)
  SQLQuery1.DataBase := SQLite3Connection1;
  SQLQuery1.Transaction := SQLTransaction1;
  SQLQuery2.DataBase := SQLite3Connection2;
  SQLQuery2.Transaction := SQLTransaction2;
  MenuItem50.Checked := odd(StrToInt(getvalue('General', 'ShowDT', '0')));
  If GetValue('General', 'RestoreFormularPositions', '1') = '1' Then Begin
    width := strtointdef(getvalue('General', 'Form1Width', inttostr(Width)), width);
    Height := strtointdef(getvalue('General', 'Form1Height', inttostr(Height)), Height);
  End;
  left := (screen.width - form1.width) Div 2;
  top := (screen.height - form1.height) Div 2;
  Application.OnRestore := @OnApplicationRestore;
  RefreshSearchRemember();
End;

Procedure TForm1.FormResize(Sender: TObject);
Begin
  StringGrid1.Height := StatusBar1.Top - StringGrid1.Top - 10;
End;

Procedure TForm1.FormShow(Sender: TObject);
Var
  s: String;
Begin
  If Form1ShowOnce Then Begin
    Form1ShowOnce := false;
    LoadAndApplyLanguage;
    (*
     * Die Sprach Abhängigen Sachen dürfen natürlich erst nach dem Laden der Sprache gemacht werden.
     *)
    ResetMainGridCaptions;
    CreateWaypointImages;
    s := getvalue('General', 'LastDB', '');
    If (s <> '') And FileExistsUTF8(s) Then Begin
      OpenDataBase(s, true);
    End
    Else Begin
      caption := R_Not_Connected;
    End;
    CheckForNewVersion(false);
    // Den Wizzard starten
    If VeryFirstStartofCCM Then Begin
      showmessage(R_Welcome_Message);
    End;
    If GetValue('General', 'DisableWizard', '0') = '0' Then Begin
      // Wir starten den Wizard, dieser soll aber nur Fehlende Elemente erneut abfragen
      form36.StartWizzard(false, false, true);
    End;
    // Sämtliche Menüstrukturen werden erst nach dem Wizzard erstellt, dieser erweitert diese ggf.
    CreateExportMenu;
    CreateFilterMenu;
    CreateFieldImportMenu;
    CreateScriptMenu;
    CreateSpoilerMenu;
    CreateToolsMenu;
    CheckIniFileVersion();
  End;
End;

Procedure TForm1.MenuItem100Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
Begin
  // Reset Usernotes Online
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If lowercase(GCTGetServerParams().UserInfo.Usertype) <> 'premium' Then Begin
    showmessage(R_Error_This_feature_is_only_available_if_you_have_a_premium_account);
    exit;
  End;
  r := StringGrid1.Selection;
  self.Enabled := false;
  RefresStatsMethod('', 0, r.Bottom - r.Top + 1, true);
  For i := r.Top To r.Bottom Do Begin
    If RefresStatsMethod(StringGrid1.Cells[MainColGCCode, i], i - r.Top + 1, r.Bottom - r.Top + 1, false) Then Begin
      break;
    End;
    If Not GCTClearOnlineNote(StringGrid1.Cells[MainColGCCode, i]) Then break; // Konnte nicht einloggen
  End;
  Form4.Hide;
  self.Enabled := true;
  ShowMessage(R_Finished);
End;

Procedure TForm1.MenuItem101Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
Begin
  // Reset Corrected Coords Online
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If lowercase(GCTGetServerParams().UserInfo.Usertype) <> 'premium' Then Begin
    showmessage(R_Error_This_feature_is_only_available_if_you_have_a_premium_account);
    exit;
  End;
  r := StringGrid1.Selection;
  self.Enabled := false;
  RefresStatsMethod('', 0, r.Bottom - r.Top + 1, true);
  For i := r.Top To r.Bottom Do Begin
    If RefresStatsMethod(StringGrid1.Cells[MainColGCCode, i], i - r.Top + 1, r.Bottom - r.Top + 1, false) Then Begin
      break;
    End;
    If Not GCTClearOnlineCorrectedCoords(StringGrid1.Cells[MainColGCCode, i]) Then break; // Konnte nicht einloggen
  End;
  Form4.Hide;
  self.Enabled := true;
  ShowMessage(R_Finished);
End;

Procedure TForm1.Button1Click(Sender: TObject);
Var
  loclat, loclon: Double;
  filterquery, pre, query: String;
  t: int64;
Begin
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Error_not_connected_to_database);
    exit;
  End;
  t := GetTickCount64;
  query := GetValue('Locations', 'Place' + getvalue('General', 'AktualLocation', '0'), '');
  If query <> '' Then Begin
    loclat := strtofloat(copy(query, 1, pos('x', query) - 1), DefFormat);
    loclon := strtofloat(copy(query, pos('x', query) + 1, length(query)), DefFormat);
  End
  Else Begin
    locLat := -1;
    locLon := -1;
  End;
  // Go
  If trim(ComboBox2.text) <> '' Then Begin
    If ComboBox1.Text <> '-' Then Begin
      If ComboBox1.ItemIndex = ComboBox1.Items.Count - 1 Then Begin
        filterquery := form29.GetFilter;
      End
      Else Begin
        filterquery := FromSQLString(GetValue('Queries', 'Query' + IntToStr(ComboBox1.ItemIndex - 1), ''));
      End;
      Query := QueryToMainGridSelector + 'from caches c ' +
        filterquery +
        ' and (c.G_NAME like "%' + ToSQLString(trim(ComboBox2.text)) + '%"' +
        'or c.name like "%' + ToSQLString(trim(ComboBox2.text)) + '%")';
      pre := ' and ';
    End
    Else Begin
      Query := QueryToMainGridSelector + 'from caches c where ' +
        'G_NAME like "%' + ToSQLString(trim(ComboBox2.text)) + '%"' +
        'or name like "%' + ToSQLString(trim(ComboBox2.text)) + '%"';
      pre := ' and ';
    End;
  End
  Else Begin
    If ComboBox1.Text <> '-' Then Begin
      If ComboBox1.ItemIndex = ComboBox1.Items.Count - 1 Then Begin
        filterquery := form29.GetFilter;
      End
      Else Begin
        filterquery := FromSQLString(GetValue('Queries', 'Query' + IntToStr(ComboBox1.ItemIndex - 1), ''));
      End;
      Query := QueryToMainGridSelector + 'from caches c ' +
        filterquery;
      pre := ' and ';
    End
    Else Begin
      Query := QueryToMainGridSelector + 'from caches c';
      pre := ' Where ';
    End;
  End;
  // Vorfilter Distanzsuche
  If (trim(edit2.text) <> '') And (locLat <> -1) Then Begin
    (*
     * Die Werte 0.05 und 0.15 wurden empirisch ermittelt
     *
     * Dabei sind 0.05 bzw. 0.15 so weit weg vom Optimal (ca. 0.10) das die 3km Luflinie für Mysteries innerhalb der Toleranz liegt
     * und damit COR_LAT Berechnungen gespart werden können (die Feinselektierung am schluss richtet das dann.
     *)
    If trim(edit2.text)[1] = '-' Then Begin
      Query := query + pre +
        '((c.lat - ' + floattostr(loclat, DefFormat) + ')*' +
        '(c.lat - ' + floattostr(loclat, DefFormat) + ')) + ' +
        '((c.lon - ' + floattostr(loclon, DefFormat) + ')*' +
        '(c.lon - ' + floattostr(loclon, DefFormat) + ')) >= ' + floattostr((StrToFloatdef(Edit2.Text, 0, DefFormat) * StrToFloatdef(Edit2.Text, 0, DefFormat) * 0.05) / 1000, DefFormat);
    End
    Else Begin
      Query := query + pre +
        '((c.lat - ' + floattostr(loclat, DefFormat) + ')*' +
        '(c.lat - ' + floattostr(loclat, DefFormat) + ')) + ' +
        '((c.lon - ' + floattostr(loclon, DefFormat) + ')*' +
        '(c.lon - ' + floattostr(loclon, DefFormat) + ')) <= ' + floattostr((StrToFloatdef(Edit2.Text, 0, DefFormat) * StrToFloatdef(Edit2.Text, 0, DefFormat) * 0.15) / 1000, DefFormat);
    End;
  End;
  StartSQLQuery(query);
  QueryToMainGrid(t);
  If AddSearchRemember(Combobox2.Text) Then RefreshSearchRemember();
End;

Procedure TForm1.ComboBox1Change(Sender: TObject);
Begin
  If ComboBox1.Text = r_Customize Then Begin
    If Not form29.Visible Then Begin
      form29.Left := Form1.Left + form1.Width + 15;
      form29.Top := form1.Top;
      BringFormBackToScreen(form29); // Unter Windows könnte es passieren das das Fenster aus dem Monitor geschoben wird und sonst nicht mehr erreichbar wird.
      form29.Show;
    End;
  End
  Else Begin
    If form29.Visible Then form29.Hide;
  End;
End;

Procedure TForm1.ComboBox2KeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  (*
   * Separat Handle the Stringgrid Popup Menu Global hotkey's as they are not forwarded if the focus is on some other LCL-Elements
   *)
  If key = VK_F1 Then Begin
    MenuItem22Click(Nil); // Forward Edit Coords
  End;
  If key = VK_F2 Then Begin // Forwart Edit Usernote
    MenuItem18Click(Nil);
  End;
  If (ssCtrl In shift) Then Begin
    If key = VK_A Then Begin // Forward Select All
      MenuItem44Click(Nil);
    End;
    If key = VK_S Then Begin // Forward Set Custom Flag
      MenuItem62Click(Nil);
    End;
    If key = VK_C Then Begin // Forwart Cleat Custom Flag
      MenuItem63Click(Nil);
    End;
  End;
End;

Procedure TForm1.Edit1KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then button1.Click;
End;

Procedure TForm1.FormCloseQuery(Sender: TObject; Var CanClose: boolean);
Begin
  Setvalue('General', 'Form1Width', inttostr(Width));
  Setvalue('General', 'Form1Height', inttostr(Height));
  fUpdater.free;
  fUpdater := Nil;
End;

Procedure TForm1.MenuItem10Click(Sender: TObject);
Var
  t: int64;
  i: integer;
Begin
  If Not SQLite3Connection1.Connected Then Begin
    Showmessage(R_Error_not_connected_to_database);
    exit;
  End;
  form8.modalresult := mrnone;
  form8.Edit1.Text := GetValue('General', 'LastImportDir', '');
  form8.CheckBox1.Checked := GetValue('General', 'DontImportFoundCaches', '1') = '1';
  form8.CheckBox2.Checked := GetValue('General', 'DeleteImportedFiles', '0') = '1';
  FormShowModal(form8, self);
  If form8.modalresult = mrok Then Begin
    Application.ProcessMessages; // Sicherstellen, dass Form8 auch zugeht.
    SetValue('General', 'LastImportDir', form8.Edit1.Text);
    SetValue('General', 'DontImportFoundCaches', inttostr(ord(form8.CheckBox1.Checked)));
    SetValue('General', 'DeleteImportedFiles', inttostr(ord(form8.CheckBox2.Checked)));
    // Import Directory
    ComboBox2.text := '';
    Edit2.text := '';
    ComboBox1.ItemIndex := 0;
    t := gettickcount64;
    i := ImportDirectory(form8.Edit1.Text);
    t := gettickcount64 - t;
    showmessage(format(RF_Imported_Caches_in, [i, PrettyTime(t)], DefFormat));
    If StringGrid1.RowCount <> 1 Then Begin
      If id_yes = Application.MessageBox(pchar(R_All_Shown_Caches_have_not_been_updated_mar_as_archived), pchar(R_Question), MB_YESNO Or MB_ICONQUESTION) Then Begin
        // 1. Alle Anwählen
        MenuItem44Click(Nil);
        // 2. Alle als Archived Markieren
        MenuItem43Click(Nil);
      End;
    End;
  End;
End;

Procedure TForm1.MenuItem13Click(Sender: TObject);
Begin
  // Folder und file editor
  form21.LoadFolderFiles;
  FormShowModal(form21, self);
  // Alle Notwendigen Untermenues neu erstellen
  CreateExportMenu;
  CreateFieldImportMenu;
  CreateSpoilerMenu;
End;

Procedure TForm1.MenuItem14Click(Sender: TObject);
Var
  i: integer;
Begin
  // Filter Editor
  CreateFilterMenu;
  form6.ComboBox1.Clear;
  For i := 1 To ComboBox1.Items.Count - 2 Do // -2 weil ja der custom Filter als letztes drin steht und den kann man nicht Editieren.
    form6.ComboBox1.Items.Add(ComboBox1.Items[i]);
  If form6.ComboBox1.Items.count <> 0 Then Begin
    form6.ComboBox1.ItemIndex := 0;
    form6.ComboBox1.OnChange(Nil);
  End
  Else Begin
    form6.ComboBox1.Text := '';
  End;
  form6.SynCompletion1.Editor := Form6.SynEdit1;
  FormShowModal(form6, self);
  CreateFilterMenu;
End;

Procedure TForm1.MenuItem15Click(Sender: TObject);
Begin
  // Location Editor
  form14.ReloadLocations;
  form14.show;
End;

Procedure TForm1.MenuItem17Click(Sender: TObject);
Begin
  form41.ShowVersionInformations();
  form41.ShowModal;
End;

Procedure TForm1.MenuItem33Click(Sender: TObject);
Var
  lat, lon, clat, clon: Double;
  r: trect;
  i: LongInt;
Begin
  // mark Coord as modified
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    StartSQLQuery('Select lat, lon, cor_lat, cor_lon from caches where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    If SQLQuery1.EOF Then exit;
    lat := SQLQuery1.Fields[0].AsFloat;
    lon := SQLQuery1.Fields[1].AsFloat;
    clat := SQLQuery1.Fields[2].AsFloat;
    clon := SQLQuery1.Fields[3].AsFloat;
    If (clon = -1) Or (clat = -1) Then Begin
      StringGrid1.Cells[MainColType, i] := AddCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'C');
      CommitSQLTransactionQuery('Update caches set ' +
        'COR_LAT = ' + floattostr(lat, DefFormat) + ' ' +
        ',COR_Lon = ' + floattostr(lon, DefFormat) + ' ' +
        'where name = "' + StringGrid1.Cells[MainColGCCode, i] + '";');
    End;
  End;
  StringGrid1.Invalidate;
  SQLTransaction1.Commit;
End;

Procedure TForm1.MenuItem18Click(Sender: TObject);
Var
  loclat, loclon, lat, lon, clat, clon: Double;
  s: String;
Begin
  // Modify Coordinates
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  If form5.ModifyCoordinate(StringGrid1.Cells[MainColGCCode, row], Self) Then Begin
    StartSQLQuery('Select lat, lon, cor_lat, cor_lon from caches where name = "' + StringGrid1.Cells[MainColGCCode, row] + '"');
    lat := SQLQuery.Fields[0].AsFloat;
    lon := SQLQuery.Fields[1].AsFloat;
    clat := SQLQuery.Fields[2].AsFloat;
    clon := SQLQuery.Fields[3].AsFloat;
    // Update Icon Modifizierte Koords oder nicht
    If (clat = -1) Then Begin
      StringGrid1.Cells[MainColType, row] := RemoveCacheTypeSpezifier(StringGrid1.Cells[MainColType, row], 'C');
    End
    Else Begin
      StringGrid1.Cells[MainColType, row] := AddCacheTypeSpezifier(StringGrid1.Cells[MainColType, row], 'C');
    End;
    StringGrid1.Invalidate;
    // Update Distanz zu Home in Row
    s := GetValue('Locations', 'Place' + getvalue('General', 'AktualLocation', ''), '');
    If s <> '' Then Begin
      loclat := strtofloat(copy(s, 1, pos('x', s) - 1), DefFormat);
      loclon := strtofloat(copy(s, pos('x', s) + 1, length(s)), DefFormat);
    End
    Else Begin
      locLat := -1;
      locLon := -1;
    End;
    If locLat = -1 Then Begin
      StringGrid1.cells[MainColDist, row] := ''; // Keine Location definiert, also auch keine Distanz berechenbar
    End
    Else Begin
      If clat = -1 Then Begin
        // Dose ohne modifizierten Koords
        StringGrid1.cells[MainColDist, row] := format('%1.1fkm', [distance(locLat, locLon, lat, lon) / 1000]);
      End
      Else Begin
        // Dose mit modifizierten Koords
        StringGrid1.cells[MainColDist, row] := format('%1.1fkm', [distance(locLat, locLon, clat, clon) / 1000]);
      End;
    End;
  End;
End;

Procedure TForm1.MenuItem19Click(Sender: TObject);
Var
  gegen, p: String;
  StartTime: int64;
Begin
  // List all Caches, that are also in other DB
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  GetDBList(form11.ComboBox1.Items, ExtractFileNameOnly(SQLite3Connection1.DatabaseName));
  If form11.ComboBox1.Items.Count = 0 Then Begin
    showmessage(R_Error_no_other_databases_found_Please_create_one_first);
    exit;
  End;
  form11.ComboBox1.ItemIndex := 0;
  form11.ModalResult := mrNone;
  FormShowModal(form11, self);
  If Form11.ModalResult = mrOK Then Begin
    StartTime := GetTickCount64;
    StringGrid1.RowCount := 1;
    p := GetDataBaseDir();
    gegen := p + RemoveCacheCountInfo(Form11.ComboBox1.Text) + '.db';
    SelectCutSetToOtherDB(gegen);
    // Anzeigen wie viele Dosen es denn nun sind.
    StartTime := GetTickCount64 - StartTime;
    StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [StringGrid1.RowCount - 1]);
    StatusBar1.Panels[MainSBarInfo].Text := format(RF_Time, [PrettyTime(StartTime)]);
    Application.ProcessMessages;
  End;
End;

Procedure TForm1.MenuItem21Click(Sender: TObject);
Begin
  // Travel Bug Editor
  form23.LoadTBList;
  form23.LoadTBGroupList;
  FormShowModal(Form23, self);
End;

Procedure TForm1.MenuItem22Click(Sender: TObject);
Begin
  // Edit notes
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  EditCacheNote(self, StringGrid1.Cells[MainColGCCode, row]);
End;

Procedure TForm1.MenuItem25Click(Sender: TObject);
Begin
  // Exportiere Selektierte Datensätze in eine ander Datenbank
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  If StringGrid1.RowCount = 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  Form11.ComboBox1.items.Clear;
  GetDBList(form11.ComboBox1.Items, ExtractFileNameOnly(SQLite3Connection1.DatabaseName));
  If form11.ComboBox1.Items.Count = 0 Then Begin
    showmessage(R_Error_no_other_databases_found_Please_create_one_first);
    exit;
  End;
  form11.ComboBox1.ItemIndex := 0;
  form11.ModalResult := mrNone;
  FormShowModal(form11, self);
  If Form11.ModalResult = mrOK Then Begin
    MoveSelectionToOtherDB(RemoveCacheCountInfo(Form11.ComboBox1.Text));
  End;
End;

Procedure TForm1.MenuItem26Click(Sender: TObject);
Var
  skipped: integer;
Begin
  // Show on 81er
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  skipped := Form12.ReloadCachesFromDB;
  If Not form12.Visible Then form12.show;
  If skipped <> 0 Then Begin
    showmessage(format(RF_Skipped_caches_due_to_invalid_d_t_settings, [skipped]));
  End;
End;

Procedure TForm1.MenuItem27Click(Sender: TObject);
Var
  i, j: integer;
Begin
  // transfer POI
  If StringGrid1.RowCount <= 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  j := strtoint(getvalue('GPSPOI', 'Count', '0'));
  form9.ComboBox1.Clear;
  For i := 0 To j - 1 Do Begin
    form9.ComboBox1.Items.Add(getvalue('GPSPOI', 'Folder' + inttostr(i), ''));
  End;
  If Form9.ComboBox1.Items.Count <> 0 Then Begin
    Form9.ComboBox1.ItemIndex := 0;
  End;
  form9.show;
End;

Procedure TForm1.MenuItem28Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
Begin
  // Mark as Found
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set g_found=1 where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    SQLTransaction1.Commit;
    StringGrid1.Cells[MainColType, i] := AddCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'F');
  End;
  StringGrid1.Invalidate;
End;

Procedure TForm1.MenuItem35Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
Begin
  // Unmark as found
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set g_found=0 where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    SQLTransaction1.Commit;
    StringGrid1.Cells[MainColType, i] := RemoveCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'F');
  End;
  StringGrid1.Invalidate;
End;

Procedure TForm1.MenuItem37Click(Sender: TObject);
Var
  r: TRect;
  c, i: LongInt;
Begin
  // Delete Cache
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  r := StringGrid1.Selection;
  c := 0;
  form1.Enabled := false;
  For i := r.Bottom Downto r.Top Do Begin
    inc(c);
    Form4.RefresStatsMethod(format(RF_Delete, [StringGrid1.Cells[MainColTitle, i]]), c, 0, i = r.Bottom);
    DelCache(StringGrid1.Cells[MainColGCCode, i]);
    StringGrid1.DeleteRow(i);
    If Form4.Abbrechen Then break;
  End;
  StatusBar1.Panels[MainSBarCQCount].Text := format(RF_Caches, [StringGrid1.RowCount - 1]);
  StatusBar1.Panels[MainSBarInfo].Text := '';
  RefreshDataBaseCacheCountinfo();
  form1.Enabled := true;
  form4.Hide;
End;

Procedure TForm1.MenuItem39Click(Sender: TObject);
Var
  r: TRect;
  j, i: integer;
  t: int64;
Begin
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  r := StringGrid1.Selection;
  // Download Spoiler
  t := GetTickCount64;
  j := 0;
  form1.Enabled := false;
  form4.RefresStatsMethod(R_Get_Spoilers, 0, 0, true);
  For i := r.Top To r.Bottom Do Begin
    If form4.RefresStatsMethod(R_Get_Spoilers + ': ' + StringGrid1.Cells[MainColGCCode, i] + ', ' + StringGrid1.Cells[MainColTitle, i], i - r.Top + 1, j, false) Then Begin
      break;
    End;
    j := j + GCTDownloadSpoiler(StringGrid1.Cells[MainColGCCode, i]);
  End;
  form4.Hide;
  form1.Enabled := true;
  t := GetTickCount64 - t;
  showmessage(format(RF_Downloaded_spoiler_images_Time, [j, PrettyTime(t)], DefFormat));
End;

Procedure TForm1.MenuItem3Click(Sender: TObject);
Var
  t: int64;
Begin
  // Export as c:geo
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  If StringGrid1.RowCount <= 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If Not SaveDialog1.Execute Then exit;
  t := GetTickCount64;
  If Not ExportAsCGEOZIP(SaveDialog1.FileName) Then Begin
    showmessage(format(RF_Error_could_not_create, [SaveDialog1.FileName]));
  End
  Else Begin
    t := GetTickCount64 - t;
    showmessage(format(RF_Finished_after, [PrettyTime(t)], DefFormat));
  End;
End;

Procedure TForm1.MenuItem41Click(Sender: TObject);
Begin
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  // Add SpoilerImage
  AddSpoilerImageToCache(StringGrid1.Cells[MainColGCCode, row]);
End;

Procedure TForm1.MenuItem42Click(Sender: TObject);
Var
  i: integer;
Begin
  // Remove Mark Archived
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set G_ARCHIVED=0 where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    // Entfernen des Leading "A"
    StringGrid1.Cells[MainColType, i] := RemoveCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'A');
  End;
  SQLTransaction1.Commit;
  StringGrid1.Invalidate;
End;

Procedure TForm1.MenuItem43Click(Sender: TObject);
Var
  i: integer;
Begin
  // Mark as Archived
  For i := StringGrid1.Selection.Top To StringGrid1.Selection.Bottom Do Begin
    CommitSQLTransactionQuery('Update caches set G_ARCHIVED=1 where name = "' + StringGrid1.Cells[MainColGCCode, i] + '"');
    StringGrid1.Cells[MainColType, i] := AddCacheTypeSpezifier(StringGrid1.Cells[MainColType, i], 'A');
  End;
  SQLTransaction1.Commit;
  StringGrid1.Invalidate;
End;

Procedure TForm1.MenuItem44Click(Sender: TObject);
Var
  r: TRect;
Begin
  // Select all
  r.Left := 0;
  r.Right := StringGrid1.ColCount - 1;
  r.top := 1;
  r.Bottom := StringGrid1.RowCount - 1;
  StringGrid1.Selection := r;
End;

Procedure TForm1.MenuItem46Click(Sender: TObject);
Begin
  // Show on Map
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  allowcnt := 0;
  Form15Initialized := false;
  FormShowModal(form15, self);
End;

Procedure TForm1.MenuItem47Click(Sender: TObject);
Begin
  // Copy to oder DB
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  If StringGrid1.RowCount = 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  GetDBList(form11.ComboBox1.Items, ExtractFileNameOnly(SQLite3Connection1.DatabaseName));
  If form11.ComboBox1.Items.Count = 0 Then Begin
    showmessage(R_Error_no_other_databases_found_Please_create_one_first);
    exit;
  End;
  form11.ComboBox1.ItemIndex := 0;
  form11.ModalResult := mrNone;
  FormShowModal(form11, self);
  If Form11.ModalResult = mrOK Then Begin
    CopySelectionToOtherDB(RemoveCacheCountInfo(Form11.ComboBox1.Text));
  End;
End;

Procedure TForm1.MenuItem48Click(Sender: TObject);
Var
  r: trect;
Begin
  // Edit Waypoints
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  If r.Top <> r.Bottom Then Begin
    showmessage(R_To_use_this_feature_select_only_one_cache);
    exit;
  End;
  form17.LoadCache(StringGrid1.Cells[MainColGCCode, r.top]);
  FormShowModal(form17, Self);
End;

Procedure TForm1.MenuItem29Click(Sender: TObject);
Var
  t: int64;
Begin
  If Not SQLite3Connection1.Connected Then Begin
    showmessage(R_Not_Connected);
    exit;
  End;
  If StringGrid1.RowCount = 1 Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  // Exportieren der Selektierten als Pocket Query
  If SaveDialog1.Execute Then Begin
    t := GetTickCount64;
    ExportAsPocketQuery(SaveDialog1.FileName);
    t := GetTickCount64 - t;
    showmessage(format(RF_Finished_after, [PrettyTime(t)], DefFormat));
  End;
End;

Procedure TForm1.MenuItem2Click(Sender: TObject);
Begin
  // Load database
  form16.modalresult := mrcancel;
  GetDBList(form16.ListBox1.Items, '');
  FormShowModal(form16, self);
  If form16.modalresult = mrOK Then Begin
    OpenDataBase(form16.Filename, true);
  End;
End;

Procedure TForm1.MenuItem34Click(Sender: TObject);
Var
  r: TRect;
  i: integer;
Begin
  // Open in Browser
  If (row <= 0) Or (row >= StringGrid1.RowCount) Then Begin
    exit;
  End;
  r := StringGrid1.Selection;
  For i := r.Top To r.Bottom Do Begin
    OpenCacheInBrowser(StringGrid1.Cells[MainColGCCode, i]);
  End;
End;

End.

