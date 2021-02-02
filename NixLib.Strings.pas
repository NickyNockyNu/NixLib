{
  NixLib.Strings.pas

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

unit NixLib.Strings;

interface

uses
  System.SysUtils,
  System.Classes,
  System.RTTI;

type
  TStringHelper = record helper for String
  private
    {$REGION 'Property helpers'}
    const PlatformIndexOffset = {$IFDEF MSWINDOWS}0{$ELSE}-1{$ENDIF};

    function  GetChars(AIndex: Integer): Char;
    procedure SetChars(AIndex: Integer; AChar: Char);

    function  GetLength: Integer;          inline;
    procedure SetLength(ALength: Integer); inline;

    function  GetSize: Integer;        inline;
    procedure SetSize(ASize: Integer); inline;

    function GetPtr(AIndex: Integer): PChar; inline;
    {$ENDREGION}
  public
    {$REGION 'Predefined'}
    const CharsAlphaUpper   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const CharsAlphaLower   = 'abcdefghijklmnopqrstuvwxyz';
    const CharsAlpha        = CharsAlphaUpper + CharsAlphaLower;
    const CharsNumeric      = '0123456789';
    const CharsAlphaNumeric = CharsAlpha + CharsNumeric;

    const CharsQuote = '`"''';

    const CharCR    = #13;
    const CharLF    = #10;
    const CharsCRLF = CharCR + CharLF;

    const CharSpace = #32;
    const CharTab   = #9;

    const CharsWhiteSpace = CharSpace + CharTab + CharsCRLF;

    const CharsBase = CharsNumeric + CharsAlphaUpper; // + CharsAlphaLower;

    const CharsIdentStart = '_' + CharsAlpha;
    const CharsIdent      = CharsIdentStart + CharsNumeric;
    const CharsIdentObj   = CharsIdent + '.';
    {$ENDREGION}

    {$REGION 'Properties'}
    property Chars[AIndex: Integer]: Char read GetChars write SetChars;

    property Length: Integer read GetLength write SetLength;
    property Size:   Integer read GetSize   write SetSize;

    property Ptr[AIndex: Integer]: PChar read GetPtr;
    {$ENDREGION}

    {$REGION 'Empty'}
    const Empty = '';

    function IsEmpty:    Boolean; inline;
    function IsNotEmpty: Boolean; inline;

    procedure Clear;
    procedure Burn;
    {$ENDREGION}

    {$REGION 'Compare'}
    function Compare    (const AStr: String; const AIgnoreCase: Boolean = False): Integer;
    function CompareLike(const AStr: String; const AIgnoreCase: Boolean = True): Extended;

    function Same    (const AStr: String): Boolean; inline;
    function SameCase(const AStr: String): Boolean; inline;

    function Match(const AMask: String; const AIgnoreCase: Boolean = False): Boolean;

    function Pos     (const AStr: String; const AStart: Integer = 1; const AIgnoreCase: Boolean = False; const AOutOfQuotes: Boolean = False): Integer;
    function Contains(const AStr: String; const AStart: Integer = 1; const AIgnoreCase: Boolean = False; const AOutOfQuotes: Boolean = False): Boolean; inline;

    function Starts(const AStr: String; const AIgnoreCase: Boolean = False; const ARemoveIfFound: Boolean = False): Boolean;
    function Ends  (const AStr: String; const AIgnoreCase: Boolean = False; const ARemoveIfFound: Boolean = False): Boolean;

    function IndexOf(const AStrs: array of String; const AIgnoreCase: Boolean = False): Integer;
    {$ENDREGION}

    {$REGION 'Split'}
    function SplitFirst(const ADelim: String = ' '; const ATrim: Boolean = True; const AOutOfQuotes: Boolean = False): String;
    function Split     (const ADelim: String = ' '; const ATrim: Boolean = True; const AOutOfQuotes: Boolean = False): TArray<String>;

    function SplitToken(const ARemove: Boolean = True): String;

    function Copy(const AIndex: Integer; const ACount: Integer = -1): String;

    function FirstChar: Char; inline;
    function LastChar:  Char; inline;

    function Start(const ACount: Integer): String; inline;
    {$ENDREGION}

    {$REGION 'Convert'}
    function UpperCase(const AEnable: Boolean = True): String;
    function LowerCase(const AEnable: Boolean = True): String;

    function UTF8: UTF8String; inline;

    function AsInteger(const ADefault: Int64    = 0):     Int64;    inline;
    function AsFloat  (const ADefault: Extended = 0):     Extended; inline;
    function AsBoolean(const ADefault: Boolean  = False): Boolean;  inline;
    function AsPointer(const ADefault: Pointer  = nil):   Pointer;  inline;

    function Markup  (const   CodeUnprintable: Boolean = False): String;
    function UnMarkup(const DecodeUnprintable: Boolean = False): String;
    {$ENDREGION}

    {$REGION 'Tidy'}
    function LTrim: String;
    function RTrim: String;
    function Trim(AEnable: Boolean = true): String; inline;

    function Tidy: String;

    function TidyNumeric(APlaces: Integer = 0): String;

    function Quote(const AQuote: Char = '"'): String;
    function Unquote: String;
    {$ENDREGION}

    {$REGION 'Modify'}
    function Insert(const AStr: String; const AIndex: Integer): String; inline;
    function Delete(const AIndex, ACount: Integer): String; inline;

    function Replace(const AFindStr, AReplaceStr: String; const AStart: Integer = 1; const AIgnoreCase: Boolean = False; const AOutOfQuotes: Boolean = False): String;

    function LAlign(const AMask: String): String;
    function RAlign(const AMask: String): String;
    function CAlign(const AMask: String): String;
    {$ENDREGION}

    {$REGION 'Build'}
    function Repeated(const ATimes: Integer): String;

    function Append(const AStr: String; const ASep: String = ' '): String;

    class function From(const A):    String; overload; static;
    class function From(R: TVarRec): String; overload; static;
    class function From(O: TObject): String; overload; static;
    class function From(V: TValue):  String; overload; static;

    class function Join(AValues: array of const; ADelim: String = ' '): String; static;

    class function Base(const AInt: Int64;  const ABase: Integer; AMinSize: Integer = 0): String; overload; static;
    class function Base(const AStr: String; const ABase: Integer; ADefault: Integer = 0): Int64;  overload; static;

    class function Int(const AInt: Int64; const AMinSize: Integer = 0): String; overload; inline; static;
    class function Dec(const AInt: Int64; const AMinSize: Integer = 0): String; overload; inline; static;
    class function Hex(const AInt: Int64; const AMinSize: Integer = 0): String; overload; inline; static;
    class function Oct(const AInt: Int64; const AMinSize: Integer = 0): String; overload; inline; static;
    class function Bin(const AInt: Int64; const AMinSize: Integer = 0): String; overload; inline; static;

    class function Int(const AStr: String; const ADefault: Int64 = 0): Int64; overload;         static;
    class function Dec(const AStr: String; const ADefault: Int64 = 0): Int64; overload; inline; static;
    class function Hex(const AStr: String; const ADefault: Int64 = 0): Int64; overload; inline; static;
    class function Oct(const AStr: String; const ADefault: Int64 = 0): Int64; overload; inline; static;
    class function Bin(const AStr: String; const ADefault: Int64 = 0): Int64; overload; inline; static;

    class function Float(const AFloat: Extended; const APrec: Integer = 2): String;   overload; inline; static;
    class function Float(const AStr: String; const ADefault: Extended = 0): Extended; overload; inline; static;

    class function Bool(const ABool: Boolean; const ATrue: String = 'True'; const AFalse: String = 'False'): String; overload; inline; static;
    class function Bool(const AStr: String; const ADefault: Boolean = False): Boolean;                               overload;         static;

    class function Pointer(const APtr: Pointer): String; overload; inline; static;
    class function Pointer(const AStr: String): Pointer; overload; inline; static;
    {$ENDREGION}

    {$REGION 'Load/Save'}
    class function LoadFromStream(const AStream: TStream; var AEncoding: TEncoding): String; overload; static;
    class function LoadFromStream(const AStream: TStream): String; overload; static;

    class function LoadFromFile(const AFileName: String; var AEncoding: TEncoding): String; overload; static;
    class function LoadFromFile(const AFileName: String): String; overload; static;

    procedure SaveToStream(const AStream:   TStream; AEncoding: TEncoding = nil; const AWriteBOM: Boolean = True);
    procedure SaveToFile  (const AFileName: String;  AEncoding: TEncoding = nil; const AWriteBOM: Boolean = True);
    {$ENDREGION}
  end;

implementation

uses
  NixLib.RTTI;

{$REGION 'Property helpers'}
function TStringHelper.GetChars;
begin
  Result := Self[AIndex + PlatformIndexOffset]
end;

procedure TStringHelper.SetChars;
begin
  Self[AIndex + PlatformIndexOffset] := AChar;
end;

function TStringHelper.GetLength;
begin
  Result := System.Length(Self);
end;

procedure TStringHelper.SetLength;
begin
  System.SetLength(Self, ALength);
end;

function TStringHelper.GetSize;
begin
  Result := Length * SizeOf(Char);
end;

procedure TStringHelper.SetSize;
begin
  Length := ASize div SizeOf(Char);
end;

function TStringHelper.GetPtr;
begin
  Result := @Self[AIndex + PlatformIndexOffset];
end;
{$ENDREGION}

{$REGION 'Empty'}
function TStringHelper.IsEmpty;
begin
  Result := Length = 0;
end;

function TStringHelper.IsNotEmpty;
begin
  Result := Length > 0;
end;

procedure TStringHelper.Clear;
begin
  FillChar(Ptr[1]^, Size, $00);

  Self := '';
end;

procedure TStringHelper.Burn;
begin
  FillChar(Ptr[1]^, Size, $FF);
  FillChar(Ptr[1]^, Size, $00);
  FillChar(Ptr[1]^, Size, $FF);
  FillChar(Ptr[1]^, Size, $00);

  Self := '';
end;
{$ENDREGION}

{$REGION 'Compare'}
function TStringHelper.Compare;
begin
  if AIgnoreCase then
    Result := System.SysUtils.CompareText(Self, AStr)
  else
    Result := System.SysUtils.CompareStr(Self, AStr);
end;

function TStringHelper.CompareLike;
var
  S1, S2:   String;
  MaxRange: Byte;

  procedure Prepare(var St1: String; const St2: String);
  var
    i: Byte;
  begin
    i := 1;

    while i <= St1.Length do
      if St2.Pos(St1.Chars[i]) = 0 then
        St1 := St1.Delete(i, 1)
      else
        Inc(i);
  end;

  procedure SubMatch(Elem, CurPos, Len: Integer);
  begin
    if (Len + S1.Length - Elem + 1 <= MaxRange) or (Len + S2.Length - CurPos + 1 <= MaxRange) then
      Exit;

    if (CurPos > S2.Length) or (Elem > S1.Length) then
    begin
      if Len > MaxRange then
        MaxRange := Len;

      Exit;
    end;

    if S1.Chars[Elem] = S2.Chars[CurPos] then
      SubMatch(Elem + 1, CurPos + 1, Len + 1)
    else
    begin
      SubMatch(Elem + 1, CurPos,     Len);
      SubMatch(Elem,     CurPos + 1, Len);
    end;
  end;
begin
  if IsEmpty or AStr.IsEmpty then
    Exit(-1);

  S1 := LowerCase(AIgnoreCase);
  S2 := AStr.LowerCase(AIgnoreCase);

  Prepare(S1, S2);
  Prepare(S2, S1);

  MaxRange := 0;
  SubMatch(1, 1, 0);

  if Length > AStr.Length then
    Result := MaxRange / Length
  else
    Result := MaxRange / AStr.Length;
end;

function TStringHelper.Same;
begin
  Result := Compare(AStr, True) = 0;
end;

function TStringHelper.SameCase;
begin
  Result := Compare(AStr, False) = 0;
end;

function TStringHelper.Match;
var
  MStr, CStr: String;

  function Comp(MaskI, StrI: Integer): Boolean;
  var
    m: Char;
  begin
    if MaskI > MStr.Length then
      Exit(StrI = CStr.Length + 1);

    if StrI > CStr.Length then
      Exit(False);

    m := MStr.Chars[MaskI];

    if m = '*' then
      Result := Comp(Succ(MaskI), Succ(StrI)) or Comp(MaskI, Succ(StrI))
    else if (m = '?') or (m = cStr.Chars[StrI]) then
      Result := Comp(Succ(MaskI), Succ(StrI))
    else
      Result := False;
  end;
begin
  if AMask.Copy(1, 1) = '!' then
    Result := Contains(AMask.Copy(2), 1, AIgnoreCase)
  else
  begin
    CStr := LowerCase(AIgnoreCase);
    MStr := AMask.LowerCase(AIgnoreCase);

    Result := Comp(1, 1);
  end;
end;

function TStringHelper.Pos;
var
  i: Integer;
begin

  if AOutOfQuotes then
  begin
    var q: Char := #0;

    for i := AStart to Length do
      if q <> #0 then
      begin
        if Self.Chars[i] = q then
          q := #0;
      end
      else if System.Pos(Self.Chars[i], CharsQuote) > 0 then
        q  := Self.Chars[i]
      else if Copy(i, AStr.Length).Compare(AStr, AIgnoreCase) = 0 then
        Exit(i);
  end
  else
    for i := AStart to Length do
      if Copy(i, AStr.Length).Compare(AStr, AIgnoreCase) = 0 then
        Exit(i);

  Result := 0;
end;

function TStringHelper.Contains;
begin
  Result := Pos(AStr, AStart, AIgnoreCase, AOutOfQuotes) > 0;
end;

function TStringHelper.Starts;
begin
  Result := Copy(1, AStr.Length).Compare(AStr, AIgnoreCase) = 0;

  if Result and ARemoveIfFound then
    Self := Copy(AStr.Length + 1);
end;

function TStringHelper.Ends;
begin
  Result := Copy(1 + Length - AStr.Length, AStr.Length).Compare(AStr, AIgnoreCase) = 0;

  if Result and ARemoveIfFound then
    Self := Copy(1, Length - AStr.Length);
end;

function TStringHelper.IndexOf;
begin
  for var i := Low(AStrs) to High(AStrs) do
    if Compare(AStrs[i], AIgnoreCase) = 0 then
      Exit((i - Low(AStrs)) + 1);

  Result := 0;
end;
{$ENDREGION}

{$REGION 'Split'}
function TStringHelper.SplitFirst;
var
  i: Integer;
begin
  Self := Self.Trim(ATrim);

  i := Pos(ADelim, 1, False, AOutOfQuotes);

  if i = 0 then
  begin
    Result := Self;
    Self   := '';
  end
  else
  begin
    Result := Copy(1, i - 1).Trim(ATrim);
    Self   := Copy(i + ADelim.Length).Trim(ATrim);
  end;
end;

function TStringHelper.Split;
var
  s: String;
  e: String;
begin
  s := Self.Trim(ATrim);

  while s.IsNotEmpty do
  begin
    e := s.SplitFirst(ADelim, ATrim, AOutofQuotes);

    if e.IsNotEmpty then
    begin
      System.SetLength(Result, System.Length(Result) + 1);

      Result[High(Result)] := e;
    end
    else
      Break;
  end;
end;

function TStringHelper.SplitToken;
const
  DblTokens: array[0..20] of String{$IFDEF MSWINDOWS}[2]{$ENDIF} = (
    '<>', '==', '!=', '<=', '>=', '<<', '>>', '&&', '||', '^^', '+=', '-=',
    '++', '--', '&=', '^=', '|=', ':=', '/*', '*/', '//'
  );
var
  i: Integer;
  c: Char;
  f: Boolean;
begin
  Result := '';

  if IsEmpty then
    Exit;

  i := 1;

  if CharsWhitespace.Contains(Self.Chars[i]) then
    while (i < Length) and CharsWhitespace.Contains(Self.Chars[i]) do
      Inc(i);

  if i > Length then
    Exit;

  c := Self.Chars[i];

  if CharsQuote.Contains(c) then
  begin
    repeat
      Result := Result + Self.Chars[i];

      Inc(i);

      if Self.Chars[i] = c then
      begin
        Inc(i);
        Break;
      end;
    until i > Length;

    if Result.Chars[Result.Length] <> c then
      Result := Result + c;
  end
  else if CharsNumeric.Contains(c) then
  begin
    f := False;

    repeat
      Result := Result + Self.Chars[i];

      Inc(i);

      if i > Length then
        Break;

      if (not f) and (Self.Chars[i] = '.') then
      begin
        Result := Result + '.';
        f      := True;

        Inc(i);
      end
    until (i > Length) or (not CharsNumeric.Contains(Self.Chars[i]))
  end
  else if CharsIdentStart.Contains(c) then
    repeat
      Result := Result + Self.Chars[i];

      Inc(i);
    until (i > Length) or (not (CharsIdent + '.').Contains(Self.Chars[i]))
  else
  begin
    Result := c;
    Inc(i);

    if i < Length then
      for var j := Low(DblTokens) to High(DblTokens) do
        if (String(DblTokens[j]).Chars[1] = c) and (String(DblTokens[j]).Chars[2] = Self[i]) then
        begin
          Result := Result + Self.Chars[i];
          Inc(i);
          Break;
        end;
  end;

  if ARemove then
    Self := Copy(i).Trim;
end;

function TStringHelper.Copy;
var
  C: Integer;
begin
  if ACount = -1 then
    C := Length
  else
    C := ACount;

  Result := System.Copy(Self, AIndex, C);
end;

function TStringHelper.FirstChar;
begin
  if IsEmpty then
    Exit(#0);

  Result := Self.Chars[1];
end;

function TStringHelper.LastChar;
begin
  if IsEmpty then
    Exit(#0);

  Result := Self.Chars[Self.Length];
end;

function TStringHelper.Start;
begin
  if ACount < 0 then
    Result := Copy(1, Length + ACount)
  else
    Result := Copy(1, ACount);
end;
{$ENDREGION}

{$REGION 'Convert'}
function TStringHelper.UpperCase;
begin
  if AEnable then
    Result := System.SysUtils.UpperCase(Self)
  else
    Result := Self;
end;

function TStringHelper.LowerCase;
begin
  if AEnable then
    Result := System.SysUtils.LowerCase(Self)
  else
    Result := Self;
end;

function TStringHelper.UTF8;
begin
  Result := UTF8String(Self);
end;

function TStringHelper.AsInteger;
begin
  Result := String.Int(Self, ADefault);
end;

function TStringHelper.AsFloat;
begin
  Result := String.Float(Self, ADefault);
end;

function TStringHelper.AsBoolean;
begin
  Result := String.Bool(Self, ADefault);
end;

function TStringHelper.AsPointer;
begin
  Result := String.Pointer(Self);
end;

{$REGION 'Markup codes'}
type
  TMarkupCode = record
    Name:  String{$IFDEF MSWINDOWS}[10]{$ENDIF};
    Value: String{$IFDEF MSWINDOWS}[2]{$ENDIF};
  end;

const
  // As per ISO 8859-1 (ish) (I added/removed a few for convenience)
  MarkupCodes: array[0..106] of TMarkupCode = (
    (Name:'amp';    Value:#1'&'),(Name:'quot';   Value:'"'), (Name:'apos';    Value:''''),
    (Name:'lt';     Value:'<'),  (Name:'gt';     Value:'>'), (Name:'copy';    Value:'©'),
    (Name:'reg';    Value:'®'),  (Name:'middot'; Value:'·'), (Name:'deg';     Value:'°'),
    (Name:'sup1';   Value:'¹'),  (Name:'sup2';   Value:'²'), (Name:'sup3';    Value:'³'),
    (Name:'frac14'; Value:'¼'),  (Name:'frac12'; Value:'½'), (Name:'frac34';  Value:'¾'),
    (Name:'cent';   Value:'¢'),  (Name:'pound';  Value:'£'), (Name:'yen';     Value:'¥'),
    (Name:'cr';     Value:#13),  (Name:'lf';     Value:#10), (Name:'crlf';    Value:#13#10),
    (Name:'nbsp';   Value:#160), (Name:'iexcl';  Value:'¡'), (Name:'curren';  Value:'¤'),
    (Name:'brvbar'; Value:'¦'),  (Name:'sect';   Value:'§'), (Name:'uml';     Value:'¨'),
    (Name:'ordf';   Value:'ª'),  (Name:'laquo';  Value:'«'), (Name:'raquo';   Value:'»'),
    (Name:'not';    Value:'¬'),  (Name:'macr';   Value:'¯'), (Name:'shy';     Value:#173),
    (Name:'plusmn'; Value:'±'),  (Name:'acute';  Value:'´'), (Name:'micro';   Value:'µ'),
    (Name:'para';   Value:'¶'),  (Name:'cedil';  Value:'¸'), (Name:'ordm';    Value:'º'),
    (Name:'iquest'; Value:'¿'),  (Name:'times';  Value:'×'), (Name:'divide';  Value:'÷'),
    (Name:'Agrave'; Value:'À'),  (Name:'Aacute'; Value:'Á'), (Name:'Acirc';   Value:'Â'),
    (Name:'Atilde'; Value:'Ã'),  (Name:'Auml';   Value:'Ä'), (Name:'Aring';   Value:'Å'),
    (Name:'AElig';  Value:'Æ'),  (Name:'Ccedil'; Value:'Ç'), (Name:'Egrave';  Value:'È'),
    (Name:'Eacute'; Value:'É'),  (Name:'Ecirc';  Value:'Ê'), (Name:'Euml';    Value:'Ë'),
    (Name:'Igrave'; Value:'Ì'),  (Name:'Iacute'; Value:'Í'), (Name:'Icirc';   Value:'Î'),
    (Name:'Iuml';   Value:'Ï'),  (Name:'ETH';    Value:'Ð'), (Name:'Ntilde';  Value:'Ñ'),
    (Name:'Ograve'; Value:'Ò'),  (Name:'Oacute'; Value:'Ó'), (Name:'Ocirc';   Value:'Ô'),
    (Name:'Otilde'; Value:'Õ'),  (Name:'Ouml';   Value:'Ö'), (Name:'Oslash';  Value:'Ø'),
    (Name:'Ugrave'; Value:'Ù'),  (Name:'Uacute'; Value:'Ú'), (Name:'Ucirc';   Value:'Û'),
    (Name:'Uuml';   Value:'Ü'),  (Name:'Yacute'; Value:'Ý'), (Name:'THORN';   Value:'Þ'),
    (Name:'szlig';  Value:'ß'),  (Name:'agrave'; Value:'à'), (Name:'aacute';  Value:'á'),
    (Name:'acirc';  Value:'â'),  (Name:'atilde'; Value:'ã'), (Name:'auml';    Value:'ä'),
    (Name:'aring';  Value:'å'),  (Name:'aelig';  Value:'æ'), (Name:'ccedil';  Value:'ç'),
    (Name:'egrave'; Value:'è'),  (Name:'eacute'; Value:'é'), (Name:'ecirc';   Value:'ê'),
    (Name:'euml';   Value:'ë'),  (Name:'igrave'; Value:'ì'), (Name:'iacute';  Value:'í'),
    (Name:'icirc';  Value:'î'),  (Name:'iuml';   Value:'ï'), (Name:'eth';     Value:'ð'),
    (Name:'ntilde'; Value:'ñ'),  (Name:'ograve'; Value:'ò'), (Name:'oacute';  Value:'ó'),
    (Name:'ocirc';  Value:'ô'),  (Name:'otilde'; Value:'õ'), (Name:'ouml';    Value:'ö'),
    (Name:'oslash'; Value:'ø'),  (Name:'ugrave'; Value:'ù'), (Name:'uacute';  Value:'ú'),
    (Name:'ucirc';  Value:'û'),  (Name:'uuml';   Value:'ü'), (Name:'yacute';  Value:'ý'),
    (Name:'thorn';  Value:'þ'),  (Name:'yuml';   Value:'ÿ'), (Name:'semicol'; Value:#1';'),
    (Name:'tm';     Value:'™'),  (Name:'grave';  Value:'`')
  );{Do not localize}
{$ENDREGION}

function TStringHelper.Markup;
var
  Coded: String;
  c:     Char;
begin
  Result := Self.Replace('&', '/+');

  for var Markup in MarkupCodes do
    if String(Markup.Value).Chars[1] <> #1 then
      Result := Result.Replace(String(Markup.Value), '&' + String(Markup.Name) + ';');

  if CodeUnprintable then
  begin
    Coded := '';

    for c in Result do
      if CharsIdentObj.Contains(c) then
        Coded := Coded + c
      else
        Coded := Coded + '&' + Int(Ord(c)) + ';';

    Result := Coded;
  end;
end;

function TStringHelper.UnMarkup;
var
  i: Integer;
begin
  Result := Self.Replace('/+', '&');

  for var Markup in MarkupCodes do
    if String(Markup.Value).Chars[1] = #1 then
      Result := Result.Replace('&' + String(Markup.Name) + ';', String(String(Markup.Value).Chars[2]))
    else
      Result := Result.Replace('&' + String(Markup.Name) + ';', String(Markup.Value));

  if DecodeUnprintable then
    for i := 0 to 255 do
      Result := Result.Replace('&' + Int(i) + ';', Char(i));
end;
{$ENDREGION}

{$REGION 'Tidy'}
function TStringHelper.LTrim;
var
  i: Integer;
begin
  for i := 1 to Length do
    if CharsWhitespace.Pos(Self.Chars[i]) = 0 then
      Break;

  Result := Copy(i);
end;

function TStringHelper.RTrim;
var
  i: Integer;
begin
  for i := Length downto 1 do
    if CharsWhitespace.Pos(Self.Chars[i]) = 0 then
      Break;

  Result := Copy(1, i);
end;

function TStringHelper.Trim;
begin
  if AEnable then
    Result := Self.LTrim.RTrim
  else
    Result := Self;
end;

function TStringHelper.Tidy;
var
  i:    Integer;
  c, q: Char;
  w:    Boolean;

  function SkipWhitespace: Boolean;
  begin
    Result := CharsWhitespace.Contains(c);

    if not Result then
      Exit;

    while (i <= Length) and CharsWhitespace.Contains(Self.Chars[i]) do
      Inc(i);

    i := i - 1;
  end;
begin
  Result := '';

  if IsEmpty then
    Exit;

  i := 1; q := #0;

  repeat
    c := Self.Chars[i];

    if q <> #0 then
    begin
      if c = q then
        q := #0;

      Result := Result + c;
    end
    else
    begin
      w := SkipWhitespace;

      if i > Length then
        Break;

      if w then
        c := Self.Chars[i];

      if CharsQuote.Contains(c) then
        q := c;

      if CharsWhitespace.Contains(c) then
        c := #32;

      Result := Result + c;
    end;

    Inc(i);
  until i > Length;

  Result := Result.Trim;
end;

function TStringHelper.TidyNumeric;
var
  i: Integer;
begin
  Result := Trim;

  if Result.Pos('.') > 0 then
  begin
    while Result.LastChar = '0' do
      Result := Result.Copy(1, Result.Length - 1);

    if Result.LastChar = '.' then
      Result := Result.Copy(1, Result.Length - 1);
  end;

  while (not Result.IsEmpty) and (Result.FirstChar = '0') do
    Result := Result.Copy(2);

  i := Result.Pos('.') - 1;

  if i < 1 then
    i := Result.Length;

  repeat
    i := i - 3;

    if i < 1 then
      Break;

    Result := Result.Insert(',', i);
  until False;

  if Result.IsEmpty or (Result.FirstChar = '.') then
    Result := '0' + Result;

  if APlaces > 0 then
  begin
    var Mask := String('0').Repeated(APlaces);

    i := Result.Pos('.');

    if i = 0 then
      Result := Result + '.' + Mask
    else
    begin
      var D := Result.SplitFirst('.');

      Result := D + '.' + Result.LAlign(Mask).Copy(1, APlaces);
    end;
  end;
end;

function TStringHelper.Quote;
begin
  Result := Trim;

  if Result.IsEmpty then
    Exit(AQuote + AQuote);

  if Result.FirstChar <> AQuote then
    Result := AQuote + Result;

  if Result.LastChar <> AQuote then
    Result := Result + AQuote;
end;

function TStringHelper.Unquote;
var
  QuoteChar: Char;
begin
  Result := Trim;

  if Result.IsEmpty then
    Exit;

  QuoteChar := Result.FirstChar;

  if CharsQuote.Contains(QuoteChar) then
  begin
    Result := Result.Copy(2);
    if Result.IsEmpty then
      Exit;

    if Result.LastChar = QuoteChar then
      Result := Result.Copy(1, Result.Length - 1);
  end;
end;
{$ENDREGION}

{$REGION 'Modify'}
function TStringHelper.Insert;
begin
  Result := Copy(1, AIndex) + AStr + Copy(AIndex + 1);
end;

function TStringHelper.Delete;
begin
  Result := Copy(1, AIndex - 1) + Copy(AIndex + ACount);
end;

function TStringHelper.Replace;
var
  i: Integer;
  p: Integer;
begin
  Result := Self;
  p := AStart;

  i := Result.Pos(AFindStr, p, AIgnoreCase, AOutOfQuotes);

  while i > 0 do
  begin
    Result := Result.Copy(1, i - 1) + AReplaceStr + Result.Copy(i + AFindStr.Length);

    p := p + AReplaceStr.Length + 1;
    i := Result.Pos(AFindStr, p, AIgnoreCase, AOutOfQuotes);
  end;
end;

function TStringHelper.LAlign;
begin
  Result := AMask;

  for var i := 1 to Length do
    if i > Result.Length then
      Exit
    else
      Result.Chars[i] := Self.Chars[i];
end;

function TStringHelper.RAlign;
var
  j: Integer;
begin
  Result := AMask;

  for var i := 1 to Length do
  begin
    j := Result.Length - i + 1;

    if j < 1 then
      Exit;

    Result.Chars[j] := Self.Chars[Length - i + 1];
  end;
end;

function TStringHelper.CAlign;
var
  j: Integer;
begin
  Result := AMask;

  for var i := 1 to Length do
  begin
    j := ((AMask.Length shr 1) - (Length shr 1) + i);

    if j < 1 then
      Continue
    else if j > Result.Length then
      Exit;

    Result.Chars[j] := Self.Chars[i];
  end;
end;
{$ENDREGION}

{$REGION 'Build'}
function TStringHelper.Repeated;
begin
  Result := '';

  for var i := 1 to ATimes do
    Result := Result + Self;
end;

function TStringHelper.Append;
begin
  Result := Self;

  if AStr.IsEmpty then Exit;

  if not Result.IsEmpty then
    if not Result.Ends(ASep, False, False) then
      Result := Result + ASep;

  Result := Result + AStr;
end;

class function TStringHelper.From(const A): String;
begin
  Result := From(TVarRec(A));
end;

class function TStringHelper.From(R: TVarRec): String;
begin
  with TVarRec(R) do
  begin
    case VType of
      vtInteger:       Result := Int(VInteger);
      vtBoolean:       Result := Bool(VBoolean);
      vtChar:          Result := String(VChar);
      vtWideChar:      Result := String(VWideChar);
      vtExtended:      Result := Float(VExtended^);
{$IFDEF MSWINDOWS}
      vtString:        Result := String(VString);
{$ENDIF}
      vtPointer:       Result := Pointer(VPointer);
      vtPChar:         Result := String(VPChar);
      vtObject:        Result := VObject.RttiAsText;
      vtClass:         Result := VClass.ClassName;
      vtPWideChar:     Result := VPWideChar;
      vtWideString:    Result := String({$IFDEF MSWINDOWS}WideString{$ENDIF}(VWideString));
      vtInt64:         Result := Int(VInt64^);
      vtUnicodeString: Result := String(UnicodeString(VUnicodeString));
{$IFDEF MSWINDOWS}
      vtAnsiString:    Result := String(AnsiString(VAnsiString));
{$ELSE}
      vtAnsiString:    Result := Pointer(VAnsiString);
{$ENDIF}
    else
      Result := 'Unk(' + Int(VType) + ')';
    end;

    Result := String.Int(VType) + ':' + Result;
  end;
end;

class function TStringHelper.From(O: TObject): String;
begin
  Result := O.RttiAsText;
end;

class function TStringHelper.From(V: TValue): String;
begin
  Result := V.ToString;
end;

class function TStringHelper.Join;
begin
  Result := '';

  for var i := Low(AValues) to High(AValues) do
  begin
    Result := Result + From(AValues[i]);

    if i < High(AValues) then
      Result := Result + ADelim;
  end;
end;

class function TStringHelper.Base(const AInt: Int64; const ABase: Integer; AMinSize: Integer = 0): String;
var
  Val: Int64;
  Neg: Boolean;
begin
  Result := '';

  if ABase > CharsBase.Length then
    Exit;

  Neg := AInt < 0;
  Val := Abs(AInt);

  if Val = 0 then
    Result := CharsBase.Chars[1]
  else
    while Val > 0 do
    begin
      Result := CharsBase.Chars[(Val mod Cardinal(ABase)) + 1] + Result;
      Val := Val div Int64(ABase);
    end;

  if AMinSize > 0 then
    while Result.Length < AMinSize do
      Result := CharsBase.Chars[1] + Result;

  if Neg then
    Result := '-' + Result;
end;

class function TStringHelper.Base(const AStr: String; const ABase: Integer; ADefault: Integer = 0): Int64;
var
  CS: String;
begin
  CS := AStr.Trim.Replace(',', '');

  if (ABase = 0) or (ABase > CharsBase.Length) or CS.IsEmpty then
    Exit(ADefault);

  var Valid := CharsBase.Copy(1, ABase);

  Result := 0;

  var j: Integer;

  for var i := 1 to CS.Length do
  begin
    j := Valid.Pos(CS.Chars[i]);

    if j = 0 then
      Exit(ADefault);

    Result := Result * ABase + (j - 1);
  end;
end;

class function TStringHelper.Int(const AInt: Int64; const AMinSize: Integer = 0): String;
begin
  Result := Dec(AInt, AMinSize);
end;

class function TStringHelper.Dec(const AInt: Int64; const AMinSize: Integer = 0): String;
var
  S: {$IFDEF MSWINDOWS}ShortString{$ELSE}String{$ENDIF};
begin
  System.Str(AInt, S);
  Result := String(S);

  if AMinSize > 0 then
    while Result.Length < AMinSize do
      Result := CharsBase.Chars[1] + Result;
end;

class function TStringHelper.Hex(const AInt: Int64; const AMinSize: Integer = 0): String;
begin
  Result := Base(AInt, 16, AMinSize);
end;

class function TStringHelper.Oct(const AInt: Int64; const AMinSize: Integer = 0): String;
begin
  Result := Base(AInt, 8, AMinSize);
end;

class function TStringHelper.Bin(const AInt: Int64; const AMinSize: Integer = 0): String;
begin
  Result := Base(AInt, 2, AMinSize);
end;

class function TStringHelper.Int(const AStr: String; const ADefault: Int64 = 0): Int64;
var
  Neg: Boolean;
  V:   String;
begin
  Result := ADefault;

  V := AStr.Trim.Replace(',', '');

  if V.IsEmpty then
    Exit;

  Neg := V.Chars[1] = '-';
  if Neg then
  begin
    V := V.Copy(2);

    if V.IsEmpty then
      Exit;
  end;

  try
{ TODO:    for var i := 0 to System.Length(IntBases) - 1 do
      with IntBases[i] do
        if (V.Copy(1, Prefix.Length) = Prefix) and (V.Copy(V.Length - Postfix.Length + 1, Postfix.Length) = Postfix) then
          Exit(String.Base(V.Copy(Prefix.Length + 1, V.Length - Prefix.Length - Postfix.Length), Base, Default));
}
    Result := Dec(V, ADefault);
  finally
    if Neg and (Result > 0) then
      Result := -Result;
  end;
end;

class function TStringHelper.Dec(const AStr: String; const ADefault: Int64 = 0): Int64;
begin
  Result := Base(AStr.Replace(',', ''), 10, ADefault);
end;

class function TStringHelper.Hex(const AStr: String; const ADefault: Int64 = 0): Int64;
begin
  Result := Base(AStr.Replace(',', ''), 16, ADefault);
end;

class function TStringHelper.Oct(const AStr: String; const ADefault: Int64 = 0): Int64;
begin
  Result := Base(AStr.Replace(',', ''), 8, ADefault);
end;

class function TStringHelper.Bin(const AStr: String; const ADefault: Int64 = 0): Int64;
begin
  Result := Base(AStr.Replace(',', ''), 2, ADefault);
end;

class function TStringHelper.Float(const AFloat: Extended; const APrec: Integer = 2): String;
var
  s: {$IFDEF MSWINDOWS}ShortString{$ELSE}String{$ENDIF};
begin
  System.Str(AFloat:APrec:APrec, s);
  Result := String(s);
end;

class function TStringHelper.Float(const AStr: String; const ADefault: Extended = 0): Extended;
var
  Code: Integer;
begin
  Val(AStr.Replace(',', ''), Result, Code);

  if Code <> 0 then
    Result := ADefault;
end;

class function TStringHelper.Bool(const ABool: Boolean; const ATrue: String = 'True'; const AFalse: String = 'False'): String;
begin
  if ABool then
    Result := ATrue
  else
    Result := AFalse;
end;

class function TStringHelper.Bool(const AStr: String; const ADefault: Boolean = False): Boolean;
var
  t: String;
begin
  if AStr.IsEmpty then
    Exit(ADefault);

  t := AStr.Copy(1, 2).LowerCase;

  if (t = 'ok') or (t = 'on') or (t = 'en') or ({$IFDEF MSWINDOWS}AnsiChar{$ENDIF}(AStr.Chars[1]) in ['Y', 'y', 'T', 't', #1]) then
    Result := True
  else
    Result := Int(AStr, 0) <> 0;
end;

class function TStringHelper.Pointer(const APtr: Pointer): String;
begin
  Result := Hex(Int64(APtr), SizeOf(System.Pointer) * 4);
end;

class function TStringHelper.Pointer(const AStr: String): Pointer;
begin
  Result := System.Pointer(Int(AStr));
end;
{$ENDREGION}

{$REGION 'Load/Save'}
class function TStringHelper.LoadFromStream(const AStream: TStream; var AEncoding: TEncoding): String;
var
  Size: Integer;
  Buffer: TBytes;
begin
  AEncoding := nil;

  Size := AStream.Size - AStream.Position;
  System.SetLength(Buffer, Size);

  AStream.Read(Buffer, 0, Size);

  Size := TEncoding.GetBufferEncoding(Buffer, AEncoding, TEncoding.Default);
  Result := AEncoding.GetString(Buffer, Size, System.Length(Buffer) - Size);
end;

class function TStringHelper.LoadFromStream(const AStream: TStream): String;
var
  Encoding: TEncoding;
begin
  Result := LoadFromStream(AStream, Encoding);
end;

class function TStringHelper.LoadFromFile(const AFileName: String; var AEncoding: TEncoding): String;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead);

  try
    Result := LoadFromStream(Stream, AEncoding);
  finally
    Stream.Free;
  end;
end;

class function TStringHelper.LoadFromFile(const AFileName: String): String;
var
  Encoding: TEncoding;
begin
  Encoding := nil;

  Result := LoadFromFile(AFileName, Encoding);
end;

procedure TStringHelper.SaveToStream;
var
  Buffer, Preamble: TBytes;
begin
  if AEncoding = nil then
    AEncoding := TEncoding.Default;

  Buffer := AEncoding.GetBytes(Self);

  if AWriteBOM then
  begin
    Preamble := AEncoding.GetPreamble;

    if System.Length(Preamble) > 0 then
      AStream.WriteBuffer(Preamble, System.Length(Preamble));
  end;

  AStream.WriteBuffer(Buffer, System.Length(Buffer));
end;

procedure TStringHelper.SaveToFile;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate or fmOpenWrite);

  try
    SaveToStream(Stream, AEncoding, AWriteBOM);
  finally
    Stream.Free;
  end;
end;
{$ENDREGION}

end.

