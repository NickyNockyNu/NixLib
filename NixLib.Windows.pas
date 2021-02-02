unit NixLib.Windows;

interface

uses
  WinApi.Windows,
  WinApi.Messages;

// TODO: Window/class creation exceptions

type
{$REGION 'TWindow'}
  TWindow = class
  private
    FHandle: HWND;

    FRunning: Boolean;

    function  GetWindowValue(AIndex: Integer): Integer; inline;
    procedure SetWindowValue(AIndex, AValue: Integer);   inline;

    function  GetClassValue (AIndex: Integer): Integer; inline;
    procedure SetClassValue (AIndex, AValue: Integer);   inline;

    function  GetPosSize(AIndex: Integer): Integer;
    procedure SetPosSize(AIndex, AValue: Integer);

    function  GetClientSize(AIndex: Integer): Integer;
    procedure SetClientSize(AIndex, AValue: Integer);

    function  GetCaption: String;
    procedure SetCaption(AValue: String);
  public
    class function ProcessMessages(const AWait: Boolean = True): Cardinal;

    constructor Create(const AHandle: HWND);

    function Perform(const AMsg: Integer; const AWParam: WPARAM; const ALParam: LPARAM; const ADelayed: Boolean = False): LRESULT; inline;

    procedure Show(const AShowCmd: Integer = SW_SHOW);

    function Rect:       TRect; inline;
    function ClientRect: TRect; inline;

    procedure Run(const AWait: Boolean = True);

    procedure RunBegin; virtual;
    procedure RunIdle;  virtual;
    procedure RunEnd;   virtual;

    property Handle: HWND read FHandle;

    property Running: Boolean read FRunning;

    property WindowLong[AIndex: Integer]: Integer read GetWindowValue write SetWindowValue;
    property ClassLong [AIndex: Integer]: Integer read GetClassValue  write SetClassValue;

    property StyleEx:   Integer index GWL_EXSTYLE   read GetWindowValue write SetWindowValue;
    property Style:     Integer index GWL_STYLE     read GetWindowValue write SetWindowValue;
    property Instance:  Integer index GWL_HINSTANCE read GetWindowValue write SetWindowValue;
    property ID:        Integer index GWL_ID        read GetWindowValue write SetWindowValue;
    //property DlgProc:   Integer index DWL_DLGPROC   read GetWindowValue write SetWindowValue;
    //property DlgResult: Integer index DWL_MSGRESULT read GetWindowValue write SetWindowValue;
    //property DlgUser:   Integer index DWL_USER      read GetWindowValue write SetWindowValue;

    property ClassAtom:       Integer index GCW_ATOM          read GetClassValue write SetClassValue;
    property ClassBackground: Integer index GCL_HBRBACKGROUND read GetClassValue write SetClassValue;
    property ClassCursor:     Integer index GCL_HCURSOR       read GetClassValue write SetClassValue;
    property ClassIcon:       Integer index GCL_HICON         read GetClassValue write SetClassValue;
    property ClassSmallIcon:  Integer index GCL_HICONSM       read GetClassValue write SetClassValue;
    property ClassModule:     Integer index GCL_HMODULE       read GetClassValue write SetClassValue;
    property ClassMenuName:   Integer index GCL_MENUNAME      read GetClassValue write SetClassValue;
    property ClassStyle:      Integer index GCL_STYLE         read GetClassValue write SetClassValue;

    property Left:   Integer index 0 read GetPosSize write SetPosSize;
    property Top:    Integer index 1 read GetPosSize write SetPosSize;
    property Width:  Integer index 2 read GetPosSize write SetPosSize;
    property Height: Integer index 3 read GetPosSize write SetPosSize;

    property ClientWidth:  Integer index 0 read GetClientSize write SetClientSize;
    property ClientHeight: Integer index 1 read GetClientSize write SetClientSize;

    property Caption: String read GetCaption write SetCaption;
  end;
{$ENDREGION}

{$REGION 'TWindowSubclass'}
  PWndMsg = ^TWndMsg;
  TWndMsg = packed record
    Msg:     Cardinal;
    Wnd:     HWND;
    wParam:  WPARAM;
    lParam:  LPARAM;
    lResult: LRESULT;
  end;

  PWindowProc = ^TWindowProc;
  TWindowProc = function(AWnd: HWND; AMsg: Integer; AWParam: WPARAM; ALParam: LPARAM): LRESULT; stdcall;

  TWindowSubclass = class(TWindow)
  private
    FOldWindowProc: PWindowProc;
  public
    constructor Create(const AHandle: HWND);
    destructor  Destroy; override;

    function StartSubClass: Boolean;
    function EndSubClass:   Boolean;

    procedure RunBegin; override;
    procedure RunEnd;   override;

    procedure DefaultHandler(var AMsg);          override;
    procedure WindowMethod  (var AMsg: TWndMsg); virtual;

    property OldWindowProc: PWindowProc read fOldWindowProc;
  end;
{$ENDREGION}

{$REGION 'TWindowClass'}
  TWindowParams = record
    ExStyle:    Cardinal;
    WindowName: String;
    Style:      Cardinal;
    X, Y, W, H: Integer;
    Parent:     HWND;
    Menu:       HMENU;
    HInstance:  HINST;
    Param:      Pointer;
  end;

  TWindowClass = class(TWindowSubclass)
  public
    class var Atom: ATOM;

    class constructor Create;
    class destructor  Destroy;

    class procedure InitWindowClass(var AWndClass: WNDCLASSEX); virtual;

    class function  RegisterClass:   Boolean;
    class function  UnregisterClass: Boolean;

    constructor Create;
    destructor  Destroy; override;

    procedure InitWindowParams(var AParams: TWindowParams); virtual;

    function CreateWindow:  Boolean; virtual;
    function DestroyWindow: Boolean; virtual;

    procedure RunBegin; override;
    procedure RunEnd;   override;
  end;
{$ENDREGION}

implementation

{$REGION 'TWindow'}
function TWindow.GetWindowValue;
begin
  if FHandle <> 0 then
    Result := GetWindowLong(FHandle, AIndex)
  else
    Result := 0;
end;

procedure TWindow.SetWindowValue;
begin
  if FHandle <> 0 then
    SetWindowLong(FHandle, AIndex, AValue);
end;

function TWindow.GetClassValue;
begin
  if FHandle <> 0 then
    Result := GetClassLong(FHandle, AIndex)
  else
    Result := 0;
end;

procedure TWindow.SetClassValue;
begin
  if FHandle <> 0 then
    SetClassLong(FHandle, AIndex, AValue);
end;

function TWindow.GetPosSize;
begin
  if FHandle <> 0 then
  begin
    with Rect do
      case AIndex of
        0: Result := Left;
        1: Result := Top;
        2: Result := Right - Left;
        3: Result := Bottom - Top;
      else
        Result := 0;
      end;
  end
  else
    Result := 0;
end;

procedure TWindow.SetPosSize;
begin
  if FHandle <> 0 then
    with Rect do
      case AIndex of
        0: MoveWindow(fHandle, AValue, Top,    Right - Left,  Bottom - Top, True);
        1: MoveWindow(fHandle, Left,   AValue, Right - Left,  Bottom - Top, True);
        2: MoveWindow(fHandle, Left,   Top,    AValue,        Bottom - Top, True);
        3: MoveWindow(fHandle, Left,   Top,    Right - Left,  AValue,       True);
      end;
end;

function TWindow.GetClientSize;
begin
  if FHandle <> 0 then
  begin
    with ClientRect do
      case AIndex of
        0: Result := Right  - Left;
        1: Result := Bottom - Top;
      else
        Result := 0;
      end;
  end
  else
    Result := 0;
end;

procedure TWindow.SetClientSize;
begin
  if FHandle <> 0 then
    case AIndex of
      0: Width  := AValue + (Width  - ClientWidth);
      1: Height := AValue + (Height - ClientHeight);
    end;
end;

function TWindow.GetCaption;
begin
  if FHandle <> 0 then
  begin
    SetLength(Result, GetWindowTextLength(FHandle) + 1);
    SetLength(Result, GetWindowText(FHandle, PChar(Result), Length(Result)));
  end
  else
    Result := '';
end;

procedure TWindow.SetCaption;
begin
  if FHandle <> 0 then
    SetWindowText(FHandle, AValue);
end;

class function TWindow.ProcessMessages;
var
  Msg: TMsg;
begin
  if AWait then WaitMessage;

  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
  begin
    if Msg.message = WM_QUIT then
      Break;

    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;

  Result := Msg.message;
end;

constructor TWindow.Create;
begin
  inherited Create;

  FHandle  := AHandle;
  FRunning := False;
end;

function TWindow.Perform;
begin
  if FHandle <> 0 then
  begin
    if ADelayed then
      Result := LRESULT(PostMessage(FHandle, AMsg, AWParam, ALParam))
    else
      Result := SendMessage(FHandle, AMsg, AWParam, ALParam);
  end
  else
    Result := LRESULT(False);
end;

procedure TWindow.Show;
begin
  if FHandle <> 0 then
    ShowWindow(FHandle, AShowCmd);
end;

function TWindow.Rect: TRect;
begin
  if FHandle <> 0 then
    GetWindowRect(FHandle, Result);
end;

function TWindow.ClientRect: TRect;
begin
  if FHandle <> 0 then
    GetClientRect(FHandle, Result);
end;

procedure TWindow.Run;
begin
  if Running then
    Exit;

  try
    RunBegin;

    while fRunning and (ProcessMessages(AWait) <> WM_QUIT) do
      RunIdle;
  finally
    RunEnd;

    FRunning := False;
  end;
end;

procedure TWindow.RunBegin;
begin
  FRunning := True;
end;

procedure TWindow.RunIdle;
begin
  FRunning := (FHandle <> 0) and IsWindowVisible(FHandle);
  Sleep(0);
end;

procedure TWindow.RunEnd;
begin
  FRunning := False;
end;
{$ENDREGION'}

{$REGION 'TWindowSubclass'}
function TWindowSubclassWindowProc(AWnd: HWND; AMsg: Integer; AWParam: WPARAM; ALParam: LPARAM): LRESULT; stdcall;
var
  Subclass: TWindowSubclass;
  WndMsg:   TWndMsg;
begin
  Subclass := TWindowSubclass(GetWindowLong(AWnd, GWL_USERDATA));

  WndMsg.Msg     := AMsg;
  WndMsg.Wnd     := AWnd;
  WndMsg.wParam  := AWParam;
  WndMsg.lParam  := ALParam;
  WndMsg.lResult := 0;

  Subclass.WindowMethod(WndMsg);
  Result := WndMsg.lResult;
end;

constructor TWindowSubclass.Create;
begin
  inherited Create(AHandle);

  FOldWindowProc := nil;
  StartSubClass;
end;

destructor TWindowSubclass.Destroy;
begin
  EndSubClass;

  inherited;
end;

function TWindowSubclass.StartSubclass;
begin
  if (not EndSubclass) or (Handle = 0) then
    Exit(False);

  FOldWindowProc := Pointer(GetWindowLong(Handle, GWL_WNDPROC));

  SetWindowLong(Handle, GWL_USERDATA, NativeInt(Self));
  SetWindowLong(Handle, GWL_WNDPROC,  NativeInt(@TWindowSubclassWindowProc));

  Result := True;
end;

function TWindowSubclass.EndSubclass;
begin
  if FOldWindowProc = nil then
    Exit(True);

  SetWindowLong(Handle, GWL_WNDPROC, NativeInt(FOldWindowProc));
  FOldWindowProc := nil;

  Result := True;
end;

procedure TWindowSubclass.RunBegin;
begin
  FRunning := StartSubclass;
end;

procedure TWindowSubclass.RunEnd;
begin
  EndSubclass;

  FRunning := False;
end;

procedure TWindowSubclass.DefaultHandler;
begin
  with TWndMsg(AMsg) do
    lResult := CallWindowProc(FOldWindowProc, Wnd, Msg, wParam, lParam);
end;

procedure TWindowSubclass.WindowMethod;
begin
  Dispatch(AMsg);
end;
{$ENDREGION}

{$REGION 'TWindowClass'}
class constructor TWindowClass.Create;
begin
  Atom := 0;
end;

class destructor TWindowClass.Destroy;
begin
  UnregisterClass;
end;

class procedure TWindowClass.InitWindowClass;
begin
  with AWndClass do
  begin
    lpfnWndProc   := @DefWindowProc;
    hInstance     := SysInit.HInstance;
    hIcon         := LoadIcon(0, IDI_APPLICATION);
    hCursor       := LoadCursor(0, IDC_ARROW);
    hbrBackground := COLOR_BTNFACE + 1;
    lpszClassName := PChar(ClassName);
  end;
end;

class function TWindowClass.RegisterClass;
var
  WndClass: WNDCLASSEX;
begin
  if Atom <> 0 then
    Exit(True);

  FillChar(WndClass, SizeOf(WndClass), 0);
  WndClass.cbSize := SizeOf(WndClass);

  InitWindowClass(WndClass);

  Atom := RegisterClassEx(WndClass);
  Result := Atom <> 0;
end;

class function TWindowClass.UnregisterClass;
begin
  if Atom = 0 then
    Exit(True);

  Result :=  WinApi.Windows.UnregisterClass(PChar(Atom), HInstance);
  if Result then Atom := 0;
end;

constructor TWindowClass.Create;
begin
  inherited Create(0);

  //CreateWindow;
end;

destructor TWindowClass.Destroy;
begin
  DestroyWindow;

  inherited;
end;

procedure TWindowClass.InitWindowParams;
begin
  with AParams do
  begin
    ExStyle    := 0;
    WindowName := ClassName;
    Style      := WS_VISIBLE or WS_OVERLAPPEDWINDOW;
    X          := Integer(CW_USEDEFAULT);
    Y          := Integer(CW_USEDEFAULT);
    W          := Integer(CW_USEDEFAULT);
    H          := Integer(CW_USEDEFAULT);
    Parent     := 0;
    Menu       := 0;
    HInstance  := SysInit.HInstance;
    Param      := nil;
  end;
end;

function TWindowClass.CreateWindow;
var
  Params: TWindowParams;
begin
  if FHandle <> 0 then
    Exit(True);

  if not RegisterClass then
    Exit(False);

  InitWindowParams(Params);

  with Params do
    FHandle := CreateWindowEx(ExStyle, PChar(Atom), PChar(WindowName), Style, X, Y, W, H, Parent, Menu, HInstance, Param);

  if Handle = 0 then
    Exit(False);

  Result := StartSubclass;
end;

function TWindowClass.DestroyWindow;
begin
  if Handle = 0 then
    Exit(True);

  WinApi.Windows.DestroyWindow(Handle);
  Result := EndSubclass;

  FHandle := 0;
end;

procedure TWindowClass.RunBegin;
begin
  FRunning := CreateWindow;
end;

procedure TWindowClass.RunEnd;
begin
  DestroyWindow;

  FRunning := False;
end;
{$ENDREGION}

end.

