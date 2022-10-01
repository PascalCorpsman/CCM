Unit unit27;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterSQL, Forms, Controls,
  Graphics, Dialogs, StdCtrls;

Const
  Script_Select_Database = 0;
  Script_Prompt_Database = 1;
  Script_Create_Database = 2;
  Script_Create_Database_From_GSAK_GPX = 3;
  Script_Del_Database = 4;
  Script_Prompt_Directory = 5;
  Script_Import_directory = 6;
  Script_Exec_Filter_Query = 7;
  Script_Exec_SQL_Query = 8;
  Script_Exec_SQL_Transaction = 9;
  Script_Select_cut_set_to_database = 10;
  Script_Copy_selection_to_database = 11;
  Script_Move_selection_to_database = 12;
  Script_Delete_selection = 13;
  Script_Mark_selection_as_archived = 14;
  Script_Export_as_pocket_query = 15;
  Script_Export_as_GSAK_GPX = 16;
  Script_Export_selection_to_as_ggz = 17;
  Script_Export_selection_to_as_poi = 18;
  Script_Call_Script = 19;
  Script_Showmessage = 20;
  Script_Show_yes_no_question = 21;
  Script_ReDownloadListing = 22;

Type
  TItem = Record
    tp: integer;
    data: TStringList;
  End;

  { TForm27 }

  TForm27 = Class(TForm)
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
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListBox1: TListBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SynEdit1: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
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
    Procedure ComboBox1Change(Sender: TObject);
    Procedure ComboBox2Change(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure ListBox1Click(Sender: TObject);
  private
    Function SetSkriptIndex(Script_name: String; Type_, index: integer): Boolean;
    Function GetItem(Script_name: String; index: integer): Titem;
    Procedure SetItem(Script_name: String; index: integer; item: Titem);
    Procedure CreateSkriptIndex(SkriptName: String);
  public
    Procedure ReloadScriptCombobox;
    Procedure LoadScriptToListbox;
    Function SkriptIndexCaption(Script_name: String; index: integer): String;
  End;

Var
  Form27: TForm27;

Implementation

{$R *.lfm}

Uses
  usqlite_helper,
  uccm,
  Unit1, // Hauptfenster
  Unit18, // Skript Editor online Hilfe
  Unit28, // Dialog Script überschreiben ?
  LCLType,
  IniFiles,
  ulanguage
  ;

{ TForm27 }

Procedure TForm27.ReloadScriptCombobox;
Var
  i: Integer;
Begin
  ComboBox1.Items.Clear;
  For i := 0 To strtoint(getvalue('Scripts', 'Count', '0')) - 1 Do Begin
    ComboBox1.Items.Add(FromSQLString(getvalue('Scripts', 'Name' + inttostr(i), '')));
  End;
  ComboBox1.Text := '';
  ListBox1.Clear;
End;

Procedure TForm27.Button8Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm27.ComboBox1Change(Sender: TObject);
Begin
  LoadScriptToListbox;
End;

Procedure TForm27.Button4Click(Sender: TObject);
Var
  item1, item2: TItem;
  Script_name: String;
Begin
  // Move Up
  If ListBox1.ItemIndex <= 0 Then exit;
  Script_name := ToSQLString(trim(ComboBox1.Text));
  item1 := Getitem(Script_name, ListBox1.ItemIndex);
  item2 := Getitem(Script_name, ListBox1.ItemIndex - 1);
  Setitem(Script_name, ListBox1.ItemIndex, item2);
  Setitem(Script_name, ListBox1.ItemIndex - 1, item1);
  ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
  item1.data.free;
  item2.data.free;
End;

Procedure TForm27.Button3Click(Sender: TObject);
Var
  c, i, j: integer;
  Script_name, sn: String;
Begin
  // Del Skript
  Script_name := ToSQLString(trim(ComboBox1.Text));
  // Schauen ob ein Skript ungültig wird
  For i := 0 To StrToInt(getvalue('Scripts', 'Count', '0')) - 1 Do Begin
    sn := getvalue('Scripts', 'Name' + inttostr(i), '');
    For j := 0 To strtoint(GetValue('Script_' + sn, 'Count', '0')) - 1 Do Begin
      If getvalue('Script_' + sn, 'Type' + inttostr(j), '') = inttostr(Script_Call_Script) Then Begin
        If ComboBox1.Text = GetValue('Script_' + sn, 'script_name' + IntToStr(j), '') Then Begin
          If id_no = Application.MessageBox(pchar(
            format(RF_Deleting_the_script_will_leave_invalid_state, [ComboBox1.Text, FromSQLString(sn), ComboBox1.Text])
            ), pchar(R_Warning), MB_YESNO Or MB_ICONWARNING) Then Begin
            exit;
          End;
          break;
        End;
      End;
    End;
  End;
  // Das eigentliche Löschen
  c := strtoint(GetValue('Scripts', 'Count', '0'));
  For i := 0 To c - 1 Do Begin
    If getvalue('Scripts', 'Name' + IntToStr(i), '') = Script_name Then Begin
      SetValue('Scripts', 'Count', inttostr(c - 1));
      For j := i To c - 1 Do Begin
        setvalue('Scripts', 'Name' + IntToStr(j), getvalue('Scripts', 'Name' + IntToStr(j + 1), ''))
      End;
      DeleteSection('Script_' + Script_name);
      DeleteValue('Scripts', 'Name' + inttostr(c - 1));
      ComboBox1.Items.Delete(i);
      ListBox1.Clear;
      ListBox1.ItemIndex := -1;
      ComboBox1.Text := '';
      ComboBox1Change(Nil);
      exit;
    End;
  End;
End;

Procedure TForm27.Button1Click(Sender: TObject);
Var
  ini: tinifile;

  Procedure CloneSectionToIni(SectionName: String);
  Var
    i, j: integer;
  Begin
    If Not SectionExists(SectionName) Then Begin
      showmessage(format(RF_Error_could_not_export_section, [SectionName]));
      exit;
    End;
    ini.WriteString(SectionName, 'Count', GetValue(SectionName, 'Count', ''));
    For i := 0 To strtoint(GetValue(SectionName, 'Count', '')) - 1 Do Begin
      ini.WriteString(SectionName, 'Type' + inttostr(i), GetValue(SectionName, 'Type' + inttostr(i), ''));
      Case strtoint(GetValue(SectionName, 'Type' + inttostr(i), '')) Of
        Script_ReDownloadListing,
          Script_Mark_selection_as_archived,
          Script_Delete_selection,
          Script_Prompt_Directory,
          Script_Prompt_Database: Begin
          End;
        Script_Move_selection_to_database,
          Script_Copy_selection_to_database,
          Script_Select_cut_set_to_database,
          Script_Del_Database,
          Script_Create_Database,
          Script_Select_Database: ini.WriteString(SectionName, 'database' + inttostr(i), GetValue(SectionName, 'database' + inttostr(i), ''));
        Script_Export_as_GSAK_GPX,
          Script_Export_as_pocket_query,
          Script_Create_Database_From_GSAK_GPX: ini.WriteString(SectionName, 'Filename' + inttostr(i), GetValue(SectionName, 'Filename' + inttostr(i), ''));
        Script_Import_directory: Begin
            ini.WriteString(SectionName, 'Directory' + inttostr(i), GetValue(SectionName, 'Directory' + inttostr(i), ''));
            ini.WriteString(SectionName, 'NotImportFound' + inttostr(i), GetValue(SectionName, 'NotImportFound' + inttostr(i), ''));
            ini.WriteString(SectionName, 'DelAfterImport' + inttostr(i), GetValue(SectionName, 'DelAfterImport' + inttostr(i), ''));
          End;
        Script_Exec_Filter_Query: Begin
            ini.WriteString(SectionName, 'search' + inttostr(i), GetValue(SectionName, 'search' + inttostr(i), ''));
            ini.WriteString(SectionName, 'distance' + inttostr(i), GetValue(SectionName, 'distance' + inttostr(i), ''));
            ini.WriteString(SectionName, 'filter' + inttostr(i), GetValue(SectionName, 'filter' + inttostr(i), ''));
            // Alle Beteiligten Queries werden vorsichtshalber auch mit Exportiert.
            For j := 0 To strtoint(GetValue('Queries', 'Count', '')) - 1 Do Begin
              If GetValue(SectionName, 'filter' + inttostr(i), '') = GetValue('Queries', 'Name' + inttostr(j), '') Then Begin
                ini.WriteString('Queries', GetValue(SectionName, 'filter' + inttostr(i), ''), GetValue('Queries', 'Query' + inttostr(j), ''));
                break;
              End;
            End;
          End;
        Script_Exec_SQL_Query: ini.WriteString(SectionName, 'Query' + inttostr(i), GetValue(SectionName, 'Query' + inttostr(i), ''));
        Script_Exec_SQL_Transaction: ini.WriteString(SectionName, 'transaction' + inttostr(i), GetValue(SectionName, 'transaction' + inttostr(i), ''));
        Script_Export_selection_to_as_poi,
          Script_Export_selection_to_as_ggz: ini.WriteString(SectionName, 'Folder' + inttostr(i), GetValue(SectionName, 'Folder' + inttostr(i), ''));
        Script_Call_Script: Begin
            ini.WriteString(SectionName, 'script_name' + inttostr(i), GetValue(SectionName, 'script_name' + inttostr(i), ''));
            If Not ini.SectionExists(GetValue(SectionName, 'script_name' + inttostr(i), '')) Then Begin // Verhindert ne Rekursion
              CloneSectionToIni('Script_' + GetValue(SectionName, 'script_name' + inttostr(i), ''));
            End;
          End;
        Script_Showmessage: ini.WriteString(SectionName, 'Text' + inttostr(i), GetValue(SectionName, 'Text' + inttostr(i), ''));
        Script_Show_yes_no_question: Begin
            ini.WriteString(SectionName, 'Text' + inttostr(i), GetValue(SectionName, 'Text' + inttostr(i), ''));
            ini.WriteString(SectionName, 'OnYes' + inttostr(i), GetValue(SectionName, 'OnYes' + inttostr(i), ''));
            ini.WriteString(SectionName, 'OnNo' + inttostr(i), GetValue(SectionName, 'OnNo' + inttostr(i), ''));
          End;
      Else Begin
          showmessage('TForm27.Button1Click.CloneSectionToIni, missing case ' + GetValue(SectionName, 'Type' + inttostr(i), ''));
        End;
      End;
    End;
  End;

Var
  i: integer;
  sn: String;
  b: Boolean;
Begin
  // Export Skript
  b := false;
  sn := ToSQLString(ComboBox1.Text);
  For i := 0 To StrToInt(getvalue('Scripts', 'Count', '0')) - 1 Do Begin
    If GetValue('Scripts', 'Name' + IntToStr(i), '') = sn Then Begin
      b := true;
      break;
    End;
  End;
  If (Not b) Or (trim(sn) = '') Then Begin
    showmessage(R_Noting_Selected);
    exit;
  End;
  If Not SaveDialog1.Execute Then exit;
  ini := TIniFile.Create(SaveDialog1.FileName);
  ini.WriteString('Script', 'Name', sn);
  CloneSectionToIni('Script_' + sn);
  ini.free;
  ShowMessage(R_Finished);
End;

Procedure TForm27.Button10Click(Sender: TObject);
Begin
  // Online Hilfe
  form18.Show;
End;

Procedure TForm27.Button2Click(Sender: TObject);
  Function SkriptExists(Scriptname: String): Boolean;
  Var
    i: Integer;
  Begin
    result := false;
    For i := 0 To strtoint(getvalue('Scripts', 'Count', '0')) - 1 Do Begin
      If GetValue('Scripts', 'Name' + inttostr(i), '') = Scriptname Then Begin
        result := true;
        break;
      End;
    End;
  End;

  // Result = -1, nicht gefunden, sonst die Nummer
  Function GetFilterindex(Filtername: String): integer;
  Var
    i: Integer;
  Begin
    result := -1;
    For i := 0 To strtoint(getvalue('Queries', 'Count', '0')) - 1 Do Begin
      If getValue('Queries', 'Name' + inttostr(i), '') = Filtername Then Begin
        result := i;
        exit;
      End;
    End;
  End;

Var
  ini: TIniFile;

  Function ImportScript(Scriptname: String): String;
  Var
    i, j: Integer;
    SourceScript, DestScript: String;
  Begin
    Result := Scriptname;
    If SkriptExists(Scriptname) Then Begin
      // Todo: Besonders Cool wäre hier natürlich, ob man Prüfen kann
      // Ob das zu Überschreibende Script Identisch zu dem existierenden ist, und wenn ja einfach nichts zu machen
      // Dazu müsste auf "Section" ebene verglichen werden (notfalls auch Rekursiv)..
      form28.label1.caption := R_Script_already_exists_enter_new_name_or_overwrite;
      form28.ModalResult := 0;
      form28.Edit1.Text := FromSQLString(Scriptname);
      FormShowModal(form28, self);
      If form28.ModalResult = mrOK Then Begin
        If SkriptExists(ToSQLString(form28.Edit1.Text)) Then Begin
          If ID_NO = Application.MessageBox(pchar('Script "' + form28.Edit1.Text + '" already exists, overwrite it ?'), 'Warning', MB_YESNO Or MB_ICONQUESTION) Then Begin
            ini.free;
            exit;
          End;
        End;
        Result := ToSQLString(form28.Edit1.Text);
      End
      Else Begin
        // Der User hat abgebrochen, also Leer und raus
        result := '';
        exit;
      End;
    End;
    SourceScript := 'Script_' + Scriptname;
    DestScript := 'Script_' + result;
    CreateSkriptIndex(Result);
    SetValue(DestScript, 'Count', ini.ReadString(SourceScript, 'Count', ''));
    For i := 0 To ini.ReadInteger(SourceScript, 'Count', 0) - 1 Do Begin
      SetValue(DestScript, 'Type' + inttostr(i), ini.ReadString(SourceScript, 'Type' + inttostr(i), ''));
      Case ini.ReadInteger(SourceScript, 'Type' + inttostr(i), -1) Of
        Script_Mark_selection_as_archived,
          Script_ReDownloadListing,
          Script_Delete_selection,
          Script_Prompt_Directory,
          Script_Prompt_Database: Begin
          End;
        Script_Move_selection_to_database,
          Script_Copy_selection_to_database,
          Script_Select_cut_set_to_database,
          Script_Del_Database,
          Script_Create_Database,
          Script_Select_Database: SetValue(DestScript, 'database' + inttostr(i), ini.ReadString(SourceScript, 'database' + IntToStr(i), ''));
        Script_Export_as_GSAK_GPX,
          Script_Export_as_pocket_query,
          Script_Create_Database_From_GSAK_GPX: SetValue(DestScript, 'Filename' + inttostr(i), ini.ReadString(SourceScript, 'Filename' + IntToStr(i), ''));
        Script_Import_directory: Begin
            SetValue(DestScript, 'Directory' + inttostr(i), ini.ReadString(SourceScript, 'Directory' + IntToStr(i), ''));
            SetValue(DestScript, 'NotImportFound' + inttostr(i), ini.ReadString(SourceScript, 'NotImportFound' + IntToStr(i), ''));
            SetValue(DestScript, 'DelAfterImport' + inttostr(i), ini.ReadString(SourceScript, 'DelAfterImport' + IntToStr(i), ''));
          End;
        Script_Exec_Filter_Query: Begin
            SetValue(DestScript, 'search' + inttostr(i), ini.ReadString(SourceScript, 'search' + IntToStr(i), ''));
            SetValue(DestScript, 'distance' + inttostr(i), ini.ReadString(SourceScript, 'distance' + IntToStr(i), ''));
            SetValue(DestScript, 'filter' + inttostr(i), ini.ReadString(SourceScript, 'filter' + IntToStr(i), ''));
            // den Filter müssen wir ja noch imporieren ..
            j := GetFilterindex(ini.ReadString(SourceScript, 'filter' + IntToStr(i), ''));
            If j = -1 Then Begin
              j := strtoint(getvalue('Queries', 'Count', '0'));
              SetValue('Queries', 'Name' + inttostr(j), ini.ReadString(SourceScript, 'filter' + IntToStr(i), ''));
              SetValue('Queries', 'Query' + inttostr(j), ini.ReadString('Queries', ini.ReadString(SourceScript, 'filter' + IntToStr(i), ''), ''));
              Setvalue('Queries', 'Count', inttostr(strtoint(getvalue('Queries', 'Count', '0')) + 1));
            End
            Else Begin
              // Wenn die beiden hinterlegten Queries unterschiedlich sind
              If lowercase(trim(ini.ReadString('Queries', ini.ReadString(SourceScript, 'filter' + IntToStr(i), ''), ''))) <>
                lowercase(trim(GetValue('Queries', 'Query' + inttostr(j), ''))) Then Begin
                form28.label1.caption := R_Filter_already_exists_enter_new_name_or_overwrite;
                form28.ModalResult := 0;
                form28.Edit1.Text := ini.ReadString(SourceScript, 'filter' + IntToStr(i), '');
                FormShowModal(form28, self);
                If form28.ModalResult = mrOK Then Begin
                  j := GetFilterindex(form28.Edit1.Text);
                  If j <> -1 Then Begin
                    If ID_YES = Application.MessageBox(pchar(format(RF_Filter_already_exists_overwrite_it, [form28.Edit1.Text])), pchar(R_Warning), MB_YESNO Or MB_ICONQUESTION) Then Begin
                      SetValue('Queries', 'Query' + inttostr(j), ini.ReadString('Queries', ini.ReadString(SourceScript, 'filter' + IntToStr(i), ''), ''));
                    End;
                    // Das Skript soll überschrieben werden
                    SetValue(DestScript, 'filter' + inttostr(i), form28.Edit1.Text);
                  End
                  Else Begin
                    // Der Filter wurde "umbenannt" dann adden wir ihn und setzen entsprechend den Filternamen um
                    j := strtoint(getvalue('Queries', 'Count', '0'));
                    SetValue('Queries', 'Name' + inttostr(j), form28.Edit1.Text);
                    SetValue('Queries', 'Query' + inttostr(j), ini.ReadString('Queries', ini.ReadString(SourceScript, 'filter' + IntToStr(i), ''), ''));
                    Setvalue('Queries', 'Count', inttostr(strtoint(getvalue('Queries', 'Count', '0')) + 1));
                    SetValue(DestScript, 'filter' + inttostr(i), form28.Edit1.Text);
                  End;
                End
                Else Begin
                  // Der User hat Abbrechen Geklickt, dann lassen wir den falschen Filter stehen..
                End;
              End;
            End;
          End;
        Script_Exec_SQL_Query: SetValue(DestScript, 'Query' + inttostr(i), ini.ReadString(SourceScript, 'Query' + IntToStr(i), ''));
        Script_Exec_SQL_Transaction: SetValue(DestScript, 'transaction' + inttostr(i), ini.ReadString(SourceScript, 'transaction' + IntToStr(i), ''));
        Script_Export_selection_to_as_poi,
          Script_Export_selection_to_as_ggz: SetValue(DestScript, 'Folder' + inttostr(i), ini.ReadString(SourceScript, 'Folder' + IntToStr(i), ''));
        Script_Call_Script: Begin
            SetValue(DestScript, 'script_name' + inttostr(i), ImportScript(ini.ReadString(SourceScript, 'script_name' + IntToStr(i), '')));
          End;
        Script_Showmessage: SetValue(DestScript, 'Text' + inttostr(i), ini.ReadString(SourceScript, 'Text' + IntToStr(i), ''));
        Script_Show_yes_no_question: Begin
            SetValue(DestScript, 'Text' + inttostr(i), ini.ReadString(SourceScript, 'Text' + IntToStr(i), ''));
            SetValue(DestScript, 'OnYes' + inttostr(i), ini.ReadString(SourceScript, 'OnYes' + IntToStr(i), ''));
            SetValue(DestScript, 'OnNo' + inttostr(i), ini.ReadString(SourceScript, 'OnNo' + IntToStr(i), ''));
          End;
      Else Begin
          showmessage('TForm27.Button2Click.ImportScript, missing case ' + ini.ReadString(SourceScript, 'Type' + inttostr(i), ''));
        End;
      End;
    End;
  End;

Var
  sn: String;
Begin
  // Import Script
  If Not OpenDialog1.Execute Then exit;
  ini := TIniFile.Create(OpenDialog1.FileName);
  sn := ini.ReadString('Script', 'Name', '');
  If sn = '' Then Begin
    ShowMessage(R_Noting_Selected);
    ini.free;
    exit;
  End;
  // Gibt es das Script schon ?
  ImportScript(sn);
  Form1.CreateFilterMenu;
  ini.Free;
End;

Procedure TForm27.Button5Click(Sender: TObject);
Var
  Script_name: String;
  index, cnt, i: integer;
Begin
  // Del command
  Script_name := ToSQLString(trim(ComboBox1.Text));
  If listbox1.ItemIndex = ListBox1.Items.Count - 1 Then Begin
    cnt := strtoint(GetValue('Script_' + Script_name, 'Count', '1'));
    SetValue('Script_' + Script_name, 'Count', inttostr(cnt - 1));
    ListBox1.Items.Delete(ListBox1.Items.Count - 1);
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  End
  Else Begin
    // Löschen aus der Mitte
    index := listbox1.ItemIndex;
    For i := listbox1.ItemIndex To ListBox1.Items.Count - 2 Do Begin
      // Laden des nächsten Datensatzes
      ListBox1.ItemIndex := i + 1;
      ListBox1Click(Nil);
      If Not (SetSkriptIndex(Script_name, ComboBox2.ItemIndex, i)) Then Begin
        showmessage(R_Error_could_not_set_index_restart_application_and_double_check_all_values);
      End;
      ListBox1.Items[i] := ListBox1.Items[i + 1];
    End;
    cnt := strtoint(GetValue('Script_' + Script_name, 'Count', '1'));
    SetValue('Script_' + Script_name, 'Count', inttostr(cnt - 1));
    ListBox1.Items.Delete(ListBox1.Items.Count - 1);
    ListBox1.ItemIndex := index;
    ListBox1Click(Nil);
  End;
End;

Procedure TForm27.Button6Click(Sender: TObject);
Var
  item1, item2: TItem;
  Script_name: String;
Begin
  // Move down
  If ListBox1.ItemIndex >= ListBox1.Items.Count - 1 Then exit;
  Script_name := ToSQLString(trim(ComboBox1.Text));
  item1 := Getitem(Script_name, ListBox1.ItemIndex);
  item2 := Getitem(Script_name, ListBox1.ItemIndex + 1);
  Setitem(Script_name, ListBox1.ItemIndex, item2);
  Setitem(Script_name, ListBox1.ItemIndex + 1, item1);
  ListBox1.ItemIndex := ListBox1.ItemIndex + 1;
  item1.data.free;
  item2.data.free;
End;

Procedure TForm27.Button9Click(Sender: TObject);
Var
  c: integer;
  sn: String;
Begin
  // Overwrite Step
  If ComboBox1.Text = '' Then Begin
    ShowMessage(R_No_Script_name_defined);
    exit;
  End;
  sn := ToSQLString(trim(ComboBox1.Text));
  // Anzahl der "Befehle" pro Skript um eins erhöhen
  c := ListBox1.ItemIndex;
  If Not (SetSkriptIndex(sn, ComboBox2.ItemIndex, c)) Then Begin
    showmessage(R_Error_could_not_set_index_restart_application_and_double_check_all_values);
  End;
End;

Procedure TForm27.CreateSkriptIndex(SkriptName: String);
Var
  i, c: integer;
Begin
  c := strtoint(GetValue('Scripts', 'Count', '0'));
  // Das script gibt es => Index davon Rausgeben
  For i := 0 To c - 1 Do Begin
    If getvalue('Scripts', 'Name' + IntToStr(i), '') = SkriptName Then Begin
      exit;
    End;
  End;
  // Das Skript gibt es noch nicht => anlegen
  setvalue('Scripts', 'Count', inttostr(c + 1));
  setvalue('Scripts', 'Name' + IntToStr(c), SkriptName);
  ComboBox1.Items.Add(FromSQLString(SkriptName));
End;

Procedure TForm27.Button7Click(Sender: TObject);
Var
  c: integer;
  sn: String;
Begin
  // Add Step
  If ComboBox1.Text = '' Then Begin
    ShowMessage(R_No_Script_name_defined);
    exit;
  End;
  sn := ToSQLString(trim(ComboBox1.Text));
  CreateSkriptIndex(sn);
  // Anzahl der "Befehle" pro Skript um eins erhöhen
  c := strtoint(getvalue('Script_' + sn, 'Count', '0'));
  setvalue('Script_' + sn, 'Count', inttostr(c + 1));
  Listbox1.items.add('');
  If Not (SetSkriptIndex(sn, ComboBox2.ItemIndex, c)) Then Begin
    setvalue('Script_' + sn, 'Count', inttostr(c)); // Wieder Rückgängig machen
    Listbox1.items.Delete(ListBox1.Items.Count - 1);
  End;
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;
End;

Procedure TForm27.ListBox1Click(Sender: TObject);
Var
  index, tp: integer;
  Script_name: String;
Begin
  If ListBox1.ItemIndex <> -1 Then Begin
    Script_name := ToSQLString(ComboBox1.Text);
    tp := strtoint(getvalue('Script_' + Script_name, 'Type' + inttostr(ListBox1.ItemIndex), '-1'));
    index := ListBox1.ItemIndex;
    ComboBox2.ItemIndex := tp;
    ComboBox2Change(Nil);
    Case tp Of
      Script_Select_cut_set_to_database,
        Script_Copy_selection_to_database,
        Script_Move_selection_to_database,
        Script_Select_Database,
        Script_Create_Database,
        Script_Del_Database: combobox5.text := getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
      Script_ReDownloadListing,
        Script_Delete_selection,
        Script_Mark_selection_as_archived,
        Script_Prompt_Database,
        Script_Prompt_Directory: Begin // Nichts in und her zu kopieren
        End;
      Script_Export_selection_to_as_ggz,
        Script_Export_selection_to_as_poi: ComboBox5.text := getvalue('Script_' + Script_name, 'folder' + inttostr(index), '');
      Script_Export_as_pocket_query,
        Script_Create_Database_From_GSAK_GPX,
        Script_Export_as_GSAK_GPX: edit1.text := getvalue('Script_' + Script_name, 'filename' + inttostr(index), '');
      Script_Import_directory: Begin
          edit1.text := getvalue('Script_' + Script_name, 'Directory' + inttostr(index), '');
          CheckBox1.Checked := getvalue('Script_' + Script_name, 'NotImportFound' + inttostr(index), '0') = '1';
          CheckBox2.Checked := getvalue('Script_' + Script_name, 'DelAfterImport' + inttostr(index), '0') = '1';
        End;
      Script_Exec_SQL_Query: Begin
          SynEdit1.Text := FromSQLString(getvalue('Script_' + Script_name, 'Query' + inttostr(index), ''));
        End;
      Script_Exec_Filter_Query: Begin
          Edit1.text := getvalue('Script_' + Script_name, 'search' + inttostr(index), '');
          edit2.text := getvalue('Script_' + Script_name, 'distance' + inttostr(index), '');
          combobox4.text := getvalue('Script_' + Script_name, 'filter' + inttostr(index), '');
        End;
      Script_Exec_SQL_Transaction: Begin
          SynEdit1.Text := FromSQLString(getvalue('Script_' + Script_name, 'transaction' + inttostr(index), ''));
        End;
      Script_Call_Script: Begin
          ComboBox5.Text := getvalue('Script_' + Script_name, 'script_name' + inttostr(index), '');
        End;
      Script_Showmessage: Begin
          edit1.text := FromSQLString(getvalue('Script_' + Script_name, 'Text' + inttostr(index), ''));
        End;
      Script_Show_yes_no_question: Begin
          edit1.text := FromSQLString(getvalue('Script_' + Script_name, 'Text' + inttostr(index), ''));
          ComboBox3.ItemIndex := strtoint(getvalue('Script_' + Script_name, 'OnYes' + inttostr(index), '0'));
          ComboBox4.ItemIndex := strtoint(getvalue('Script_' + Script_name, 'OnNo' + inttostr(index), '0'));
        End;
    Else Begin
        showmessage('TForm27.ListBox1Click, missing case ' + inttostr(tp));
      End;
    End;
  End;
End;

Procedure TForm27.FormCreate(Sender: TObject);
Begin
  caption := 'Script Editor';
  ComboBox1.Text := '';
  (*
   * Allgemeingültige Variablen : $importdir$
   *)
  ComboBox2.items.clear;
  (*
   * Wenn sich hier was ändert, dann oben die Constanten auch anpassen !!
   *)
  ComboBox2.items.Add('Select database '); //                0
  ComboBox2.items.Add('Prompt database'); //                 1 -> $promptdatabase$
  ComboBox2.items.Add('Create database'); //                 2
  ComboBox2.items.Add('Create database from GSAK GPX'); //   3
  ComboBox2.items.Add('Del database'); //                    4
  ComboBox2.items.Add('Prompt directory'); //                5 -> $promptdir$
  ComboBox2.items.Add('Import directory'); //                6
  ComboBox2.items.Add('Exec Filter Query'); //               7
  ComboBox2.items.Add('Exec SQL Query'); //                  8
  ComboBox2.items.Add('Exec SQL Transaction'); //            9
  ComboBox2.items.Add('Select cut set to database'); //     10
  ComboBox2.items.Add('Copy selection to database'); //     11
  ComboBox2.items.Add('Move selection to database'); //     12
  ComboBox2.items.Add('Delete selection'); //               13
  ComboBox2.items.Add('Mark Selection as archived'); //     14
  ComboBox2.items.Add('Export as pocket query'); //         15
  ComboBox2.items.Add('Export as GSAK GPX'); //             16
  ComboBox2.items.Add('Export selection to (as GGZ)'); //   17
  ComboBox2.items.Add('Export selection to (as POI)'); //   18
  ComboBox2.items.Add('Call Script'); //                    19
  ComboBox2.items.Add('Showmessage'); //                    20
  ComboBox2.items.Add('Show Yes No question'); //           21
  ComboBox2.items.Add('Redownload listings'); //            22
  ComboBox2.ItemIndex := -1;
  ComboBox2Change(Nil);
End;

Procedure TForm27.ComboBox2Change(Sender: TObject);
Var
  i: integer;
Begin
  // Erst mal alles Ab schalten
  label4.Visible := false;
  label5.Visible := false;
  label6.Visible := false;
  edit1.Visible := false;
  edit2.Visible := false;
  CheckBox1.Visible := false;
  CheckBox2.Visible := false;
  ComboBox3.Visible := false;
  ComboBox4.Visible := false;
  ComboBox5.Style := csDropDown;
  ComboBox5.Visible := false;
  SynEdit1.Visible := false;
  //  Es fehlen noch die Features zum Automatischen Archivieren ?
  Case ComboBox2.ItemIndex Of
    Script_Select_cut_set_to_database,
      Script_Copy_selection_to_database,
      Script_Move_selection_to_database,
      Script_Select_Database,
      Script_Create_Database,
      Script_Del_Database: Begin // Select, Create, Del Database
        label4.Caption := R_Database;
        ComboBox5.Text := '';
        GetDBList(ComboBox5.Items, '');
        For i := 0 To ComboBox5.Items.Count - 1 Do Begin
          ComboBox5.Items[i] := RemoveCacheCountInfo(ComboBox5.Items[i]);
        End;
        ComboBox5.Items.add('$database$');
        ComboBox5.Items.add('$promptdatabase$');
        label4.Visible := true;
        ComboBox5.Visible := true;
      End;
    -1,
      Script_ReDownloadListing,
      Script_Delete_selection,
      Script_Mark_selection_as_archived,
      Script_Prompt_Database,
      Script_Prompt_Directory: Begin // Alles Ausblenden
      End;
    Script_Export_selection_to_as_poi: Begin
        label4.caption := R_Folder;
        label4.visible := True;
        ComboBox5.Text := '';
        ComboBox5.Items.Clear;
        For i := 0 To strtoint(getvalue('GPSPOI', 'Count', '0')) - 1 Do Begin
          ComboBox5.Items.Add(GetValue('GPSPOI', 'Folder' + inttostr(i), ''));
        End;
        ComboBox5.Visible := true;
      End;
    Script_Export_selection_to_as_ggz: Begin
        label4.caption := R_Folder;
        label4.visible := True;
        ComboBox5.Text := '';
        ComboBox5.Items.Clear;
        For i := 0 To strtoint(getvalue('GPSExport', 'Count', '0')) - 1 Do Begin
          ComboBox5.Items.Add(GetValue('GPSExport', 'Folder' + inttostr(i), ''));
        End;
        ComboBox5.Visible := true;
      End;
    Script_Export_as_pocket_query,
      Script_Create_Database_From_GSAK_GPX,
      Script_Export_as_GSAK_GPX: Begin
        label4.caption := R_Filename;
        edit1.text := '';
        label4.visible := True;
        edit1.visible := true;
      End;
    Script_Import_directory: Begin
        label4.caption := R_Folder;
        edit1.text := '';
        CheckBox1.Caption := R_Do_not_import_found_caches;
        CheckBox2.Caption := R_Delete_files_after_import;
        label4.Visible := true;
        edit1.Visible := true;
        CheckBox1.Visible := true;
        CheckBox2.Visible := true;
      End;
    Script_Exec_Filter_Query: Begin
        edit1.text := '';
        edit2.text := '';
        ComboBox4.Clear;
        ComboBox4.Items.Add('-');
        For i := 0 To strtoint(getvalue('Queries', 'Count', '0')) - 1 Do Begin
          ComboBox4.Items.Add(getvalue('Queries', 'Name' + inttostr(i), ''));
        End;
        ComboBox4.ItemIndex := 0;
        edit1.Visible := true;
        edit2.Visible := true;
        ComboBox4.Visible := true;
        label4.caption := R_Search;
        label5.caption := R_Distance_km;
        label6.caption := R_Filter;
        label4.Visible := true;
        label5.Visible := true;
        label6.Visible := true;
      End;
    Script_Exec_SQL_Query: Begin // Exec SQL Query
        label4.caption := 'Select c.G_TYPE, c.NAME, c.G_NAME from caches c ';
        SynEdit1.Text := '';
        label4.Visible := true;
        SynEdit1.Visible := true;
      End;
    Script_Exec_SQL_Transaction: Begin // Exec SQL Transaction
        label4.caption := R_Enter_transaction_query;
        SynEdit1.Text := '';
        label4.Visible := true;
        SynEdit1.Visible := true;
      End;
    Script_Call_Script: Begin
        label4.caption := R_Script_name;
        label4.visible := True;
        ComboBox5.Style := csDropDownList;
        ComboBox5.Text := '';
        ComboBox5.items.Clear;
        For i := 0 To strtoint(getvalue('Scripts', 'Count', '0')) - 1 Do Begin
          ComboBox5.items.add(getvalue('Scripts', 'Name' + inttostr(i), ''));
        End;
        ComboBox5.Visible := true;
      End;
    Script_Showmessage: Begin
        edit1.text := '';
        label4.Caption := R_Text;
        label4.visible := true;
        edit1.visible := true;
      End;
    Script_Show_yes_no_question: Begin
        edit1.text := '';
        label4.Caption := R_Text;
        label5.caption := R_OnYes;
        label6.caption := R_OnNo;
        ComboBox3.Items.Text := R_Abort_Continue;
        ComboBox4.Items.Text := R_Abort_Continue;
        ComboBox3.ItemIndex := 0;
        ComboBox4.ItemIndex := 0;
        label4.visible := true;
        label5.visible := true;
        label6.visible := true;
        edit1.visible := true;
        ComboBox3.visible := true;
        ComboBox4.visible := true;
      End;
  Else Begin
      showmessage('TForm27.ComboBox2Change, missing case ' + inttostr(ComboBox2.ItemIndex));
    End;
  End;
End;

Function TForm27.SetSkriptIndex(Script_name: String; Type_, index: integer
  ): Boolean;
Begin
  result := true;
  setvalue('Script_' + Script_name, 'Type' + inttostr(index), inttostr(Type_));
  Case type_ Of
    Script_Select_cut_set_to_database,
      Script_Copy_selection_to_database,
      Script_Del_Database,
      Script_Move_selection_to_database,
      Script_Create_Database,
      Script_Select_Database: Begin
        setvalue('Script_' + Script_name, 'database' + inttostr(index), combobox5.text);
      End;
    Script_ReDownloadListing,
      Script_Delete_selection,
      Script_Mark_selection_as_archived,
      Script_Prompt_Database,
      Script_Prompt_Directory: Begin
      End;
    Script_Export_selection_to_as_ggz,
      Script_Export_selection_to_as_poi: Begin
        setvalue('Script_' + Script_name, 'Folder' + inttostr(index), ToSQLString(combobox5.text));
      End;
    Script_Export_as_pocket_query,
      Script_Create_Database_From_GSAK_GPX,
      Script_Export_as_GSAK_GPX: Begin
        setvalue('Script_' + Script_name, 'Filename' + inttostr(index), ToSQLString(edit1.text));
      End;
    Script_Import_directory: Begin
        setvalue('Script_' + Script_name, 'Directory' + inttostr(index), edit1.text);
        setvalue('Script_' + Script_name, 'NotImportFound' + inttostr(index), inttostr(ord(CheckBox1.Checked)));
        setvalue('Script_' + Script_name, 'DelAfterImport' + inttostr(index), inttostr(ord(CheckBox2.Checked)));
      End;
    Script_Exec_SQL_Query: Begin
        setvalue('Script_' + Script_name, 'Query' + inttostr(index), ToSQLString(SynEdit1.Text));
      End;
    Script_Exec_Filter_Query: Begin
        setvalue('Script_' + Script_name, 'search' + inttostr(index), Edit1.text);
        setvalue('Script_' + Script_name, 'distance' + inttostr(index), edit2.text);
        setvalue('Script_' + Script_name, 'filter' + inttostr(index), combobox4.text);
      End;
    Script_Exec_SQL_Transaction: Begin
        If trim(SynEdit1.Text) = '' Then Begin
          result := false;
          exit;
        End;
        setvalue('Script_' + Script_name, 'transaction' + inttostr(index), ToSQLString(SynEdit1.Text));
      End;
    Script_Call_Script: Begin
        If ComboBox5.Text = ComboBox1.Text Then Begin // Rekursion => nein
          ShowMessage(R_Script_recursion_not_allowed);
          result := false;
          exit;
        End;
        setvalue('Script_' + Script_name, 'script_name' + inttostr(index), ToSQLString(ComboBox5.Text));
      End;
    Script_Showmessage: Begin
        setvalue('Script_' + Script_name, 'Text' + inttostr(index), ToSQLString(edit1.text));
      End;
    Script_Show_yes_no_question: Begin
        setvalue('Script_' + Script_name, 'Text' + inttostr(index), ToSQLString(edit1.text));
        setvalue('Script_' + Script_name, 'OnYes' + inttostr(index), inttostr(ComboBox3.ItemIndex));
        setvalue('Script_' + Script_name, 'OnNo' + inttostr(index), inttostr(ComboBox4.ItemIndex));
      End;
  Else Begin
      showmessage('TForm27.SetSkriptIndex, missing case ' + inttostr(type_));
      result := false;
    End;
  End;
  Listbox1.items[index] := SkriptIndexCaption(Script_name, index);
End;

Function TForm27.GetItem(Script_name: String; index: integer): Titem;
Begin
  // Todo: Das geht zwar, läst aber ettliche Einträge im ini file übrig, weil es die nicht löscht ...
  //       Einziges Trostplaster, wenn jemand das Skript komplett löscht und wieder importiert ists wieder sauber.
  result.tp := strtoint(getvalue('Script_' + Script_name, 'Type' + IntToStr(index), '-1'));
  result.data := TStringList.Create;
  Case result.tp Of
    -1: Begin
        ShowMessage('TForm27.GetItem: Internal Error on Getitem -> restart application.');
      End;
    Script_Select_cut_set_to_database,
      Script_Copy_selection_to_database,
      Script_Del_Database,
      Script_Move_selection_to_database,
      Script_Create_Database,
      Script_Select_Database: result.data.add(getvalue('Script_' + Script_name, 'database' + inttostr(index), ''));
    Script_ReDownloadListing,
      Script_Delete_selection,
      Script_Mark_selection_as_archived,
      Script_Prompt_Database,
      Script_Prompt_Directory: Begin // Nichts in und her zu kopieren
      End;
    Script_Export_selection_to_as_ggz,
      Script_Export_selection_to_as_poi: result.data.add(getvalue('Script_' + Script_name, 'Folder' + inttostr(index), ''));
    Script_Export_as_pocket_query,
      Script_Create_Database_From_GSAK_GPX,
      Script_Export_as_GSAK_GPX: result.data.add(getvalue('Script_' + Script_name, 'Filename' + inttostr(index), ''));
    Script_Import_directory: Begin
        result.data.add(getvalue('Script_' + Script_name, 'Directory' + inttostr(index), ''));
        result.data.add(getvalue('Script_' + Script_name, 'NotImportFound' + inttostr(index), ''));
        result.data.add(getvalue('Script_' + Script_name, 'DelAfterImport' + inttostr(index), ''));
      End;
    Script_Exec_SQL_Query: result.data.add(getvalue('Script_' + Script_name, 'Query' + inttostr(index), ''));
    Script_Exec_Filter_Query: Begin
        result.data.add(getvalue('Script_' + Script_name, 'search' + inttostr(index), ''));
        result.data.add(getvalue('Script_' + Script_name, 'distance' + inttostr(index), ''));
        result.data.add(getvalue('Script_' + Script_name, 'filter' + inttostr(index), ''));
      End;
    Script_Exec_SQL_Transaction: result.data.add(getvalue('Script_' + Script_name, 'transaction' + inttostr(index), ''));
    Script_Call_Script: result.data.add(getvalue('Script_' + Script_name, 'script_name' + inttostr(index), ''));
    Script_Showmessage: result.data.add(getvalue('Script_' + Script_name, 'Text' + inttostr(index), ''));
    Script_Show_yes_no_question: Begin
        result.data.add(getvalue('Script_' + Script_name, 'Text' + inttostr(index), ''));
        result.data.add(getvalue('Script_' + Script_name, 'OnYes' + inttostr(index), ''));
        result.data.add(getvalue('Script_' + Script_name, 'OnNo' + inttostr(index), ''));
      End;
  Else Begin
      ShowMessage('Index ' + inttostr(result.tp) + ' not implemented in TForm27.GetItem');
    End;
  End;
End;

Procedure TForm27.SetItem(Script_name: String; index: integer; item: Titem);
Begin
  Case item.tp Of
    Script_Call_Script,
      Script_Select_cut_set_to_database,
      Script_Copy_selection_to_database,
      Script_Move_selection_to_database,
      Script_Select_Database,
      Script_Create_Database,
      Script_Del_Database: combobox5.text := item.data[0];
    Script_ReDownloadListing,
      Script_Delete_selection,
      Script_Mark_selection_as_archived,
      Script_Prompt_Database,
      Script_Prompt_Directory: Begin // Nichts in und her zu kopieren
      End;
    Script_Export_selection_to_as_ggz,
      Script_Export_selection_to_as_poi: ComboBox5.text := item.data[0];
    Script_Export_as_pocket_query,
      Script_Create_Database_From_GSAK_GPX,
      Script_Export_as_GSAK_GPX: edit1.text := item.data[0];
    Script_Import_directory: Begin
        edit1.text := item.data[0];
        CheckBox1.Checked := item.data[1] = '1';
        CheckBox2.Checked := item.data[2] = '1';
      End;
    Script_Exec_Filter_Query: Begin
        Edit1.text := item.data[0];
        edit2.text := item.data[1];
        combobox4.text := item.data[2];
      End;
    Script_Exec_SQL_Query,
      Script_Exec_SQL_Transaction: SynEdit1.Text := FromSQLString(item.data[0]);
    Script_Showmessage: edit1.text := FromSQLString(item.data[0]);
    Script_Show_yes_no_question: Begin
        edit1.text := FromSQLString(item.data[0]);
        ComboBox3.ItemIndex := strtoint(item.data[1]);
        ComboBox4.ItemIndex := strtoint(item.data[2]);
      End;
  Else Begin
      ShowMessage('Index ' + inttostr(item.tp) + ' not implemented in TForm27.SetItem');
      exit;
    End;
  End;
  SetSkriptIndex(Script_name, item.tp, index);
End;

Function TForm27.SkriptIndexCaption(Script_name: String; index: integer
  ): String;
Var
  sl: Tstringlist;
Begin
  result := 'Not implemented : TForm27.SkriptIndexCaption(' + inttostr(index) + ')';
  // Todo: Das muss noch Sprachabhängig gehen...
  Case strtoint(getvalue('Script_' + Script_name, 'Type' + IntToStr(index), '-1')) Of
    Script_Select_Database: result := 'Select database: ' + getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
    Script_Prompt_Database: result := 'Prompt database';
    Script_Create_Database: result := 'Create database: ' + getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
    Script_Create_Database_From_GSAK_GPX: result := 'Create database from GSAK (gpx): ' + getvalue('Script_' + Script_name, 'filename' + inttostr(index), '');
    Script_ReDownloadListing: result := 'Redownload listings';
    Script_Del_Database: result := 'Del database: ' + getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
    Script_Prompt_Directory: result := 'prompt directory';
    Script_Import_directory: result := 'Import dir: ' + ResolveDirectory(getvalue('Script_' + Script_name, 'Directory' + inttostr(index), ''), getvalue('Script_' + Script_name, 'Directory' + inttostr(index), ''));
    Script_Exec_SQL_Query: Begin
        sl := TStringList.Create;
        sl.Text := FromSQLString(getvalue('Script_' + Script_name, 'Query' + inttostr(index), ''));
        If sl.Count <> 0 Then Begin
          result := 'Execute SQL-Query: ' + sl[0];
        End
        Else Begin
          result := 'Execute SQL-Query: ';
        End;
        sl.free;
      End;
    Script_Exec_Filter_Query: result := 'Execute filter: ' + getvalue('Script_' + Script_name, 'filter' + inttostr(index), '');
    Script_Exec_SQL_Transaction: Begin
        sl := TStringList.Create;
        sl.Text := FromSQLString(getvalue('Script_' + Script_name, 'transaction' + inttostr(index), ''));
        result := 'Execute SQL-transaction: ' + sl[0];
        sl.free;
      End;
    Script_Select_cut_set_to_database: result := 'Select cut set to database: ' + getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
    Script_Copy_selection_to_database: result := 'Copy selection to database: ' + getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
    Script_Move_selection_to_database: result := 'Move selection to database: ' + getvalue('Script_' + Script_name, 'database' + inttostr(index), '');
    Script_Delete_selection: result := 'Delete selection';
    Script_Mark_selection_as_archived: result := 'Mark selection as archived';
    Script_Export_as_pocket_query: result := 'Export as pocket query to: ' + getvalue('Script_' + Script_name, 'filename' + inttostr(index), '');
    Script_Export_as_GSAK_GPX: result := 'Export as GSAK (gpx) to: ' + getvalue('Script_' + Script_name, 'filename' + inttostr(index), '');
    Script_Export_selection_to_as_ggz: result := 'Export as ggz to: ' + getvalue('Script_' + Script_name, 'folder' + inttostr(index), '');
    Script_Export_selection_to_as_poi: result := 'Export as poi to: ' + getvalue('Script_' + Script_name, 'folder' + inttostr(index), '');
    Script_Call_Script: result := 'Call Script: ' + getvalue('Script_' + Script_name, 'script_name' + inttostr(index), '');
    Script_Showmessage: result := 'Message: ' + FromSQLString(getvalue('Script_' + Script_name, 'Text' + inttostr(index), ''));
    Script_Show_yes_no_question: result := 'Yes No: ' + FromSQLString(getvalue('Script_' + Script_name, 'Text' + inttostr(index), ''));
  Else Begin
      showmessage('TForm27.SkriptIndexCaption, missing case ' + getvalue('Script_' + Script_name, 'Type' + IntToStr(index), '-1'));
    End;
  End;
End;

Procedure TForm27.LoadScriptToListbox;
Var
  Script_name: String;
  index: Integer;
Begin
  ListBox1.Clear;
  Script_name := ToSQLString(trim(ComboBox1.Text));
  For index := 0 To strtoint(getvalue('Script_' + Script_name, 'Count', '0')) - 1 Do Begin
    ListBox1.Items.Add(SkriptIndexCaption(Script_name, index));
  End;
End;

End.

