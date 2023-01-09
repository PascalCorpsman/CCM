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
Unit Unit21;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm21 }

  TForm21 = Class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Procedure Button10Click(Sender: TObject);
    Procedure Button11Click(Sender: TObject);
    Procedure Button12Click(Sender: TObject);
    Procedure Button13Click(Sender: TObject);
    Procedure Button14Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure ComboBox2Change(Sender: TObject);
    Procedure ComboBox3Change(Sender: TObject);
    Procedure ComboBox4Change(Sender: TObject);
    Procedure Edit4KeyPress(Sender: TObject; Var Key: char);
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Procedure LoadFolderFiles;
  End;

Var
  Form21: TForm21;

Implementation

{$R *.lfm}

Uses uccm, LazFileUtils, ulanguage;

{ TForm21 }

Procedure TForm21.FormCreate(Sender: TObject);
Begin
  caption := 'Editor for files and folders';
  Constraints.MinHeight := height;
  Constraints.MinWidth := Width;
  Constraints.MaxHeight := height;
  Constraints.MaxWidth := Width;
End;

Procedure TForm21.Button1Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm21.Button10Click(Sender: TObject);
Begin
  If OpenDialog1.Execute Then Begin
    ComboBox3.Text := OpenDialog1.FileName;
    ComboBox3Change(Nil);
  End;
End;

Procedure TForm21.Button11Click(Sender: TObject);
Var
  c, index, i: integer;
  s: String;
Begin
  index := LocateExportSpoilerIndex(ComboBox4.Text);
  If index = -1 Then Begin
    exit; // Nichts zu Löschen
  End;
  // Delete Import Geocache_Visits
  c := strtointdef(getvalue('GPSSpoilerExport', 'Count', '0'), 0);
  SetValue('GPSSpoilerExport', 'Count', inttostr(c - 1));
  If c > 1 Then Begin
    For i := index To c - 2 Do Begin
      s := GetValue('GPSSpoilerExport', 'Folder' + inttostr(i + 1), '');
      SetValue('GPSSpoilerExport', 'Folder' + inttostr(i), s);
    End;
  End;
  // Den letzten Datensatz Platt machen
  DeleteValue('GPSSpoilerExport', 'Folder' + inttostr(c - 1));
  For i := 0 To ComboBox4.Items.Count - 1 Do Begin
    If ComboBox4.Items[i] = ComboBox4.Text Then Begin
      ComboBox4.Items.Delete(i);
      break;
    End;
  End;
  edit3.text := '';
End;

Procedure TForm21.Button12Click(Sender: TObject);
Var
  c, index: integer;
Begin
  //Add Spoiler Export
  If Not DirectoryExistsUTF8(ComboBox4.Text) Then Begin
    ShowMessage(format(RF_Error_Directory_does_not_exist, [ComboBox4.Text]));
    exit;
  End;
  index := LocateExportSpoilerIndex(ComboBox4.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSSpoilerExport', 'Count', '0'), 0);
    SetValue('GPSSpoilerExport', 'Folder' + inttostr(c), ComboBox4.Text);
    SetValue('GPSSpoilerExport', 'Name' + inttostr(c), Edit3.text);
    Setvalue('GPSSpoilerExport', 'Count', inttostr(c + 1));
    ComboBox4.Items.Add(ComboBox4.Text);
  End
  Else Begin
    // Overwrite
    SetValue('GPSSpoilerExport', 'Name' + inttostr(index), Edit3.text);
  End;
End;

Procedure TForm21.Button13Click(Sender: TObject);
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    ComboBox4.Text := SelectDirectoryDialog1.FileName;
    ComboBox4Change(Nil);
  End;
End;

Procedure TForm21.Button14Click(Sender: TObject);
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    edit4.text := SelectDirectoryDialog1.FileName;
    setValue('General', 'LastImportDir', edit4.text);
  End;
End;

Procedure TForm21.Button2Click(Sender: TObject);
Var
  c, index, i: integer;
  s: String;
Begin
  index := LocatePoiExportFilderIndex(ComboBox1.Text);
  If index = -1 Then Begin
    exit; // Nichts zu Löschen
  End;
  // Delete POI Folder
  c := strtointdef(getvalue('GPSPOI', 'Count', '0'), 0);
  SetValue('GPSPOI', 'Count', inttostr(c - 1));
  If c > 1 Then Begin
    For i := index To c - 2 Do Begin
      s := GetValue('GPSPOI', 'Folder' + inttostr(i + 1), '');
      SetValue('GPSPOI', 'Folder' + inttostr(i), s);
    End;
  End;
  // Den letzten Datensatz Platt machen
  DeleteValue('GPSPOI', 'Folder' + inttostr(c - 1));
  For i := 0 To ComboBox1.Items.Count - 1 Do Begin
    If ComboBox1.Items[i] = ComboBox1.Text Then Begin
      ComboBox1.Items.Delete(i);
      break;
    End;
  End;
End;

Procedure TForm21.Button3Click(Sender: TObject);
Var
  c, index: integer;
Begin
  // Add POI Folder
  If Not DirectoryExistsUTF8(ComboBox1.Text) Then Begin
    ShowMessage(format(RF_Error_Directory_does_not_exist, [ComboBox1.Text]));
    exit;
  End;
  index := LocatePoiExportFilderIndex(ComboBox1.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSPOI', 'Count', '0'), 0);
    SetValue('GPSPOI', 'Folder' + inttostr(c), ComboBox1.Text);
    Setvalue('GPSPOI', 'Count', inttostr(c + 1));
    ComboBox1.Items.Add(ComboBox1.Text);
  End
  Else Begin
    // Overwrite
    // -- Nichts gibts net, weil kein Name Tag
  End;
End;

Procedure TForm21.Button4Click(Sender: TObject);
Var
  c, index, i: integer;
  s: String;
Begin
  index := LocateGPSExportIndex(ComboBox2.Text);
  If index = -1 Then Begin
    exit; // Nichts zu Löschen
  End;
  // Delete GPS Export Folder
  c := strtointdef(getvalue('GPSExport', 'Count', '0'), 0);
  SetValue('GPSExport', 'Count', inttostr(c - 1));
  If c > 1 Then Begin
    For i := index To c - 2 Do Begin
      s := GetValue('GPSExport', 'Folder' + inttostr(i + 1), '');
      SetValue('GPSExport', 'Folder' + inttostr(i), s);
    End;
  End;
  // Den letzten Datensatz Platt machen
  DeleteValue('GPSExport', 'Folder' + inttostr(c - 1));
  For i := 0 To ComboBox2.Items.Count - 1 Do Begin
    If ComboBox2.Items[i] = ComboBox2.Text Then Begin
      ComboBox2.Items.Delete(i);
      break;
    End;
  End;
  edit1.text := '';
End;

Procedure TForm21.Button5Click(Sender: TObject);
Var
  c, index: integer;
Begin
  //Add GPS Export
  If trim(edit1.text) = '' Then Begin
    showmessage(R_error_no_Name_defined);
    exit;
  End;
  If Not DirectoryExistsUTF8(ComboBox2.Text) Then Begin
    ShowMessage(format(RF_Error_Directory_does_not_exist, [ComboBox2.Text]));
    exit;
  End;
  index := LocateGPSExportIndex(ComboBox2.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSExport', 'Count', '0'), 0);
    SetValue('GPSExport', 'Folder' + inttostr(c), ComboBox2.Text);
    SetValue('GPSExport', 'Name' + inttostr(c), Edit1.text);
    Setvalue('GPSExport', 'Count', inttostr(c + 1));
    ComboBox2.Items.Add(ComboBox2.Text);
  End
  Else Begin
    // Overwrite
    SetValue('GPSExport', 'Name' + inttostr(index), Edit1.text);
  End;
End;

Procedure TForm21.Button6Click(Sender: TObject);
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    ComboBox2.Text := SelectDirectoryDialog1.FileName;
    ComboBox2Change(Nil);
  End;
End;

Procedure TForm21.Button7Click(Sender: TObject);
Begin
  If SelectDirectoryDialog1.Execute Then Begin
    ComboBox1.Text := SelectDirectoryDialog1.FileName;
  End;
End;

Procedure TForm21.Button8Click(Sender: TObject);
Var
  c, index, i: integer;
  s: String;
Begin
  index := LocateImportGeocacheVisitsIndex(ComboBox3.Text);
  If index = -1 Then Begin
    exit; // Nichts zu Löschen
  End;
  // Delete Import Geocache_Visits
  c := strtointdef(getvalue('GPSImport', 'Count', '0'), 0);
  SetValue('GPSImport', 'Count', inttostr(c - 1));
  If c > 1 Then Begin
    For i := index To c - 2 Do Begin
      s := GetValue('GPSImport', 'Filename' + inttostr(i + 1), '');
      SetValue('GPSImport', 'Filename' + inttostr(i), s);
    End;
  End;
  // Den letzten Datensatz Platt machen
  DeleteValue('GPSImport', 'Filename' + inttostr(c - 1));
  For i := 0 To ComboBox3.Items.Count - 1 Do Begin
    If ComboBox3.Items[i] = ComboBox3.Text Then Begin
      ComboBox3.Items.Delete(i);
      break;
    End;
  End;
  edit2.text := '';
End;

Procedure TForm21.Button9Click(Sender: TObject);
Var
  c, index: integer;
Begin
  //Add Import Geocache Visits
  If Not FileExistsUTF8(ComboBox3.Text) Then Begin
    ShowMessage(format(RF_warning_File_does_not_exist, [ComboBox3.Text]));
  End;
  index := LocateImportGeocacheVisitsIndex(ComboBox3.Text);
  If Index = -1 Then Begin
    // Add
    c := strtointdef(getvalue('GPSImport', 'Count', '0'), 0);
    SetValue('GPSImport', 'Filename' + inttostr(c), ComboBox3.Text);
    SetValue('GPSImport', 'Name' + inttostr(c), Edit2.text);
    Setvalue('GPSImport', 'Count', inttostr(c + 1));
    ComboBox3.Items.Add(ComboBox3.Text);
  End
  Else Begin
    // Overwrite
    SetValue('GPSImport', 'Name' + inttostr(index), Edit2.text);
  End;
End;

Procedure TForm21.ComboBox2Change(Sender: TObject);
Begin
  edit1.text := getvalue('GPSExport', 'name' + inttostr(LocateGPSExportIndex(ComboBox2.Text)), '');
End;

Procedure TForm21.ComboBox3Change(Sender: TObject);
Begin
  edit2.text := getvalue('GPSImport', 'name' + inttostr(LocateImportGeocacheVisitsIndex(ComboBox3.Text)), '');
End;

Procedure TForm21.ComboBox4Change(Sender: TObject);
Begin
  edit3.text := getvalue('GPSSpoilerExport', 'name' + inttostr(LocateExportSpoilerIndex(ComboBox4.Text)), '');
End;

Procedure TForm21.Edit4KeyPress(Sender: TObject; Var Key: char);
Begin
  If key = #13 Then Begin
    setValue('General', 'LastImportDir', edit4.text);
  End;
End;

Procedure TForm21.LoadFolderFiles;
Var
  c, i: Integer;
Begin
  // Import folder
  edit4.text := GetValue('General', 'LastImportDir', '');
  // POI Folder
  c := strtoint(getvalue('GPSPOI', 'Count', '0'));
  ComboBox1.Clear;
  For i := 0 To c - 1 Do Begin
    ComboBox1.Items.Add(getvalue('GPSPOI', 'Folder' + inttostr(i), ''));
  End;
  If ComboBox1.Items.Count = 0 Then Begin
    ComboBox1.text := '';
  End
  Else Begin
    ComboBox1.ItemIndex := 0;
  End;
  // GPS export Folder
  c := strtoint(getvalue('GPSExport', 'Count', '0'));
  ComboBox2.Clear;
  For i := 0 To c - 1 Do Begin
    ComboBox2.Items.Add(getvalue('GPSExport', 'Folder' + inttostr(i), ''));
  End;
  If ComboBox2.Items.Count = 0 Then Begin
    ComboBox2.text := '';
    Edit1.text := '';
  End
  Else Begin
    ComboBox2.ItemIndex := 0;
    ComboBox2.OnChange(Nil);
  End;
  // Import Geocache_visits.txt
  c := strtoint(getvalue('GPSImport', 'Count', '0'));
  ComboBox3.Clear;
  For i := 0 To c - 1 Do Begin
    ComboBox3.Items.Add(getvalue('GPSImport', 'Filename' + inttostr(i), ''));
  End;
  If ComboBox3.Items.Count = 0 Then Begin
    ComboBox3.text := '';
    Edit2.text := '';
  End
  Else Begin
    ComboBox3.ItemIndex := 0;
    ComboBox3.OnChange(Nil);
  End;
  // Export Spoiler folder
  c := strtoint(getvalue('GPSSpoilerExport', 'Count', '0'));
  ComboBox4.Clear;
  For i := 0 To c - 1 Do Begin
    ComboBox4.Items.Add(getvalue('GPSSpoilerExport', 'Folder' + inttostr(i), ''));
  End;
  If ComboBox4.Items.Count = 0 Then Begin
    ComboBox4.text := '';
    Edit3.text := '';
  End
  Else Begin
    ComboBox4.ItemIndex := 0;
    ComboBox4.OnChange(Nil);
  End;
End;

End.

