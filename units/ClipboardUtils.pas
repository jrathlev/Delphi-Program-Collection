(* Delphi-Unit
   Functions to read or write data from or to clipboard
   ====================================================

   - Read and write file lists (CF_HDROP)

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Created:        July 2025
   last modified:  July 2025
   *)

unit ClipboardUtils;

interface

uses System.SysUtils, System.Classes;

function ReadFileListFromClipboard (AFileList : TStrings) : boolean;
procedure WriteFileListToClipboard (AFileList : TStrings);
function GetDropList (HDrop : THandle; AList : TStrings) : integer;

implementation

uses Winapi.Windows, WinApi.ShlObj, WinApi.ShellApi, Vcl.ClipBrd;

function GetDropList (HDrop : THandle; AList : TStrings) : integer;
var
  i,sz : integer;
  fn : PChar;
begin
  fn:=nil;
  Result:= DragQueryFile(HDrop,$FFFFFFFF,fn,255);
  if Result>0 then begin
    for i:=0 to Result-1 do begin
      sz:=DragQueryFile(HDrop,i,nil,0) + 1;
      fn:=StrAlloc(sz);
      DragQueryFile(HDrop,i,fn,sz);
      AList.Add(fn);
      StrDispose(fn);
      end;
    end;
  end;

function ReadFileListFromClipboard (AFileList : TStrings) : boolean;
var
  mh    : THandle;
begin
  if ClipBoard.HasFormat(CF_HDROP) then begin
    mh:=Clipboard.GetAsHandle(CF_HDROP);
    Result:=GetDropList(mh,AFileList)>0;
    end
  else Result:=false;
  end;

procedure WriteFileListToClipboard (AFileList : TStrings);
var
  s : string;
  i : integer;
  df : PDropFiles;
  mh : THandle;
begin
  s:='';
  for i:=0 to AFileList.Count-1 do s:=s+AFileList[i]+#0;
  s:=s+#0;
  mh:=GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,SizeOf(TDropFiles)+ByteLength(s));
  try
    df:=GlobalLock(mh);
    df.pFiles:=SizeOf(TDropFiles);
    df.fWide:=true;
    Move(s[1],(PByte(df)+SizeOf(TDropFiles))^,ByteLength(s));
  finally
    GlobalUnlock(mh);
    end;
  Clipboard.SetAsHandle(CF_HDROP,mh);
  end;

end.
