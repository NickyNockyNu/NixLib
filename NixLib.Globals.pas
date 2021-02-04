{
  NixLib.Globals.pas

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

unit NixLib.Globals;

interface

const AppPlatform = {$IFDEF MSWINDOWS}'Windows'{$ELSEIF DEFINED(IOS)}'iOS'{$ELSEIF DEFINED(ANDROID)}'Android'{$ELSEIF DEFINED(MACOS)}'Mac OS'{$ELSEIF DEFINED(LINUX)}'Linux'{$ELSE}'Undefined Platform'{$ENDIF};
const AppCPU      = {$IFDEF CPUX86}'IA32'{$ELSEIF DEFINED(CPUX64)}'IA64'{$ELSEIF DEFINED(ARM32)}'ARM32'{$ELSEIF DEFINED(ARM64)}'ARM64'{$ELSE}'Undefined CPU'{$ENDIF};

var AppName:       String  = '';
var AppVersionNum: Single  = 0.1;
var AppVersionStr: String  = '0.1 alpha';
var AppRegistered: String  = '';
var AppDebug:      Boolean = False;

var
  DisableEffects: Boolean = False;

implementation

end.

