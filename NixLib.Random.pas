{
  NixLib.Random.pas

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

unit NixLib.Random;

interface

uses
  System.Classes;

type
{$REGION 'TRandom'}
  TRandom = record
  private
    FSeed:  Integer;

    procedure SetSeed(ASeed: Integer);
  public
    Value: Integer;

    const RandMod = $08088405;
    const RandTap = $23000001;

    constructor Create(const ASeed: Integer);

    function Next(const ARange: Integer): Integer;  overload;
    function Next:                        Extended; overload;

    function LFSR:  Cardinal; // Treat 'Value' as a 32-bit linear feedback shift register
    function LFSR0: Boolean; inline;

    function MeanStdDev(AMean, AStdDev: Extended): Extended;

    procedure Randomize;

    property Seed: Integer read FSeed write SetSeed;
  end;
{$ENDREGION}

{$REGION 'TPerlin'}
  TPerlin = record
  private
    const GradientSize = 255;

    const Permutations: array[0..GradientSize] of Byte = (
      225, 155, 210, 108, 175, 199, 221, 144, 203, 116,  70, 213,  69, 158,  33, 252,
        5,  82, 173, 133, 222, 139, 174,  27,   9,  71,  90, 246,  75, 130,  91, 191,
      169, 138,   2, 151, 194, 235,  81,   7,  25, 113, 228, 159, 205, 253, 134, 142,
      248,  65, 224, 217,  22, 121, 229,  63,  89, 103,  96, 104, 156,  17, 201, 129,
       36,   8, 165, 110, 237, 117, 231,  56, 132, 211, 152,  20, 181, 111, 239, 218,
      170, 163,  51, 172, 157,  47,  80, 212, 176, 250,  87,  49,  99, 242, 136, 189,
      162, 115,  44,  43, 124,  94, 150,  16, 141, 247,  32,  10, 198, 223, 255,  72,
       53, 131,  84,  57, 220, 197,  58,  50, 208,  11, 241,  28,   3, 192,  62, 202,
       18, 215, 153,  24,  76,  41,  15, 179,  39,  46,  55,   6, 128, 167,  23, 188,
      106,  34, 187, 140, 164,  73, 112, 182, 244, 195, 227,  13,  35,  77, 196, 185,
       26, 200, 226, 119,  31, 123, 168, 125, 249,  68, 183, 230, 177, 135, 160, 180,
       12,   1, 243, 148, 102, 166,  38, 238, 251,  37, 240, 126,  64,  74, 161,  40,
      184, 149, 171, 178, 101,  66,  29,  59, 146,  61, 254, 107,  42,  86, 154,   4,
      236, 232, 120,  21, 233, 209,  45,  98, 193, 114,  78,  19, 206,  14, 118, 127,
       48,  79, 147,  85,  30, 207, 219,  54,  88, 234, 190, 122,  95,  67, 143, 109,
      137, 214, 145,  93,  92, 100, 245,   0, 216, 186,  60,  83, 105,  97, 204,  52
    );

    var Gradients: array[0..GradientSize * 3] of Extended;

    function Permutate(AX: Integer): Integer; inline;
    function Index(AX, AY, AZ: Integer): Integer; inline;
    function Lattice(Aix, Aiy, Aiz: Integer; Afx, Afy, Afz: Extended): Extended;
    function Lerp(AAlpha, ASource, ADest: Extended): Extended; inline;
    function Smooth(AX: Extended): Extended; inline;

    function  GetSeed: Integer;
    procedure SetSeed(ASeed: Integer);
  public
    Random: TRandom;

    constructor Create(const ASeed: Integer);

    procedure CreateGradients;

    function Noise(AX, AY, AZ: Extended): Extended;

    procedure Randomize;

    property Seed: Integer read GetSeed write SetSeed;
  end;
{$ENDREGION}

var
  RNG: TRandom;

implementation

{$REGION 'TRandom'}
procedure TRandom.SetSeed;
begin
  FSeed := ASeed;
  Value := ASeed;
end;

constructor TRandom.Create;
begin
  SetSeed(ASeed);
end;

function TRandom.Next(const ARange: Integer): Integer;
begin
  Value  := Value * RandMod + 1;
  Result := (UInt64(Cardinal(ARange)) * UInt64(Cardinal(Value))) shr 32;
end;

function TRandom.Next: Extended;
const
  Two2Neg32: Double = (1 / $10000) / $10000;  // 2^-32
begin
  Value  := Value * RandMod + 1;
  Result := Int64(Cardinal(Value)) * Two2Neg32;
end;

function TRandom.LFSR;
var
  NewBit: Cardinal;
begin
  // 32-bit Feedback polynormal taken from:
  // https://www.researchgate.net/publication/236109080_FPGA_Implementation_of_8_16_and_32_Bit_LFSR_with_Maximum_Length_Feedback_Polynomial_using_VHDL

  // X^32 + X^22 + X^2 + X^1 + 1
  // A = (A >> 1) | (((A ^ (A >> 10) | (A >> 30) | (A >> 31)) & 1) << 31)

  NewBit := Value xor (Value shr 10) xor (Value shr 30) xor (Value shr 31);
  Value  := Integer(Cardinal(Value shr 1) or ((NewBit and 1) shl 31));

  Result := Cardinal(Value);
end;

function TRandom.LFSR0;
begin
  Result := (LFSR and 1) = 1;
end;

function TRandom.MeanStdDev;
var
  r1, r2: Extended;
begin
  repeat
    r1 := 2 * Next - 1;
    r2 := Sqr(r1) + Sqr(2 * Next - 1);
  until r2 < 1;

  Result := Sqrt(-2 * Ln(r2) / r2) * r1 * AStdDev + AMean;
end;

procedure TRandom.Randomize;
begin
  fSeed := Integer(TThread.GetTickCount) + RNG.Next(MaxInt);
  Value := FSeed;
end;
{$ENDREGION}

{$REGION 'TPerlin'}
function TPerlin.Permutate;
begin
  Result := Permutations[AX and GradientSize];
end;

function TPerlin.Index;
begin
  Result := Permutate(AX + Permutate(AY + Permutate(AZ)));
end;

function TPerlin.Lattice;
var
  i: Integer;
begin
  i := Index(Aix, Aiy, Aiz) * 3;
  Result := Gradients[i] * Afx + Gradients[i + 1] * Afy + Gradients[i + 2] + Afz;
end;

function TPerlin.Lerp;
begin
  Result := ASource + AAlpha * (ADest - ASource);
end;

function TPerlin.Smooth;
begin
  Result := AX * AX * (3 - 2 * AX);
end;

function TPerlin.GetSeed;
begin
  Result := Random.Seed;
end;

procedure TPerlin.SetSeed;
begin
  Random.Seed := ASeed;
  CreateGradients;
end;

constructor TPerlin.Create;
begin
  Random := TRandom.Create(ASeed);

  CreateGradients;
end;

procedure TPerlin.CreateGradients;
var
  i:           Integer;
  z, r, Theta: Extended;
begin
  for i := 0 to GradientSize do
  begin
    z     := 1 - 2 * Random.Next;
    r     := Sqrt(1 - z * z);
    Theta := 2 * PI * Random.Next;
    Gradients[i * 3]     := r * Cos(Theta);
    Gradients[i * 3 + 1] := r * Sin(Theta);
    Gradients[i * 3 + 2] := z;
  end;
end;

function TPerlin.Noise;
var
  ix,  iy,  iz:  Integer;
  wx,  wy,  wz:  Extended;
  fx0, fy0, fz0: Extended;
  fx1, fy1, fz1: Extended;
  vx0, vy0, vz0: Extended;
  vx1, vy1, vz1: Extended;
begin
  ix  := Trunc(AX);
  fx0 := AX - ix;
  fx1 := fx0 - 1;
  wx  := Smooth(fx0);

  iy  := Trunc(AY);
  fy0 := AY - iy;
  fy1 := fy0 - 1;
  wy  := Smooth(fy0);

  iz  := Trunc(AZ);
  fz0 := AZ - iz;
  fz1 := fz0 - 1;
  wz  := Smooth(fz0);

  vx0 := Lattice(ix, iy, iz, fx0, fy0, fz0);
  vx1 := Lattice(ix + 1, iy, iz, fx1, fy0, fz0);
  vy0 := Lerp(wx, vx0, vx1);

  vx0 := Lattice(ix, iy + 1, iz, fx0, fy1, fz0);
  vx1 := Lattice(ix + 1, iy + 1, iz, fx1, fy1, fz0);
  vy1 := Lerp(wx, vx0, vx1);

  vz0 := Lerp(wy, vy0, vy1);

  vx0 := Lattice(ix, iy, iz + 1, fx0, fy0, fz1);
  vx1 := Lattice(ix + 1, iy, iz + 1, fx1, fy0, fz1);
  vy0 := Lerp(wx, vx0, vx1);

  vx0 := Lattice(ix, iy + 1, iz + 1, fx0, fy1, fz1);
  vx1 := Lattice(ix + 1, iy + 1, iz + 1, fx1, fy1, fz1);
  vy1 := Lerp(wx, vx0, vx1);

  vz1 := Lerp(wy, vy0, vy1);

  Result := Abs(Lerp(wz, vz0, vz1));
end;

procedure TPerlin.Randomize;
begin
  Random.Randomize;
  CreateGradients;
end;
{$ENDREGION}

initialization
  RNG.Randomize;
end.

