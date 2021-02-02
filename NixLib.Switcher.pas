{
  NixLib.Switcher.pas

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

unit NixLib.Switcher;

interface

{$M+}

uses
  System.Types,
  System.Classes,
  System.Generics.Collections,

  FMX.Types,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.Layouts,
  FMX.Filter.Effects,
  FMX.Effects,
  FMX.Ani,

  NixLib.Busy,
  NixLib.Transitions;

type
{$REGION 'TSwitcher'}
  TSwitcher = class
  private
    FControls:      TList<TControl>;
    FActiveControl: TControl;

    FTransition:     TTransition;
    FTransitionType: TTransitionType;
    FTransitionTime: Single;

    fBusy: TBusy;

    procedure TransitionAnimationFinish(ASender: TObject);

    procedure SetActiveControl(AControl: TControl);

    function  GetTransitionType: TTransitionType;                  inline;
    procedure SetTransitionType(ATransitionType: TTransitionType); inline;

    function  GetTransitionTime: Single;                  inline;
    procedure SetTransitionTime(ATransitionTime: Single); inline;

    function GetControlCount: Integer; inline;
    function GetControl(AIndex: Integer): TControl; inline;
  public
    class function CreateGroup(ARoot: TComponent; ATag: Integer = 0): TSwitcher;

    constructor Create;
    destructor  Destroy; override;

    procedure Add   (AControls: array of TControl);
    procedure Remove(AControls: array of TControl);

    procedure AddFromComponent(AComponent: TComponent; ATag: Integer = 0);

    procedure Clear; inline;

    procedure HideAll(const AHideActive: Boolean = False);

    procedure Random;
  published
    property ActiveControl: TControl read FActiveControl write SetActiveControl;

    property Transition:     TTransition     read FTransition;
    property TransitionType: TTransitionType read GetTransitionType write SetTransitionType;
    property TransitionTime: Single          read GettransitionTime write SetTransitionTime;

    property Busy: TBusy read FBusy;
  public
    property ControlCount:             Integer  read GetControlCount;
    property Control[AIndex: Integer]: TControl read GetControl;
  end;
{$ENDREGION}

implementation

uses
  NixLib.Globals;

{$REGION 'TSwitcher'}
procedure TSwitcher.TransitionAnimationFinish;
begin
  if FTransition.Parent <> nil then
  begin
    //TControl(FTransition.Parent).Visible := False;
    FTransition.Parent := nil;
  end;

  if FActiveControl <> nil then
    FActiveControl.Visible := True;
end;

procedure TSwitcher.SetActiveControl;
var
  OldControl: TControl;
begin
  if (FActiveControl = AControl) or (FControls.IndexOf(AControl) = -1) then
    Exit;

  FTransition.Animation.StopAtCurrent;

  OldControl     := FActiveControl;
  FActiveControl := AControl;

  Busy.Control := FActiveControl;

  FTransition.TransitionType     := FTransitionType;
  FTransition.Animation.Duration := FTransitionTime;

  if (FTransition.Animation.Duration = 0) or NixLib.Globals.DisableEffects then
  begin
    FActiveControl.Visible := True;

    if OldControl <> nil then
      OldControl.Visible := False;

    FActiveControl.UpdateEffects;

    Exit;
  end;

  if OldControl <> nil then
  begin
    //OldControl.Repaint;
    //FActiveControl.Repaint;

    if FTransition.TransitionType = ttSlide then
      with FTransition.Transition as TSlideTransitionEffect do
        SlideAmount := TPointF.Create(fActiveControl.Width, 0);

    var TransView := OldControl.MakeScreenshot;
    try
      FTransition.Parent := FActiveControl;
      FTransition.Target.Assign(TransView);
      FTransition.Animation.Start;
    finally
      TransView.Free;
    end;
  end;

  FActiveControl.Visible := True;

  if OldControl <> nil then
  begin
    OldControl.Visible := False;
    FTransition.Animation.Start;
  end;
end;

function TSwitcher.GetTransitionType;
begin
  Result := FTransitionType;
end;

procedure TSwitcher.SetTransitionType;
begin
  FTransitionType := ATransitionType;
end;

function TSwitcher.GetTransitionTime;
begin
  Result := FTransitionTime;
end;

procedure TSwitcher.SetTransitionTime;
begin
  FTransitionTime := ATransitionTime;
end;

function TSwitcher.GetControlCount;
begin
  Result := FControls.Count;
end;

function TSwitcher.GetControl;
begin
  Result := FControls[AIndex];
end;

class function TSwitcher.CreateGroup;
begin
  Result := TSwitcher.Create;
  Result.AddFromComponent(ARoot, ATag);
end;

constructor TSwitcher.Create;
begin
  inherited;

  FControls := TList<TControl>.Create;

  FActiveControl := nil;

  FTransition := TTransition.Create(nil);
  FTransition.Animation.OnFinish := TransitionAnimationFinish;

  FTransitionType := fTransition.TransitionType;
  FTransitionTime := fTransition.Animation.Duration;

  FBusy := TBusy.Create(nil);
end;

destructor TSwitcher.Destroy;
begin
  FBusy.Free;
  FTransition.Free;
  FControls.Free;

  inherited;
end;

procedure TSwitcher.Add;
begin
  for var Control in AControls do
  begin
    if FControls.IndexOf(Control) >= 0 then
      Continue;

    FControls.Add(Control);
  end;
end;

procedure TSwitcher.Remove;
var
  Index: Integer;
begin
  for var Control in AControls do
  begin
    Index := FControls.IndexOf(Control);

    if Index >= 0 then
      FControls.Delete(Index);
  end;
end;

procedure TSwitcher.AddFromComponent;
  procedure IncludeComponent(C: TComponent);
  begin
    for var i := 0 to C.ComponentCount - 1 do
    begin
      if C.Components[i] is TControl then
        if TControl(C.Components[i]).Tag = ATag then
          Add([TControl(C.Components[i])]);

      //IncludeComponent(C.Components[i]);
    end;
  end;
begin
  IncludeComponent(AComponent);
end;

procedure TSwitcher.Clear;
begin
  FControls.Clear;
end;

procedure TSwitcher.HideAll;
begin
  for var Control in FControls do
    if (Control <> FActiveControl) or AHideActive then
      Control.Visible := False;

  if AHideActive then
    FActiveControl := nil;
end;

procedure TSwitcher.Random;
var
  i:      Integer;
  Picked: TControl;
begin
  i := 0;
  repeat
    Picked := FControls[System.Random(FControls.Count)];

    if (Picked <> FActiveControl) and (Picked.Tag >= 0) then
      Break;

    Inc(i);
  until i > 10000;

  ActiveControl := Picked;
end;
{$ENDREGION}

end.

