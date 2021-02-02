{
  NixLib.Cadencer.pas

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

unit NixLib.Cadencer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  System.Threading,
  System.SyncObjs,
  System.TimeSpan,

  NixLib.Timing;

type
  TCadencer = class;

  TTickEvent = function(ASender: TCadencer; ADelta: Double): Boolean of object;
  TTickProc  = reference to function(ASender: TCadencer; ADelta: Double): Boolean;

{$REGION 'TCadencer'}
  TCadencer = class
  private
    FTargetTicksPerSec: Integer;
    FTicksPerSec:       Double;

    FSynchronize: Boolean;

    FRunning:    Boolean;
    FStopSignal: Boolean;

    FOnTick:  TTickEvent;
    FOnStart: TNotifyEvent;
    FOnStop:  TNotifyEvent;

    FTickProc: TTickProc;

    FTask: ITask;

    function GetThreaded: Boolean; inline;
  protected
    procedure Execute(ASender: TObject); virtual;
    procedure Stopped;                   virtual;
  public
    constructor Create(const ATargetTicksPerSec: Integer = 60);
    destructor  Destroy; override;

    procedure Start(const AThreaded: Boolean = True; const ATickProc: TTickProc = nil); virtual;
    procedure Stop; virtual;

    procedure Tick(ASender: TObject; ADelta: Double); virtual;

    property TargetTicksPerSec: Integer read FTargetTicksPerSec write FTargetTicksPerSec;
    property TicksPerSec:       Double  read FTicksPerSec;

    property Synchronize: Boolean read FSynchronize write FSynchronize;

    property Running: Boolean read fRunning;

    property Threaded: Boolean read GetThreaded;

    property OnTick:  TTickEvent    read FOnTick  write FOnTick;
    property OnStart: TNotifyEvent  read FOnStart write FOnStart;
    property OnStop:  TNotifyEvent  read FOnStop  write FOnStop;

    property TickProc: TTickProc read FTickProc write FTickProc;
  end;
{$ENDREGION}

implementation

{$REGION 'TCadencer'}
function TCadencer.GetThreaded: Boolean;
begin
  Result := fTask <> nil;
end;

procedure TCadencer.Execute;
var
  TickTimer: TStopwatch;
  TickWatch: TStopwatch;
  TickCount: Integer;
  Delta:     Double;
begin
  FStopSignal := False;
  FRunning    := True;

  TickTimer := TStopwatch.StartNew;
  TickWatch := TStopwatch.StartNew;
  TickCount := 0;

  try
    repeat
      Delta := TickTimer.WaitFor(1 / FTargetTicksPerSec, False, True);

      if Threaded and FSynchronize then
        TThread.Synchronize(nil, procedure begin Tick(ASender, Delta); end)
      else
        Tick(ASender, Delta);

      Inc(TickCount);

      if TickWatch.ElapsedSeconds > 1 then
      begin
        FTicksPerSec := TickCount / TickWatch.Restart;
        TickCount    := 0;
      end;
    until FStopSignal;
  finally
    if Threaded then
      TThread.Queue(nil, Stopped)
    else
      Stopped;
  end;
end;

procedure TCadencer.Stopped;
begin
  if not FRunning then
    Exit;

  FTask := nil;
  FRunning := False;

  if Assigned(FOnStop) then
    FOnStop(Self);
end;

constructor TCadencer.Create;
begin
  inherited Create;

  FTargetTicksPerSec := ATargetTicksPerSec;

  FSynchronize := True;
end;

destructor TCadencer.Destroy;
begin
  Stop;

  inherited;
end;

procedure TCadencer.Start;
begin
  if FRunning then
    Exit;

  FTask := nil;

  if Assigned(ATickProc) then
    FTickProc := ATickProc;

  if Assigned(FOnStart) then
    FOnStart(Self);

  if AThreaded then
    FTask := TTask.Run(Self, Execute)
  else
    Execute(Self);
end;

procedure TCadencer.Stop;
begin
  FStopSignal := True;
end;

procedure TCadencer.Tick;
begin
  if Assigned(FOnTick) then
    if not FOnTick(Self, ADelta) then
      FStopSignal := True;

  if Assigned(FTickProc) then
    if not FTickProc(Self, ADelta) then
      FStopSignal := True;
end;
{$ENDREGION}

end.

