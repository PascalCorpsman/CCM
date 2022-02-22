Unit unit29;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls, Types;

Type

  { TForm29 }

  TForm29 = Class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    ImageList1: TImageList;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ScrollBox1: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton100: TSpeedButton;
    SpeedButton101: TSpeedButton;
    SpeedButton102: TSpeedButton;
    SpeedButton103: TSpeedButton;
    SpeedButton104: TSpeedButton;
    SpeedButton105: TSpeedButton;
    SpeedButton106: TSpeedButton;
    SpeedButton107: TSpeedButton;
    SpeedButton108: TSpeedButton;
    SpeedButton109: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton110: TSpeedButton;
    SpeedButton111: TSpeedButton;
    SpeedButton112: TSpeedButton;
    SpeedButton113: TSpeedButton;
    SpeedButton114: TSpeedButton;
    SpeedButton115: TSpeedButton;
    SpeedButton116: TSpeedButton;
    SpeedButton117: TSpeedButton;
    SpeedButton118: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButton15: TSpeedButton;
    SpeedButton16: TSpeedButton;
    SpeedButton17: TSpeedButton;
    SpeedButton18: TSpeedButton;
    SpeedButton19: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton20: TSpeedButton;
    SpeedButton21: TSpeedButton;
    SpeedButton22: TSpeedButton;
    SpeedButton23: TSpeedButton;
    SpeedButton24: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    SpeedButton27: TSpeedButton;
    SpeedButton28: TSpeedButton;
    SpeedButton29: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton30: TSpeedButton;
    SpeedButton31: TSpeedButton;
    SpeedButton32: TSpeedButton;
    SpeedButton33: TSpeedButton;
    SpeedButton34: TSpeedButton;
    SpeedButton35: TSpeedButton;
    SpeedButton36: TSpeedButton;
    SpeedButton37: TSpeedButton;
    SpeedButton38: TSpeedButton;
    SpeedButton39: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton40: TSpeedButton;
    SpeedButton41: TSpeedButton;
    SpeedButton42: TSpeedButton;
    SpeedButton43: TSpeedButton;
    SpeedButton44: TSpeedButton;
    SpeedButton45: TSpeedButton;
    SpeedButton46: TSpeedButton;
    SpeedButton47: TSpeedButton;
    SpeedButton48: TSpeedButton;
    SpeedButton49: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton50: TSpeedButton;
    SpeedButton51: TSpeedButton;
    SpeedButton52: TSpeedButton;
    SpeedButton53: TSpeedButton;
    SpeedButton54: TSpeedButton;
    SpeedButton55: TSpeedButton;
    SpeedButton56: TSpeedButton;
    SpeedButton57: TSpeedButton;
    SpeedButton58: TSpeedButton;
    SpeedButton59: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton60: TSpeedButton;
    SpeedButton61: TSpeedButton;
    SpeedButton62: TSpeedButton;
    SpeedButton63: TSpeedButton;
    SpeedButton64: TSpeedButton;
    SpeedButton65: TSpeedButton;
    SpeedButton66: TSpeedButton;
    SpeedButton67: TSpeedButton;
    SpeedButton68: TSpeedButton;
    SpeedButton69: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton70: TSpeedButton;
    SpeedButton71: TSpeedButton;
    SpeedButton72: TSpeedButton;
    SpeedButton73: TSpeedButton;
    SpeedButton74: TSpeedButton;
    SpeedButton75: TSpeedButton;
    SpeedButton76: TSpeedButton;
    SpeedButton77: TSpeedButton;
    SpeedButton78: TSpeedButton;
    SpeedButton79: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton80: TSpeedButton;
    SpeedButton81: TSpeedButton;
    SpeedButton82: TSpeedButton;
    SpeedButton83: TSpeedButton;
    SpeedButton84: TSpeedButton;
    SpeedButton85: TSpeedButton;
    SpeedButton86: TSpeedButton;
    SpeedButton87: TSpeedButton;
    SpeedButton88: TSpeedButton;
    SpeedButton89: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton90: TSpeedButton;
    SpeedButton91: TSpeedButton;
    SpeedButton92: TSpeedButton;
    SpeedButton93: TSpeedButton;
    SpeedButton94: TSpeedButton;
    SpeedButton95: TSpeedButton;
    SpeedButton96: TSpeedButton;
    SpeedButton97: TSpeedButton;
    SpeedButton98: TSpeedButton;
    SpeedButton99: TSpeedButton;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure SpeedButton100Click(Sender: TObject);
    Procedure SpeedButton111Click(Sender: TObject);
    Procedure SpeedButton82Click(Sender: TObject);
    Procedure SpeedButton91Click(Sender: TObject);
  private
    Procedure CreateAttribList();
    Procedure RemoveAttribFromScrollbox(Sender: TObject);
  public
    Function GetFilter(): String;
  End;

Var
  Form29: TForm29;

Implementation

{$R *.lfm}

Uses Unit1, uccm, LCLType, ulanguage;

{ TForm29 }

Procedure TForm29.FormCreate(Sender: TObject);
  Procedure ApplyImage(Const SpeedButton: TSpeedButton; Index: Integer; text: String);
  Var
    b: TBitmap;
  Begin
    b := TBitmap.Create;
    b.Height := 16;
    b.Width := 16;
    b.Canvas.Brush.Color := clFuchsia;
    b.Canvas.Rectangle(-1, -1, 17, 17);
    b.TransparentColor := clFuchsia;
    b.Transparent := true;
    Form1.ImageList1.Draw(b.Canvas, 0, 0, index);
    SpeedButton.Glyph := b;
    SpeedButton.Tag := IntPtr(NewStr(text));
    b.free;
  End;

Var
  i: integer;
Begin
  // Sorgt dafür, dass die Speedbuttons "Checkbar" werden.
  For i := 0 To ComponentCount - 1 Do Begin
    If Components[i] Is TSpeedButton Then TSpeedButton(Components[i]).GroupIndex := i + 1;
  End;
  ApplyImage(SpeedButton101, MainImageIndexTraditionalCache, Traditional_Cache);
  ApplyImage(SpeedButton102, MainImageIndexMultiCache, Multi_cache);
  ApplyImage(SpeedButton103, MainImageIndexMysterieCache, Unknown_Cache);
  ApplyImage(SpeedButton104, MainImageIndexLetterbox, Letterbox_Hybrid);
  ApplyImage(SpeedButton105, MainImageIndexWhereIGo, Wherigo_Cache);
  ApplyImage(SpeedButton106, MainImageIndexEarthCache, Earthcache);
  ApplyImage(SpeedButton107, MainImageIndexVirtualCache, Virtual_Cache);
  ApplyImage(SpeedButton108, MainImageIndexEventCache, Giga_Event_Cache + ',' + Mega_Event_Cache + ',' + Event_Cache);
  ApplyImage(SpeedButton109, MainImageIndexCITO, Cache_In_Trash_Out_Event);
  ApplyImage(SpeedButton110, MainImageIndexWebcamCache, Webcam_Cache);
  CreateAttribList();
End;

Procedure TForm29.ComboBox1DrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
Begin
  ImageList1.Draw(ComboBox1.Canvas, ARect.Left + 1, ARect.Top + 1, index);
  //ComboBox1.Canvas.Brush.Color := clwhite;
  //ComboBox1.Canvas.Rectangle(ARect.Left + 1, ARect.Top, ARect.Left + 32, ARect.Top + 32);
End;

Procedure TForm29.Button1Click(Sender: TObject);
Var
  b: TBitmap;
  img: TImage;
  i: Integer;
  h: String;
Begin
  // Add to Attribute filter
  If ComboBox1.ItemIndex < 0 Then exit;
  For i := 0 To ScrollBox1.ComponentCount - 1 Do Begin
    If (ScrollBox1.Components[i] Is TImage) And (TImage(ScrollBox1.Components[i]).Tag = ComboBox1.ItemIndex) Then Begin
      showmessage(R_Already_in_list_double_click_image_to_remove);
      exit;
    End;
  End;
  If ComboBox1.ItemIndex >= length(PosAttribs) Then Begin
    i := NegAttribs[ComboBox1.ItemIndex - Length(PosAttribs)];
    b := GetAttribImage(i, false);
  End
  Else Begin
    i := PosAttribs[ComboBox1.ItemIndex];
    b := GetAttribImage(i, True);
  End;
  If (i >= low(AttribsNames)) And (i <= high(AttribsNames)) Then Begin
    h := AttribsNames[i];
  End
  Else Begin
    h := ''; // -- Keine Ahnung was das ist, wir haben keinen Namen dafür
  End;
  img := TImage.Create(ScrollBox1);
  img.Parent := ScrollBox1;
  img.Picture.Assign(b);
  img.Width := b.Width;
  img.Height := b.Height;
  img.Hint := h;
  img.ShowHint := true;
  img.Tag := ComboBox1.ItemIndex;
  img.OnDblClick := @RemoveAttribFromScrollbox;
  img.Transparent := true;
  b.free;
  img.Left := (ScrollBox1.ComponentCount - 1) * (img.Width + 5);
  img.Top := 2;
End;

Procedure TForm29.Button2Click(Sender: TObject);
Var
  s: String;
  c, i: Integer;
Begin
  s := InputBox('', R_Please_enter_a_filter_name, '');
  // Cancel
  If trim(s) = '' Then exit;
  For i := 0 To strtoint(getValue('Queries', 'Count', '0')) - 1 Do Begin
    If lowercase(trim(getValue('Queries', 'Name' + inttostr(i), ''))) = lowercase(trim(s)) Then Begin
      If id_yes = application.MessageBox('Filter already exists, overrite?', 'Question', mb_iconquestion Or mb_YESNO) Then Begin
        // Overwrite
        SetValue('Queries', 'Query' + inttostr(i), ToSQLString(GetFilter()));
        exit;
      End
      Else Begin
        exit;
      End;
    End;
  End;
  // Add as new
  c := strtoint(getvalue('Queries', 'Count', '0'));
  SetValue('Queries', 'Name' + inttostr(C), s);
  SetValue('Queries', 'Query' + inttostr(C), ToSQLString(GetFilter()));
  SetValue('Queries', 'Count', inttostr(C + 1));
  form1.CreateFilterMenu;
  form1.ComboBox1.ItemIndex := form1.ComboBox1.Items.Count - 1;
End;

Procedure TForm29.FormDestroy(Sender: TObject);
Var
  i: Integer;
  sb: TSpeedButton;
Begin
  For i := 101 To 110 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i)));
    DisposeStr(PString(sb.Tag));
  End;
End;

Procedure TForm29.SpeedButton100Click(Sender: TObject);
Var
  i: integer;
  sb: TSpeedButton;
Begin
  // Alle
  For i := 0 To 80 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i + 1)));
    sb.Down := TSpeedButton(Sender).Down;
  End;
End;

Procedure TForm29.SpeedButton111Click(Sender: TObject);
Var
  i: integer;
  sb: TSpeedButton;
Begin
  For i := 101 To 110 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i)));
    sb.Down := SpeedButton111.Down;
  End;
End;

Procedure TForm29.SpeedButton82Click(Sender: TObject);
Var
  index, i: integer;
  sb: TSpeedButton;
Begin
  // Die Waagrechten
  index := strtoint(copy(TSpeedButton(Sender).Name, length('Speedbutton') + 1, length(TSpeedButton(Sender).Name))) - 82;
  For i := 0 To 8 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i + 1 + index * 9)));
    sb.Down := TSpeedButton(Sender).Down;
  End;
End;

Procedure TForm29.SpeedButton91Click(Sender: TObject);
Var
  index, i: integer;
  sb: TSpeedButton;
Begin
  // Die Senkrechten
  index := strtoint(copy(TSpeedButton(Sender).Name, length('Speedbutton') + 1, length(TSpeedButton(Sender).Name))) - 91;
  For i := 0 To 8 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i * 9 + 1 + index)));
    sb.Down := TSpeedButton(Sender).Down;
  End;
End;

Procedure TForm29.CreateAttribList();
Var
  i: integer;
  b: TBitmap;
Begin
  ComboBox1.Items.Clear;
  For i := low(PosAttribs) To high(PosAttribs) Do Begin
    b := GetAttribImage(PosAttribs[i], true);
    ImageList1.Add(b, Nil);
    b.free;
    ComboBox1.Items.Add(inttostr(PosAttribs[i]));
  End;
  For i := low(NegAttribs) To high(NegAttribs) Do Begin
    b := GetAttribImage(NegAttribs[i], false);
    ImageList1.Add(b, Nil);
    b.free;
    ComboBox1.Items.Add(inttostr(NegAttribs[i]));
  End;
End;

Procedure TForm29.RemoveAttribFromScrollbox(Sender: TObject);
Var
  i, j: Integer;
Begin
  For i := 0 To ScrollBox1.ComponentCount - 1 Do Begin
    If ScrollBox1.Components[i] = sender Then Begin
      For j := i + 1 To ScrollBox1.ComponentCount - 1 Do Begin
        TImage(ScrollBox1.Components[j]).Left := (j - 1) * (TImage(sender).Width + 5);
      End;
      sender.Free;
      exit;
    End;
  End;
End;

Function TForm29.GetFilter(): String;
Var
  index, i: integer;
  sb: TSpeedButton;
  t, s: String;
Begin
  result := '-- This is a auto generated filter' + LineEnding +
    'where (1=1) -- the tautology statement is always true' + LineEnding;

  // Selektierung nach Allen Icons oder gezielt
  t := '';
  For i := 101 To 110 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i)));
    If sb.down Then Begin
      // Die Compilerwarnung ist nonsens, da sb.tag vom Typ PtrInt ist.
      s := PString(sb.Tag)^ + ',';
      While pos(',', s) <> 0 Do Begin
        If t = '' Then Begin
          t := t + '(c.G_TYPE = "' + copy(s, 1, pos(',', s) - 1) + '")' + LineEnding;
        End
        Else Begin
          t := t + 'or (c.G_TYPE = "' + copy(s, 1, pos(',', s) - 1) + '")' + LineEnding;
        End;
        delete(s, 1, pos(',', s));
      End;
    End;
  End;
  If t <> '' Then Begin
    result := result + ' and ( -- all icon selections' + LineEnding +
      t + ')' + LineEnding;
  End;
  // Selectieren nach D/T Wertung
  t := '';
  For i := 1 To 81 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i)));
    If sb.down Then Begin
      If t = '' Then Begin
        t := t + '((c.g_terrain = ' + format('%0.1f', [((i - 1) Mod 9 + 2) / 2], DefFormat) + ') and (c.g_difficulty = ' + format('%0.1f', [((i - 1) Div 9 + 2) / 2], DefFormat) + '))' + LineEnding;
      End
      Else Begin
        t := t + 'or ((c.g_terrain = ' + format('%0.1f', [((i - 1) Mod 9 + 2) / 2], DefFormat) + ') and (c.g_difficulty = ' + format('%0.1f', [((i - 1) Div 9 + 2) / 2], DefFormat) + '))' + LineEnding;
      End;
    End;
  End;
  If t <> '' Then Begin
    result := result + ' and ( -- all d/t selections' + LineEnding +
      t + ')' + LineEnding;
  End;
  // Selectieren nach Cache Attributen
  t := '';
  For i := 0 To scrollbox1.componentcount - 1 Do Begin
    If scrollbox1.components[i] Is TImage Then Begin
      index := TImage(scrollbox1.components[i]).tag;
      If Index >= length(PosAttribs) Then Begin
        If t = '' Then Begin
          t := t + '((a.id = ' + inttostr(NegAttribs[Index - Length(PosAttribs)]) + ') and (a.inc=0)) -- ' + TImage(scrollbox1.components[i]).Hint + LineEnding;
        End
        Else Begin
          t := t + 'or ((a.id = ' + inttostr(NegAttribs[Index - Length(PosAttribs)]) + ') and (a.inc=0)) -- ' + TImage(scrollbox1.components[i]).Hint + LineEnding;
        End;
      End
      Else Begin
        If t = '' Then Begin
          t := t + '((a.id = ' + inttostr(PosAttribs[Index]) + ') and (a.inc=1)) -- ' + TImage(scrollbox1.components[i]).Hint + LineEnding;
        End
        Else Begin
          t := t + 'or ((a.id = ' + inttostr(PosAttribs[Index]) + ') and (a.inc=1)) -- ' + TImage(scrollbox1.components[i]).Hint + LineEnding;
        End;
      End;
    End;
  End;
  If t <> '' Then Begin
    result := 'inner join attributes a on a.cache_name = c.name -- include the attribute database to be able to search with attributes' + LineEnding +
      result + ' and ( -- all attribute selections' + LineEnding +
      t + ')' + LineEnding;
  End;
  // Selectieren nach Cache Size
  t := '';
  For i := 112 To 118 Do Begin
    sb := TSpeedButton(FindComponent('SpeedButton' + inttostr(i)));
    If sb.down Then Begin
      If t = '' Then Begin
        t := t + '(c.G_Container = "' + IndexToCacheSize(sb.ImageIndex) + '")' + LineEnding;
      End
      Else Begin
        t := t + ' or (c.G_Container = "' + IndexToCacheSize(sb.ImageIndex) + '")' + LineEnding;
      End;
    End;
  End;
  If t <> '' Then Begin
    result := result + ' and ( -- the container size' + LineEnding +
      t + ')' + LineEnding;
  End;
End;

End.

