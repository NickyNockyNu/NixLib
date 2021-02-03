{
  NixLib.Busy.pas

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

unit NixLib.Busy;

interface

uses
  System.Types,
  System.Classes,

  WinApi.Windows,

  FMX.Types,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.Layouts,
  FMX.Filter.Effects,
  FMX.Effects,
  FMX.Ani;

type
{$REGION 'TBusy'}
  TBusy = class
  private
    FLevel: Integer;

    FEffect:    TBlurEffect;
    FAnimation: TFloatAnimation;

    FControl: TControl;

    procedure AnimationFinish(ASender: TObject);

    procedure SetControl(AControl: TControl);

    function  GetDuration: Single;         inline;
    procedure SetDuration(AValue: Single); inline;
  public
    constructor Create(AControl: TControl);
    destructor  Destroy; override;

    procedure Update;

    procedure Start;
    procedure Stop;

    function IsBusy: Boolean; inline;

    property Control: TControl read FControl write SetControl;

    property Duration: Single read GetDuration write SetDuration;
  end;
{$ENDREGION}

implementation

uses
  NixLib.Globals;

{$REGION 'TBusy'}
procedure TBusy.AnimationFinish;
begin
  if FEffect.Softness = 0 then
  begin
    FEffect.Enabled := False;
    FEffect.Parent  := nil;
  end;
end;

procedure TBusy.SetControl;
begin
  FControl := AControl;
  Update;
end;

function TBusy.GetDuration;
begin
  Result := FAnimation.Duration;
end;

procedure TBusy.SetDuration;
begin
  FAnimation.Duration := AValue;
end;

constructor TBusy.Create;
begin
  inherited Create;

  FLevel := 0;

  FEffect := TBlurEffect.Create(nil);
  FEffect.Softness := 0;

  FAnimation              := TFloatAnimation.Create(FEffect);
  FAnimation.Parent       := FEffect;
  FAnimation.Interpolation:= TInterpolationType.Exponential;
  FAnimation.Duration     := 0.6;
  FAnimation.PropertyName := 'Softness';
  FAnimation.OnFinish     := AnimationFinish;

  SetControl(AControl);
end;

destructor TBusy.Destroy;
begin
  FEffect.Parent := nil;
  FEffect.Free;

  inherited;
end;

procedure TBusy.Update;
begin
  if FControl <> nil then
  begin
    if NixLib.Globals.DisableEffects then
      FControl.Enabled := not IsBusy
    else
      FControl.SetDesign(IsBusy, True);

    if IsBusy then
      FEffect.Parent := FControl;
  end;
end;

procedure TBusy.Start;
begin
  Inc(FLevel);

  if FLevel = 1 then
  begin
    Update;

    FAnimation.StopAtCurrent;

    if not NixLib.Globals.DisableEffects then
    begin
      FAnimation.StartValue := FEffect.Softness;
      FAnimation.StopValue  := 0.4;

      FAnimation.Start;

      FEffect.Enabled := True;
    end;
  end;
end;

procedure TBusy.Stop;
begin
  if FLevel = 0 then
    Exit;

  Dec(FLevel);

  if FLevel = 0 then
  begin
    Update;

    FAnimation.StopAtCurrent;

    if not NixLib.Globals.DisableEffects then
    begin
      FAnimation.StartValue := FEffect.Softness;
      FAnimation.StopValue  := 0;

      FAnimation.Start;

      FEffect.Enabled := True;
    end;
  end;
end;

function TBusy.IsBusy: Boolean;
begin
  Result := FLevel > 0;
end;
{$ENDREGION}

end.

