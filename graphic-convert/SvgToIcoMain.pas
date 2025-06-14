(* Convert svg images to icons with multiple sizes

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

unit SvgToIcoMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Shell.ShellCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

const
  Vers = '2.0.0';
  CopRgt = '© 2024-2025 Dr. J. Rathlev, D-24222 Schwentinental';
  EmailAdr = 'kontakt(a)rathlev-home.de';

  MaxSizes = 4;

type
  TMainForm = class(TForm)
    Label1: TLabel;
    btnImgDir: TSpeedButton;
    edtImgDir: TComboBox;
    bbConvert: TBitBtn;
    ShellListView: TShellListView;
    ShellComboBox: TShellComboBox;
    bbInfo: TBitBtn;
    bbExit: TBitBtn;
    StatusBar: TStatusBar;
    btSelectAll: TBitBtn;
    btSelectNone: TBitBtn;
    edtIcoDir: TComboBox;
    Label2: TLabel;
    btnPngDir: TSpeedButton;
    paStatus: TPanel;
    paMain: TPanel;
    meStatus: TMemo;
    spStatus: TSplitter;
    gbSizes: TGroupBox;
    cb032: TCheckBox;
    cb064: TCheckBox;
    cb128: TCheckBox;
    cb256: TCheckBox;
    OpenDialog: TOpenDialog;
    cb048: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShellListViewAddFolder(Sender: TObject; AFolder: TShellFolder;
      var CanAdd: Boolean);
    procedure bbInfoClick(Sender: TObject);
    procedure btnImgDirClick(Sender: TObject);
    procedure btSelectAllClick(Sender: TObject);
    procedure btSelectNoneClick(Sender: TObject);
    procedure bbExitClick(Sender: TObject);
    procedure bbConvertClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtImgDirCloseUp(Sender: TObject);
    procedure btnPngDirClick(Sender: TObject);
    procedure edtIcoDirCloseUp(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ShellListViewClick(Sender: TObject);
  private
    { Private-Deklarationen }
    AppPath,IniName,
    LastPath,LastDest,
    DefPath,FileMask : string;
    PngSizes : array [0..MaxSizes] of TCheckBox;
    procedure ShowStatus;
    procedure UpdateDirList;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.Types, System.Masks, System.IniFiles, Vcl.Graphics, Vcl.Imaging.PngImage,
  SVGInterfaces, SVGIconUtils,
  GnuGetText, InitProg, WinShell, ShellDirDlg, PathUtils, ListUtils, WinUtils,
  MsgDialogs, StringUtils, GraphUtils;

const
  PngExt = 'png';
  PngSubDir = PngExt;
  IcoExt = 'ico';
  SvgMask = '*.svg';

  IniExt = 'ini';

  (* INI-Sektionen *)
  CfGSekt = 'Config';
  ImgDirSekt = 'ImageDirs';
  DestSekt   = 'IcoDirs';

  iniTop      = 'Top';
  iniLeft     = 'Left';
  iniHeight   = 'Height';
  iniWidth    = 'Width';
  iniStatus   = 'StatusHeight';
  iniLast     = 'LastDir';
  iniDest     = 'LastDest';
  iniSizes    = 'Sizes';

  BitMask : array [0..MaxSizes] of word = (1,2,4,8,16);

{ ------------------------------------------------------------------- }
procedure TMainForm.FormCreate(Sender: TObject);
var
  IniFile : TMemIniFile;
  n,i     : integer;
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
    LastDest:=ReadString(CfgSekt,IniDest,'ico');
    n:=ReadInteger(CfgSekt,iniSizes,15);
    end;
  LoadHistory(IniFile,ImgDirSekt,edtImgDir);
  LoadHistory(IniFile,DestSekt,edtIcoDir);
  IniFile.Free;
  FileMask:=SvgMask;
  PngSizes[0]:=cb032; PngSizes[1]:=cb048; PngSizes[2]:=cb064; PngSizes[3]:=cb128; PngSizes[4]:=cb256;
  for i:=0 to MaxSizes do PngSizes[i].Checked:=n and BitMask[i]<>0;
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  IniFile : TMemIniFile;
  n,i : integer;
begin
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    WriteInteger(CfgSekt,iniTop,Top);
    WriteInteger(CfgSekt,iniLeft,Left);
    WriteInteger(CfgSekt,iniHeight,ClientHeight);
    WriteInteger(CfgSekt,iniWidth,ClientWidth);
    WriteInteger(CfgSekt,iniStatus,paStatus.Height);
    WriteString(CfgSekt,IniLast,edtImgDir.Text);
    WriteString(CfgSekt,IniDest,edtIcoDir.Text);
    n:=0;
    for i:=0 to MaxSizes do if PngSizes[i].Checked then n:=n or BitMask[i];
    WriteInteger(CfgSekt,iniSizes,n);
    end;
  SaveHistory(IniFile,ImgDirSekt,true,edtImgDir);
  SaveHistory(IniFile,DestSekt,true,edtIcoDir);
  with IniFile do begin
    UpdateFile; Free;
    end;
  end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  with ShellListView do SetColWidths([GetWidth-46,12,12,18]);
  end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  AddToHistory(edtImgDir,LastPath);
  AddToHistory(edtIcoDir,LastDest);
  UpdateDirList;
  with ShellListView do if Items.Count>0 then Items[0].Selected:=true;
  ShowStatus;
  end;

procedure TMainForm.ShowStatus;
begin
  with ShellListView do if Items.Count>0 then begin
    if SelCount>0 then Statusbar.SimpleText:=GetPluralString(_('image of'),_('images of'),SelCount)+
      Format(_(' %u selected'),[Items.Count])
    else Statusbar.SimpleText:=GetPluralString(_('matching image'),_('matching images'),Items.Count);
    end
  else Statusbar.SimpleText:='';
  end;

procedure TMainForm.ShellListViewAddFolder(Sender: TObject;
  AFolder: TShellFolder; var CanAdd: Boolean);
begin
  CanAdd:=MatchesMask(AFolder.DisplayName,FileMask);
  end;

procedure TMainForm.ShellListViewClick(Sender: TObject);
begin
  ShowStatus;
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
  s:=edtIcoDir.Text;
  if not ContainsFullPath(s) then s:=AddPath(edtImgDir.Text,s);
  s:=GetExistingParentPath(s,DefPath);
  if ShellDirDialog.Execute (_('Directory for PNG images'),true,true,false,'',s) then begin
    s:=MakeRelativePath(edtImgDir.Text,s);
    AddToHistory(edtIcoDir,s);
    end;
  end;

procedure TMainForm.UpdateDirList;
var
  sp : string;
begin
  with edtImgDir do sp:=Items[ItemIndex];
  ShellComboBox.Path:=GetExistingParentPath(sp,DefPath);
  end;

procedure TMainForm.edtImgDirCloseUp(Sender: TObject);
begin
  UpdateHistory(edtImgDir);
  UpdateDirList;
  ShowStatus;
  end;

procedure TMainForm.edtIcoDirCloseUp(Sender: TObject);
begin
  UpdateHistory(edtIcoDir);
  end;

procedure TMainForm.btSelectNoneClick(Sender: TObject);
var
  i : integer;
begin
  with ShellListView do for i:=0 to Items.Count-1 do Items[i].Selected:=false;
  ShowStatus;
  end;

procedure TMainForm.btSelectAllClick(Sender: TObject);
var
  i : integer;
begin
  with ShellListView do for i:=0 to Items.Count-1 do Items[i].Selected:=true;
  ShowStatus;
  end;

procedure TMainForm.bbConvertClick(Sender: TObject);
var
  sd,sn,sp,s,sv,ss : string;
  i,m,k      : integer;
  ok         : boolean;
  PngList    : TList;
  sPng       : TMemoryStream;
  LSVG       : ISVG;

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

  function ExportToPng (ASize : Integer; FSVG: ISVG; sPng : TMemoryStream) : boolean;
  var
    LImagePng: TPngImage;
    LBitmap: TBitmap;
  begin
    Result:=false;
    LBitmap := nil;
    LImagePng := nil;
    try
      LBitmap := TBitmap.Create;
      LBitmap.PixelFormat := TPixelFormat.pf32bit;   // 32bit bitmap
      LBitmap.AlphaFormat := TAlphaFormat.afDefined; // Enable alpha channel

      LBitmap.SetSize(ASize, ASize);

      // Fill background with transparent
      LBitmap.Canvas.Brush.Color := clNone;
      LBitmap.Canvas.FillRect(Rect(0, 0, ASize, ASize));

      FSVG.PaintTo(LBitmap.Canvas.Handle, TRectF.Create(0, 0, ASize, ASize));

      LImagePng := PNG4TransparentBitMap(LBitmap);
      LImagePng.SaveToStream(sPng);
      sPng.Position:=0;
      Result:=true;
    finally
      LBitmap.Free;
      LImagePng.Free;
      end;
    end;

begin
  Cursor:=crHourglass;
  LSVG:=GlobalSVGFactory.NewSvg;
  sd:=edtImgDir.Text; sp:=edtIcoDir.Text;
  if not ContainsFullPath(sp) then sp:=AddPath(sd,sp);
  ForceDirectories(sp);
  PngList:=TList.Create;
  meStatus.Clear;
  with ShellListView do for i:=0 to Items.Count-1 do if Items[i].Selected then begin
    sn:=Folders[i].DisplayName;
    sv:=AddPath(sd,sn); ok:=false;
    k:=meStatus.Lines.Add(_('Creating icon from ')+ColSpace+sn);
    if FileExists(sv) then begin
      try
        LSVG.LoadFromFile(sv);
        ss:=LSVG.Source;
        ok:=true;
      except
        on Exception do ok:=false;
        end;
      if ok then begin
        for m:=0 to MaxSizes do with PngSizes[m] do if Checked then begin
          s:=IntToStr(Tag);
          if PngList.Count>0 then s:=','+s else s:=' ('+s;
          with meStatus do Lines[k]:=Lines[k]+s;
          sPng:=TMemoryStream.Create;
          LSVG.Clear;        // force Img32.SVG.Reader to perform a new rendering
          LSVG.Source:=ss;
          ok:=ExportToPng(Tag,LSVG,sPng);
          if ok then PngList.Add(sPng) else Break;
          end;
        if ok then begin
          with meStatus do Lines[k]:=Lines[k]+')';
          end;
        if CreateIconFromPngStreamList(AddPath(sp,NewExt(sn,IcoExt)),PngList) then
          with meStatus do Lines[k]:=Lines[k]+' => '+_('Done')
        else meStatus.Lines.Add('  *** '+_('Error'));
        FreeList(PngList);
        end
      else with meStatus do Lines[k]:=Lines[k]+' *** '+_('Error loading file!');
      end
    else begin
      with meStatus do Lines[k]:=Lines[k]+' *** '+_('File not found!');
      end;
    end;
  Cursor:=crDefault;
  PngList.Free;
  end;

end.
