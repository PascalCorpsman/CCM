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
Unit Unit20;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

Type

  { TForm20 }

  TForm20 = Class(TForm)
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Procedure LoadLogsFromCache(CacheName: String);
  End;

Var
  Form20: TForm20;

Implementation

{$R *.lfm}

Uses usqlite_helper, uccm, lazutf8, LazFileUtils, ulanguage;

{ TForm20 }

Procedure TForm20.FormCreate(Sender: TObject);
Begin
  //
End;

Procedure TForm20.LoadLogsFromCache(CacheName: String);
Const
  HeightPerLog = 150;
Var
  lt: TLogtype;
  t, i: Integer;
  g: TGroupBox;
  l: Tlabel;
  m: Tmemo;
  im: Timage;
  tmp, s: String;
  d: TDateTime;
Begin
  // Alte Logs Löschen
  For i := ComponentCount - 1 Downto 0 Do Begin
    If Components[i] Is TGroupBox Then Begin
      Components[i].free;
    End;
  End;
  StartSQLQuery('Select Finder, Type, Date, Log_Text from logs where Cache_name = "' + CacheName + '" order by Date desc');
  t := 0;
  While Not SQLQuery.EOF Do Begin
    g := TGroupBox.Create(self);
    g.Parent := self;
    g.name := 'Log' + inttostr(t); // Egal, hauptsache was das sich ändert
    g.left := 8;
    g.top := t;
    g.height := 144;
    t := t + HeightPerLog;
    g.Width := Width - 28;
    g.Anchors := [akTop, akRight, akLeft];
    g.Caption := '';
    // Finder
    l := TLabel.Create(g);
    l.Parent := g;
    l.name := 'Label1_' + inttostr(t);
    l.left := 8;
    l.top := 0;
    l.caption := FromSQLString(SQLQuery.Fields[0].AsString);
    // Type
    l := TLabel.Create(g);
    l.Parent := g;
    l.name := 'Label2_' + inttostr(t);
    l.left := 8;
    l.top := 16;
    l.caption := FromSQLString(SQLQuery.Fields[1].AsString);
    // Type Image
    im := TImage.Create(g);
    im.Parent := g;
    im.Left := 8;
    im.Top := 40;
    im.AutoSize := true;
    // Problematische Zeichen für Dateinamen entfernen.
    tmp := lowercase(StringReplace(l.caption, ' ', '', [rfReplaceAll]));
    tmp := StringReplace(tmp, '''', '', [rfReplaceAll]);
    s := GetImagesDir() + 'log' + tmp + '.png';
    If FileExistsUTF8(s) Then Begin
      im.Picture.LoadFromFile(s);
    End
    Else Begin
      // Wenn der Fund Status als Zahl codiert ist und nicht als Text
      Try
        lt := LogtypeIndexToLogtype(strtointdef(tmp, -1));
        tmp := LogTypeToEnglishString(lt);
        // Problematische Zeichen für Dateinamen entfernen.
        tmp := lowercase(StringReplace(tmp, ' ', '', [rfReplaceAll]));
        tmp := StringReplace(tmp, '''', '', [rfReplaceAll]);
        s := GetImagesDir() + 'log' + tmp + '.png';
        If FileExistsUTF8(s) Then Begin
          im.Picture.LoadFromFile(s);
          l.Caption := LogTypeToEnglishString(lt);
        End;
      Except
        // Nichts, wir kennen den Logtyp wohl wirklich nicht
      End;
    End;
    // Date
    l := TLabel.Create(g);
    l.Parent := g;
    l.name := 'Label3_' + inttostr(t);
    l.AutoSize := false;
    l.left := 512;
    l.Width := 167;
    l.top := 0;
    l.Anchors := [akTop, akRight];
    l.Alignment := taRightJustify;
    d := StrToTime(FromSQLString(SQLQuery.Fields[2].AsString));
    l.caption := FormatDateTime('YYYY-MM-DD', d);
    // Logtext
    m := TMemo.Create(g);
    m.Parent := g;
    m.name := 'Memo1_' + inttostr(t);
    m.Left := 96;
    m.Top := 16;
    m.Width := 583;
    m.Height := 106;
    m.WordWrap := false;
    m.ScrollBars := ssAutoBoth;
    m.Anchors := [akLeft, akRight, akTop];
    m.Text := FromSQLString(SQLQuery.Fields[3].AsString);
    SQLQuery.Next;
  End;
  caption := format(RF_Logs_for, [t Div HeightPerLog, CacheName]);
  If t = 0 Then Begin
    g := TGroupBox.Create(self);
    g.Parent := self;
    g.name := 'Log' + inttostr(t); // Egal, hauptsache was das sich ändert
    g.left := 8;
    g.top := t;
    g.height := 144;
    t := t + HeightPerLog;
    g.Width := Width - 28;
    g.Anchors := [akTop, akRight, akLeft];
    g.Caption := '';
    // Finder
    l := TLabel.Create(g);
    l.Parent := g;
    l.name := 'Label1_' + inttostr(t);
    l.left := 8;
    l.top := 144 Div 2;
    l.caption := R_No_Logs_found_in_List;
  End;
End;

End.

