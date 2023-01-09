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
(*
 * Include File zur Steuerung Projectweiter Configurationen
 * dieses Includefile muss bei jeder Verwendeten .pas Datei
 * eingebunden sein.
 *)
{$IFDEF Linux}
{$DEFINE NoShowModal} // Auf dem Odroid unter LXDE machen Modale Fenster Probleme.
{$ENDIF}

(*
 * Ist dieses Flag gesetzt, wird das mehrfache Invalidate nicht gesetzt.
 * Bei Raspbian scheint das nicht nötig, sogar eher Problematisch.
 * Auf Windows ist es notwendig.
 *)
{.$DEFINE DoNotInvalidateOpenGLWindow}

