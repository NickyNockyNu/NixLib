{
  NixLib.SceneGraph.pas

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

unit NixLib.SceneGraph;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Diagnostics,
  System.Threading,
  System.SyncObjs,
  System.TimeSpan,

  NixLib.Timing;

type
{$REGION 'TSceneNode'}
  TSceneNode = class
  private
    FParent:   TSceneNode;
    FChildren: TList<TSceneNode>;

    FData: Pointer;

    FLock:    Integer;
    FEnabled: Boolean;

    FAutoFree: Boolean;

    procedure SetParent(AValue: TSceneNode);
    function  GetRoot: TSceneNode;

    function GetChildCount: Integer;                inline;
    function GetChild(AIndex: Integer): TSceneNode; inline;

    function  GetLocked: Boolean;         inline;
    procedure SetLocked(AValue: Boolean); inline;

    function  GetEnabled: Boolean;         virtual;
    procedure SetEnabled(AValue: Boolean); virtual;
  public
    constructor Create(const AParent: TSceneNode; const AAutoFree: Boolean = True);
    destructor  Destroy; override;

    procedure Lock;
    procedure Unlock(const ASignal: Boolean = True);
    procedure Unlocked; virtual;

    function  Find  (const AChild: TSceneNode): Integer;
    function  Exists(const AChild: TSceneNode): Boolean; inline;
    function  Add   (const AChild: TSceneNode): Integer;
    procedure Remove(const AChild: TSceneNode; const AAndFree: Boolean = True);
    procedure Clear (const AAndFree: Boolean = True);

    procedure PushState; virtual;
    procedure PopState;  virtual;

    function Process(const ADelta: Double = 1): Boolean; virtual;
    function Update (const ADelta: Double = 1): Boolean;

    procedure Yield;

    property Parent: TSceneNode read FParent write SetParent;
    property Root:   TSceneNode read GetRoot;

    property ChildCount:                Integer    read GetChildCount;
    property Children[AIndex: Integer]: TSceneNode read GetChild;

    property Data: Pointer read FData write FData;

    property AutoFree: Boolean read FAutoFree write FAutoFree;

    property Locked:  Boolean read GetLocked  write SetLocked;
    property Enabled: Boolean read GetEnabled write SetEnabled;
  end;
{$ENDREGION}

implementation

{$REGION 'TSceneNode'}
procedure TSceneNode.SetParent;
begin
  if FParent = AValue then
    Exit;

  if AValue <> nil then
    AValue.Add(Self)
  else if FParent <> nil then
    FParent.Remove(Self, False);
end;

function TSceneNode.GetRoot;
begin
  Result := Self;

  while Result.FParent <> nil do
    Result := Result.FParent;
end;

function TSceneNode.GetChildCount;
begin
  Result := FChildren.Count;
end;

function TSceneNode.GetChild;
begin
  Result := FChildren[AIndex];
end;

function TSceneNode.GetLocked;
begin
  Result := FLock > 0;
end;

procedure TSceneNode.SetLocked;
begin
  if AValue then
    Lock
  else
    Unlock;
end;

function TSceneNode.GetEnabled;
begin
  Result := FEnabled;
end;

procedure TSceneNode.SetEnabled;
begin
  fEnabled := AValue;
end;

constructor TSceneNode.Create;
begin
  inherited Create;

  FLock := 0;

  FChildren := TList<TSceneNode>.Create;

  FParent := nil;

  FAutoFree := AAutoFree;

  if AParent <> nil then
    SetParent(AParent);
end;

destructor TSceneNode.Destroy;
begin
  Clear;

  if FParent <> nil then
    SetParent(nil);

  FChildren.Free;

  inherited;
end;

procedure TSceneNode.Lock;
begin
  Inc(FLock);
end;

procedure TSceneNode.Unlock;
begin
  if FLock = 0 then
    Exit;

  Dec(FLock);

  if (FLock = 0) and ASignal then
    Unlocked;
end;

procedure TSceneNode.Unlocked;
begin
  Root.Update;
end;

function TSceneNode.Find;
var
  i: Integer;
begin
  for i := FChildren.Count - 1 downto 0 do
    if FChildren[i] = AChild then
      Exit(i);

  Result := -1;
end;

function TSceneNode.Exists;
begin
  Result := Find(AChild) > -1;
end;

function TSceneNode.Add;
begin
  if AChild = nil then
    Exit(-1);

  Result := Find(AChild);
  if Result > -1 then
    Exit;

  if AChild.FParent <> nil then
    AChild.FParent.Remove(Self, False);

  AChild.FParent := Self;

  Result := FChildren.Add(AChild);
end;

procedure TSceneNode.Remove;
var
  i: Integer;
begin
  i := Find(AChild);
  if i = -1 then
    Exit;

  AChild.FParent := nil;
  FChildren.Delete(i);

  if AAndFree then
    AChild.Free;
end;

procedure TSceneNode.Clear;
var
  i: Integer;
begin
  if AAndFree then
    for i := FChildren.Count - 1 downto 0 do
      FChildren[i].Free;

  FChildren.Clear;
end;

procedure TSceneNode.PushState;
begin
  {}
end;

procedure TSceneNode.PopState;
begin
  {}
end;

function TSceneNode.Process;
begin
  Result := True;
end;

function TSceneNode.Update;
var
  i: Integer;
begin
  if Locked or (not Enabled) then
    Exit(False);

  PushState;

  try
    Result := Process(ADelta);

    if Result then
      for i := FChildren.Count - 1 downto 0 do
        if (not FChildren[i].Update(ADelta)) and FChildren[i].FAutoFree then
        begin
          FChildren[i].FParent := nil;
          FChildren[i].Free;
          FChildren.Delete(i);
        end;
  finally
    PopState;
  end;
end;

procedure TSceneNode.Yield;
begin
  Lock;

  try
    Root.Update;
  finally
    Unlock;
  end;
end;
{$ENDREGION}

end.

