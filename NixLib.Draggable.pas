{
  NixLib.Draggable.pas

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

unit NixLib.Draggable;

interface

uses
  System.Types,
  System.UITypes,
  System.Classes,
  System.Math.Vectors,

  FMX.Controls;

type
  TDragEvent = procedure(AControl: TControl) of object;

{$REGION 'TDragHelper'}
  TDragHelper = class
  private
    FDragControl: TControl;
    FDragPoint:   TPointF;

    FRepaintBeforeDrag: Boolean;
    FRepaintAfterDrag:  Boolean;
    FRepaintOnDrag:     Boolean;

    FBringToFront: Boolean;

    FOnDragBegin: TDragEvent;
    FOnDragEnd:   TDragEvent;
    FOnDragMove:  TDragEvent;

    procedure RepaintDragControl;
  public
    constructor Create;

    procedure SetControlEvents(AControl: TControl);

    procedure ControlMouseDown(ASender: TObject; AButton: TMouseButton; AShift: TShiftState; AX, AY: Single);
    procedure ControlMouseUp  (ASender: TObject; AButton: TMouseButton; AShift: TShiftState; AX, AY: Single);
    procedure ControlMouseMove(ASender: TObject; AShift: TShiftState; AX, AY: Single);

    property DragControl: TControl read FDragControl;
  published
    property RepaintBeforeDrag: Boolean read FRepaintBeforeDrag write FRepaintBeforeDrag;
    property RepaintAfterDrag:  Boolean read FRepaintAfterDrag  write FRepaintAfterDrag;
    property RepaintOnDrag:     Boolean read FRepaintOnDrag     write FRepaintOnDrag;

    property BringToFront: Boolean read FBringToFront write FBringToFront;

    property OnDragBegin: TDragEvent read FOnDragBegin write FOnDragBegin;
    property OnDragEnd:   TDragEvent read FOnDragEnd   write FOnDragEnd;
    property OnDragMove:  TDragEvent read FOnDragMove  write FOnDragMove;
  end;
{$ENDREGION}

implementation

{$REGION 'TDragHelper'}
constructor TDragHelper.Create;
begin
  inherited;

  FRepaintBeforeDrag := True;
  FRepaintAfterDrag  := True;
  FRepaintOnDrag     := True;

  FBringToFront := True;
end;

procedure TDragHelper.SetControlEvents;
begin
  with AControl do
  begin
    OnMouseDown := ControlMouseDown;
    OnMouseUp   := ControlMouseUp;
    OnMouseMove := ControlMouseMove;

    AutoCapture := True;
  end;
end;

procedure TDragHelper.RepaintDragControl;
begin
  if FDragControl = nil then
    Exit;

  try
    FDragControl.UpdateEffects;
    FDragControl.Repaint;
  except
    {}
  end;
end;

procedure TDragHelper.ControlMouseDown;
begin
  if (ASender = FDragControl) or (not (ASender is TControl)) then
    Exit;

  FDragControl := ASender as TControl;
  FDragPoint   := TPointF.Create(AX, AY);

  if FBringToFront then
    FDragControl.BringToFront;

  if Assigned(FOnDragBegin) then
    FOnDragBegin(FDragControl);

  if FRepaintBeforeDrag then
    RepaintDragControl;
end;

procedure TDragHelper.ControlMouseUp;
begin
  if Assigned(FOnDragEnd) then
    FOnDragEnd(FDragControl);

  if FRepaintAfterDrag then
    RepaintDragControl;

  FDragControl := nil;
end;

procedure TDragHelper.ControlMouseMove;
begin
  if (FDragControl = nil) or (ASender <> FDragControl) then
    Exit;

  var MoveVect := FDragControl.LocalToAbsoluteVector(TVector.Create(AX - FDragPoint.X, AY - FDragPoint.Y));

  if FDragControl.ParentControl <> nil then
    MoveVect := FDragControl.ParentControl.AbsoluteToLocalVector(MoveVect);

  FDragControl.Position.Point := FDragControl.Position.Point + TPointF(MoveVect);

  if Assigned(FOnDragMove) then
    FOnDragMove(FDragControl);

  if FRepaintOnDrag then
    RepaintDragControl;
end;
{$ENDREGION}

end.

