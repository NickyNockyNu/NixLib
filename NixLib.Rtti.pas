{
  NixLib.Rtti.pas

    Copyright � 2021 Nicholas Smith

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

unit NixLib.Rtti;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo;

type
{$REGION 'TRttiConextHelper'}
  TRttiContextHelper = record helper for TRttiContext
  private
    class constructor Create;
    class destructor  Destroy;
  public
    class var Context: TRttiContext;

    function FindPublishedType(const AName: String): TRttiType;
  end;
{$ENDREGION}

{$REGION 'TObjectHelper'}
  TObjectHelper = class helper for TObject
  private
    function GetThis: TObject; inline;

    function  RttiGetAsText: String;
    procedure RttiSetAsText(AValue: String);
  public
    class procedure Use;

    function  RttiReadProperty (const AName: String): TValue;
    procedure RttiWriteProperty(const AName: String; AValue: TValue);

    function RttiInvokeMethod(const AName: String; AArgs: array of TValue): TValue;

    function RttiIsReadable (const AName: String): Boolean;
    function RttiIsWriteable(const AName: String): Boolean;

    property This: TObject read GetThis;

    property RttiAsText: String read RttiGetAsText write RttiSetAsText;
  end;
{$ENDREGION}

{$REGION 'TExpandableObject'}
  TExpandableObject = class
  public
    function  RttiReadExpandedProperty (const AName: String): TValue;        virtual;
    procedure RttiWriteExpandedProperty(const AName: String; AValue: TValue); virtual;

    function RttiInvokeExpandedMethod(const AName: String; AArgs: array of TValue): TValue; virtual;

    function RttiIsExpandedReadable (const AName: String): Boolean; virtual;
    function RttiIsExpandedWriteable(const AName: String): Boolean; virtual;
  end;
{$ENDREGION}

  EReadOnlyProperty = class(Exception);
  EUnknownProperty  = class(Exception);
  EUnknownMethod    = class(Exception);

resourcestring
  SReadOnlyProperty  = 'Property "%s" is read only';
  SUnknownProperty   = 'Unknown property "%s"';
  SUnknownMethod     = 'Unknown method "%s"';

const
  RttiTextProps: array[0..4] of String = ('AsText', 'Text', 'AsString', 'Name', 'Caption');

var
  RttiTextPrefix: Boolean = False;

implementation

uses
  NixLib.Strings;

{$REGION 'TRttiContextHelper'}
class constructor TRttiContextHelper.Create;
begin
  Context := TRttiContext.Create;
end;

class destructor TRttiContextHelper.Destroy;
begin
  Context.Free;
end;

function TRttiContextHelper.FindPublishedType;
var
  i:    Integer;
  f, n: String;
begin
  f := AName.LowerCase;

  Result := nil;

  for var Typ in Context.GetTypes do
  begin
    n := Result.QualifiedName.LowerCase;

    for i := n.Length downto 1 do
      if n[i] = '.' then
        Break;

    n := n.Copy(i + 1);

    if n = f then
      Exit(Typ);
  end;
end;
{$ENDREGION}

{$REGION 'TObjectHelper'}
function TObjectHelper.GetThis;
begin
  Result := Self;
end;

function TObjectHelper.RttiGetAsText;
begin
  if Self = nil then
    Exit('(nil object)');

  if RttiTextPrefix then
{$IFDEF MSWINDOWS}
    Result := ClassName + '(' + String.Pointer(@Self) + ')'
{$ELSE}
    Result := String.Pointer(Self)
{$ENDIF}
  else
    Result := '';

  if ToString.Compare(ClassName) = 0 then
  begin
    for var Prop in RttiTextProps do
      if RttiIsReadable(Prop) then
        Exit(Result.Append(RttiReadProperty(Prop).ToString, ':'));
  end
  else
    Result := Result.Append(ToString, ':');
end;

procedure TObjectHelper.RttiSetAsText;
begin
  if Self = nil then Exit;

  for var Prop in RttiTextProps do
    if RttiIsWriteable(Prop) then
      try
        RttiWriteProperty(Prop, AValue);
        Exit;
      except
        Continue;
      end;
end;

class procedure TObjectHelper.Use;
begin
  for var i := 0 to 1 do ;
end;

function TObjectHelper.RttiReadProperty;
var
  RttiProperty: TRttiProperty;
begin
  TMonitor.Enter(Self);

  try
    if Self is TExpandableObject then
      with Self as TExpandableObject do
      begin
        if RttiIsExpandedReadable(AName) then
          try
            Result := RttiReadExpandedProperty(AName);
            Exit;
          except

          end;
      end;

    RttiProperty := TRttiContext.Context.GetType(Self.ClassType).GetProperty(AName);

    if (RttiProperty = nil) or (RttiProperty.Visibility in [mvPrivate, mvProtected]) then
      raise EUnknownProperty.CreateFmt(SUnknownProperty, [AName]);

    Result := RttiProperty.GetValue(Self);
  finally
    TMonitor.Exit(Self);
  end;
end;

procedure TObjectHelper.RttiWriteProperty;
var
  RttiProperty: TRttiProperty;
begin
  TMonitor.Enter(Self);

  try
    if Self is TExpandableObject then
      with Self as TExpandableObject do
      begin
        if RttiIsExpandedWriteable(AName) then
          try
            RttiWriteExpandedProperty(AName, AValue);
            Exit;
          except

          end;
      end;

    RttiProperty := TRttiContext.Context.GetType(Self.ClassType).GetProperty(AName);

    if (RttiProperty = nil) or (RttiProperty.Visibility in [mvPrivate, mvProtected]) then
      raise EUnknownProperty.CreateFmt(SUnknownProperty, [AName]);

    if not RttiProperty.IsWritable then
      raise EReadOnlyProperty.CreateFmt(SReadOnlyProperty, [AName]);

    RttiProperty.SetValue(Self, AValue);
  finally
    TMonitor.Exit(Self);
  end;
end;

function TObjectHelper.RttiInvokeMethod;
var
  RttiMethod: TRttiMethod;
begin
  TMonitor.Enter(Self);

  try
    if Self is TExpandableObject then
      with Self as TExpandableObject do
      begin
        if RttiIsExpandedReadable(AName) then
          try
            Result := RttiInvokeExpandedMethod(AName, AArgs);
            Exit;
          except

          end;
      end;

    RttiMethod := TRttiContext.Context.GetType(Self.ClassType).GetMethod(AName);

    if (RttiMethod = nil) or (RttiMethod.Visibility in [mvPrivate, mvProtected]) then
      raise EUnknownMethod.CreateFmt(SUnknownMethod, [AName]);

    Result := RttiMethod.Invoke(Self, AArgs);
  finally
    TMonitor.Exit(Self);
  end;
end;

function TObjectHelper.RttiIsReadable;
var
  RttiProperty: TRttiProperty;
  RttiMethod:   TRttiMethod;
begin
  if Self is TExpandableObject then
  begin
    Result := TExpandableObject(Self).RttiIsExpandedReadable(AName);

    if Result then
      Exit;
  end;

  RttiProperty := TRttiContext.Context.GetType(Self.ClassType).GetProperty(AName);

  if RttiProperty <> nil then
    Result := (RttiProperty.Visibility in [mvPublic, mvPublished]) and RttiProperty.IsReadable
  else
  begin
    RttiMethod := TRttiContext.Context.GetType(Self.ClassType).GetMethod(AName);
    Result := (RttiMethod <> nil) and (RttiMethod.Visibility in [mvPublic, mvPublished]);
  end;
end;

function TObjectHelper.RttiIsWriteable;
var
  RttiProperty: TRttiProperty;
begin
  if Self is TExpandableObject then
  begin
    Result := TExpandableObject(Self).RttiIsExpandedWriteable(AName);

    if Result then
      Exit;
  end;

  RttiProperty := TRttiContext.Context.GetType(Self.ClassType).GetProperty(AName);

  Result := (RttiProperty <> nil) and (RttiProperty.Visibility in [mvPublic, mvPublished]) and RttiProperty.IsWritable;
end;
{$ENDREGION}

{$REGION 'TExpandableObject'}
function TExpandableObject.RttiReadExpandedProperty;
begin
  raise EUnknownProperty.CreateFmt(SUnknownProperty, [AName]);
end;

procedure TExpandableObject.RttiWriteExpandedProperty;
begin
  raise EUnknownProperty.CreateFmt(SUnknownProperty, [AName]);
end;

function TExpandableObject.RttiInvokeExpandedMethod;
begin
  raise EUnknownMethod.CreateFmt(SUnknownMethod, [AName]);
end;

function TExpandableObject.RttiIsExpandedReadable;
begin
  Result := False;
end;

function TExpandableObject.RttiIsExpandedWriteable;
begin
  Result := False;
end;
{$ENDREGION}

end.

