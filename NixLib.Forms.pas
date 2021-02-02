{
  NixLib.Forms.pas

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

unit NixLib.Forms;

interface

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows,
  WinApi.Messages,

  FMX.Platform.Win,
{$ENDIF}

  FMX.Forms;

type
{$REGION 'TFormHelper'}
  TFormHelper = class helper for TForm
  private
    function GetHandle: THandle; inline;

    function  GetWindowValue(AIndex: Integer): NativeInt; inline;
    procedure SetWindowValue(AIndex: Integer; AValue: NativeInt); inline;

    function  GetClassValue (AIndex: Integer): NativeInt; inline;
    procedure SetClassValue (AIndex: Integer; AValue: NativeInt); inline;

    function  GetShowState: NativeInt;
    procedure SetShowState(AValue: NativeInt);

    function GetActive: Boolean;
  public
    function WinPerform(const AMsg: Integer; const AWParam: WPARAM; const ALParam: LPARAM): LRESULT; inline;

    function WinMaxRestore: Integer;

    property HWND: THandle read GetHandle;

    property WinShowState: NativeInt read GetShowState write SetShowState;

    property WinActive: Boolean read GetActive;

    property WindowLong[AIndex: Integer]: NativeInt read GetWindowValue write SetWindowValue;
    property ClassLong [AIndex: Integer]: NativeInt read GetClassValue  write SetClassValue;

    property WinStyleEx:   NativeInt index GWL_EXSTYLE   read GetWindowValue write SetWindowValue;
    property WinStyle:     NativeInt index GWL_STYLE     read GetWindowValue write SetWindowValue;
    property WinInstance:  NativeInt index GWL_HINSTANCE read GetWindowValue write SetWindowValue;
    property WinID:        NativeInt index GWL_ID        read GetWindowValue write SetWindowValue;

    property ClassAtom:       NativeInt index GCW_ATOM          read GetClassValue write SetClassValue;
    property ClassBackground: NativeInt index GCL_HBRBACKGROUND read GetClassValue write SetClassValue;
    property ClassCursor:     NativeInt index GCL_HCURSOR       read GetClassValue write SetClassValue;
    property ClassIcon:       NativeInt index GCL_HICON         read GetClassValue write SetClassValue;
    property ClassSmallIcon:  NativeInt index GCL_HICONSM       read GetClassValue write SetClassValue;
    property ClassModule:     NativeInt index GCL_HMODULE       read GetClassValue write SetClassValue;
    property ClassMenuName:   NativeInt index GCL_MENUNAME      read GetClassValue write SetClassValue;
    property ClassStyle:      NativeInt index GCL_STYLE         read GetClassValue write SetClassValue;
  end;
{$ENDREGION}

implementation

{$REGION 'TFormHelper'}
function TFormHelper.GetHandle;
begin
{$IFDEF MSWINDOWS}
  Result := FormToHWND(Self);
{$ELSE}
  Result := 0;
{$ENDIF}
end;

function TFormHelper.GetWindowValue;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
    Result := WinApi.Windows.GetWindowLong(HWND, AIndex)
  else
{$ENDIF}
    Result := 0;
end;

procedure TFormHelper.SetWindowValue;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
    WinApi.Windows.SetWindowLong(HWND, AIndex, AValue);
{$ENDIF}
end;

function TFormHelper.GetClassValue;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
    Result := WinApi.Windows.GetClassLong(HWND, AIndex)
  else
{$ENDIF}
    Result := 0;
end;

procedure TFormHelper.SetClassValue;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
    WinApi.Windows.SetClassLong(HWND, AIndex, AValue);
{$ENDIF}
end;

function TFormHelper.GetShowState;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
  begin
    var wp: TWindowPlacement;

    FillChar(wp, 0, SizeOf(wp));
    wp.length := Sizeof(wp);

    GetWindowPlacement(FormToHWND(Self), wp);

    Result := wp.showCmd;
  end
  else
{$ENDIF}
    Result := 0;
end;

procedure TFormHelper.SetShowState;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
    ShowWindowAsync(HWND, AValue);
{$ENDIF}
end;

function TFormHelper.GetActive;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
    Result := GetForegroundWindow = HWND
  else
{$ENDIF}
    Result := True;
end;

function TFormHelper.WinPerform;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
    Result := SendMessage(HWND, AMsg, AWParam, ALParam)
  else
{$ENDIF}
    Result := 0;
end;

function TFormHelper.WinMaxRestore;
begin
{$IFDEF MSWINDOWS}
  if HWND <> 0 then
  begin
    if WinShowState = SW_SHOWMAXIMIZED then
      Result := SW_SHOWNORMAL
    else
      Result := SW_MAXIMIZE;

    WinShowState := Result;
  end
  else
{$ENDIF}
    Result := 0;
end;
{$ENDREGION}

end.

