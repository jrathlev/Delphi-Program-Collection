(* Delphi unit
   Grahic conversions
   ==================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1.0 - September 2024
   last modified: September 2024
   *)

unit GraphUtils;

interface

uses System.SysUtils, Winapi.Windows, System.Classes;

function CreateIconFromPngStreamList(const IconFile : string; PngList : TList) : boolean;
function CreateIconFromPngFileList(const IconFile : string; PngList : TStringList) : boolean;

implementation

uses Vcl.Graphics, Vcl.Imaging.PngImage;

type
  TIconHeader = packed record
    wReserved,wImgType,wImgCount : word;
    end;

  TIconDirEntry = packed record
    bWidth,bHeight,bColors,bReserved : byte;
    wPlanes,wBits : word;
    cSize,cOffset : cardinal;
    end;

const
  defBlockSize = 256*1024;
  defIconHeader : TIconHeader = (wReserved : 0; wImgType : 1; wImgCount : 1);
  defIconDirEntry : TIconDirEntry = (bWidth : 0; bHeight : 0; bColors : 32; bReserved : 0;
    wPlanes : 0; wBits : 0; cSize : 0; cOffset : 0);

function CopyStream (ss,sd : TStream) : boolean;
var
  nr,nw : integer;
  FBuffer : array of byte;
begin
  SetLength(FBuffer,defBlockSize);
  repeat
    nr:=ss.Read(FBuffer[0],defBlockSize);
    nw:=sd.Write(FBuffer[0],nr);
    Result:=nr=nw;
    until (nr<defBlockSize) or not Result;
  FBuffer:=nil;
  end;

function CreateIconFromPngStreamList(const IconFile : string; PngList : TList) : boolean;
// refer to: https://en.wikipedia.org/wiki/ICO_(file_format)
// and https://devblogs.microsoft.com/oldnewthing/20101018-00/?p=12513
var
  fi      : TFileStream;
  fp,fm   : TMemoryStream;
  sn,sp,s : string;
  m       : integer;
  dh      : cardinal;
  ih      : TIconHeader;
  ide     : TIconDirEntry;
  ip      : int64;
  PngImg  : TPngImage;
  bp      : TBitMap;
const
  BmHeaderSize = sizeof(TBitmapFileHeader);
  BmInfoSize = sizeof(TBitmapInfoHeader);
  HeightOffs =  8; // Offset of height info
begin
  Result:=false;
  fi:=TFileStream.Create(IconFile,fmCreate);
  try
    ih:=defIconHeader;
    ih.wImgCount:=PngList.Count;
    fi.Write(ih,sizeof(TIconHeader));
    ide:=defIconDirEntry;
    for m:=0 to PngList.Count-1 do fi.Write(ide,sizeof(TIconDirEntry));  // reserve space
    for m:=0 to PngList.Count-1 do begin
      PngImg:=TPngImage.Create;
      PngImg.LoadFromStream(TStream(PngList[m]));
      bp:=TBitMap.Create;
      bp.Assign(PngImg);
      PngImg.Free;
      fp:=TMemoryStream.Create; bp.SaveToStream(fp);
      bp.Mask(bp.TransparentColor);
      fm:=TMemoryStream.Create; bp.SaveToStream(fm);
      with ide do begin
        bWidth:=bp.Width and $FF; bHeight:=bp.Height and $FF;
        cSize:=fp.Size+fm.Size-2*BmHeaderSize-BmInfoSize; cOffset:=fi.Position;
        dh:=2*bp.Height;
        end;
      bp.Free;
      ip:=fi.Position;
      fi.Position:=sizeof(TIconHeader)+m*sizeof(TIconDirEntry);
      fi.Write(ide,sizeof(TIconDirEntry));  // write updated dir entry
      fi.Position:=ip;
      fp.Position:=BmHeaderSize+HeightOffs;
      fp.Write(dh,sizeof(cardinal));   // set to twice the height
      fp.Position:=BmHeaderSize;
      fm.Position:=BmHeaderSize+BmInfoSize+2*sizeof(TRGBQuad);
      try
        Result:=CopyStream(fp,fi);
        if Result then Result:=CopyStream(fm,fi);
      finally
        fp.Free; fm.Free;
        end;
      end;
  finally
    fi.Free;
    end;
  end;

function CreateIconFromPngFileList(const IconFile : string; PngList : TStringList) : boolean;
var
  lPng    : TList;
  sPng    : TFileStream;
  m       : integer;

  procedure FreeList (AList : TList);
  var
    i : integer;
  begin
    with AList do begin
      for i:=0 to Count-1 do if assigned(Items[i]) then begin
        try TObject(Items[i]).Free; except end;
        Items[i]:=nil;
        end;
      Clear;
      end;
    end;

begin
  lPng:=TList.Create;
  for m:=0 to PngList.Count-1 do begin
    sPng:=TFileStream.Create(PngList[m],fmOpenRead);
    sPng.Position:=0;
    lPng.Add(sPng);
    end;
  Result:=CreateIconFromPngStreamList(IconFile,lPng);
  FreeList(lPng);
  lPng.Free;
  end;

end.
