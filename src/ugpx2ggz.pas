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
(*                                                                            *)
(* Inspired by : https://github.com/rsaxvc/ggz-tools                          *)
(*                                                                            *)
(******************************************************************************)

Unit ugpx2ggz;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils;

(*
 * Converts the .gpx files given in gpxlist, to a valid ggz file
 *
 * false if an error occours
 *
 *)
Function gpx2ggz(Const gpxlist: TStringlist; ggzfilename, Workdir: String): boolean;

Implementation

Uses LazFileUtils, ugpx_parse, ucrc, zipper, Laz2_DOM, laz2_XMLWrite;

(*
 * Berechnen der CRC32 Checksumme passend zu ZLib
 *)

Function crc32(Const Stream: TStream): dWord;
Begin
  Stream.position := 0;
  // Berechnen 32-Bit Result
  Result := $FFFFFFFF;
  CalcCRC32(Stream, Result);
  Result := Result Xor $FFFFFFFF;
End;

Function CreateIndexXML(Const gpxlist: TStringlist; filename: String): integer;
Var
  Doc: TXMLDocument;
  DefFormat: TFormatSettings;

  (*
   * Hängt an Parent den Knoten der Form <Tagname> Content </Tagname>
   *)
  Procedure AddTag(Const Parent: TDOMNode; TagName, Content: String);
  Var
    nofilho, tmp: TDOMNode;
  Begin
    nofilho := Doc.CreateElement(TagName);
    tmp := Doc.CreateTextNode(Content);
    nofilho.AppendChild(tmp);
    Parent.Appendchild(nofilho);
  End;

  (*
   * Convertiert TCache in einen XML Knoten
   *)
  Function CacheItemToNode(Const Data: TCache): TDOMNode;
  Var
    ratings: TDOMNode;
  Begin
    result := Doc.CreateElement('gch');
    Addtag(result, 'code', data.Code);
    Addtag(result, 'name', data.Name);
    Addtag(result, 'type', Data.Type_);
    Addtag(result, 'lat', format('%1.6f', [data.lat], DefFormat));
    Addtag(result, 'lon', format('%1.6f', [data.lon], DefFormat));
    Addtag(result, 'file_pos', format('%d', [data.file_pos], DefFormat));
    Addtag(result, 'file_len', format('%d', [data.file_len], DefFormat));
    ratings := Doc.CreateElement('ratings');
    result.AppendChild(ratings);
    Addtag(ratings, 'awesomeness', format('%1.6f', [data.awesomeness], DefFormat));
    Addtag(ratings, 'difficulty', format('%1.6f', [data.difficulty], DefFormat));
    Addtag(ratings, 'size', format('%1.6f', [data.size], DefFormat));
    Addtag(ratings, 'terrain', format('%1.6f', [data.terrain], DefFormat));
  End;

Var
  //small_files,
  i, j: integer;
  //sz: int64;
  p: TGPXParser;
  ggzNode, fileNode: TDOMNode;
  cl: TCacheList;
  f: TFilestream;
  m: TMemoryStream;
Begin
  DefFormat := FormatSettings;
  DefFormat.DecimalSeparator := '.';

  result := 0;
  //small_files := 0;
  p := TGPXParser.Create;
  Doc := TXMLDocument.Create;
  // Erzeuge einen Wurzelknoten
  ggzNode := Doc.CreateElement('ggz');
  Doc.Appendchild(ggzNode); // sichere den Wurzelelement
  // Create a parent node
  ggzNode := Doc.DocumentElement;
  m := TMemoryStream.Create;
  For i := 0 To gpxlist.Count - 1 Do Begin
    f := TFileStream.Create(gpxlist[i], fmOpenRead);
    m.Clear;
    m.CopyFrom(f, f.Size);
    f.free;
    m.Position := 0;
    // Writeln('Processing : ' + gpxlist[i]);
    //sz := FileSizeUtf8(gpxlist[i]);
    //If sz < 100 * 1024 Then Begin
      //inc(small_files);
      //If (small_files = 2) Then Begin
        // writeln('Warning:packing multiple small files(<100KiB)');
        // writeln('These should be combined');
      //End;
    //End;
    //If sz > 5 * 1024 * 1024 Then Begin
      // writeln('Warning:large file(>5Mib):' + gpxlist[i]);
      // writeln('GPX size:' + inttostr(sz));
      // writeln('This should be split into smaller files');
    //End;
    fileNode := Doc.CreateElement('file');
    ggzNode.Appendchild(fileNode);
    AddTag(fileNode, 'name', ExtractFileName(gpxlist[i]));
    AddTag(fileNode, 'crc', format('%X', [crc32(m)], DefFormat));
    cl := p.GetCachelist(m);
    For j := 0 To high(cl) Do Begin
      fileNode.Appendchild(CacheItemToNode(cl[j]));
      inc(result);
    End;
    // writeln(format('Found %d caches.', [length(cl)]));
    If length(cl) = 0 Then Begin
      //writeln('Error invalid file : "' + gpxlist[i] + '" cancel process.');
      result := 0;
      p.free;
      doc.free;
      m.free;
      exit;
    End;
    setlength(cl, 0);
  End;
  m.free;
  p.free;
  writeXMLFile(Doc, filename);
  doc.free;
End;

Function gpx2ggz(Const gpxlist: TStringlist; ggzfilename, Workdir: String
  ): boolean;
Var
  i: integer;
  z: TZipper;
  tmpIndexName: String;
Begin
  result := false;
  tmpIndexName := IncludeTrailingPathDelimiter(Workdir) + 'index_tmp.xml'; // Egal was, wird nachher wieder gelöscht, sollte aber nicht existieren
  If FileExistsUTF8(tmpIndexName) Then Begin
    If Not DeleteFileUTF8(tmpIndexName) Then Begin
      // writeln('Error tempfilename "' + tmpIndexName + '" already exists.');
      exit;
    End;
  End;
  // 1. Erzeugen der Index Datei
  // writeln('Create index list');
  i := CreateIndexXML(gpxlist, tmpIndexName);
  If i = 0 Then exit; // Keine Caches gefunden
  // writeln(format('Created indexes for %d caches', [i]));
  // 2. Erstellen eines Zip Files mit allen gpx Dateien und der index.xml
  // writeln('Create output file: ' + ggzfilename);
  z := TZipper.Create;
  z.FileName := ggzfilename;
  For i := 0 To gpxlist.Count - 1 Do Begin
    z.Entries.AddFileEntry(gpxlist[i], 'data' + PathDelim + ExtractFileName(gpxlist[i]));
  End;
  z.Entries.AddFileEntry(tmpIndexName, 'index' + PathDelim + 'com' + PathDelim + 'garmin' + PathDelim + 'geocaches' + PathDelim + 'v0' + PathDelim + 'index.xml');
  z.ZipAllFiles;
  z.free;
  // writeln('Done.');
  // Aufräumen und Raus
  // writeln('Clean tmp file.');
  DeleteFileUTF8(tmpIndexName);
  // writeln('Done.');
  result := true;
End;

End.

