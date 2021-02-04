{
  NixLib.Types.pas

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

unit NixLib.Types;

interface

uses
  System.Math;

{$REGION 'Byte'}
type
  Byte  = System.UInt8;
  PByte = ^Byte;

  SByte  = System.Int8;
  PSByte = ^SByte;

type
  TByteHelper = record helper for Byte
  const
    Size = SizeOf(Byte);
    Bits = Size shl 3;
    Max  = Byte(-1);
  private
    function  ReadBits (AMask: Byte): Boolean; inline;
    procedure WriteBits(AMask: Byte; AValue: Boolean);
  public
    class function Clamp(AValue: Extended): Byte; inline; static;

    procedure SetBits  (AMask: Byte); inline;
    procedure ClearBits(AMask: Byte); inline;

    property MaskedBits[AMask: Byte]: Boolean read ReadBits write WriteBits;
  end;

  TSByteHelper = record helper for SByte
  const
    Max = SByte(Byte.Max shr 1);
    Min = not Max;
  public
    class function Clamp(AValue: Extended): SByte; inline; static;
  end;

  Bytes  = array[0..0] of Byte;
  PBytes = ^Bytes;

  SBytes  = array[0..0] of SByte;
  PSBytes = ^SBytes;
{$ENDREGION}

{$REGION 'Word'}
type
  Word  = System.UInt16;
  PWord = ^Word;

  SWord  = System.Int16;
  PSWord = ^SWord;

type
  TWordHelper = record helper for Word
  const
    Size = SizeOf(Word);
    Bits = Size shl 3;
    Max  = Word(-1);
  private
    function  ReadBits (AMask: Word): Boolean; inline;
    procedure WriteBits(AMask: Word; AValue: Boolean);

    function  GetByte(AIndex: Integer): Byte; inline;
    procedure SetByte(AIndex: Integer; AValue: Byte); inline;
  public
    class function Clamp(AValue: Extended): Word; inline; static;

    procedure SetBits  (AMask: Word); inline;
    procedure ClearBits(AMask: Word); inline;

    property MaskedBits[AMask: Word]: Boolean read ReadBits write WriteBits;

    property Low:  Byte index 0 read GetByte write SetByte;
    property High: Byte index 1 read GetByte write SetByte;

    property Bytes[AIndex: Integer]: Byte read GetByte write SetByte;
  end;

  TSWordHelper = record helper for SWord
  const
    Max = SWord(Word.Max shr 1);
    Min = not Max;
  public
    class function Clamp(AValue: Extended): SWord; inline; static;
  end;

  Words  = array[0..0] of Word;
  PWords = ^Words;

  SWords  = array[0..0] of SWord;
  PSWords = ^SWords;
{$ENDREGION}

{$REGION 'DWord'}
type
  DWord  = System.UInt32;
  PDWord = ^DWord;

  SDWord  = System.Int32;
  PSDWord = ^SDWord;

type
  TDWordHelper = record helper for DWord
  const
    Size = SizeOf(DWord);
    Bits = Size shl 3;
    Max  = DWord(-1);
  private
    function  ReadBits (AMask: DWord): Boolean; inline;
    procedure WriteBits(AMask: DWord; AValue: Boolean);

    function  GetByte(AIndex: Integer): Byte; inline;
    procedure SetByte(AIndex: Integer; AValue: Byte); inline;

    function  GetWord(AIndex: Integer): Word; inline;
    procedure SetWord(AIndex: Integer; AValue: Word); inline;
  public
    class function Clamp(AValue: Extended): DWord; inline; static;

    procedure SetBits  (AMask: DWord); inline;
    procedure ClearBits(AMask: DWord); inline;

    property MaskedBits[AMask: DWord]: Boolean read ReadBits write WriteBits;

    property Bytes[AIndex: Integer]: Byte read GetByte write SetByte;
    property Words[AIndex: Integer]: Word read GetWord write SetWord;

    property Low:  Word index 0 read GetWord write SetWord;
    property High: Word index 1 read GetWord write SetWord;
  end;

  TSDWordHelper = record helper for SDWord
  const
    Max = SDWord(DWord.Max shr 1);
    Min = not Max;
  public
    class function Clamp(AValue: Extended): SDWord; inline; static;
  end;

  DWords  = array[0..0] of DWord;
  PDWords = ^DWords;

  SDWords  = array[0..0] of SDWord;
  PSDWords = ^SDWords;
{$ENDREGION}

{$REGION 'QWord'}
type
  QWord  = System.UInt64;
  PQWord = ^QWord;

  SQWord  = System.Int64;
  PSQWord = ^SQWord;

type
  TQWordHelper = record helper for QWord
  const
    Size = SizeOf(QWord);
    Bits = Size shl 3;
    Max  = QWord(-1);
  private
    function  ReadBits (AMask: QWord): Boolean; inline;
    procedure WriteBits(AMask: QWord; AValue: Boolean);

    function  GetByte(AIndex: Integer): Byte; inline;
    procedure SetByte(AIndex: Integer; AValue: Byte); inline;

    function  GetWord(AIndex: Integer): Word; inline;
    procedure SetWord(AIndex: Integer; AValue: Word); inline;

    function  GetDWord(AIndex: Integer): DWord; inline;
    procedure SetDWord(AIndex: Integer; AValue: DWord); inline;
  public
    class function Clamp(AValue: Extended; AMax: QWord = QWord.Max; AMin: QWord = 0): QWord; static;

    procedure SetBits  (AMask: QWord); inline;
    procedure ClearBits(AMask: QWord); inline;

    property MaskedBits[AMask: QWord]: Boolean read ReadBits write WriteBits;

    property Bytes [AIndex: Integer]: Byte  read GetByte  write SetByte;
    property Words [AIndex: Integer]: Word  read GetWord  write SetWord;
    property DWords[AIndex: Integer]: DWord read GetDWord write SetDWord;

    property Low:  DWord index 0 read GetDWord write SetDWord;
    property High: DWord index 1 read GetDWord write SetDWord;
  end;

  TSQWordHelper = record helper for SQWord
  const
    Max = SQWord(QWord.Max shr 1);
    Min = not Max;
  public
    class function Clamp(AValue: Extended; AMax: SQWord = SQWord.Max; AMin: SQWord = SQWord.Min): SQWord; static;
  end;

  QWords  = array[0..0] of QWord;
  PQWords = ^QWords;

  SQWords  = array[0..0] of SQWord;
  PSQWords = ^SQWords;
{$ENDREGION}

{$REGION 'Integer'}
  UInteger = Cardinal;

  TUIntegerHelper = record helper for UInteger
  const
    Size = SizeOf(UInteger);
    Bits = Size shl 3;
    Max  = UInteger(-1);
  end;

  TIntegerHelper = record helper for Integer
  const
    Size = SizeOf(Integer);
    Bits = Size shl 3;
    Max  = Integer(UInteger.Max shr 1);
    Min  = not Max;
  public
    function RetInc(const ACount: Integer = 1; const AMax: Integer = Integer.Max): Integer; inline; // i++
    function IncRet(const ACount: Integer = 1; const AMax: Integer = Integer.Max): Integer; inline; // ++i
    function RetDec(const ACount: Integer = 1; const AMin: Integer = Integer.Min): Integer; inline; // i--
    function DecRet(const ACount: Integer = 1; const AMin: Integer = Integer.Min): Integer; inline; // --i

    function Clamp(const AMin: Integer = Integer.Min; const AMax: Integer = Integer.Max): Integer;

    function ClampDelta(var AWidth: Integer; const AMin: Integer = Integer.Min; const AMax: Integer = Integer.Max): Integer;
  end;
{$ENDREGION}

{$REGION 'Single'}
  TSingleHelper = record helper for Single

  end;
{$ENDREGION}

{$REGION 'Boolean'}
  TBooleanHelper = record helper for Boolean
  public
    function Normalize: Boolean; inline;

    function Iff<T>(ATrue, AFalse: T): T; inline;
  end;
{$ENDREGION}

{$REGION 'Rounding'}
type
  TRoundingMode = (rmDefault, rmNearest, rmTruncate, rmCeil, rmFloor);

var
  DefaultRoundingMode: TRoundingMode = rmNearest;

function Round(AValue: Extended; const ARoundingMode: TRoundingMode = rmDefault): Int64;
{$ENDREGION}

implementation

{$REGION 'Rounding'}
function Round(AValue: Extended; const ARoundingMode: TRoundingMode = rmDefault): Int64;
begin
  case ARoundingMode of
    rmNearest:  Result := System.Round(AValue);
    rmTruncate: Result := Trunc(AValue);
    rmCeil:     Result := Ceil(AValue);
    rmFloor:    Result := Floor(AValue);
  else
    if DefaultRoundingMode <> rmDefault then
      Result := Round(AValue, DefaultRoundingMode)
    else
      Result := System.Round(AValue);
  end;
end;
{$ENDREGION}

{$REGION 'Object/cass functions'}
function IsType(AObj: TObject; ATypes: array of TClass): Boolean;
begin
  for var &Type in ATypes do
    if AObj is &Type then
      Exit(True);

  Result := False;
end;
{$ENDREGION}

{$REGION 'Byte'}
function TByteHelper.ReadBits;
begin
  Result := (Self and AMask) = AMask;
end;

procedure TByteHelper.WriteBits;
begin
  if AValue then
    SetBits(AMask)
  else
    ClearBits(AMask);
end;

class function TByteHelper.Clamp;
begin
  Result := QWord.Clamp(AValue, Byte.Max);
end;

procedure TByteHelper.SetBits;
begin
  Self := Self or AMask;
end;

procedure TByteHelper.ClearBits;
begin
  Self := Self and (not AMask);
end;

class function TSByteHelper.Clamp;
begin
  Result := SQWord.Clamp(AValue, Max, Min);
end;
{$ENDREGION}

{$REGION 'Word'}
function TWordHelper.ReadBits;
begin
  Result := (Self and AMask) = AMask;
end;

procedure TWordHelper.WriteBits;
begin
  if AValue then
    SetBits(AMask)
  else
    ClearBits(AMask);
end;

function TWordHelper.GetByte;
begin
  Result := PBytes(@Self)^[AIndex];
end;

procedure TWordHelper.SetByte;
begin
  PBytes(@Self)^[AIndex] := AValue;
end;

class function TWordHelper.Clamp;
begin
  Result := QWord.Clamp(AValue, Word.Max);
end;

procedure TWordHelper.SetBits;
begin
  Self := Self or AMask;
end;

procedure TWordHelper.ClearBits;
begin
  Self := Self and (not AMask);
end;

class function TSWordHelper.Clamp;
begin
  Result := SQWord.Clamp(AValue, Max, Min);
end;
{$ENDREGION}

{$REGION 'DWord'}
function TDWordHelper.ReadBits;
begin
  Result := (Self and AMask) = AMask;
end;

procedure TDWordHelper.WriteBits;
begin
  if AValue then
    SetBits(AMask)
  else
    ClearBits(AMask);
end;

function TDWordHelper.GetByte;
begin
  Result := PBytes(@Self)^[AIndex];
end;

procedure TDWordHelper.SetByte;
begin
  PBytes(@Self)^[AIndex] := AValue;
end;

function TDWordHelper.GetWord;
begin
  Result := PWords(@Self)^[AIndex];
end;

procedure TDWordHelper.SetWord;
begin
  PWords(@Self)^[AIndex] := AValue;
end;

class function TDWordHelper.Clamp;
begin
  Result := QWord.Clamp(AValue, DWord.Max);
end;

procedure TDWordHelper.SetBits;
begin
  Self := Self or AMask;
end;

procedure TDWordHelper.ClearBits;
begin
  Self := Self and (not AMask);
end;

class function TSDWordHelper.Clamp;
begin
  Result := SQWord.Clamp(AValue, Max, Min);
end;
{$ENDREGION}

{$REGION 'QWord'}
function TQWordHelper.ReadBits;
begin
  Result := (Self and AMask) = AMask;
end;

procedure TQWordHelper.WriteBits;
begin
  if AValue then
    SetBits(AMask)
  else
    ClearBits(AMask);
end;

function TQWordHelper.GetByte;
begin
  Result := PBytes(@Self)^[AIndex];
end;

procedure TQWordHelper.SetByte;
begin
  PBytes(@Self)^[AIndex] := AValue;
end;

function TQWordHelper.GetWord;
begin
  Result := PWords(@Self)^[AIndex];
end;

procedure TQWordHelper.SetWord;
begin
  PWords(@Self)^[AIndex] := AValue;
end;

function TQWordHelper.GetDWord;
begin
  Result := PDWords(@Self)^[AIndex];
end;

procedure TQWordHelper.SetDWord;
begin
  PDWords(@Self)^[AIndex] := AValue;
end;

class function TQWordHelper.Clamp;
begin
  if AValue < AMin then
    Result := AMin
  else if AValue > AMax then
    Result := Max
  else
    Result := Round(AValue);
end;

procedure TQWordHelper.SetBits;
begin
  Self := Self or AMask;
end;

procedure TQWordHelper.ClearBits;
begin
  Self := Self and (not AMask);
end;

class function TSQWordHelper.Clamp;
begin
  if AValue < AMin then
    Result := AMin
  else if AValue > AMax then
    Result := Max
  else
    Result := Round(AValue);
end;
{$ENDREGION}

{$REGION 'Integer'}
function TIntegerHelper.RetInc;
begin
  Result := Self;

  Inc(Self);

  if Self > AMax then
    Self := AMax;
end;

function TIntegerHelper.IncRet;
begin
  Inc(Self);

  if Self > AMax then
    Self := AMax;

  Result := Self;
end;

function TIntegerHelper.RetDec;
begin
  Result := Self;

  Dec(Self);

  if Self < AMin then
    Self := AMin;
end;

function TIntegerHelper.DecRet;
begin
  Dec(Self);

  if Self < AMin then
    Self := AMin;

  Result := Self;
end;

function TIntegerHelper.Clamp;
begin
  if Self > AMax then
    Result := AMax
  else if Self < AMin then
    Result := AMin
  else
    Result := Self;
end;

function TIntegerHelper.ClampDelta;
begin
  Result := 0;

  if Self < AMin then
  begin
    Result := AMin - Self;
    AWidth := AWidth - Result;
    Self   := AMin;
  end;

  if (Self + AWidth) > AMax then
    AWidth := AMax - Self;

  if AWidth < 0 then
    AWidth := 0;
end;
{$ENDREGION}

{$REGION 'Single'}

{$ENDREGION}

{$REGION 'Boolean'}
function TBooleanHelper.Normalize;
begin
  Result := Self <> False;
end;

function TBooleanHelper.Iff<T>;
begin
  if Self then
    Result := ATrue
  else
    Result := AFalse;
end;
{$ENDREGION}

end.

