Unit Unit3;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm3 }

  TForm3 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
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
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure CheckBox4Change(Sender: TObject);
    Procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Form3ShowWarningOnce: Boolean;
    Form3ShowMapWarningOnce: Boolean;
    Procedure CheckForNewVersion;
  End;

Var
  Form3: TForm3;

Implementation

{$R *.lfm}

Uses LCLType, ugctoolwrapper, uccm, unit1, ulanguage, LCLIntf;

{ TForm3 }

Procedure TForm3.FormCreate(Sender: TObject);
Begin
  caption := 'Options';
{$IFDEF Linux}
  edit12.Visible := false;
  Label13.Visible := false;
{$ENDIF}
End;

Procedure TForm3.CheckForNewVersion;
Var
  val: String;
Begin
  (*
   * Form1.CheckForNewVersion Sperrt sich derart, das es nur 1 mal Pro Tag aufgerufen werden kann
   * diese Sperrung hebeln wir hier bewußt aus, da der User ja explizit auf prüfen grdrückt hat.
   *)
  val := GetValue('General', 'CheckDailyForNewVersion', '1');
  setValue('General', 'CheckDailyForNewVersion', '1');
  setValue('General', 'LastCheckForNewVersion', '-');
  Form1.CheckForNewVersion(true);
  setValue('General', 'CheckDailyForNewVersion', val)
End;

Procedure TForm3.Button2Click(Sender: TObject);
Begin
  If (Edit8.Text <> '') Or (Edit11.Text <> '') Then Begin
    If ID_YES = Application.MessageBox(pchar(R_Store_Plain_Passwort_Warning), Pchar(R_Warning), MB_YESNO) Then Begin
      modalresult := mrOK;
    End;
  End
  Else Begin
    modalresult := mrOK;
  End;
End;

Procedure TForm3.Button3Click(Sender: TObject);
Var
  User, PW, PHost, PPort, PUser, PPW: String;
  finds: integer;
Begin
  // 1. Speicher aller Alter Daten
  User := getvalue('General', 'UserName', '');
  PW := getvalue('General', 'Password', '');
  PHost := getvalue('General', 'ProxyHost', '');
  PPort := getvalue('General', 'ProxyPort', '');
  PUser := getvalue('General', 'ProxyUser', '');
  PPW := getvalue('General', 'ProxyPass', '');
  // 1.1 Setzen neuer
  Setvalue('General', 'UserName', Edit1.text);
  setvalue('General', 'Password', edit11.text);
  setvalue('General', 'ProxyHost', edit5.text);
  setvalue('General', 'ProxyPort', edit6.text);
  setvalue('General', 'ProxyUser', edit7.text);
  setvalue('General', 'ProxyPass', edit8.text);
  // 2. Einlogg Versuch
  GCTLogOut;
  If GCTGetFoundNumber(finds) Then Begin
    showmessage(format(RF_Sucessfully_logged_in_Your_online_found_number_is, [finds]));
  End;
  // 3. Wieder Herstellen der Alten Daten
  GCTLogOut;
  Setvalue('General', 'UserName', User);
  setvalue('General', 'Password', PW);
  setvalue('General', 'ProxyHost', PHost);
  setvalue('General', 'ProxyPort', PPort);
  setvalue('General', 'ProxyUser', PUser);
  setvalue('General', 'ProxyPass', PPW);
End;

Procedure TForm3.Button4Click(Sender: TObject);
Begin
  // check Now
  If (getvalue('General', 'ProxyHost', '') <> edit5.text) Or
    (getvalue('General', 'ProxyPort', '') <> edit6.text) Or
    (getvalue('General', 'ProxyUser', '') <> edit7.text) Or
    (getvalue('General', 'ProxyPass', '') <> edit8.text) Then Begin
    showmessage(R_Proxy_settings_changed_please_save_options_first_and_then_try_again);
    exit;
  End;
  button4.Enabled := false; // das darf der User nur ein mal Pro App-Start machen..
  CheckForNewVersion;
End;

Procedure TForm3.Button5Click(Sender: TObject);
Var
  s: String;
Begin
  s := GetConfigFolder();
  If s = '' Then Begin
    showmessage(format(RF_Error_could_not_find, ['ccm.ini']));
  End
  Else Begin
    OpenURL(s);
  End;
End;

Procedure TForm3.CheckBox4Change(Sender: TObject);
Begin
  label20.Visible := CheckBox4.Checked;
  CheckBox5.Visible := CheckBox4.Checked;
End;

Procedure TForm3.ComboBox2Change(Sender: TObject);
Begin
  (*
   * Die Ulanguage.pas kann auch eine Sprachumschaltung zur Laufzeit.
   * Das Problem ist aber, wenn die Sprache zur Laufzeit geändert wird,
   * das dann alle zur laufzeit erstellten Untermenüs (vom User) alle auch
   * übersetzt werden wollten.
   * Das allein ist erst mal kein Problem, löscht der User nun aber einen Eintrag
   * und erstellt an selber Stelle einen neuen, dann kann es sein das dieser
   * mit dem Alten Text angezeigt wird (nämlich dann, wenn der Benutzer nach
   * der Änderung die Sprache wechselt).
   * Durch das Erzwingen des Neustarts kommen wir in diese Falle nicht, da die
   * Sprache stets initialisiert wird bevor dir Custom Menüs erzeugt werden !!
   *)
  If Form3ShowWarningOnce Then Begin
    showmessage(R_Please_save_and_restart_the_application_to_apply_language_changes);
    Form3ShowWarningOnce := false;
  End;
End;

procedure TForm3.ComboBox3Change(Sender: TObject);
begin
  If Form3ShowMapWarningOnce Then Begin
    showmessage(R_Please_clear_cache_for_maptiles);
    Form3ShowMapWarningOnce := false;
  End;
end;

End.

