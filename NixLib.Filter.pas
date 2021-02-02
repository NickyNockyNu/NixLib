{
  NixLib.Filter.pas

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

unit NixLib.Filter;

interface

uses
  System.Math;

type
{$REGION 'TFloatFilter'}
  TCustomFloatFilter = class
  private
    FValue: Extended;
    FDirty: Boolean;

    function  GetValue: Extended;         virtual;
    procedure SetValue(AValue: Extended); virtual;
  public
    procedure Update; virtual;
    procedure Reset(const AValue: Extended); virtual;

    property Value: Extended read GetValue write SetValue;
    property Dirty: Boolean  read FDirty;
  end;
{$ENDREGION}

{$REGION 'TFloatBucketFilter'}
  TFloatBucketFilter = class(TCustomFloatFilter)
  private
    FBucket: array of Extended;
    FIndex:  Integer;

    function  GetBucketSize: Integer;
    procedure SetBucketSize(AValue: Integer);

    procedure SetValue(AValue: Extended); override;
  public
    constructor Create(const ABucketSize: Integer = 16);

    property BucketSize: Integer read GetBucketSize write SetBucketSize;
  end;
{$ENDREGION}

{$REGION 'TFloatFilter'}
  TFloatFilterType = (ftMean, ftMin, ftMax, ftStdDev, ftNorm);

  TFloatFilter = class(TFloatBucketFilter)
  private
    FFilterType: TFloatFilterType;

    procedure SetFilterType(AValue: TFloatFilterType);
  public
    class function Filter(const AData: array of Extended; AFilterType: TFloatFilterType): Extended;

    constructor Create(const AFilterType: TFloatFilterType = ftMean; const ABucketSize: Integer = 16);

    procedure Update; override;

    property FilterType: TFloatFilterType read FFilterType write SetFilterType;
  end;
{$ENDREGION}

implementation

{$REGION 'TCustomFloatFilter'}
function TCustomFloatFilter.GetValue;
begin
  if FDirty then
    Update;

  Result := FValue;
end;

procedure TCustomFloatFilter.SetValue;
begin
  FDirty := True;
  FValue := AValue;
end;

procedure TCustomFloatFilter.Update;
begin
  FDirty := False;
end;

procedure TCustomFloatFilter.Reset;
begin
  FValue := AValue;
  FDirty := False;
end;
{$ENDREGION}

{$REGION 'TFloatBucketFilter'}
function TFloatBucketFilter.GetBucketSize;
begin
  Result := Length(FBucket);
end;

procedure TFloatBucketFilter.SetBucketSize;
var
  v: Extended;
begin
  v := GetValue;

  SetLength(FBucket, AValue);

  Reset(v);
end;

procedure TFloatBucketFilter.SetValue;
begin
  Inc(FIndex);

  if FIndex > High(FBucket) then
    FIndex := Low(FBucket);

  FBucket[FIndex] := AValue;

  FDirty := True;
end;

constructor TFloatBucketFilter.Create;
begin
  inherited Create;

  SetBucketSize(ABucketSize);
end;
{$ENDREGION}

{$REGION 'TFloatFilter'}
procedure TFloatFilter.SetFilterType;
begin
  if FFilterType = AValue then
    Exit;

  FFilterType := AValue;
  FDirty      := True;
end;

class function TFloatFilter.Filter;
begin
  case AFilterType of
    ftMin:    Result := MinValue(AData);
    ftMax:    Result := MaxValue(AData);
    ftMean:   Result := Mean(AData);
    ftStdDev: Result := StdDev(AData);
    ftNorm:   Result := Norm(AData);
  else
    Result := 0;
  end;
end;

constructor TFloatFilter.Create;
begin
  FFilterType := AFilterType;

  inherited Create(ABucketSize);
end;

procedure TFloatFilter.Update;
begin
  FValue := Filter(FBucket, FFilterType);
  FDirty := False;
end;
{$ENDREGION}

end.

