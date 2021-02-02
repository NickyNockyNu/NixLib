{
  NixLib.Transitions.pas

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

unit NixLib.Transitions;

interface

uses
  System.Types,
  System.Classes,

  FMX.Types,
  FMX.Graphics,
  FMX.Filter.Effects,
  FMX.Ani,

  NixLib.Rtti;

type
  TTransitionClass = class of TImageFXEffect;

  TTransitionType = (ttFade, ttLine, ttCircle, ttRipple, ttBlur, ttPixelate,
                     ttDissolve, ttBlood, ttShape, ttDrop, ttWater, ttWave,
                     ttCrumple, ttRotateCrumple, ttMagnify, ttWiggle, ttSwirl,
                     ttBandedSwirl, ttBlind, ttSlide, ttSaturate, ttBright);

const
  TransitionTypes: array[TTransitionType] of TTransitionClass = (
    TFadeTransitionEffect,
    TLineTransitionEffect,
    TCircleTransitionEffect,
    TRippleTransitionEffect,
    TBlurTransitionEffect,
    TPixelateTransitionEffect,
    TDissolveTransitionEffect,
    TBloodTransitionEffect,
    TShapeTransitionEffect,
    TDropTransitionEffect,
    TWaterTransitionEffect,
    TWaveTransitionEffect,
    TCrumpleTransitionEffect,
    TRotateCrumpleTransitionEffect,
    TMagnifyTransitionEffect,
    TWiggleTransitionEffect,
    TSwirlTransitionEffect,
    TBandedSwirlTransitionEffect,
    TBlindTransitionEffect,
    TSlideTransitionEffect,
    TSaturateTransitionEffect,
    TBrightTransitionEffect
  );

type
{$REGION 'TTransition'}
  TTransition = class(TfmxObject)
  private
    FTransitionType: TTransitionType;
    FTransition:     TImageFXEffect;
    FAnimation:      TFloatAnimation;

    function  GetParent: TFmxObject;          inline;
{$WARN HIDDEN_VIRTUAL OFF}
    procedure SetParent(AParent: TFmxObject); inline;
{$WARN HIDDEN_VIRTUAL ON}

    procedure SetTransitionType(AType: TTransitionType);

    function  GetProgress: Single;            inline;
    procedure SetProgress(AProgress: Single); inline;

    function GetTarget: TBitmap;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    property Parent: TFmxObject read GetParent write SetParent;

    property TransitionType: TTransitionType read fTransitionType write SetTransitionType;
    property Transition:     TImageFXEffect  read fTransition;
    property Animation:      TFloatAnimation read fAnimation;

    property Progress: Single  read GetProgress write SetProgress;
    property Target:   TBitmap read GetTarget;
  end;
{$ENDREGION}

implementation

uses
  NixLib.Globals;

{$REGION 'TTransition'}
function TTransition.GetParent;
begin
  Result := inherited Parent;
end;

procedure TTransition.SetParent;
begin
  inherited Parent := AParent;
  FTransition.Parent := AParent;
end;

procedure TTransition.SetTransitionType;
begin
  if FTransition <> nil then
    FTransition.Free;

  FTransitionType := AType;
  FTransition := TransitionTypes[AType].Create(nil);
end;

function TTransition.GetProgress;
begin
  Result := 100 - FTransition.RttiReadProperty('Progress').AsType<Single>;
end;

procedure TTransition.SetProgress;
begin
  FTransition.RttiWriteProperty('Progress', 100 - AProgress);
end;

function TTransition.GetTarget;
begin
  Result := fTransition.RttiReadProperty('Target').AsObject as TBitmap;
end;

constructor TTransition.Create;
begin
  inherited Create(AOwner);

  FTransition := nil;
  SetTransitionType(ttFade);

  FAnimation              := TFloatAnimation.Create(Self);
  FAnimation.Parent       := Self;
  FAnimation.Duration     := 0.5;
  FAnimation.PropertyName := 'Progress';
  FAnimation.StartValue   := 0;
  FAnimation.StopValue    := 100;
end;

destructor TTransition.Destroy;
begin
  FAnimation.Stop;
  FAnimation.Free;

  if FTransition <> nil then
  begin
    FTransition.Parent := nil;
    try FTransition.Free; except end;
  end;

  inherited;
end;
{$ENDREGION}

end.

