{
  NixLib.Hash.pas

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

unit NixLib.Hash;

interface

uses
  NixLib.Memory,
  NixLib.Strings;

type
{$REGION 'THash'}
  THashClass = class of THash;

  THash = class abstract
  public
    constructor Create;

    procedure Reset; virtual; abstract;
    procedure Update(AData: Pointer; ALen: Integer); virtual; abstract;
    procedure Done; virtual; abstract;

    procedure UpdateStr(AStr: String); inline;

    function AsString: String; virtual; abstract;

    class function HashStr (const AStr: String):                 String; inline;
    class function HashData(const AData; const ASize: Cardinal): String;
  end;
{$ENDREGION}

{$REGION 'TCRC8'}
  TCRC8 = class(THash)
  private
    FHash: Byte;
  public
    procedure Reset; override;
    procedure Update(AData: Pointer; ALen: Integer); override;
    procedure Done; override;

    function AsString: String; override;

    property Hash: Byte read FHash;
  end;

{$REGION 'CRC8Table'}
const
  CRC8Table: array[Byte] of Byte = (
       098,006,085,150,036,023,112,164,135,207,169,005,026,064,165,219, //  1
       061,020,068,089,130,063,052,102,024,229,132,245,080,216,195,115, //  2
       090,168,156,203,177,120,002,190,188,007,100,185,174,243,162,010, //  3
       237,018,253,225,008,208,172,244,255,126,101,079,145,235,228,121, //  4
       123,251,067,250,161,000,107,097,241,111,181,082,249,033,069,055, //  5
       059,153,029,009,213,167,084,093,030,046,094,075,151,114,073,222, //  6
       197,096,210,045,016,227,248,202,051,152,252,125,081,206,215,186, //  7
       039,158,178,187,131,136,001,049,050,017,141,091,047,129,060,099, //  8
       154,035,086,171,105,034,038,200,147,058,077,118,173,246,076,254, //  9
       133,232,196,144,198,124,053,004,108,074,223,234,134,230,157,139, // 10
       189,205,199,128,176,019,211,236,127,192,231,070,233,088,146,044, // 11
       183,201,022,083,013,214,116,109,159,032,095,226,140,220,057,012, // 12
       221,031,209,182,143,092,149,184,148,062,113,065,037,027,106,166, // 13
       003,014,204,072,021,041,056,066,028,193,040,217,025,054,179,117, // 14
       238,087,240,155,180,170,242,212,191,163,078,218,137,194,175,110, // 15
       043,119,224,071,122,142,042,160,104,048,247,103,015,011,138,239  // 16
   );
{$ENDREGION}
{$ENDREGION}

{$REGION 'TCRC32'}
type
  TCRC32 = class(THash)
  private
    FHash: Cardinal;
  public
    procedure Reset; override;
    procedure Update(AData: Pointer; ALen: Integer); override;
    procedure Done; override;

    function AsString: String; override;

    property Hash: Cardinal read FHash;
  end;

{$REGION 'CRC32Table'}
const
  CRC32Table: array[Byte] of Cardinal = (
    $00000000, $77073096, $EE0E612C, $990951BA, $076DC419,
    $706AF48F, $E963A535, $9E6495A3, $0EDB8832, $79DCB8A4,
    $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07,
    $90BF1D91, $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7, $136C9856,
    $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9,
    $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4,
    $A2677172, $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3,
    $45DF5C75, $DCD60DCF, $ABD13D59, $26D930AC, $51DE003A,
    $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599,
    $B8BDA50F, $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190,
    $01DB7106, $98D220BC, $EFD5102A, $71B18589, $06B6B51F,
    $9FBFE4A5, $E8B8D433, $7807C9A2, $0F00F934, $9609A88E,
    $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED,
    $1B01A57B, $8208F4C1, $F50FC457, $65B0D9C6, $12B7E950,
    $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3,
    $FBD44C65, $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB, $4369E96A,
    $346ED9FC, $AD678846, $DA60B8D0, $44042D73, $33031DE5,
    $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA, $BE0B1010,
    $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17,
    $2EB40D81, $B7BD5C3B, $C0BA6CAD, $EDB88320, $9ABFB3B6,
    $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615,
    $73DC1683, $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1, $F00F9344,
    $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A,
    $67DD4ACC, $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1,
    $A6BC5767, $3FB506DD, $48B2364B, $D80D2BDA, $AF0A1B4C,
    $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF,
    $4669BE79, $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE,
    $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31,
    $2CD99E8B, $5BDEAE1D, $9B64C2B0, $EC63F226, $756AA39C,
    $026D930A, $9C0906A9, $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B,
    $E5D5BE0D, $7CDCEFB7, $0BDBDF21, $86D3D2D4, $F1D4E242,
    $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1,
    $18B74777, $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45, $A00AE278,
    $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7,
    $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC, $40DF0B66,
    $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605,
    $CDD70693, $54DE5729, $23D967BF, $B3667A2E, $C4614AB8,
    $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B,
    $2D02EF8D
  );
{$ENDREGION}
{$ENDREGION}

implementation

{$REGION 'THash'}
constructor THash.Create;
begin
  inherited;

  Reset;
end;

procedure THash.UpdateStr;
begin
  Update(AStr.Ptr[1], AStr.Size);
end;

class function THash.HashStr;
begin
  Result := HashData(AStr.Ptr[1]^, AStr.Size);
end;

class function THash.HashData;
begin
  with Self.Create do try
    Update(@AData, ASize);
    Done;
    Result := AsString;
  finally
    Free;
  end;
end;
{$ENDREGION}

{$REGION 'TCRC8'}
procedure TCRC8.Reset;
begin
  FHash := $FF;
end;

procedure TCRC8.Update;
begin
  for var i := 1 to ALen do
  begin
    FHash := CRC8Table[FHash xor PByte(AData)^];
    AData.Inc;
  end;
end;

procedure TCRC8.Done;
begin
  FHash := FHash xor $FF;
end;

function TCRC8.AsString;
begin
  Result := String.Hex(FHash, 2);
end;
{$ENDREGION}

{$REGION 'TCRC32'}
procedure TCRC32.Reset;
begin
  FHash := $FFFFFFFF;
end;

procedure TCRC32.Update;
var
  i: Cardinal;
begin
  for i := 1 to ALen do
  begin
    FHash := CRC32Table[Byte(FHash xor Cardinal(PByte(AData)^))] xor ((FHash shr 8) and $FFFFFF);
    AData.Inc;
  end;
end;

procedure TCRC32.Done;
begin
  FHash := FHash xor $FFFFFFFF;
end;

function TCRC32.AsString;
begin
  Result := String.Hex(FHash, 8);
end;
{$ENDREGION}

end.

