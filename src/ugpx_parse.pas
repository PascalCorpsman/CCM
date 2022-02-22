(******************************************************************************)
(* gpx2ggz ver.                                                    08.02.2016 *)
(*                                                                            *)
(* Version     : 0.01                                                         *)
(*                                                                            *)
(* Autor       : Corpsman                                                     *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : parses a .gpx file and gives a list of all waypoints in it.  *)
(*                                                                            *)
(* License     : This component is postcardware for non commercial use only.  *)
(*               If you like the component, send me a postcard:               *)
(*                    Uwe Schächterle                                         *)
(*                    Buhlstraße 85                                           *)
(*                    71384 Weinstadt - Germany                               *)
(*               It is not allowed to change or remove this lizensetext from  *)
(*               any source file of the project.                              *)
(*                                                                            *)
(*                                                                            *)
(* Warranty    : There is no warranty, use at your own risk.                  *)
(*                                                                            *)
(* History     : 0.01 - Initial version                                       *)
(*                                                                            *)
(* Known Bugs  : none                                                         *)
(*                                                                            *)
(* Inspired by : https://github.com/rsaxvc/ggz-tools                          *)
(*                                                                            *)
(******************************************************************************)
Unit ugpx_parse;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils;

Type
  TCache = Record
    Code: String;
    Name: String;
    Type_: String;
    lat: Single;
    lon: Single;
    file_pos: integer;
    file_len: integer;
    awesomeness: Single;
    difficulty: Single;
    size: Single;
    terrain: Single;
  End;

  TCacheList = Array Of TCache;

  { TGPXParser }

  TGPXParser = Class
  public
    (*
     * Extrahiert aus einem GPX Container eine Liste aller enthaltenen wpt- Tags
     * und gibt die notwendigen Daten für die .ggz Erzeugung zurück.
     *)
    Function GetCachelist(Const Stream: Tstream): TCacheList;
  End;

Implementation

Uses dialogs;

{ TGPXParser }

Function TGPXParser.GetCachelist(Const Stream: Tstream): TCacheList;
Var
  s: String;
  p, sz: int64;
  state, c, i: integer;
  ch: Char;
  start: int64;
  sl: TStringList;
  DefFormat: TFormatSettings;
Begin
  (*
   * Da die Position der Wegpunkte Bytegenau erfolgen muss, dürfen LCL
   * lade routinen nicht verwendet werden, diese wandeln nämlich beim laden automatisch CR + LF in what ever um
   * Auch dürfen UTF8 Zeichen nicht als 1 sondern als Byteanzahl gewertet werden.
   *
   * Der unten anstehende Code parst die Datei und bestimmt die Byteposition aller <wpt Tags sowie deren Länge in Byte
   * anschließend extrahiert er die notwendigen daten und legt für jeden gefundenen "wpt" Eintrag ein Element in result an.
   *)
  DefFormat := FormatSettings;
  DefFormat.DecimalSeparator := '.';
  Stream.Position := 0;
  s := '';
  sz := Stream.Size;
  p := 0;
  c := 0;
  result := Nil;
  setlength(result, 1024);
  state := 0;
  sl := TStringList.Create;
  ch := #0;
  While p < sz Do Begin
    Stream.Read(ch, 1);
    Case state Of
      (*
       * Suche des Beginnenden tags "<wpt "
       *)
      0: Begin // Suche nach "<"
          If ch = '<' Then Begin
            state := 1;
            start := p;
          End;
        End;
      1: Begin // Suche nach "<w"
          If ch = 'w' Then Begin
            state := 2;
          End
          Else Begin
            state := 0;
          End;
        End;
      2: Begin // Suche nach "<wp"
          If ch = 'p' Then Begin
            state := 3;
          End
          Else Begin
            state := 0;
          End;
        End;
      3: Begin // Suche nach "<wpt"
          If ch = 't' Then Begin
            state := 4;
          End
          Else Begin
            state := 0;
          End;
        End;
      4: Begin // Suche nach "<wpt "
          If ch = ' ' Then Begin
            state := 5;
          End
          Else Begin
            state := 0;
          End;
        End;
      (*
       * Wir sind im wpt Tag und suchen nach dem Ende  "</wpt>"
       *)
      5: Begin // Suche nach "<"
          If ch = '<' Then Begin
            state := 6;
          End
          Else Begin
            state := 5;
          End;
        End;
      6: Begin // Suche nach "</"
          If ch = '/' Then Begin
            state := 7;
          End
          Else Begin
            state := 5;
          End;
        End;
      7: Begin // Suche nach "</w"
          If ch = 'w' Then Begin
            state := 8;
          End
          Else Begin
            state := 5;
          End;
        End;
      8: Begin // Suche nach "</wp"
          If ch = 'p' Then Begin
            state := 9;
          End
          Else Begin
            state := 5;
          End;
        End;
      9: Begin // Suche nach "</wpt"
          If ch = 't' Then Begin
            state := 10;
          End
          Else Begin
            state := 5;
          End;
        End;
      10: Begin // Suche nach "</wpt>"
          If ch = '>' Then Begin
            // in s steht nun der gesammte Wegpunkt
            result[c].file_pos := start;
            result[c].file_len := p - start + 1; // +1 weil wir das aktuelle Zeichen ja noch nicht mit gezählt haben ;)
            result[c].awesomeness := 3; // Todo : Rauskriegen was das sein soll !!
            sl.text := s;
            result[c].Type_ := '';
            For i := 0 To sl.count - 1 Do Begin
              // Tag Code
              If pos('<name>', sl[i]) <> 0 Then Begin
                s := copy(sl[i], pos('<name>', sl[i]) + length('<name>'), length(sl[i]));
                result[c].Code := copy(s, 1, pos('<', s) - 1);
              End;
              // Tag name
              If pos('<groundspeak:name>', sl[i]) <> 0 Then Begin
                s := copy(sl[i], pos('<groundspeak:name>', sl[i]) + length('<groundspeak:name>'), length(sl[i]));
                result[c].Name := copy(s, 1, pos('<', s) - 1);
              End;
              // Tag type
              If (pos('<groundspeak:type>', sl[i]) <> 0) And (result[c].Type_ = '') Then Begin
                s := copy(sl[i], pos('<groundspeak:type>', sl[i]) + length('<groundspeak:type>'), length(sl[i]));
                result[c].Type_ := copy(s, 1, pos('<', s) - 1);
              End;
              // tag Lat
              If pos('lat="', sl[i]) <> 0 Then Begin
                s := copy(sl[i], pos('lat="', sl[i]) + length('lat="'), length(sl[i]));
                result[c].lat := strtofloat(copy(s, 1, pos('"', s) - 1), DefFormat);
              End;
              // tag Lon
              If pos('lon="', sl[i]) <> 0 Then Begin
                s := copy(sl[i], pos('lon="', sl[i]) + length('lon="'), length(sl[i]));
                result[c].lon := strtofloat(copy(s, 1, pos('"', s) - 1), DefFormat);
              End;
              // tag awesomeness
              // ??
              // Tag difficulty
              If pos('<groundspeak:difficulty>', sl[i]) <> 0 Then Begin
                s := copy(sl[i], pos('<groundspeak:difficulty>', sl[i]) + length('<groundspeak:difficulty>'), length(sl[i]));
                result[c].difficulty := strtofloat(copy(s, 1, pos('<', s) - 1), DefFormat);
              End;
              // Tag size
              If pos('<groundspeak:container>', sl[i]) <> 0 Then Begin
                s := copy(sl[i], pos('<groundspeak:container>', sl[i]) + length('<groundspeak:container>'), length(sl[i]));
                s := lowercase(copy(s, 1, pos('<', s) - 1));
                Case s Of
                  'unknown',
                    'not chosen': result[c].size := -2;
                  'other': result[c].size := -1;
                  'virtual': result[c].size := 0;
                  // '': result[c].size := 1; ??
                  'micro': result[c].size := 2;
                  'small': result[c].size := 3;
                  'regular': result[c].size := 4;
                  'large': result[c].size := 5;
                Else Begin
                    showmessage('Kann Größe "' + s + '" für "' + result[c].Code + '" nicht bestimmen.');
                    halt;
                  End;
                End;
              End;
              // Tag terrain
              If pos('<groundspeak:terrain>', sl[i]) <> 0 Then Begin
                s := copy(sl[i], pos('<groundspeak:terrain>', sl[i]) + length('<groundspeak:terrain>'), length(sl[i]));
                result[c].terrain := strtofloat(copy(s, 1, pos('<', s) - 1), DefFormat);
              End;
            End;
            inc(c);
            If c > high(result) Then Begin
              setlength(result, high(result) + 1025);
            End;
            state := 0; // Suche des nächsten
          End
          Else Begin
            state := 5;
          End;
        End;
    End;
    // Wenn State <> 0 => Sammeln des "Strings" für wpt
    If state = 0 Then Begin
      s := '';
    End
    Else Begin
      s := s + ch;
    End;
    inc(p); // Hochzählen der Aktuellen Byte Position in der Datei
  End;
  setlength(result, c);
  sl.free;
End;

End.

