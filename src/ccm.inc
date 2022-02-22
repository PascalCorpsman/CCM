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

