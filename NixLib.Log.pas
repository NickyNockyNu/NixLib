{
  NixLib.Log.pas

    Copyright © 2021 Nicholas Smith

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}

unit NixLib.Log;

interface

{$IFDEF MSWINDOWS}
uses
  WinApi.Windows,
{$ENDIF}
  System.SysUtils,

  NixLib.Globals,
  NixLib.Strings;

const
  LogIDMessage = 0;
  LogIDHint    = 1;
  LogIDWarning = 2;
  LogIDError   = 3;
  LogIDFatal   = 4;

  LogIDConfig = 10;

  LogIDLoad = 20;
  LogIDSave = 21;

  LogIDSystem = 30;
  LogIDUser   = 31;

  LogIDDebug = 40;

type
  TLogProc = reference to procedure(AStr: String; const AEventID: Integer = LogIDMessage);

var
  LogProc:    TLogProc = nil;
  LogTimeFmt: String = 'd/m/y h:mm:ss.zzz > ';
  LogEnabled: Boolean = False;

procedure Log(AStr: String; const AEventID: Integer = LogIDMessage);

function LogIDToStr(AEventID: Integer; const AUnicodeGlyph: Boolean = False): String;

implementation

procedure Log;
var
  O: String;
begin
  if not LogEnabled then
    Exit;

  if (AEventID = LogIDDebug) and (not AppDebug) then
    Exit;

  if Assigned(LogProc) then
    LogProc(AStr, AEventID)
  else
  begin
    O := AStr.Trim;

    if O.IsEmpty then
      Exit;

    O := LogIDToStr(AEventID).Append(O, ': ');
    O := FormatDateTime(LogTimeFmt, Now).Append(O);

{$IFDEF MSWINDOWS}
    AllocConsole;
    WriteLn(O);
{$ENDIF}
  end;

  if AEventID = LogIDFatal then
    Halt;
end;

function LogIDToStr;
begin
  case AEventID of
    LogIDMessage: if AUnicodeGlyph then Result := '🗨' else Result := '';
    LogIDHint:    if AUnicodeGlyph then Result := '🔹' else Result := 'Hint';
    LogIDWarning: if AUnicodeGlyph then Result := '⚠' else Result := 'Warning';
    LogIDError:   if AUnicodeGlyph then Result := '⛔' else Result := 'Error';
    LogIDFatal:   if AUnicodeGlyph then Result := '☠' else Result := 'Fatal';

    LogIDConfig: if AUnicodeGlyph then Result := '🔧' else Result := 'Config';

    LogIDLoad: if AUnicodeGlyph then Result := '💾' else Result := 'Load';
    LogIDSave: if AUnicodeGlyph then Result := '💾' else Result := 'Save';

    LogIDSystem: if AUnicodeGlyph then Result := '🖥' else Result := 'System';
    LogIDUser:   if AUnicodeGlyph then Result := '👤' else Result := 'User';

    LogIDDebug: if AUnicodeGlyph then Result := '🐞' else Result := 'Debug';
  else
    if AUnicodeGlyph then Result := '🖥' else Result := 'Event' + IntToStr(AEventID);
  end;
end;

end.

