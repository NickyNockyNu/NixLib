{
  NixLib.Config.pas

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

unit NixLib.Config;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  NixLib.Strings,
  NixLib.Log;

const
  DefaultValue = '';

type
{$REGION 'TIniLine'}
  PIniLine = ^TIniLine;
  TIniLine = record
  private
    function  GetAsText: String;
    procedure SetAsText(AText: String);
  public
    Key:     String;
    Value:   String;
    Comment: String;

    class function Create(AStr: String): PIniLine; static;
    procedure Free;

    property AsText: String read GetAsText write SetAsText;
  end;
{$ENDREGION}

{$REGION 'TIniSection'}
  TIniSection = class
  private
    FName:    String;
    FComment: String;

    FLines: TList<PIniLine>;

    function GetLineCount: Integer;              inline;
    function GetLine(AIndex: Integer): PIniLine; inline;

    function  GetAsText: String;        virtual;
    procedure SetAsText(aText: String); virtual;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;

    procedure AddLine(AStr: String); inline;

    function FindKey(AKey: String): Integer;

    function  GetValue(AKey: String; ADefault: String = ''): String;
    procedure SetValue(AKey, AValue: String; const ACanCreate: Boolean = True);

    procedure DeleteKey(AKey: String);

    property Name:    String read FName    write FName;
    property Comment: String read FComment write FComment;

    property LineCount:              Integer  read GetLineCount;
    property Lines[AIndex: Integer]: PIniLine read GetLine;

    property AsText: String read GetAsText write SetAsText;
  end;
{$ENDREGION}

{$REGION 'TIniFile'}
  TIniHive = class;

  TIniFile = class(TIniSection)
  private
    FFileName: String;
    FEncoding: TEncoding;
    FModified: Boolean;

    FHive: TIniHive;

    FSections: TList<TIniSection>;

    function GetSectionCount: Integer;                        inline;
    function GetSectionIndexed(AIndex: Integer): TIniSection; inline;

    function  GetAsText: String;        override;
    procedure SetAsText(AText: String); override;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;

    function GetSection(AName: String; ACanCreate: Boolean = False): TIniSection;

    function  GetValue(ASection, AKey: String; ADefault: String = ''): String;
    procedure SetValue(ASection, AKey, AValue: String; const ACanCreate: Boolean = True);

    procedure DeleteValue(ASection, AKey: String);

    function GetInt  (ASection, AKey: String; ADefault: Int64    = 0):     Int64;    inline;
    function GetFloat(ASection, AKey: String; ADefault: Extended = 0):     Extended; inline;
    function GetBool (ASection, AKey: String; ADefault: Boolean  = False): Boolean;  inline;

    procedure SetInt  (ASection, AKey: String; AValue: Int64);    inline;
    procedure SetFloat(ASection, AKey: String; AValue: Extended); inline;
    procedure SetBool (ASection, AKey: String; AValue: Boolean);  inline;

    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream  (const AStream: TStream; const AWriteBOM: Boolean = True);

    procedure LoadFromFile(const AFileName: String);
    procedure SaveToFile  (const AFileName: String; const AWriteBOM: Boolean = True);

    property FileName: String    read FFileName write FFileName;
    property Encoding: TEncoding read FEncoding write FEncoding;
    property Modified: Boolean   read FModified write FModified;

    property SectionCount:              Integer     read GetSectionCount;
    property Sections[AIndex: Integer]: TIniSection read GetSectionIndexed;

    property Hive: TIniHive read FHive;
  end;
{$ENDREGION}

{$REGION 'TIniHive'}
  TIniHive = class
  private
    FFiles: TList<TIniFile>;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;
    procedure Save;

    procedure Process(const AKey, AValue: String); virtual;

    procedure Include(const AFileName: String); virtual;
    procedure Echo(const AStr: String; const AEventID: Integer = LogIDConfig);

    function  GetValue(ASection, AKey: String; ADefault: String = ''): String;
    procedure SetValue(ASection, AKey, AValue: String; const ACanCreate: Boolean = True);

    function GetInt  (ASection, AKey: String; ADefault: Int64    = 0):     Int64;    inline;
    function GetFloat(ASection, AKey: String; ADefault: Extended = 0):     Extended; inline;
    function GetBool (ASection, AKey: String; ADefault: Boolean  = False): Boolean;  inline;

    procedure SetInt  (ASection, AKey: String; AValue: Int64);    inline;
    procedure SetFloat(ASection, AKey: String; AValue: Extended); inline;
    procedure SetBool (ASection, AKey: String; AValue: Boolean);  inline;
  end;
{$ENDREGION}

{$REGION 'TValues'}
  TValues = class(TDictionary<String, String>)
  private
    FName: String;

    function  GetAsText: String;
    procedure SetAsText(AText: String);
  public
    procedure AddValues(const ASettings: String);

    function Read     (const AKey: String; const ADefault: String   = DefaultValue): String;
    function ReadInt  (const AKey: String; const ADefault: Int64    = 0):     Int64;    inline;
    function ReadFloat(const AKey: String; const ADefault: Extended = 0):     Extended; inline;
    function ReadBool (const AKey: String; const ADefault: Boolean  = False): Boolean;  inline;

    procedure Write     (const AKey: String; const AValue: String);
    procedure WriteInt  (const AKey: String; const AValue: Int64);    inline;
    procedure WriteFloat(const AKey: String; const AValue: Extended); inline;
    procedure WriteBool (const AKey: String; const AValue: Boolean);  inline;

    function Expand(const AFormat: String): String;

    function Exists(const AKey: String): Boolean; inline;

    property Name: String read FName     write FName;
    property Text: String read GetAsText write SetAsText;
  end;
{$ENDREGION}

implementation

{$REGION 'TIniLine'}
function TIniLine.GetAsText;
begin
  Result := '';

  if String(Key).IsNotEmpty then
  begin
    Result := Result + String(Key).Trim;

    if String(Value).IsNotEmpty then
      Result := Result + ' = ' + String(Value).Trim;
  end;

  if String(Comment).IsNotEmpty then
    Result := Result.Append('# ' + String(Comment).Trim);
end;

procedure TIniLine.SetAsText;
var
  S: String;
begin
  S := AText;

  Value   := S.SplitFirst('#', True, True);
  Comment := S;

  if String(Value).IsEmpty then
    Key := ''
  else
  begin
    S     := Value;
    Key   := S.SplitFirst('=', True, True);
    Value := S;

    if String(Key).IsEmpty then
    begin
      Key   := Value;
      Value := '';
    end;
  end;
end;

class function TIniLine.Create;
begin
  New(Result);

  Result^.AsText := AStr;
end;

procedure TIniLine.Free;
begin
  Dispose(@Self);
end;
{$ENDREGION}

{$REGION 'TIniSection'}
function TIniSection.GetLineCount;
begin
  Result := FLines.Count;
end;

function TIniSection.GetLine;
begin
  Result := FLines[AIndex];
end;

function TIniSection.GetAsText;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;

  try
    for var Line in FLines do
      Lines.Add(Line.AsText);

    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TIniSection.SetAsText;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;

  try
    Clear;
    Lines.Text := AText;

    for var Line in Lines do
      AddLine(Line);
  finally
    Lines.Free;
  end;
end;

constructor TIniSection.Create;
begin
  inherited;

  FLines := TList<PIniLine>.Create;
end;

destructor TIniSection.Destroy;
begin
  Clear;
  FLines.Free;

  inherited;
end;

procedure TIniSection.Clear;
begin
  for var Line in FLines do
    Line.Free;

  FLines.Clear;
end;

procedure TIniSection.AddLine;
begin
  var Line := TIniLine.Create(AStr);

  FLines.Add(Line);

  if (Self is TIniFile) then
    with Self as TIniFile do
      if FHive <> nil then
        FHive.Process(Line.Key, Line.Value);
end;

function TIniSection.FindKey;
begin
  for var i := 0 to FLines.Count - 1 do
    if AKey.Same(FLines[i]^.Key) then
      Exit(i);

  Result := -1;
end;

procedure TIniSection.SetValue;
var
  i: Integer;
  l: PIniLine;
begin
  i := FindKey(AKey);

  if i = -1 then
  begin
    if ACanCreate then
    begin
      New(l);

      l^.Key     := AKey;
      l^.Comment := '';

      FLines.Add(l);
    end
    else
      Exit;
  end
  else
    l := FLines[i];

  l^.Value := AValue;
end;

procedure TIniSection.DeleteKey;
var
  i: Integer;
begin
  i := FindKey(AKey);

  if i = -1 then
    Exit;

  FLines[i]^.Free;
  FLines.Delete(i);
end;

function TIniSection.GetValue;
var
  i: Integer;
begin
  i := FindKey(AKey);

  if i = -1 then
    Result := ADefault
  else
    Result := FLines[i]^.Value;
end;
{$ENDREGION}

{$REGION 'TIniFile'}
function TIniFile.GetSectionCount;
begin
  Result := FSections.Count;
end;

function TIniFile.GetSectionIndexed;
begin
  Result := FSections[AIndex];
end;

function TIniFile.GetAsText: String;
var
  Lines: TStringList;

  procedure AddSection(Section: TIniSection);
  begin
    for var Line in Section.FLines do
      Lines.Add(Line.AsText);
  end;
begin
  Lines := TStringList.Create;

  try
    AddSection(Self);

    for var Section in FSections do
    begin
      Lines.Add('[' + Section.Name + ']');
      AddSection(Section);
    end;

    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TIniFile.SetAsText;
var
  Lines:   TStringList;
  Line:    String;
  Name:    String;
  Section: TIniSection;
begin
  Lines := TStringList.Create;

  try
    Clear;
    Lines.Text := AText;

    Section := Self;

    for var i := 0 to Lines.Count - 1 do
    begin
      Line := Lines[i].Trim;

      //if Line.IsEmpty then
      //  Continue;

      if Line.Starts('[') then
      begin
        Name := Line.SplitFirst(']');

        Section      := TIniSection.Create;
        Section.Name := Name;

        FSections.Add(Section);
      end
      else
        Section.AddLine(Line);
    end;
  finally
    Lines.Free;
  end;
end;

constructor TIniFile.Create;
begin
  inherited;

  FSections := TList<TIniSection>.Create;

  FModified := False;
  FFileName := '';

  FHive := nil;
end;

destructor TIniFile.Destroy;
begin
  Clear;
  FSections.Free;

  inherited;
end;

procedure TIniFile.Clear;
begin
  for var Section in FSections do
    Section.Free;

  FSections.Clear;
end;

function TIniFile.GetSection;
begin
  if AName.IsEmpty then
    Exit(Self);

  for var Section in FSections do
    if AName.Same(Section.Name) then
      Exit(Section);

  if ACanCreate then
  begin
    Result := TIniSection.Create;
    Result.Name := AName;

    FSections.Add(Result);
  end
  else
    Result := nil;
end;

function TIniFile.GetValue;
begin
  var Sec := GetSection(ASection, False);

  if Sec = nil then
    Exit(ADefault);

  Result := Sec.GetValue(AKey, ADefault);
end;

procedure TIniFile.SetValue;
begin
  var Sec := GetSection(ASection, ACanCreate);

  if Sec = nil then
    Exit;

  Sec.SetValue(AKey, AValue, ACanCreate);

  FModified := True;
end;

procedure TIniFile.DeleteValue;
begin
  var Sec := GetSection(ASection, False);

  if Sec = nil then
    Exit;

  Sec.DeleteKey(AKey);

  FModified := True;
end;

function TIniFile.GetInt;
begin
  Result := GetValue(ASection, AKey, String.Int(ADefault)).AsInteger(ADefault);
end;

function TIniFile.GetFloat;
begin
  Result := GetValue(ASection, AKey, String.Float(ADefault)).AsFloat(ADefault);
end;

function TIniFile.GetBool;
begin
  Result := GetValue(ASection, AKey, String.Bool(ADefault)).AsBoolean(ADefault);
end;

procedure TIniFile.SetInt;
begin
  SetValue(ASection, AKey, String.Int(AValue));
end;

procedure TIniFile.SetFloat;
begin
  SetValue(ASection, AKey, String.Float(AValue));
end;

procedure TIniFile.SetBool;
begin
  SetValue(ASection, AKey, String.Bool(AValue));
end;

procedure TIniFile.LoadFromStream;
var
  S: String;
begin
  FEncoding := nil;
  S.LoadFromStream(AStream, FEncoding);

  AsText := S.Trim;

  FModified := False;
end;

procedure TIniFile.SaveToStream;
var
  S: String;
begin
  S := AsText;

  S.SaveToStream(AStream, FEncoding, AWriteBOM);

  FModified := False;
end;

procedure TIniFile.LoadFromFile;
var
  Stream: TStream;
begin
  Log(AFileName, LogIDLoad);

  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);

  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;

  FFileName := AFileName;
end;

procedure TIniFile.SaveToFile;
var
  Stream: TStream;
begin
  Log(AFileName, LogIDSave);

  Stream := TFileStream.Create(AFileName, fmCreate);

  try
    SaveToStream(Stream, AWriteBOM);
  finally
    Stream.Free;
  end;

  FFileName := AFileName;
end;
{$ENDREGION}

{$REGION 'TIniHive'}
constructor TIniHive.Create;
begin
  inherited;

  FFiles := TList<TIniFile>.Create;
end;

destructor TInihive.Destroy;
begin
  Clear;
  FFiles.Free;

  inherited;
end;

procedure TIniHive.Clear;
begin
  for var IniFile in FFiles do
    IniFile.Free;

  FFiles.Clear;
end;

procedure TIniHive.Save;
begin
  for var IniFile in FFiles do
    if IniFile.Modified then
      IniFile.SaveToFile(IniFile.FileName);
end;

procedure TIniHive.Process;
begin
  if AKey.Same('include') then
    Include(AValue)
  else if AKey.Same('echo') then
    Echo(AValue)
  else if AKey.Same('hint') then
    Echo(AValue, LogIDHint)
  else if AKey.Same('warn') then
    Echo(AValue, LogIDWarning)
  else if AKey.Same('error') then
    Echo(AValue, LogIDError)
  else if AKey.Same('fatal') then
    Echo(AValue, LogIDFatal);
end;

procedure TIniHive.Include;
begin
  for var IniFile in FFiles do
    if IniFile.FileName.Same(AFileName) then Exit;

  var IniFile := TIniFile.Create;

  IniFile.fHive := Self;
  FFiles.Add(IniFile);

  IniFile.LoadFromFile(AFileName);
end;

procedure TIniHive.Echo;
begin
  Log(AStr, LogIDConfig);
end;

function TIniHive.GetValue;
var
  i: Integer;
  s: TIniSection;
begin
  if FFiles.Count = 0 then
    Exit(ADefault);

  for var IniFile in FFiles do
  begin
    if ASection.IsEmpty then
      s := IniFile
    else
    begin
      s := IniFile.GetSection(ASection, False);

      if s = nil then
        Continue;
    end;

    i := s.FindKey(AKey);

    if i > -1 then
      Exit(s.Lines[i].Value);
  end;

  Result := ADefault;
end;

procedure TIniHive.SetValue;
var
  i: Integer;
  s: TIniSection;
begin
  if FFiles.Count = 0 then
    Exit;

  for var IniFile in FFiles do
  begin
    if ASection.IsEmpty then
      s := IniFile
    else
    begin
      s := IniFile.GetSection(ASection, False);

      if s = nil then
        Continue;
    end;

    i := s.FindKey(AKey);

    if i > -1 then
    begin
      s.Lines[i].Value := AValue;
      IniFile.Modified := True;

      Exit;
    end;
  end;

  if ACanCreate then
    fFiles[0].SetValue(ASection, AKey, AValue, True);
end;

function TIniHive.GetInt;
begin
  Result := GetValue(ASection, AKey, String.Int(ADefault)).AsInteger(ADefault);
end;

function TIniHive.GetFloat;
begin
  Result := GetValue(ASection, AKey, String.Float(ADefault)).AsFloat(ADefault);
end;

function TIniHive.GetBool;
begin
  Result := GetValue(ASection, AKey, String.Bool(ADefault)).AsBoolean(ADefault);
end;

procedure TIniHive.SetInt;
begin
  SetValue(ASection, AKey, String.Int(AValue));
end;

procedure TIniHive.SetFloat;
begin
  SetValue(ASection, AKey, String.Float(AValue));
end;

procedure TIniHive.SetBool;
begin
  SetValue(ASection, AKey, String.Bool(AValue));
end;
{$ENDREGION}

{$REGION 'TValues'}
function TValues.GetAsText;
begin
  Result := '';

  for var Pair: TPair<String, String> in Self do
    //if Pair.Value = DefaultValue then
    //  Result := Result.AppendSeparated(Pair.Key.LowerCase)
    //else
      Result := Result.Append(Pair.Key.LowerCase + '="' + Pair.Value.Markup + '"');
end;

procedure TValues.SetAsText;
begin
  Clear;
  AddValues(AText);
end;

procedure TValues.AddValues;
var
  m, n, v: String;
begin
  m := ASettings.Trim;

  if m.IsEmpty then
    Exit;

  repeat
    n := m.SplitToken.LowerCase;

    if n.IsEmpty then
      Exit;

    if not String.CharsIdentStart.Contains(n.Chars[1]) then
      Exit;

    if m.SplitToken(False) = '=' then
    begin
      m.SplitToken;

      v := m.SplitToken.Unquote;

      if v.IsEmpty then
        v := DefaultValue;
    end

    else
      v := DefaultValue;

    AddOrSetValue(n, v.UnMarkup);
  until m.IsEmpty;
end;

function TValues.Read;
begin
  if not TryGetValue(AKey.LowerCase, Result) then
    Result := ADefault;
end;

function TValues.ReadInt;
begin
  Result := Read(AKey, String.Int(ADefault)).AsInteger(ADefault);
end;

function TValues.ReadFloat;
begin
  Result := Read(AKey, String.Float(ADefault)).AsFloat(ADefault);
end;

function TValues.ReadBool;
begin
  Result := Read(AKey, String.Bool(ADefault)).AsBoolean(ADefault);
end;

procedure TValues.Write;
begin
  AddOrSetValue(AKey.LowerCase, AValue);
end;

procedure TValues.WriteInt;
begin
  Write(AKey, String.Int(AValue));
end;

procedure TValues.WriteFloat;
begin
  Write(AKey, String.Float(AValue));
end;

procedure TValues.WriteBool;
begin
  Write(AKey, String.Bool(AValue));
end;

function TValues.Expand;
begin
  Result := AFormat;

  for var Pair: TPair<String, String> in Self do
    Result := Result.Replace('%' + Pair.Key + '%', Pair.Value, 1, True);
end;

function TValues.Exists;
begin
  Result := ContainsKey(AKey);
end;
{$ENDREGION}

end.

