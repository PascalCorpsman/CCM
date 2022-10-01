Unit Unit36;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

Type

  { TForm36 }

  TForm36 = Class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox8: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox8: TComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    Procedure Button10Click(Sender: TObject);
    Procedure Button11Click(Sender: TObject);
    Procedure Button12Click(Sender: TObject);
    Procedure Button13Click(Sender: TObject);
    Procedure Button14Click(Sender: TObject);
    Procedure Button15Click(Sender: TObject);
    Procedure Button16Click(Sender: TObject);
    Procedure Button17Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure ComboBox1Change(Sender: TObject);
    Procedure ComboBox2Change(Sender: TObject);
    Procedure ComboBox3Change(Sender: TObject);
    Procedure ComboBox8Change(Sender: TObject);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCreate(Sender: TObject);
    Procedure Label6Click(Sender: TObject);
  private
    // Die Übergabeparameter der StartWizzard Funktion werden hier noch mal gespeichert, damit diese intern immer wieder übergeben werden können
    wStep: integer;
    wAll: Boolean;
    wShowFinishHint: Boolean;
    Function Start(index: integer): Boolean; // Zeigt die Karte für das jeweilige Wizard Element
    Function DatabaseFilename: String; // Macht aus der Listbox1 einen Gültigen Datenbank Dateinamen
  public
    Function StartWizzard(ShowFinishHint, All, Reset: Boolean): boolean; // True, wenn wenigstens ein Punkt abgearbetet wurde
  End;

Var
  Form36: TForm36;

Implementation

{$R *.lfm}

Uses
  unit1,
  unit27,
  usqlite_helper,
  uccm,
  ulanguage,
  LCLIntf,
  LCLType,
  LazFileUtils,
  ugctoolwrapper,
  LazUTF8;

Const
  (*
   * Achtung, die Reihenfolge der Tabs mus idetnisch der hier stehenden Nummern sein !!
   *)
  Index_Select_Database = 0;
  Index_ImportDir = 1;
  Index_SetLocation = 2;
  Index_Groundspeak_Settings = 3;
  Index_logCount = 4;
  Index_GPS_Settings = 5;
  Index_Export_Spoiler = 6;
  Index_Wizard = 7; // -- Achtung muss immer der letzte sein, also beim neu anlegen anderer diesen nach hinten schieben (in der Pagecontrol und hier numerisch)

  { TForm36 }

Procedure TForm36.Button1Click(Sender: TObject);
Begin
  // Abbrechen
  Close;
End;

Procedure TForm36.Button11Click(Sender: TObject);
Var
  c, index: integer;
  n: String;
Begin
  // OK des Enter GPS Settings Dialogs
  // Alle Vorbedingungen
  If trim(edit8.text) = '' Then Begin
    showmessage(R_error_no_Name_defined);
    exit;
  End;
  If trim(edit12.text) = '' Then Begin
    showmessage(R_error_no_Name_defined);
    exit;
  End;
  If Not DirectoryExistsUTF8(ComboBox6.Text) Then Begin
    ShowMessage(format(RF_Error_Directory_does_not_exist, [ComboBox6.Text]));
    exit;
  End;
  If Not DirectoryExistsUTF8(ComboBox2.Text) Then Begin
    ShowMessage(format(RF_Error_Directory_does_not_exist, [ComboBox2.Text]));
    exit;
  End;
  If Not FileExistsUTF8(ComboBox3.Text) Then Begin
    ShowMessage(format(RF_warning_File_does_not_exist, [ComboBox3.Text]));
  End;

{$IFDEF Windows}
  If trim(edit13.text) = '' Then Begin
    Showmessage(R_Error_no_gpsbabel_folder_set);
    exit;
  End;
{$ENDIF}
  If CheckBox1.Checked Then Begin
    If Trim(ComboBox7.Text) = '' Then Begin
      showmessage(R_error_no_Name_defined);
      exit;
    End;
  End;
  // ---- GGZ Folder
  index := LocateGPSExportIndex(ComboBox2.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSExport', 'Count', '0'), 0);
    SetValue('GPSExport', 'Folder' + inttostr(c), ComboBox2.Text);
    SetValue('GPSExport', 'Name' + inttostr(c), Edit8.text);
    Setvalue('GPSExport', 'Count', inttostr(c + 1));
    ComboBox2.Items.Add(ComboBox2.Text);
  End
  Else Begin
    // Overwrite
    SetValue('GPSExport', 'Name' + inttostr(index), Edit8.text);
  End;
  // ---- POI Folder
  index := LocatePoiExportFilderIndex(ComboBox6.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSPOI', 'Count', '0'), 0);
    SetValue('GPSPOI', 'Folder' + inttostr(c), ComboBox6.Text);
    Setvalue('GPSPOI', 'Count', inttostr(c + 1));
    ComboBox6.Items.Add(ComboBox6.Text);
  End
  Else Begin
    // Overwrite
    // -- Nichts gibts net, weil kein Name Tag
  End;
  setvalue('General', 'GPSBabelFolder', edit13.text);
  // ---- Create Export Script
  If CheckBox1.Checked Then Begin
    showmessage(R_Creating_Export_Script);
    c := strtoint(getvalue('Scripts', 'Count', '0'));
    n := '';
    For index := 0 To c - 1 Do Begin
      If getvalue('Scripts', 'Name' + inttostr(index), '') = ComboBox7.Text Then Begin
        n := ComboBox7.Text; // Das Skript gibt es schon
        break;
      End;
    End;
    If n = '' Then Begin // Das Skript gibt es noch nicht
      setvalue('Scripts', 'Count', inttostr(c + 1));
      n := ComboBox7.Text;
      setvalue('Scripts', 'Name' + inttostr(c), n);
    End;
    setvalue('Script_' + n, 'Count', '2');
    setvalue('Script_' + n, 'Type0', inttostr(Script_Export_selection_to_as_ggz));
    setvalue('Script_' + n, 'Folder0', ComboBox2.Text);
    setvalue('Script_' + n, 'Type1', inttostr(Script_Export_selection_to_as_poi));
    setvalue('Script_' + n, 'Folder1', ComboBox6.Text);
  End;
  // ---- Geocachevisits.txt
  index := LocateImportGeocacheVisitsIndex(ComboBox3.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSImport', 'Count', '0'), 0);
    SetValue('GPSImport', 'Filename' + inttostr(c), ComboBox3.Text);
    SetValue('GPSImport', 'Name' + inttostr(c), Edit12.text);
    Setvalue('GPSImport', 'Count', inttostr(c + 1));
    ComboBox3.Items.Add(ComboBox3.Text);
  End
  Else Begin
    // Overwrite
    SetValue('GPSImport', 'Name' + inttostr(index), Edit12.text);
  End;

  // Epilog
  If Not StartWizzard(wShowFinishHint, wAll, false) Then Begin
    close;
  End;
End;

Procedure TForm36.Button10Click(Sender: TObject);
Var
  nam: String;
Begin
  nam := edit12.text;
  If OpenDialog1.Execute Then Begin
    ComboBox3.Text := OpenDialog1.FileName;
    ComboBox3Change(Nil);
    If edit12.text = '' Then Begin
      Edit12.Text := nam;
    End;
  End;
End;

Procedure TForm36.Button12Click(Sender: TObject);
Var
  finds: integer;
  User, PW: String;
Begin
  // Test Connection
  Button12.Enabled := false;
  // 1. Speicher aller Alter Daten
  User := getvalue('General', 'UserName', '');
  PW := getvalue('General', 'Password', '');
  // 1.1 Setzen neuer
  Setvalue('General', 'UserName', Edit2.text);
  setvalue('General', 'Password', '');
  // 2. Einlogg Versuch
  GCTLogOut;
  If GCTGetFoundNumber(finds) Then Begin
    showmessage(format(RF_Sucessfully_logged_in_Your_online_found_number_is, [finds]));
  End;
  // 3. Wieder Herstellen der Alten Daten
  GCTLogOut;
  Setvalue('General', 'UserName', User);
  setvalue('General', 'Password', PW);
  Button12.Enabled := true;
End;

Procedure TForm36.Button13Click(Sender: TObject);
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    edit13.Text := SelectDirectoryDialog1.FileName;
  End;
End;

Procedure TForm36.Button14Click(Sender: TObject);
Var
  nam: String;
Begin
  nam := Edit10.Text;
  If SelectDirectoryDialog1.Execute Then Begin
    ComboBox8.Text := SelectDirectoryDialog1.FileName;
    ComboBox8Change(Nil);
    If Edit10.Text = '' Then Begin
      Edit10.Text := nam;
    End;
  End;
End;

Procedure TForm36.Button15Click(Sender: TObject);
Var
  c, index: integer;
Begin
  // OK -Spoiler Settings
  If trim(edit10.text) = '' Then Begin
    showmessage(R_error_no_Name_defined);
    exit;
  End;
  If Not DirectoryExistsUTF8(ComboBox8.Text) Then Begin
    ShowMessage(format(RF_Error_Directory_does_not_exist, [ComboBox8.Text]));
    exit;
  End;
  //Add Spoiler Export
  index := LocateExportSpoilerIndex(ComboBox8.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSSpoilerExport', 'Count', '0'), 0);
    SetValue('GPSSpoilerExport', 'Folder' + inttostr(c), ComboBox8.Text);
    SetValue('GPSSpoilerExport', 'Name' + inttostr(c), Edit10.text);
    Setvalue('GPSSpoilerExport', 'Count', inttostr(c + 1));
    ComboBox8.Items.Add(ComboBox8.Text);
  End
  Else Begin
    // Overwrite
    SetValue('GPSSpoilerExport', 'Name' + inttostr(index), Edit10.text);
  End;
  // Epilog
  If Not StartWizzard(wShowFinishHint, wAll, false) Then Begin
    close;
  End;
End;

Procedure TForm36.Button16Click(Sender: TObject);
Begin
  setValue('General', 'DisableWizard', inttostr(ord(CheckBox8.Checked)));
  // Diese Karte ist definitiv die letzte, danach brauchen wir den Wizard nicht mehr starten
  close;
End;

Procedure TForm36.Button17Click(Sender: TObject);
Var
  finds: integer;
Begin
  // Refresh Found Number
  form36.Enabled := false;
  If GCTGetFoundNumber(finds) Then Begin
    edit4.text := inttostr(finds);
  End;
  form36.Enabled := True;
End;

Procedure TForm36.Button2Click(Sender: TObject);
Begin
  // OK - Select Database
  // Prolog
  If ListBox1.ItemIndex = -1 Then Begin
    // Neue Datenbank erstellen
    If Not form1.NewDataBase(Edit1.Text) Then Begin
      showmessage(format(RF_Could_not_Open_Or_Create_Database_Did_you_install_SQLite3, [edit1.text]));
    End;
  End
  Else Begin
    // Laden einer Existierenden Datenbank
    If Not (Form1.OpenDataBase(DatabaseFilename(), True)) Then Begin
      showmessage(format(RF_Could_not_Open_Or_Create_Database_Did_you_install_SQLite3, [RemoveCacheCountInfo(ListBox1.Items[ListBox1.ItemIndex])]));
    End;
  End;
  // Epilog
  If Not StartWizzard(wShowFinishHint, wAll, false) Then Begin
    close;
  End;
End;

Procedure TForm36.Button3Click(Sender: TObject);
Begin
  // OK - Enter Groundspeak Settings
  setvalue('General', 'UserName', edit2.text);
  setvalue('General', 'UserID', edit3.text);
  // Epilog
  If Not StartWizzard(wShowFinishHint, wAll, false) Then Begin
    close;
  End;
End;

Procedure TForm36.Button4Click(Sender: TObject);
Begin
  // OK - Set Logcount und Formatstring
  Setvalue('General', 'Logcount', inttostr(strtointdef(edit4.text, -1)));
  setvalue('General', 'LogCountFormat', edit9.text);
  // Epilog
  If Not StartWizzard(wShowFinishHint, wAll, false) Then Begin
    close;
  End;
End;

Procedure TForm36.Button5Click(Sender: TObject);
Var
  lat, lon: Double;
  index: integer;
  s: String;
Begin
  // das OK der Location
  If Trim(ComboBox1.Text) = '' Then Begin
    showmessage(R_No_Location_Name_defined);
    exit;
  End;
  If StringToCoord(ComboBox4.Text + edit5.text + ComboBox5.Text + Edit6.text, lat, lon) Then Begin
    index := GetIndexOfLocation(ComboBox1.Text, false);
    // Setzen der Eigentlichen Location
    If index = -1 Then Begin // Create
      index := strtoint(GetValue('Locations', 'Count', '0'));
      SetValue('Locations', 'Name' + inttostr(index), ComboBox1.Text);
      SetValue('Locations', 'Count', inttostr(index + 1));
    End;
    s := format('%0.6fx%0.6f', [lat, lon], DefFormat);
    SetValue('Locations', 'Place' + inttostr(Index), s);
    // Übernehmen als Home
    setvalue('General', 'AktualLocation', inttostr(index));
    // Epilog
    If Not StartWizzard(wShowFinishHint, wAll, false) Then Begin
      close;
    End;
  End
  Else Begin
    showmessage(format(RF_Error_unable_to_decode_location, [ComboBox4.Text + edit5.text, ComboBox5.Text + Edit6.text]));
  End;
End;

Procedure TForm36.Button6Click(Sender: TObject);
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    edit7.text := SelectDirectoryDialog1.FileName;
  End;
End;

Procedure TForm36.Button7Click(Sender: TObject);
Begin
  // OK Set Import Folder
  setValue('General', 'LastImportDir', edit7.text);
  // Epilog
  If Not StartWizzard(wShowFinishHint, wAll, false) Then Begin
    close;
  End;
End;

Procedure TForm36.Button8Click(Sender: TObject);
Var
  Nam: String;
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    nam := Edit8.Text;
    ComboBox2.Text := SelectDirectoryDialog1.FileName;
    ComboBox2Change(Nil);
    If Edit8.Text = '' Then Begin
      Edit8.Text := nam;
    End;
  End;
End;

Procedure TForm36.Button9Click(Sender: TObject);
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    ComboBox6.Text := SelectDirectoryDialog1.FileName;
  End;
End;

Procedure TForm36.ComboBox1Change(Sender: TObject);
Var
  lat, lon: Extended;
  index: integer;
  s: String;
  c: String;
Begin
  index := GetIndexOfLocation(ComboBox1.Text, false);
  If index = -1 Then exit;
  s := getvalue('Locations', 'Place' + inttostr(index), '');
  lat := strtofloat(copy(s, 1, pos('x', s) - 1), DefFormat);
  lon := strtofloat(copy(s, pos('x', s) + 1, length(s)), DefFormat);
  c := CoordToString(lat, lon);
  StringCoordToComboboxEdit(c, ComboBox4, edit5, ComboBox5, edit6);
End;

Procedure TForm36.ComboBox2Change(Sender: TObject);
Var
  s: String;
Begin
  s := edit8.text;
  edit8.text := getvalue('GPSExport', 'name' + inttostr(LocateGPSExportIndex(ComboBox2.Text)), '');
  If edit8.text = '' Then edit8.text := s;
End;

Procedure TForm36.ComboBox3Change(Sender: TObject);
Var
  s: String;
Begin
  s := edit12.text;
  edit12.text := getvalue('GPSImport', 'name' + inttostr(LocateImportGeocacheVisitsIndex(ComboBox3.Text)), '');
  If edit12.text = '' Then edit12.text := s;
End;

Procedure TForm36.ComboBox8Change(Sender: TObject);
Var
  s: String;
Begin
  s := edit10.text;
  edit10.text := getvalue('GPSSpoilerExport', 'name' + inttostr(LocateExportSpoilerIndex(ComboBox8.Text)), '');
  If edit10.text = '' Then edit10.text := s;
End;

Procedure TForm36.Edit1KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then Button2.Click;
End;

Procedure TForm36.FormCreate(Sender: TObject);
Begin
{$IFDEF Linux}
  edit13.Visible := false;
  Label25.Visible := false;
  Button13.Visible := false;
{$ENDIF}
End;

Procedure TForm36.Label6Click(Sender: TObject);
Begin
  lclintf.OpenURL('https://www.geocaching.com/account/settings/membership');
End;

Function TForm36.Start(index: integer): Boolean;
Var
  i: Integer;
Begin
  inc(wStep);
  PageControl1.ActivePage := PageControl1.Pages[index];
  // Nur einen Tab Aktiv schalten
  For i := 0 To PageControl1.PageCount - 1 Do Begin
    PageControl1.Pages[i].TabVisible := index = i;
  End;
  button1.Parent := PageControl1.Pages[index]; // Den Abbrechen Button implementieren wir nur 1 mal
  If Not Visible Then Begin
    FormShowModal(self, Nil);
    BringToFront;
    SetFocusedControl(form36);
  End;
  result := true;
End;

Function TForm36.DatabaseFilename: String;
Var
  p: String;
Begin
  result := '';
  If ListBox1.ItemIndex <> -1 Then Begin
    p := GetDataBaseDir();
    result := p + RemoveCacheCountInfo(ListBox1.Items[ListBox1.ItemIndex]) + '.db';
  End;
End;

Function TForm36.StartWizzard(ShowFinishHint, All, Reset: Boolean): boolean;
Var
  a, b: String;
  i: Integer;
  j: LongInt;
Begin
  (*
   * Die Idee dieser Routinie ist, dass sie der Reihe nach alles mögliche Abbrüft
   * Wird etwas gefunden, das eingestellt werden soll, so wird die entsprechende
   * page der PageControl1 mittels result := Start(Index) aktiviert und raus gesprungen.
   * andernfalls läuft sie mit false durch.
   *)
  result := false;
  wShowFinishHint := ShowFinishHint;
  wAll := All;
  If Reset Then WStep := 0;
{$IFDEF Windows}
  // Unter Windows prüfen wir SQLite3 ab
  a := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStrUTF8(0)));
  If Not FileExists(a + 'sqlite3.dll') Then Begin
    showmessage(R_you_did_not_install_sqlite_ccm_will_not_work_download_ccmsetup_zip_or_read_the_readme_txt_file);
    showmessage(R_ccm_will_close_now);
    halt;
  End;
  // Abprüfen SSL Library
  If (Not FileExists(a + 'libeay32.dll')) Or (Not FileExists(a + 'ssleay32.dll')) Then Begin
    showmessage(R_you_did_not_install_the_ssl_library_downloading_logging_and_cache_preview_will_not_work);
  End;
{$ENDIF}
  (*
   * !! ACHTUNG !!
   * Die Implementierungsreihenfolge der Folgenden Schritte wirkt sich direkt auf die
   * Reihenfolge der im Wizard abgefragten Elemente aus !
   * Wenn All Gesetzt ist wird die Index Reihenfolge Ausgewertet => Beide sollten also Gleich sein.
   *)
  // Verbunden mit Datenbank ?
  If (Not form1.SQLite3Connection1.Connected) Or (all And (wStep = Index_Select_Database)) Then Begin
    edit1.text := '';
    GetDBList(ListBox1.Items, '');
    ListBox1.ItemIndex := -1;
    If form1.SQLite3Connection1.Connected Then Begin
      a := ExtractFileNameOnly(form1.SQLite3Connection1.DatabaseName);
      For i := 0 To ListBox1.Items.Count - 1 Do Begin
        If RemoveCacheCountInfo(ListBox1.Items[i]) = a Then Begin
          ListBox1.ItemIndex := i;
          break;
        End;
      End;
    End;
    result := Start(Index_Select_Database);
    exit;
  End;
  //  Import Dir
  a := GetValue('General', 'LastImportDir', '');
  If (a = '') Or (Not DirectoryExistsUTF8(a)) Or (all And (wStep = Index_ImportDir)) Then Begin
    showmessage(R_You_need_to_define_a_folder);
    edit7.text := GetValue('General', 'LastImportDir', '');
    result := Start(Index_ImportDir);
    exit;
  End;
  // Distanzmessung
  a := getvalue('General', 'AktualLocation', '-1');
  If (a = '-1') Or (all And (wStep = Index_SetLocation)) Then Begin
    If id_yes = Application.MessageBox(pchar(R_Do_you_want_to_edit_distance_measurement_settings_for_caches), PChar(R_Question), mb_YesNo Or MB_ICONQUESTION) Then Begin
      ComboBox1.Clear;
      ComboBox1.Text := '';
      Edit5.text := '';
      Edit6.text := '';
      For i := 0 To strtointdef(getvalue('Locations', 'Count', '0'), 0) - 1 Do Begin
        ComboBox1.Items.Add(getvalue('Locations', 'Name' + inttostr(i), ''));
      End;
      ComboBox1.ItemIndex := strtoint(getvalue('General', 'AktualLocation', '-1'));
      ComboBox1Change(Nil);
      result := Start(Index_SetLocation);
      exit;
    End
    Else Begin
      setvalue('General', 'AktualLocation', '-2'); // -1 = undefiniert, >= 0 = Definiert, -2 = Aus
      wStep := Index_SetLocation + 1;
    End;
  End;
  // Username für Groundspeak oder ID nicht definiert (Password nicht !!)
  a := getvalue('General', 'UserName', '');
  b := getvalue('General', 'UserID', '');
  If ((a = '') And (b = '')) Or (all And (wStep = Index_Groundspeak_Settings)) Then Begin
    If id_yes = Application.MessageBox(pchar(R_Do_you_want_to_edit_your_groundspeak_account_settings), PChar(R_Question), mb_YesNo Or MB_ICONQUESTION) Then Begin
      edit2.Text := a;
      edit3.Text := b;
      result := Start(Index_Groundspeak_Settings);
      exit;
    End
    Else Begin
      setvalue('General', 'UserName', 'Dummy_Delete_me');
      setvalue('General', 'UserID', '0');
      setvalue('General', 'Logcount', '0');
      wStep := Index_Groundspeak_Settings + 1;
    End;
  End
  Else Begin
    If (a = '') Or (b = '') Then Begin
      showmessage(R_To_use_the_Groundspeak_Account_you_need_both_username_and_id);
      edit2.Text := a;
      edit3.Text := b;
      result := Start(Index_Groundspeak_Settings);
      exit;
    End;
  End;
  // LogCount, !! Achtung !! Nutzt initialisiertes a,b von Groundspeack Settings
  If (a <> '') And (b <> '') Then Begin
    // Der User plant online Logging zu verwenden
    If (getvalue('General', 'Logcount', '-1') = '-1') Or (all And (wStep = Index_logCount)) Then Begin // Hat der User bereits logs
      If id_yes = Application.MessageBox(pchar(R_Do_you_want_to_edit_the_logcounts_settings), PChar(R_Question), mb_YesNo Or MB_ICONQUESTION) Then Begin
        edit4.Text := getvalue('General', 'Logcount', '0');
        edit9.Text := getvalue('General', 'LogCountFormat', '# %d');
        result := Start(Index_logCount);
        exit;
      End
      Else Begin
        setvalue('General', 'Logcount', '0');
        wStep := Index_logCount + 1;
      End;
    End;
  End;
  // GPS Settings
  A := inttostr(ord(GetValue('GPSExport', 'Count', '0') = '0'));
  a := a + inttostr(ord(getvalue('GPSPOI', 'Count', '0') = '0'));
  a := a + inttostr(ord(GetValue('GPSImport', 'Count', '0') = '0'));
  If (pos('1', a) <> 0) Or (all And (wStep = Index_GPS_Settings)) Then Begin // Nichts zum Importieren / Exportieren definiert
    If id_yes = Application.MessageBox(pchar(R_Do_You_want_To_edit_a_GPS_settings), PChar(R_Question), mb_YesNo Or MB_ICONQUESTION) Then Begin
      edit13.text := getvalue('General', 'GPSBabelFolder', '');
      edit8.text := '';
      Edit12.Text := '';
      // GGZ Export Verzeichnisse
      ComboBox2.Items.Clear;
      ComboBox2.Text := '';
      j := strtointdef(getvalue('GPSExport', 'Count', '0'), 0);
      For i := 0 To j - 1 Do Begin
        ComboBox2.Items.Add(getValue('GPSExport', 'Folder' + inttostr(i), ''));
      End;
      If ComboBox2.Items.Count <> 0 Then Begin
        ComboBox2.ItemIndex := 0;
        edit8.text := getvalue('GPSExport', 'Name0', '0');
      End;
      // POI Verzeichnisse
      ComboBox6.Items.Clear;
      ComboBox6.Text := '';
      j := strtoint(getvalue('GPSPOI', 'Count', '0'));
      ComboBox6.Clear;
      For i := 0 To j - 1 Do Begin
        ComboBox6.Items.Add(getvalue('GPSPOI', 'Folder' + inttostr(i), ''));
      End;
      If ComboBox6.Items.Count <> 0 Then Begin
        ComboBox6.ItemIndex := 0;
      End;
      CheckBox1.Checked := false;
      j := strtoint(GetValue('Scripts', 'Count', '0'));
      ComboBox7.Items.Clear;
      ComboBox7.Text := '';
      For i := 0 To j - 1 Do Begin
        ComboBox7.Items.Add(FromSQLString(GetValue('Scripts', 'Name' + inttostr(i), '- - -')));
      End;
      // Geocache Visits Orte
      j := strtoint(GetValue('GPSImport', 'Count', '0'));
      ComboBox3.Items.Clear;
      ComboBox3.Text := '';
      For i := 0 To j - 1 Do Begin
        ComboBox3.Items.Add(FromSQLString(GetValue('GPSImport', 'Filename' + inttostr(i), '- - -')));
      End;
      If ComboBox3.Items.Count <> 0 Then Begin
        ComboBox3.ItemIndex := 0;
        edit12.text := getvalue('GPSImport', 'Name0', '0');
      End;
      result := Start(Index_GPS_Settings);
      exit;
    End
    Else Begin
      wStep := Index_Export_Spoiler + 1; // !! Bei Nein überspringen wir die Spoileranfrage ebenfalls (normalerweise stünde da Index_GPS_Settings + 1
      If GetValue('GPSExport', 'Count', '0') = '0' Then Begin
        setValue('GPSExport', 'Count', '-1');
      End;
      If getvalue('GPSPOI', 'Count', '0') = '0' Then Begin
        setvalue('GPSPOI', 'Count', '-1');
      End;
      If GetValue('GPSImport', 'Count', '0') = '0' Then Begin
        setValue('GPSImport', 'Count', '-1');
      End;
      If strtoint(GetValue('GPSSpoilerExport', 'Count', '0')) = 0 Then Begin
        SetValue('GPSSpoilerExport', 'Count', '-1');
      End;
    End;
  End;
  // Spoiler Settings, !! Achtung !! nutzt intialisiertes a von GPS-Settings
  If (pos('0', a) <> 0) Or (all And (wStep = Index_Export_Spoiler)) Then Begin // Nichts zum Importieren / Exportieren definiert
    If (strtoint(getvalue('GPSSpoilerExport', 'Count', '0')) = 0) Or (all And (wStep = Index_Export_Spoiler)) Then Begin
      If id_yes = Application.MessageBox(pchar(R_Do_You_want_To_edit_spoiler_downloading_settings), PChar(R_Question), mb_YesNo Or MB_ICONQUESTION) Then Begin
        edit10.text := '';
        ComboBox8.Clear;
        ComboBox8.Text := '';
        j := strtoint(GetValue('GPSSpoilerExport', 'Count', '0'));
        For i := 0 To j - 1 Do Begin
          ComboBox8.Items.Add(FromSQLString(GetValue('GPSSpoilerExport', 'Folder' + inttostr(i), '- - -')));
        End;
        If ComboBox8.Items.Count <> 0 Then Begin
          ComboBox8.ItemIndex := 0;
          edit10.text := getvalue('GPSSpoilerExport', 'Name0', '');
        End;
        result := Start(Index_Export_Spoiler);
        exit;
      End
      Else Begin
        // Der user will keine Spoiler Downloads haben, also Legen wir einen Dummy an, damit die Frage nie wieder kommt
        If strtoint(GetValue('GPSSpoilerExport', 'Count', '0')) = 0 Then Begin
          SetValue('GPSSpoilerExport', 'Count', '-1');
        End;
        wStep := Index_Export_Spoiler + 1;
      End;
    End;
  End;
  (*
   * Epilog
   *)
  If (all And (wstep = Index_Wizard)) Then Begin
    CheckBox8.Checked := GetValue('General', 'DisableWizard', '0') = '1';
    result := Start(Index_Wizard);
    exit;
  End;
  If ShowFinishHint Then Begin
    Showmessage(R_Wizard_finished_to_disable_go_to_the_Options_menu);
  End;
End;

End.

