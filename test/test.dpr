program test;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  NixLib.Strings in '..\NixLib.Strings.pas',
  NixLib.Rtti in '..\NixLib.Rtti.pas',
  NixLib.Random in '..\NixLib.Random.pas',
  NixLib.Memory in '..\NixLib.Memory.pas',
  NixLib.Bitmap32 in '..\NixLib.Bitmap32.pas',
  NixLib.Types in '..\NixLib.Types.pas',
  NixLib.Timing in '..\NixLib.Timing.pas',
  NixLib.Cadencer in '..\NixLib.Cadencer.pas',
  NixLib.Config in '..\NixLib.Config.pas',
  NixLib.Log in '..\NixLib.Log.pas',
  NixLib.Busy in '..\NixLib.Busy.pas',
  NixLib.Globals in '..\NixLib.Globals.pas',
  NixLib.Draggable in '..\NixLib.Draggable.pas',
  NixLib.Filter in '..\NixLib.Filter.pas',
  NixLib.Geometry in '..\NixLib.Geometry.pas',
  NixLib.Forms in '..\NixLib.Forms.pas',
  NixLib.Hash in '..\NixLib.Hash.pas',
  NixLib.Streams in '..\NixLib.Streams.pas',
  NixLib.Windows in '..\NixLib.Windows.pas',
  NixLib.Transitions in '..\NixLib.Transitions.pas',
  NixLib.Shapes in '..\NixLib.Shapes.pas',
  NixLib.Switcher in '..\NixLib.Switcher.pas',
  NixLib.SceneGraph in '..\NixLib.SceneGraph.pas';

begin
  try
    {}
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

