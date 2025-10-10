(* Delphi program
   Change "last modified" hint in source files
   ===========================================

   © Dr. J. Rathlev, D-24222 Schwentinental (pb(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - July 2025
   last modified: October 2025

   Calling: ChangeModHint <Directory> [options]
     Directory    : root directory (current if omitted)
     /f:<mask>    : scan for files matchint to <mask> (default = all)
     /e:<ext>     : scan for files with given extension (default = pas)
     /h:<hint>    : search for hint string (default = last modified:)
     /d:<date>    : set to given date (default = file date)
     /l:<en,de>   : language selection for date format
     /?           : show command line parameters
   *)

program ChangeModHint;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  System.StrUtils, WinApi.Windows, ExtsysUtils, StringUtils;

const
  PrgDesc = 'Change last modified hint in source files to current date';
  CopRgt = '© 2025 Dr. J. Rathlev, D-24222 Schwentinental';

  defExt = 'pas';
  defHint = 'last modified:';
var
  sd,s,se,sh,
  sf,la,st : string;
  hlp : boolean;
  fl  : TList<string>;
  i,j,n,cnt : integer;
  k  : word;
  sl : TStringList;
  fd : TDateTime;
  fs : TFormatSettings;
begin
  Writeln(PrgDesc); Writeln(CopRgt); writeln;
  sd:=GetCurrentDir; se:=defExt; sh:=defHint; la:='en'; st:=''; sf:='*';
  hlp:=false;
  if ParamCount>0 then for i:=1 to ParamCount do begin
    s:=ParamStr(i);
    if (s[1]='/') or (s[1]='-') then begin
      delete (s,1,1);
      if ReadOptionValue(s,'e') then se:=s
      else if ReadOptionValue(s,'f') then sf:=s
      else if ReadOptionValue(s,'h') then sh:=s
      else if ReadOptionValue(s,'d') then st:=s
      else if ReadOptionValue(s,'l') then la:=s
      else if CompareOption(s,'?') then hlp:=true;
      end
    else sd:=ExpandFileName(s);
    end;
  if hlp then begin
    writeln('Calling:');
    writeln('  ChangeModHint.exe <directory> [/<option> ...]');
    writeln('    directory  : root directory (current if omitted)');
    writeln('    no option  : scan all "pas" files for "last modified:"');
    writeln('    /f:<mask>  : scan for files matching to <mask> (default = all)');
    writeln('    /e:<ext>   : scan only files with given extension');
    writeln('    /h:<hint>  : search for given string as hint');
    writeln('    /d:<date>  : Set to given date (default = file date');
    writeln('    /l:<en,de> : language selection for date format');
    writeln('Example: ChangeModHint.exe C:\Programs\Sources /e:js');
    end
  else begin
    if AnsiStartsText('d',la) then fs:=TFormatSettings.Create('de')
    else fs:=TFormatSettings.Create('en-US');
    sh:=AnsiUppercase(sh); cnt:=0;
    fl:=TList<string>.Create;
    fl.AddRange(TDirectory.GetFiles(sd,sf+'.'+se,TSearchOption.soTopDirectoryOnly));
//    for i:=0 to fl.Count-1 do writeln(fl[i]);
    writeln('Directory: ',sd);
    write(Format('%u source files found - continue (c) or cancel (esc)?',[fl.Count]));
    k:=ReadKey; writeln;
    if (k=ord('c')) or (k=ord('C')) then begin
      sl:=TStringList.Create;
      for i:=0 to fl.Count-1 do begin
        sf:=fl[i];
        sl.LoadFromFile(sf);
        fd:=TFile.GetLastWriteTime(sf);
        if st.IsEmpty then st:=FormatDateTime('mmmm yyyy',fd,fs);
        for j:=0 to sl.Count-1 do begin
          n:=AnsiPos(sh,AnsiUppercase(sl[j]));
          if n>0 then Break;
          end;
        if j<sl.Count then begin
          s:=copy(sl[j],1,n-1+length(sh))+' '+st;
//          writeln('  ',j+1:3,': ',s,' - ',sl[j]);
          if not AnsiSameText(sl[j],s) then begin
            writeln(Format('File: %s - changed (%s)',[sf,st]));
            sl[j]:=s;
            sl.SaveToFile(sf);
            TFile.SetLastWriteTime(sf,fd);
            inc(cnt);
            end;
          end;
        end;
      sl.Free;
      if cnt>0 then writeln(Format('%u files updated!',[cnt]))
      else writeln('All files are up to date!');
      end;
    fl.Free;
    end;

  WaitForAnyKey;
end.
