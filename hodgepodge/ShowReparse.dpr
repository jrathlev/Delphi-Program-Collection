(* Delphi program
   show a list of all reparse points in a directory
   ================================================
   
   https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/c8e77b37-3909-4fe6-a4ea-2b9d423b1ee4

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Calling: showreparse.exe [<directory>]

   Vers. 1 - August 2025
   *)

program ShowReparse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows, System.SysUtils, ExtSysUtils, FileUtils, StringUtils;

var
  dir,fn,s,
  LinkPath   : string;
  DirInfo    : TSearchRec;
  FindResult : integer;
  res        : dword;
  surr,msbit  : boolean;

const
//  JunctionType : array[TReparseType] of string = ('','Junction','Symbolic');
  SMask = $20000000;  // Name Surrogate bit
  MMask = $80000000;  // Microsoft bit 
  CMask = $9000001A;  // Cloud File

function BoolStr(b : boolean) : string;
begin
  if b then Result:='X' else Result:=' ';
  end;

// Check for special directories ('.'=self and '..'=one up )
function NotSpecialDir (const Name : string) : boolean;
var
  i : integer;
begin
  Result:=(Name<>'.') and (Name<>'..');
  end;


begin
  if ParamCount>0 then dir:=ParamStr(1)
  else dir:=GetCurrentDir;
  writeln ('Show reparse points');
  writeln ('===================');
  writeln ('Directory: "',dir,'"');
  writeln;
  writeln('Name                  Type          M S  Path');
  writeln('----------------------------------------------------');
  FindResult:=FindFirst((Dir)+'*.*',faAnyFile,DirInfo);
  while FindResult=0 do with DirInfo do begin
    if NotSpecialDir(Name) then begin
      if((Attr and FILE_ATTRIBUTE_REPARSE_POINT)<>0) then begin
        fn:=IncludeTrailingPathDelimiter(Dir)+Name;
        res:=FindData.dwReserved0;
        if Res and CMask = CMask then begin
          surr:=false; msbit:=false;
          res:=(res and $F000) div $1000;
          s:=Format('Cloud %.1x',[res]);
          end
        else begin
          surr:=res and SMask <>0;
          msbit:=res and MMask <>0;
          res:=res and $FF;
          case res of
          $03  : s:='Junction';
          $04  : s:='HSM';
          $05  : s:='DriveExt';
          $06  : s:='HSM2';
          $07  : s:='SIS';
          $08  : s:='WIM';
          $09  : s:='CSV';
          $0A  : s:='DFS';
          $0B  : s:='FiltMan';
          $0C  : s:='Symbolic';
          $10  : s:='CACHE';
          $12  : s:='DFSR';
          $13  : s:='DEDUP';
          $14  : s:='NFS';
          $15  : s:='FPH';
          $16  : s:='DFM';
          $17  : s:='WOF';
          $18  : s:='WCI';
          $19  : s:='GlobalRep';
          $1B  : s:='AppExeLink';
          $1C  : s:='PROJFS';
          $1D  : s:='WSL-Link';
          $1E  : s:='StgSync';
          $1F  : s:='WCI-Tombstone';
          $22  : s:='ProfTombstone';
          $23  : s:='Unix';
          $24  : s:='UnixFifo';
          $25  : s:='WSL-Char';
          $26  : s:='WSL-Block';
          $27  : s:='WCI-Link';
          $1027  : s:='WCI-Link-1';
          else s:=Format('Unknown (0x%.4x)',[res]);
            end;
          end;
        LinkPath:=GetLinkPath(fn);
        writeln(ExtSp(Name,22),ExtSp(s,14),BoolStr(msbit),' ',BoolStr(surr),'  ',LinkPath);
        end;
      end;
    FindResult:=FindNext (DirInfo);
    end;
  FindClose(DirInfo);
{$ifdef DEBUG}
  WaitForAnyKey;
{$endif}

end.
