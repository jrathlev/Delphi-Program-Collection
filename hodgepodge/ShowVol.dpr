(* Delphi program
   Show all available volumes
   ==========================

   © Dr. J. Rathlev, D-24222 Schwentinental (pb(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - May 2018
   last modified: January 2021

   Calling: ShowVol [VolName]
     no Argument: show all available volumes
     [VolName]  : show drive letter or volume GUID associated with VolName
   *)

program ShowVol;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, Winapi.Windows, WinDevUtils, NumberUtils, ExtSysUtils;

function GetDriveForVolume (const VolName : string; var DriveName : string;
  OnlyMounted : boolean = false) : HResult;
var
  VolHandle   : THandle;
  Buf         : array [0..MAX_PATH+1] of Char;
  VolumeId,
  VName       : string;
  n,cl,sf     : cardinal;
begin
  Result:=NO_ERROR;
  VolHandle:=FindFirstVolume(Buf,length(Buf));
  if VolHandle=INVALID_HANDLE_VALUE then Result:=GetLastError
  else begin
    repeat
      VolumeId:=Buf;
      if GetVolumePathNamesForVolumeName(PChar(VolumeId),Buf,length(Buf),n) then begin
        DriveName:=Buf;
        if GetVolumeInformation(pchar(VolumeId),Buf,length(Buf),nil,cl,sf,nil,0) then begin
          VName:=Buf;
          if AnsiSameText(VolName,VName) then begin
            if (length(DriveName)=0) then begin
              if OnlyMounted then DriveName:=''
              else DriveName:=VolumeId;
              end;
            Break;
            end
          else DriveName:='';
          end
        else begin
          Result:=GetLastError;
          if Result=ERROR_NOT_READY then DriveName:=''
          else Break;
          end;
        end
      else begin
        Result:=GetLastError; Break;
        end;
      until not FindNextVolume(VolHandle,Buf,length(Buf));
    end;
  FindVolumeClose(VolHandle);
  if length(DriveName)=0 then Result:=ERROR_NO_VOLUME_LABEL;
  end;

function DriveForVolume (const VolName : string; OnlyMounted : boolean = false) : string;
begin
  GetDriveForVolume(VolName,Result,OnlyMounted);
  end;

function CheckValue (const Value: string) : string;
begin
  if length(Value)>0 then Result:=Value else Result:='Unknown';
  end;

procedure WriteInfo (const mn : string);
var
  MaximumComponentLength: DWORD;
  VolumeSerialNumber,
  Flags: DWORD;
  sBuf,FileSystem: array [0..MAX_PATH] of Char;
  vn,fs      : string;
  fsFlags    : TFileSystemFlags;
  fl         : TFileSystemFlag;
begin
  if GetVolumeInformation(PChar(mn),sBuf,SizeOf(sBuf),@VolumeSerialNumber,
    MaximumComponentLength,Flags,FileSystem,SizeOf(FileSystem)) then begin
    vn:=sBuf; fs:=FileSystem;
    writeln('Volume name      : ',vn);
    writeln('Volume #         : ',IntToHex(HiWord(VolumeSerialNumber),4)+'-'+IntToHex(LoWord(VolumeSerialNumber),4));
    writeln('Size             : ',SizeToStr(GetDiskFree(mn))+' free of '+SizeToStr(GetDiskTotal(mn)));
    writeln('Max comp. length : ',MaximumComponentLength);
    writeln('Drive type       : ',DriveTypeNames[DriveType(mn)]);
    writeln('Bus type         : "',BusNames[GetBusType(mn)],'"');
    writeln('File system      : "',CheckValue(fs),'"');
    fsFlags:=GetFileSystemAttributes(Flags);
    writeln('System flags     : ');
    for fl:=Low(TFileSystemFlag) to High(TFileSystemFlag) do if fl in fsFlags then
      writeln('  ',FileSystemFlagDesc[fl]);
    end
  else writeln('GetVolumeInformation failed: ',SysErrorMessage(GetLastError));
  end;

var
  VolHandle   : THandle;
  sBuf : array [0..MAX_PATH] of Char;
  MountName,
  VolumeName,
  DeviceName,
  VolumeId   : string;
  ok         : boolean;
  n,
  CharCount  : dword;
begin
  if ParamCount=0 then begin
    VolHandle:=FindFirstVolume(sBuf,length(sBuf));
    if VolHandle=INVALID_HANDLE_VALUE then
      writeln ('FindFirstVolume failed: ',SysErrorMessage(GetLastError))
    else begin
      repeat
        VolumeId:=sBuf;
        if QueryDosDevice(pchar(copy(VolumeId,5,length(VolumeId)-5)),sBuf,length(sBuf))>0 then begin
          DeviceName:=sBuf;
          writeln ('Device name      : ',DeviceName);
          writeln ('Volume GUID      : ',VolumeId);
          end
        else writeln('QueryDosDevice failed: ',SysErrorMessage(GetLastError));
        if GetVolumePathNamesForVolumeName(PChar(VolumeId),sBuf,length(sBuf),CharCount) then begin
          MountName:=sBuf;
          if length(MountName)=0 then MountName:='not mounted';
          writeln ('Mount point      : ',MountName);
          end
        else writeln('GetVolumePathNamesForVolumeName failed: ',SysErrorMessage(GetLastError));
        WriteInfo(VolumeId);
//      WriteInfo(MountName);
        writeln;
        ok:=FindNextVolume(VolHandle,sBuf,length(sBuf));
        until not ok;
      FindVolumeClose(VolHandle);
      end;
    end
  else begin
    VolumeName:=ParamStr(1);
    if length(VolumeName)>0 then begin
      if pos(':',VolumeName)>0 then begin
        writeln ('Mount point      : ',VolumeName);
        WriteInfo(IncludeTrailingPathDelimiter(VolumeName));
        end
      else begin
        n:=GetDriveForVolume(VolumeName,MountName);
        if (n=NO_ERROR) then begin
          if AnsiSameText(copy(MountName,1,4),'\\?\') then begin
            writeln ('Volume "',VolumeName,'" is available but not mounted');
            writeln ('Volume GUID: "',MountName,'"');
            WriteInfo(MountName);
            end
          else begin
            writeln ('Volume "',VolumeName,'" is mounted as "',MountName,'"');
            WriteInfo(MountName);
            end;
          end
        else if n=ERROR_NO_VOLUME_LABEL then writeln ('Volume not found: "',VolumeName,'"')
        else writeln('Error on Volume "',VolumeName,'" - ',SysErrorMessage(GetLastError));
        end
      end;
    end;
{$ifdef DEBUG}
  WaitForAnyKey;
{$endif}
end.
