{
  NixLib.Streams.pas

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

unit NixLib.Streams;

interface

uses
  System.SysUtils,
  System.Classes;

const
  CipherTableSize = 1023;

type
{$REGION 'TStreamHelper'}
  TStreamHelper = class helper for TStream
  public

  end;
{$ENDREGION}

{$REGION 'TStreamProxy'}
  TStreamProxy = class(TStream)
  private
    FTarget:     TStream;
    FOwnsTarget: Boolean;

    FBytesRead:    Int64;
    FBytesWritten: Int64;

    FCipherKey:   Integer;
    FCipherTable: array[0..CipherTableSize] of Byte;

    procedure SetCipherKey(AValue: Integer);

    procedure BlockCipher(var AData; const ASize, AIndex: Int64);

    procedure SetTarget(ATarget: TStream);
  public
    constructor Create(ATarget: TStream);
    destructor  Destroy; override;

    function Read (var   ABuffer; ACount: Longint): LongInt; override;
    function Write(const ABuffer; ACount: Longint): LongInt; override;

    function Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64; override;

    property Target:     TStream read FTarget     write SetTarget;
    property OwnsTarget: Boolean read FOwnsTarget write FOwnsTarget;

    property BytesRead:    Int64 read FBytesRead;
    property BytesWritten: Int64 read FBytesWritten;

    property CipherKey: Integer read FCipherKey write SetCipherKey;
  end;
{$ENDREGION}

implementation

uses
  Framework.Random;

{$REGION 'TStreamHelper'}

{$ENDREGION}

{$REGION 'TStreamProxy'}
procedure TStreamProxy.SetCipherKey;
var
  i: Integer;
  r: TRandom;
begin
  FCipherKey := AValue;
  r.Seed := FCipherKey;

  for i := 0 to CipherTableSize do
    FCipherTable[i] := round($FF * r.Next);
end;

procedure TStreamProxy.BlockCipher;
var
  i: Int64;
  p: PByte;
begin
  p := @AData;

  for i := 0 to Size do
  begin
    p^ := p^ xor FCipherTable[(AIndex + i) mod CipherTableSize];
    Inc(p);
  end;
end;

procedure TStreamProxy.SetTarget;
begin
  if (FTarget <> nil) and FOwnsTarget then
    FTarget.Free;

  FTarget := ATarget;

  FBytesRead    := 0;
  FBytesWritten := 0;
end;

constructor TStreamProxy.Create;
begin
  inherited Create;

  FCipherKey := 0;

  FOwnsTarget := False;

  FTarget := nil;
  SetTarget(ATarget);
end;

destructor TStreamProxy.Destroy;
begin
  SetTarget(nil);

  inherited;
end;

function TStreamProxy.Read(var ABuffer; ACount: Longint): LongInt;
var
  CipherIndex: Int64;
begin
  CipherIndex := Position;

  Result := FTarget.Read(ABuffer, ACount);

  if Result > 0 then
  begin
    Inc(FBytesRead, Result);

    if FCipherKey <> 0 then
      BlockCipher(ABuffer, Result, CipherIndex);
  end;
end;

function TStreamProxy.Write(const ABuffer; ACount: Longint): LongInt;
var
  CBuffer: array of Byte;
begin
  if FCipherKey <> 0 then
  begin
    SetLength(CBuffer, ACount);
    Move(ABuffer, CBuffer[0], ACount);

    BlockCipher(CBuffer[0], ACount, Position);

    Result := FTarget.Write(CBuffer[0], ACount);
  end
  else
    Result := FTarget.Write(ABuffer, ACount);

  if Result > 0 then
    Inc(FBytesWritten, Result);
end;

function TStreamProxy.Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64;
begin
  Result := FTarget.Seek(AOffset, AOrigin);
end;
{$ENDREGION}

end.

