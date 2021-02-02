{
  NixLib.Timing.pas

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

unit NixLib.Timing;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  System.TimeSpan;

const
  msPerSec  = Int64(1000);
  msPerMin  = Int64(msPerSec  * 60);
  msPerHour = Int64(msPerMin  * 60);
  msPerDay  = Int64(msPerHour * 24);
  msPerWeek = Int64(msPerDay  * 7);
  msPerYear = Int64(msPerWeek * 52);

type
{$REGION 'TStopwatchHelper'}
  TStopwatchHelper = record helper for TStopwatch
  public
    class function SysSeconds: Double; static; inline;

    function Restart: Double; inline;

    function ElapsedSeconds: Double; inline;

    function Expired     (ASeconds: Double): Boolean; inline;
    function ExpiredDelta(ASeconds: Double): Double;

    function WaitFor(ASeconds: Double; AResetBefore: Boolean = True; AResetAfter: Boolean = False): Double;
  end;
{$ENDREGION}

implementation

{$REGION 'TStopwatchHelper'}
class function TStopwatchHelper.SysSeconds;
begin
  Result := GetTimeStamp / TTimeSpan.TicksPerSecond;
end;

function TStopwatchHelper.Restart;
begin
  Result := ElapsedSeconds;
  Self   := StartNew;
end;

function TStopwatchHelper.ElapsedSeconds;
begin
  Result := Elapsed.TotalSeconds;
end;

function TStopwatchHelper.Expired;
begin
  Result := ExpiredDelta(ASeconds) <= 0;
end;

function TStopwatchHelper.ExpiredDelta;
begin
  Result := ASeconds - ElapsedSeconds;
  if Result <= 0 then Restart;
end;

function TStopwatchHelper.WaitFor;
begin
  if AResetBefore then
    Reset;

  Start;

  if ASeconds > 0 then
  begin
    while ElapsedSeconds < ASeconds do
      TThread.Yield;

    Result := (ElapsedSeconds / ASeconds);
  end
  else
    Result := 1;

  if AResetAfter then
    Restart;
end;
{$ENDREGION}

end.

