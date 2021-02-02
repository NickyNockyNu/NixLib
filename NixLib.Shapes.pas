{
  NixLib.Shapes.pas

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

unit NixLib.Shapes;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Generics.Collections,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Objects;

const
  PropRotateX = 1;
  PropRotateY = 2;

  PropRotateAngle = 5;

type
{$REGION 'TShapeHelper'}
  TShapeHelper = class helper for TShape
  private
    function  GetRotateProp(AIndex: Integer): Extended;
    procedure SetRotateProp(AIndex: Integer; AValue: Extended);
  published
    property RotateX: Extended index PropRotateX read GetRotateProp write SetRotateProp;
    property RotateY: Extended index PropRotateY read GetRotateProp write SetRotateProp;

    property RotateAngle: Extended index PropRotateAngle read GetRotateProp write SetRotateProp;
  end;
{$ENDREGION}

{$REGION 'TPathHelper'}
  TPathHelper = class helper for TPath
  public
    procedure CalculateBounds;
  end;
{$ENDREGION}

implementation

{$REGION 'TShapeHelper'}
function TShapeHelper.GetRotateProp;
begin
  case AIndex of
    PropRotateX:
      if Self is TRectangle then
        Result := TRectangle(Self).RotationCenter.X
      else if Self is TRoundRect then
        Result := TRoundRect(Self).RotationCenter.X
      else if Self is TEllipse then
        Result := TEllipse(Self).RotationCenter.X
      else if Self is TPath then
        Result := TPath(Self).RotationCenter.X
      else
        Result := 0;

    PropRotateY:
      if Self is TRectangle then
        Result := TRectangle(Self).RotationCenter.Y
      else if Self is TRoundRect then
        Result := TRoundRect(Self).RotationCenter.Y
      else if Self is TEllipse then
        Result := TEllipse(Self).RotationCenter.Y
      else if Self is TPath then
        Result := TPath(Self).RotationCenter.Y
      else
        Result := 0;

    PropRotateAngle:
      if Self is TRectangle then
        Result := TRectangle(Self).RotationAngle
      else if Self is TRoundRect then
        Result := TRoundRect(Self).RotationAngle
      else if Self is TEllipse then
        Result := TEllipse(Self).RotationAngle
      else if Self is TPath then
        Result := TPath(Self).RotationAngle
      else
        Result := 0;
  else
    Result := 0;
  end;
end;

procedure TShapeHelper.SetRotateProp;
begin
  case AIndex of
    PropRotateX:
      if Self is TRectangle then
        TRectangle(Self).RotationCenter.X := AValue
      else if Self is TRoundRect then
        TRoundRect(Self).RotationCenter.X := AValue
      else if Self is TEllipse then
        TEllipse(Self).RotationCenter.X := AValue
      else if Self is TPath then
        TPath(Self).RotationCenter.X := AValue;

    PropRotateY:
      if Self is TRectangle then
        TRectangle(Self).RotationCenter.Y := AValue
      else if Self is TRoundRect then
        TRoundRect(Self).RotationCenter.Y := AValue
      else if Self is TEllipse then
        TEllipse(Self).RotationCenter.Y := AValue
      else if Self is TPath then
        TPath(Self).RotationCenter.Y := AValue;

    PropRotateAngle:
      if Self is TRectangle then
        TRectangle(Self).RotationAngle := AValue
      else if Self is TRoundRect then
        TRoundRect(Self).RotationAngle := AValue
      else if Self is TEllipse then
        TEllipse(Self).RotationAngle := AValue
      else if Self is TPath then
        TPath(Self).RotationAngle := AValue;
  end;
end;
{$ENDREGION}

{$REGION 'TPathHelper'}
procedure TPathHelper.CalculateBounds;
var
  MinX, MaxX: Extended;
  MinY, MaxY: Extended;
begin
  MinX := 0; MaxX := 0;
  MinY := 0; MaxY := 0;

  for var i := 0 to Data.Count - 1 do
    with Data.Points[i].Point do
    begin
      SetLocation(X, -Y);

      if X < MinX then
        MinX := X;

      if Y < MinY then
        MinY := Y;

      if X > MaxX then
        MaxX := X;

      if Y > MaxY then
        MaxY := Y;
    end;

  if (MinX = MaxX) or (MinY = MaxY) then
  begin
    Exit;
  end;

  Width  := MaxX - MinX;
  Height := MaxY - MinY;
end;
{$ENDREGION}

end.

