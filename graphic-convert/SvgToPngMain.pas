(* Convert svg images to transparent png

   © Dr. J. Rathlev, D-24222 Schwentinental

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   J. Rathlev, September 2024
   Vers. 1 - uses inkscape for the conversion
   Vers. 2 (March 2025) - uses the Delphi SVG package by  Ethea
                          https://github.com/EtheaDev/SVGIconImageList
   last modified: March 2025
   *)

unit SvgToPngMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Shell.ShellCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, SVGInterfaces;

const
  Vers = '2.1.2';
  CopRgt = '© 2024-2025 Dr. J. Rathlev, D-24222 Schwentinental';
  EmailAdr = 'kontakt(a)rathlev-home.de';

type
  TMainForm = class(TForm)
    Label1: TLabel;
    btnImgDir: TSpeedButton;
    edtImgDir: TComboBox;
    bbConvert: TBitBtn;
    bbInfo: TBitBtn;
    bbExit: TBitBtn;
    StatusBar: TStatusBar;
    btSelectAll: TBitBtn;
    btSelectNone: TBitBtn;
    edtPngDir: TComboBox;
    Label2: TLabel;
    btnPngDir: TSpeedButton;
    paStatus: TPanel;
    paMain: TPanel;
    meStatus: TMemo;
    spStatus: TSplitter;
    OpenDialog: TOpenDialog;
    rgSize: TRadioGroup;
    lvFiles: TListView;
    pbxSvg: TPaintBox;
    rgFormat: TRadioGroup;
    cbSuffix: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bbInfoClick(Sender: TObject);
    procedure btnImgDirClick(Sender: TObject);
    procedure btSelectAllClick(Sender: TObject);
    procedure btSelectNoneClick(Sender: TObject);
    procedure bbExitClick(Sender: TObject);
    procedure bbConvertClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtImgDirCloseUp(Sender: TObject);
    procedure btnPngDirClick(Sender: TObject);
    procedure edtPngDirCloseUp(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure rgSizeClick(Sender: TObject);
    procedure lvFilesCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvFilesColumnClick(Sender: TObject; Column: TListColumn);
    procedure spStatusMoved(Sender: TObject);
    procedure pbxSvgPaint(Sender: TObject);
    procedure lvFilesClick(Sender: TObject);
  private
    { Private-Deklarationen }
    AppPath,IniName,
    LastPath,LastDest,
    DefPath : string;
    ImgSize : integer;
    FCol: integer;
    FReverse: boolean;
    IconSvg: ISVG;
    procedure ShowStatus;
    procedure UpdateDirList;
    function GetImageSize (const Filename : string) : string;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.Types, System.Masks, System.IniFiles, System.DateUtils, System.Math, System.Character,
  SVGIconUtils, NumberUtils, GnuGetText, InitProg, WinShell, ShellDirDlg, PathUtils, ListUtils,
  WinUtils, MsgDialogs, StringUtils, GraphUtils;

const
  PngExt = 'png';
  PngSubDir = PngExt;
  SvgMask = '*.svg';

  IniExt = 'ini';

  (* INI-Sektionen *)
  CfGSekt = 'Config';
  ImgDirSekt = 'ImageDirs';
  DestSekt   = 'PngDirs';

  iniTop      = 'Top';
  iniLeft     = 'Left';
  iniHeight   = 'Height';
  iniWidth    = 'Width';
  iniStatus   = 'StatusHeight';
  iniLast     = 'LastDir';
  iniDest     = 'LastDest';
  iniSize     = 'PngSize';
  iniFormat   = 'PngFormat';
  iniSuffix   = 'Suffix';

  ImgSizes : array[0..8] of integer = (16,24,32,48,64,128,256,512,1024);

{ ------------------------------------------------------------------- }
procedure TMainForm.FormCreate(Sender: TObject);
var
  IniFile : TMemIniFile;
  i       : integer;
begin
  TranslateComponent(self);
  InitPaths(AppPath,DefPath);
  IniName:=Erweiter(AppPath,PrgName,IniExt);
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    Top:=ReadInteger(CfgSekt,iniTop,Top);
    Left:=ReadInteger(CfgSekt,iniLeft,Left);
    ClientHeight:=ReadInteger(CfgSekt,iniHeight,ClientHeight);
    ClientWidth:=ReadInteger(CfgSekt,iniWidth,ClientWidth);
    with paStatus do Height:=ReadInteger(CfgSekt,iniStatus,Height);
    LastPath:=ReadString(CfgSekt,IniLast,DefPath);
    LastDest:=ReadString(CfgSekt,IniDest,'png');
    ImgSize:=ReadInteger(CfgSekt,iniSize,256);
    rgFormat.ItemIndex:=ReadInteger(CfgSekt,iniFormat,0);
    cbSuffix.Checked:=ReadBool(CfgSekt,iniSuffix,true);
    end;
  LoadHistory(IniFile,ImgDirSekt,edtImgDir);
  LoadHistory(IniFile,DestSekt,edtPngDir);
  IniFile.Free;
  for i:=0 to High(ImgSizes) do if ImgSize=ImgSizes[i] then Break;
  if i>High(ImgSizes) then begin
    i:=6; ImgSize:=256;
    end;
  rgSize.ItemIndex:=i;
  FCol:=0; FReverse:=false;
  with pbxSvg do Width:=Height;
  IconSvg:=GlobalSVGFactory.NewSvg;
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  IniFile : TMemIniFile;
begin
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    WriteInteger(CfgSekt,iniTop,Top);
    WriteInteger(CfgSekt,iniLeft,Left);
    WriteInteger(CfgSekt,iniHeight,ClientHeight);
    WriteInteger(CfgSekt,iniWidth,ClientWidth);
    WriteInteger(CfgSekt,iniStatus,paStatus.Height);
    WriteString(CfgSekt,IniLast,edtImgDir.Text);
    WriteString(CfgSekt,IniDest,edtPngDir.Text);
    WriteInteger(CfgSekt,iniSize,ImgSize);
    WriteInteger(CfgSekt,iniFormat,rgFormat.ItemIndex);
    WriteBool(CfgSekt,iniSuffix,cbSuffix.Checked);
    end;
  SaveHistory(IniFile,ImgDirSekt,true,edtImgDir);
  SaveHistory(IniFile,DestSekt,true,edtPngDir);
  with IniFile do begin
    UpdateFile; Free;
    end;
  end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  with lvFiles do begin
    Column[1].Width:=120;
    Column[2].Width:=70;
    Column[3].Width:=70;
    Column[0].Width:=Width-285;
    end;
  end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  AddToHistory(edtImgDir,LastPath);
  AddToHistory(edtPngDir,LastDest);
  UpdateDirList;
  with lvFiles do if Items.Count>0 then Items[0].Selected:=true;
  ShowStatus;
  bbConvert.SetFocus;
  end;

procedure TMainForm.lvFilesClick(Sender: TObject);
begin
  pbxSvg.Invalidate;
  ShowStatus;
  end;

procedure TMainForm.lvFilesColumnClick(Sender: TObject; Column: TListColumn);
begin
  if Column.Index=FCol then FReverse:=not FReverse
  else FReverse:=false;
  FCol:=Column.Index;
  lvFiles.AlphaSort;
  end;

procedure TMainForm.lvFilesCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var
  dt1,dt2 : TDateTime;
  n1,n2   : int64;
begin
  if FCol=0 then Compare:=CompareText(Item1.Caption,Item2.Caption)
  else if (FCol=1) and (Item1.SubItems.Count>0) then begin  // Date
    if not TryStrToDateTime(Item1.SubItems[0],dt1) then dt1:=0;
    if not TryStrToDateTime(Item2.SubItems[0],dt2) then dt2:=0;
    Compare:=CompareDateTime(dt1,dt2);
    end
  else if (Item1.SubItems.Count>1) then begin // Size
    if not StrToSize(Item1.SubItems[1],n1) then n1:=0;
    if not StrToSize(Item2.SubItems[1],n2) then n2:=0;
    Compare:=CompareValue(n1,n2);
    end;
  if FReverse then Compare:=-Compare;
  end;

procedure TMainForm.pbxSvgPaint(Sender: TObject);
var
  sn : string;
begin
  with lvFiles do if SelCount>0 then begin
    sn:=Selected.Caption;
    sn:=AddPath(edtImgDir.Text,sn);
    with IconSvg do begin
      LoadFromFile(sn);
      PaintTo(pbxSvg.Canvas.Handle,TRectF.Create(2,2,pbxSvg.Width-2,pbxSvg.Height-2),true);
      end;
    end;
  end;

procedure TMainForm.rgSizeClick(Sender: TObject);
begin
  ImgSize:=ImgSizes[rgSize.ItemIndex];
  end;

procedure TMainForm.ShowStatus;
begin
  with lvFiles do if Items.Count>0 then begin
    if SelCount>0 then Statusbar.SimpleText:=GetPluralString(_('image of'),_('images of'),SelCount)+
      Format(_(' %u selected'),[Items.Count])
    else Statusbar.SimpleText:=GetPluralString(_('matching image'),_('matching images'),Items.Count);
    end
  else Statusbar.SimpleText:='';
  end;

procedure TMainForm.spStatusMoved(Sender: TObject);
begin
  with pbxSvg do Width:=Height;
  end;

procedure TMainForm.bbExitClick(Sender: TObject);
begin
  Cursor:=crDefault;
  Close;
  end;

procedure TMainForm.bbInfoClick(Sender: TObject);
begin
  InfoDialog(TopLeftPos(bbExit),Caption+' - '+GetVersion(3,Vers)
    +' ('+DateToStr(FileDateToDateTime(FileAge(Application.ExeName)))+')'+sLineBreak
    +CopRgt+sLineBreak+'E-Mail: '+EMailAdr);
  end;

procedure TMainForm.btnImgDirClick(Sender: TObject);
var
  s : string;
begin
  s:=GetExistingParentPath(edtImgDir.Text,DefPath);
  if ShellDirDialog.Execute (_('Directory with SVG images'),true,true,false,'',s) then begin
    AddToHistory(edtImgDir,s);
    UpdateDirList;
    ShowStatus;
    end;
  end;

procedure TMainForm.btnPngDirClick(Sender: TObject);
var
  s : string;
begin
  s:=edtPngDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(edtImgDir.Text,s);
  s:=GetExistingParentPath(s,DefPath);
  if ShellDirDialog.Execute (_('Directory for PNG images'),true,true,false,'',s) then begin
    s:=MakeRelativePath(edtImgDir.Text,s);
    AddToHistory(edtPngDir,s);
    end;
  end;

function TMainForm.GetImageSize (const Filename : string) : string;
var
  sn,sv,s : string;
  sr  : RawByteString;
  n,nh,w,h  : integer;
  fs : TFileStream;
const
  vb = 'viewBox';
  wd = 'width';
  hg = 'height';

  function GetNxtQuotedStr (const s : string; Pos : integer) : string;
  var
    n,m : integer;
  begin
    n:=Pos; Result:='';
    while (n<=length(s)) and (s[n]<>'=') do inc(n);
    while (n<=length(s)) and (s[n]<>'"') do inc(n);
    m:=succ(n);
    if length(s)>=m then begin
      while (m<=length(s)) and (s[m]<>'"') do inc(m);
      if s[m]='"' then Result:=TrimRight(copy(s,n+1,m-n-1));
      end
    end;

  function ReadNxtInt (var s : string) : integer;
  var
    i,ic : integer;
  begin
    i:=1;
    while (i<=length(s)) and TCharacter.IsDigit(s[i]) do inc(i);
    val(copy(s,1,pred(i)),Result,ic);
    if ic>0 then ReadNxtInt:=0;
    while (i<=length(s)) and (s[i]<>' ') do inc(i);
    delete(s,1,i);
    end;

begin
  Result:='';
  sn:=AddPath(edtImgDir.Text,Filename);
  if FileExists(sn) then begin
    fs:=TFileStream.Create(sn,fmOpenRead or fmShareDenyWrite);
    try
      with fs do if Size>0 then begin
        SetLength(sr,Size);
        Read(sr[1],Size);
        end
    finally
      fs.Free;
      end;
    s:=RawByteToUnicode(sr,cpUtf8);
    n:=TextPos(vb,s);
    if n>0 then begin
      sv:=GetNxtQuotedStr(s,n);
      ReadNxtInt(sv); ReadNxtInt(sv);
      w:=ReadNxtInt(sv); h:=ReadNxtInt(sv);
      if (w>0) and (h>0) then Result:=IntToStr(w)+'x'+IntToStr(h);
      end
    else begin
      n:=TextPos(wd,s);
      if n>0 then begin
        nh:=TextPos(hg,s);
        if nh>0 then begin
          sv:=GetNxtQuotedStr(s,n);
          w:=ReadNxtInt(sv);
          sv:=GetNxtQuotedStr(s,nh);
          h:=ReadNxtInt(sv);
          if (w>0) and (h>0) then Result:=IntToStr(w)+'x'+IntToStr(h);
          end
        end;
      end;
    end;
  end;

procedure TMainForm.UpdateDirList;
var
  FileInfo   : TSearchRec;
  Findresult : integer;
  sp : string;
begin
  with edtImgDir do sp:=GetExistingParentPath(Items[ItemIndex],DefPath);
  AddToHistory(edtImgDir,sp);
  lvFiles.Clear;
  FindResult:=FindFirst(AddPath(sp,SvgMask),faArchive+faReadOnly+faHidden+faSysfile+faNormal,FileInfo);
  while FindResult=0 do with FileInfo do begin
    if NotSpecialDir(Name) then begin
      with lvFiles.Items.Add do begin
        Caption:=Name;
        SubItems.Add(DateTimeToStr(TimeStamp));
        SubItems.Add(SizeToStr(Size));
        SubItems.Add(GetImageSize(Name));
        end;
      end;
    FindResult:=FindNext (FileInfo);
    end;
  FindClose(FileInfo);
  with lvFiles do if Items.Count>0 then ItemIndex:=0;
  pbxSvg.Invalidate;
  end;

procedure TMainForm.edtImgDirCloseUp(Sender: TObject);
begin
  UpdateHistory(edtImgDir);
  UpdateDirList;
  ShowStatus;
  end;

procedure TMainForm.edtPngDirCloseUp(Sender: TObject);
begin
  UpdateHistory(edtPngDir);
  end;

procedure TMainForm.btSelectNoneClick(Sender: TObject);
var
  i : integer;
begin
  with lvFiles do for i:=0 to Items.Count-1 do Items[i].Selected:=false;
  ShowStatus;
  end;

procedure TMainForm.btSelectAllClick(Sender: TObject);
var
  i : integer;
begin
  with lvFiles do for i:=0 to Items.Count-1 do Items[i].Selected:=true;
  ShowStatus;
  end;

procedure TMainForm.bbConvertClick(Sender: TObject);
var
  sd,sn,sp,s,se : string;
  i,n,k  : integer;

  function ConvertToPng (Size : integer; const SvgName,PngName : string) : boolean;
  var
    w,h : integer;
  begin
    Result:=false;
    if FileExists(SvgName) then begin
      try
        IconSvg.LoadFromFile(SvgName);
        w:=round(IconSvg.Width); h:=round(IconSvg.Height);
        if rgFormat.ItemIndex=2 then begin   // check for longest
          if w>h then begin
            h:=MulDiv(h,Size,w); w:=Size;
            end
          else begin
            w:=MulDiv(w,Size,h); h:=Size;
            end;
          end
        else if rgFormat.ItemIndex=1 then begin // fixed height
          w:=MulDiv(w,Size,h); h:=Size;
          end
        else begin     // fixed width
          h:=MulDiv(h,Size,w); w:=Size;
          end;
        SVGExportToPng(w,h,IconSvg,PngName);
        Result:=true;
      except
        on E:Exception do se:=E.Message;
        end;
      end;
    end;

begin
  Cursor:=crHourglass;
  sd:=edtImgDir.Text; sp:=edtPngDir.Text;
  if not ContainsFullPath(sp) then sp:=AddPath(sd,sp);
  ForceDirectories(sp);
  meStatus.Clear;
  n:=0;
  with lvFiles do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
    sn:=Items[i].Caption;
    s:=NewExt(sn,PngExt);
    if cbSuffix.Checked then s:=InsertNameSuffix(sn,'-'+ZStrInt(ImgSize,4));
    k:=meStatus.Lines.Add(_('Converting')+ColSpace+sn+' -> '+AddPath(edtPngDir.Text,s));
    s:=AddPath(sp,s); se:='';
    if ConvertToPng(ImgSize,AddPath(sd,sn),s) then begin
      s:=_('Done'); inc(n);
      end
    else s:='*** '+_('Error')+' ***';
    with meStatus do begin
      Lines[k]:=Lines[k]+' -> '+s;
      if not se.IsEmpty then Lines.Add('  *** '+se);
      end;
    end;
  if n>0 then begin
    meStatus.Lines.Add(' => '+Format(_('%u png images were created'),[n]));
    end
  else meStatus.Lines.Add('  *** '+_('No images selected'));
  meStatus.Lines.Add(' => '+_('Done'));
  Cursor:=crDefault;
  end;

end.
