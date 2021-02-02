{
  NixLib.Geometry.pas

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

unit NixLib.Geometry;

interface

uses
  System.Types,
  System.Math,
  System.Math.Vectors;

type
  TPoint2D  = TPointF;
  TVector2D = TVector;
  TMatrix2D = TMatrix;

{$REGION 'TPoint2DHelper'}
  TPoint2DHelper = record helper for TPoint2D
    class function CreateSinCos(ATheta: Single): TPoint2D; inline; static;

    function Abs: TPoint2D; inline;

    function Perp: TPoint2D; inline;
    function PerpDotProduct(APoint: TPoint2D): Single; inline;

    function Lerp   (APoint: TPoint2D; AAlpha: Single): TPoint2D;
    function CosLerp(APoint: TPoint2D; AAlpha: Single): TPoint2D; inline;

    function Rotate(ATheta: Single): TPoint2D;

    function CircleMap: TPoint2D;
  end;
{$ENDREGION}

{$REGION 'TPoint3DHelper'}
  TPoint3DHelper = record helper for TPoint3D
    function Abs: TPoint3D; inline;

    function Lerp   (APoint: TPoint3D; AAlpha: Single): TPoint3D;
    function CosLerp(APoint: TPoint3D; AAlpha: Single): TPoint3D; inline;

    function Reflect(ASurfaceNormal: TPoint3D): TPoint3D;
    function ParallelNormal(APt: TPoint3D): TPoint3D;
  end;
{$ENDREGION}

{$REGION 'TMatrix2DHelper'}
  TMatrix2DHelper = record helper for TMatrix2D
    const Identity: TMatrix2D = (m11: 1; m12: 0; m13: 0; m21: 0; m22: 1; m23: 0; m31: 0; m32: 0; m33: 1);

    procedure LoadIdentity; inline;
  end;
{$ENDREGION}

{$REGION 'TMatrix3DHelper'}
  TMatrix3DHelper = record helper for TMatrix3D
    const Identity: TMatrix3D = (m11: 1; m12: 0; m13: 0; m14: 0; m21: 0; m22: 1; m23: 0; m24: 0; m31: 0; m32: 0; m33: 1; m34: 0; m41: 0; m42: 0; m43: 0; m44: 1);

    procedure LoadIdentity; inline;

    function WorldPos: TPoint3D;
    function EyePos:   TPoint3D;

    function Lerp(ADest: TMatrix3D; AAlpha: Single): TMatrix3D;

    procedure Translate(APt: TPoint3D); inline;
    procedure Scale    (APt: TPoint3D); inline;
    procedure Reflect  (APt: TPoint3D); inline;

    procedure RotateX(AAngle: Single); inline;
    procedure RotateY(AAngle: Single); inline;
    procedure RotateZ(AAngle: Single); inline;

    procedure Rotate(AAxis: TPoint3D; AAngle: Single); inline;

    procedure RotateXLocal(AAngle: Single); inline;
    procedure RotateYLocal(AAngle: Single); inline;
    procedure RotateZLocal(AAngle: Single); inline;
  end;
{$ENDREGION}

implementation

{$REGION 'TPoint2DHelper'}
class function TPoint2DHelper.CreateSinCos;
begin
  SinCos(ATheta, Result.X, Result.Y);
end;

function TPoint2DHelper.Abs;
begin
  Result := Create(System.Abs(X), System.Abs(Y));
end;

function TPoint2DHelper.Perp;
begin
  Result := Create(-Y, X);
end;

function TPoint2DHelper.PerpDotProduct;
begin
  Result := (X * APoint.Y) - (Y * APoint.X);
end;

function TPoint2DHelper.Lerp;
begin
  Result := Self + ((APoint - Self) * AAlpha);
end;

function TPoint2DHelper.CosLerp;
begin
  Result := Lerp(APoint, (1 - Cos(AAlpha * PI)) * 0.5);
end;

function TPoint2DHelper.Rotate;
var
  s, c: Single;
begin
  SinCos(ATheta, s, c);
  Result := Create(c * X - s * Y, s * X + c * Y);
end;

function TPoint2DHelper.CircleMap;
begin
  Result := Create(X * Sqrt(1 - Y * Y / 2), Y * Sqrt(1 - X * X / 2));
end;
{$ENDREGION}

{$REGION 'TPoint3DHelper'}
function TPoint3DHelper.Abs;
begin
  Result := Create(System.Abs(X), System.Abs(Y), System.Abs(Z));
end;

function TPoint3DHelper.Lerp;
begin
  Result := Self + ((APoint - Self) * AAlpha);
end;

function TPoint3DHelper.CosLerp;
begin
  Result := Lerp(APoint, (1 - Cos(AAlpha * PI)) * 0.5);
end;

function TPoint3DHelper.Reflect;
begin
  Result := Self - 2.0 * ASurfaceNormal * DotProduct(ASurfaceNormal);
end;

function TPoint3DHelper.ParallelNormal;
begin
  Result := APt * (DotProduct(APt) / Sqr(Length));
end;
{$ENDREGION}

{$REGION 'TMatrix2DHelper'}
procedure TMatrix2DHelper.LoadIdentity;
begin
  Self := Identity;
end;
{$ENDREGION}

{$REGION 'TMatrix3DHelper'}
procedure TMatrix3DHelper.LoadIdentity;
begin
  Self := Identity;
end;

function TMatrix3DHelper.WorldPos;
begin
  Result := TPoint3D.Create(m41, m42, m43);
end;

function TMatrix3DHelper.EyePos;
begin
  Result.X := -m11 * m41 - m12 * m42 - m13 * m43;
  Result.Y := -m21 * m41 - m22 * m42 - m23 * m43;
  Result.Z := -m31 * m41 - m32 * m42 - m33 * m43;
end;

function TMatrix3DHelper.Lerp;
begin
  Result.m11 := m11 + (ADest.m11 - m11) * AAlpha; Result.m21 := m21 + (ADest.m21 - m21) * AAlpha; Result.m31 := m31 + (ADest.m31 - m31) * AAlpha; Result.m41 := m41 + (ADest.m41 - m41) * AAlpha;
  Result.m12 := m12 + (ADest.m12 - m12) * AAlpha; Result.m22 := m22 + (ADest.m22 - m22) * AAlpha; Result.m32 := m32 + (ADest.m32 - m32) * AAlpha; Result.m42 := m41 + (ADest.m42 - m42) * AAlpha;
  Result.m11 := m13 + (ADest.m13 - m11) * AAlpha; Result.m23 := m21 + (ADest.m23 - m23) * AAlpha; Result.m33 := m33 + (ADest.m31 - m33) * AAlpha; Result.m43 := m41 + (ADest.m43 - m43) * AAlpha;
  Result.m11 := m14 + (ADest.m14 - m11) * AAlpha; Result.m24 := m21 + (ADest.m24 - m24) * AAlpha; Result.m34 := m34 + (ADest.m31 - m34) * AAlpha; Result.m44 := m41 + (ADest.m44 - m44) * AAlpha;
end;

procedure TMatrix3DHelper.Translate;
begin
  Self := Self * CreateTranslation(APt);
end;

procedure TMatrix3DHelper.Scale;
begin
  Self := Self * CreateScaling(APt);
end;

procedure TMatrix3DHelper.Reflect;
begin
  // TODO: Reflect
  Self := Self;
end;

procedure TMatrix3DHelper.RotateX;
begin
  Self := Self * CreateRotationX(AAngle);
end;

procedure TMatrix3DHelper.RotateY;
begin
  Self := Self * CreateRotationY(AAngle);
end;

procedure TMatrix3DHelper.RotateZ;
begin
  Self := Self * CreateRotationZ(AAngle);
end;

procedure TMatrix3DHelper.Rotate;
begin
  Self := Self * CreateRotation(AAxis, AAngle)
end;

procedure TMatrix3DHelper.RotateXLocal;
begin
  Self := Self * CreateRotation(TPoint3D.Create(m11, m12, m13), AAngle);
end;

procedure TMatrix3DHelper.RotateYLocal;
begin
  Self := Self * CreateRotation(TPoint3D.Create(m21, m22, m23), AAngle);
end;

procedure TMatrix3DHelper.RotateZLocal;
begin
  Self := Self * CreateRotation(TPoint3D.Create(m31, m32, m33), AAngle);
end;
{$ENDREGION}

end.

