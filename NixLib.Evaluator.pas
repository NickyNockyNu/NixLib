{
  NixLib.Rtti.pas

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

unit NixLib.Evaluator;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,

  NixLib.Rtti,
  NixLib.Strings;

type
  EEvaluator = class(Exception);

{$REGION 'TVariables'}
  TNamedValues = TDictionary<String, TValue>;

  TVariables = class(TExpandableObject)
  private
    FNamedValues: TNamedValues;
  public
    constructor Create;
    destructor  Destroy; override;

    function  RttiReadExpandedProperty (const AName: String): TValue;         override;
    procedure RttiWriteExpandedProperty(const AName: String; AValue: TValue); override;

    function RttiIsExpandedReadable (const AName: String): Boolean; override;
    function RttiIsExpandedWriteable(const AName: String): Boolean; override;

    procedure Declare(AName: String; const AValue: TValue);
    procedure Delete (AName: String);
  end;
{$ENDREGION}

{$REGION 'TMethods'}
  TMethod = class
  public
    function Invoke(AArgs: array of TValue): TValue; virtual; abstract;
  end;

  TNamedMethods = TDictionary<String, TMethod>;

  TMethods = class(TExpandableObject)
  private
    FNamedMethods: TNamedMethods;
  public
    constructor Create;
    destructor  Destroy; override;

    function RttiInvokeExpandedMethod(const AName: String; AArgs: array of TValue): TValue; override;

    function RttiIsExpandedMethod(const AName: String): Boolean; override;
  end;
{$ENDREGION}

{$REGION 'TNamespace'}
  TNamespace = class(TExpandableObject)
  private
    FNamespace: TArray<TObject>;

    FVariables: TVariables;
    FMethods:   TMethods;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Push(ANamespace: TObject);
    procedure Pop;

    function  RttiReadExpandedProperty (const AName: String): TValue;         override;
    procedure RttiWriteExpandedProperty(const AName: String; AValue: TValue); override;

    function RttiInvokeExpandedMethod(const AName: String; AArgs: array of TValue): TValue; override;

    function RttiIsExpandedReadable (const AName: String): Boolean; override;
    function RttiIsExpandedWriteable(const AName: String): Boolean; override;

    function RttiIsExpandedMethod(const AName: String): Boolean; override;

    function ReadValue (const AName: String; var   AValue: TValue): Boolean;
    function WriteValue(const AName: String; const AValue: TValue): Boolean;

    function Evaluate(const AExpression: String): TValue;

    function Eval(const AExpression: String): Variant;

    property Variables: TVariables read FVariables;
    property Methods:   TMethods   read FMethods;
  end;
{$ENDREGION}

implementation

{$REGION 'TVariables'}
constructor TVariables.Create;
begin
  inherited;

  FNamedValues := TNamedValues.Create;
end;

destructor TVariables.Destroy;
begin
  FNamedValues.Free;

  inherited;
end;

function TVariables.RttiReadExpandedProperty;
begin
  var Name := AName.LowerCase;

  if not FNamedValues.ContainsKey(Name) then
    Result := inherited
  else
    Result := FNamedValues[Name];
end;

procedure TVariables.RttiWriteExpandedProperty;
begin
  var Name := AName.LowerCase;

  if not FNamedValues.ContainsKey(Name) then
    inherited
  else
    FNamedValues[Name] := AValue;
end;

function TVariables.RttiIsExpandedReadable;
begin
  if FNamedValues.ContainsKey(AName.LowerCase) then
    Result := True
  else
    Result := inherited;
end;

function TVariables.RttiIsExpandedWriteable;
begin
  if FNamedValues.ContainsKey(AName.LowerCase) then
    Result := True
  else
    Result := inherited;
end;

procedure TVariables.Declare;
begin
  var Name := AName.LowerCase;

  if not FNamedValues.ContainsKey(Name) then
    FNamedValues.Add(Name, AValue);
end;

procedure TVariables.Delete;
begin
  FNamedValues.Remove(AName.LowerCase);
end;
{$ENDREGION}

{$REGION 'TMethods'}
constructor TMethods.Create;
begin
  inherited;

  FNamedMethods := TNamedMethods.Create;
end;

destructor TMethods.Destroy;
begin
  FNamedMethods.Free;

  inherited;
end;

function TMethods.RttiInvokeExpandedMethod;
begin
  var Name := AName.LowerCase;

  if FNamedMethods.ContainsKey(Name) then
    Result := FNamedMethods[Name].Invoke(AArgs)
  else
    Result := inherited;
end;

function TMethods.RttiIsExpandedMethod;
begin
  if FNamedMethods.ContainsKey(AName.LowerCase) then
    Result := True
  else
    Result := inherited;
end;
{$ENDREGION}

{$REGION 'TNamespace'}
constructor TNamespace.Create;
begin
  inherited;

  FVariables := TVariables.Create;
  FMethods   := TMethods.Create;
end;

destructor TNamespace.Destroy;
begin
  FMethods.Free;
  FVariables.Free;

  inherited;
end;

procedure TNamespace.Push;
begin
  SetLength(FNamespace, Length(FNamespace) + 1);
  FNamespace[High(FNamespace)] := ANamespace;
end;

procedure TNamespace.Pop;
begin
  if Length(FNamespace) <= 0 then
    Exit;

  SetLength(FNamespace, Length(FNamespace) - 1);
end;

function TNamespace.RttiReadExpandedProperty;
begin
  for var i := High(FNamespace) downto 0 do
  begin
    var Found := FNamespace[i].RttiIsReadable(AName);

    if Found then
      Exit(FNamespace[i].RttiReadProperty(AName));
  end;

  Result := inherited;
end;

procedure TNamespace.RttiWriteExpandedProperty;
begin
  for var i := High(FNamespace) downto 0 do
  begin
    var Found := FNamespace[i].RttiIsWriteable(AName);

    if Found then
    begin
      FNamespace[i].RttiWriteProperty(AName, AValue);
      Exit;
    end;
  end;

  inherited;
end;

function TNamespace.RttiInvokeExpandedMethod;
begin
  for var i := High(FNamespace) downto 0 do
  begin
    var Found := FNamespace[i].RttiIsMethod(AName);

    if Found then
      Exit(FNamespace[i].RttiInvokeMethod(AName, AArgs));
  end;

  Result := inherited;
end;

function TNamespace.RttiIsExpandedReadable;
begin
  for var i := High(FNamespace) downto 0 do
  begin
    Result := FNamespace[i].RttiIsReadable(AName);
    if Result then
      Exit;
  end;

  Result := inherited;
end;

function TNamespace.RttiIsExpandedWriteable;
begin
  for var i := High(FNamespace) downto 0 do
  begin
    Result := FNamespace[i].RttiIsWriteable(AName);
    if Result then
      Exit;
  end;

  Result := inherited;
end;

function TNamespace.RttiIsExpandedMethod;
begin
  for var i := High(FNamespace) downto 0 do
  begin
    Result := FNamespace[i].RttiIsMethod(AName);
    if Result then
      Exit;
  end;

  Result := inherited;
end;

function TNamespace.ReadValue;
  function ReadValueNS(Namespace: TObject): TValue;
  var
    i: Integer;
    p: TArray<TValue>;
    s: String;
    c: Char;
    f: Boolean;

    procedure Whitespace;
    begin
      repeat
        if not CharInSet(AName[i], [#32, #9]) then
          Exit;

        Inc(i);
      until i > AName.Length;
    end;

    procedure OverName;
    begin
      Whitespace;

      s := '';

      repeat
        c := AName[i];

        if not CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
          Exit;

        s := s + c;

        Inc(i);
      until i > AName.Length;
    end;

    procedure OverParams;
    var
      q:  Boolean;
      n:  Integer;
      v:  String;
      l:  TValue;
    begin
      q := False;
      n := 0;
      v := '';

      SetLength(p, 0);

      Inc(i);

      repeat
        if not q then
          Whitespace;

        c := AName[i];

        case c of
          '"': q := not q;

          '(': if not q then Inc(n);
          ')': if not q then Dec(n);

          ',': if (not q) and (n = 0) then
               begin
                 l := Evaluate(v);

                 SetLength(p, Length(p) + 1);
                 p[High(p)] := l;

                 Inc(i);
                 v := '';
              end;
        end;

        if i > AName.Length then
          Break;

        v := v + AName[i];

        Inc(i);
      until (n = -1) or (i > AName.Length);

      if (n = -1) and (v[Length(v)] = ')') then v := v.Copy(1, v.Length - 1);

      if v.IsNotEmpty then
      begin
        l := Evaluate(v);

        SetLength(p, Length(p) + 1);
        p[High(p)] := l;
      end;
    end;
  begin
    Result := TValue.From<TObject>(Namespace);

    i := 1;

    repeat
      OverName;

      f := c = '(';

      if f then
      begin
        OverParams;
        c := AName[i];
      end;

      if f and Result.AsObject.RttiIsMethod(s) then
        Result := Result.AsObject.RttiInvokeMethod(s, p)
      else if Result.AsObject.RttiIsReadable(s) then
        Result := Result.AsObject.RttiReadProperty(s)
      else
        raise EEvaluator.Create('Cannot read value "' + s + '"');

      Inc(i);
    until (c <> '.') or (i > Length(AName));
  end;
begin
  //for var i := High(FNamespace) downto 0 do
    try
      AValue := ReadValueNS(Self);//FNameSpace[i]);
      Exit(True);
    except
    end;

  Result := False;
end;

function TNamespace.WriteValue;
  procedure WriteValueNS(Namespace: TObject);
  var
    i: Integer;
    v: TValue;
  begin
    for i := AName.Length downto 1 do
      if not CharInSet(AName[i], ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
        Break;

    var s := AName.Copy(i + 1);
    var p := AName.Copy(1, i - 1);

    if s.IsEmpty then
      raise EEvaluator.Create('Syntax error');

    if p.IsEmpty then
      v := TValue.From<TObject>(Namespace)
    else if not ReadValue(p, v) then
      raise EEvaluator.Create(p);

    if not v.AsObject.RttiIsWriteable(s) then
      raise EEvaluator.Create(p);

    v.AsObject.RttiWriteProperty(s, AValue);
  end;
begin
  //for var i := High(FNamespace) downto 0 do
    try
      WriteValueNS(Self);//FNamespace[i]);
      Exit(True);
    except
    end;

  Result := False;
end;

function TNamespace.Evaluate;
var
  s, v: String;
  i:    Integer;

  function Compare: TValue; forward;

  procedure Whitespace;
  begin
    repeat
      if not CharInSet(s[i], [#32, #9]) then
        Exit;

      Inc(i);
    until i > Length(s);
  end;

  function CheckSymbol(Symbol: String; Follow: String = ''; State: Boolean = True): Boolean;
  begin
    Whitespace;

    Result := s.Copy(i, Symbol.Length) = Symbol;

    if Result and (Follow.Length > 0) then
      Result := (Pos(s[i + Symbol.Length], Follow) = 0) = State;

    if Result then
      Inc(i, Symbol.Length);
  end;

  function GetConst(var Value: TValue): Boolean;
  var
    c: String;
  begin
    Whitespace;

    Result := True;

    case s[i] of
      '0'..'9':
      begin
        c := s[i];

        Inc(i);

        while CharInSet(s[i], ['0'..'9', '.']) and (i <= s.Length) do
        begin
          c := c + s[i];
          Inc(i);
        end;

        if Pos('.', c) = 0 then
          Value := TValue.From<Integer>(c.AsInteger)
        else
          Value := TValue.From<Single>(c.AsFloat);
      end;

      '$':
      begin
        c := '';//s[i];

        Inc(i);

        while CharInSet(s[i], ['0'..'9', 'a'..'f', 'A'..'F']) and (i <= s.Length) do
        begin
          c := c + s[i];
          Inc(i);
        end;

        Value := TValue.From<Cardinal>(String.Hex(c));
      end;

      '#':
      begin
        c := '';//s[i];

        Inc(i);

        while CharInSet(s[i], ['0', '1']) and (i <= s.Length) do
        begin
          c := c + s[i];
          Inc(i);
        end;

        Value := TValue.From<Cardinal>(String.Bin(c));
      end;

      '"':
      begin
        Inc(i);

        c := '';

        while s[i] <> '"' do
        begin
          if s[i] = '`' then
            c := c + '"'
          else
            c := c + s[i];

          Inc(i);

          if i > s.Length then
            raise EEvaluator.Create('Expected "');
        end;

        Inc(i);

        Value := TValue.From<String>(c);
      end;
    else
      Result := False;
    end;

    if Result then
      v := '';
  end;

  function GetValue(var Value: TValue): Boolean;
  var
    c: Char;

    procedure OverName;
    begin
      Whitespace;

      repeat
        c := s[i];

        if not CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
          Exit;

        v := v + c;

        Inc(i);
      until i > s.Length;
    end;

    procedure OverParams;
    var
      q: Boolean;
      n: Integer;
    begin
      Whitespace;

      q := False;
      n := 0;

      repeat
        c := s[i];

        case c of
          '"': q := not q;

          '(': if not q then Inc(n);
          ')': if not q then
               begin
                 Dec(n);

                 if n = 0 then
                 begin
                   v := v + c; Inc(i);
                   Break;
                 end;
               end;
        end;

        v := v + c;

        Inc(i);
      until i > s.Length;
    end;
  begin
    Whitespace;

    Result := False;

    if not CharInSet(s[i], ['A'..'Z', 'a'..'z', '_']) then
      Exit;

    v := '';

    repeat
      OverName;

      if i > s.Length then
        Break;

      if c = '.' then
      begin
        v := v + c;
        Inc(i);

        Continue;
      end
      else
      begin
        Whitespace;

        if c = '(' then
        begin
          Whitespace;

          OverParams;

          if c = '.' then
          begin
            v := v + c;
            Inc(i);

            Continue;
          end;
        end

        else Break;
      end;
    until i > s.Length;

    Result := ReadValue(v, Value);
  end;

  function IsNot: Boolean;
  begin
    Whitespace;

    Result := s[i] = '!';

    if Result then
      Inc(i);
  end;

  function IsNeg: Boolean;
  begin
    Whitespace;

    Result := s[i] = '-';

    if Result then
      Inc(i);
  end;

  function Bracket: TValue;
  var
    nt: Boolean;
    ng: Boolean;
  begin
    Whitespace;

    nt := IsNot;
    ng := IsNeg;

    v := '';

    if CheckSymbol('(') then
    begin
      Result := Compare;

      if not CheckSymbol(')') then
        raise EEvaluator.Create('Expected )');
    end
    else
    begin
      if not GetConst(Result) then
        if not GetValue(Result) then
          raise EEvaluator.Create('Expected value');
    end;

    if ng then
      Result := TValue.FromVariant(-Result.AsVariant);

    if nt then
      Result := TValue.From<Boolean>(not Result.AsBoolean);
  end;

  function Assign: TValue;
  var
    n: String;

    procedure Check;
    begin
      if v.IsEmpty then
        raise EEvaluator.Create('Expected variable');

      n := v;
    end;

    procedure GetValue;
    begin
      if not ReadValue(n, Result) then
        raise EEvaluator.Create('Expected variable');
    end;

    procedure SetValue;
    begin
      if not WriteValue(n, Result) then
        raise EEvaluator.Create('Expected variable');
    end;
  begin
    Whitespace;

    Result := Bracket;

    if CheckSymbol('=', '=') then
    begin
      Check;

      Result := Compare;
      SetValue;
    end
    else if CheckSymbol('*=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant * Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('/=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant / Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('\=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant div Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('%=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant mod Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('&=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant and Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('|=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant or Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('^=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant xor Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('+=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant + Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('-=') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant - Compare.AsVariant);
      SetValue;
    end
    else if CheckSymbol('++') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant + 1);
      SetValue;

      s := n + s.Copy(i);
      i := 1;
      Result := Compare;
    end
    else if CheckSymbol('--') then
    begin
      Check;

      GetValue;
      Result := TValue.FromVariant(Result.AsVariant - 1);
      SetValue;

      s := n + s.Copy(i);
      i := 1;
      Result := Compare;
    end
  end;

  function MulDiv: TValue;
  begin
    Whitespace;

    Result := Assign;

    while True do
           if CheckSymbol('*', '=') then Result := TValue.FromVariant(Result.AsVariant *   Assign.AsVariant)
      else if CheckSymbol('/', '=') then Result := TValue.FromVariant(Result.AsVariant /   Assign.AsVariant)
      else if CheckSymbol('\', '=') then Result := TValue.FromVariant(Result.AsVariant div Assign.AsVariant)
      else if CheckSymbol('%', '=') then Result := TValue.FromVariant(Result.AsVariant mod Assign.AsVariant)
      else if CheckSymbol('^')      then Result := TValue.FromVariant(Power(Result.AsVariant, Assign.AsVariant))
      else Break;
  end;

  function Bitwise: TValue;
  begin
    Whitespace;

    Result := MulDiv;

    while True do
           if CheckSymbol('<<')      then Result := TValue.From<Cardinal>(Result.AsOrdinal shl MulDiv.AsOrdinal)
      else if CheckSymbol('>>')      then Result := TValue.From<Cardinal>(Result.AsOrdinal shr MulDiv.AsOrdinal)
      else if CheckSymbol('&', '&=') then Result := TValue.From<Cardinal>(Result.AsOrdinal and MulDiv.AsOrdinal)
      else if CheckSymbol('|', '|=') then Result := TValue.From<Cardinal>(Result.AsOrdinal or  MulDiv.AsOrdinal)
      else if CheckSymbol('^', '=')  then Result := TValue.From<Cardinal>(Result.AsOrdinal xor MulDiv.AsOrdinal)
      else Break;
  end;

  function AddSub: TValue;
  begin
    Whitespace;

    Result := Bitwise;

    while True do
           if CheckSymbol('+', '+=') then Result := TValue.FromVariant(Result.AsVariant + Bitwise.AsVariant)
      else if CheckSymbol('-', '-=') then Result := TValue.FromVariant(Result.AsVariant - Bitwise.AsVariant)
      else Break;
  end;

  function Compare: TValue;
  begin
    Whitespace;

    Result := AddSub;

    while True do
           if CheckSymbol('==')      then Result := TValue.From<Boolean>(Result.AsVariant =  AddSub.AsVariant)
      else if CheckSymbol('>=')      then Result := TValue.From<Boolean>(Result.AsVariant >= AddSub.AsVariant)
      else if CheckSymbol('<=')      then Result := TValue.From<Boolean>(Result.AsVariant <= AddSub.AsVariant)
      else if CheckSymbol('<>')      then Result := TValue.From<Boolean>(Result.AsVariant <> AddSub.AsVariant)
      else if CheckSymbol('>', '>=') then Result := TValue.From<Boolean>(Result.AsVariant >  AddSub.AsVariant)
      else if CheckSymbol('<', '<=') then Result := TValue.From<Boolean>(Result.AsVariant <  AddSub.AsVariant)
      else if CheckSymbol('!=')      then Result := TValue.From<Boolean>(Result.AsVariant <> AddSub.AsVariant)
      else if CheckSymbol('&&')      then Result := TValue.From<Boolean>((Result.AsBoolean) and (AddSub.AsBoolean))
      else if CheckSymbol('||')      then Result := TValue.From<Boolean>((Result.AsBoolean) or  (AddSub.AsBoolean))
      else Break;

  end;
begin
  s := AExpression.Trim;
  if s.IsEmpty then
    Exit(TValue.Empty);

  i := 1;

  Result := Compare;
end;

function TNamespace.Eval(const AExpression: String): Variant;
begin
  Result := Evaluate(AExpression).AsVariant;
end;
{$ENDREGION}

end.

