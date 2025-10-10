(* Delphi Unit
   procedures and functions for file and directory processing
   with prefix to allow extended-length pathnames (>= MAX_PATH)
   ============================================================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Version 1.0 - Feb. 2009 (UnicodeUtils)
           1.1 - May  2010
           2.0 - Jan. 2016: unit renamed, Unicode routines moved to FileUtils
                            adapted to Delphi 10
   last updated: Feb. 2017
   *)

unit XlFileUtils;

interface

uses WinApi.Windows, System.Classes, System.SysUtils, FileUtils;

{ ------------------------------------------------------------------- }
// Function to add prefix to full path if pathlength >= MAX_PATH = 260
function FilenameToXL(const FileName : string) : string;

{ ------------------------------------------------------------------- }
function ForceDirectoriesXL(const DirName : string) : boolean;
function IsEmptyDirXL(const Directory : string) : boolean;
function DirectoryExistsXL(Directory : string; FollowLink: Boolean = True) : boolean;
function RemoveDirXL(const DirName : string) : integer; overload;
function RemoveDirXL(const DirName : string; DelReadOnly : boolean) : integer; overload;
function RemoveEmptyDirXL(const DirName : string; DelReadOnly : boolean = false) : integer;
procedure DeleteEmptyDirectoriesXL(const Directory : string);
function FileExistsXL(const FileName : string; FollowLink: Boolean = True) : boolean;
function FileNotFoundXL (const FileName : string) : boolean;
function DeleteFileXL(const FileName : string; DelReadOnly : boolean = false) : integer;
function DeleteExistingFileXL(const Filename : string; DelReadOnly : boolean = false) : integer;
function EraseFileXL(const FileName : string; DelReadOnly : boolean = false) : boolean;
function RenameFileXL(const OldName,NewName : string) : integer; overload;
function RenameFileXL(const OldName,NewName : string; Attr : integer) : integer; overload;
function ExpandFileNameXL(const FileName: string): string;

function LongFileSizeXL(const FileName : string) : int64;

function FileGetAttrXL(const FileName: string; FollowLink: Boolean = True): Integer;
function FileSetAttrXL(const FileName: string; Attr: Integer; FollowLink: Boolean = True): Integer;
function FileChangeAttrXL(const FileName: string; Attr: Integer; Clear : boolean;
                          FollowLink: Boolean = True): Integer;

function IsFileReadOnlyXL (const fName : string) : boolean;
function IsFileInUseXL (const fName : string) : boolean;

function GetFileInfoXL(const FileName : string; var FileInfo : TFileInfo) : boolean;
function GetFindDataXL(FileName : string; var FileData : TWin32FindData) : boolean;

function GetFileAttrDataXL(const FileName : string; var FileData : TWin32FileAttributeData;
                     FollowLink: Boolean = True) : integer;

function GetFileLastWriteTimeXL(const FileName: string): TFileTime;
function GetFileLastWriteDateTimeXL(const FileName: string): TDateTime;
function SetFileLastWriteDateTimeXL(const FileName: string; FileTime : TDateTime) : integer;
function GetFileDateTimeXL(const FileName: string; FollowLink : Boolean = True): TDateTime;
function FileAgeXL(const FileName: string; Default : double) : TDateTime;
function SetFileAgeXL(const FileName: string; Age: Integer; FollowLink : Boolean = True): Integer; overload;
function SetFileAgeXL(const FileName: string; Age: FileTime; FollowLink : Boolean = True): Integer; overload;
function GetFileTimestampsXL(const FileName: string; FollowLink: Boolean = True): TFileTimestamps;
function GetDirTimestampsXL(const DirName : string; FollowLink : Boolean = True): TFileTimestamps;
function SetFileTimestampsXL(const FileName: string; Timestamps : TFileTimestamps;
                            CheckTime,SetCreationTime : boolean; FollowLink : Boolean = True) : integer;
function SetDirTimestampsXL(const Dir: string; Timestamps : TFileTimestamps;
                             CheckTime,SetCreationTime : boolean) : integer;

function SetTimestampAndAttrXL(const FileName : string; SearchRec : TSearchRec) : integer;

function DirectoryAgeXL(const FileName: string; Default : double) : TDateTime;
function GetDirectoryDateTimeXL(const FileName: string; FollowLink : Boolean = True): TDateTime;

function CheckForReparsePointXL(const Path : string; Attr : integer;
                               var LinkPath : string; var RpType : TReparseType) : boolean;
function IsReparsePointXL(const Path : string) : boolean; overload;
function IsReparsePointXL(Attr : integer) : boolean; overload;
function CreateJunctionXL(const Source,Destination : string): integer;

{ ------------------------------------------------------------------- }
// Copy file without timestamp and attributes *)
function CopyFileDataXL (const SrcFilename,DestFilename : string;
                         BlockSize : integer = defBlockSize): cardinal;

// Copy file with timestamp and attributes *)
procedure CopyFileXL (const SrcFilename,DestFilename : string;
                      AAttr : integer = -1; BlockSize : integer = defBlockSize);

                       // Copy files from one directory to another
function CopyFilesXL (const FromDir,ToDir,AMask : string; OverWrite : boolean) : boolean;

// Copy file permissions (ACL)
function CopyFileAclXL (const SrcFilename,DestFilename : String) : cardinal;

// Copy alternate file streams
function CopyAlternateStreamsXL (const SrcFilename,DestFilename : string): cardinal;

{ ------------------------------------------------------------------- }
function DeleteMatchingFilesXL(const APath,AMask : string) : integer;
function DeleteOlderFilesXL(const APath,AMask : string; ADate : TDateTime) : integer;
procedure CountFilesXL(const Base,Dir : string; IncludeSubDir : boolean;
                      var FileCount : integer; var FileSize : int64);
procedure DeleteDirectoryXL(const Base,Dir        : string;
                           DeleteRoot               : boolean;
                           var DCount,FCount,ECount : cardinal);

{ ---------------------------------------------------------------- }
// prüfen, ob auf ein Verzeichnis zugegriffen werden  kann
function CanAccessXL (const Directory : string; var ErrorCode : integer) : boolean; overload;
function CanAccessXL (const Directory : string) : boolean; overload;

{ ------------------------------------------------------------------- }
function FindFirstXL(const Path: string; Attr: Integer; var F: TSearchRec) : Integer;

implementation

uses PathUtils;

const
  MaxPathLength = 248;  // limit from CreateDirectory (see Windsows SDK)

{ ------------------------------------------------------------------- }
function FilenameToXL(const FileName : string) : string;
begin
  if (copy(FileName,1,2)='\\') then begin
    if (copy(FileName,3,2)='?\') then Result:=FileName               // has already prefix
    else Result:='\\?\UNC\'+Copy(Filename,3,length(Filename)-2);     // network
    end
  else if ((length(FileName)>1) and (FileName[2]<>':')) then Result:=Filename // relative path                                                // relative path
  else if length(FileName)>=MaxPathLength then Result:='\\?\'+FileName  // add prefix
  else Result:=FileName;                                           // let unchanged
  end;

{ ------------------------------------------------------------------- }
function ForceDirectoriesXL(const DirName : string) : boolean;
begin
  Result:=ForceDirectories(FilenameToXL(DirName));
  end;

function RemoveDirXL(const DirName : string) : integer;
begin
  if RemoveDirectory(PChar(FilenameToXL(DirName))) then Result:=NO_ERROR
  else Result:=GetLastError;
  end;

function RemoveDirXL(const DirName : string; DelReadOnly : boolean) : integer;
begin
  if DelReadOnly then Result:=FileChangeAttrXL(DirName,faReadOnly,true,false)
  else Result:=NO_ERROR;
  if Result=NO_ERROR then Result:=RemoveDirXL(DirName);
  end;

function DirectoryExistsXL(Directory : string; FollowLink: Boolean = True) : boolean;
begin
  Result:=DirectoryExists(FilenameToXL(Directory),FollowLink);
  end;

// Check if directory is empty
function IsEmptyDirXL(const Directory : string) : boolean;
begin
  Result:=IsEmptyDir(FilenameToXL(Directory));
  end;

// Delete empty directories
procedure DeleteEmptyDirectoriesXL(const Directory : string);
begin
  DeleteEmptyDirectories(FilenameToXL(Directory));
  end;

function RemoveEmptyDirXL(const DirName : string; DelReadOnly : boolean = false) : integer;
begin
  if IsEmptyDirXL(DirName) then begin
    if DelReadOnly then Result:=FileChangeAttrXL(DirName,faReadOnly,true,false)
    else Result:=NO_ERROR;;
    if Result=NO_ERROR then Result:=RemoveDirXL(DirName);
    end
  else Result:=ERROR_DIR_NOT_EMPTY ;
  end;

{ ------------------------------------------------------------------- }
function FileExistsXL(const FileName : string; FollowLink: Boolean = True) : boolean;
begin
  Result:=FileExists(FilenameToXL(FileName),FollowLink);
  end;

function FileNotFoundXL (const FileName : string) : boolean;
begin
  Result:=FileNotFound(FilenameToXL(FileName));
  end;

function DeleteFileXL(const FileName : string; DelReadOnly : boolean = false) : integer;
begin
  if DelReadOnly then Result:=FileChangeAttrXL(Filename,faReadOnly,true,false)
  else Result:=NO_ERROR;
  if Result=NO_ERROR then begin
    if DeleteFile(PChar(FilenameToXL(FileName))) then Result:=NO_ERROR
    else Result:=GetLastError;
    end;
  end;

function DeleteExistingFileXL(const Filename : string; DelReadOnly : boolean) : integer;
begin
  if FileExistsXL(Filename) then Result:=DeleteFileXL(Filename,DelReadOnly)
  else Result:=NO_ERROR;
  end;

function EraseFileXL(const FileName : string; DelReadOnly : boolean = false) : boolean;
begin
  Result:=DeleteFileXL(FileName,DelReadOnly)=NO_ERROR;
  end;

function RenameFileXL(const OldName,NewName : string) : integer;
begin
  if RenameFile(FilenameToXL(OldName),FilenameToXL(NewName)) then Result:=NO_ERROR
  else Result:=GetLastError;
  end;

// Result = 0 : ok
//        > 0 : sytem error code - rename failed
//        < 0 : sytem error code - set attribute failed
function RenameFileXL(const OldName,NewName : string; Attr : integer) : integer;
begin
  Result:=RenameFileXL(OldName,NewName);
  if Result=NO_ERROR then Result:=-FileSetAttrXL(NewName,Attr,true);
  end;

function ExpandFileNameXL(const FileName: string): string;
var
  FName: PChar;
  Buffer: array[0..32767] of Char;
  Len: Integer;
begin
  Len:=GetFullPathName(PChar(FilenameToXL(FileName)), Length(Buffer), Buffer, FName);
  if Len <= Length(Buffer) then SetString(Result, Buffer, Len)
  else if Len > 0 then begin
    SetLength(Result,Len);
    Len := GetFullPathName(PChar(FilenameToXL(FileName)), Len, PChar(Result),FName);
    if Len<Length(Result) then SetLength(Result,Len);
    end;
  end;

{ ------------------------------------------------------------------- }
// read file infos
function GetFileInfoXL(const FileName : string; var FileInfo : TFileInfo) : boolean;
begin
  Result:=GetFileInfo(FilenameToXL(FileName),FileInfo);
  end;

function GetFindDataXL(FileName : string; var FileData : TWin32FindData) : boolean;
begin
  Result:=GetFindData(FilenameToXL(FileName),FileData);
  end;

function GetFileAttrDataXL(const FileName : string; var FileData : TWin32FileAttributeData;
                     FollowLink: Boolean = True) : integer;
begin
  Result:=GetFileAttrData(FilenameToXL(FileName),FileData,FollowLink);
  end;

{ ------------------------------------------------------------------- }
function LongFileSizeXL(const FileName : string) : int64;
begin
  Result:=LongFileSize(FilenameToXL(FileName));
  end;

{ ------------------------------------------------------------------- }
function FileGetAttrXL(const FileName: string; FollowLink: Boolean = True): Integer;
begin
  Result:=FileGetAttr(FilenameToXL(FileName),FollowLink);
  end;

function FileSetAttrXL(const FileName: string; Attr: Integer; FollowLink: Boolean = True): Integer;
begin
  Result:=FileSetAttr(FilenameToXL(FileName),Attr and faChangeable,FollowLink);
  end;

// Clear = true  : clear given attributes
//       = false : set given attributes
function FileChangeAttrXL(const FileName: string; Attr: Integer; Clear : boolean;
                            FollowLink: Boolean = True) : Integer;
begin
  Result:=FileChangeAttr(FilenameToXL(FileName),Attr,Clear,FollowLink);
  end;

function IsFileReadOnlyXL (const fName : string) : boolean;
begin
  Result:=IsFileReadOnly(FilenameToXL(fName));
  end;

function IsFileInUseXL (const fName : string) : boolean;
begin
  Result:=IsFileInUse(FilenameToXL(fName));
  end;

{ ------------------------------------------------------------------- }
// get time (UTC) of last file write
function GetFileLastWriteTimeXL(const FileName: string): TFileTime;
begin
  Result:=GetFileLastWriteTime(FilenameToXL(FileName));
  end;

function GetFileLastWriteDateTimeXL(const FileName: string): TDateTime;
begin
  Result:=GetFileLastWriteDateTime(FileName);
  end;

function SetFileLastWriteDateTimeXL(const FileName: string; FileTime : TDateTime) : integer;
begin
  Result:=SetFileLastWriteDateTime(FileName,FileTime);
  end;

function GetFileDateTimeXL(const FileName: string; FollowLink : Boolean = True) : TDateTime;
begin
  Result:=GetFileDateTime(FilenameToXL(FileName),FollowLink);
  end;

function FileAgeXL(const FileName: string; Default : double) : TDateTime;
begin
  if not FileAge(FilenameToXL(FileName),Result,false) then Result:=Default;
  end;

function SetFileAgeXL(const FileName: string; Age: Integer; FollowLink : Boolean = True): Integer;
begin
  Result:=SetFileAge(FilenameToXL(FileName),Age,FollowLink);
  end;

function SetFileAgeXL(const FileName: string; Age: FileTime; FollowLink : Boolean = True) : Integer;
begin
  Result:=SetFileAge(FilenameToXL(FileName),Age,FollowLink);
  end;

function DirectoryAgeXL(const FileName: string; Default : double) : TDateTime;
begin
  if not DirectoryAge(FilenameToXL(FileName),Result,false) then Result:=Default;
  end;

function GetDirectoryDateTimeXL(const FileName: string; FollowLink : Boolean = True): TDateTime;
begin
  Result:=GetDirectoryDateTime(FilenameToXL(FileName),FollowLink);
  end;

// get file timestamps (UTC)
function GetFileTimestampsXL(const FileName : string; FollowLink : Boolean = True): TFileTimestamps;
begin
  Result:=GetFileTimestamps(FilenameToXL(FileName),FollowLink);
  end;

// get directory timestamps (UTC)
function GetDirTimestampsXL(const DirName : string; FollowLink : Boolean = True): TFileTimestamps;
begin
  Result:=GetDirTimestamps(FilenameToXL(DirName),FollowLink);
  end;

// set file or directory timestamps (UTC)
// CheckTime = true: Change FileTime to actual time if out of range
// SetCreationTime = true: Copy timestamp ftCreationTime
function SetFileTimestampsXL(const FileName: string; Timestamps : TFileTimestamps;
                             CheckTime,SetCreationTime : boolean; FollowLink : Boolean = True) : integer;
begin
  Result:=SetFileTimestamps(FilenameToXL(FileName),Timestamps,CheckTime,SetCreationTime,FollowLink);
  end;

function SetDirTimestampsXL(const Dir: string; Timestamps : TFileTimestamps;
                            CheckTime,SetCreationTime : boolean) : integer;
begin
  if IsRootPath(Dir) then Result:=NO_ERROR
  else Result:=SetFileTimestamps(FilenameToXL(Dir),Timestamps,CheckTime,SetCreationTime,false);
  end;

function SetTimestampAndAttrXL(const FileName : string; SearchRec : TSearchRec) : integer;
begin
  Result:=SetTimestampAndAttr(FilenameToXL(FileName),SearchRec);
  end;

{ ------------------------------------------------------------------- }
// Check if reparse point and return linked path
function CheckForReparsePointXL(const Path : string; Attr : integer;
                               var LinkPath : string; var RpType : TReparseType) : boolean;
begin
  Result:=CheckForReparsePoint (FilenameToXL(Path),Attr,LinkPath,RpType);
  end;

// Check for reparse point
function IsReparsePointXL(Attr : integer) : boolean;
begin
  Result:=IsReparsePoint(Attr);
  end;

function IsReparsePointXL(const Path : string) : boolean;
begin
  Result:=IsReparsePoint(FilenameToXL(Path));
  end;

function CreateJunctionXL(const Source,Destination : string): integer;
begin
  Result:=CreateJunction(FilenameToXL(Source),FilenameToXL(Destination));
  end;

{ ------------------------------------------------------------------- }
// Copy file without timestamp and attributes *)
function CopyFileDataXL (const SrcFilename,DestFilename : string;
                         BlockSize : integer = defBlockSize): cardinal;
begin
  Result:=CopyFileData(FilenameToXL(SrcFilename),FilenameToXL(DestFilename),BlockSize);
  end;

// Copy file with timestamp and attributes
// AAttr = -1: copy original attributes
procedure CopyFileXL(const SrcFilename,DestFilename : string;
                       AAttr : integer = -1; BlockSize : integer = defBlockSize);
begin
  CopyFileTS(FilenameToXL(SrcFilename),FilenameToXL(DestFilename),AAttr,BlockSize);
  end;

// Copy files from one directory to another
function CopyFilesXL(const FromDir,ToDir,AMask : string; OverWrite : boolean) : boolean;
begin
  Result:=CopyFilesXL(FilenameToXL(FromDir),FilenameToXL(ToDir),AMask,OverWrite);
  end;

function CopyFileAclXL (const SrcFilename,DestFilename : String) : cardinal;
begin
  Result:=CopyFileAcl(FilenameToXL(srcfilename),FilenameToXL(destfilename));
  end;

// Copy alternate file streams
function CopyAlternateStreamsXL (const SrcFilename,DestFilename : string) : cardinal;
begin
  Result:=CopyAlternateStreams(FilenameToXL(SrcFilename),FilenameToXL(DestFilename));
  end;

{ ---------------------------------------------------------------- }
// Delete all matching files in directory
function DeleteMatchingFilesXL(const APath,AMask : string) : integer;
begin
  Result:=DeleteMatchingFiles(FilenameToXL(APath),AMask);
  end;

function DeleteOlderFilesXL(const APath,AMask : string; ADate : TDateTime) : integer;
begin
  Result:=DeleteOlderFiles(FilenameToXL(APath),AMask,ADate);
  end;

// Dateien in einem Verzeichnis zählen und Gesamtgröße bestimmen
procedure CountFilesXL(const Base,Dir : string; IncludeSubDir : boolean;
                      var FileCount : integer; var FileSize : int64);
begin
  CountFiles(FilenameToXL(Base),Dir,IncludeSubDir,FileCount,FileSize);
  end;

// Lösche ein Verzeichnis einschließlich aller Unterverzeichnisse und Dateien
procedure DeleteDirectoryXL(const Base,Dir           : string;
                           DeleteRoot               : boolean;
                           var DCount,FCount,ECount : cardinal);
begin
  DeleteDirectory(FilenameToXL(Base),Dir,DeleteRoot,DCount,FCount,ECount);
  end;

{ ---------------------------------------------------------------- }
// prüfen, ob auf ein Verzeichnis zugegriffen werden  kann
function CanAccessXL (const Directory : string; var ErrorCode : integer) : boolean;
begin
  Result:=CanAccess(FilenameToXL(Directory),ErrorCode);
  end;

function CanAccessXL (const Directory : string) : boolean; overload;
var
  ec : integer;
begin
  Result:=CanAccessXL(Directory,ec);
  end;

{ ------------------------------------------------------------------- }
function FindFirstXL(const Path: string; Attr: Integer; var F: TSearchRec) : Integer;
begin
  Result:=FindFirst(FilenameToXL(Path),Attr,F);
  end;

end.
