{
  NixLib.Memory.pas

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

unit NixLib.Memory;

interface

type
{$REGION 'TMemory'}
  TMemory<T> = record
    type TPtr = ^T;
    var  Ptr: TPtr;

    class function Null: TMemory<T>; inline; static;

    constructor Create(const ASize: Integer); overload;
    constructor Create(const APtr: TPtr);     overload;

    procedure Resize(const ASize: Integer);
    procedure Free;

    function Void(const AIndex: Integer = 0): Pointer; inline;

    class operator Implicit(AValue: TMemory<T>): Pointer;    inline;
    class operator Implicit(AValue: Pointer):    TMemory<T>; inline;

    function  Read (                 const AIncrement: Boolean = True): T; inline;
    procedure Write(const AValue: T; const AIncrement: Boolean = True);    inline;

    procedure Inc(const ACount: Integer = 1); inline;
    procedure Dec(const ACount: Integer = 1); inline;

    function  ReadItem (AIndex: Integer): T;         inline;
    procedure WriteItem(aIndex: Integer; AValue: T); inline;

    property Items[AIndex: Integer]: T read ReadItem write WriteItem; default;
  end;
{$ENDREGION}

{$REGION 'TPointerHelper'}
  TPointerHelper = record helper for Pointer
    class function Alloc(const ASize: Integer): Pointer; static; inline;

    procedure Resize(const ASize: Integer);
    procedure Free;

    procedure Inc(const ACount: Integer = 1); inline;
    procedure Dec(const ACount: Integer = 1); inline;

    procedure Read (var   AData; const ASize: Integer; const AIncrement: Boolean = True); overload;
    procedure Write(const AData; const ASize: Integer; const AIncrement: Boolean = True); overload;

    function  Read<T> (                 const AIncrement: Boolean = True): T; overload; inline;
    procedure Write<T>(const AValue: T; const AIncrement: Boolean = True);    overload; inline;

    function Offset(AValue: Integer): Pointer; inline;

    function  ArrayRead<T> (AIndex: Integer): T;        inline;
    procedure ArrayWrite<T>(AIndex: Integer; AValue: T); inline;

    //property Bytes[AIndex: Integer]: Byte read ArrayRead<Byte> write ArrayWrite<Byte>;
    //property ArrayOf<T>[AIndex: Integer]: T read ArrayRead<T> write ArrayWrite<T>;
  end;
{$ENDREGION}

implementation

{$REGION 'TMemory'}
class function TMemory<T>.Null;
begin
  Result.Ptr := nil;
end;

constructor TMemory<T>.Create(const ASize: Integer);
begin
  GetMem(Pointer(Ptr), SizeOf(T) * ASize);
end;

constructor TMemory<T>.Create(const APtr: TPtr);
begin
  Ptr := APtr;
end;

procedure TMemory<T>.Resize;
begin
  if Ptr = nil then
    GetMem(Pointer(Ptr), SizeOf(T) * ASize)
  else
    ReallocMem(Pointer(Ptr), SizeOf(T) * ASize);
end;

procedure TMemory<T>.Free;
begin
  if Ptr = nil then
    Exit;

  FreeMem(Pointer(Ptr));

  Ptr := nil;
end;

function TMemory<T>.Void;
begin
  Result := Pointer(UIntPtr(Ptr) + UIntPtr(AIndex * SizeOf(T)));
end;

class operator TMemory<T>.Implicit(AValue: TMemory<T>): Pointer;
begin
  Result := AValue.Ptr;
end;

class operator TMemory<T>.Implicit(AValue: Pointer): TMemory<T>;
begin
  Result.Ptr := AValue;
end;

function TMemory<T>.Read;
begin
  Result := Void.Read<T>(AIncrement);
end;

procedure TMemory<T>.Write;
begin
  Void.Write<T>(AValue, AIncrement);
end;

procedure TMemory<T>.Inc;
begin
  Ptr := TPtr(UIntPtr(Ptr) + UIntPtr(ACount * SizeOf(T)));
end;

procedure TMemory<T>.Dec;
begin
  Ptr := TPtr(UIntPtr(Ptr) - UIntPtr(ACount * SizeOf(T)));
end;

function TMemory<T>.ReadItem;
begin
  Result := TPtr(UIntPtr(Ptr) + UIntPtr(AIndex * SizeOf(T)))^;
end;

procedure TMemory<T>.WriteItem;
begin
  TPtr(UIntPtr(Ptr) + UIntPtr(AIndex * SizeOf(T)))^ := AValue;
end;
{$ENDREGION}

{$REGION 'TPointerHelper'}
class function TPointerHelper.Alloc;
begin
  GetMem(Result, ASize);
end;

procedure TPointerHelper.Resize;
begin
  if Self = nil then
    GetMem(Self, ASize)
  else
    ReallocMem(Self, ASize);
end;

procedure TPointerHelper.Free;
begin
  if Self = nil then
    Exit;

  FreeMem(Self);
  Self := nil;
end;

procedure TPointerHelper.Inc;
begin
  Self := Pointer(UIntPtr(Self) + UIntPtr(ACount));
end;

procedure TPointerHelper.Dec;
begin
  Self := Pointer(UIntPtr(Self) - UIntPtr(ACount));
end;

procedure TPointerHelper.Read(var AData; const ASize: Integer; const AIncrement: Boolean = True);
begin
  Move(Self^, AData, ASize);

  if AIncrement then
    Inc(ASize);
end;

procedure TPointerHelper.Write(const AData; const ASize: Integer; const AIncrement: Boolean = True);
begin
  Move(AData, Self^, ASize);

  if AIncrement then
    Inc(ASize);
end;

function TPointerHelper.Read<T>(const AIncrement: Boolean = True): T;
begin
  Read(Result, SizeOf(Result), AIncrement);
end;

procedure TPointerHelper.Write<T>(const AValue: T; const AIncrement: Boolean = True);
begin
  Write(AValue, SizeOf(AValue), AIncrement);
end;

function TPointerHelper.Offset;
begin
  Result := Pointer(IntPtr(Self) + AValue);
end;

function TPointerHelper.ArrayRead<T>;
begin
  Move(Offset(SizeOf(T) * AIndex)^, Result, SizeOf(T));
end;

procedure TPointerHelper.ArrayWrite<T>;
begin
  Move(AValue, Offset(SizeOf(T) * AIndex)^, SizeOf(T));
end;
{$ENDREGION}

end.

