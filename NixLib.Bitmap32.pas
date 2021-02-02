{
  NixLib.Bitmap32.pas

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

unit NixLib.Bitmap32;

interface

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ENDIF}

  System.UITypes,

  NixLib.Types,
  NixLib.Memory;

const
  PixelFormat32 = 2498570;

type
{$REGION 'TColour32'}
  TColour32 = record
  private

  public
    class function Create (const AR, AG, AB: Byte;   const AA: Byte   = $FF): TColour32; static; inline;
    class function CreateF(const AR, AG, AB: Single; const AA: Single = 1.0): TColour32; static; inline;

    class operator Implicit(AColour: TAlphaColor): TColour32;   overload;
    class operator Implicit(AColour: TColour32):   TAlphaColor; overload;

    class operator Add(AColour1, AColour2: TColour32): TColour32;

    class operator Multiply(AColour: TColour32; AValue: Single): TColour32;

    function Pastel(ALightness, ASaturation: Single): TColour32;

  case Cardinal of
    0: (Colour: DWord);
    1: (Channels: array[0..3] of Byte);
    2: ({$IFDEF BIGENDIAN}A, R, G, B{$ELSE}B, G, R, A{$ENDIF}: Byte);
  end;
{$ENDREGION}

{$REGION 'TCustomBitmap32'}
  TBitmapLockMode = (lmRead, lmWrite, lmUserBuf);
  TBitmapLockModes = set of TBitmapLockMode;

  TBitmapData = packed record
    Width:        Cardinal;
    Height:       Cardinal;
    Stride:       Integer;
    PixelFormat:  Integer;
    Scan0:        Pointer;
    Reserved:     PInteger;
    Size:         Cardinal;
    LockMode:     TBitmapLockModes;
    LockX:        Cardinal;
    LockY:        Cardinal;
  end;

  TScanline = TMemory<TColour32>;

  TCustomBitmap32 = class abstract
  protected
    procedure SetWidth (AValue: Cardinal); virtual;
    procedure SetHeight(AValue: Cardinal); virtual;
  public
    BitmapData: TBitmapData;
    Scanlines:  array of TScanline;

    constructor Create(const AWidth: Integer = 0; const AHeight: Integer = 0);
    destructor  Destroy; override;

    function Resize(const AWidth, AHeight: Cardinal): Boolean; virtual;

    function Lock  (var ABitmapData: TBitmapData; const Ax, Ay, Aw, Ah: Integer; const ALockMode: TBitmapLockModes): Boolean; virtual;
    function Unlock(var ABitmapData: TBitmapData): Boolean; virtual;

    property Width:  Cardinal read BitmapData.Width  write SetWidth;
    property Height: Cardinal read BitmapData.Height write SetHeight;
    property Stride: Integer  read BitmapData.Stride;
    property Bits:   Pointer  read BitmapData.Scan0;
    property Size:   Cardinal read BitmapData.Size;
  end;
{$ENDREGION}

{$REGION 'TSubBitmap32'}
  TSubBitmap32 = class(TCustomBitmap32)
  private
    FParent: TCustomBitmap32;
  public
    constructor Create(const AParent: TCustomBitmap32; const AX, AY, AW, AH: Integer);
    destructor  Destroy; override;

    property Parent: TCustomBitmap32 read FParent;
  end;
{$ENDREGION}

{$REGION 'TDIB32'}
{$IFDEF MSWINDOWS}
  TDIB32 = class(TCustomBitmap32)
  private
    FHandle: HBITMAP;
    FInfo:   BITMAPINFO;
    FHeader: BITMAPINFOHEADER;
    FDC:     HDC;

    function GetDC: HDC;
  public
    function Resize(const AWidth, AHeight: Cardinal): Boolean; override;

    procedure BltToDC(const ADC: HDC; const AX: Integer = 0; const AY: Integer = 0; const AW: Integer = 0; const AH: Integer = 0);

    procedure CreateDC;
    procedure ReleaseDC;

    property Handle: HBITMAP read FHandle;
    property DC:     HDC     read GetDC;
  end;
{$ENDIF}
{$ENDREGION}

implementation

{$REGION 'TColour32'}
class function TColour32.Create;
begin
  Result.R := AR;
  Result.G := AG;
  Result.B := AB;
  Result.A := AA;
end;

class function TColour32.CreateF;
begin
  Result := Create(Byte.Clamp($FF * AR), Byte.Clamp($FF * AG), Byte.Clamp($FF * AB), Byte.Clamp($FF * AA));
end;

class operator TColour32.Implicit(AColour: TAlphaColor): TColour32;
begin
  Result.Colour := AColour;
end;

class operator TColour32.Implicit(AColour: TColour32): TAlphaColor;
begin
  Result := AColour.Colour;
end;

class operator TColour32.Add(AColour1, AColour2: TColour32): TColour32;
begin
  Result.R := Byte.Clamp((AColour1.R + AColour2.R) / 2);
  Result.G := Byte.Clamp((AColour1.G + AColour2.G) / 2);
  Result.B := Byte.Clamp((AColour1.B + AColour2.B) / 2);
  Result.A := Byte.Clamp((AColour1.A + AColour2.A) / 2);
end;

function TColour32.Pastel;
var
  Base: Byte;
begin
  Base     := Round($FF * ALightness);
  Result.R := Base + Byte.Clamp(R * ASaturation);
  Result.G := Base + Byte.Clamp(G * ASaturation);
  Result.B := Base + Byte.Clamp(B * ASaturation);
  Result.A := A;
end;

class operator TColour32.Multiply(AColour: TColour32; AValue: Single): TColour32;
begin
  Result.R := Byte.Clamp(AColour.R * AValue);
  Result.G := Byte.Clamp(AColour.G * AValue);
  Result.B := Byte.Clamp(AColour.B * AValue);
  Result.A := Byte.Clamp(AColour.A * AValue);
end;
{$ENDREGION}

{$REGION 'TCustomBitmap32'}
procedure TCustomBitmap32.SetWidth;
begin
  Resize(AValue, Height);
end;

procedure TCustomBitmap32.SetHeight;
begin
  Resize(Width, AValue);
end;

constructor TCustomBitmap32.Create;
begin
  inherited Create;

  if (AWidth <> 0) and (AHeight <> 0) then
    Resize(AWidth, AHeight);
end;

destructor TCustomBitmap32.Destroy;
begin
  Resize(0, 0);

  inherited;
end;

function TCustomBitmap32.Resize;
var
  i: Integer;
begin
  Result := True;

  BitmapData.Width       := AWidth;
  BitmapData.Height      := AHeight;
  BitmapData.PixelFormat := PixelFormat32;

  BitmapData.Size := Cardinal(BitmapData.Stride) * AHeight;

  SetLength(Scanlines, AHeight + 1);

  if (AWidth = 0) or (AHeight = 0) then
    Exit;

  for i := 0 to AHeight do
    Scanlines[i] := Pointer(Cardinal(BitmapData.Scan0) + Cardinal(BitmapData.Stride * i));
end;

function TCustomBitmap32.Lock;
var
  i:      Integer;
  xx, yy: Integer;
  ww, hh: Integer;
  p1, p2: PByte;
begin
  FillChar(ABitmapData, 0, SizeOf(ABitmapData));

  if (Ax >= Integer(BitmapData.Width)) or (Ay >= Integer(BitmapData.Height)) then
    Exit(False);

  xx := Ax; yy := Ay;
  ww := Aw; hh := Ah;

  //AdjustClamp(xx, ww, 0, BitmapData.Width);
  //AdjustClamp(yy, hh, 0, BitmapData.Height);

  ABitmapData.Width    := ww;
  ABitmapData.Height   := hh;
  ABitmapData.LockMode := ALockMode;
  ABitmapData.LockX    := xx;
  ABitmapData.LockY    := yy;
  ABitmapData.Reserved := BitmapData.Scan0;

  if lmUserBuf in ALockMode then
  begin
    if (BitmapData.PixelFormat <> PixelFormat32) or (Integer(ABitmapData.Width) <> ww) or (Integer(ABitmapData.Height) <> hh) then
      Exit(False);

    if lmRead in ALockMode then
    begin
      p1 := Pointer(Integer(Scanlines[yy]) + (xx shl 2));
      p2 := BitmapData.Scan0;

      for i := 0 to hh - 1 do
      begin
        Move(p1^, p2^, ww shl 2);

        Inc(p1,  BitmapData.Stride);
        Inc(p2, ABitmapData.Stride);
      end;
    end;
  end
  else
  begin
    ABitmapData.Stride      := BitmapData.Stride;
    ABitmapData.Scan0       := Pointer(Integer(Scanlines[yy]) + (xx shl 2));
    ABitmapData.PixelFormat := BitmapData.PixelFormat;
  end;

  Result := True;
end;

function TCustomBitmap32.Unlock;
var
  i:      Integer;
  p1, p2: PByte;
begin
  Result := ABitmapData.Reserved = BitmapData.Scan0;

  if not Result then
    Exit;

  if (lmUserBuf in ABitmapData.LockMode) and (lmWrite in ABitmapData.LockMode) then
  begin
    p1 := Pointer(Integer(Scanlines[ABitmapData.LockX]) + Integer(ABitmapData.LockY shl 2));
    p2 := ABitmapData.Scan0;

    for i := 0 to ABitmapData.Height - 1 do
    begin
      Move(p2^, p1^, ABitmapData.Width shl 2);

      Inc(p1,  BitmapData.Stride);
      Inc(p2, ABitmapData.Stride);
    end;
  end;

  FillChar(ABitmapData, 0, sizeof(ABitmapData));
end;
{$ENDREGION}

{$REGION 'TSubBitmap'}
constructor TSubBitmap32.Create;
begin
  inherited Create;

  FillChar(BitmapData, SizeOf(BitmapData), 0);

  if AParent.Lock(BitmapData, AX, AY, AW, AH, [lmRead, lmWrite]) then
  begin
    FParent := AParent;
    Resize(BitmapData.Width, BitmapData.Height);
  end
  else
    FParent := nil;
end;

destructor TSubBitmap32.Destroy;
begin
  if FParent <> nil then
    Parent.Unlock(BitmapData);

  inherited;
end;
{$ENDREGION}

{$REGION 'TDIB32'}
{$IFDEF MSWINDOWS}
function TDIB32.GetDC;
begin
  if FDC = 0 then
    CreateDC;

  Result := FDC;
end;

function TDIB32.Resize;
begin
  ReleaseDC;

  if FHandle <> 0 then
    DeleteObject(FHandle);

  FHandle := 0;

  FillChar(BitmapData, SizeOf(BitmapData), 0);

  if (AWidth <> 0) and (AHeight <> 0) then
  begin
    with FHeader do
    begin
      biSize        := SizeOf(FHeader);
      biWidth       := AWidth;
      biHeight      := -AHeight;
      biPlanes      := 1;
      biBitCount    := 32;
      biCompression := BI_RGB;
    end;

    FInfo.bmiHeader := FHeader;

    FHandle := CreateDIBSection(0, FInfo, DIB_RGB_COLORS, BitmapData.Scan0, 0, 0);

    if FHandle = 0 then
    begin
      inherited Resize(0, 0);

      Exit(False);
    end;

    BitmapData.Stride   := AWidth * 4;
    BitmapData.LockMode := [lmRead, lmWrite];
  end;

  Result := inherited Resize(AWidth, AHeight);
end;

procedure TDIB32.BltToDC;
begin
  if (AW = 0) or (AH = 0) then
    SetDIBitsToDevice(ADC, AX, AY, BitmapData.Width, BitmapData.Height, 0, 0, 0, BitmapData.Height, BitmapData.Scan0, FInfo, DIB_RGB_COLORS)
  else
    StretchDIBits(ADC, AX, AY, AW, AH, 0, 0, BitmapData.Width, BitmapData.Height, BitmapData.Scan0, FInfo, DIB_RGB_COLORS, SRCCOPY);
end;

procedure TDIB32.CreateDC;
var
  ScreenDC: HDC;
begin
  if FDC <> 0 then
    Exit;

  ScreenDC := WinApi.Windows.GetDC(0);

  FDC := CreateCompatibleDC(ScreenDC);
  SelectObject(FDC, FHandle);

  WinApi.Windows.ReleaseDC(0, ScreenDC);
end;

procedure TDIB32.ReleaseDC;
begin
  if DC = 0 then
    Exit;

  WinApi.Windows.ReleaseDC(0, FDC);
  FDC := 0;
end;
{$ENDIF}
{$ENDREGION}

end.

