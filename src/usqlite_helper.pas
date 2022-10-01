(******************************************************************************)
(* uSQL_Helper                                                     01.10.2022 *)
(*                                                                            *)
(* Version     : 0.01                                                         *)
(*                                                                            *)
(* Autor       : Corpsman                                                     *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : Collection of usefull SQLLite3 commands and routines         *)
(*                                                                            *)
(* License     : This component is postcardware for non commercial use only.  *)
(*               If you like the component, send me a postcard:               *)
(*                                                                            *)
(*                    Uwe Schächterle                                         *)
(*                    Buhlstraße 85                                           *)
(*                    71384 Weinstadt - Germany                               *)
(*                                                                            *)
(*               It is not allowed to change or remove this license from any  *)
(*               source file of the project.                                  *)
(*                                                                            *)
(*                                                                            *)
(* Warranty    : There is no warranty, use at your own risk.                  *)
(*                                                                            *)
(* History     : 0.01 - Initial version                                       *)
(*                                                                            *)
(* Known Bugs  : none                                                         *)
(*                                                                            *)
(******************************************************************************)

Unit usqlite_helper;

{$MODE ObjFPC}{$H+}

Interface

Uses
  sqldb, Classes, SysUtils;

(*
 * Startet eine SQLQuery im Anschluss muss diese nur noch ausgewertet werden.
 * Result = false, Fehler
 * Result = True, Auswertung via :
 *
 *  While (Not SQLQuery.EOF) Do Begin
 *    -- Auswertung des jeweiligen Datensatzes
 *    SQLQuery.Next;
 *  End;
 *  SQLQuery.Active := false; // -- Optional beenden des Kommunikationskanals
 *)
Function StartSQLQuery(Const SQLQuery: TSQLQuery; Query: String): Boolean;

(*
 * Using : - Call CommitSQLTransactionQuery as many times you want.
 *         - Write your results to the database by
 *           if assigned(SQLTransaction) the function will automatically commit otherwise you have to call
 *           SQLTransaction.Commit;
 *           by yourself !
 *)
Function CommitSQLTransactionQuery(Const SQLQuery: TSQLQuery; aText: String; SQLTransaction: TSQLTransaction = Nil): Boolean;

Function ColumnExistsInTable(Const SQLQuery: TSQLQuery; ColumnName, TableName: String): Boolean;
Function GetAllColumsFromTable(Const SQLQuery: TSQLQuery; TableName: String): TStringlist;

(*
 * Entfernt alle SQL-Kommentare aus einer Query
 *)
Function RemoveCommentFromSQLQuery(Query: String): String;

(*
 * Strings dürfen nicht direkt an SQL Statements übergeben werden, alle Strings müssen vorher
 * umgewandelt werden (entfernen/ Umwandeln unerlaubter Symbole ...)
 *)
Function ToSQLString(Value: String): String;
Function FromSQLString(Value: String): String;

Implementation

Uses DB, Dialogs;

Function ToSQLString(Value: String): String;
Begin
  value := StringReplace(value, '+', '++', [rfReplaceAll]);
  value := StringReplace(value, '-', '+5', [rfReplaceAll]); // -- ist ein Einleitender Kommentar -> das muss verhindert werden
  value := StringReplace(value, ';', '+4', [rfReplaceAll]); // Die Commit Routine reagiert empfindlich auf ";"
  value := StringReplace(value, #13, '+3', [rfReplaceAll]);
  value := StringReplace(value, '''', '+2', [rfReplaceAll]); // ' = Trennzeichen String in SQL => so wird eine SQL-Injection erschwert
  value := StringReplace(value, '"', '+1', [rfReplaceAll]); // " =  Trennzeichen String in SQL => so wird eine SQL-Injection erschwert
  result := StringReplace(value, #10, '+0', [rfReplaceAll]);
End;

Function FromSQLString(Value: String): String;
Var
  i: integer;
Begin
  // Das geht nicht via Stringreplace, da ein String der Form 8+13 nach 8++13
  // übersetzt wird und die Rückübersetzung macht daraus dann 8+"3
  result := '';
  i := 1;
  While i <= length(value) Do Begin
    If value[i] = '+' Then Begin
      Case value[i + 1] Of
        '0': result := result + #10;
        '1': result := result + '"';
        '2': result := result + '''';
        '3': result := result + #13;
        '4': result := result + ';';
        '5': result := result + '-';
      Else
        result := result + value[i + 1]; // Unbekannt
      End;
      inc(i);
    End
    Else Begin
      result := result + value[i];
    End;
    inc(i);
  End;
End;

Function RemoveCommentFromSQLQuery(Query: String): String;
Var
  j, i: integer;
  instring, instring2: Boolean;
Begin
  result := Query + LineEnding; // Falls die Query mit einem Kommentar endet
  instring := false; // " Kommentare
  instring2 := false; // ' Kommentare
  i := 1;
  j := -1;
  While i < length(result) Do Begin
    If j = -1 Then Begin
      If result[i] = '"' Then Begin // Die String Erkennung, darf in Kommentaren nicht getriggert werden.
        instring := Not instring;
      End;
      If result[i] = '''' Then Begin // Die String Erkennung, darf in Kommentaren nicht getriggert werden.
        instring2 := Not instring2;
      End;
      If (Not instring) And (Not instring2) Then Begin
        // Start eines Kommentars
        If (result[i] = '-') And (result[i + 1] = '-') Then Begin
          // Wir haben den Begin eines Kommentars gefunden
          j := i;
        End;
      End;
    End
    Else Begin
      // Der Kommentar endet beim cr oder lf
      If ((result[i] = #13) Or (result[i] = #10)) Then Begin
        delete(result, j, i - j);
        i := j - 1;
        j := -1;
      End;
    End;
    i := i + 1;
  End;
End;

Function StartSQLQuery(Const SQLQuery: TSQLQuery; Query: String): Boolean;
Begin
  Query := RemoveCommentFromSQLQuery(Query);
  result := false;
  // Unnatürlicher Abbruch
  If Not assigned(SQLQuery) Then exit;
  If trim(query) = '' Then exit;
  SQLQuery.Active := false;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Text := Query;
  Try
    SQLQuery.Open;
  Except
    On e: Exception Do Begin
      ShowMessage('Error invalid query.' + LineEnding + 'Errormessage:' + LineEnding + e.Message);
      exit;
    End;
  End;
  result := true;
End;

Function CommitSQLTransactionQuery(Const SQLQuery: TSQLQuery; aText: String;
  SQLTransaction: TSQLTransaction): Boolean;
Var
  t: String;
  i: integer;
  instring, instring2: Boolean;
Begin
  result := false;
  //Unnatürlicher Abbruch
  If Not assigned(SQLQuery) Then exit;
  If trim(aText) = '' Then exit;
  SQLQuery.Active := false;
  SQLQuery.SQL.Clear;
  // Unterstützung für "Viele" Befehle hintereinander, bereinigen unnötiger Symbole
  aText := RemoveCommentFromSQLQuery(aText);
  aText := trim(aText) + ';';
  instring := false; // " Kommentare
  instring2 := false; // ' Kommentare
  t := '';
  Try
    For i := 1 To length(aText) Do Begin
      If aText[i] = '"' Then Begin // Die String Erkennung
        instring := Not instring;
      End;
      If aText[i] = '''' Then Begin // Die String Erkennung
        instring2 := Not instring2;
      End;
      t := t + aText[i];
      If (Not instring) And (Not instring2) Then Begin
        If (aText[i] = ';') Then Begin
          t := trim(t);
          If (t <> '') And (t <> ';') Then Begin
            result := true; // Mindestens eine Query wurde ausgeführt -> nur dann ist das Ergebnis True
            SQLQuery.SQL.Text := t;
            SQLQuery.ExecSQL;
            If assigned(SQLTransaction) Then Begin
              SQLTransaction.Commit;
            End;
          End;
          t := '';
        End;
      End;
    End;
  Except
    On e: Exception Do Begin
      ShowMessage('Error invalid query.' + LineEnding + 'Errormessage:' + LineEnding + e.Message);
      If assigned(SQLTransaction) Then Begin
        SQLTransaction.Rollback;
      End;
      result := false;
    End;
  End;
  If assigned(SQLTransaction) Then Begin
    SQLQuery.Active := false; // den Kommunikationskanal wieder frei geben, darf aber nur wenn auch commited wurde !
  End;
End;

Function ColumnExistsInTable(Const SQLQuery: TSQLQuery; ColumnName,
  TableName: String): Boolean;
Var
  f: tfield;
Begin
  result := false;
  StartSQLQuery(SQLQuery, 'Pragma table_info(' + TableName + ')');
  f := SQLQuery.FieldByName('name');
  While (Not SQLQuery.EOF) Do Begin
    If lowercase(f.AsString) = lowercase(ColumnName) Then Begin
      result := true;
      exit;
    End;
    SQLQuery.Next;
  End;
End;

Function GetAllColumsFromTable(Const SQLQuery: TSQLQuery; TableName: String
  ): TStringlist;
Var
  f: TField;
Begin
  result := TStringList.Create;
  If Not StartSQLQuery(SQLQuery, 'PRAGMA table_info(' + TableName + ');') Then exit;
  f := SQLQuery.FieldByName('name');
  While (Not SQLQuery.EOF) Do Begin
    result.Add(F.AsString);
    SQLQuery.Next;
  End;
End;

End.

