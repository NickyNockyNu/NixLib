program test;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Rtti,
  NixLib.Strings in '..\NixLib.Strings.pas',
  NixLib.Rtti in '..\NixLib.Rtti.pas',
  NixLib.Random in '..\NixLib.Random.pas',
  NixLib.Memory in '..\NixLib.Memory.pas',
  NixLib.Bitmap32 in '..\NixLib.Bitmap32.pas',
  NixLib.Types in '..\NixLib.Types.pas',
  NixLib.Timing in '..\NixLib.Timing.pas',
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
  NixLib.SceneGraph in '..\NixLib.SceneGraph.pas',
  NixLib.Evaluator in '..\NixLib.Evaluator.pas';

type
  TTestLib = class
  public
    procedure Print(AValue: TValue);
  end;

procedure TTestLib.Print;
begin
  WriteLn(AValue.ToString);
end;

var
  N: TNamespace;
  L: TTestLib;
  E: String;

  S: TStatement;
  I: TIfStatement;
begin
  N := TNamespace.Create;
  L := TTestLib.Create;

  N.Variables.Declare('TestLib', L);

  S := TStatement.Create;
  S.Expression := 'Declare("A", 123)';
  N.AddStatement(S);

  S := TStatement.Create;
  S.Expression := 'TestLib.Print(A)';
  N.AddStatement(S);

  I := TIfStatement.Create;
  I.Condition := 'A==123';
  N.AddStatement(I);

  S := TStatement.Create;
  S.Expression := 'Declare("A", 0)';
  I.FFalseStatements.Namespace.AddStatement(S);

  S := TStatement.Create;
  S.Expression := 'A="Nope")';
  I.FFalseStatements.Namespace.AddStatement(S);

  S := TStatement.Create;
  S.Expression := 'TestLib.Print(A)';
  I.FFalseStatements.Namespace.AddStatement(S);

  S := TStatement.Create;
  S.Expression := 'Declare("A", 0)';
  I.FTrueStatements.Namespace.AddStatement(S);

  S := TStatement.Create;
  S.Expression := 'A="Nope")';
  I.FTrueStatements.Namespace.AddStatement(S);

  S := TStatement.Create;
  S.Expression := 'TestLib.Print(A)';
  I.FTrueStatements.Namespace.AddStatement(S);

  S := TStatement.Create;
  S.Expression := 'TestLib.Print(A)';
  N.AddStatement(S);

  N.Execute;

  repeat
    try
      ReadLn(E);
      N.Evaluate(E);
    except
      on E: Exception do
      begin
        WriteLn(E.ClassName, ': ', E.Message);
      end;
    end;
  until False;
end.

