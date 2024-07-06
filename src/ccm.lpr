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
Program ccm;

{$MODE objfpc}{$H+}

Uses
{$IFDEF UNIX}
  cthreads, // Notwendig für
  clocale, // Gemäß: https://wiki.lazarus.freepascal.org/Multiplatform_Programming_Guide muss dies eingebunden werden, damit DefaultFormatSettings definiert ist.
{$ENDIF}
  Interfaces, // this includes the LCL widgetset
{$IFDEF Windows}
  windows,
{$ENDIF}
  Forms, Unit1, Unit2, Unit3, Unit4, Unit5, Unit6, Unit7, Unit8, Unit9, Unit10, 
  Unit11, Unit12, Unit13, Unit14, Unit15, Unit16, Unit17, Unit18, Unit19, Unit20, 
  Unit21, unit22, unit27, Unit23, Unit24, Unit25, Unit26, Unit28, unit29, unit30, 
  Unit31, Unit32, Unit33, Unit34, Unit35, Unit36, Unit37, Unit38, Unit39, Unit40, 
  Unit41, unit42, Unit43, Unit44, uopengl_font_common;

{$IFDEF Windows}
{$IFDEF CPU32}
{$SETPEFLAGS IMAGE_FILE_LARGE_ADDRESS_AWARE}
{$ENDIF}
{$ENDIF}

{$R *.res}

Begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm8, Form8);
  Application.CreateForm(TForm9, Form9);
  Application.CreateForm(TForm10, Form10);
  Application.CreateForm(TForm11, Form11);
  Application.CreateForm(TForm12, Form12);
  Application.CreateForm(TForm13, Form13);
  Application.CreateForm(TForm14, Form14);
  Application.CreateForm(TForm15, Form15);
  Application.CreateForm(TForm16, Form16);
  Application.CreateForm(TForm17, Form17);
  Application.CreateForm(TForm18, Form18);
  Application.CreateForm(TForm19, Form19);
  Application.CreateForm(TForm20, Form20);
  Application.CreateForm(TForm21, Form21);
  Application.CreateForm(TForm22, Form22);
  Application.CreateForm(TForm23, Form23);
  Application.CreateForm(TForm24, Form24);
  Application.CreateForm(TForm25, Form25);
  Application.CreateForm(TForm26, Form26);
  Application.CreateForm(TForm27, Form27);
  Application.CreateForm(TForm28, Form28);
  Application.CreateForm(TForm29, Form29);
  Application.CreateForm(TForm30, Form30);
  Application.CreateForm(TForm31, Form31);
  Application.CreateForm(TForm32, Form32);
  Application.CreateForm(TForm33, Form33);
  Application.CreateForm(TForm34, Form34);
  Application.CreateForm(TForm35, Form35);
  Application.CreateForm(TForm36, Form36);
  Application.CreateForm(TForm37, Form37);
  Application.CreateForm(TForm38, Form38);
  Application.CreateForm(TForm39, Form39);
  Application.CreateForm(TForm40, Form40);
  Application.CreateForm(TForm41, Form41);
  Application.CreateForm(TForm42, Form42);
  Application.CreateForm(TForm43, Form43);
  Application.CreateForm(TForm44, Form44);
  Application.Run;
End.

