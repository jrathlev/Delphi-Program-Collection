(* Delphi program
   Show Windows license key
   ========================
   Code partially from:
   http://blog.bigbasti.com/windows-lizenzschlussel-aus-der-registry-auslesen/
   Note: The web site does not seem to exist anymore

   © Dr. J. Rathlev, D-24222 Schwentinental (pb(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - October 2025
   *)

program WinKey;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, Winapi.Windows, System.Win.Registry,
  SystemInfo, ExtSysUtils;

resourcestring
  rsCompName     = 'Computername        : ';
  rsLicenseOwner = 'License owner       : ';
  rsProductID    = 'Product ID          : ';
  rsProductKey   = 'Product key         : ';
  rsBackupKey    = 'Backup product key  : ';
  rsNoKeyFound   = 'Product key could not be read!';

const
  KeyName = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion';
  SubKeyName = '\SoftwareProtectionPlatform';
  charsArray : array [0..23] of AnsiChar =
    ('B','C','D','F','G','H','J','K','M','P','Q','R','T','V','W','X','Y','2','3','4','6','7','8','9');

//  Win8Key : array [0..14] of byte = ($28,$0A,$B0,$C2,$09,$38,$B8,$60,$BF,$0C,$BF,$48,$64,$97,$08);

type
  TComputer = record
    CompName,ProductName,ServicePack,BuildNr,ProductId,Owner : string;
    end;

function ComputerName : string;
var
  p : pchar;
  size : dword;
begin
  size:=1024;
  p:=StrAlloc(size);
  GetComputerName (p,size);
  Result:=p;
  Strdispose(p);
  end;

var
  data : array of byte;
  binArray : array [0..14] of byte;
  n,i,j,k : integer;
  ProductKey,BPKey,
  ProductId,Owner,sv : string;
  s : AnsiString;
  ok,IsWin8  : boolean;
begin
  ok:=false; BPKey:='';
  with TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY) do begin
    RootKey:=HKEY_LOCAL_MACHINE;
    if OpenKeyReadOnly(KeyName) then begin
      ProductId:=ReadString('ProductId');
      Owner:=ReadString('RegisteredOwner');
      n:=GetDataSize('DigitalProductId');
      if n>0 then begin
        SetLength(data,n);
        i:=ReadBinaryData('DigitalProductId',data[0],n);
        ok:=i=n;
        end;
      end;
    CloseKey;
    if OpenKeyReadOnly(KeyName+SubKeyName) then begin
      BPKey:=ReadString('BackupProductKeyDefault');
      end;
    CloseKey;
    Free;
    end;
  sv:=GetOSVersionAsText;
  ProductKey:='';
  if ok then begin
    s:='';
    for i:=0 to 14 do begin
      binArray[i]:=data[i+52]; // Win8Key[i];
      end;
    IsWin8:=binArray[14] div 6 and 1 <>0;    // Windows 8
    binArray[14]:=(binArray[14] and $F7);// or 4*(i and 2); ???
    for i:=24 downto 0 do begin
      k:=0;
      for j:=14 downto 0 do begin
        k:=256*k xor binArray[j];
        binArray[j]:=k div 24;
        k:=k mod 24;
        end;
      s:=charsArray[k]+s;
      end;
    if IsWin8 then s:=copy(s,2,k)+'N'+copy(s,k+2,length(s)-k);
    for i:=1 to 25 do begin
      productKey:=productKey+s[i];
      if (i mod 5=0) and (i<25) then productKey:=productKey+'-';
      end;
    end;
  writeln(sv);
  writeln(rsCompName,ComputerName);
  writeln(rsLicenseOwner,Owner);
  writeln(rsProductID,ProductId);
  if ok then writeln(rsProductKey,ProductKey)
  else writeln(rsNoKeyFound);
  writeln(rsBackupKey,BPKey);
  writeln;
{$ifdef DEBUG}
  WaitForAnyKey;
{$endif}
end.
